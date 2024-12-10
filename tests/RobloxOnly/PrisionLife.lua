if getgenv().loaded then -- if the script has already been loaded, then say that it has already been loaded
    error("* Users Development Script Hub * has already been loaded")
end
getgenv().loaded = true


--[[
    Prision Life Game ID:

    73885730


--]]


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Vynixius/Source.lua"))()
local notif = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/notiflib/main/main"))()




if game:IsLoaded() then -- if the game is loaded, then say that the game has loaded
    print("✅ : Game has loaded")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    notif:Notification ("Users Development","✅ : Game has loaded","GothamSemibold","Gotham",0.1)
else
    print("🟡 : Game is loading")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    notif:Notification ("Users Development","🟡 : Game is loading","GothamSemibold","Gotham",0.1)
    game.Loaded:Wait() -- wait for the game to load
    print("✅ : Game has loaded")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    notif:Notification ("Users Development","✅ : Game has loaded","GothamSemibold","Gotham",0.1)
end

notif:Notification("Users Development","Launching Script Hub with ❤️","GothamSemibold","Gotham",5) -- title: <string> description: <string> title font: <string> description font: <string> notification show time: <number>
--[[
    Notification Library HOW TO USE [ SYNTAX ]

    PARAM 1: title: <string>
    PARAM 2: description: <string>
    PARAM 3: title font: <string>
    PARAM 4: description font: <string>
    PARAM 5: notification appearance time: <number>
--]]


local Window = Library:AddWindow({
	title = {"Users Development", "Prison Life"},
	theme = {
		Accent = Color3.fromRGB(0, 255, 0)
	},
	key = Enum.KeyCode.RightControl,
	default = true
})


print("✅ : Successfully loaded Users Development Script Hub [ Prison Life ]")


local Tab = Window:AddTab("Home", {default = true})

local Section = Tab:AddSection("General", {default = true})


local Button = Section:AddButton("Copy Discord", function()
    print("🟡 : Copying Discord link to clipboard")
    setclipboard("https://discord.gg/ecz2z36gkB")
    print("✅ : Discord link copied to clipboard")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)


local Tab = Window:AddTab("Prison Life", {default = false})

local Section = Tab:AddSection("Player", {default = false})



local Slider = Section:AddSlider("Set Walkspeed", 16, 500, 16, {toggleable = true, default = false, flag = "Slider_Flag", fireontoggle = true, fireondrag = true, rounded = true}, function(val, bool)
    if bool == true then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        print("🟣 : Slider value:", val, " - Slider toggled:", bool)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)




local Slider = Section:AddSlider("Set Jump Power", 16, 500, 16, {toggleable = true, default = false, flag = "Slider_Flag", fireontoggle = true, fireondrag = true, rounded = true}, function(val, bool)
    if bool == true then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
        print("🟣 : Slider value:", val, " - Slider toggled:", bool)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    else
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)


local Button = Section:AddButton("Infinite Jump", function()
    print("✅ : Infinite Jump Enabled")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    game:GetService("UserInputService").JumpRequest:connect(function()
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end)
end)







local Section = Tab:AddSection("Combat", {default = false})




local Button = Section:AddButton("Arrest All Crims", function()
    print("🟡 : Attempting to arresting all criminals")
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    -- Check if the character is seated
    if humanoid.SeatPart then
        humanoid.Sit = false -- Make the character stand up
        wait(1) -- Wait for a moment to ensure the character stands up
    end
    
    -- Function to check if a player is still a criminal
    local function isCriminal(player)
        return player.Team == game.Teams.Criminals
    end
    
    for i, v in pairs(game.Teams.Criminals:GetPlayers()) do
        if v.Name ~= player.Name then
            local inp = 10
            local retries = 3
            repeat
                wait()
                inp = inp - 1
                player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                game.Workspace.Remote.arrest:InvokeServer(v.Character.HumanoidRootPart)
                
                -- Check if the player is still a criminal
                if not isCriminal(v) then
                    break
                end
                
                retries = retries - 1
            until inp == 0 or retries == 0
        end
    end
    
    print("✅ : all criminals have been arrested")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)



local Section = Tab:AddSection("Teams", {default = false})


local Dropdown = Section:AddDropdown("Select Team", {"Criminals", "Guards", "Inmates", "Neutral"}, {default = "Pick Team"}, function(val)

    if val == "Guards" then
        print("🟣 : Dropdown value:", selected)
        game.Players.LocalPlayer.Team = game:GetService("Teams").Guards
        print("✅ : Team set to Guards")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end

    if val == "Criminals" then
        print("🟣 : Dropdown value:", selected)
        game.Players.LocalPlayer.Team = game:GetService("Teams").Criminals
        print("✅ : Team set to Criminals")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end

    if val == "Inmates" then
        print("🟣 : Dropdown value:", selected)
        game.Players.LocalPlayer.Team = game:GetService("Teams").Inmates
        print("✅ : Team set to Inmates")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end

    if val == "Neutral" then
        print("🟣 : Dropdown value:", selected)
        game.Players.LocalPlayer.Team = game:GetService("Teams").Neutral
        print("✅ : Team set to Neutral")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end
end)




local Section = Tab:AddSection("Other", {default = false})

local Button = Section:AddButton("Btools", function()
    print("🟡 : Attempting to get the tools: Clone, GameTool, Hammer, Script, Grab")
    if game.Players.LocalPlayer.Backpack:FindFirstChild("Clone") and game.Players.LocalPlayer.Backpack:FindFirstChild("GameTool") and game.Players.LocalPlayer.Backpack:FindFirstChild("Hammer") and game.Players.LocalPlayer.Backpack:FindFirstChild("Script") and game.Players.LocalPlayer.Backpack:FindFirstChild("Grab") then
        notif:Notification("Users Development","❌ : You already have the tools.","GothamSemibold","Gotham",5)
        print("❌ : You already have the tools: Clone, GameTool, Hammer, Script, Grab")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    else
        print("🟡 : Attempting to get the tools: Clone, GameTool, Hammer, Script, Grab")
        local tool1 = Instance.new("HopperBin",game.Players.LocalPlayer.Backpack)
        local tool2 = Instance.new("HopperBin",game.Players.LocalPlayer.Backpack)
        local tool3 = Instance.new("HopperBin",game.Players.LocalPlayer.Backpack)
        local tool4 = Instance.new("HopperBin",game.Players.LocalPlayer.Backpack)
        local tool5 = Instance.new("HopperBin",game.Players.LocalPlayer.Backpack)
        tool1.BinType = "Clone"
        tool2.BinType = "GameTool"
        tool3.BinType = "Hammer"
        tool4.BinType = "Script"
        tool5.BinType = "Grab"
        print("✅ : Successfully got the tools: Clone, GameTool, Hammer, Script, Grab")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end
end)


local Section = Tab:AddSection("Troll Players", {default = false})

local Box = Section:AddBox("Benx Player", {fireonempty = false}, function(Player)
	print("Annoying the player: " .. Player)
    if Player == "" then
        notif:Notification("Users Development","❌ : Player Not Found.","GothamSemibold","Gotham",5)
        print("❌ : Error: Player Not Found")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
        return
    end
        
    if Player ~= "" then
        local Player = game.Players:FindFirstChild(Player)
        if Player then
            while wait(0.1) do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame
            end
        else
            notif:Notification("Users Development","❌ : Player Not Found.","GothamSemibold","Gotham",5)
            print("❌ : Error: Player Not Found")
            print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
        end
    end
end)




local Tab = Window:AddTab("Settings", {default = false})

local Section = Tab:AddSection("Script", {default = false})

local Bind = Section:AddBind("Hide/Show Bind", Enum.KeyCode.RightShift, {toggleable = true, default = false, flag = "Bind_Flag"}, function(keycode)
	Window:SetKey(keycode)
end)

local Section = Tab:AddSection("Server", {default = false})

local Button = Section:AddButton("Switch to Random Server", function()
    print("🟡 : Switching to random server")
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    print("✅ : Switched to random server")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)


local Button = Section:AddButton("Rejoin", function()
    print("🟡 : Rejoining")
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    print("✅ : Rejoined")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)



coroutine.wrap(SCRIPT_1JZQ_fake_script)()