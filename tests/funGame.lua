-- ANSI escape codes for colors
local RED = "\27[31m"
local GREEN = "\27[32m"
local YELLOW = "\27[33m"
local RESET = "\27[0m"

-- Emojis
local SKULL = "💀"
local MONSTER = "👹"
local DOOR = "🚪"

-- Game state
local rooms = {
    ["hall"] = { description = "You are in a hall. There is a door to the south. " .. DOOR, south = "monsterRoom", monster = false },
    ["monsterRoom"] = { description = "You are in a room with a monster! " .. MONSTER, monster = true }
}
local player = { location = "hall", health = 100 }

-- Game functions
local function printColor(color, text)
    print(color .. text .. RESET)
end

local function move(direction)
    local room = rooms[player.location]
    if room[direction] then
        player.location = room[direction]
    else
        printColor(RED, "You can't go that way!")
    end
end

local function fight()
    local room = rooms[player.location]
    if room.monster then
        printColor(RED, "You fight the monster! " .. MONSTER)
        player.health = player.health - 20
        room.monster = false
    else
        printColor(GREEN, "There is nothing to fight.")
    end
end

-- Game loop
while player.health > 0 do
    local room = rooms[player.location]
    printColor(YELLOW, "\n-----------------------------")
    printColor(GREEN, "Health: " .. player.health)
    printColor(YELLOW, room.description)
    if room.monster then
        printColor(RED, "There is a monster here! " .. MONSTER)
    end
    print("What do you do? (Options: fight, move north, move south, move east, move west)")
    local action = io.read()
    if action == "fight" then
        fight()
    elseif action == "move north" then
        move("north")
    elseif action == "move south" then
        move("south")
    elseif action == "move east" then
        move("east")
    elseif action == "move west" then
        move("west")
    else
        printColor(RED, "I don't understand that action.")
    end
end

printColor(RED, "You have died. Game over. " .. SKULL)