if getgenv().loaded then -- if the script has already been loaded, then say that it has already been loaded
    error("* Users Development Script Hub * has already been loaded")
end
getgenv().loaded = true



--[[
    Build a Boat for Treasure Game ID:

    210851291


--]]



--[[

-- How to use the teleport function with TweenService --

local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(
    5, --time
    Enum.EasingStyle.Quad, --easing style
    Enum.EasingDirection.Out, --easing direction
    0, --repeat count
    false, --reverses
    0 --delay
)

local tween = TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(POS X, POS Y, POS Z)})
tween:Play()


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
	title = {"Users Development", "Build a Boat for Treasure"},
	theme = {
		Accent = Color3.fromRGB(0, 255, 0)
	},
	key = Enum.KeyCode.RightControl,
	default = true
})


print("✅ : Successfully loaded Users Development Script Hub [ Build a Boat for Treasure ]")


local Tab = Window:AddTab("Home", {default = true})

local Section = Tab:AddSection("General", {default = true})


local Button = Section:AddButton("Copy Discord", function()
    print("🟡 : Copying Discord link to clipboard")
    setclipboard("https://discord.gg/ecz2z36gkB")
    print("✅ : Discord link copied to clipboard")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)




local Tab = Window:AddTab("Babft", {default = false})

local Section = Tab:AddSection("AutoFarm", {default = false})

local presscount = 0 --this is for the autofarm button

local Button = Section:AddButton("Instant TP Autofarm", function() --gets you 3k in 20 minutes
    presscount = presscount + 1


    if presscount > 1 then
        notif:Notification("Users Development","❌ : Already Running!","GothamSemibold","Gotham",5)
        print("🟡 : Instant TP Autofarm has been pressed more than once")
        print("❌ : This autofarm is already running")
        Notification.new("Users Development","❌ : Already Running!","GothamSemibold","Gotham",5)

        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    else
        local orgionalpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        print("🟡 : Instant TP has been pressed")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
        while wait() do
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage1.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage2.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage3.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage4.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage5.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage6.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage7.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage8.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage9.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.CaveStage10.DarknessPart.Position)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace").BoatStages.NormalStages.TheEnd.GoldenChest.Trigger.Position)
            wait(1)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = orgionalpos
            wait(20)
            print("✅ : Successfully completed the autofarm")
            print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
        end
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



coroutine.wrap(Users_Development)()
--coroutine is used to run the script in the background
--wrap is used to run the script in the background
--Users_Development is the name of the script