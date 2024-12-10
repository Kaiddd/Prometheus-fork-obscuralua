-- This Script is Part of the Prometheus Obfuscator by levno-710
-- Library for Creating Random Literals

-- Import required modules
local Ast = require("Prometheus.ast")
local RandomStrings = require("Prometheus.randomStrings")

-- Initialize RandomLiterals table
local RandomLiterals = {}

-- Cache global functions
local random = math.random
local insert = table.insert

-- Define types outside of the function
local types = {
    { func = RandomLiterals.String,     needsPipeline = true },
    { func = RandomLiterals.Number,     needsPipeline = false },
    { func = RandomLiterals.Dictionary, needsPipeline = true },
    { func = RandomLiterals.Table,      needsPipeline = true }
}

-- Seed the RNG with a more complex seed at the start of the script
local function seedRNG()
    local timeSeed = os.time()
    local memUsageSeed = collectgarbage("count")
    local finalSeed = timeSeed + (memUsageSeed * 1000) -- Combine time and memory usage
    math.randomseed(finalSeed)
end

-- Call the name generator function
local function callNameGenerator(generatorFunction, ...)
    if (type(generatorFunction) == "table") then
        generatorFunction = generatorFunction.generateName
    end
    return generatorFunction(...)
end

-- Generate a list of random numbers
local randomNumbers = {}
for i = 1, 1024 do
    insert(randomNumbers, random(1, 1024))
end

-- Generate a random string
function RandomLiterals.String(pipeline)
    return Ast.StringExpression(callNameGenerator(pipeline.namegenerator, randomNumbers[random(#randomNumbers)]))
end

-- Cache for generated strings
local stringCache = {}

-- Generate a random dictionary
function RandomLiterals.Dictionary(pipeline, depth, maxDepth)
    depth = depth or 1       -- Provide a default value of 2 if depth is nil
    maxDepth = maxDepth or 1 -- Provide a default value of 1 if maxDepth is nil
    assert(pipeline ~= nil, "pipeline must not be nil")
    local dictionary = Ast.TableConstructorExpression({})
    local entryCount = 1 -- Limit the number of entries to 1
    for i = 1, entryCount do
        local key
        if stringCache[i] then
            key = stringCache[i]                  -- Use cached string
        else
            key = RandomLiterals.String(pipeline) -- Generate new string
            stringCache[i] = key                  -- Cache the generated string
        end
        local value
        if depth > 0 then
            value = key                     -- Use the same string for the value
        else
            value = RandomLiterals.Number() -- Use Number type for the value
        end
        insert(dictionary.entries, Ast.KeyValue(key, value))
    end
    -- Limit the depth of recursion
    if depth > maxDepth then
        return dictionary
    else
        return RandomLiterals.Any(pipeline, depth - 1, 1) -- Limit maxDepth to 1
    end
end

-- Generate a random number
function RandomLiterals.Number()
    return Ast.NumberExpression(random(-4194304, 4194303))
end

-- Generate a random table
function RandomLiterals.Table(pipeline)
    local entries = {
        Ast.KeyValue(RandomLiterals.String(pipeline), RandomLiterals.Any(pipeline))
    }
    return Ast.TableConstructorExpression(entries)
end

-- Generate any random literal
function RandomLiterals.Any(pipeline, depth, maxDepth)
    depth = depth or 1       -- Provide a default value of 1 if depth is nil
    maxDepth = maxDepth or 1 -- Provide a default value of 1 if maxDepth is nil
    if depth <= 0 or maxDepth <= 0 then
        -- Base case: return a simple type
        local simpleTypes = {
            { func = RandomLiterals.String, needsPipeline = true },
            { func = RandomLiterals.Number, needsPipeline = false }
        }
        local typeIndex = random(#simpleTypes)
        local selectedType = simpleTypes[typeIndex]
        if selectedType.needsPipeline then
            return selectedType.func(pipeline)
        else
            return selectedType.func()
        end
    else
        local typeIndex = random(#types)
        local selectedType = types[typeIndex]
        if selectedType.needsPipeline then
            if selectedType.func == RandomLiterals.Dictionary then
                return selectedType.func(pipeline, depth - 1, maxDepth - 1) -- Decrement maxDepth
            else
                return selectedType.func(pipeline)
            end
        else
            return selectedType.func()
        end
    end
end

-- Seed the RNG
seedRNG()

-- Return the RandomLiterals table
return RandomLiterals