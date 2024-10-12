local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local targetLockEnabled = false
local cameraLockEnabled = false
local targetPlayer = nil
local horizontalPrediction = 0
local verticalPrediction = 0
local guiVisible = true -- Track GUI visibility

-- Create the GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create a smaller main frame for the GUI
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0.15, 0, 0.35, 0) -- Slightly taller for the lock button
mainFrame.Position = UDim2.new(0.85, 0, 0.1, 0) -- Positioned in the top right corner
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Dark background color
mainFrame.BorderSizePixel = 0

-- Add rounded corners to the main frame
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

-- Create the toggle button to open/close GUI
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0.08, 0, 0.04, 0) -- Adjusted size for the toggle button
toggleButton.Position = UDim2.new(0.92, 0, 0.05, 0) -- Top-right corner of the screen
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Button color
toggleButton.Text = "Toggle GUI"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 18 -- Reduced text size
toggleButton.BorderSizePixel = 0 -- No border

-- Add rounded corners to the toggle button
local toggleButtonCorner = Instance.new("UICorner", toggleButton)
toggleButtonCorner.CornerRadius = UDim.new(0, 10)

-- Function to toggle GUI visibility
local function toggleGUI()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
    if guiVisible then
        toggleButton.Text = "Hide GUI"
    else
        toggleButton.Text = "Show GUI"
    end
end

-- Create buttons and input boxes inside the main frame
local function createButton(text, position)
    local button = Instance.new("TextButton", mainFrame)
    button.Size = UDim2.new(1, 0, 0.15, 0) -- Full width, reduced height
    button.Position = position -- Position the button
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Button color
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18 -- Reduced text size
    button.BorderSizePixel = 0 -- No border

    -- Add rounded corners to the button
    local buttonCorner = Instance.new("UICorner", button)
    buttonCorner.CornerRadius = UDim.new(0, 10)

    return button
end

local function createTextBox(position)
    local textBox = Instance.new("TextBox", mainFrame)
    textBox.Size = UDim2.new(0.8, 0, 0.15, 0) -- Reduced width and height
    textBox.Position = position -- Position the textbox
    textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White background
    textBox.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
    textBox.Font = Enum.Font.SourceSans
    textBox.PlaceholderText = "Enter Value"
    textBox.TextSize = 18 -- Reduced text size
    textBox.ClearTextOnFocus = true -- Clear text when focused

    -- Add rounded corners to the textbox
    local textBoxCorner = Instance.new("UICorner", textBox)
    textBoxCorner.CornerRadius = UDim.new(0, 10)

    return textBox
end

-- Create the target lock and camera lock buttons
local targetLockButton = createButton("Toggle Target Lock", UDim2.new(0, 0, 0, 0))
local cameraLockButton = createButton("Toggle Camera Lock", UDim2.new(0, 0, 0.2, 0))

-- Create text boxes for horizontal and vertical prediction
local horizontalPredictionBox = createTextBox(UDim2.new(0, 0, 0.4, 0))
horizontalPredictionBox.Name = "HorizontalPredictionBox"
horizontalPredictionBox.PlaceholderText = "Horizontal Prediction"

local verticalPredictionBox = createTextBox(UDim2.new(0, 0, 0.6, 0))
verticalPredictionBox.Name = "VerticalPredictionBox"
verticalPredictionBox.PlaceholderText = "Vertical Prediction"

-- Create a lock button with the 🔒/🔓 emoji
local lockButton = Instance.new("TextButton", mainFrame)
lockButton.Size = UDim2.new(1, 0, 0.15, 0) -- Full width, reduced height
lockButton.Position = UDim2.new(0, 0, 0.8, 0) -- Adjust the position in the frame
lockButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Button color
lockButton.Text = "🔓 Lock Off" -- Default state is unlocked
lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockButton.Font = Enum.Font.SourceSans
lockButton.TextSize = 24 -- Emoji size
lockButton.BorderSizePixel = 0 -- No border

-- Add rounded corners to the lock button
local lockButtonCorner = Instance.new("UICorner", lockButton)
lockButtonCorner.CornerRadius = UDim.new(0, 10)

-- Function to toggle the lock button state
local isLocked = false

local function toggleLockButton()
    isLocked = not isLocked
    if isLocked then
        lockButton.Text = "🔒 Lock On" -- Change to locked state
        print("Lock On")
    else
        lockButton.Text = "🔓 Lock Off" -- Change to unlocked state
        print("Lock Off")
    end
end

-- Function to find the nearest player
local function getNearestPlayer()
    local nearestPlayer = nil
    local nearestDistance = math.huge -- Set initial distance to a huge value
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = otherPlayer
            end
        end
    end
    
    return nearestPlayer
end

-- Function to toggle target lock
local function toggleTargetLock()
    targetLockEnabled = not targetLockEnabled
    if targetLockEnabled then
        targetLockButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green if enabled
        print("Target Lock Enabled")
        
        -- Lock onto the nearest player
        targetPlayer = getNearestPlayer()
        if targetPlayer then
            print("Targeting: " .. targetPlayer.Name)
        else
            print("No player found")
        end
    else
        targetLockButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Default color if disabled
        targetPlayer = nil
        print("Target Lock Disabled")
    end
end

-- Function to toggle camera lock
local function toggleCameraLock()
    cameraLockEnabled = not cameraLockEnabled
    if cameraLockEnabled then
        cameraLockButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green if enabled
        print("Camera Lock Enabled")
    else
        cameraLockButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Default color if disabled
        print("Camera Lock Disabled")
    end
end

-- Function to hit the target player
local function hitTargetPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = targetPlayer.Character.Humanoid
        humanoid:TakeDamage(10) -- Deal 10 damage, change this value as needed
        print("Hit: " .. targetPlayer.Name)
    end
end

-- Function to update the camera lock position
local function updateCamera()
    if cameraLockEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            -- Get the position of the target's HumanoidRootPart
            local targetPosition = targetPart.Position
