-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- AddVararg.lua
--
-- This Script provides a Simple Obfuscation Step that wraps the entire Script into a function

local Step  		 = require("Prometheus.step");
local Ast 		     = require("Prometheus.ast");
local visitast  	 = require("Prometheus.visitast");
local AstKind  		 = Ast.AstKind;

local AddVararg = Step:extend();
AddVararg.Description = "This Step Adds Vararg to all Functions";
AddVararg.Name = "Add Vararg";

AddVararg.SettingsDescriptor = {
    layers = {
        type = "number",
        default = math.random(5, 15),
        description = "Number of additional vararg wrapping layers"
    }
}

function AddVararg:init(settings)
end

function AddVararg:apply(ast)
    local VarargExpression = Ast.VarargExpression
    local IdentifierExpression = Ast.IdentifierExpression
    local FunctionLiteralExpression = Ast.FunctionLiteralExpression
    local vararg = VarargExpression()
    visitast(ast, nil, function(node)
        if node.kind == AstKind.FunctionDeclaration or node.kind == AstKind.LocalFunctionDeclaration or node.kind == AstKind.FunctionLiteralExpression then
            node.args = node.args or {}
            if #node.args < 1 or node.args[#node.args].kind ~= AstKind.VarargExpression then
                node.args[#node.args + 1] = vararg
            end

            for i = 1, self.layers, 1 do
                local newFunc = FunctionLiteralExpression()
                newFunc.args = newFunc.args or {}
                newFunc.args[#newFunc.args + 1] = vararg
                -- Insert a dummy argument
                newFunc.args[#newFunc.args + 1] = IdentifierExpression({ name = "dummy" .. tostring(i) })
                newFunc.body = { node }
                node = newFunc
            end
        end
    end)
end

return AddVararg;