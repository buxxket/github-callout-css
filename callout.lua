-- Pandoc Lua filter to convert > [!TYPE] callouts into HTML divs for styling
local icons = {
  WARNING = "&#9888;&#65039;",  -- ⚠️
  IMPORTANT = "&#10071;",       -- ❗
  TIP = "&#128161;",            -- 💡
  CAUTION = "&#9940;",          -- ⛔
  NOTE = "&#8505;&#65039;"      -- ℹ️
}
local colors = {
  WARNING = "warning",
  IMPORTANT = "important",
  TIP = "tip",
  CAUTION = "caution",
  NOTE = "note"
}

function BlockQuote(el)
  if #el.content > 0 and el.content[1].t == "Para" then
    local text = pandoc.utils.stringify(el.content[1])
    local m = text:match("^%[!(%u+)%]%s*")
    if m and colors[m] then
      local rest = text:gsub("^%[!%u+%]%s*", "")
      local children = el.content
      children[1] = pandoc.Para({pandoc.RawInline("html",
        '<div class="gh-callout gh-callout-' .. colors[m] .. '">'
        .. '<div class="gh-callout-title"><span class="gh-callout-icon">' .. (icons[m] or "") .. '</span>'
        .. m:sub(1,1)..m:sub(2):lower() .. '</div>'
        .. pandoc.utils.stringify(pandoc.Span(children[1].content):walk {
             Str = function(s)
               return s.text == ("[!"..m.."]") and pandoc.Str("") or s
             end
           })
      )})
      children[#children+1] = pandoc.RawBlock("html", "</div>")
      return pandoc.Div(children)
    end
  end
end
