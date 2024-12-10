-- This Script is Part of the Prometheus Obfuscator by levno-710
-- Prometheus.lua
-- This file is the entrypoint for Prometheus

-- Require Prometheus Submodules
local Pipeline  = require("Prometheus.pipeline")
local highlight = require("highlightlua")
local colors    = require("colors")
local Logger    = require("logger")
local Presets   = require("presets")
local Config    = require("config")
local util      = require("Prometheus.util")

-- Export
return {
    Pipeline  = Pipeline,
    colors    = colors,
    Config    = util.readonly(Config), -- Readonly
    Logger    = Logger,
    highlight = highlight,
    Presets   = Presets,
}