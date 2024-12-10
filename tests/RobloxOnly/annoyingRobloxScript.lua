-- Get services
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Change lighting
Lighting.Brightness = 0
Lighting.Ambient = Color3.new(1, 0, 1)

-- Distort camera
Workspace.CurrentCamera.FieldOfView = 120

-- Disable player controls
UserInputService.MouseIconEnabled = false
UserInputService.UserInputEnabled = false

-- Main Script

-- Get the PlayerGui
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Create a new ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomScreenGui"

-- Create a new ImageLabel
local imageLabel = Instance.new("ImageLabel")

-- Set the properties of the ImageLabel
imageLabel.Name = "YRRR"
imageLabel.Size = UDim2.new(0, 200, 0, 200) -- Change this to the size you want
imageLabel.Position = UDim2.new(0.5, -100, 0.5, -100) -- This will center the image
imageLabel.Image = "rbxassetid://6403436082" -- Replace with your image asset id

-- Create a new TextLabel for the text
local textLabel = Instance.new("TextLabel")

-- Set the properties of the TextLabel
textLabel.Name = "Prometheus IS #1"
textLabel.Size = UDim2.new(1, 0, 0, 50) -- This will make the text label the same width as the image and 50 pixels high
textLabel.Position = UDim2.new(0, 0, 1, 0) -- This will position the text label just below the image
textLabel.Text = "HACKED MF HAAAAAAAHAHAHAH"
textLabel.Font = Enum.Font.SourceSans
textLabel.TextSize = 24
textLabel.TextColor3 = Color3.new(1, 1, 1) -- This will make the text white
textLabel.BackgroundTransparency = 1 -- This will make the background of the text label transparent

-- Parent the TextLabel to the ImageLabel
textLabel.Parent = imageLabel

-- Parent the ImageLabel to the ScreenGui
imageLabel.Parent = screenGui

-- Parent the ScreenGui to the PlayerGui
screenGui.Parent = playerGui

-- Check if the image loaded successfully
if imageLabel.Image == "" then
    -- The image failed to load, create a new TextLabel
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "ErrorLabel"
    errorLabel.Size = UDim2.new(1, 0, 0, 50)
    errorLabel.Position = UDim2.new(0, 0, 0, 0) -- This will position the error label at the top of the screen
    errorLabel.Text = "Failed to load image"
    errorLabel.Font = Enum.Font.SourceSans
    errorLabel.TextSize = 24
    errorLabel.TextColor3 = Color3.new(1, 0, 0) -- This will make the text red
    errorLabel.BackgroundTransparency = 1 -- This will make the background of the error label transparent

    -- Parent the ErrorLabel to the ScreenGui
    errorLabel.Parent = screenGui
end

-- Create a loop to constantly change the game's environment
while true do
    -- Change the time of day every second
    for i = 0, 24, 0.1 do
        Lighting:SetMinutesAfterMidnight(i * 60)
        wait(0.1)
    end

    -- Randomly change the ambient light color
    Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())

    -- Randomly change the camera's field of view
    Workspace.CurrentCamera.FieldOfView = math.random(70, 120)

    -- Kick the player after 10 seconds
    
-- Create a loop to constantly change the game's environment
local hasKicked = false
while true do
    -- Change the time of day every second
    for i = 0, 24, 0.1 do
        Lighting:SetMinutesAfterMidnight(i * 60)
        wait(0.1)
    end

    -- Randomly change the ambient light color
    Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())

    -- Randomly change the camera's field of view
    Workspace.CurrentCamera.FieldOfView = math.random(70, 120)

    -- Kick the player after 10 seconds
    if not hasKicked then
        wait(10)
        -- Get the Players service
        local Players = game:GetService("Players")

        -- Define the player and the reason
        local player = Players.LocalPlayer
        local reason = "You have been kicked for being a big loser!"

        player:Kick(reason)
        hasKicked = true
    end
end
end