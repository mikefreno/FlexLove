--- Renderer Module
-- Handles all visual rendering for Elements including backgrounds, borders,
-- images, themes, blur effects, and text rendering.
--
-- This module is responsible for the visual presentation layer of Elements,
-- delegating from Element's draw() method to keep rendering concerns separated.

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

local Renderer = {}
Renderer.__index = Renderer

-- Dependencies
local Color = req("Color")
local RoundedRect = req("RoundedRect")
local NinePatch = req("NinePatch")
local ImageRenderer = req("ImageRenderer")
local ImageCache = req("ImageCache")
local Theme = req("Theme")
local Blur = req("Blur")
local utils = req("utils")

-- Font cache and enums (shared with Element for now - could be refactored later)
local FONT_CACHE = utils.FONT_CACHE
local enums = utils.enums
local TextAlign = enums.TextAlign

--- Create a new Renderer instance
---@param config table Configuration table with rendering properties
---@return table Renderer instance
function Renderer.new(config)
  local self = setmetatable({}, Renderer)
  
  -- Store reference to parent element (will be set via initialize)
  self._element = nil
  
  -- Visual properties
  self.backgroundColor = config.backgroundColor or Color.new(0, 0, 0, 0)
  self.borderColor = config.borderColor or Color.new(0, 0, 0, 1)
  self.opacity = config.opacity or 1
  
  -- Border configuration
  self.border = config.border or {
    top = false,
    right = false,
    bottom = false,
    left = false
  }
  
  -- Corner radius
  self.cornerRadius = config.cornerRadius or {
    topLeft = 0,
    topRight = 0,
    bottomLeft = 0,
    bottomRight = 0
  }
  
  -- Theme properties
  self.theme = config.theme
  self.themeComponent = config.themeComponent
  self._themeState = "normal"
  
  -- Image properties
  self.imagePath = config.imagePath
  self.image = config.image
  self._loadedImage = nil
  self.objectFit = config.objectFit or "fill"
  self.objectPosition = config.objectPosition or "center center"
  self.imageOpacity = config.imageOpacity or 1
  
  -- Blur effects
  self.contentBlur = config.contentBlur
  self.backdropBlur = config.backdropBlur
  self._blurInstance = nil
  
  -- Load image if path provided
  if self.imagePath and not self.image then
    local loadedImage, err = ImageCache.load(self.imagePath)
    if loadedImage then
      self._loadedImage = loadedImage
    else
      self._loadedImage = nil
    end
  elseif self.image then
    self._loadedImage = self.image
  else
    self._loadedImage = nil
  end
  
  return self
end

--- Initialize renderer with parent element reference
---@param element table The parent Element instance
function Renderer:initialize(element)
  self._element = element
end

--- Get or create blur instance for this element
---@return table|nil Blur instance or nil
function Renderer:getBlurInstance()
  -- Determine quality from blur settings
  local quality = "medium"
  if self.contentBlur and self.contentBlur.quality then
    quality = self.contentBlur.quality
  elseif self.backdropBlur and self.backdropBlur.quality then
    quality = self.backdropBlur.quality
  end
  
  -- Create or reuse blur instance
  if not self._blurInstance or self._blurInstance.quality ~= quality then
    self._blurInstance = Blur.new(quality)
  end
  
  return self._blurInstance
end

--- Set theme state (normal, hover, pressed, disabled, active)
---@param state string The theme state
function Renderer:setThemeState(state)
  self._themeState = state
end

--- Draw background layer
---@param x number X position
---@param y number Y position
---@param width number Width
---@param height number Height
---@param drawBackgroundColor table Background color (may have animation applied)
function Renderer:_drawBackground(x, y, width, height, drawBackgroundColor)
  local backgroundWithOpacity = Color.new(
    drawBackgroundColor.r,
    drawBackgroundColor.g,
    drawBackgroundColor.b,
    drawBackgroundColor.a * self.opacity
  )
  love.graphics.setColor(backgroundWithOpacity:toRGBA())
  RoundedRect.draw("fill", x, y, width, height, self.cornerRadius)
end

--- Draw image layer
---@param x number X position (border box)
---@param y number Y position (border box)
---@param paddingLeft number Left padding
---@param paddingTop number Top padding
---@param contentWidth number Content width
---@param contentHeight number Content height
---@param borderBoxWidth number Border box width
---@param borderBoxHeight number Border box height
function Renderer:_drawImage(x, y, paddingLeft, paddingTop, contentWidth, contentHeight, borderBoxWidth, borderBoxHeight)
  if not self._loadedImage then
    return
  end
  
  -- Calculate image bounds (content area - respects padding)
  local imageX = x + paddingLeft
  local imageY = y + paddingTop
  local imageWidth = contentWidth
  local imageHeight = contentHeight
  
  -- Combine element opacity with imageOpacity
  local finalOpacity = self.opacity * self.imageOpacity
  
  -- Apply cornerRadius clipping if set
  local hasCornerRadius = self.cornerRadius.topLeft > 0
    or self.cornerRadius.topRight > 0
    or self.cornerRadius.bottomLeft > 0
    or self.cornerRadius.bottomRight > 0
  
  if hasCornerRadius then
    -- Use stencil to clip image to rounded corners
    love.graphics.stencil(function()
      RoundedRect.draw("fill", x, y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
  end
  
  -- Draw the image
  ImageRenderer.draw(self._loadedImage, imageX, imageY, imageWidth, imageHeight, self.objectFit, self.objectPosition, finalOpacity)
  
  -- Clear stencil if it was used
  if hasCornerRadius then
    love.graphics.setStencilTest()
  end
end

--- Draw theme layer (9-patch)
---@param x number X position
---@param y number Y position
---@param borderBoxWidth number Border box width
---@param borderBoxHeight number Border box height
---@param scaleCorners boolean Whether to scale corners (from element)
---@param scalingAlgorithm string Scaling algorithm (from element)
function Renderer:_drawTheme(x, y, borderBoxWidth, borderBoxHeight, scaleCorners, scalingAlgorithm)
  if not self.themeComponent then
    return
  end
  
  -- Get the theme to use
  local themeToUse = nil
  if self.theme then
    -- Element specifies a specific theme - load it if needed
    if Theme.get(self.theme) then
      themeToUse = Theme.get(self.theme)
    else
      -- Try to load the theme
      pcall(function()
        Theme.load(self.theme)
      end)
      themeToUse = Theme.get(self.theme)
    end
  else
    -- Use active theme
    themeToUse = Theme.getActive()
  end
  
  if not themeToUse then
    return
  end
  
  -- Get the component from the theme
  local component = themeToUse.components[self.themeComponent]
  if not component then
    return
  end
  
  -- Check for state-specific override
  local state = self._themeState
  if state and component.states and component.states[state] then
    component = component.states[state]
  end
  
  -- Use component-specific atlas if available, otherwise use theme atlas
  local atlasToUse = component._loadedAtlas or themeToUse.atlas
  
  if atlasToUse and component.regions then
    -- Validate component has required structure
    local hasAllRegions = component.regions.topLeft
      and component.regions.topCenter
      and component.regions.topRight
      and component.regions.middleLeft
      and component.regions.middleCenter
      and component.regions.middleRight
      and component.regions.bottomLeft
      and component.regions.bottomCenter
      and component.regions.bottomRight
    
    if hasAllRegions then
      -- Pass element-level overrides for scaleCorners and scalingAlgorithm
      NinePatch.draw(component, atlasToUse, x, y, borderBoxWidth, borderBoxHeight, self.opacity, scaleCorners, scalingAlgorithm)
    end
  end
end

--- Draw borders
---@param x number X position
---@param y number Y position
---@param borderBoxWidth number Border box width
---@param borderBoxHeight number Border box height
function Renderer:_drawBorders(x, y, borderBoxWidth, borderBoxHeight)
  local borderColorWithOpacity = Color.new(
    self.borderColor.r,
    self.borderColor.g,
    self.borderColor.b,
    self.borderColor.a * self.opacity
  )
  love.graphics.setColor(borderColorWithOpacity:toRGBA())
  
  -- Check if all borders are enabled
  local allBorders = self.border.top and self.border.bottom and self.border.left and self.border.right
  
  if allBorders then
    -- Draw complete rounded rectangle border
    RoundedRect.draw("line", x, y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
  else
    -- Draw individual borders (without rounded corners for partial borders)
    if self.border.top then
      love.graphics.line(x, y, x + borderBoxWidth, y)
    end
    if self.border.bottom then
      love.graphics.line(x, y + borderBoxHeight, x + borderBoxWidth, y + borderBoxHeight)
    end
    if self.border.left then
      love.graphics.line(x, y, x, y + borderBoxHeight)
    end
    if self.border.right then
      love.graphics.line(x + borderBoxWidth, y, x + borderBoxWidth, y + borderBoxHeight)
    end
  end
end

--- Main draw method - renders all visual layers
---@param backdropCanvas table|nil Backdrop canvas for backdrop blur
function Renderer:draw(backdropCanvas)
  -- Early exit if element is invisible (optimization)
  if self.opacity <= 0 then
    return
  end
  
  -- Element must be initialized before drawing
  if not self._element then
    error("Renderer:draw() called before initialize(). Call renderer:initialize(element) first.")
  end
  
  local element = self._element
  
  -- Handle opacity during animation
  local drawBackgroundColor = self.backgroundColor
  if element.animation then
    local anim = element.animation:interpolate()
    if anim.opacity then
      drawBackgroundColor = Color.new(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, anim.opacity)
    end
  end
  
  -- Cache border box dimensions for this draw call (optimization)
  local borderBoxWidth = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local borderBoxHeight = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)
  
  -- LAYER 0.5: Draw backdrop blur if configured (before background)
  if self.backdropBlur and self.backdropBlur.intensity > 0 and backdropCanvas then
    local blurInstance = self:getBlurInstance()
    if blurInstance then
      Blur.applyBackdrop(blurInstance, self.backdropBlur.intensity, element.x, element.y, borderBoxWidth, borderBoxHeight, backdropCanvas)
    end
  end
  
  -- LAYER 1: Draw backgroundColor first (behind everything)
  self:_drawBackground(element.x, element.y, borderBoxWidth, borderBoxHeight, drawBackgroundColor)
  
  -- LAYER 1.5: Draw image on top of backgroundColor (if image exists)
  self:_drawImage(
    element.x,
    element.y,
    element.padding.left,
    element.padding.top,
    element.width,
    element.height,
    borderBoxWidth,
    borderBoxHeight
  )
  
  -- LAYER 2: Draw theme on top of backgroundColor (if theme exists)
  self:_drawTheme(element.x, element.y, borderBoxWidth, borderBoxHeight, element.scaleCorners, element.scalingAlgorithm)
  
  -- LAYER 3: Draw borders on top of theme
  self:_drawBorders(element.x, element.y, borderBoxWidth, borderBoxHeight)
end

--- Get font for element (resolves from theme or fontFamily)
---@param element table Reference to the parent Element instance
---@return love.Font
function Renderer:getFont(element)
  -- Get font path from theme or element
  local fontPath = nil
  if element.fontFamily then
    local themeToUse = element._themeManager:getTheme()
    if themeToUse and themeToUse.fonts and themeToUse.fonts[element.fontFamily] then
      fontPath = themeToUse.fonts[element.fontFamily]
    else
      fontPath = element.fontFamily
    end
  end

  return FONT_CACHE.getFont(element.textSize, fontPath)
end

--- Wrap a line of text based on element's textWrap mode
---@param element table Reference to the parent Element instance
---@param line string The line of text to wrap
---@param maxWidth number Maximum width for wrapping
---@return table Array of {text, startIdx, endIdx}
function Renderer:wrapLine(element, line, maxWidth)
  -- UTF-8 support
  local utf8 = utf8 or require("utf8")
  
  if not element.editable then
    return { { text = line, startIdx = 0, endIdx = utf8.len(line) } }
  end

  local font = self:getFont(element)
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

  if element.textWrap == "word" then
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
    local charPos = 0 -- Track our position in the original line
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

--- Draw text content (includes text, cursor, selection, placeholder, password masking)
---@param element table Reference to the parent Element instance
function Renderer:drawText(element)
  -- Update text layout if dirty (for multiline auto-grow)
  if element._textEditor then
    element._textEditor:_updateTextIfDirty()
    element._textEditor:updateAutoGrowHeight()
  end

  -- For editable elements, use TextEditor buffer; for non-editable, use text
  local displayText = element._textEditor and element._textEditor:getText() or element.text
  local isPlaceholder = false
  local isPasswordMasked = false

  -- Show placeholder if editable and empty
  if element.editable and (not displayText or displayText == "") and element.placeholder then
    displayText = element.placeholder
    isPlaceholder = true
  end

  -- Apply password masking if enabled
  if element.passwordMode and displayText and displayText ~= "" and not isPlaceholder then
    local maskedText = string.rep("•", utf8.len(displayText))
    displayText = maskedText
    isPasswordMasked = true
  end

  if displayText and displayText ~= "" then
    local textColor = isPlaceholder and Color.new(element.textColor.r * 0.5, element.textColor.g * 0.5, element.textColor.b * 0.5, element.textColor.a * 0.5)
      or element.textColor
    local textColorWithOpacity = Color.new(textColor.r, textColor.g, textColor.b, textColor.a * self.opacity)
    love.graphics.setColor(textColorWithOpacity:toRGBA())

    local origFont = love.graphics.getFont()
    if element.textSize then
      -- Resolve font path from font family
      local fontPath = nil
      if element.fontFamily then
        -- Check if fontFamily is a theme font name
        local themeToUse = element.theme and Theme.get(element.theme) or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts[element.fontFamily] then
          fontPath = themeToUse.fonts[element.fontFamily]
        else
          -- Treat as direct path to font file
          fontPath = element.fontFamily
        end
      elseif element.themeComponent then
        -- If using themeComponent but no fontFamily specified, check for default font in theme
        local themeToUse = element.theme and Theme.get(element.theme) or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts.default then
          fontPath = themeToUse.fonts.default
        end
      end

      -- Use cached font instead of creating new one every frame
      local font = FONT_CACHE.get(element.textSize, fontPath)
      love.graphics.setFont(font)
    end
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(displayText)
    local textHeight = font:getHeight()
    local tx, ty

    -- Text is drawn in the content box (inside padding)
    -- For 9-patch components, use contentPadding if available
    local textPaddingLeft = element.padding.left
    local textPaddingTop = element.padding.top
    local textAreaWidth = element.width
    local textAreaHeight = element.height

    -- Check if we should use 9-patch contentPadding for text positioning
    local scaledContentPadding = element:getScaledContentPadding()
    if scaledContentPadding then
      local borderBoxWidth = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local borderBoxHeight = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

      textPaddingLeft = scaledContentPadding.left
      textPaddingTop = scaledContentPadding.top
      textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
      textAreaHeight = borderBoxHeight - scaledContentPadding.top - scaledContentPadding.bottom
    end

    local contentX = element.x + textPaddingLeft
    local contentY = element.y + textPaddingTop

    -- Check if text wrapping is enabled
    if element.textWrap and (element.textWrap == "word" or element.textWrap == "char" or element.textWrap == true) then
      -- Use printf for wrapped text
      local align = "left"
      if element.textAlign == TextAlign.CENTER then
        align = "center"
      elseif element.textAlign == TextAlign.END then
        align = "right"
      elseif element.textAlign == TextAlign.JUSTIFY then
        align = "justify"
      end

      tx = contentX
      ty = contentY

      -- Use printf with the available width for wrapping
      love.graphics.printf(displayText, tx, ty, textAreaWidth, align)
    else
      -- Use regular print for non-wrapped text
      if element.textAlign == TextAlign.START then
        tx = contentX
        ty = contentY
      elseif element.textAlign == TextAlign.CENTER then
        tx = contentX + (textAreaWidth - textWidth) / 2
        ty = contentY + (textAreaHeight - textHeight) / 2
      elseif element.textAlign == TextAlign.END then
        tx = contentX + textAreaWidth - textWidth - 10
        ty = contentY + textAreaHeight - textHeight - 10
      elseif element.textAlign == TextAlign.JUSTIFY then
        --- need to figure out spreading
        tx = contentX
        ty = contentY
      end

      -- Apply scroll offset for editable single-line inputs
      if element.editable and not element.multiline and element._textScrollX then
        tx = tx - element._textScrollX
      end

      -- Use scissor to clip text to content area for editable inputs
      if element.editable and not element.multiline then
        love.graphics.setScissor(contentX, contentY, textAreaWidth, textAreaHeight)
      end

      love.graphics.print(displayText, tx, ty)

      -- Reset scissor
      if element.editable and not element.multiline then
        love.graphics.setScissor()
      end
    end

    -- Draw cursor for focused editable elements (even if text is empty)
    if element._textEditor and element._textEditor:isFocused() and element._textEditor._cursorVisible then
      local cursorColor = element.cursorColor or element.textColor
      local cursorWithOpacity = Color.new(cursorColor.r, cursorColor.g, cursorColor.b, cursorColor.a * self.opacity)
      love.graphics.setColor(cursorWithOpacity:toRGBA())

      -- Calculate cursor position using TextEditor method
      local cursorRelX, cursorRelY = element._textEditor:_getCursorScreenPosition()
      local cursorX = contentX + cursorRelX
      local cursorY = contentY + cursorRelY
      local cursorHeight = textHeight

      -- Apply scroll offset for single-line inputs
      if not element.multiline and element._textEditor._textScrollX then
        cursorX = cursorX - element._textEditor._textScrollX
      end

      -- Apply scissor for single-line editable inputs
      if not element.multiline then
        love.graphics.setScissor(contentX, contentY, textAreaWidth, textAreaHeight)
      end

      -- Draw cursor line
      love.graphics.rectangle("fill", cursorX, cursorY, 2, cursorHeight)

      -- Reset scissor
      if not element.multiline then
        love.graphics.setScissor()
      end
    end

    -- Draw selection highlight for editable elements
    if element._textEditor and element._textEditor:isFocused() and element._textEditor:hasSelection() and element.text and element.text ~= "" then
      local selStart, selEnd = element._textEditor:getSelection()
      local selectionColor = element.selectionColor or Color.new(0.3, 0.5, 0.8, 0.5)
      local selectionWithOpacity = Color.new(selectionColor.r, selectionColor.g, selectionColor.b, selectionColor.a * self.opacity)

      -- Get selection rectangles from TextEditor
      local selectionRects = element._textEditor:_getSelectionRects(selStart, selEnd)

      -- Apply scissor for single-line editable inputs
      if not element.multiline then
        love.graphics.setScissor(contentX, contentY, textAreaWidth, textAreaHeight)
      end

      -- Draw selection background rectangles
      love.graphics.setColor(selectionWithOpacity:toRGBA())
      for _, rect in ipairs(selectionRects) do
        local rectX = contentX + rect.x
        local rectY = contentY + rect.y
        if not element.multiline and element._textEditor._textScrollX then
          rectX = rectX - element._textEditor._textScrollX
        end
        love.graphics.rectangle("fill", rectX, rectY, rect.width, rect.height)
      end

      -- Reset scissor
      if not element.multiline then
        love.graphics.setScissor()
      end
    end

    if element.textSize then
      love.graphics.setFont(origFont)
    end
  end

  -- Draw cursor for focused editable elements even when empty
  if element._textEditor and element._textEditor:isFocused() and element._textEditor._cursorVisible and (not displayText or displayText == "") then
    -- Set up font for cursor rendering
    local origFont = love.graphics.getFont()
    if element.textSize then
      local fontPath = nil
      if element.fontFamily then
        local themeToUse = element.theme and Theme.get(element.theme) or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts[element.fontFamily] then
          fontPath = themeToUse.fonts[element.fontFamily]
        else
          fontPath = element.fontFamily
        end
      end
      local font = FONT_CACHE.get(element.textSize, fontPath)
      love.graphics.setFont(font)
    end

    local font = love.graphics.getFont()
    local textHeight = font:getHeight()

    -- Calculate text area position
    local textPaddingLeft = element.padding.left
    local textPaddingTop = element.padding.top
    local scaledContentPadding = element:getScaledContentPadding()
    if scaledContentPadding then
      textPaddingLeft = scaledContentPadding.left
      textPaddingTop = scaledContentPadding.top
    end

    local contentX = element.x + textPaddingLeft
    local contentY = element.y + textPaddingTop

    -- Draw cursor
    local cursorColor = element.cursorColor or element.textColor
    local cursorWithOpacity = Color.new(cursorColor.r, cursorColor.g, cursorColor.b, cursorColor.a * self.opacity)
    love.graphics.setColor(cursorWithOpacity:toRGBA())
    love.graphics.rectangle("fill", contentX, contentY, 2, textHeight)

    if element.textSize then
      love.graphics.setFont(origFont)
    end
  end
end

--- Draw scrollbars (both vertical and horizontal)
---@param element table Reference to the parent Element instance
---@param x number X position
---@param y number Y position
---@param w number Width
---@param h number Height
---@param dims table Scrollbar dimensions from _calculateScrollbarDimensions
function Renderer:drawScrollbars(element, x, y, w, h, dims)
  -- Vertical scrollbar
  if dims.vertical.visible and not element.hideScrollbars.vertical then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + element.padding.left
    local contentY = y + element.padding.top
    local trackX = contentX + w - element.scrollbarWidth - element.scrollbarPadding
    local trackY = contentY + element.scrollbarPadding

    -- Determine thumb color based on state (independent for vertical)
    local thumbColor = element.scrollbarColor
    if element._scrollbarDragging and element._hoveredScrollbar == "vertical" then
      -- Active state: brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.4), math.min(1, thumbColor.g * 1.4), math.min(1, thumbColor.b * 1.4), thumbColor.a)
    elseif element._scrollbarHoveredVertical then
      -- Hover state: slightly brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.2), math.min(1, thumbColor.g * 1.2), math.min(1, thumbColor.b * 1.2), thumbColor.a)
    end

    -- Draw track
    love.graphics.setColor(element.scrollbarTrackColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY, element.scrollbarWidth, dims.vertical.trackHeight, element.scrollbarRadius)

    -- Draw thumb with state-based color
    love.graphics.setColor(thumbColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY + dims.vertical.thumbY, element.scrollbarWidth, dims.vertical.thumbHeight, element.scrollbarRadius)
  end

  -- Horizontal scrollbar
  if dims.horizontal.visible and not element.hideScrollbars.horizontal then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + element.padding.left
    local contentY = y + element.padding.top
    local trackX = contentX + element.scrollbarPadding
    local trackY = contentY + h - element.scrollbarWidth - element.scrollbarPadding

    -- Determine thumb color based on state (independent for horizontal)
    local thumbColor = element.scrollbarColor
    if element._scrollbarDragging and element._hoveredScrollbar == "horizontal" then
      -- Active state: brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.4), math.min(1, thumbColor.g * 1.4), math.min(1, thumbColor.b * 1.4), thumbColor.a)
    elseif element._scrollbarHoveredHorizontal then
      -- Hover state: slightly brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.2), math.min(1, thumbColor.g * 1.2), math.min(1, thumbColor.b * 1.2), thumbColor.a)
    end

    -- Draw track
    love.graphics.setColor(element.scrollbarTrackColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY, dims.horizontal.trackWidth, element.scrollbarWidth, element.scrollbarRadius)

    -- Draw thumb with state-based color
    love.graphics.setColor(thumbColor:toRGBA())
    love.graphics.rectangle("fill", trackX + dims.horizontal.thumbX, trackY, dims.horizontal.thumbWidth, element.scrollbarWidth, element.scrollbarRadius)
  end

  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end

--- Draw visual feedback when element is pressed
---@param x number X position
---@param y number Y position
---@param borderBoxWidth number Border box width
---@param borderBoxHeight number Border box height
function Renderer:drawPressedState(x, y, borderBoxWidth, borderBoxHeight)
  love.graphics.setColor(0.5, 0.5, 0.5, 0.3 * self.opacity) -- Semi-transparent gray for pressed state with opacity
  RoundedRect.draw("fill", x, y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
end

--- Cleanup renderer resources
function Renderer:destroy()
  self._element = nil
  self._loadedImage = nil
  self._blurInstance = nil
end

return Renderer
