-- Test suite for PathValidator.lua (extracted from utils.lua)
-- Verifies the focused module produces identical output to the old utils
-- path-validation functions.

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")
ErrorHandler.init({})

local utils = require("modules.utils")
local PathValidator = require("modules.PathValidator")
utils.init({ ErrorHandler = ErrorHandler })

TestPathValidator = {}

function TestPathValidator:testNormalizePath_Whitespace()
  luaunit.assertEquals(PathValidator.normalizePath("  /path/to/file  "), "/path/to/file")
  luaunit.assertEquals(PathValidator.normalizePath("\t/path/to/file\t"), "/path/to/file")
end

function TestPathValidator:testNormalizePath_Backslashes()
  luaunit.assertEquals(PathValidator.normalizePath("C:\\path\\to\\file"), "C:/path/to/file")
  luaunit.assertEquals(PathValidator.normalizePath("path\\to\\file"), "path/to/file")
end

function TestPathValidator:testNormalizePath_DuplicateSlashes()
  luaunit.assertEquals(PathValidator.normalizePath("/path//to///file"), "/path/to/file")
end

function TestPathValidator:testNormalizePath_Combined()
  luaunit.assertEquals(PathValidator.normalizePath("  C:\\path\\\\to///file  "), "C:/path/to/file")
end

function TestPathValidator:testSanitizePath()
  luaunit.assertEquals(PathValidator.sanitizePath(nil), "")
  luaunit.assertEquals(PathValidator.sanitizePath("  /a/b/  "), "/a/b")
  luaunit.assertEquals(PathValidator.sanitizePath("a\\b"), "a/b")
  luaunit.assertEquals(PathValidator.sanitizePath("a//b"), "a/b")
end

function TestPathValidator:testIsPathSafe_Empty()
  local ok, reason = PathValidator.isPathSafe("")
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(reason)
end

function TestPathValidator:testIsPathSafe_Traversal()
  local ok, reason = PathValidator.isPathSafe("../etc/passwd")
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(reason)
end

function TestPathValidator:testIsPathSafe_EncodedTraversal()
  local ok, reason = PathValidator.isPathSafe("foo%2e%2e/bar")
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(reason)
end

function TestPathValidator:testIsPathSafe_NullBytes()
  local ok, reason = PathValidator.isPathSafe("foo\0bar")
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(reason)
end

function TestPathValidator:testIsPathSafe_Good()
  local ok = PathValidator.isPathSafe("themes/fonts/main.ttf")
  luaunit.assertTrue(ok)
end

function TestPathValidator:testIsPathSafe_WithBaseDirInside()
  local ok = PathValidator.isPathSafe("images/icon.png", "/app/assets")
  luaunit.assertTrue(ok)
end

function TestPathValidator:testIsPathSafe_WithBaseDirOutside()
  local ok, reason = PathValidator.isPathSafe("/etc/passwd", "/app/assets")
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(reason)
end

function TestPathValidator:testValidatePath_Empty()
  local ok, err = PathValidator.validatePath("")
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(err)
end

function TestPathValidator:testValidatePath_TooLong()
  local long = string.rep("a", 5000)
  local ok, err = PathValidator.validatePath(long, { maxLength = 4096 })
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(err)
end

function TestPathValidator:testValidatePath_DisallowedExtension()
  local ok, err = PathValidator.validatePath("foo.exe", { allowedExtensions = { "png", "ttf" } })
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(err)
end

function TestPathValidator:testValidatePath_AllowedExtension()
  local ok = PathValidator.validatePath("foo.png", { allowedExtensions = { "png", "ttf" } })
  luaunit.assertTrue(ok)
end

function TestPathValidator:testValidatePath_NoExtension()
  local ok, err = PathValidator.validatePath("noext", { allowedExtensions = { "png" } })
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(err)
end

function TestPathValidator:testGetFileExtension()
  luaunit.assertEquals(PathValidator.getFileExtension("foo.PNG"), "png")
  luaunit.assertEquals(PathValidator.getFileExtension("foo"), nil)
  luaunit.assertEquals(PathValidator.getFileExtension(nil), nil)
end

function TestPathValidator:testHasAllowedExtension()
  luaunit.assertTrue(PathValidator.hasAllowedExtension("foo.png", { "png", "ttf" }))
  luaunit.assertFalse(PathValidator.hasAllowedExtension("foo.exe", { "png" }))
  luaunit.assertFalse(PathValidator.hasAllowedExtension("noext", { "png" }))
end

function TestPathValidator:testAliasParity()
  luaunit.assertEquals(utils.normalizePath, PathValidator.normalizePath)
  luaunit.assertEquals(utils.sanitizePath, PathValidator.sanitizePath)
  luaunit.assertEquals(utils.isPathSafe, PathValidator.isPathSafe)
  luaunit.assertEquals(utils.validatePath, PathValidator.validatePath)
  luaunit.assertEquals(utils.getFileExtension, PathValidator.getFileExtension)
  luaunit.assertEquals(utils.hasAllowedExtension, PathValidator.hasAllowedExtension)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
