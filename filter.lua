function CodeBlock(el)
    local keywords = { "thrm", "postulate", "defn", "lemma" } 

    local function has_value (tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end

        return false
    end

    local class = el.classes[1]

    if class == 'python' then
        local html = '<div class="compute"><script type="text/x-python">\n'
        html = html .. el.text
        html = html .. '\n</script></div>'
        return pandoc.RawBlock('html', html)
    end

    if has_value(keywords, class) then
        -- Temporarily replace LaTeX expressions
        local placeholders = {}
        local index = 1
        local text = el.text
        -- Handling both inline and display math
        text = text:gsub("%$%$(.-)%$%$", function(latex)
            local placeholder = "DISPLAYMATHPLACEHOLDER" .. index
            placeholders[placeholder] = latex
            index = index + 1
            return placeholder
        end)
        text = text:gsub("%$(.-)%$", function(latex)
            local placeholder = "INLINEMATHPLACEHOLDER" .. index
            placeholders[placeholder] = latex
            index = index + 1
            return placeholder
        end)

        -- Parse as Markdown to HTML
        local markdown_parsed = pandoc.read(text, 'markdown')
        local html_converted = pandoc.write(markdown_parsed, 'html')

        -- Restore LaTeX expressions
        html_converted = html_converted:gsub("DISPLAYMATHPLACEHOLDER(%d+)", function(idx)
            return "$$" .. placeholders["DISPLAYMATHPLACEHOLDER" .. idx] .. "$$"
        end)
        html_converted = html_converted:gsub("INLINEMATHPLACEHOLDER(%d+)", function(idx)
            return "$" .. placeholders["INLINEMATHPLACEHOLDER" .. idx] .. "$"
        end)

        -- Remove unwanted <p> tags wrapping the entire block, if it's just a single block
        html_converted = html_converted:gsub("^<p>(.-)</p>$", "%1")

        return pandoc.RawBlock('html', '<div class="' .. class .. ' box">' .. html_converted .. '</div>')
    end
end