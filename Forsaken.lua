local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

-- Variables
local localplayer = Players.LocalPlayer
local currentCharacter = localplayer.Character or localplayer.CharacterAdded:Wait()
local testPath = PathfindingService:CreatePath()
_G.autoRun = false
_G.killAuraConnection = nil
_G.espConnections = {}

-- Functions
local function killerNearby()
    for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
        if killer:FindFirstChild("HumanoidRootPart") then
            local dist = (killer.HumanoidRootPart.Position - currentCharacter.HumanoidRootPart.Position).Magnitude
            if dist < 120 then
                return true
            end
        end
    end
    return false
end

local function runAway()
    VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
    for _ = 1, 5 do
        local angle = math.rad(math.random(0, 220))
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 250
        testPath:ComputeAsync(currentCharacter.HumanoidRootPart.Position, currentCharacter.HumanoidRootPart.Position + offset)
        
        if testPath.Status == Enum.PathStatus.Success then
            local waypoints = testPath:GetWaypoints()
            for _, wp in ipairs(waypoints) do
                if not _G.autoRun then 
                    VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                    return 
                end
                
                currentCharacter.Humanoid:MoveTo(wp.Position)
                currentCharacter.Humanoid.MoveToFinished:Wait()
                
                local killerTooClose = false
                for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
                    if killer:FindFirstChild("HumanoidRootPart") then
                        local dist = (killer.HumanoidRootPart.Position - currentCharacter.HumanoidRootPart.Position).Magnitude
                        if dist < 120 then
                            killerTooClose = true
                            break
                        end
                    end
                end
                
                if not killerTooClose then
                    VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                    return
                end
            end
        end
    end
    VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
end

local function repairGenerators()
    for _, gen in ipairs(workspace.Map.Ingame.Map:GetChildren()) do
        if not _G.autoRun then return end
        
        if gen.Name == "Generator" and gen:FindFirstChild("Progress") and gen.Progress.Value < 100 then
            -- Teleport directly to generator
            local targetPosition = gen.Positions.Right.Position or gen.Position
            currentCharacter.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
            
            -- Immediately start repairing
            local prompt = gen.Main and gen.Main:FindFirstChild("Prompt")
            if prompt then
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 99999
                
                for i = 1, 10 do
                    if not _G.autoRun then  -- Removed killer check
                        prompt:InputHoldEnd()
                        return
                    end
                    prompt:InputHoldBegin()
                    task.wait(0.1)
                    prompt:InputHoldEnd()
                    gen.Remotes.RE:FireServer()
                    if gen.Progress.Value >= 110 then break end
                    task.wait(2.5)
                end
            end
        end
    end
end

local function toggleStaminaHack(state)
    local staminaLoopThread
    
    if state then
        staminaLoopThread = task.spawn(function()
            while true do
                require(game.ReplicatedStorage.Systems.Character.Game.Sprinting).StaminaLossDisabled = true
                task.wait(0.1)
            end
        end)
    else
        if staminaLoopThread then
            task.cancel(staminaLoopThread)
            require(game.ReplicatedStorage.Systems.Character.Game.Sprinting).StaminaLossDisabled = false
        end
    end
end

local function instantKill(targetPlayer)
    if not localplayer.Character:FindFirstChild("Knife") then
        if localplayer.Backpack:FindFirstChild("Knife") then
            localplayer.Character.Humanoid:EquipTool(localplayer.Backpack.Knife)
        else
            return
        end
    end

    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    targetHRP.Anchored = true
    targetHRP.CFrame = localplayer.Character.HumanoidRootPart.CFrame + 
                      localplayer.Character.HumanoidRootPart.CFrame.LookVector * 2
    task.wait(0.1)
    localplayer.Character.Knife.Stab:FireServer("Slash")
end

local function createKillAura()
    return RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localplayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local myHrp = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
                
                if myHrp and (hrp.Position - myHrp.Position).Magnitude < 7 then
                    hrp.Anchored = true
                    hrp.CFrame = myHrp.CFrame + myHrp.CFrame.LookVector * 2
                    task.wait(0.1)
                    if localplayer.Character:FindFirstChild("Knife") then
                        localplayer.Character.Knife.Stab:FireServer("Slash")
                    end
                end
            end
        end
    end)
end

-- ESP Functions
local function clearESP(type)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:FindFirstChild(type) then
            obj[type]:Destroy()
        end
    end
end

local function createPlayerESP()
    clearESP("PlayerESP")
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localplayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "PlayerESP"
            highlight.Adornee = player.Character
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineTransparency = 1
            highlight.Parent = player.Character
        end
    end
    
    -- Setup connection for new players
    if _G.espConnections["PlayerESP"] then
        _G.espConnections["PlayerESP"]:Disconnect()
    end
    
    _G.espConnections["PlayerESP"] = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if _G.playerESPEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Adornee = character
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineTransparency = 1
                highlight.Parent = character
            end
        end)
    end)
end

local function createGeneratorESP()
    clearESP("GeneratorESP")
    
    if workspace:FindFirstChild("Map") then
        for _, gen in ipairs(workspace.Map:GetDescendants()) do
            if gen.Name == "Generator" then
                local highlight = Instance.new("Highlight")
                highlight.Name = "GeneratorESP"
                highlight.Adornee = gen
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.OutlineTransparency = 1
                highlight.Parent = gen
            end
        end
    end
end

local function createItemESP()
    clearESP("ItemESP")
    
    if workspace:FindFirstChild("Map") then
        for _, item in ipairs(workspace.Map:GetDescendants()) do
            if item:IsA("Tool") or (item:IsA("Model") and item.Name == "Medkit") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ItemESP"
                highlight.Adornee = item
                highlight.FillColor = Color3.fromRGB(0, 200, 255)
                highlight.OutlineTransparency = 1
                highlight.Parent = item
            end
        end
    end
end

local function createKillerESP()
    clearESP("KillerESP")
    
    if workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers") then
        for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
            if killer:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "KillerESP"
                highlight.Adornee = killer
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineTransparency = 0
                highlight.FillTransparency = 0.2
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = killer
            end
        end
    end
    
    -- Setup connection for new killers
    if _G.espConnections["KillerESP"] then
        _G.espConnections["KillerESP"]:Disconnect()
    end
    
    _G.espConnections["KillerESP"] = workspace.Players.Killers.ChildAdded:Connect(function(killer)
        if _G.killerESPEnabled and killer:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "KillerESP"
            highlight.Adornee = killer
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineTransparency = 0
            highlight.FillTransparency = 0.2
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = killer
        end
    end)
end

local function CopyDiscordInvite()
    setclipboard("https://discord.gg/yourinvitecode")
    WindUI:Notify({
        Title = "Discord Invite Copied!",
        Content = "Paste it in your browser to join",
        Duration = 3,
        Icon = "clipboard"
    })
end

-- Character setup
Players.LocalPlayer.CharacterAdded:Connect(function(character)
    currentCharacter = character
end)

local Window = WindUI:CreateWindow({
    Title = "Tuff Guys | Forsaken V1",
    Icon = "rbxassetid://130506306640152",
    IconThemed = true,
    Author = "Tuff Agsy",
    Folder = "ForsakenTuff",
    Size = UDim2.fromOffset(580, 380),
    Transparent = true,
    Theme = "Black",
    SideBarWidth = 200,
})

Window:SetBackgroundImage("rbxassetid://130506306640152")
Window:SetBackgroundImageTransparency(0.8)
Window:DisableTopbarButtons({"Fullscreen"})

Window:EditOpenButton({
    Title = "Tuff Guys | Forsaken V1",
    Icon = "slice",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),   -- Green
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) -- White
}),
    Enabled = true,
    Draggable = true,
})


local function CopyDiscordInvite()
    setclipboard("https://discord.gg/tuffguys")
end

local Tabs = {
    discordTab = Window:Tab({ Title = "Important", Icon = "bell" }),
    MainTab = Window:Tab({ Title = "Main", Icon = "house" }),
    KillerTab = Window:Tab({ Title = "Killer", Icon = "skull" }),
    VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
}

-- Discord Tab
Tabs.discordTab:Paragraph({
    Title = "Join Discord To Know Updates!",
    Desc = "Stay updated with the latest features and fixes",
    Image = "rbxassetid://130506306640152",
    Thumbnail = "rbxassetid://130506306640152",
    Buttons = {
        {
            Title = "Copy Invite",
            Icon = "clipboard",
            Callback = CopyDiscordInvite,
            Variant = "Primary"
        },
        {
            Title = "Visit YouTube",
            Icon = "youtube",
            Callback = function() 
                setclipboard("https://www.youtube.com/@incrediblebread")
            end,
            Variant = "Secondary"
        }
    }
})

-- Main Tab
Tabs.MainTab:Toggle({
    Title = "Inf Stamina",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        toggleStaminaHack(state)
    end
})

-- Main Tab
Tabs.MainTab:Toggle({
    Title = "Auto Generator Repair",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.autoRun = state
        if state then
            task.spawn(function()
                while _G.autoRun do
                    repairGenerators()
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.MainTab:Toggle({
    Title = "Killer Avoidance",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while _G.autoRun do
                    if killerNearby() then
                        runAway()
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Killer Tab
local playerDropdown = Tabs.KillerTab:Dropdown({
    Title = "Select Player",
    Values = {},
    Value = "",
    Callback = function(selected)
        _G.selectedPlayer = selected
    end
})

-- Function to update player list
local function updatePlayerList()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localplayer then
            table.insert(players, player.Name)
        end
    end
    playerDropdown:Refresh(players)
end

-- Initial update and set up listener
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

Tabs.KillerTab:Button({
    Title = "Instant Kill",
    Callback = function()
        if _G.selectedPlayer then
            local target = Players:FindFirstChild(_G.selectedPlayer)
            if target then
                instantKill(target)
            end
        else
            WindUI:Notify({
                Title = "Error",
                Content = "No player selected!",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end,
    Icon = "zap"
})

Tabs.KillerTab:Toggle({
    Title = "Kill Aura",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            _G.killAuraConnection = createKillAura()
        else
            if _G.killAuraConnection then
                _G.killAuraConnection:Disconnect()
                _G.killAuraConnection = nil
            end
        end
    end,
    Icon = "circle"
})

-- Visuals Tab
Tabs.VisualsTab:Toggle({
    Title = "Player ESP",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.playerESPEnabled = state
        if state then
            createPlayerESP()
        else
            clearESP("PlayerESP")
            if _G.espConnections["PlayerESP"] then
                _G.espConnections["PlayerESP"]:Disconnect()
            end
        end
    end,
    Icon = "user"
})

Tabs.VisualsTab:Toggle({
    Title = "Generator ESP",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            createGeneratorESP()
        else
            clearESP("GeneratorESP")
        end
    end,
    Icon = "zap"
})

Tabs.VisualsTab:Toggle({
    Title = "Item ESP",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            createItemESP()
        else
            clearESP("ItemESP")
        end
    end,
    Icon = "package"
})

Tabs.VisualsTab:Toggle({
    Title = "Killer ESP",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.killerESPEnabled = state
        if state then
            createKillerESP()
        else
            clearESP("KillerESP")
            if _G.espConnections["KillerESP"] then
                _G.espConnections["KillerESP"]:Disconnect()
            end
        end
    end,
    Icon = "skull"
})