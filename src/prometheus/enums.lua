-- This Script is Part of the Prometheus Obfuscator by levno-710
--
-- enums.lua
-- This file Provides some enums used by the Obfuscator

local Enums = {};

local chararray = require("Prometheus.util").chararray;

Enums.LuaVersion = {
	LuaU  = "LuaU",
	Lua51 = "Lua51",
}

Enums.Conventions = {
	[Enums.LuaVersion.Lua51] = {
		Keywords = {
			"and", "break", "do", "else", "elseif",
			"end", "false", "for", "function", "if",
			"in", "local", "nil", "not", "or",
			"repeat", "return", "then", "true", "until", "while"
		},

		SymbolChars = chararray("+-*/%^#=~<>(){}[];:,._<>!&|"), -- added bitwise operators
		MaxSymbolLength = 4,
		Symbols = {
			"+", "-", "*", "/", "%", "^", "#",
			"==", "~=", "<=", ">=", "<", ">", "=",
			"(", ")", "{", "}", "[", "]",
			";", ":", ",", ".", "..", "...", "_",
			"!=", "&", "|", "&&", "||", "<<", ">>", "~" -- added bitwise operators
		},

		IdentChars = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789ΩΣΔΠабвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"),
		NumberChars = chararray("0123456789"),
		HexNumberChars = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars = { "0", "1" },
		DecimalExponent = { "e", "E" },
		HexadecimalNums = { "x", "X" },
		BinaryNums = { "b", "B" },
		DecimalSeperators = false,

		EscapeSequences = {
			["a"] = "\a",
			["b"] = "\b",
			["f"] = "\f",
			["n"] = "\n",
			["r"] = "\r",
			["t"] = "\t",
			["v"] = "\v",
			["\\"] = "\\",
			["\""] = "\"",
			["\'"] = "\'",
			["z"] = "\032",
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
		CustomEscapes = true, -- New field indicating we have added custom escape sequences

	},
	[Enums.LuaVersion.LuaU] = {
		Keywords = {
			"and", "break", "do", "else", "elseif", "continue",
			"end", "false", "for", "function", "if",
			"in", "local", "nil", "not", "or",
			"repeat", "return", "then", "true", "until", "while",
			-- Added hypothetical new Luau specific keywords below
			"import", "export", "try", "catch", "finally", "goto",
		},

		SymbolChars = chararray("+-*/%^#=~<>(){}[];:,.@<>!&|?$"),
		MaxSymbolLength = 4,
		Symbols = {
			"+", "-", "*", "/", "%", "^", "#",
			"==", "~=", "<=", ">=", "<", ">", "=",
			"+=", "-=", "/=", "%=", "^=", "..=", "*=",
			"(", ")", "{", "}", "[", "]",
			";", ":", ",", ".", "..", "...",
			"::", "->", "?", "|", "&", "@", "&&", "||", "~", "<<", ">>", "=>",
			"??", "?=", "<<<", ">>>", ":::"
		},

		IdentChars = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789ΩΣΔΠабвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"),
		NumberChars = chararray("0123456789"),
		HexNumberChars = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars = { "0", "1" },
		DecimalExponent = { "e", "E" },
		HexadecimalNums = { "x", "X" },
		BinaryNums = { "b", "B" },
		DecimalSeperators = { "_", "@", "$" }, -- Enhanced separator support

		EscapeSequences = {
			["a"] = "\a",
			["b"] = "\b",
			["f"] = "\f",
			["n"] = "\n",
			["r"] = "\r",
			["t"] = "\t",
			["v"] = "\v",
			["\\"] = "\\",
			["\""] = "\"",
			["\'"] = "\'",
			["@"] = "\000", -- Enhanced dummy escape sequence
			["z"] = "\032", -- Adding another escape sequence for consistency
			-- Hypothetical new escape sequences for Luau
			["$"] = "\034",
			["?"] = "\035",
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
		CustomEscapes = true, -- New field indicating we have added custom escape sequences
	},
}

return Enums;
