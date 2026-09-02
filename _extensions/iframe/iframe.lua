--[[
  Embeds a zoomable iframe from a fenced div.

  Usage:
    ::: {.iframe url="https://example.com" title="Example site"}
    :::

  Attributes:
    url / src     required iframe source
    zoom          scale of the inner page (default 100%). Accepts 75%, 0.75, or 75
    width         visible viewport width (default 100%)
    height        visible viewport height (default 560)
    loading       iframe loading attr (default lazy)
    title         caption shown under the iframe (optional; also used as the iframe title)
    class         extra classes on the frame via class="..." or {.iframe .your-class}
    align         horizontal position on the page (default center). left|center|right
    valign        vertical alignment in a flex/grid parent (default center). top|center|bottom
    new-window    show an open-in-new-window control (default true)
]]

local DEFAULT_ZOOM = 1
local DEFAULT_WIDTH = "100%"
local DEFAULT_HEIGHT = "560px"

local OPEN_WINDOW_SVG = table.concat({
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"',
  ' stroke="currentColor" stroke-width="2" stroke-linecap="round"',
  ' stroke-linejoin="round" aria-hidden="true" focusable="false">',
  '<path d="M15 3h6v6"/>',
  '<path d="M10 14 21 3"/>',
  '<path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>',
  "</svg>"
})

local css_injected = false

local function is_html()
  return quarto.doc.is_format("html:js") or quarto.doc.is_format("html")
end

local function stringify(value)
  if value == nil then
    return ""
  end
  return pandoc.utils.stringify(value)
end

local function escape_html(text)
  return text
    :gsub("&", "&amp;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;")
end

local function escape_attr(text)
  return escape_html(text)
    :gsub('"', "&quot;")
    :gsub("'", "&#39;")
end

local function parse_zoom(value)
  local raw = stringify(value):gsub("%s+", "")
  if raw == "" then
    return DEFAULT_ZOOM
  end

  local pct = raw:match("^([%d%.]+)%%$")
  if pct then
    local num = tonumber(pct)
    if num and num > 0 then
      return num / 100
    end
    return DEFAULT_ZOOM
  end

  local num = tonumber(raw)
  if not num or num <= 0 then
    return DEFAULT_ZOOM
  end
  if num > 1 then
    return num / 100
  end
  return num
end

local function parse_align(value)
  local raw = stringify(value):lower():gsub("%s+", "")
  if raw == "left" or raw == "l" or raw == "start" then
    return "left"
  elseif raw == "right" or raw == "r" or raw == "end" then
    return "right"
  end
  return "center"
end

local function parse_valign(value)
  local raw = stringify(value):lower():gsub("%s+", "")
  if raw == "top" or raw == "t" or raw == "start" then
    return "top"
  elseif raw == "bottom" or raw == "b" or raw == "end" then
    return "bottom"
  end
  return "center"
end

local function parse_bool(value, default)
  local raw = stringify(value):lower():gsub("%s+", "")
  if raw == "" then
    return default
  end
  if raw == "false" or raw == "0" or raw == "no" or raw == "off" then
    return false
  end
  if raw == "true" or raw == "1" or raw == "yes" or raw == "on" then
    return true
  end
  return default
end

local function css_size(value, default)
  local raw = stringify(value):gsub("%s+", "")
  if raw == "" then
    return default
  end
  if raw:match("^[%d.]+$") then
    return raw .. "px"
  end
  return raw
end

local function split_classes(value)
  local classes = {}
  local raw = stringify(value)
  if raw ~= "" then
    for token in raw:gmatch("%S+") do
      table.insert(classes, token)
    end
  end
  return classes
end

local function has_class(classes, name)
  for _, class in ipairs(classes) do
    if class == name then
      return true
    end
  end
  return false
end

local function ensure_css()
  if css_injected then
    return
  end
  quarto.doc.add_html_dependency({
    name = "iframe",
    version = "1.1.0",
    stylesheets = { "iframe.css" }
  })
  css_injected = true
end

function Div(div)
  if not div.classes:includes("iframe") then
    return nil
  end
  if not is_html() then
    return nil
  end

  local url = stringify(div.attributes["url"] or div.attributes["src"])
  if url == "" then
    quarto.log.warning("iframe div is missing a url/src attribute")
    return nil
  end

  ensure_css()

  local zoom = parse_zoom(div.attributes["zoom"])
  local width = css_size(div.attributes["width"], DEFAULT_WIDTH)
  local height = css_size(div.attributes["height"], DEFAULT_HEIGHT)
  local align = parse_align(div.attributes["align"])
  local valign = parse_valign(div.attributes["valign"])
  local loading = stringify(div.attributes["loading"])
  if loading == "" then
    loading = "lazy"
  end
  local title = stringify(div.attributes["title"])
  local new_window = parse_bool(div.attributes["new-window"], true)

  local extra = {}
  for _, class in ipairs(div.classes) do
    if class ~= "iframe" then
      table.insert(extra, class)
    end
  end
  for _, class in ipairs(split_classes(div.attributes["class"])) do
    if class ~= "iframe" and not has_class(extra, class) then
      table.insert(extra, class)
    end
  end

  local frame_classes = { "iframe-embed__chrome" }
  for _, class in ipairs(extra) do
    table.insert(frame_classes, class)
  end

  local id_attr = ""
  if div.identifier ~= "" then
    id_attr = ' id="' .. escape_attr(div.identifier) .. '"'
  end

  local title_attr = ""
  local caption = ""
  if title ~= "" then
    title_attr = ' title="' .. escape_attr(title) .. '"'
    caption = "  <figcaption>" .. escape_html(title) .. "</figcaption>\n"
  end

  local tag = title ~= "" and "figure" or "div"
  local wrapper_class = title ~= "" and "iframe-embed figure" or "iframe-embed"
  wrapper_class = wrapper_class
    .. " iframe-embed--align-" .. align
    .. " iframe-embed--valign-" .. valign
  if new_window then
    wrapper_class = wrapper_class .. " iframe-embed--new-window"
  end

  local open_link = ""
  if new_window then
    local open_label = title ~= ""
      and ("Open " .. title .. " in a new window")
      or "Open in a new window"
    open_link = string.format(
      '    <a class="iframe-embed__open" href="%s" target="_blank" rel="noopener noreferrer" title="%s" aria-label="%s">\n'
        .. "      %s\n"
        .. "    </a>\n",
      escape_attr(url),
      escape_attr(open_label),
      escape_attr(open_label),
      OPEN_WINDOW_SVG
    )
  end

  local html = string.format(
    '<%s%s class="%s" style="--iframe-zoom: %s; --iframe-width: %s; --iframe-height: %s;">\n'
      .. '  <div class="%s">\n'
      .. '    <div class="iframe-embed__frame">\n'
      .. '      <iframe src="%s"%s loading="%s"></iframe>\n'
      .. "    </div>\n"
      .. "%s"
      .. "  </div>\n"
      .. "%s"
      .. "</%s>",
    tag,
    id_attr,
    wrapper_class,
    tostring(zoom),
    escape_attr(width),
    escape_attr(height),
    escape_attr(table.concat(frame_classes, " ")),
    escape_attr(url),
    title_attr,
    escape_attr(loading),
    open_link,
    caption,
    tag
  )

  return pandoc.RawBlock("html", html)
end
