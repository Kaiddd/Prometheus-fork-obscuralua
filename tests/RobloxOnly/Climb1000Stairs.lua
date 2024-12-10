--[[
    Climb 1000 Stairs Game ID:

    2017809925

    
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



repeat task.wait() until game:IsLoaded()

if getgenv().loaded then -- if the script has already been loaded, then say that it has already been loaded
    error("* Users Development Script Hub * has already been loaded")
end
getgenv().loaded = true





local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Vynixius/Source.lua"))()
local notif = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/notiflib/main/main"))()



notif:Notification("Users Development","Launching Script Hub with ❤️","GothamSemibold","Gotham",5) -- title: <string> description: <string> title font: <string> description font: <string> notification show time: <number>
local Window = Library:AddWindow({
	title = {"Users Development", "Climb 1000 Stairs"},
	theme = {
		Accent = Color3.fromRGB(0, 255, 0)
	},
	key = Enum.KeyCode.RightControl,
	default = true
})


print("✅ : Successfully loaded Users Development Script Hub [ Climb 1000 Stairs ]")


local Tab = Window:AddTab("Home", {default = true})

local Section = Tab:AddSection("General", {default = true})


local Button = Section:AddButton("Copy Discord", function()
    print("🟡 : Copying Discord link to clipboard")
    setclipboard("https://discord.gg/ecz2z36gkB")
    print("✅ : Discord link copied to clipboard")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)


local Tab = Window:AddTab("Climb 1k Stairs", {default = false})
local Section = Tab:AddSection("Player", {default = false})


local Slider = Section:AddSlider("Set Walkspeed", 16, 100, 16, {toggleable = true, default = false, flag = "Slider_Flag", fireontoggle = true, fireondrag = true, rounded = true}, function(val, bool)
    if bool == true then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        print("🟣 : Slider value:", val, " - Slider toggled:", bool)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)


local Slider = Section:AddSlider("Set Jump Power", 16, 100, 16, {toggleable = true, default = false, flag = "Slider_Flag", fireontoggle = true, fireondrag = true, rounded = true}, function(val, bool)
    if bool == true then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
        print("🟣 : Slider value:", val, " - Slider toggled:", bool)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    else
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

local Dropdown = Section:AddDropdown("Get Badge", {"VampyBadge", "SushiBadge", "MrBonesBadge"}, {default = "Pick Badge"}, function(selected)
    if selected == "VampyBadge" then
        print("🟣 : Dropdown value:", selected)
        print("🟡 : Attempting to get the badge ", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Badges.VampyBadge.CFrame
        print("✅ : Badge ", selected, " has been obtained")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "SushiBadge" then
        print("🟣 : Dropdown value:", selected)
        print("🟡 : Attempting to get the badge ", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Badges.SushiBadge.CFrame
        print("✅ : Badge ", selected, " has been obtained")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "MrBonesBadge" then
        print("🟣 : Dropdown value:", selected)
        print("🟡 : Attempting to get the badge ", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Badges.MrBonesBadge.CFrame
        print("✅ : Badge ", selected, " has been obtained")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end
end)



local Dropdown = Section:AddDropdown("Select Team", {"Climber", "Winner"}, {default = "Pick Team"}, function(selected)
    if selected == "Climber" then
        print("🟣 : Dropdown value:", selected)
        print("🟡 : Attempting to change team to ", selected)
        game.Players.LocalPlayer.Team = game:GetService("Teams").Climber
        print("✅ : Team Selected")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "Winner" then
        print("🟣 : Dropdown value:", selected)
        print("🟡 : Attempting to change team to ", selected)
        game.Players.LocalPlayer.Team = game:GetService("Teams").Winner
        print("✅ : Team Selected")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end
end)

local Button = Section:AddButton("Anti Ragdoll", function()
    print("🟡 : Anti Ragdoll")
    game:GetService("ReplicatedStorage").RagdollEvents.RagdollOff:FireServer()
    print("✅ : Anti Ragdoll has been enabled")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)

local Button = Section:AddButton("Inf Jump", function()
    print("✅ : Infinite Jump Enabled")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    game:GetService("UserInputService").JumpRequest:connect(function()
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end)
end)

local Button = Section:AddButton("Anti-AFK", function()
    print("🟡 : Enabled Anti-AFK")
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(function()
       vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
       wait(1)
       vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    print("✅ : Anti-AFK has been enabled")
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
end)



local Section = Tab:AddSection("Teleports", {default = false})

local Dropdown = Section:AddDropdown("Teleport to Place", {"Trails", "Shop", "Top"}, {default = "The Place You Want to Teleport to"}, function(selected)
    if selected == "Trails" then
        print("🟡 : Attempting to Teleport to ", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("ReplicatedStorage").Assets.Convertable.Color.CFrame
        print("✅ : Teleported to ", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "Shop" then
        print("🟡 : Attempting to Teleport to ", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Part.CFrame
        print("✅ : Teleported to ", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))


    elseif selected == "Top" then
        print("🟡 : Attempting to Teleport to ", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1016, 1007, 93)
        print("✅ : Teleported to ", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end
end)



local Dropdown = Section:AddDropdown("Teleport to Vehicle", {"Buggy", "Truck", "Sedan", "Lambo", "Aston"}, {default = "The Vehicle You Want to Teleport to"}, function(selected)

    if selected == "Buggy" then
        print("🟡 : Attempting to Teleport to", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Vehicles.BuggyGiver.Part.CFrame
        print("✅ : Teleported to the Vehicle", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "Truck" then
        print("🟡 : Attempting to Teleport to", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Vehicles.TruckGiver.Part.CFrame
        print("✅ : Teleported to the Vehicle ", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "Sedan" then
        print("🟡 : Attempting to Teleport to", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Vehicles.SedanGiver.Part.CFrame
        print("✅ : Teleported to the Vehicle ", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "Lambo" then
        print("🟡 : Attempting to Teleport to", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Vehicles.LamboGiver.Part.CFrame
        print("✅ : Teleported to the Vehicle", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))

    elseif selected == "Aston" then
        print("🟡 : Attempting to Teleport to", selected)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Vehicles.AstonGiver.Part.CFrame
        print("✅ : Teleported to the Vehicle ", selected)
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
    end
end)


local Box = Section:AddBox("Teleport to Player", {fireonempty = false}, function(Player)
	print(Player)
    if Player == "" then
        notif:Notification("Users Development","❌ : Player Not Found.","GothamSemibold","Gotham",5)
        print("❌ : No Player Name Entered")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
        return
    end
        
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")[Player].HumanoidRootPart.CFrame
    print("✅ : Teleported to ", Player)
    print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
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



local Section = Tab:AddSection("Autofarm", {default = false})

local Toggle = Section:AddToggle("Fast Autofarm", {flag = "Toggle_Flag", default = false}, function(bool)
	print("Toggle is now", bool)    

    if bool == true then
        print("✅: Fast Autofarm Enabled")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
        local TweenService = game:GetService("TweenService")

        local tweenInfo = TweenInfo.new(
            0.0001, --time
            Enum.EasingStyle.Quad, --easing style
            Enum.EasingDirection.Out, --easing direction
            0, --repeat count
            false, --reverses
            0 --delay
        )

        while wait() do
            if bool == true then
                for i,v in pairs(game:GetService("Workspace").Stairs:GetChildren()) do
                    if v.Name == "Part" then
                        local tween = TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = v.CFrame})
                        tween:Play()
                        tween.Completed:Wait()
                    end 
                end
            else
                break
            end
        end 
    else
        print("✅: Fast Autofarm Disabled")
        print(os.date("Current Date : %m/%d/%Y Time: %I:%M:%S %p", os.time()))
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
