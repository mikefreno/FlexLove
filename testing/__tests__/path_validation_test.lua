-- Test suite for path validation functions
-- Tests sanitizePath, isPathSafe, validatePath, getFileExtension, hasAllowedExtension

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local utils = require("modules.utils")

-- Test suite for sanitizePath
TestSanitizePath = {}

function TestSanitizePath:testSanitizePath_NilInput()
  local result = utils.sanitizePath(nil)
  luaunit.assertEquals(result, "")
end

function TestSanitizePath:testSanitizePath_EmptyString()
  local result = utils.sanitizePath("")
  luaunit.assertEquals(result, "")
end

function TestSanitizePath:testSanitizePath_Whitespace()
  local result = utils.sanitizePath("  /path/to/file  ")
  luaunit.assertEquals(result, "/path/to/file")
end

function TestSanitizePath:testSanitizePath_Backslashes()
  local result = utils.sanitizePath("C:\\path\\to\\file")
  luaunit.assertEquals(result, "C:/path/to/file")
end

function TestSanitizePath:testSanitizePath_DuplicateSlashes()
  local result = utils.sanitizePath("/path//to///file")
  luaunit.assertEquals(result, "/path/to/file")
end

function TestSanitizePath:testSanitizePath_TrailingSlash()
  local result = utils.sanitizePath("/path/to/dir/")
  luaunit.assertEquals(result, "/path/to/dir")
  
  -- Root should keep trailing slash
  result = utils.sanitizePath("/")
  luaunit.assertEquals(result, "/")
end

function TestSanitizePath:testSanitizePath_MixedIssues()
  local result = utils.sanitizePath("  C:\\path\\\\to///file.txt  ")
  luaunit.assertEquals(result, "C:/path/to/file.txt")
end

-- Test suite for isPathSafe
TestIsPathSafe = {}

function TestIsPathSafe:testIsPathSafe_EmptyPath()
  local safe, reason = utils.isPathSafe("")
  luaunit.assertFalse(safe)
  luaunit.assertStrContains(reason, "empty")
end

function TestIsPathSafe:testIsPathSafe_NilPath()
  local safe, reason = utils.isPathSafe(nil)
  luaunit.assertFalse(safe)
  luaunit.assertNotNil(reason)
end

function TestIsPathSafe:testIsPathSafe_ParentDirectory()
  local safe, reason = utils.isPathSafe("../etc/passwd")
  luaunit.assertFalse(safe)
  luaunit.assertStrContains(reason, "..")
end

function TestIsPathSafe:testIsPathSafe_MultipleParentDirectories()
  local safe, reason = utils.isPathSafe("../../../../../../etc/passwd")
  luaunit.assertFalse(safe)
  luaunit.assertStrContains(reason, "..")
end

function TestIsPathSafe:testIsPathSafe_HiddenParentDirectory()
  local safe, reason = utils.isPathSafe("/path/to/../../../etc/passwd")
  luaunit.assertFalse(safe)
  luaunit.assertStrContains(reason, "..")
end

function TestIsPathSafe:testIsPathSafe_NullBytes()
  local safe, reason = utils.isPathSafe("/path/to/file\0.txt")
  luaunit.assertFalse(safe)
  luaunit.assertStrContains(reason, "null")
end

function TestIsPathSafe:testIsPathSafe_EncodedTraversal()
  local safe, reason = utils.isPathSafe("/path/%2e%2e/file")
  luaunit.assertFalse(safe)
  luaunit.assertStrContains(reason, "encoded")
end

function TestIsPathSafe:testIsPathSafe_LegitimatePathNoBaseDir()
  local safe, reason = utils.isPathSafe("/themes/default.lua")
  luaunit.assertTrue(safe)
  luaunit.assertNil(reason)
end

function TestIsPathSafe:testIsPathSafe_LegitimatePathWithBaseDir()
  local safe, reason = utils.isPathSafe("/allowed/themes/default.lua", "/allowed")
  luaunit.assertTrue(safe)
  luaunit.assertNil(reason)
end

function TestIsPathSafe:testIsPathSafe_RelativePathWithBaseDir()
  local safe, reason = utils.isPathSafe("themes/default.lua", "/allowed")
  luaunit.assertTrue(safe)
  luaunit.assertNil(reason)
end

function TestIsPathSafe:testIsPathSafe_OutsideBaseDir()
  local safe, reason = utils.isPathSafe("/other/themes/default.lua", "/allowed")
  luaunit.assertFalse(safe)
  luaunit.assertStrContains(reason, "outside")
end

-- Test suite for validatePath
TestValidatePath = {}

function TestValidatePath:testValidatePath_EmptyPath()
  local valid, err = utils.validatePath("")
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "empty")
end

function TestValidatePath:testValidatePath_NilPath()
  local valid, err = utils.validatePath(nil)
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "empty")
end

function TestValidatePath:testValidatePath_TooLong()
  local longPath = string.rep("a", 5000)
  local valid, err = utils.validatePath(longPath, { maxLength = 100 })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "maximum length")
end

function TestValidatePath:testValidatePath_TraversalAttack()
  local valid, err = utils.validatePath("../../../etc/passwd")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
end

function TestValidatePath:testValidatePath_AllowedExtension()
  local valid, err = utils.validatePath("theme.lua", { allowedExtensions = { "lua", "txt" } })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestValidatePath:testValidatePath_DisallowedExtension()
  local valid, err = utils.validatePath("script.exe", { allowedExtensions = { "lua", "txt" } })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "not allowed")
end

function TestValidatePath:testValidatePath_NoExtension()
  local valid, err = utils.validatePath("README", { allowedExtensions = { "lua", "txt" } })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "no file extension")
end

function TestValidatePath:testValidatePath_CaseInsensitiveExtension()
  local valid, err = utils.validatePath("Theme.LUA", { allowedExtensions = { "lua" } })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestValidatePath:testValidatePath_WithBaseDir()
  local valid, err = utils.validatePath("themes/default.lua", { baseDir = "/allowed" })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestValidatePath:testValidatePath_OutsideBaseDir()
  local valid, err = utils.validatePath("/other/theme.lua", { baseDir = "/allowed" })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "outside")
end

-- Test suite for getFileExtension
TestGetFileExtension = {}

function TestGetFileExtension:testGetFileExtension_SimpleExtension()
  local ext = utils.getFileExtension("file.txt")
  luaunit.assertEquals(ext, "txt")
end

function TestGetFileExtension:testGetFileExtension_MultipleDotsInPath()
  local ext = utils.getFileExtension("/path/to/file.name.txt")
  luaunit.assertEquals(ext, "txt")
end

function TestGetFileExtension:testGetFileExtension_NoExtension()
  local ext = utils.getFileExtension("README")
  luaunit.assertNil(ext)
end

function TestGetFileExtension:testGetFileExtension_NilPath()
  local ext = utils.getFileExtension(nil)
  luaunit.assertNil(ext)
end

function TestGetFileExtension:testGetFileExtension_CaseSensitive()
  local ext = utils.getFileExtension("File.TXT")
  luaunit.assertEquals(ext, "txt") -- Should be lowercase
end

function TestGetFileExtension:testGetFileExtension_LongExtension()
  local ext = utils.getFileExtension("archive.tar.gz")
  luaunit.assertEquals(ext, "gz")
end

-- Test suite for hasAllowedExtension
TestHasAllowedExtension = {}

function TestHasAllowedExtension:testHasAllowedExtension_Allowed()
  local allowed = utils.hasAllowedExtension("file.txt", { "txt", "lua" })
  luaunit.assertTrue(allowed)
end

function TestHasAllowedExtension:testHasAllowedExtension_NotAllowed()
  local allowed = utils.hasAllowedExtension("file.exe", { "txt", "lua" })
  luaunit.assertFalse(allowed)
end

function TestHasAllowedExtension:testHasAllowedExtension_CaseInsensitive()
  local allowed = utils.hasAllowedExtension("File.TXT", { "txt", "lua" })
  luaunit.assertTrue(allowed)
end

function TestHasAllowedExtension:testHasAllowedExtension_NoExtension()
  local allowed = utils.hasAllowedExtension("README", { "txt", "lua" })
  luaunit.assertFalse(allowed)
end

function TestHasAllowedExtension:testHasAllowedExtension_EmptyArray()
  local allowed = utils.hasAllowedExtension("file.txt", {})
  luaunit.assertFalse(allowed)
end

-- Test suite for security scenarios
TestPathSecurity = {}

function TestPathSecurity:testPathSecurity_WindowsTraversal()
  local safe = utils.isPathSafe("..\\..\\..\\windows\\system32")
  luaunit.assertFalse(safe)
end

function TestPathSecurity:testPathSecurity_MixedSeparators()
  local safe = utils.isPathSafe("../path\\to/../file")
  luaunit.assertFalse(safe)
end

function TestPathSecurity:testPathSecurity_DoubleEncodedTraversal()
  local safe = utils.isPathSafe("%252e%252e%252f")
  luaunit.assertFalse(safe)
end

function TestPathSecurity:testPathSecurity_LegitimateFileWithDots()
  -- Files with dots in name should be OK (not ..)
  local safe = utils.isPathSafe("/path/to/file.backup.txt")
  luaunit.assertTrue(safe)
end

function TestPathSecurity:testPathSecurity_HiddenFiles()
  -- Hidden files (starting with .) should be OK
  local safe = utils.isPathSafe("/path/to/.hidden")
  luaunit.assertTrue(safe)
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
