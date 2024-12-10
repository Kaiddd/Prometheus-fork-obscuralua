-- Get services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Get the PlayerGui
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create a new ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FunScreenGui"

-- Create a new TextLabel for the text
local textLabel = Instance.new("TextLabel")

-- Set the properties of the TextLabel
textLabel.Name = "FunMessage"
textLabel.Size = UDim2.new(1, 0, 0, 50) -- This will make the text label the full width of the screen and 50 pixels high
textLabel.Position = UDim2.new(0, 0, 0.5, -25) -- This will position the text label in the middle of the screen
textLabel.Text = "Let's have some fun!"
textLabel.Font = Enum.Font.SourceSans
textLabel.TextSize = 24
textLabel.TextColor3 = Color3.new(1, 1, 1) -- This will make the text white
textLabel.BackgroundTransparency = 1 -- This will make the background of the text label transparent

-- Parent the TextLabel to the ScreenGui
textLabel.Parent = screenGui

-- Parent the ScreenGui to the PlayerGui
screenGui.Parent = playerGui

-- Create a loop to constantly make the player's character jump
while true do
    -- Make the player's character jump
    Players.LocalPlayer.Character.Humanoid.Jump = true

    -- Wait for a random amount of time between 0.5 and 2 seconds
    wait(math.random(50, 200) / 100)

    -- Change the text label's text to a random funny message
    local messages = {"hi!", "__Prometheus__!", "Up, up, and away!", "I believe I can fly!", "Jump around!", "Hop to it!"}
    textLabel.Text = messages[math.random(#messages)]
end