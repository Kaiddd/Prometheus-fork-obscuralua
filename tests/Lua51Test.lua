-- Utility function for asserting equality
function assertEqual(actual, expected, testName)
    if actual == expected then
        print(testName .. ": PASS")
    else
        print(testName .. ": FAIL - Expected " .. tostring(expected) .. ", got " .. tostring(actual))
    end
end

-- String Manipulation Tests
assertEqual(string.upper("hello"), "HELLO", "String Upper")
assertEqual(string.lower("HELLO"), "hello", "String Lower")
assertEqual(string.sub("Hello, World", 1, 5), "Hello", "String Sub")
assertEqual(select(2, string.find("Hello, World", "World")), 12, "String Find")
assertEqual(string.gsub("Hello, World", "World", "Lua"), "Hello, Lua", "String Gsub")
assertEqual(string.reverse("Lua"), "auL", "String Reverse")

-- Table Manipulation Tests
local tbl = {1, 2, 3}
table.insert(tbl, 4)
assertEqual(tbl[4], 4, "Table Insert")
table.remove(tbl, 1)
assertEqual(tbl[1], 2, "Table Remove")
table.sort(tbl, function(a, b) return a > b end)
assertEqual(tbl[1], 4, "Table Sort")
assertEqual(table.concat(tbl, ","), "4,3,2", "Table Concat")

-- Math Library Tests
assertEqual(math.max(1, 2, 3), 3, "Math Max")
assertEqual(math.min(1, 2, 3), 1, "Math Min")
math.randomseed(os.time())
print("Math Random: Skipping assert for random value")
assertEqual(math.floor(3.5), 3, "Math Floor")
assertEqual(math.ceil(3.5), 4, "Math Ceil")

-- IO Library Tests
local file = io.open("test.txt", "w")
file:write("Hello, Lua")
file:close()

file = io.open("test.txt", "r")
local content = file:read("*all")
file:close()
assertEqual(content, "Hello, Lua", "IO Write and Read")
os.remove("test.txt")
assertEqual(not io.open("test.txt", "r"), true, "IO Remove")

-- OS Library Tests
assertEqual(os.time() > 0, true, "OS Time")
assertEqual(os.date("%Y-%m-%d"), os.date("%Y-%m-%d"), "OS Date")
assertEqual(os.getenv("HOME"), nil, "OS Getenv")


-- Math Library Tests
assertEqual(1 + 1, 2, "Addition")
assertEqual(1 - 1, 0, "Subtraction")
assertEqual(1 * 1, 1, "Multiplication")
assertEqual(1 / 1, 1, "Division")
assertEqual(1 % 1, 0, "Modulo")
assertEqual(1 ^ 1, 1, "Exponentiation")

-- Comparison Tests
assertEqual(1 == 1, true, "Equal")
assertEqual(1 ~= 1, false, "Not Equal")
assertEqual(1 < 1, false, "Less Than")
assertEqual(1 <= 1, true, "Less Than or Equal")
assertEqual(1 > 1, false, "Greater Than")
assertEqual(1 >= 1, true, "Greater Than or Equal")

-- Logical Tests
assertEqual(true and true, true, "And")
assertEqual(true or false, true, "Or")
assertEqual(not true, false, "Not")