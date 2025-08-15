local callout_types = {
  WARNING   = {icon = "&#9888;&#65039;", klass = "warning",    label = "Warning"},
  IMPORTANT = {icon = "&#10071;",        klass = "important",  label = "Important"},
  TIP       = {icon = "&#128161;",       klass = "tip",        label = "Tip"},
  CAUTION   = {icon = "&#9940;",         klass = "caution",    label = "Caution"},
  NOTE      = {icon = "&#8505;&#65039;", klass = "note",       label = "Note"},
}

function BlockQuote(el)
  if #el.content > 0 and el.content[1].t == "Para" then
    local first = pandoc.utils.stringify(el.content[1])
    local m = first:match("^%[!(%u+)%]%s*$")
    if m and callout_types[m] then
      -- Multi-line callout: first line is [!TYPE], rest is content
      local content = {}
      for i = 2, #el.content do
        table.insert(content, el.content[i])
      end
      local inner = pandoc.write(pandoc.Pandoc(content), "html")
      local t = callout_types[m]
      local html = string.format(
        '<div class="gh-callout gh-callout-%s"><div class="gh-callout-title"><span class="gh-callout-icon">%s</span>%s</div>%s</div>',
        t.klass, t.icon, t.label, inner
      )
      return pandoc.RawBlock("html", html)
    else
      -- Single-line callout: [!TYPE] content...
      local sm, scontent = first:match("^%[!(%u+)%]%s*(.+)")
      if sm and callout_types[sm] then
        local t = callout_types[sm]
        local html = string.format(
          '<div class="gh-callout gh-callout-%s"><div class="gh-callout-title"><span class="gh-callout-icon">%s</span>%s</div><p>%s</p></div>',
          t.klass, t.icon, t.label, scontent
        )
        return pandoc.RawBlock("html", html)
      end
    end
  end
end

