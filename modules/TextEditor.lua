-- ====================
-- TextEditor Module
-- ====================
-- Extracted text editing functionality from Element.lua
-- Handles all text input, cursor management, selection, and text rendering for editable elements

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local GuiState = req("GuiState")
local StateManager = req("StateManager")
local Color = req("Color")
local utils = req("utils")

-- Extract utilities
local FONT_CACHE = utils.FONT_CACHE
local getModifiers = utils.getModifiers

-- Reference to Gui (via GuiState)
local Gui = GuiState

-- UTF-8 support (available in LÖVE/Lua 5.3+)
local utf8 = utf8 or require("utf8")

---@class TextEditor
---@field editable boolean
---@field multiline boolean
---@field passwordMode boolean
---@field textWrap boolean|"word"|"char"
---@field maxLines number?
---@field maxLength number?
---@field placeholder string?
---@field inputType "text"|"number"|"email"|"url"
---@field textOverflow "clip"|"ellipsis"|"scroll"
---@field scrollable boolean
---@field autoGrow boolean
---@field selectOnFocus boolean
---@field cursorColor Color?
---@field selectionColor Color?
---@field cursorBlinkRate number
---@field _cursorPosition number
---@field _cursorLine number
---@field _cursorColumn number
---@field _cursorBlinkTimer number
---@field _cursorVisible boolean
---@field _cursorBlinkPaused boolean
---@field _cursorBlinkPauseTimer number
---@field _selectionStart number?
---@field _selectionEnd number?
---@field _selectionAnchor number?
---@field _focused boolean
---@field _textBuffer string
---@field _lines table?
---@field _wrappedLines table?
---@field _textDirty boolean
---@field _textScrollX number
---@field _mouseDownPosition number?
---@field _element Element?
local TextEditor = {}
TextEditor.__index = TextEditor

--- Create a new TextEditor instance
---@param config table Configuration options
---@return TextEditor
function TextEditor.new(config)
  local self = setmetatable({}, TextEditor)
  
  -- Configuration
  self.editable = config.editable or false
  self.multiline = config.multiline or false
  self.passwordMode = config.passwordMode or false
  self.textWrap = config.textWrap
  self.maxLines = config.maxLines
  self.maxLength = config.maxLength
  self.placeholder = config.placeholder
  self.inputType = config.inputType or "text"
  self.textOverflow = config.textOverflow or "clip"
  self.scrollable = config.scrollable
  self.autoGrow = config.autoGrow
  self.selectOnFocus = config.selectOnFocus or false
  self.cursorColor = config.cursorColor
  self.selectionColor = config.selectionColor
  self.cursorBlinkRate = config.cursorBlinkRate or 0.5
  
  -- Initialize cursor and selection state
  self._cursorPosition = 0
  self._cursorLine = 1
  self._cursorColumn = 0
  self._cursorBlinkTimer = 0
  self._cursorVisible = true
  self._cursorBlinkPaused = false
  self._cursorBlinkPauseTimer = 0
  
  -- Selection state
  self._selectionStart = nil
  self._selectionEnd = nil
  self._selectionAnchor = nil
  
  -- Focus state
  self._focused = false
  
  -- Text buffer state
  self._textBuffer = config.text or ""
  self._lines = nil
  self._wrappedLines = nil
  self._textDirty = true
  
  -- Scroll state
  self._textScrollX = 0
  
  -- Mouse tracking
  self._mouseDownPosition = nil
  
  -- Element reference (set via initialize)
  self._element = nil
  
  return self
end

--- Initialize with parent element reference
---@param element Element The parent element
function TextEditor:initialize(element)
  self._element = element
  
  -- Restore state from StateManager in immediate mode
  if Gui._immediateMode and element._stateId then
    local state = StateManager.getState(element._stateId)
    if state then
      -- Restore focus state
      if state._focused then
        self._focused = true
        Gui._focusedElement = element
      end
      
      -- Restore text buffer
      if state._textBuffer and state._textBuffer ~= "" then
        self._textBuffer = state._textBuffer
      end
      
      -- Restore cursor position
      if state._cursorPosition then
        self._cursorPosition = state._cursorPosition
      end
      
      -- Restore selection
      if state._selectionStart then
        self._selectionStart = state._selectionStart
      end
      if state._selectionEnd then
        self._selectionEnd = state._selectionEnd
      end
      
      -- Restore cursor blink state
      if state._cursorBlinkTimer then
        self._cursorBlinkTimer = state._cursorBlinkTimer
      end
      if state._cursorVisible ~= nil then
        self._cursorVisible = state._cursorVisible
      end
      if state._cursorBlinkPaused ~= nil then
        self._cursorBlinkPaused = state._cursorBlinkPaused
      end
      if state._cursorBlinkPauseTimer then
        self._cursorBlinkPauseTimer = state._cursorBlinkPauseTimer
      end
    end
  end
end

-- ====================
-- Cursor Management
-- ====================

--- Set cursor position
---@param position number Character index (0-based)
function TextEditor:setCursorPosition(position)
  self._cursorPosition = position
  self:_validateCursorPosition()
  self:_resetCursorBlink()
end

--- Get cursor position
---@return number Character index (0-based)
function TextEditor:getCursorPosition()
  return self._cursorPosition
end

--- Move cursor by delta characters
---@param delta number Number of characters to move (positive or negative)
function TextEditor:moveCursorBy(delta)
  self._cursorPosition = self._cursorPosition + delta
  self:_validateCursorPosition()
  self:_resetCursorBlink()
end

--- Move cursor to start of text
function TextEditor:moveCursorToStart()
  self._cursorPosition = 0
  self:_resetCursorBlink()
end

--- Move cursor to end of text
function TextEditor:moveCursorToEnd()
  local textLength = utf8.len(self._textBuffer or "")
  self._cursorPosition = textLength
  self:_resetCursorBlink()
end

--- Move cursor to start of current line
function TextEditor:moveCursorToLineStart()
  -- For now, just move to start (will be enhanced for multi-line)
  self:moveCursorToStart()
end

--- Move cursor to end of current line
function TextEditor:moveCursorToLineEnd()
  -- For now, just move to end (will be enhanced for multi-line)
  self:moveCursorToEnd()
end

--- Move cursor to start of previous word
function TextEditor:moveCursorToPreviousWord()
  if not self._textBuffer then
    return
  end
  
  local text = self._textBuffer
  local pos = self._cursorPosition
  
  if pos <= 0 then
    return
  end
  
  -- Helper function to get character at position
  local function getCharAt(p)
    if p < 0 or p >= utf8.len(text) then
      return nil
    end
    local offset1 = utf8.offset(text, p + 1)
    local offset2 = utf8.offset(text, p + 2)
    if not offset1 then
      return nil
    end
    if not offset2 then
      return text:sub(offset1)
    end
    return text:sub(offset1, offset2 - 1)
  end
  
  -- Skip any whitespace/punctuation before current position
  while pos > 0 do
    local char = getCharAt(pos - 1)
    if char and char:match("[%w]") then
      break
    end
    pos = pos - 1
  end
  
  -- Move to start of current word
  while pos > 0 do
    local char = getCharAt(pos - 1)
    if not char or not char:match("[%w]") then
      break
    end
    pos = pos - 1
  end
  
  self._cursorPosition = pos
  self:_validateCursorPosition()
end

--- Move cursor to start of next word
function TextEditor:moveCursorToNextWord()
  if not self._textBuffer then
    return
  end
  
  local text = self._textBuffer
  local textLength = utf8.len(text) or 0
  local pos = self._cursorPosition
  
  if pos >= textLength then
    return
  end
  
  -- Helper function to get character at position
  local function getCharAt(p)
    if p < 0 or p >= textLength then
      return nil
    end
    local offset1 = utf8.offset(text, p + 1)
    local offset2 = utf8.offset(text, p + 2)
    if not offset1 then
      return nil
    end
    if not offset2 then
      return text:sub(offset1)
    end
    return text:sub(offset1, offset2 - 1)
  end
  
  -- Skip current word
  while pos < textLength do
    local char = getCharAt(pos)
    if not char or not char:match("[%w]") then
      break
    end
    pos = pos + 1
  end
  
  -- Skip any whitespace/punctuation
  while pos < textLength do
    local char = getCharAt(pos)
    if char and char:match("[%w]") then
      break
    end
    pos = pos + 1
  end
  
  self._cursorPosition = pos
  self:_validateCursorPosition()
end

--- Validate cursor position (ensure it's within text bounds)
function TextEditor:_validateCursorPosition()
  local textLength = utf8.len(self._textBuffer or "") or 0
  local cursorPos = tonumber(self._cursorPosition) or 0
  self._cursorPosition = math.max(0, math.min(cursorPos, textLength))
end

--- Reset cursor blink (show cursor immediately)
---@param pauseBlink boolean? Whether to pause blinking (for typing)
function TextEditor:_resetCursorBlink(pauseBlink)
  self._cursorBlinkTimer = 0
  self._cursorVisible = true
  
  if pauseBlink then
    self._cursorBlinkPaused = true
    self._cursorBlinkPauseTimer = 0
  end
  
  -- Update scroll to keep cursor visible
  self:_updateTextScroll()
end

--- Update text scroll offset to keep cursor visible
function TextEditor:_updateTextScroll()
  if not self._element or self.multiline then
    return
  end
  
  -- Get font for measuring text
  local font = self:_getFont()
  if not font then
    return
  end
  
  -- Calculate cursor X position in text coordinates
  local cursorText = ""
  if self._textBuffer and self._textBuffer ~= "" and self._cursorPosition > 0 then
    local byteOffset = utf8.offset(self._textBuffer, self._cursorPosition + 1)
    if byteOffset then
      cursorText = self._textBuffer:sub(1, byteOffset - 1)
    end
  end
  local cursorX = font:getWidth(cursorText)
  
  -- Get available text area width (accounting for padding)
  local textAreaWidth = self._element.width
  local scaledContentPadding = self._element:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._element._borderBoxWidth or (self._element.width + self._element.padding.left + self._element.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end
  
  -- Add some padding on the right for the cursor
  local cursorPadding = 4
  local visibleWidth = textAreaWidth - cursorPadding
  
  -- Adjust scroll to keep cursor visible
  if cursorX - self._textScrollX < 0 then
    -- Cursor is to the left of visible area - scroll left
    self._textScrollX = cursorX
  elseif cursorX - self._textScrollX > visibleWidth then
    -- Cursor is to the right of visible area - scroll right
    self._textScrollX = cursorX - visibleWidth
  end
  
  -- Ensure we don't scroll past the beginning
  self._textScrollX = math.max(0, self._textScrollX)
end

-- ====================
-- Selection Management
-- ====================

--- Set selection range
---@param startPos number Start position (inclusive)
---@param endPos number End position (inclusive)
function TextEditor:setSelection(startPos, endPos)
  local textLength = utf8.len(self._textBuffer or "")
  self._selectionStart = math.max(0, math.min(startPos, textLength))
  self._selectionEnd = math.max(0, math.min(endPos, textLength))
  
  -- Ensure start <= end
  if self._selectionStart > self._selectionEnd then
    self._selectionStart, self._selectionEnd = self._selectionEnd, self._selectionStart
  end
  
  self:_resetCursorBlink()
end

--- Get selection range
---@return number?, number? Start and end positions, or nil if no selection
function TextEditor:getSelection()
  if not self:hasSelection() then
    return nil, nil
  end
  return self._selectionStart, self._selectionEnd
end

--- Check if there is an active selection
---@return boolean
function TextEditor:hasSelection()
  return self._selectionStart ~= nil and self._selectionEnd ~= nil and self._selectionStart ~= self._selectionEnd
end

--- Clear selection
function TextEditor:clearSelection()
  self._selectionStart = nil
  self._selectionEnd = nil
  self._selectionAnchor = nil
end

--- Select all text
function TextEditor:selectAll()
  local textLength = utf8.len(self._textBuffer or "")
  self._selectionStart = 0
  self._selectionEnd = textLength
  self:_resetCursorBlink()
end

--- Get selected text
---@return string? Selected text or nil if no selection
function TextEditor:getSelectedText()
  if not self:hasSelection() then
    return nil
  end
  local startPos, endPos = self:getSelection()
  if not startPos or not endPos then
    return nil
  end
  
  -- Convert character indices to byte offsets for string.sub
  local text = self._textBuffer or ""
  local startByte = utf8.offset(text, startPos + 1)
  local endByte = utf8.offset(text, endPos + 1)
  
  if not startByte then
    return ""
  end
  
  -- If endByte is nil, it means we want to the end of the string
  if endByte then
    endByte = endByte - 1
  end
  
  return string.sub(text, startByte, endByte)
end

--- Delete selected text
---@return boolean True if text was deleted
function TextEditor:deleteSelection()
  if not self:hasSelection() then
    return false
  end
  local startPos, endPos = self:getSelection()
  if not startPos or not endPos then
    return false
  end
  
  self:deleteText(startPos, endPos)
  self:clearSelection()
  self._cursorPosition = startPos
  self:_validateCursorPosition()
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
  
  return true
end

-- ====================
-- Focus Management
-- ====================

--- Focus this element for keyboard input
function TextEditor:focus()
  if not self._element then
    return
  end
  
  if Gui._focusedElement and Gui._focusedElement ~= self._element then
    -- Blur the previously focused element
    if Gui._focusedElement.editable and Gui._focusedElement._textEditor then
      Gui._focusedElement._textEditor:blur()
    else
      Gui._focusedElement:blur()
    end
  end
  
  -- Set focus state
  self._focused = true
  Gui._focusedElement = self._element
  
  self:_resetCursorBlink()
  
  if self.selectOnFocus then
    self:selectAll()
  else
    self:moveCursorToEnd()
  end
  
  -- Trigger onFocus callback if defined
  if self._element.onFocus then
    self._element.onFocus(self._element)
  end
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

--- Remove focus from this element
function TextEditor:blur()
  if not self._element then
    return
  end
  
  self._focused = false
  
  -- Clear global focused element if it's this element
  if Gui._focusedElement == self._element then
    Gui._focusedElement = nil
  end
  
  -- Trigger onBlur callback if defined
  if self._element.onBlur then
    self._element.onBlur(self._element)
  end
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

--- Check if this element is focused
---@return boolean
function TextEditor:isFocused()
  return self._focused == true
end

--- Save editable element state to StateManager (for immediate mode)
function TextEditor:_saveEditableState()
  if not self._element or not self._element._stateId or not Gui._immediateMode then
    return
  end
  
  StateManager.updateState(self._element._stateId, {
    _focused = self._focused,
    _textBuffer = self._textBuffer,
    _cursorPosition = self._cursorPosition,
    _selectionStart = self._selectionStart,
    _selectionEnd = self._selectionEnd,
    _cursorBlinkTimer = self._cursorBlinkTimer,
    _cursorVisible = self._cursorVisible,
    _cursorBlinkPaused = self._cursorBlinkPaused,
    _cursorBlinkPauseTimer = self._cursorBlinkPauseTimer,
  })
end

-- ====================
-- Text Buffer Management
-- ====================

--- Get current text buffer
---@return string
function TextEditor:getText()
  return self._textBuffer or ""
end

--- Set text buffer and mark dirty
---@param text string
function TextEditor:setText(text)
  if not self._element then
    self._textBuffer = text or ""
    return
  end
  
  self._textBuffer = text or ""
  self._element.text = self._textBuffer -- Sync display text
  self:_markTextDirty()
  self:_updateTextIfDirty()
  self:_updateAutoGrowHeight()
  self:_validateCursorPosition()
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

--- Insert text at position
---@param text string Text to insert
---@param position number? Position to insert at (default: cursor position)
function TextEditor:insertText(text, position)
  position = position or self._cursorPosition
  local buffer = self._textBuffer or ""
  
  -- Check maxLength constraint before inserting
  if self.maxLength then
    local currentLength = utf8.len(buffer) or 0
    local textLength = utf8.len(text) or 0
    local newLength = currentLength + textLength
    
    if newLength > self.maxLength then
      return
    end
  end
  
  -- Convert character position to byte offset
  local byteOffset = utf8.offset(buffer, position + 1) or (#buffer + 1)
  
  -- Insert text
  local before = buffer:sub(1, byteOffset - 1)
  local after = buffer:sub(byteOffset)
  self._textBuffer = before .. text .. after
  if self._element then
    self._element.text = self._textBuffer
  end
  
  self._cursorPosition = position + utf8.len(text)
  
  self:_markTextDirty()
  self:_updateTextIfDirty()
  self:_updateAutoGrowHeight()
  self:_validateCursorPosition()
  
  -- Reset cursor blink to show cursor and pause blinking while typing
  self:_resetCursorBlink(true)
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

--- Delete text in range
---@param startPos number Start position (inclusive)
---@param endPos number End position (inclusive)
function TextEditor:deleteText(startPos, endPos)
  local buffer = self._textBuffer or ""
  
  -- Ensure valid range
  local textLength = utf8.len(buffer)
  startPos = math.max(0, math.min(startPos, textLength))
  endPos = math.max(0, math.min(endPos, textLength))
  
  if startPos > endPos then
    startPos, endPos = endPos, startPos
  end
  
  -- Convert character positions to byte offsets
  local startByte = utf8.offset(buffer, startPos + 1) or 1
  local endByte = utf8.offset(buffer, endPos + 1) or (#buffer + 1)
  
  -- Delete text
  local before = buffer:sub(1, startByte - 1)
  local after = buffer:sub(endByte)
  self._textBuffer = before .. after
  if self._element then
    self._element.text = self._textBuffer
  end
  
  self:_markTextDirty()
  self:_updateTextIfDirty()
  self:_updateAutoGrowHeight()
  
  -- Reset cursor blink to show cursor and pause blinking while deleting
  self:_resetCursorBlink(true)
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

--- Replace text in range
---@param startPos number Start position (inclusive)
---@param endPos number End position (inclusive)
---@param newText string Replacement text
function TextEditor:replaceText(startPos, endPos, newText)
  self:deleteText(startPos, endPos)
  self:insertText(newText, startPos)
end

--- Mark text as dirty (needs recalculation)
function TextEditor:_markTextDirty()
  self._textDirty = true
end

--- Update text if dirty (recalculate lines and wrapping)
function TextEditor:_updateTextIfDirty()
  if not self._textDirty then
    return
  end
  
  self:_splitLines()
  self:_calculateWrapping()
  self:_validateCursorPosition()
  self._textDirty = false
end

-- ====================
-- Text Wrapping and Line Splitting
-- ====================

--- Split text into lines (for multi-line text)
function TextEditor:_splitLines()
  if not self.multiline then
    self._lines = { self._textBuffer or "" }
    return
  end
  
  self._lines = {}
  local text = self._textBuffer or ""
  
  -- Split on newlines
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(self._lines, line)
  end
  
  -- Ensure at least one line
  if #self._lines == 0 then
    self._lines = { "" }
  end
end

--- Calculate text wrapping
function TextEditor:_calculateWrapping()
  if not self._element or not self.textWrap then
    self._wrappedLines = nil
    return
  end
  
  self._wrappedLines = {}
  local availableWidth = self._element.width - self._element.padding.left - self._element.padding.right
  
  for lineNum, line in ipairs(self._lines or {}) do
    if line == "" then
      table.insert(self._wrappedLines, {
        text = "",
        startIdx = 0,
        endIdx = 0,
        lineNum = lineNum,
      })
    else
      local wrappedParts = self:_wrapLine(line, availableWidth)
      for _, part in ipairs(wrappedParts) do
        part.lineNum = lineNum
        table.insert(self._wrappedLines, part)
      end
    end
  end
end

--- Wrap a single line of text
---@param line string Line to wrap
---@param maxWidth number Maximum width in pixels
---@return table Array of wrapped line parts
function TextEditor:_wrapLine(line, maxWidth)
  if not self._element then
    return { { text = line, startIdx = 0, endIdx = utf8.len(line) } }
  end
  
  local font = self:_getFont()
  local wrappedParts = {}
  local currentLine = ""
  local startIdx = 0
  
  -- Helper function to extract a UTF-8 character by character index
  local function getUtf8Char(str, charIndex)
    local byteStart = utf8.offset(str, charIndex)
    if not byteStart then
      return ""
    end
    local byteEnd = utf8.offset(str, charIndex + 1)
    if byteEnd then
      return str:sub(byteStart, byteEnd - 1)
    else
      return str:sub(byteStart)
    end
  end
  
  if self.textWrap == "word" then
    -- Tokenize into words and whitespace, preserving exact spacing
    local tokens = {}
    local pos = 1
    local lineLen = utf8.len(line)
    
    while pos <= lineLen do
      -- Check if current position is whitespace
      local char = getUtf8Char(line, pos)
      if char:match("%s") then
        -- Collect whitespace sequence
        local wsStart = pos
        while pos <= lineLen and getUtf8Char(line, pos):match("%s") do
          pos = pos + 1
        end
        table.insert(tokens, {
          type = "space",
          text = line:sub(utf8.offset(line, wsStart), utf8.offset(line, pos) and utf8.offset(line, pos) - 1 or #line),
          startPos = wsStart - 1,
          length = pos - wsStart,
        })
      else
        -- Collect word (non-whitespace sequence)
        local wordStart = pos
        while pos <= lineLen and not getUtf8Char(line, pos):match("%s") do
          pos = pos + 1
        end
        table.insert(tokens, {
          type = "word",
          text = line:sub(utf8.offset(line, wordStart), utf8.offset(line, pos) and utf8.offset(line, pos) - 1 or #line),
          startPos = wordStart - 1,
          length = pos - wordStart,
        })
      end
    end
    
    -- Process tokens and wrap
    local charPos = 0
    for i, token in ipairs(tokens) do
      if token.type == "word" then
        local testLine = currentLine .. token.text
        local width = font:getWidth(testLine)
        
        if width > maxWidth and currentLine ~= "" then
          -- Current line is full, wrap before this word
          local currentLineLen = utf8.len(currentLine)
          table.insert(wrappedParts, {
            text = currentLine,
            startIdx = startIdx,
            endIdx = startIdx + currentLineLen,
          })
          startIdx = charPos
          currentLine = token.text
          charPos = charPos + token.length
          
          -- Check if the word itself is too long - if so, break it with character wrapping
          if font:getWidth(token.text) > maxWidth then
            local wordLen = utf8.len(token.text)
            local charLine = ""
            local charStartIdx = startIdx
            
            for j = 1, wordLen do
              local char = getUtf8Char(token.text, j)
              local testCharLine = charLine .. char
              local charWidth = font:getWidth(testCharLine)
              
              if charWidth > maxWidth and charLine ~= "" then
                table.insert(wrappedParts, {
                  text = charLine,
                  startIdx = charStartIdx,
                  endIdx = charStartIdx + utf8.len(charLine),
                })
                charStartIdx = charStartIdx + utf8.len(charLine)
                charLine = char
              else
                charLine = testCharLine
              end
            end
            
            currentLine = charLine
            startIdx = charStartIdx
          end
        elseif width > maxWidth and currentLine == "" then
          -- Word is too long to fit on a line by itself - use character wrapping
          local wordLen = utf8.len(token.text)
          local charLine = ""
          local charStartIdx = startIdx
          
          for j = 1, wordLen do
            local char = getUtf8Char(token.text, j)
            local testCharLine = charLine .. char
            local charWidth = font:getWidth(testCharLine)
            
            if charWidth > maxWidth and charLine ~= "" then
              table.insert(wrappedParts, {
                text = charLine,
                startIdx = charStartIdx,
                endIdx = charStartIdx + utf8.len(charLine),
              })
              charStartIdx = charStartIdx + utf8.len(charLine)
              charLine = char
            else
              charLine = testCharLine
            end
          end
          
          currentLine = charLine
          startIdx = charStartIdx
          charPos = charPos + token.length
        else
          currentLine = testLine
          charPos = charPos + token.length
        end
      else
        -- It's whitespace - add to current line
        currentLine = currentLine .. token.text
        charPos = charPos + token.length
      end
    end
  else
    -- Character wrapping
    local lineLength = utf8.len(line)
    for i = 1, lineLength do
      local char = getUtf8Char(line, i)
      local testLine = currentLine .. char
      local width = font:getWidth(testLine)
      
      if width > maxWidth and currentLine ~= "" then
        table.insert(wrappedParts, {
          text = currentLine,
          startIdx = startIdx,
          endIdx = startIdx + utf8.len(currentLine),
        })
        currentLine = char
        startIdx = i - 1
      else
        currentLine = testLine
      end
    end
  end
  
  -- Add remaining text
  if currentLine ~= "" then
    table.insert(wrappedParts, {
      text = currentLine,
      startIdx = startIdx,
      endIdx = startIdx + utf8.len(currentLine),
    })
  end
  
  -- Ensure at least one part
  if #wrappedParts == 0 then
    table.insert(wrappedParts, {
      text = "",
      startIdx = 0,
      endIdx = 0,
    })
  end
  
  return wrappedParts
end

--- Get font for text rendering
---@return love.Font
function TextEditor:_getFont()
  if not self._element then
    return love.graphics.getFont()
  end
  
  return self._element:_getFont()
end

-- ====================
-- Cursor and Selection Screen Position
-- ====================

--- Get cursor screen position for rendering (handles multiline text)
---@return number, number Cursor X and Y position relative to content area
function TextEditor:_getCursorScreenPosition()
  if not self._element then
    return 0, 0
  end
  
  local font = self:_getFont()
  if not font then
    return 0, 0
  end
  
  local text = self._textBuffer or ""
  local cursorPos = self._cursorPosition or 0
  
  -- Apply password masking for cursor position calculation
  local textForMeasurement = text
  if self.passwordMode and text ~= "" then
    textForMeasurement = string.rep("•", utf8.len(text))
  end
  
  -- For single-line text, calculate simple X position
  if not self.multiline then
    local cursorText = ""
    if textForMeasurement ~= "" and cursorPos > 0 then
      local byteOffset = utf8.offset(textForMeasurement, cursorPos + 1)
      if byteOffset then
        cursorText = textForMeasurement:sub(1, byteOffset - 1)
      end
    end
    return font:getWidth(cursorText), 0
  end
  
  -- For multiline text, we need to find which wrapped line the cursor is on
  self:_updateTextIfDirty()
  
  -- Get text area width for wrapping
  local textAreaWidth = self._element.width
  local scaledContentPadding = self._element:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._element._borderBoxWidth or (self._element.width + self._element.padding.left + self._element.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end
  
  -- Split text by actual newlines first
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  if #lines == 0 then
    lines = { "" }
  end
  
  -- Track character position as we iterate through lines
  local charCount = 0
  local cursorX = 0
  local cursorY = 0
  local lineHeight = font:getHeight()
  
  for lineNum, line in ipairs(lines) do
    local lineLength = utf8.len(line) or 0
    
    -- Check if cursor is on this line (before the newline)
    if cursorPos <= charCount + lineLength then
      -- Cursor is on this line
      local posInLine = cursorPos - charCount
      
      -- If text wrapping is enabled, find which wrapped segment
      if self.textWrap and textAreaWidth > 0 then
        local wrappedSegments = self:_wrapLine(line, textAreaWidth)
        
        for segmentIdx, segment in ipairs(wrappedSegments) do
          -- Check if cursor is within this segment's character range
          if posInLine >= segment.startIdx and posInLine <= segment.endIdx then
            -- Cursor is in this segment
            local posInSegment = posInLine - segment.startIdx
            local segmentText = ""
            if posInSegment > 0 and segment.text ~= "" then
              local endByte = utf8.offset(segment.text, posInSegment + 1)
              if endByte then
                segmentText = segment.text:sub(1, endByte - 1)
              else
                segmentText = segment.text
              end
            end
            cursorX = font:getWidth(segmentText)
            cursorY = (lineNum - 1) * lineHeight + (segmentIdx - 1) * lineHeight
            
            return cursorX, cursorY
          end
        end
      else
        -- No wrapping, simple calculation
        local lineText = ""
        if posInLine > 0 then
          local endByte = utf8.offset(line, posInLine + 1)
          if endByte then
            lineText = line:sub(1, endByte - 1)
          else
            lineText = line
          end
        end
        cursorX = font:getWidth(lineText)
        cursorY = (lineNum - 1) * lineHeight
        return cursorX, cursorY
      end
    end
    
    charCount = charCount + lineLength + 1
  end
  
  -- Cursor is at the very end
  return 0, #lines * lineHeight
end

--- Get selection rectangles for rendering (handles multiline and wrapped text)
---@param selStart number Selection start position (character index)
---@param selEnd number Selection end position (character index)
---@return table Array of rectangles {x, y, width, height} relative to content area
function TextEditor:_getSelectionRects(selStart, selEnd)
  if not self._element then
    return {}
  end
  
  local font = self:_getFont()
  if not font then
    return {}
  end
  
  local text = self._textBuffer or ""
  local rects = {}
  
  -- Apply password masking for selection rectangle calculation
  local textForMeasurement = text
  if self.passwordMode and text ~= "" then
    textForMeasurement = string.rep("•", utf8.len(text))
  end
  
  -- For single-line text, calculate simple rectangle
  if not self.multiline then
    local startByte = utf8.offset(textForMeasurement, selStart + 1)
    local endByte = utf8.offset(textForMeasurement, selEnd + 1)
    
    if startByte and endByte then
      local beforeSelection = textForMeasurement:sub(1, startByte - 1)
      local selectedText = textForMeasurement:sub(startByte, endByte - 1)
      local selX = font:getWidth(beforeSelection)
      local selWidth = font:getWidth(selectedText)
      local selY = 0
      local selHeight = font:getHeight()
      
      table.insert(rects, { x = selX, y = selY, width = selWidth, height = selHeight })
    end
    
    return rects
  end
  
  -- For multiline text, we need to handle line wrapping
  self:_updateTextIfDirty()
  
  -- Get text area width for wrapping
  local textAreaWidth = self._element.width
  local scaledContentPadding = self._element:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._element._borderBoxWidth or (self._element.width + self._element.padding.left + self._element.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end
  
  -- Split text by actual newlines first
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  if #lines == 0 then
    lines = { "" }
  end
  
  local lineHeight = font:getHeight()
  local charCount = 0
  local visualLineNum = 0
  
  for lineNum, line in ipairs(lines) do
    local lineLength = utf8.len(line) or 0
    
    -- Check if selection intersects with this line
    local lineStartChar = charCount
    local lineEndChar = charCount + lineLength
    
    if selEnd > lineStartChar and selStart <= lineEndChar then
      -- Selection intersects with this line
      local selStartInLine = math.max(0, selStart - charCount)
      local selEndInLine = math.min(lineLength, selEnd - charCount)
      
      -- If text wrapping is enabled, handle wrapped segments
      if self.textWrap and textAreaWidth > 0 then
        local wrappedSegments = self:_wrapLine(line, textAreaWidth)
        
        for segmentIdx, segment in ipairs(wrappedSegments) do
          -- Check if selection intersects with this segment
          if selEndInLine > segment.startIdx and selStartInLine <= segment.endIdx then
            -- Selection intersects with this segment
            local segSelStart = math.max(segment.startIdx, selStartInLine)
            local segSelEnd = math.min(segment.endIdx, selEndInLine)
            
            -- Calculate X position and width
            local beforeText = ""
            local selectedText = ""
            
            if segSelStart > segment.startIdx then
              local startByte = utf8.offset(segment.text, segSelStart - segment.startIdx + 1)
              if startByte then
                beforeText = segment.text:sub(1, startByte - 1)
              end
            end
            
            local selStartByte = utf8.offset(segment.text, segSelStart - segment.startIdx + 1)
            local selEndByte = utf8.offset(segment.text, segSelEnd - segment.startIdx + 1)
            if selStartByte and selEndByte then
              selectedText = segment.text:sub(selStartByte, selEndByte - 1)
            end
            
            local selX = font:getWidth(beforeText)
            local selWidth = font:getWidth(selectedText)
            local selY = visualLineNum * lineHeight
            local selHeight = lineHeight
            
            table.insert(rects, { x = selX, y = selY, width = selWidth, height = selHeight })
          end
          
          visualLineNum = visualLineNum + 1
        end
      else
        -- No wrapping, simple calculation
        local beforeText = ""
        local selectedText = ""
        
        if selStartInLine > 0 then
          local startByte = utf8.offset(line, selStartInLine + 1)
          if startByte then
            beforeText = line:sub(1, startByte - 1)
          end
        end
        
        local selStartByte = utf8.offset(line, selStartInLine + 1)
        local selEndByte = utf8.offset(line, selEndInLine + 1)
        if selStartByte and selEndByte then
          selectedText = line:sub(selStartByte, selEndByte - 1)
        end
        
        local selX = font:getWidth(beforeText)
        local selWidth = font:getWidth(selectedText)
        local selY = visualLineNum * lineHeight
        local selHeight = lineHeight
        
        table.insert(rects, { x = selX, y = selY, width = selWidth, height = selHeight })
        visualLineNum = visualLineNum + 1
      end
    else
      -- Selection doesn't intersect, but we still need to count visual lines
      if self.textWrap and textAreaWidth > 0 then
        local wrappedSegments = self:_wrapLine(line, textAreaWidth)
        visualLineNum = visualLineNum + #wrappedSegments
      else
        visualLineNum = visualLineNum + 1
      end
    end
    
    charCount = charCount + lineLength + 1
  end
  
  return rects
end

-- ====================
-- Auto-Grow Height
-- ====================

--- Update element height based on text content (for autoGrow multiline fields)
function TextEditor:_updateAutoGrowHeight()
  if not self._element or not self.multiline or not self.autoGrow then
    return
  end
  
  local font = self:_getFont()
  if not font then
    return
  end
  
  local text = self._textBuffer or ""
  local lineHeight = font:getHeight()
  
  -- Get text area width for wrapping
  local textAreaWidth = self._element.width
  local scaledContentPadding = self._element:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._element._borderBoxWidth or (self._element.width + self._element.padding.left + self._element.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end
  
  -- Split text by actual newlines
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  if #lines == 0 then
    lines = { "" }
  end
  
  -- Count total wrapped lines
  local totalWrappedLines = 0
  if self.textWrap and textAreaWidth > 0 then
    for _, line in ipairs(lines) do
      if line == "" then
        totalWrappedLines = totalWrappedLines + 1
      else
        local wrappedSegments = self:_wrapLine(line, textAreaWidth)
        totalWrappedLines = totalWrappedLines + #wrappedSegments
      end
    end
  else
    totalWrappedLines = #lines
  end
  
  totalWrappedLines = math.max(1, totalWrappedLines)
  
  local newContentHeight = totalWrappedLines * lineHeight
  
  if self._element.height ~= newContentHeight then
    self._element.height = newContentHeight
    self._element._borderBoxHeight = self._element.height + self._element.padding.top + self._element.padding.bottom
    if self._element.parent and not self._element._explicitlyAbsolute then
      self._element.parent:layoutChildren()
    end
  end
end

-- ====================
-- Mouse Selection
-- ====================

--- Convert mouse coordinates to cursor position in text
---@param mouseX number Mouse X coordinate (absolute)
---@param mouseY number Mouse Y coordinate (absolute)
---@return number Cursor position (character index)
function TextEditor:_mouseToTextPosition(mouseX, mouseY)
  if not self._element or not self._textBuffer then
    return 0
  end
  
  -- Get content area bounds
  local contentX = (self._element._absoluteX or self._element.x) + self._element.padding.left
  local contentY = (self._element._absoluteY or self._element.y) + self._element.padding.top
  
  -- Calculate relative position within text area
  local relativeX = mouseX - contentX
  local relativeY = mouseY - contentY
  
  -- Get font for measuring text
  local font = self:_getFont()
  if not font then
    return 0
  end
  
  local text = self._textBuffer
  local textLength = utf8.len(text) or 0
  
  -- === SINGLE-LINE TEXT HANDLING ===
  if not self.multiline then
    -- Account for horizontal scroll offset in single-line inputs
    if self._textScrollX then
      relativeX = relativeX + self._textScrollX
    end
    
    -- Find the character position closest to the click
    local closestPos = 0
    local closestDist = math.huge
    
    -- Check each position in the text
    for i = 0, textLength do
      local offset = utf8.offset(text, i + 1)
      local beforeText = offset and text:sub(1, offset - 1) or text
      local textWidth = font:getWidth(beforeText)
      
      local dist = math.abs(relativeX - textWidth)
      
      if dist < closestDist then
        closestDist = dist
        closestPos = i
      end
    end
    
    return closestPos
  end
  
  -- === MULTILINE TEXT HANDLING ===
  
  -- Update text wrapping if dirty
  self:_updateTextIfDirty()
  
  -- Split text into lines
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  if #lines == 0 then
    lines = { "" }
  end
  
  local lineHeight = font:getHeight()
  
  -- Get text area width for wrapping calculations
  local textAreaWidth = self._element.width
  local scaledContentPadding = self._element:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._element._borderBoxWidth or (self._element.width + self._element.padding.left + self._element.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end
  
  -- Determine which line the click is on based on Y coordinate
  local clickedLineNum = math.floor(relativeY / lineHeight) + 1
  clickedLineNum = math.max(1, math.min(clickedLineNum, #lines))
  
  -- Calculate character offset for lines before the clicked line
  local charOffset = 0
  for i = 1, clickedLineNum - 1 do
    local lineLen = utf8.len(lines[i]) or 0
    charOffset = charOffset + lineLen + 1
  end
  
  -- Get the clicked line
  local clickedLine = lines[clickedLineNum]
  local lineLen = utf8.len(clickedLine) or 0
  
  -- If text wrapping is enabled, handle wrapped segments
  if self.textWrap and textAreaWidth > 0 then
    local wrappedSegments = self:_wrapLine(clickedLine, textAreaWidth)
    
    -- Determine which wrapped segment was clicked
    local lineYOffset = (clickedLineNum - 1) * lineHeight
    local segmentNum = math.floor((relativeY - lineYOffset) / lineHeight) + 1
    segmentNum = math.max(1, math.min(segmentNum, #wrappedSegments))
    
    local segment = wrappedSegments[segmentNum]
    
    -- Find closest position within the segment
    local segmentText = segment.text
    local segmentLen = utf8.len(segmentText) or 0
    local closestPos = segment.startIdx
    local closestDist = math.huge
    
    for i = 0, segmentLen do
      local offset = utf8.offset(segmentText, i + 1)
      local beforeText = offset and segmentText:sub(1, offset - 1) or segmentText
      local textWidth = font:getWidth(beforeText)
      local dist = math.abs(relativeX - textWidth)
      
      if dist < closestDist then
        closestDist = dist
        closestPos = segment.startIdx + i
      end
    end
    
    return charOffset + closestPos
  end
  
  -- No wrapping - find closest position in the clicked line
  local closestPos = 0
  local closestDist = math.huge
  
  for i = 0, lineLen do
    local offset = utf8.offset(clickedLine, i + 1)
    local beforeText = offset and clickedLine:sub(1, offset - 1) or clickedLine
    local textWidth = font:getWidth(beforeText)
    local dist = math.abs(relativeX - textWidth)
    
    if dist < closestDist then
      closestDist = dist
      closestPos = i
    end
  end
  
  return charOffset + closestPos
end

--- Handle mouse click on text (set cursor position or start selection)
---@param mouseX number Mouse X coordinate
---@param mouseY number Mouse Y coordinate
---@param clickCount number Number of clicks (1=single, 2=double, 3=triple)
function TextEditor:handleTextClick(mouseX, mouseY, clickCount)
  if not self._focused then
    return
  end
  
  if clickCount == 1 then
    -- Single click: Set cursor position
    local pos = self:_mouseToTextPosition(mouseX, mouseY)
    self:setCursorPosition(pos)
    self:clearSelection()
    
    -- Store position for potential drag selection
    self._mouseDownPosition = pos
  elseif clickCount == 2 then
    -- Double click: Select word
    self:_selectWordAtPosition(self:_mouseToTextPosition(mouseX, mouseY))
  elseif clickCount >= 3 then
    -- Triple click: Select all
    self:selectAll()
  end
  
  self:_resetCursorBlink()
end

--- Handle mouse drag for text selection
---@param mouseX number Mouse X coordinate
---@param mouseY number Mouse Y coordinate
function TextEditor:handleTextDrag(mouseX, mouseY)
  if not self._focused or not self._mouseDownPosition then
    return
  end
  
  local currentPos = self:_mouseToTextPosition(mouseX, mouseY)
  
  -- Create selection from mouse down position to current position
  if currentPos ~= self._mouseDownPosition then
    self:setSelection(self._mouseDownPosition, currentPos)
    self._cursorPosition = currentPos
  else
    self:clearSelection()
  end
  
  self:_resetCursorBlink()
end

--- Select word at given position
---@param position number Character position
function TextEditor:_selectWordAtPosition(position)
  if not self._textBuffer then
    return
  end
  
  local text = self._textBuffer
  local textLength = utf8.len(text) or 0
  
  if position < 0 or position > textLength then
    return
  end
  
  -- Find word boundaries
  local wordStart = position
  local wordEnd = position
  
  -- Find start of word (move left while alphanumeric)
  while wordStart > 0 do
    local offset = utf8.offset(text, wordStart)
    local char = offset and text:sub(offset, utf8.offset(text, wordStart + 1) - 1) or ""
    if char:match("[%w]") then
      wordStart = wordStart - 1
    else
      break
    end
  end
  
  -- Find end of word (move right while alphanumeric)
  while wordEnd < textLength do
    local offset = utf8.offset(text, wordEnd + 1)
    local char = offset and text:sub(offset, utf8.offset(text, wordEnd + 2) - 1) or ""
    if char:match("[%w]") then
      wordEnd = wordEnd + 1
    else
      break
    end
  end
  
  -- Select the word
  if wordEnd > wordStart then
    self:setSelection(wordStart, wordEnd)
    self._cursorPosition = wordEnd
  end
end

--- Clear mouse down position (called on mouse release)
function TextEditor:clearMouseDownPosition()
  self._mouseDownPosition = nil
end

-- ====================
-- Keyboard Input
-- ====================

--- Handle text input (character input)
---@param text string Character(s) to insert
function TextEditor:handleInput(text)
  if not self._focused or not self._element then
    return
  end
  
  -- Trigger onTextInput callback if defined
  if self._element.onTextInput then
    local result = self._element.onTextInput(self._element, text)
    if result == false then
      return
    end
  end
  
  -- Capture old text for callback
  local oldText = self._textBuffer
  
  -- Delete selection if exists
  local hadSelection = self:hasSelection()
  if hadSelection then
    self:deleteSelection()
  end
  
  -- Insert text at cursor position
  self:insertText(text)
  
  -- Trigger onTextChange callback if text changed
  if self._element.onTextChange and self._textBuffer ~= oldText then
    self._element.onTextChange(self._element, self._textBuffer, oldText)
  end
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

--- Handle key press (special keys)
---@param key string Key name
---@param scancode string Scancode
---@param isrepeat boolean Whether this is a key repeat
function TextEditor:handleKeyPress(key, scancode, isrepeat)
  if not self._focused or not self._element then
    return
  end
  
  local modifiers = getModifiers()
  local ctrl = modifiers.ctrl or modifiers.super
  
  -- Handle cursor movement with selection
  if key == "left" or key == "right" or key == "home" or key == "end" or key == "up" or key == "down" then
    -- Set selection anchor if Shift is pressed and no anchor exists
    if modifiers.shift and not self._selectionAnchor then
      self._selectionAnchor = self._cursorPosition
    end
    
    -- Store old cursor position
    local oldCursorPos = self._cursorPosition
    
    -- Move cursor based on key
    if key == "left" then
      if modifiers.super then
        self:moveCursorToStart()
        if not modifiers.shift then
          self:clearSelection()
        end
      elseif modifiers.alt then
        self:moveCursorToPreviousWord()
      elseif self:hasSelection() and not modifiers.shift then
        local startPos, _ = self:getSelection()
        self._cursorPosition = startPos
        self:clearSelection()
      else
        self:moveCursorBy(-1)
      end
    elseif key == "right" then
      if modifiers.super then
        self:moveCursorToEnd()
        if not modifiers.shift then
          self:clearSelection()
        end
      elseif modifiers.alt then
        self:moveCursorToNextWord()
      elseif self:hasSelection() and not modifiers.shift then
        local _, endPos = self:getSelection()
        self._cursorPosition = endPos
        self:clearSelection()
      else
        self:moveCursorBy(1)
      end
    elseif key == "home" then
      if not self.multiline then
        self:moveCursorToStart()
      else
        self:moveCursorToLineStart()
      end
      if not modifiers.shift then
        self:clearSelection()
      end
    elseif key == "end" then
      if not self.multiline then
        self:moveCursorToEnd()
      else
        self:moveCursorToLineEnd()
      end
      if not modifiers.shift then
        self:clearSelection()
      end
    elseif key == "up" then
      -- TODO: Implement up/down for multi-line
      if not modifiers.shift then
        self:clearSelection()
      end
    elseif key == "down" then
      -- TODO: Implement up/down for multi-line
      if not modifiers.shift then
        self:clearSelection()
      end
    end
    
    -- Update selection if Shift is pressed
    if modifiers.shift and self._selectionAnchor then
      self:setSelection(self._selectionAnchor, self._cursorPosition)
    elseif not modifiers.shift then
      self._selectionAnchor = nil
    end
    
    self:_resetCursorBlink()
    
  -- Handle backspace and delete
  elseif key == "backspace" then
    local oldText = self._textBuffer
    if self:hasSelection() then
      self:deleteSelection()
    elseif ctrl then
      -- Ctrl/Cmd+Backspace: Delete all text from start to cursor
      if self._cursorPosition > 0 then
        self:deleteText(0, self._cursorPosition)
        self._cursorPosition = 0
        self:_validateCursorPosition()
      end
    elseif self._cursorPosition > 0 then
      local deleteStart = self._cursorPosition - 1
      local deleteEnd = self._cursorPosition
      self._cursorPosition = deleteStart
      self:deleteText(deleteStart, deleteEnd)
      self:_validateCursorPosition()
    end
    
    if self._element.onTextChange and self._textBuffer ~= oldText then
      self._element.onTextChange(self._element, self._textBuffer, oldText)
    end
    self:_resetCursorBlink(true)
    
  elseif key == "delete" then
    local oldText = self._textBuffer
    if self:hasSelection() then
      self:deleteSelection()
    else
      local textLength = utf8.len(self._textBuffer or "")
      if self._cursorPosition < textLength then
        self:deleteText(self._cursorPosition, self._cursorPosition + 1)
      end
    end
    
    if self._element.onTextChange and self._textBuffer ~= oldText then
      self._element.onTextChange(self._element, self._textBuffer, oldText)
    end
    self:_resetCursorBlink(true)
    
  -- Handle return/enter
  elseif key == "return" or key == "kpenter" then
    if self.multiline then
      local oldText = self._textBuffer
      if self:hasSelection() then
        self:deleteSelection()
      end
      self:insertText("\n")
      
      if self._element.onTextChange and self._textBuffer ~= oldText then
        self._element.onTextChange(self._element, self._textBuffer, oldText)
      end
    else
      if self._element.onEnter then
        self._element.onEnter(self._element)
      end
    end
    self:_resetCursorBlink(true)
    
  -- Handle Ctrl/Cmd+A (select all)
  elseif ctrl and key == "a" then
    self:selectAll()
    self:_resetCursorBlink()
    
  -- Handle Ctrl/Cmd+C (copy)
  elseif ctrl and key == "c" then
    if self:hasSelection() then
      local selectedText = self:getSelectedText()
      if selectedText then
        love.system.setClipboardText(selectedText)
      end
    end
    self:_resetCursorBlink()
    
  -- Handle Ctrl/Cmd+X (cut)
  elseif ctrl and key == "x" then
    if self:hasSelection() then
      local selectedText = self:getSelectedText()
      if selectedText then
        love.system.setClipboardText(selectedText)
        
        local oldText = self._textBuffer
        self:deleteSelection()
        
        if self._element.onTextChange and self._textBuffer ~= oldText then
          self._element.onTextChange(self._element, self._textBuffer, oldText)
        end
      end
    end
    self:_resetCursorBlink(true)
    
  -- Handle Ctrl/Cmd+V (paste)
  elseif ctrl and key == "v" then
    local clipboardText = love.system.getClipboardText()
    if clipboardText and clipboardText ~= "" then
      local oldText = self._textBuffer
      
      if self:hasSelection() then
        self:deleteSelection()
      end
      
      self:insertText(clipboardText)
      
      if self._element.onTextChange and self._textBuffer ~= oldText then
        self._element.onTextChange(self._element, self._textBuffer, oldText)
      end
    end
    self:_resetCursorBlink(true)
    
  -- Handle Escape
  elseif key == "escape" then
    if self:hasSelection() then
      self:clearSelection()
    else
      self:blur()
    end
    self:_resetCursorBlink()
  end
  
  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

-- ====================
-- Update
-- ====================

--- Update cursor blink timer
---@param dt number Delta time
function TextEditor:update(dt)
  if not self._focused then
    return
  end
  
  -- If blink is paused, increment pause timer
  if self._cursorBlinkPaused then
    self._cursorBlinkPauseTimer = (self._cursorBlinkPauseTimer or 0) + dt
    -- Unpause after 0.5 seconds of no typing
    if self._cursorBlinkPauseTimer >= 0.5 then
      self._cursorBlinkPaused = false
      self._cursorBlinkPauseTimer = 0
    end
  else
    -- Normal blinking
    self._cursorBlinkTimer = self._cursorBlinkTimer + dt
    if self._cursorBlinkTimer >= self.cursorBlinkRate then
      self._cursorBlinkTimer = 0
      self._cursorVisible = not self._cursorVisible
    end
  end
end

-- ====================
-- Draw
-- ====================

--- Draw text, cursor, and selection
---@param x number Content area X position
---@param y number Content area Y position
---@param width number Content area width
---@param height number Content area height
function TextEditor:draw(x, y, width, height)
  if not self._element then
    return
  end
  
  local font = self:_getFont()
  if not font then
    return
  end
  
  local textHeight = font:getHeight()
  
  -- Draw selection highlight
  if self._focused and self:hasSelection() and self._textBuffer and self._textBuffer ~= "" then
    local selStart, selEnd = self:getSelection()
    local selectionColor = self.selectionColor or Color.new(0.3, 0.5, 0.8, 0.5)
    local selectionWithOpacity = Color.new(selectionColor.r, selectionColor.g, selectionColor.b, selectionColor.a * self._element.opacity)
    
    local selectionRects = self:_getSelectionRects(selStart, selEnd)
    
    -- Apply scissor for single-line editable inputs
    if not self.multiline then
      love.graphics.setScissor(x, y, width, height)
    end
    
    love.graphics.setColor(selectionWithOpacity:toRGBA())
    for _, rect in ipairs(selectionRects) do
      local rectX = x + rect.x
      local rectY = y + rect.y
      if not self.multiline and self._textScrollX then
        rectX = rectX - self._textScrollX
      end
      love.graphics.rectangle("fill", rectX, rectY, rect.width, rect.height)
    end
    
    if not self.multiline then
      love.graphics.setScissor()
    end
  end
  
  -- Draw cursor
  if self._focused and self._cursorVisible then
    local cursorColor = self.cursorColor or self._element.textColor
    local cursorWithOpacity = Color.new(cursorColor.r, cursorColor.g, cursorColor.b, cursorColor.a * self._element.opacity)
    love.graphics.setColor(cursorWithOpacity:toRGBA())
    
    local cursorRelX, cursorRelY = self:_getCursorScreenPosition()
    local cursorX = x + cursorRelX
    local cursorY = y + cursorRelY
    local cursorHeight = textHeight
    
    -- Apply scroll offset for single-line inputs
    if not self.multiline and self._textScrollX then
      cursorX = cursorX - self._textScrollX
    end
    
    -- Apply scissor for single-line editable inputs
    if not self.multiline then
      love.graphics.setScissor(x, y, width, height)
    end
    
    love.graphics.rectangle("fill", cursorX, cursorY, 2, cursorHeight)
    
    if not self.multiline then
      love.graphics.setScissor()
    end
  end
end

return TextEditor
