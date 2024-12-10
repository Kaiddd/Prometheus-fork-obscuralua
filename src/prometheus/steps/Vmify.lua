local Step = require("Prometheus.step");
local logger = require("logger");
local CompilerA = require("Prometheus.compiler.compilerA");
local CompilerB = require("Prometheus.compiler.compilerB");
local CompilerC = require("Prometheus.compiler.compilerC");
local CompilerD = require("Prometheus.compiler.compilerD");
-- Add more compilers as needed

local Vmify = Step:extend();
Vmify.Description = "This Step will Compile your script into a fully-custom (not a half custom like other lua obfuscators) Bytecode Format and emit a vm for executing it.";
Vmify.Name = "Vmify";
Vmify.lastSelectedCompiler = nil; -- Static variable to remember the last selected compiler

Vmify.SettingsDescriptor = {
    -- vms to generate. The free version will only and always use CompilerA while the paid version will use a random compiler and any compiler
    VM = {
        name = "Vm",
        description = "The Vm to use for compiling the script",
        type = "string",
        default = "CompilerA", -- but the paid version will use a random compiler via math.random
    },
}

function Vmify:init(settings)
end

function Vmify:apply(ast)
    local compilers = {
        CompilerA = CompilerA,
        CompilerB = CompilerB,
        CompilerC = CompilerC,
        CompilerD = CompilerD,

    }

    local compiler
    if self.VM == "random" then
        local compilerKeys = {}
        for key, _ in pairs(compilers) do
            if key ~= Vmify.lastSelectedCompiler or next(compilers, next(compilers)) == nil then
                table.insert(compilerKeys, key)
            end
        end

        -- Shuffle compilerKeys to ensure a random order
        for i = #compilerKeys, 2, -1 do
            local j = math.random(1, i)
            compilerKeys[i], compilerKeys[j] = compilerKeys[j], compilerKeys[i]
        end

        if #compilerKeys == 0 then
            compilerKeys = {Vmify.lastSelectedCompiler}
        end

        local compilerKey = compilerKeys[1] -- Select the first compiler after shuffling
        logger:info(string.format("Selected Compiler: %s", compilerKey))
        compiler = compilers[compilerKey]:new()
        Vmify.lastSelectedCompiler = compilerKey
    else
        local compilerKey = self.VM or "CompilerA"
        if compilers[compilerKey] then
            logger:info(string.format("Selected Compiler: %s", compilerKey))
            compiler = compilers[compilerKey]:new()
            Vmify.lastSelectedCompiler = compilerKey
        else
            error(string.format("Compiler %s not found", tostring(compilerKey)))
        end
    end

    return compiler:compile(ast)
end

return Vmify;