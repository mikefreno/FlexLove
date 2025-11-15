-- LDoc configuration for FlexLöve
project = 'FlexLöve'
title = 'FlexLöve Documentation'
description = 'UI Library for LÖVE Framework based on flexbox'
format = 'discount' -- Use markdown formatting

-- Source files and directories
file = 'modules/'

-- Output directory
dir = 'docs'

-- Documentation options
all = false -- Don't document private (_prefixed) items by default
boilerplate = false -- Don't include boilerplate
not_luadoc = true -- Allow non-standard annotations
no_return_or_parms = true -- More lenient with params/returns
no_summary = true -- Don't require summary

-- README file to include as index
readme = 'README.md'

-- Sort items alphabetically
sort = true

-- Show function signatures
pretty = 'lua'

-- Topics
topics = {
  'README.md',
}

-- Use full names
full_description = true
