-- Adapted code from https://github.com/michal-h21/luaxml-mathml
--
local domobject = require "luaxml-domobject"

local process_children

-- We need to define different actions for XML elements. The default action is
-- to just process child elements and return the result
local function default_action(element)
  return process_children(element)
end

-- Use template string to place the processed children
local function simple_content(str)
  return function(element)
    local content = process_children(element)
    -- Process attrubutes
    -- Attribute should be marked as @{name}
    local expanded = str:gsub("@{(.-)}", function(name)
      return element:get_attribute(name) or ""
    end)
    return string.format(expanded, content)
  end
end

-- Actions for particular elements
local actions = {}

-- Add more complicated action
local function add_custom_action(name, fn)
  actions[name] = fn
end

-- Normal actions
local function add_action(name, template)
  actions[name] = simple_content(template)
end

-- Convert Unicode characters to TeX sequences
local unicodes = {
  [35] = "\\#",
  [38] = "\\&",
  [60] = "\\textless{}",
  [62] = "\\textgreater{}",
  [92] = "\\textbackslash{}",
  [123] = "\\{",
  [125] = "\\}"
}

local function process_text(text)
  local t = {}
  -- Process all Unicode characters and find if they should be replaced
  for _, char in utf8.codes(text) do
    -- Construct new string with replacements or original char
    t[#t+1] = unicodes[char] or utf8.char(char)
  end
  return table.concat(t)
end

local function process_tree(element)
  -- find specific action for the element, or use the default action
  local element_name = element:get_element_name()
  local action = actions[element_name] or default_action
  return action(element)
end

local function process_children(element)
  -- Accumulate text from children elements
  local t = {}
  -- Sometimes we may get text node
  if type(element) ~= "table" then return element end
  for i, elem in ipairs(element:get_children()) do
    if elem:is_text() then
      -- Concat text
      t[#t+1] = process_text(elem:get_text())
    elseif elem:is_element() then
      -- Recursivelly process child elements
      t[#t+1] = process_tree(elem)
    end
  end
  return table.concat(t)
end

local function parse_xml(content)
  -- Parse XML string and process it
  local dom = domobject.parse(content)
  -- Start processing of DOM from the root element
  -- Return string with TeX content
  return process_tree(dom:root_node())
end

local function load_file(filename)
  local f = io.open(filename, "r")
  local content = f:read("*all")
  f:close()
  return parse_xml(content)
end

local function print_tex(content)
  -- We need to replace "\n" characters with calls to tex.sprint
  for s in content:gmatch("([^\n]*)") do
    tex.sprint(s)
  end
end

return {
  parse_xml = parse_xml,
  process_children = process_children,
  print_tex = print_tex,
  add_action = add_action,
  add_custom_action = add_custom_action,
  simple_content = simple_content,
  load_file = load_file
}
