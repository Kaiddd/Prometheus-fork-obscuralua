local colors = require("colors")

local function highlight(code)
    local out = ""
    local position = 1

    local function read()
        if position > #code then
            return nil
        end
        local c = code:sub(position, position)
        position = position + 1
        return c
    end

    local function highlightToken(token, color)
        return colors(token, color)
    end

    local function isKeyword(token)
        local keywords = { "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local",
            "nil", "not", "or", "repeat", "return", "then", "true", "until", "while" }
        for _, keyword in ipairs(keywords) do
            if token == keyword then
                return true
            end
        end
        return false
    end

    local function isGlobal(token)
        local globals = { "string", "table", "bit32", "bit" }
        for _, global in ipairs(globals) do
            if token == global then
                return true
            end
        end
        return false
    end

    local function isSymbol(token)
        local symbols = { ",", ";", "(", ")", "{", "}", ".", ":", "[", "]" }
        for _, symbol in ipairs(symbols) do
            if token == symbol then
                return true
            end
        end
        return false
    end

    while true do
        local token, kind = load(read)
        if not token then
            break
        end
        if kind == "keyword" or isKeyword(token) then
            out = out .. highlightToken(token, "yellow")
        elseif kind == "name" then
            if isGlobal(token) then
                out = out .. highlightToken(token, "red")
            else
                out = out .. token
            end
        elseif kind == "string" or kind == "number" then
            out = out .. highlightToken(token, kind == "string" and "green" or "red")
        elseif kind == "symbol" then
            if isSymbol(token) then
                out = out .. token
            else
                out = out .. highlightToken(token, "yellow")
            end
        else
            out = out .. token
        end
    end

    return out
end

return highlight
