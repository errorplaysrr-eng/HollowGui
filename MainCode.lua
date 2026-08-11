local workspace = game:GetService("Workspace");
local players = game:GetService("Players");
local runService = game:GetService("RunService");
local statsService = game:GetService("Stats");
local localPlayer = players.LocalPlayer;
local coreGui = game:GetService("CoreGui");
local marketplaceService = game:GetService("MarketplaceService");

local DEFAULT_THEME_COLOR = Color3.fromRGB(220, 30, 30);

-- Cleanup old GUI if present
if coreGui:FindFirstChild("HollowClientSuite") then 
    coreGui.HollowClientSuite:Destroy() 
end

-- ==========================================
-- GAME DETECTION SYSTEM
-- ==========================================
local currentGameName = "";
pcall(function()
    local productInfo = marketplaceService:GetProductInfo(game.PlaceId);
    if productInfo and productInfo.Name then
        currentGameName = string.lower(productInfo.Name);
    end
end);
if currentGameName == "" then 
    currentGameName = string.lower(game.Name); 
end

local supportedGames = {
    { Name = "PetSimulator99", Key = "pet simulator 99" },
    { Name = "GrowAGarden2",  Key = "grow a garden" },
    { Name = "Fisch",          Key = "fisch" },
    { Name = "BloxFruits",      Key = "blox fruits" },
    { Name = "CageFishing",    Key = "cage fishing" },
    { Name = "Prospecting",    Key = "prospecting" }
};

-- Tracking elements for dynamic theme updates
_G.ThemeTextElements = {};
_G.ThemeBorderElements = {};

local function registerThemeText(instance)
    table.insert(_G.ThemeTextElements, instance);
end

local function registerThemeBorder(instance)
    table.insert(_G.ThemeBorderElements, instance);
end

-- ==========================================
-- 1. BASE GUI SETUP
-- ==========================================
local screenGui = Instance.new("ScreenGui");
screenGui.Name = "HollowClientSuite";
screenGui.ResetOnSpawn = false;
pcall(function() screenGui.Parent = coreGui; end);
if not screenGui.Parent then 
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui"); 
end;

local mainFrame = Instance.new("Frame");
mainFrame.Size = UDim2.new(0, 600, 0, 360);
mainFrame.Position = UDim2.new(0.25, 0, 0.25, 0);
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14);
mainFrame.BorderSizePixel = 0;
mainFrame.Active = true;
mainFrame.Draggable = true;
mainFrame.Parent = screenGui;

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8);

_G.MainStroke = Instance.new("UIStroke");
_G.MainStroke.Thickness = 1;
_G.MainStroke.Color = DEFAULT_THEME_COLOR;
_G.MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
_G.MainStroke.Parent = mainFrame;
registerThemeBorder(_G.MainStroke);

-- ==========================================
-- 2. SIDEBAR NAVIGATION
-- ==========================================
local sideBar = Instance.new("Frame", mainFrame);
sideBar.Size = UDim2.new(0, 150, 1, 0);
sideBar.BackgroundColor3 = Color3.fromRGB(8, 8, 10);
sideBar.BorderSizePixel = 0;
Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 8);

-- Subtle separator line between sidebar & content
local sideBarDivider = Instance.new("Frame", mainFrame);
sideBarDivider.Size = UDim2.new(0, 1, 0.9, 0);
sideBarDivider.Position = UDim2.new(0, 150, 0.05, 0);
sideBarDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 35);
sideBarDivider.BorderSizePixel = 0;

local logoLabel = Instance.new("TextLabel", sideBar);
logoLabel.Size = UDim2.new(1, 0, 0, 45);
logoLabel.BackgroundTransparency = 1;
logoLabel.Text = "HollowClient";
logoLabel.TextColor3 = DEFAULT_THEME_COLOR;
logoLabel.TextSize = 18;
logoLabel.Font = Enum.Font.GothamMedium;
registerThemeText(logoLabel);

local tabContainer = Instance.new("Frame", sideBar);
tabContainer.Size = UDim2.new(1, 0, 1, -50);
tabContainer.Position = UDim2.new(0, 0, 0, 45);
tabContainer.BackgroundTransparency = 1;

local btnLayout = Instance.new("UIListLayout", tabContainer);
btnLayout.Padding = UDim.new(0, 4);
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;

-- Header Close Button
local headerBar = Instance.new("Frame", mainFrame);
headerBar.Size = UDim2.new(1, -150, 0, 30);
headerBar.Position = UDim2.new(0, 150, 0, 0);
headerBar.BackgroundTransparency = 1;

local closeButton = Instance.new("TextButton", headerBar);
closeButton.Size = UDim2.new(0, 30, 0, 30);
closeButton.Position = UDim2.new(1, -35, 0, 0);
closeButton.BackgroundTransparency = 1;
closeButton.Text = "✕";
closeButton.TextColor3 = Color3.fromRGB(150, 150, 150);
closeButton.TextSize = 14;
closeButton.Font = Enum.Font.GothamMedium;
closeButton.MouseButton1Click:Connect(function() screenGui:Destroy(); end);

-- ==========================================
-- 3. CONTENT CONTAINER SETUP
-- ==========================================
local contentContainer = Instance.new("Frame", mainFrame);
contentContainer.Size = UDim2.new(1, -165, 1, -40);
contentContainer.Position = UDim2.new(0, 155, 0, 35);
contentContainer.BackgroundTransparency = 1;

_G.HollowTabs = {};

local currentSelectedButton = nil;

local function createTabButton(name)
    local button = Instance.new("TextButton", tabContainer);
    button.Size = UDim2.new(0, 135, 0, 30);
    button.BackgroundTransparency = 1;
    button.Text = "  " .. name;
    button.TextColor3 = Color3.fromRGB(160, 160, 170);
    button.TextSize = 12;
    button.TextXAlignment = Enum.TextXAlignment.Left;
    button.Font = Enum.Font.GothamMedium;
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6);
    
    local highlight = Instance.new("UIStroke", button);
    highlight.Color = Color3.fromRGB(40, 40, 45);
    highlight.Enabled = false;

    button.MouseButton1Click:Connect(function()
        for tabName, tabFrame in pairs(_G.HollowTabs) do 
            tabFrame.Visible = (tabName == name);
        end
        for _, child in ipairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") then 
                child.BackgroundTransparency = 1; 
                child.TextColor3 = Color3.fromRGB(160, 160, 170);
                child.Font = Enum.Font.GothamMedium;
                child:FindFirstChildOfClass("UIStroke").Enabled = false;
            end
        end
        button.BackgroundTransparency = 0;
        button.BackgroundColor3 = Color3.fromRGB(22, 18, 18);
        button.TextColor3 = _G.MainStroke.Color;
        buttonTextLabel.Font = Enum.Font.GothamMedium;
        highlight.Color = _G.MainStroke.Color;
        highlight.Enabled = true;
        currentSelectedButton = button;
    end);
end

local function createTextLabel(text, size, font, parent)
    local l = Instance.new("TextLabel", parent);
    l.Size = UDim2.new(1, 0, 0, 18);
    l.BackgroundTransparency = 1;
    l.Text = text;
    l.TextColor3 = DEFAULT_THEME_COLOR;
    l.TextSize = size;
    l.Font = font;
    l.TextXAlignment = Enum.TextXAlignment.Left;
    
    registerThemeText(l);
    return l;
end

-- Standard Tabs Configuration
local standardTabNames = {"Home", "Troll", "Themes", "Exploits", "WorkingGames", "GlobalExploits"};
for _, tName in ipairs(standardTabNames) do
    local tabFrame = Instance.new("Frame", contentContainer);
    tabFrame.Size = UDim2.new(1, 0, 1, 0);
    tabFrame.BackgroundTransparency = 1;
    tabFrame.Visible = false;
    _G.HollowTabs[tName] = tabFrame;
    createTabButton(tName);
end

-- ==========================================
-- HOME TAB CONTENT
-- ==========================================
local homePage = _G.HollowTabs.Home;
local profileFrame = Instance.new("Frame", homePage);
profileFrame.Size = UDim2.new(1, 0, 0, 130);
profileFrame.BackgroundTransparency = 1;

local avatarImage = Instance.new("ImageLabel", profileFrame);
avatarImage.Size = UDim2.new(0, 100, 0, 100);
avatarImage.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(0, 8);
local avatarStroke = Instance.new("UIStroke", avatarImage);
avatarStroke.Color = Color3.fromRGB(40, 40, 45);

task.spawn(function()
    avatarImage.Image = players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size180x180)
end);

local infoContainer = Instance.new("Frame", profileFrame);
infoContainer.Size = UDim2.new(1, -115, 0, 125);
infoContainer.Position = UDim2.new(0, 115, 0, 0);
infoContainer.BackgroundTransparency = 1;
local infoLayout = Instance.new("UIListLayout", infoContainer);
infoLayout.Padding = UDim.new(0, 3);

local dName = createTextLabel(localPlayer.DisplayName, 16, Enum.Font.GothamMedium, infoContainer);
local uName = createTextLabel("@" .. localPlayer.Name, 13, Enum.Font.GothamMedium, infoContainer);
local fLabel = createTextLabel("FPS: Checking...", 12, Enum.Font.Gotham, infoContainer);
local pLabel = createTextLabel("Ping: Checking...", 12, Enum.Font.Gotham, infoContainer);
local gLabel = createTextLabel("Game: Fetching...", 12, Enum.Font.Gotham, infoContainer);

task.spawn(function()
    local fCount = 0; local lastC = tick();
    runService.RenderStepped:Connect(function()
        fCount = fCount + 1;
        if tick() - lastC >= 1 then
            fLabel.Text = "FPS: " .. math.floor(fCount / (tick() - lastC));
            fCount = 0; lastC = tick();
            pcall(function() pLabel.Text = "Ping: " .. math.floor(statsService.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms" end);
        end
    end)
end);

task.spawn(function()
    local success, placeInfo = pcall(function() return marketplaceService:GetProductInfo(game.PlaceId) end)
    gLabel.Text = "Game: " .. (success and placeInfo.Name or game.Name);
end);

-- ==========================================
-- TROLL TAB CONTENT (EMOTE PLAYER SYSTEM)
-- ==========================================
local trollPage = _G.HollowTabs.Troll;

local emoteTitle = createTextLabel("EmotePlayer", 16, Enum.Font.GothamMedium, trollPage);
emoteTitle.Position = UDim2.new(0, 0, 0, 0);
emoteTitle.Size = UDim2.new(1, 0, 0, 25);

local emoteTextBox = Instance.new("TextBox", trollPage);
emoteTextBox.Size = UDim2.new(0, 240, 0, 35);
emoteTextBox.Position = UDim2.new(0, 0, 0, 30);
emoteTextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
emoteTextBox.Text = "";
emoteTextBox.PlaceholderText = "Enter Emote Asset ID...";
emoteTextBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 120);
emoteTextBox.TextColor3 = Color3.fromRGB(240, 240, 240);
emoteTextBox.TextSize = 12;
emoteTextBox.Font = Enum.Font.GothamMedium;
emoteTextBox.ClearTextOnFocus = false;
Instance.new("UICorner", emoteTextBox).CornerRadius = UDim.new(0, 6);

local boxStroke = Instance.new("UIStroke", emoteTextBox);
boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
boxStroke.Color = Color3.fromRGB(40, 40, 45);
boxStroke.Thickness = 1;

local btnContainer = Instance.new("Frame", trollPage);
btnContainer.Size = UDim2.new(0, 240, 0, 32);
btnContainer.Position = UDim2.new(0, 0, 0, 72);
btnContainer.BackgroundTransparency = 1;

local startBtn = Instance.new("TextButton", btnContainer);
startBtn.Size = UDim2.new(0, 115, 1, 0);
startBtn.Position = UDim2.new(0, 0, 0, 0);
startBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
startBtn.Text = "Start";
startBtn.TextColor3 = DEFAULT_THEME_COLOR;
startBtn.TextSize = 12;
startBtn.Font = Enum.Font.GothamMedium;
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6);
registerThemeText(startBtn);

local startStroke = Instance.new("UIStroke", startBtn);
startStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
startStroke.Color = DEFAULT_THEME_COLOR;
startStroke.Thickness = 1;
registerThemeBorder(startStroke);

local stopBtn = Instance.new("TextButton", btnContainer);
stopBtn.Size = UDim2.new(0, 115, 1, 0);
stopBtn.Position = UDim2.new(1, -115, 0, 0);
stopBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
stopBtn.Text = "Stop";
stopBtn.TextColor3 = Color3.fromRGB(200, 200, 200);
stopBtn.TextSize = 12;
stopBtn.Font = Enum.Font.GothamMedium;
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6);

local stopStroke = Instance.new("UIStroke", stopBtn);
stopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
stopStroke.Color = Color3.fromRGB(40, 40, 45);
stopStroke.Thickness = 1;

-- Status Label
local statusLabel = Instance.new("TextLabel", trollPage);
statusLabel.Size = UDim2.new(0, 240, 0, 25);
statusLabel.Position = UDim2.new(0, 0, 0, 110);
statusLabel.BackgroundTransparency = 1;
statusLabel.Text = "";
statusLabel.TextColor3 = Color3.fromRGB(255, 180, 50);
statusLabel.TextSize = 11;
statusLabel.Font = Enum.Font.GothamMedium;
statusLabel.TextWrapped = true;
statusLabel.TextXAlignment = Enum.TextXAlignment.Left;

_G.CurrentActiveEmoteTrack = nil;

startBtn.MouseButton1Click:Connect(function()
    local character = localPlayer.Character;
    if not character then 
        statusLabel.Text = "Character not found!";
        statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70);
        return; 
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid");
    if not humanoid then return; end

    -- Check RigType
    if humanoid.RigType == Enum.HumanoidRigType.R6 then
        statusLabel.Text = "Error: You need to be in an R15 game!";
        statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70);
        return;
    end

    local rawId = string.match(emoteTextBox.Text, "%d+");
    if not rawId then
        statusLabel.Text = "Please enter a valid Emote ID.";
        statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70);
        return;
    end

    -- Stop existing track if one is playing
    if _G.CurrentActiveEmoteTrack then
        _G.CurrentActiveEmoteTrack:Stop();
        _G.CurrentActiveEmoteTrack = nil;
    end

    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator");

    -- Extract Animation object from the Catalog Asset ID container
    local success, animObject = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. rawId);
        for _, obj in ipairs(objects) do
            if obj:IsA("Animation") then
                return obj;
            else
                local nestedAnim = obj:FindFirstChildOfClass("Animation", true);
                if nestedAnim then return nestedAnim; end
            end
        end
    end);

    if success and animObject then
        local track = animator:LoadAnimation(animObject);
        track.Priority = Enum.AnimationPriority.Action4;
        track:Play();
        _G.CurrentActiveEmoteTrack = track;

        statusLabel.Text = "Playing Emote ID: " .. rawId;
        statusLabel.TextColor3 = Color3.fromRGB(70, 255, 70);
    else
        statusLabel.Text = "Could not load animation from ID.";
        statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70);
    end
end);

stopBtn.MouseButton1Click:Connect(function()
    if _G.CurrentActiveEmoteTrack then
        _G.CurrentActiveEmoteTrack:Stop();
        _G.CurrentActiveEmoteTrack = nil;
        statusLabel.Text = "Emote stopped.";
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200);
    else
        statusLabel.Text = "No active emote playing.";
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150);
    end
end);

-- ==========================================
-- THEMES TAB CONTENT
-- ==========================================
local function updateTheme(targetColor)
    _G.MainStroke.Color = targetColor;
    for _, textObj in ipairs(_G.ThemeTextElements) do
        if textObj and textObj.Parent then
            textObj.TextColor3 = targetColor;
        end
    end
    for _, borderObj in ipairs(_G.ThemeBorderElements) do
        if borderObj and borderObj.Parent then
            borderObj.Color = targetColor;
        end
    end
    if currentSelectedButton then
        currentSelectedButton.TextColor3 = targetColor;
        local stroke = currentSelectedButton:FindFirstChildOfClass("UIStroke");
        if stroke then stroke.Color = targetColor; end
    end
end

local themesPage = _G.HollowTabs.Themes;
Instance.new("UIListLayout", themesPage).Padding = UDim.new(0, 6);

local function addTheme(name, color)
    local tBtn = Instance.new("TextButton", themesPage);
    tBtn.Size = UDim2.new(0, 240, 0, 30);
    tBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
    tBtn.Text = "  " .. name;
    tBtn.TextColor3 = color;
    tBtn.TextSize = 12;
    tBtn.TextXAlignment = Enum.TextXAlignment.Left;
    tBtn.Font = Enum.Font.GothamMedium;
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4);
    tBtn.MouseButton1Click:Connect(function() updateTheme(color) end);
end

addTheme("Hollow Red", Color3.fromRGB(220, 30, 30));
addTheme("Viper Green", Color3.fromRGB(30, 220, 90));
addTheme("Electric Blue", Color3.fromRGB(30, 140, 220));
addTheme("Cyber Purple", Color3.fromRGB(160, 30, 220));

-- ==========================================
-- EXPLOITS TAB CONTENT (Fixed)
-- ==========================================
local exploitsPage = _G.HollowTabs.Exploits;
local exploitsLayout = Instance.new("UIListLayout", exploitsPage);
exploitsLayout.Padding = UDim.new(0, 10);

local activeGameFound = false;

for _, gameData in ipairs(supportedGames) do
    -- Fixed: Only create elements once per loop iteration to avoid redeclaration errors
    if string.find(currentGameName, gameData.Key) then
        activeGameFound = true;
        
        local gamePanelFrame = Instance.new("Frame", exploitsPage);
        gamePanelFrame.Size = UDim2.new(1, 0, 0, 80); 
        gamePanelFrame.BackgroundTransparency = 1;
        
        local panelTitle = createTextLabel(gameData.Name .. " Panel", 16, Enum.Font.GothamMedium, gamePanelFrame);
         local sampleBtn = Instance.new("TextButton", gamePanelFrame);
        sampleBtn.Size = UDim2.new(0, 220, 0, 35);
        sampleBtn.Position = UDim2.new(0, 0, 0, 40);
        sampleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
        sampleBtn.Text = "AutoPickUp";
        sampleBtn.TextColor3 = DEFAULT_THEME_COLOR;
        sampleBtn.TextSize = 12;
        sampleBtn.Font = Enum.Font.GothamMedium;
        Instance.new("UICorner", sampleBtn).CornerRadius = UDim.new(0, 6);
        registerThemeText(sampleBtn);

        local btnStroke = Instance.new("UIStroke", sampleBtn);
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        btnStroke.Color = DEFAULT_THEME_COLOR;
        btnStroke.Thickness = 1;
        registerThemeBorder(btnStroke);


        local panelTitle = createTextLabel(gameData.Name .. " Panel", 16, Enum.Font.GothamMedium, gamePanelFrame);
        panelTitle.Size = UDim2.new(1, 0, 0, 30);

        local sampleBtn = Instance.new("TextButton", gamePanelFrame);
        sampleBtn.Size = UDim2.new(0, 220, 0, 35);
        sampleBtn.Position = UDim2.new(0, 0, 0, 80);
        sampleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
        sampleBtn.Text = "AutoPickUp";
        sampleBtn.TextColor3 = DEFAULT_THEME_COLOR;
        sampleBtn.TextSize = 12;
        sampleBtn.Font = Enum.Font.GothamMedium;
        Instance.new("UICorner", sampleBtn).CornerRadius = UDim.new(0, 6);
        registerThemeText(sampleBtn);

        local btnStroke = Instance.new("UIStroke", sampleBtn);
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        btnStroke.Color = DEFAULT_THEME_COLOR;
        btnStroke.Thickness = 1;
        registerThemeBorder(btnStroke);

        local panelTitle = createTextLabel(gameData.Name .. " Panel", 16, Enum.Font.GothamMedium, gamePanelFrame);
        panelTitle.Size = UDim2.new(1, 0, 0, 30);

        local sampleBtn = Instance.new("TextButton", gamePanelFrame);
        sampleBtn.Size = UDim2.new(0, 220, 0, 35);
        sampleBtn.Position = UDim2.new(0, 0, 0, 120);
        sampleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
        sampleBtn.Text = "AutoPickUp";
        sampleBtn.TextColor3 = DEFAULT_THEME_COLOR;
        sampleBtn.TextSize = 12;
        sampleBtn.Font = Enum.Font.GothamMedium;
        Instance.new("UICorner", sampleBtn).CornerRadius = UDim.new(0, 6);
        registerThemeText(sampleBtn);

        local btnStroke = Instance.new("UIStroke", sampleBtn);
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        btnStroke.Color = DEFAULT_THEME_COLOR;
        btnStroke.Thickness = 1;
        registerThemeBorder(btnStroke);


        local panelTitle = createTextLabel(gameData.Name .. " Panel", 16, Enum.Font.GothamMedium, gamePanelFrame);
        panelTitle.Size = UDim2.new(1, 0, 0, 30);

        local sampleBtn = Instance.new("TextButton", gamePanelFrame);
        sampleBtn.Size = UDim2.new(0, 220, 0, 35);
        sampleBtn.Position = UDim2.new(0, 0, 0, 160);
        sampleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25);
        sampleBtn.Text = "AutoPickUp";
        sampleBtn.TextColor3 = DEFAULT_THEME_COLOR;
        sampleBtn.TextSize = 12;
        sampleBtn.Font = Enum.Font.GothamMedium;
        Instance.new("UICorner", sampleBtn).CornerRadius = UDim.new(0, 6);
        registerThemeText(sampleBtn);

        local btnStroke = Instance.new("UIStroke", sampleBtn);
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        btnStroke.Color = DEFAULT_THEME_COLOR;
        btnStroke.Thickness = 1;
        registerThemeBorder(btnStroke);

    end
end

if not activeGameFound then
    local noGameLabel = createTextLabel("No active game modules for this place.", 13, Enum.Font.GothamMedium, exploitsPage);
    noGameLabel.Size = UDim2.new(1, 0, 0, 30);
end

-- ==========================================
-- WORKING GAMES TAB CONTENT
-- ==========================================
local wgPage = _G.HollowTabs.WorkingGames;
local wgLabel = Instance.new("TextLabel", wgPage);
wgLabel.Size = UDim2.new(1, -10, 1, -10);
wgLabel.Position = UDim2.new(0, 5, 0, 5);
wgLabel.BackgroundTransparency = 1;
wgLabel.TextColor3 = DEFAULT_THEME_COLOR;
wgLabel.TextSize = 13;
wgLabel.Font = Enum.Font.GothamMedium;
wgLabel.TextWrapped = true;
wgLabel.TextYAlignment = Enum.TextYAlignment.Top;
wgLabel.TextXAlignment = Enum.TextXAlignment.Left;
wgLabel.Text = "Supported Games:\n\n• PetSimulator99\n• GrowAGarden2\n• Fisch\n• BloxFruits\n• CageFishing\n• Prospecting";

registerThemeText(wgLabel);

_G.HollowTabs.Home.Visible = true;
-- ==========================================
-- Global Exploits TAB CONTENT
-- ==========================================

local globalPage = _G.HollowTabs.GlobalExploits
local globalLayout = Instance.new("UIListLayout", globalPage)
globalLayout.Padding = UDim.new(0, 6)

local instantPromptActive = false
local originalDurations = {}

local function setPromptInstant(p)
    if p:IsA("ProximityPrompt") then
        if not originalDurations[p] then 
            originalDurations[p] = p.HoldDuration 
        end
        p.HoldDuration = instantPromptActive and 0 or originalDurations[p]
    end
end

workspace.DescendantAdded:Connect(function(d) 
    if instantPromptActive then 
        setPromptInstant(d) 
    end 
end)

-- Textless Base Clickable Button
local promptButton = Instance.new("TextButton", globalPage)
promptButton.Size = UDim2.new(0, 240, 0, 32)
promptButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
promptButton.Text = "" -- Completely textless to kill the engine's bolding bug

Instance.new("UICorner", promptButton).CornerRadius = UDim.new(0, 4)
local stroke = Instance.new("UIStroke", promptButton)
stroke.Color = _G.MainStroke.Color 
registerThemeBorder(stroke) 

-- Overlay TextLabel (Guarantees clean, non-bold font weight)
local buttonTextLabel = Instance.new("TextLabel", promptButton)
buttonTextLabel.Size = UDim2.new(1, 0, 1, 0)
buttonTextLabel.BackgroundTransparency = 1
buttonTextLabel.Text = "Instant Interactions: OFF"
buttonTextLabel.TextColor3 = _G.MainStroke.Color 
buttonTextLabel.TextSize = 12
buttonTextLabel.Font = Enum.Font.GothamMedium -- Clean profile, matches your sidebar perfectly
registerThemeText(buttonTextLabel)

-- Click Functionality
promptButton.MouseButton1Click:Connect(function()
    instantPromptActive = not instantPromptActive
    
    if instantPromptActive then
        buttonTextLabel.Text = "Instant Interactions: ON"
    else
        buttonTextLabel.Text = "Instant Interactions: OFF"
        table.clear(originalDurations) 
    end
    
    for _, d in ipairs(workspace:GetDescendants()) do 
        setPromptInstant(d) 
    end
end)
