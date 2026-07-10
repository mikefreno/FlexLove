-- Test suite for FontCache.lua (extracted from utils.lua)
-- Verifies the focused module produces identical output to the old utils
-- font-cache functions. Uses the loveStub font operations.

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")
ErrorHandler.init({})

local utils = require("modules.utils")
local FontCache = require("modules.FontCache")
utils.init({ ErrorHandler = ErrorHandler })

TestFontCache = {}

function TestFontCache:testResolveFontPath_DirectPath()
  luaunit.assertEquals(FontCache.resolveFontPath("path/to/font.ttf", nil, nil), "path/to/font.ttf")
end

function TestFontCache:testResolveFontPath_Nil()
  luaunit.assertNil(FontCache.resolveFontPath(nil, nil, nil))
end

function TestFontCache:testResolveFontPath_ThemeFont()
  local mockThemeManager = {
    getTheme = function()
      return { fonts = { mainFont = "themes/fonts/main.ttf" } }
    end,
  }
  luaunit.assertEquals(FontCache.resolveFontPath("mainFont", "button", mockThemeManager), "themes/fonts/main.ttf")
end

function TestFontCache:testResolveFontPath_ThemeFontNotFound_FallsBackToDirect()
  local mockThemeManager = {
    getTheme = function()
      return { fonts = {} }
    end,
  }
  luaunit.assertEquals(FontCache.resolveFontPath("unknownFont", "button", mockThemeManager), "unknownFont")
end

function TestFontCache:testResolveFontPath_ThemeComponentDefault()
  local mockThemeManager = {
    getDefaultFontFamily = function()
      return "themes/fonts/default.ttf"
    end,
  }
  luaunit.assertEquals(FontCache.resolveFontPath(nil, "button", mockThemeManager), "themes/fonts/default.ttf")
end

function TestFontCache:testGetFont_WithTextSize()
  local font = FontCache.getFont(16, nil, nil, nil)
  luaunit.assertNotNil(font)
end

function TestFontCache:testGetFont_WithoutTextSize()
  local font = FontCache.getFont(nil, nil, nil, nil)
  luaunit.assertNotNil(font)
end

function TestFontCache:testGetFont_CacheBucketing()
  -- Sizes 11 and 12 bucket to the same entry (round to nearest 2 under 20).
  FontCache.clearFontCache()
  local f1 = FontCache.getFont(11)
  local f2 = FontCache.getFont(12)
  luaunit.assertEquals(f1, f2)
  local stats = FontCache.getFontCacheStats()
  luaunit.assertTrue(stats.hits >= 1)
end

function TestFontCache:testFontCacheStats()
  FontCache.clearFontCache()
  FontCache.resetFontCacheStats()
  FontCache.getFont(20)
  local stats = FontCache.getFontCacheStats()
  luaunit.assertEquals(stats.misses, 1)
  luaunit.assertEquals(stats.size, 1)
  luaunit.assertTrue(stats.hitRate >= 0)
end

function TestFontCache:testSetFontCacheSize_Evicts()
  FontCache.clearFontCache()
  FontCache.resetFontCacheStats()
  FontCache.setFontCacheSize(2)
  FontCache.getFont(20)
  FontCache.getFont(24)
  FontCache.getFont(28)
  local stats = FontCache.getFontCacheStats()
  luaunit.assertTrue(stats.size <= 2)
  luaunit.assertTrue(stats.evictions >= 1)
end

function TestFontCache:testClearFontCache()
  FontCache.getFont(20)
  FontCache.clearFontCache()
  local stats = FontCache.getFontCacheStats()
  luaunit.assertEquals(stats.size, 0)
end

function TestFontCache:testResetFontCacheStats()
  FontCache.getFont(20)
  FontCache.resetFontCacheStats()
  local stats = FontCache.getFontCacheStats()
  luaunit.assertEquals(stats.hits, 0)
  luaunit.assertEquals(stats.misses, 0)
  luaunit.assertEquals(stats.evictions, 0)
end

function TestFontCache:testPreloadFont()
  FontCache.clearFontCache()
  FontCache.resetFontCacheStats()
  FontCache.preloadFont(nil, { 10, 12, 14 })
  local stats = FontCache.getFontCacheStats()
  luaunit.assertTrue(stats.size >= 3)
end

function TestFontCache:testFONT_CACHEHasMethods()
  luaunit.assertNotNil(FontCache.FONT_CACHE.get)
  luaunit.assertNotNil(FontCache.FONT_CACHE.getFont)
end

function TestFontCache:testAliasParity()
  luaunit.assertEquals(utils.getFont, FontCache.getFont)
  luaunit.assertEquals(utils.resolveFontPath, FontCache.resolveFontPath)
  luaunit.assertEquals(utils.preloadFont, FontCache.preloadFont)
  luaunit.assertEquals(utils.clearFontCache, FontCache.clearFontCache)
  luaunit.assertEquals(utils.setFontCacheSize, FontCache.setFontCacheSize)
  luaunit.assertEquals(utils.getFontCacheStats, FontCache.getFontCacheStats)
  luaunit.assertEquals(utils.resetFontCacheStats, FontCache.resetFontCacheStats)
  -- utils.FONT_CACHE must be the SAME table instance as FontCache.FONT_CACHE
  luaunit.assertEquals(utils.FONT_CACHE, FontCache.FONT_CACHE)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
