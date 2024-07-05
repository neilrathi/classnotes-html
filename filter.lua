local graph_count = 0

function CodeBlock(el)
    local keywords = { "thrm", "postulate", "defn", "lemma", "proof", "corollary" } 

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
    
    if class == 'graph' then
        graph_count = graph_count + 1
        
        local div_id = 'calculator' .. graph_count
        local div_content = '<div id="' .. div_id .. '" class="desmos"></div>\n'
        
        local left = el.attributes.left or -10
        local right = el.attributes.right or 10
        local bottom = el.attributes.bottom or -6.67
        local top = el.attributes.top or 6.67
        
        local expressions = {}
        for line in el.text:gmatch("[^\r\n]+") do
            table.insert(expressions, line)
        end
        
        local script_content = '<script>\n' ..
                               'var elt' .. graph_count .. ' = document.getElementById("' .. div_id .. '");\n' ..
                               'var calculator' .. graph_count .. ' = Desmos.GraphingCalculator(elt' .. graph_count .. ', {\n' ..
                               '    expressions: false\n' ..
                               '});\n'
        
        for i, expr in ipairs(expressions) do
            script_content = script_content ..
                             'calculator' .. graph_count .. '.setExpression({id:"graph' .. graph_count .. '_' .. i .. '", latex:"' .. expr .. '"});\n'
        end
        
        script_content = script_content ..
                         'calculator' .. graph_count .. '.setMathBounds({\n' ..
                         '    left: ' .. left .. ',\n' ..
                         '    right: ' .. right .. ',\n' ..
                         '    bottom: ' .. bottom .. ',\n' ..
                         '    top: ' .. top .. '\n' ..
                         '});\n' ..
                         '</script>\n'

        return pandoc.RawBlock('html', div_content .. script_content)
    end

    if has_value(keywords, class) then
        local placeholders = {}
        local index = 1
        local text = el.text
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

        local markdown_parsed = pandoc.read(text, 'markdown')
        local html_converted = pandoc.write(markdown_parsed, 'html')

        html_converted = html_converted:gsub("DISPLAYMATHPLACEHOLDER(%d+)", function(idx)
            return "$$" .. placeholders["DISPLAYMATHPLACEHOLDER" .. idx] .. "$$"
        end)
        html_converted = html_converted:gsub("INLINEMATHPLACEHOLDER(%d+)", function(idx)
            return "$" .. placeholders["INLINEMATHPLACEHOLDER" .. idx] .. "$"
        end)

        html_converted = html_converted:gsub("^<p>(.-)</p>$", "%1")

        if class == "proof" then
            return pandoc.RawBlock('html', '<div class="proof">' .. html_converted .. '<span class="proof-square"></span></div>')
        else
            return pandoc.RawBlock('html', '<div class="' .. class .. ' box">' .. html_converted .. '</div>')
        end
    end
end