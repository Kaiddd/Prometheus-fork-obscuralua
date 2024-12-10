function extractLinks()
    local urls = {}
    -- Corrected pattern explanation:
    -- [a-zA-Z]+://: Matches the protocol (http, https, etc.)
    -- [%w_%.%-]+: Matches the domain name (including subdomains)
    -- %.[%a-z%.]+: Matches the TLD
    -- [/%w_%.~?&=+#%-]*: Optionally matches the path and query string, ensuring hyphen is correctly handled
    local pattern = "([a-zA-Z]+://[%w_%.%-]+%.[%a-z%.]+[/%w_%.~?&=+#%-]*)"
    for line in io.lines("script.obfuscated.lua") do
        for url in line:gmatch(pattern) do
            table.insert(urls, url)
        end
    end
    return urls
end

function main()
    local urls = extractLinks()
    for i, url in ipairs(urls) do
        print(i, url)
    end
end

main()