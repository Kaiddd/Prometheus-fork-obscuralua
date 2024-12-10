local Ast, utils = require("Prometheus.ast"), require("Prometheus.util")
local math_random = math.random
local table_concat = table.concat
local table_insert = table.insert
local string_format = string.format

local englishCharset = utils.chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
local greekCharset = utils.chararray("αβγδεζηθικλμνξοπρστυφχψω")
local russianCharset = utils.chararray("абвгдеёжзийклмнопрстуфхцчшщъыьэюя")
local emojiCharset = utils.chararray("🤡🤠🤢🤣🤤🤥🤦🤧🤨🤩🤪🤫🤬🤭🤮🤯🤰🤱🤲🤳🤴🤵🤶🤷🤸🤹🤺🤻🤼🤽🤾🤿🥀🥁🥂🥃🥄🥅🥆🥇🥈🥉🥊🥋🥌🥍🥎🥏🥐🥑🥒🥓🥔🥕🥖🥗🥘🥙🥚🥛🥜🥝🥞🥟🥠🥡🥢🥣🥤🥥🥦🥧🥨🥩🥪🥫🥬🥭🥮🥯🥰🥱🥲🥳🥴🥵🥶🥷🥸🥹🥺🥻🥼🥽🥾🥿🦀🦁🦂🦃🦄🦅🦆🦇🦈🦉🦊🦋🦌🦍🦎🦏🦐🦑🦒🦓🦔🦕🦖🦗🦘🦙🦚🦛🦜🦝🦞🦟🦠🦡🦢🦣🦤🦥🦦🦧🦨🦩🦪🦫🦬🦭🦮🦯🦰🦱🦲🦳🦴🦵🦶🦷🦸🦹🦺🦻🦼🦽🦾🦿🧀🧁🧂🧃🧄")

local charsetStr = table_concat(englishCharset) .. table_concat(greekCharset) .. table_concat(russianCharset) .. table_concat(emojiCharset)
local charset = utils.chararray(charsetStr)

local memeStrings = {
    "gl require('Prometheus.Obfuscator')",
    "https://Prometheus.replit.app",
    "discord.gg/Prometheus",
    "levno-710 was here!",
    "Prometheus IS THE STRONGEST LUA OBFUSCATOR!",
    "English or spanish?",
    "I love Prometheus!",
    "I am a bot",
    "I am a human",
    "I am a cat",
    "I am a dog",
    "I am a bird",
    "If u try to deobfuscate this you're gay ;D",
    "This obfuscator is skid proof",
    "You can't touch what you can't analyze",
}

local operators = {"+", "-", "*", "/", "%", "^"}
local variables = {"x", "y", "z", "a", "b", "c"}
local nameStart = {"get", "set", "calc", "check", "find", "print", "create", "update", "delete", "handle"}
local nameEnd = {"Value", "Data", "Result", "Status", "Item", "Detail", "Info", "Element", "Object", "Entity"}

local function generateRandomOperator()
    return operators[math_random(#operators)]
end

local function generateRandomVariable()
    return variables[math_random(#variables)]
end

local function generateRandomNumber()
    return math_random(1, 100)
end

local function generateRandomFunctionName()
    local precomputedNames = {}
    for i, start in ipairs(nameStart) do
        for j, _end in ipairs(nameEnd) do
            table_insert(precomputedNames, start .. _end)
        end
    end
    return precomputedNames[math_random(#precomputedNames)]
end

local function generateFakeCodeSnippet()
    local snippetTypes = {
        function() return string_format("print('%s')", randomString(20)) end,
        function() return string_format("local %s = %d %s %d", generateRandomVariable(), generateRandomNumber(), generateRandomOperator(), generateRandomNumber()) end,
        function() return string_format("for i=1,%d do print(i) end", generateRandomNumber()) end,
        function() return string_format("local %s = %d", generateRandomVariable(), generateRandomNumber()) end,
        function() return string_format("local %s = {%d, %d, %d, %d, %d}", generateRandomVariable(), generateRandomNumber(), generateRandomNumber(), generateRandomNumber(), generateRandomNumber(), generateRandomNumber()) end,
        function() return string_format("local %s = {a = %d, b = %d, c = %d}", generateRandomVariable(), generateRandomNumber(), generateRandomNumber(), generateRandomNumber()) end,
        function() return string_format("function %s() return '%s' end", generateRandomFunctionName(), randomString(20)) end,
        function() return string_format("function %s() return '%s' end", generateRandomFunctionName(), randomString(20)) end,
        function() return string_format("function %s() return %d end", generateRandomFunctionName(), generateRandomNumber()) end,
        function() return string_format("function %s() return '%s' end", generateRandomFunctionName(), randomString(20)) end,
        function() return string_format("local %s = function() return '%s' end", generateRandomVariable(), randomString(20)) end,
        function() return string_format("local %s = function() return %d end", generateRandomVariable(), generateRandomNumber()) end,
        function() return string_format("local %s = function(%s) return %s end", generateRandomVariable(), generateRandomVariable(), generateRandomVariable()) end,
        function() return string_format("local %s = function(%s, %s) return %s + %s end", generateRandomVariable(), generateRandomVariable(), generateRandomVariable(), generateRandomVariable(), generateRandomVariable()) end,
    }

    local snippetType = snippetTypes[math.random(#snippetTypes)]
    return snippetType()
end

-- Define the function
randomString = function(wordsOrLen)
    local choice = math.random(1, 3)
    if choice == 1 then
        if type(wordsOrLen) == "table" then
            return wordsOrLen[math.random(1, #wordsOrLen)];
        end
        if type(wordsOrLen) ~= "number" then
            return memeStrings[math.random(1, #memeStrings)];
        end
        local result = {}
        local len = math.min(wordsOrLen, 20) -- Limit the length to 20
        for i = 1, len do
            result[i] = charset[math.random(1, #charset)]
        end
        return table.concat(result)
    elseif choice == 2 then
        return memeStrings[math.random(1, #memeStrings)]
    else
        return generateFakeCodeSnippet()
    end
end

local stringPool = {}
local maxStrings = 50 -- Set your desired limit here
while #stringPool < maxStrings do
    local newString = randomString(20)
    if not utils.contains(stringPool, newString) then
        table_insert(stringPool, newString)
    end
end

local function getRandomString()
    return stringPool[math_random(1, #stringPool)]
end

local function randomFakeCode()
    return generateFakeCodeSnippet()
end

local function randomStringNode(wordsOrLen)
    return Ast.StringExpression(getRandomString())
end

local function randomFakeCodeNode()
    return Ast.StringExpression(randomFakeCode())
end

return {
    randomString = getRandomString,
    randomStringNode = randomStringNode,
    randomFakeCode = randomFakeCode,
    randomFakeCodeNode = randomFakeCodeNode,
}