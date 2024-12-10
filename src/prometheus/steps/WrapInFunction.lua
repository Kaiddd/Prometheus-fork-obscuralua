-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- WrapInFunction.lua
--
-- This Script provides a Simple Obfuscation Step that wraps the entire Script into a function

local Step = require("Prometheus.step");
local Ast = require("Prometheus.ast");
local Scope = require("Prometheus.scope");

local WrapInFunction = Step:extend();
WrapInFunction.Description = "This Step Wraps the Entire Script into a Function";
WrapInFunction.Name = "Wrap in Function";

WrapInFunction.SettingsDescriptor = {
    Iterations = {
        name = "Iterations",
        description = "The Number Of Iterations",
        type = "number",
        default = 1,
        min = 1,
        max = nil,
    }
}

function WrapInFunction:init(settings)

end

function WrapInFunction:apply(ast)
    for i = 1, self.Iterations do
        local body = ast.body;
        local scope = Scope:new(ast.globalScope);
        body.scope:setParent(scope);

        -- Create a new vararg function that wraps the body
        local varargFunction = Ast.FunctionLiteralExpression({Ast.VarargExpression()}, body)

        -- Call the vararg function with the vararg expression as an argument
        local functionCall = Ast.FunctionCallExpression(varargFunction, {Ast.VarargExpression()})

        -- Wrap the function call in a return statement
        local returnStatement = Ast.ReturnStatement({functionCall})

        -- Wrap the return statement in a block
        ast.body = Ast.Block({returnStatement}, scope);
    end
end

return WrapInFunction;