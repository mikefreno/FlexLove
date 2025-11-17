-- Test font cache optimizations
package.path = package.path .. ";./?.lua;./modules/?.lua"

local luaunit = require("testing.luaunit")
local loveStub = require("testing.loveStub")

-- Set up stub before requiring modules
_G.love = loveStub

local utils = require("modules.utils")

TestFontCache = {}

function TestFontCache:setUp()
  utils.clearFontCache()
  utils.resetFontCacheStats()
  love.timer.setTime(0) -- Reset timer for consistent timestamps
end

function TestFontCache:tearDown()
  utils.clearFontCache()
  utils.resetFontCacheStats()
  utils.setFontCacheSize(50) -- Reset to default
end

function TestFontCache:testCacheHitOnRepeatedAccess()
  -- First access should be a miss
  utils.FONT_CACHE.get(16, nil)
  local stats1 = utils.getFontCacheStats()
  luaunit.assertEquals(stats1.misses, 1)
  luaunit.assertEquals(stats1.hits, 0)
  
  -- Second access should be a hit
  utils.FONT_CACHE.get(16, nil)
  local stats2 = utils.getFontCacheStats()
  luaunit.assertEquals(stats2.hits, 1)
  luaunit.assertEquals(stats2.misses, 1)
  
  -- Third access should also be a hit
  utils.FONT_CACHE.get(16, nil)
  local stats3 = utils.getFontCacheStats()
  luaunit.assertEquals(stats3.hits, 2)
  luaunit.assertEquals(stats3.misses, 1)
end

function TestFontCache:testCacheMissOnFirstAccess()
  utils.clearFontCache()
  utils.resetFontCacheStats()
  
  utils.FONT_CACHE.get(24, nil)
  local stats = utils.getFontCacheStats()
  
  luaunit.assertEquals(stats.misses, 1)
  luaunit.assertEquals(stats.hits, 0)
end

function TestFontCache:testLRUEviction()
  utils.setFontCacheSize(3)
  
  -- Load 3 fonts (fills cache) with time steps to ensure different timestamps
  utils.FONT_CACHE.get(10, nil)
  love.timer.step(0.001)
  utils.FONT_CACHE.get(12, nil)
  love.timer.step(0.001)
  utils.FONT_CACHE.get(14, nil)
  love.timer.step(0.001)
  
  local stats1 = utils.getFontCacheStats()
  luaunit.assertEquals(stats1.size, 3)
  luaunit.assertEquals(stats1.evictions, 0)
  
  -- Load 4th font (triggers eviction of font 10 - the oldest)
  utils.FONT_CACHE.get(16, nil)
  
  local stats2 = utils.getFontCacheStats()
  luaunit.assertEquals(stats2.size, 3)
  luaunit.assertEquals(stats2.evictions, 1)
  
  -- Access first font again - it should have been evicted (miss)
  local initialMisses = stats2.misses
  utils.FONT_CACHE.get(10, nil)
  
  local stats3 = utils.getFontCacheStats()
  luaunit.assertEquals(stats3.misses, initialMisses + 1) -- Should be a miss
end

function TestFontCache:testCacheSizeLimitEnforced()
  utils.setFontCacheSize(5)
  
  -- Load 10 fonts
  for i = 1, 10 do
    utils.FONT_CACHE.get(10 + i, nil)
  end
  
  local stats = utils.getFontCacheStats()
  luaunit.assertEquals(stats.size, 5)
  luaunit.assertTrue(stats.evictions >= 5)
end

function TestFontCache:testFontRounding()
  -- Sizes should be rounded: 14.5 and 14.7 should map to same cache entry (15)
  utils.FONT_CACHE.get(14.5, nil)
  local stats1 = utils.getFontCacheStats()
  luaunit.assertEquals(stats1.misses, 1)
  
  utils.FONT_CACHE.get(14.7, nil)
  local stats2 = utils.getFontCacheStats()
  luaunit.assertEquals(stats2.hits, 1) -- Should be a hit because both round to 15
  luaunit.assertEquals(stats2.misses, 1)
end

function TestFontCache:testCacheClear()
  utils.FONT_CACHE.get(16, nil)
  utils.FONT_CACHE.get(18, nil)
  
  local stats1 = utils.getFontCacheStats()
  luaunit.assertEquals(stats1.size, 2)
  
  utils.clearFontCache()
  
  local stats2 = utils.getFontCacheStats()
  luaunit.assertEquals(stats2.size, 0)
end

function TestFontCache:testCacheKeyWithPath()
  -- Different cache keys for same size, different paths
  utils.FONT_CACHE.get(16, nil)
  utils.FONT_CACHE.get(16, "fonts/custom.ttf")
  
  local stats = utils.getFontCacheStats()
  luaunit.assertEquals(stats.misses, 2) -- Both should be misses
  luaunit.assertEquals(stats.size, 2)
end

function TestFontCache:testPreloadFont()
  utils.clearFontCache()
  utils.resetFontCacheStats()
  
  -- Preload multiple sizes
  utils.preloadFont(nil, {12, 14, 16, 18})
  
  local stats1 = utils.getFontCacheStats()
  luaunit.assertEquals(stats1.size, 4)
  luaunit.assertEquals(stats1.misses, 4) -- All preloads are misses
  
  -- Now access one - should be a hit
  utils.FONT_CACHE.get(16, nil)
  local stats2 = utils.getFontCacheStats()
  luaunit.assertEquals(stats2.hits, 1)
end

function TestFontCache:testCacheHitRate()
  utils.clearFontCache()
  utils.resetFontCacheStats()
  
  -- 1 miss, 9 hits = 90% hit rate
  utils.FONT_CACHE.get(16, nil)
  for i = 1, 9 do
    utils.FONT_CACHE.get(16, nil)
  end
  
  local stats = utils.getFontCacheStats()
  luaunit.assertEquals(stats.hitRate, 0.9)
end

function TestFontCache:testSetCacheSizeEvictsExcess()
  utils.setFontCacheSize(10)
  
  -- Load 10 fonts
  for i = 1, 10 do
    utils.FONT_CACHE.get(10 + i, nil)
  end
  
  local stats1 = utils.getFontCacheStats()
  luaunit.assertEquals(stats1.size, 10)
  
  -- Reduce cache size - should trigger evictions
  utils.setFontCacheSize(5)
  
  local stats2 = utils.getFontCacheStats()
  luaunit.assertEquals(stats2.size, 5)
  luaunit.assertTrue(stats2.evictions >= 5)
end

function TestFontCache:testMinimalCacheSize()
  -- Minimum cache size is 1
  utils.setFontCacheSize(0)
  utils.FONT_CACHE.get(16, nil)
  
  local stats = utils.getFontCacheStats()
  luaunit.assertEquals(stats.size, 1)
end

-- Run tests if executed directly
if arg and arg[0]:find("font_cache_test%.lua$") then
  os.exit(luaunit.LuaUnit.run())
end

return TestFontCache
