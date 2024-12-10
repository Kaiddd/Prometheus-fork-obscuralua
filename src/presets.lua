-- function that generates a unique uuid
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

return {
    ["Basic"] = {
        -- The default LuaVersion is Lua51 but we can change it to LuaU
        LuaVersion = "LuaU",
        -- For minifying no VarNamePrefix is applied
        VarNamePrefix = "",
        -- Name Generator for Variables that look like this: IlI1lI1l
        NameGenerator = "MangledShuffled",
        -- No pretty printing
        PrettyPrint = false,
        -- Seed is generated based on current time
        Seed = 0,
        -- Obfuscation steps
        Steps = {
            {
                Name = "Vmify",
                Settings = {
                    VM = "CompilerA", -- Explicitly specify CompilerA for the free version
                },
            },
            {
                Name = "EncryptStrings",
                Settings = {

                },
            },
            {
                Name = "SplitStrings",
                Settings = {

                }
            },
            {
                Name = "WatermarkCheck",
                Settings = {
                    Content =
                    "This script is safeguarded by the free version of Prometheus, an advanced Lua obfuscation technology devised by levno-710. Version 1.1.0.",
                    CustomVariable = "__Prometheus__"
                }
            },
            {
                Name = "FreeAntiTamper",
                Settings = {

                }
            },
            {
                Name = "Vmify",
                Settings = {
                    VM = "CompilerA", -- Explicitly specify CompilerA for the free version
                },
            },
            {
                Name = "ConstantArray",
                Settings = {

                }
            },
            {
                Name = "StringsToExpressions",
                Settings = {

                }
            },
            {
                Name = "NumbersToExpressions",
                Settings = {

                }
            },
            {
                Name = "WrapInFunction",
                Settings = {

                }
            },


        }
    },


    ["Strong"] = {
        -- The default LuaVersion is Lua51 but we can change it to LuaU
        LuaVersion = "LuaU",
        -- For minifying no VarNamePrefix is applied
        VarNamePrefix = "",
        -- Name Generator for Variables that look like this: IlI1lI1l
        NameGenerator = "MangledShuffled",
        -- No pretty printing
        PrettyPrint = false,
        -- Seed is generated based on current time
        Seed = 0,
        -- Obfuscation steps
        Steps = {
            {
                Name = "Vmify",
                Settings = {
                    VM = "random", -- Specify "random" to select a random compiler in the paid version
                },
            },
            {
                Name = "AddVararg",
                Settings = {

                },
            },
            {
                Name = "EncryptStrings",
                Settings = {

                },
            },
            {
                Name = "SplitStrings",
                Settings = {

                }
            },
            {
                Name = "PaidAntiTamper",
                Settings = {

                },
            },
            {
                Name = "WatermarkCheck",
                Settings = {
                    Content =
                    "This script is safeguarded by the paid version of Prometheus, an advanced Lua obfuscation technology devised by levno-710. This script has been verified by Prometheus. Version 1.1.0.",
                    CustomVariable = "__Prometheus__"
                }
            },
            {
                Name = "Vmify",
                Settings = {
                    VM = "random", -- Specify "random" to select a random compiler in the paid version
                },
            },
            {
                Name = "ConstantArray",
                Settings = {

                }
            },
            {
                Name = "StringsToExpressions",
                Settings = {

                }
            },
            {
                Name = "NumbersToExpressions",
                Settings = {

                }
            },
            {
                Name = "WrapInFunction",
                Settings = {

                }
            },

            {
                Name = "ProxifyLocals",
                Settings = {

                }
            },
        }
    },
}