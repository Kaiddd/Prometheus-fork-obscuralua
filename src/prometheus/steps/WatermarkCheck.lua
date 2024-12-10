-- This Script is Part of the Prometheus Obfuscator by levno-710
-- WatermarkCheck.lua
-- This Script provides a Step that will add a watermark to the script

local Step = require("Prometheus.step")
local Ast = require("Prometheus.ast")
local Scope = require("Prometheus.scope")
local Watermark = require("Prometheus.steps.Watermark")
local EncryptStrings = require("Prometheus.steps.EncryptStrings")
local wrapInFunctionStep = require("Prometheus.steps.WrapInFunction")

local WatermarkCheck = Step:extend()

WatermarkCheck.Description = "This Step will verify the robust watermark in the script"
WatermarkCheck.Name = "RobustWatermarkCheck"
WatermarkCheck.SettingsDescriptor = {
  Content = {
    name = "Content",
    description = "The Content of the WatermarkCheck",
    type = "string",
    default =
    "This script is safeguarded by Prometheus, an advanced Lua obfuscation technology devised by levno-710."
  },
}

function WatermarkCheck:init(settings)
  -- Initialization code here
end

function WatermarkCheck:hash(content)
  local hash = 5381
  for i = 1, #content do
    local char = string.byte(content, i)
    hash = ((hash * 33) + char) % 0x100000000
    hash = hash - (hash % (char * 2 ^ ((i % 4) * 8)))
    hash = hash + (char * 2 ^ ((i % 4) * 8))
  end
  return tostring(hash)
end

function WatermarkCheck:checkRedefinition(ast)
  for _, statement in ipairs(ast.body.statements) do
    if statement.type == 'AssignmentStatement' then
      self:checkVariableInAssignment(statement)
    elseif statement.type == 'LocalStatement' then
      self:checkVariableInLocal(statement)
    elseif statement.type == 'FunctionDeclaration' then
      self:checkVariableInFunction(statement)
    end
  end
end

function WatermarkCheck:checkVariableInAssignment(statement)
  for _, variable in ipairs(statement.variables) do
    if variable.name == self.CustomVariable then
      self:insertCheck(statement)
    end
  end
end

function WatermarkCheck:checkVariableInLocal(statement)
  for _, variable in ipairs(statement.variables) do
    if variable.name == self.CustomVariable then
      self:insertCheck(statement)
    end
  end
end

function WatermarkCheck:checkVariableInFunction(statement)
  if statement.identifier and statement.identifier.name == self.CustomVariable then
    self:insertCheck(statement)
  end
end

function WatermarkCheck:insertCheck(statement)
  local notEqualsExpression = Ast.NotEqualsExpression(Ast.VariableExpression(Ast.globalScope, self.CustomVariable), Ast.StringExpression(self.Content))
  local ifBody = Ast.Block({ Ast.ReturnStatement({}) }, Scope:new(Ast.body.scope))
  table.insert(Ast.body.statements, 1, Ast.IfStatement(notEqualsExpression, ifBody, {}, nil))
end

function WatermarkCheck:apply(ast, pipeline)
  self:checkRedefinition(ast)
  -- Keep the custom variable name as __Prometheus__
  self.CustomVariable = "__Prometheus__"
  pipeline:addStep(Watermark:new(self))
  local body = ast.body
  local watermarkExpression = Ast.StringExpression(self.Content)
  local scope, variable = ast.globalScope:resolve(self.CustomVariable)
  local watermark = Ast.VariableExpression(ast.globalScope, variable)
  -- Compute the hash of the original watermark
  local originalHash = self:hash(self.Content)

  -- Embed the watermark in a less obvious way
  local embeddedWatermark = Ast.StringExpression(self.Content)

  -- Insert the watermark check at multiple random positions
  for i = 1, 5 do
      local notEqualsExpression = Ast.NotEqualsExpression(watermark, embeddedWatermark)
      local hashNotEqualsExpression = Ast.NotEqualsExpression(Ast.StringExpression(originalHash), Ast.StringExpression(self:hash(self.Content)))
      local ifBody = Ast.Block({ Ast.ReturnStatement({}) }, Scope:new(ast.body.scope))
      local insertPosition = math.random(1, #ast.body.statements)
      table.insert(body.statements, insertPosition, Ast.IfStatement(Ast.OrExpression(notEqualsExpression, hashNotEqualsExpression), ifBody, {}, nil))
  end

  -- Encrypt the WatermarkCheck code
  local encryptStringsStep = EncryptStrings:new()
  ast = encryptStringsStep:apply(ast, pipeline)

  -- Wrap the WatermarkCheck code in a function
  local wrapInFunction = wrapInFunctionStep:new()
  ast = wrapInFunction:apply(ast, pipeline)

  return ast
end

return WatermarkCheck