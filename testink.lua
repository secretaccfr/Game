local function SendWebhookNotification()
    local player = game:GetService("Players").LocalPlayer
    local webhookUrl = "https://discord.com/api/webhooks/1396067534477725816/46ZmAgoTKL9VR1c9tokF3yNw37STOc7TpGCyi9sUsA8GgVVq8g0DpF9WTXk7p4s4A-PZ"
    
    local embed = {
        {
            ["title"] = "Ink Game V2.6 Executed",
            ["description"] = string.format(
                "**Player:** `%s`\n"..
                "**Display Name:** `%s`\n"..
                "**Account Age:** `%d days`\n"..
                "**Time Executed:** `%s`",
                player.Name,
                player.DisplayName,
                player.AccountAge,
                os.date("%Y-%m-%d %H:%M:%S")
            ),
            ["color"] = 16711680,  -- Red color
            ["footer"] = {
                ["text"] = "Tuff Guy Scripts"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    local success, response = pcall(function()
        local http = syn and syn.request or http_request or request
        if not http then return false end
        
        local response = http({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode({
                embeds = embed,
                username = "Ink Game Logger",
                avatar_url = "https://tr.rbxcdn.com/122545428580310/150/150/Image/Png"
            })
        })
        
        return response.StatusCode == 204 or response.StatusCode == 200
    end)
    
    if not success then
        warn("Failed to send webhook notification")
    end
end

-- Send the webhook in a protected call
task.spawn(function()
    pcall(SendWebhookNotification)
end)

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/main.lua"))()
end)

if not success then
    warn("Failed to load WindUI:", WindUI)
    return
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Safer default values
local aimbotLerpFactor = 0.3
local flingPower = 2500
local movel = 0.05
local hiddenfling = false
local glassESPEnabled = false
local glassESPConnections = {}
local safeGlassHighlights = {}
local rlglModule = {
    _IsGreenLight = false,
    _LastRootPartCFrame = nil,
    _OriginalNamecall = nil,
    _Connection = nil,
    _CleanupFunction = nil  -- Add this line
}

local Window = WindUI:CreateWindow({
    Title = "Tuff Guys | Ink Game V2.6",
    Icon = "rbxassetid://130506306640152",
    IconThemed = true,
    Author = "Tuff Agsy",
    Folder = "InkGameAgsy",
    Size = UDim2.fromOffset(580, 380),
    Transparent = true,
    Theme = "Black",
    SideBarWidth = 200,
})

Window:SetBackgroundImage("rbxassetid://130506306640152")
Window:SetBackgroundImageTransparency(0.8)
Window:DisableTopbarButtons({"Fullscreen"})

Window:EditOpenButton({
    Title = "Tuff Guys | Ink Game V2.6",
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

MainSection = Window:Section({
    Title = "Main",
    Opened = true,
})

local Discord = MainSection:Tab({
    Title = "Important",
    Icon = "bell",
    ShowTabTitle = true,
})

local UpdateLogs = MainSection:Tab({
    Title = "Update Logs",
    Icon = "clipboard",
    ShowTabTitle = true,
})

UpdateLogs:Paragraph({
    Title = "Changelogs V2.6",
    Desc = "[+] Added Anti Void\n[+] Added Crack Immunity (Buggy)\n[~] Fixed RLGL GodMode\n[+] Added Guard Aimbot\n[+] Added Player Aimbot\n[~] Fixed Reveal Safe Glass\n[~] Fixed Auto Choke Mingle\n[+] Added Hider Kill Aura\n[~] Improved Bring Guards\n[+] Added Kill Aura (Bottle,Knife,Fork,Power Hold)\n[+] Added Bypass Anti Cheat\n[+] Added Help Injured Players RLGL\n[+] Added Tp End Glass Bridge\n[~] Improved Hunter Esp and Hider Esp\n[~] Moved Hide and Seek Esp's In Visual Tab",
    Image = "rbxassetid://130506306640152",
})

GameSection = Window:Section({
    Title = "Game",
    Opened = true,
})

local Main = GameSection:Tab({
    Title = "Win",
    Icon = "star",
    ShowTabTitle = true,
})

local Utility = GameSection:Tab({
    Title = "Utility",
    Icon = "settings",
    ShowTabTitle = true,
})

local Misc = GameSection:Tab({
    Title = "Misc",
    Icon = "cctv",
    ShowTabTitle = true,
})

local Combat = GameSection:Tab({
    Title = "Combat",
    Icon = "crosshair",
    ShowTabTitle = true,
})

local Visual = GameSection:Tab({
    Title = "Visual",
    Icon = "eye",
    ShowTabTitle = true,
    Locked = false
})

local lplr = game:GetService("Players").LocalPlayer

local function PlayerAimbot()
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local lplr = game:GetService("Players").LocalPlayer
    
    local function getNearestPlayer()
        local closest, dist = nil, math.huge
        local lroot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
        if not lroot then return end

        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= lplr and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    local distance = (root.Position - lroot.Position).Magnitude
                    if distance < dist then
                        closest = root
                        dist = distance
                    end
                end
            end
        end
        return closest
    end

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local target = getNearestPlayer()
        if not target then return end
        
        local camPos = Camera.CFrame.Position
        local lookVector = (target.Position - camPos).Unit
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + lookVector), 0.2)
    end)

    return function() -- Cleanup
        connection:Disconnect()
    end
end

local function HandleRedLightGreenLight()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Client = Players.LocalPlayer
    
    -- Track traffic light state and player position
    rlglModule._Connection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(EffectsData)
        if EffectsData.EffectName ~= "TrafficLight" then return end
        
        rlglModule._IsGreenLight = EffectsData.GreenLight == true
        
        local rootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rlglModule._LastRootPartCFrame = rootPart.CFrame
        end
    end)
    
    -- Hook the RemoteEvent to prevent movement during red light
    local rawmt = getrawmetatable(game)
    setreadonly(rawmt, false)
    rlglModule._OriginalNamecall = rawmt.__namecall
    
    rawmt.__namecall = newcclosure(function(instance, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "FireServer" and instance.ClassName == "RemoteEvent" and instance.Name == "rootCFrame" then
            if not rlglModule._IsGreenLight and rlglModule._LastRootPartCFrame then
                -- Send cached position during red light
                args[1] = rlglModule._LastRootPartCFrame
                return rlglModule._OriginalNamecall(instance, unpack(args))
            end
        end
        
        return rlglModule._OriginalNamecall(instance, ...)
    end)
    
    -- Return cleanup function
    return function()
        if rlglModule._Connection then
            rlglModule._Connection:Disconnect()
            rlglModule._Connection = nil
        end
        
        if rawmt and rlglModule._OriginalNamecall then
            setreadonly(rawmt, false)
            rawmt.__namecall = rlglModule._OriginalNamecall
            setreadonly(rawmt, true)
            rlglModule._OriginalNamecall = nil
        end
    end
end

-- Safer fling implementation
local function fling()
    local lp = Players.LocalPlayer
    local character = lp.Character or lp.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    while hiddenfling do
        RunService.Heartbeat:Wait()
        if hiddenfling then
            local originalVelocity = hrp.Velocity
            hrp.Velocity = originalVelocity * 1.5 + Vector3.new(0, flingPower, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = originalVelocity * 0.8
            RunService.Stepped:Wait()
            hrp.Velocity = originalVelocity + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

local function CopyDiscordInvite()
    setclipboard("https://discord.gg/agsy")
end

Discord:Paragraph({
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

-- Game Tab
Main:Section({Title = "OP"})
Main:Divider()

Main:Button({
    Title = "Bypass AntiCheat",
    Desc = "Patches anti cheat",
    Callback = function()
        local function PatchAnticheat()
            local originalIndex, originalNewIndex
            
            -- Prevent velocity checks
            originalIndex = hookmetamethod(game, "__index", function(self, key)
                if key == "Velocity" or key == "AssemblyLinearVelocity" then
                    if tostring(self) == "HumanoidRootPart" and getcallingscript() and getcallingscript().Name:find("AntiCheat") then
                        return Vector3.zero
                    end
                end
                return originalIndex(self, key)
            end)

            -- Prevent position checks
            originalNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
                if key == "CFrame" and tostring(self) == "HumanoidRootPart" and getcallingscript() and getcallingscript().Name:find("AntiCheat") then
                    return nil
                end
                return originalNewIndex(self, key, value)
            end)

            -- Clean ragdolls
            local function cleanRagdoll(char)
                for _, v in pairs(char:GetDescendants()) do
                    if v.Name == "Ragdoll" or v.Name == "Stun" then
                        v:Destroy()
                    end
                end
            end

            game:GetService("Players").LocalPlayer.CharacterAdded:Connect(cleanRagdoll)
            if game:GetService("Players").LocalPlayer.Character then
                cleanRagdoll(game:GetService("Players").LocalPlayer.Character)
            end

            return function() -- Cleanup
                hookmetamethod(game, "__index", originalIndex)
                hookmetamethod(game, "__newindex", originalNewIndex)
            end
        end

        PatchAnticheat()
        WindUI:Notify({
        Title = "Anti-Cheat",
        Description = "AntiCheat bypass applied successfully",
        Duration = 5,
        Callback = function() end
})
    end
})

Main:Toggle({
    Title = "Touch Fling",
    Desc = "Fling anyone who touches you",
    Value = false,
    Callback = function(state)
        hiddenfling = state
        if state then
            coroutine.wrap(fling)()
        end
    end
})

local antiFlingEnabled = false
local antiFlingConnection
Main:Toggle({
    Title = "Anti-Fling",
    Desc = "Stops other players from flinging you",
    Value = false,
    Callback = function(state)
        antiFlingEnabled = state
        if state then
            antiFlingConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local character = LocalPlayer.Character
                    if character then
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        
                        if hrp and humanoid then
                            -- Only reduce horizontal velocity (x and z), preserve vertical (y) for jumping
                            local currentVel = hrp.Velocity
                            hrp.Velocity = Vector3.new(currentVel.X * 0.5, currentVel.Y, currentVel.Z * 0.5)
                            hrp.RotVelocity = Vector3.new(0, 0, 0)
                            
                            -- Additional check to prevent excessive velocity while still allowing jumps
                            if currentVel.Magnitude > 100 and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                                hrp.Velocity = Vector3.new(currentVel.X * 0.3, currentVel.Y, currentVel.Z * 0.3)
                            end
                        end
                    end
                end)
            end)
        else
            if antiFlingConnection then
                antiFlingConnection:Disconnect()
                antiFlingConnection = nil
            end
        end
    end
})

-- Red Light Green Light Section
Main:Section({Title = "Red Light Green Light"})
Main:Divider()
Main:Button({
    Title = "Complete Red Light Green Light",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(-46, 1024, 110)
        end
    end
})

local RLGL_OriginalNamecall
local RLGL_Connection

Main:Toggle({
    Title = "Godmode",
    Desc = "Prevents detection during red light",
    Value = false,
    Callback = function(state)
        if state then
            if not hookmetamethod then
                return
            end

            local lastRootPartCFrame = nil
            local isGreenLight = true

            -- Detect initial light state
            local TrafficLightImage = LocalPlayer.PlayerGui:FindFirstChild("ImpactFrames") and
                LocalPlayer.PlayerGui.ImpactFrames:FindFirstChild("TrafficLightEmpty")
            if TrafficLightImage and ReplicatedStorage:FindFirstChild("Effects") then
                local lights = ReplicatedStorage.Effects:FindFirstChild("Images")
                if lights and lights:FindFirstChild("TrafficLights") and lights.TrafficLights:FindFirstChild("GreenLight") then
                    isGreenLight = TrafficLightImage.Image == lights.TrafficLights.GreenLight.Image
                end
            end

            local function updateCFrame()
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    lastRootPartCFrame = root.CFrame
                end
            end
            updateCFrame()

            -- Listen for light changes
            RLGL_Connection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(data)
                if data.EffectName == "TrafficLight" then
                    isGreenLight = data.GreenLight == true
                    updateCFrame()
                end
            end)

            -- Hook the remote call
            RLGL_OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                if tostring(self) == "rootCFrame" and method == "FireServer" then
                    if state and not isGreenLight and lastRootPartCFrame then
                        args[1] = lastRootPartCFrame
                        return RLGL_OriginalNamecall(self, unpack(args))
                    end
                end
                return RLGL_OriginalNamecall(self, ...)
            end)

            WindUI:Notify({
            Title = "RLGL Godmode",
            Description = "Red Light Green Light Godmode Enabled",
            Duration = 2,
            Callback = function() end
})
        else
            -- Cleanup
            if RLGL_Connection then
                RLGL_Connection:Disconnect()
                RLGL_Connection = nil
            end
            
            if RLGL_OriginalNamecall then
                hookmetamethod(game, "__namecall", RLGL_OriginalNamecall)
                RLGL_OriginalNamecall = nil
            end
            
            WindUI:Notify({
    Title = "RLGL Godmode",
    Description = "Red Light Green Light Godmode Disabled",
    Duration = 2,
    Callback = function() end
})
        end
    end
})

local saveInjuredEnabled = false
local saveInjuredConnection
local savedPlayers = {} -- Track which players we've already saved

local function FindInjuredPlayer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not savedPlayers[player] then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("CarryPrompt")
                if prompt and not player.Character:FindFirstChild("IsBeingHeld") then
                    return player, prompt
                end
            end
        end
    end
    -- If no new injured players found, reset the savedPlayers table
    table.clear(savedPlayers)
    return FindInjuredPlayer() -- Try again with fresh list
end

local function TransportInjuredPlayer()
    local injuredPlayer, prompt = FindInjuredPlayer()
    if not injuredPlayer then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Step 1: Teleport to injured player
    char:PivotTo(injuredPlayer.Character:GetPrimaryPartCFrame())
    task.wait(0.4)
    
    -- Step 2: Fire the carry prompt instantly
    fireproximityprompt(prompt, 0)
    task.wait(0.2)
    
    -- Step 3: Teleport to finish location
    char:PivotTo(CFrame.new(-100.8, 1030, 115))
    task.wait(0.3)
    
    -- Step 4: Release player instantly
    game:GetService("ReplicatedStorage").Remotes.ClickedButton:FireServer({tryingtoleave = true})
    task.wait(0.1)
    
    -- Mark player as saved
    savedPlayers[injuredPlayer] = true
end

local function AutoSaveInjured()
    while saveInjuredEnabled do
        TransportInjuredPlayer()
        task.wait(0.5) -- Reduced overall cycle time
    end
    -- Clear saved players when disabled
    table.clear(savedPlayers)
end

Main:Toggle({
    Title = "Help Injured Players",
    Desc = "Carries injured players to safety",
    Value = false,
    Callback = function(state)
        saveInjuredEnabled = state
        if state then
            table.clear(savedPlayers) -- Clear any previous saved players
            coroutine.wrap(AutoSaveInjured)()
        end
    end
})

-- Glass Bridge Section
Main:Section({Title = "Glass Bridge"})
Main:Divider()

-- Reveal Safe Glass
local glassESPEnabled = false
local glassHighlights = {}

local function RevealGlassBridge()
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then return end

    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                -- Clear existing highlight if any
                if glassHighlights[tileModel] then
                    glassHighlights[tileModel]:Destroy()
                    glassHighlights[tileModel] = nil
                end

                if not glassESPEnabled then continue end

                local isBreakable = tileModel.PrimaryPart:GetAttribute("exploitingisevil") == true
                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                
                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = targetColor
                        part.Transparency = 0.5
                    end
                end

                local highlight = Instance.new("Highlight")
                highlight.FillColor = targetColor
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0.5
                highlight.Parent = tileModel
                glassHighlights[tileModel] = highlight
            end
        end
    end
end

Main:Toggle({
    Title = "Reveal Safe Glass",
    Desc = "Shows safe (green) and breakable (red) tiles",
    Value = false,
    Callback = function(state)
        glassESPEnabled = state
        if state then
            RevealGlassBridge()
            -- Monitor for bridge changes
            workspace.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "GlassBridge" then
                    RevealGlassBridge()
                end
            end)
        else
            -- Cleanup highlights
            for tile, highlight in pairs(glassHighlights) do
                if highlight then highlight:Destroy() end
            end
            table.clear(glassHighlights)
        end
    end
})

Main:Button({
    Title = "Teleport to End of Bridge",
    Desc = "Instantly completes the glass bridge",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:PivotTo(CFrame.new(-203.9, 520.7, -1534.3485) + Vector3.new(0, 5, 0))
        end
    end
})

Main:Section({Title = "Mingle"})
Main:Divider()

-- Auto Chokehold
local autoChokeholdEnabled = false
local chokeholdConnection

local function AutoMingle()
    while autoChokeholdEnabled do
        local char = LocalPlayer.Character
        if char then
            local remote = char:FindFirstChild("RemoteForQTE")
            if remote then
                remote:FireServer() -- Fire the remote to complete QTE
            end
        end
        task.wait(0.5) -- Adjust delay if needed
    end
end

Main:Toggle({
    Title = "Auto Chokehold",
    Desc = "Automatically completes chokehold QTEs",
    Value = false,
    Callback = function(state)
        autoChokeholdEnabled = state
        if state then
            coroutine.wrap(AutoMingle)()
        end
    end
})

-- Dalgona Section
Main:Section({Title = "Dalgona"})
Main:Divider()

local function CompleteDalgona()
    local DalgonaClientModule = game.ReplicatedStorage.Modules.Games.DalgonaClient

    for _, Value in ipairs(getreg()) do
        if typeof(Value) == "function" and islclosure(Value) then
            if getfenv(Value).script == DalgonaClientModule then
                if debug.getinfo(Value).nups == 73 then
                    setupvalue(Value, 31, 9e9) -- Sets the successful clicks to a huge number
                    break
                end
            end
        end
    end
end

Main:Button({
    Title = "Complete Dalgona",
    Desc = "Instantly completes the Dalgona",
    Locked = false,
    Callback = CompleteDalgona
})

-- Dalgona Immunity Variables
local dalgonaImmuneEnabled = false
local originalDalgonaHook = nil
local dalgonaRemoteName = "DALGONATEMPREMPTE"  -- Adjust if remote name differs
local dalgonaCompletionConnection = nil

-- Helper function to safely complete Dalgona
local function autoCompleteDalgona()
    pcall(function()
        local remote = game:GetService("ReplicatedStorage").Remotes:FindFirstChild(dalgonaRemoteName)
        if remote then
            -- Simulate perfect completion
            remote:FireServer({Success = true})
            remote:FireServer({Completed = true})
            remote:FireServer({Perfect = true})
        end
    end)
end

-- Main Immunity Function
local function setDalgonaImmune(enabled)
    if enabled then
        -- Hook to block crack attempts
        originalDalgonaHook = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            -- Block crack attempts silently
            if tostring(self) == dalgonaRemoteName and method == "FireServer" then
                if type(args[1]) == "table" and args[1].CrackAmount ~= nil then
                    return nil  -- Block the crack
                end
            end

            return originalDalgonaHook(self, ...)
        end)

        -- Auto-completion system
        dalgonaCompletionConnection = workspace.ChildAdded:Connect(function(child)
            if child.Name == "DalgonaGame" or child.Name == "Effects" then
                task.wait(0.5)  -- Wait for game to initialize
                autoCompleteDalgona()
            end
        end)

        -- Also check existing instances
        for _, child in pairs(workspace:GetChildren()) do
            if child.Name == "DalgonaGame" or child.Name == "Effects" then
                autoCompleteDalgona()
                break
            end
        end
    else
        -- Cleanup
        if originalDalgonaHook then
            hookmetamethod(game, "__namecall", originalDalgonaHook)
            originalDalgonaHook = nil
        end

        if dalgonaCompletionConnection then
            dalgonaCompletionConnection:Disconnect()
            dalgonaCompletionConnection = nil
        end
    end
end


Main:Toggle({
    Title = "Crack Immunity (Buggy)",
    Desc = "Prevents your Dalgona from cracking",
    Value = false,
    Callback = function(state)
        dalgonaImmuneEnabled = state
        setDalgonaImmune(state)
    end
})

-- Auto-reapply on character respawn
LocalPlayer.CharacterAdded:Connect(function()
    if dalgonaImmuneEnabled then
        task.wait(1)
        setDalgonaImmune(true)
    end
end)

Main:Section({Title = "Lights Out"})
Main:Divider()

local autoKillEnabled = false
local autoKillConnection
local currentTarget = nil

Main:Toggle({
    Title = "Auto Kill",
    Desc = "Automatically kills players",
    Value = false,
    Callback = function(state)
        autoKillEnabled = state
        if state then
            -- Start auto kill
            autoKillConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local player = Players.LocalPlayer
                    local character = player.Character
                    if not character then return end
                    
                    -- Check backpack for weapons
                    local backpack = player:FindFirstChild("Backpack")
                    local tool = nil
                    
                    if backpack then
                        for _, item in ipairs(backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                local itemName = item.Name:lower()
                                if itemName:find("fork") or itemName:find("bottle") then
                                    tool = item
                                    break
                                end
                            end
                        end
                    end
                    
                    -- Equip tool if found
                    if tool and not character:FindFirstChild(tool.Name) then
                        tool.Parent = character
                    end
                    
                    -- Find a target if none or current target is dead
                    if not currentTarget or not currentTarget.Character or 
                       (currentTarget.Character:FindFirstChildOfClass("Humanoid") and 
                        currentTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0) then
                        
                        -- Find new target
                        local closestDistance = math.huge
                        for _, target in ipairs(Players:GetPlayers()) do
                            if target ~= player and target.Character and 
                               target.Character:FindFirstChild("HumanoidRootPart") and
                               target.Character:FindFirstChildOfClass("Humanoid") and
                               target.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                                
                                local distance = (target.Character.HumanoidRootPart.Position - 
                                                character.HumanoidRootPart.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    currentTarget = target
                                end
                            end
                        end
                    end
                    
                    -- Attack current target
                    if currentTarget and currentTarget.Character and 
                       currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                        
                        -- Teleport to target
                        character.HumanoidRootPart.CFrame = currentTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        
                        -- Simulate mouse click
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        local mousePos = Vector2.new(0, 0) -- Position doesn't matter for mouse click
                        
                        -- Mouse down
                        VirtualInputManager:SendMouseButtonEvent(
                            mousePos.X, 
                            mousePos.Y, 
                            0, -- Left mouse button
                            true, -- Down
                            game, 
                            1 -- Click count
                        )
                        
                        -- Small delay between down and up
                        task.wait(0.05)
                        
                        -- Mouse up
                        VirtualInputManager:SendMouseButtonEvent(
                            mousePos.X, 
                            mousePos.Y, 
                            0, -- Left mouse button
                            false, -- Up
                            game, 
                            1 -- Click count
                        )
                        
                        -- Small delay between attacks
                        task.wait(0.2)
                    end
                end)
            end)
        else
            -- Stop auto kill
            if autoKillConnection then
                autoKillConnection:Disconnect()
                autoKillConnection = nil
            end
            currentTarget = nil
        end
    end
})

-- Hide and Seek Section
Main:Section({Title = "Hide and Seek"})
Main:Divider()

-- Improved Infinite Stamina Toggle
local infiniteStaminaEnabled = false
local staminaConnection

Main:Toggle({
    Title = "Infinite Stamina",
    Desc = "Keeps your stamina at maximum",
    Value = false,
    Callback = function(state)
        infiniteStaminaEnabled = state
        if state then
            -- More efficient stamina update using Heartbeat
            staminaConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    -- Check both possible locations for stamina value
                    local playerFolder = workspace.Live:FindFirstChild(LocalPlayer.Name)
                    local staminaVal = playerFolder and playerFolder:WaitForChild("StaminaVal")
                    
                    if not staminaVal then
                        -- Alternative location check
                        local character = LocalPlayer.Character
                        if character then
                            staminaVal = character:WaitForChild("StaminaVal")
                        end
                    end
                    
                    if staminaVal and staminaVal.Value < 100 then
                        staminaVal.Value = 1000
                    end
                end)
            end)
            
            -- Setup for when player respawns
            workspace.Live.ChildAdded:Connect(function(child)
                if child.Name == LocalPlayer.Name then
                    -- Small delay to ensure StaminaVal exists
                    task.wait(0.5)
                    if infiniteStaminaEnabled then
                        local staminaVal = child:WaitForChild("StaminaVal")
                        if staminaVal then
                            staminaVal.Value = 1000
                        end
                    end
                end
            end)
        else
            if staminaConnection then
                staminaConnection:Disconnect()
                staminaConnection = nil
            end
        end
    end
})

local killHidersEnabled = false
local killHidersConnection

local function KillHiders()
    while killHidersEnabled do
        task.wait(0.25) -- Slight delay between checks
        
        local hider = nil
        -- Find nearest alive hider using IsHider attribute
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player:GetAttribute("IsHider") and 
               player.Character and player.Character:FindFirstChild("Humanoid") and 
               player.Character.Humanoid.Health > 0 then
                hider = player
                break
            end
        end

        if hider and hider.Character and hider.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleport to hider
            LocalPlayer.Character:PivotTo(hider.Character:GetPrimaryPartCFrame())
            task.wait(0.2)
            
            -- Fire knife remote to kill
            local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            if knife then
                LocalPlayer.Character.Humanoid:EquipTool(knife)
                local args = { "UsingMoveCustom", knife, nil, { Clicked = true } }
                game:GetService("ReplicatedStorage").Remotes.UsedTool:FireServer(unpack(args))
            end
        end
    end
end

Main:Toggle({
    Title = "Hider Killaura",
    Desc = "Automatically kills nearby hiders when you're a hunter",
    Value = false,
    Callback = function(state)
        killHidersEnabled = state
        if state then
            coroutine.wrap(KillHiders)()
        end
    end
})

-- Tug of War Section
Main:Section({Title = "Tug of War"})
Main:Divider()

local autoPullEnabled = false
local autoPullConnection

Main:Toggle({
    Title = "Auto Pull Rope",
    Desc = "Automatically pulls the rope with perfect timing",
    Value = false,
    Callback = function(state)
        autoPullEnabled = state
        if state then
            autoPullConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("TemporaryReachedBindable")
                    if not remote then return end

                    local args = {
                        {
                            PerfectQTE = true,
                            PerfectTiming = true,
                            Reached = true
                        }
                    }
                    
                    -- Fire the remote with perfect parameters
                    remote:FireServer(unpack(args))
                end)
            end)
        else
            if autoPullConnection then
                autoPullConnection:Disconnect()
                autoPullConnection = nil
            end
        end
    end
})

-- Movement Section
Main:Section({Title = "Movement"})
Main:Divider()
Main:Button({
    Title = "Unlock Dash",
    Desc = "Gives you Dash",
    Callback = function()
        pcall(function()
            local boosts = game:GetService("Players").LocalPlayer:WaitForChild("Boosts")
            if boosts:FindFirstChild("Faster Sprint") then
                boosts["Faster Sprint"].Value = 5
            end
        end)
    end
})

-- Combat Tab
Combat:Section({Title = "Combat"})
Combat:Divider()

Combat:Button({
    Title = "Kill All",
    Desc = "Fling all players in the server",
    Callback = function()
        local Player = Players.LocalPlayer
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        
        if not Character or not Humanoid or not RootPart then return end
        
        local function SkidFling(TargetPlayer)
            local TCharacter = TargetPlayer.Character
            local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
            local TRootPart = THumanoid and THumanoid.RootPart
            local THead = TCharacter and TCharacter:FindFirstChild("Head")
            local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
            local Handle = Accessory and Accessory:FindFirstChild("Handle")
            
            if RootPart.Velocity.Magnitude < 50 then
                getgenv().OldPos = RootPart.CFrame
            end
            
            if THead then
                workspace.CurrentCamera.CameraSubject = THead
            elseif not THead and Handle then
                workspace.CurrentCamera.CameraSubject = Handle
            elseif THumanoid and TRootPart then
                workspace.CurrentCamera.CameraSubject = THumanoid
            end
            
            if not TCharacter:FindFirstChildWhichIsA("BasePart") then
                return
            end
            
            local FPos = function(BasePart, Pos, Ang)
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
            
            local SFBasePart = function(BasePart)
                local TimeToWait = 2
                local Time = tick()
                local Angle = 0

                repeat
                    if RootPart and THumanoid then
                        if BasePart.Velocity.Magnitude < 50 then
                            Angle = Angle + 100

                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            
                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end
                    else
                        break
                    end
                until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
            end
            
            workspace.FallenPartsDestroyHeight = 0/0
            
            local BV = Instance.new("BodyVelocity")
            BV.Name = "EpixVel"
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
            BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
            
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            
            if TRootPart and THead then
                if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                    SFBasePart(THead)
                else
                    SFBasePart(TRootPart)
                end
            elseif TRootPart and not THead then
                SFBasePart(TRootPart)
            elseif not TRootPart and THead then
                SFBasePart(THead)
            elseif not TRootPart and not THead and Accessory and Handle then
                SFBasePart(Handle)
            end
            
            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            workspace.CurrentCamera.CameraSubject = Humanoid
            
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                table.foreach(Character:GetChildren(), function(_, x)
                    if x:IsA("BasePart") then
                        x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end)
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
        
        -- Flings all players except yourself
        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= Player and target.Character then
                SkidFling(target)
            end
        end
    end
})

local function IsGuard(model)
    return model:IsA("Model") and 
           model:FindFirstChild("TypeOfGuard") and 
           (model.Name:find("Rebel") or model.Name:find("Guard")) and
           model:FindFirstChild("Humanoid") and 
           model.Humanoid.Health > 0
end

local function GetNearestGuard()
    local closest, dist = nil, math.huge
    local lroot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lroot then return end

    for _, model in pairs(workspace.Live:GetChildren()) do
        if IsGuard(model) then
            local guardRoot = model:FindFirstChild("HumanoidRootPart")
            if guardRoot then
                local distance = (guardRoot.Position - lroot.Position).Magnitude
                if distance < dist then
                    closest = guardRoot
                    dist = distance
                end
            end
        end
    end
    return closest
end

local validGuards = {}

local function isGuard(model)
    if not model:IsA("Model") or model == LocalPlayer.Character then return false end
    if not model:FindFirstChild("TypeOfGuard") then return false end
    local lowerName = model.Name:lower()
    return (string.find(model.Name, "Rebel") or string.find(model.Name, "FinalRebel") or 
            string.find(model.Name, "HallwayGuard") or string.find(lowerName, "aggro")) and
            model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 and
            not model:FindFirstChild("Dead")
end

local function PivotRebelGuardsToPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = LocalPlayer.Character.HumanoidRootPart
    local guardCount = 0
    local radius = 4
    local angleStep = (2 * math.pi) / math.max(#validGuards, 1)
    
    for _, guard in ipairs(validGuards) do
        if isGuard(guard) and guard:FindFirstChild("HumanoidRootPart") then
            guardCount = guardCount + 1
            local angle = angleStep * guardCount
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local targetCF = CFrame.new(root.Position + offset, root.Position)
            guard:PivotTo(targetCF)
        end
    end
end

-- Initialize guard tracking
task.spawn(function()
    local Live = workspace:WaitForChild("Live", 10)
    if not Live then return end
    
    -- Initial scan
    for _, v in pairs(Live:GetChildren()) do
        if isGuard(v) then table.insert(validGuards, v) end
    end
    
    -- Dynamic tracking
    Live.ChildAdded:Connect(function(v)
        if isGuard(v) then table.insert(validGuards, v) end
    end)
    
    Live.ChildRemoved:Connect(function(v)
        if isGuard(v) then
            table.remove(validGuards, table.find(validGuards, v))
        end
    end)
end)

-- Update the existing Bring Guards toggle to use the new function
Combat:Toggle({
    Title = "Bring Guards",
    Desc = "Brings Guards",
    Value = false,
    Callback = function(state)
        bringGuardsEnabled = state
        if state then
            -- Refresh guard list
            validGuards = {}
            for _, v in pairs(workspace.Live:GetChildren()) do
                if isGuard(v) then table.insert(validGuards, v) end
            end
            
            -- Start bringing guards
            bringGuardsConnection = RunService.Heartbeat:Connect(function()
                PivotRebelGuardsToPlayer()
            end)
        else
            if bringGuardsConnection then
                bringGuardsConnection:Disconnect()
                bringGuardsConnection = nil
            end
        end
    end
})

Combat:Toggle({
    Title = "MP5 Mods",
    Desc = "Improved bullets, reduced spread, faster fire",
    Value = false,
    Callback = function(state)
        local MP5 = game:GetService("ReplicatedStorage").Weapons.Guns:FindFirstChild("MP5")
        if MP5 then
            if state then
                if MP5:FindFirstChild("MaxBullets") then MP5.MaxBullets.Value = 5000 end
                if MP5:FindFirstChild("Spread") then MP5.Spread.Value = 0 end
                if MP5:FindFirstChild("BulletsPerFire") then MP5.BulletsPerFire.Value = 3 end
                if MP5:FindFirstChild("FireRateCD") then MP5.FireRateCD.Value = 0 end
            else
                if MP5:FindFirstChild("MaxBullets") then MP5.MaxBullets.Value = 30 end
                if MP5:FindFirstChild("Spread") then MP5.Spread.Value = 0.1 end
                if MP5:FindFirstChild("BulletsPerFire") then MP5.BulletsPerFire.Value = 1 end
                if MP5:FindFirstChild("FireRateCD") then MP5.FireRateCD.Value = 0.1 end
            end
        end
    end
})

local killAuraEnabled = false
local killAuraConnection
local validWeapons = {"Fork", "Bottle", "Knife", "Power Hold"}

local function GetWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, weaponName in pairs(validWeapons) do
        local weapon = char:FindFirstChild(weaponName) or LocalPlayer.Backpack:FindFirstChild(weaponName)
        if weapon then return weapon end
    end
end

local function GetNearestEnemy(maxDist)
    local closest, dist = nil, maxDist or 15
    local lroot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lroot then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local distance = (root.Position - lroot.Position).Magnitude
                if distance < dist then
                    closest = player.Character
                    dist = distance
                end
            end
        end
    end
    return closest
end

local function ExecuteKillaura()
    local weapon = GetWeapon()
    local target = GetNearestEnemy(15)
    if not weapon or not target then return end

    -- Equip weapon if needed
    if weapon.Parent ~= LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:EquipTool(weapon)
        task.wait(0.1)
    end

    -- Teleport close to target
    local targetPos = target:GetPrimaryPartCFrame()
    LocalPlayer.Character:PivotTo(targetPos * CFrame.new(0, 0, -2))

    -- Fire attack remote
    local args = {"UsingMoveCustom", weapon, nil, {Clicked = true}}
    game:GetService("ReplicatedStorage").Remotes.UsedTool:FireServer(unpack(args))
    
    -- Fire confirmation remote
    local args2 = {"UsingMoveCustom", weapon, true, {Clicked = true}}
    game:GetService("ReplicatedStorage").Remotes.UsedTool:FireServer(unpack(args2))
end

Combat:Toggle({
    Title = "Kill Aura",
    Desc = "Automatically attacks nearby enemies (supports Bottle,Fork,Knife,Power Hold)",
    Value = false,
    Callback = function(state)
        killAuraEnabled = state
        if state then
            killAuraConnection = RunService.Heartbeat:Connect(function()
                pcall(ExecuteKillaura)
            end)
        else
            if killAuraConnection then
                killAuraConnection:Disconnect()
                killAuraConnection = nil
            end
        end
    end
})

Combat:Section({Title = "Aimbot"})
Combat:Divider()

-- Guard Aimbot Toggle
local guardAimbotEnabled = false
local guardAimbotCleanup

Combat:Toggle({
    Title = "Guard Aimbot",
    Desc = "Automatically aims at the nearest guard",
    Value = false,
    Callback = function(state)
        guardAimbotEnabled = state
        if state then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local guard = GetNearestGuard()
                if not guard then return end
                
                -- Smooth aiming
                local camPos = Camera.CFrame.Position
                local lookVector = (guard.Position - camPos).Unit
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + lookVector), 0.2)
            end)
            
            guardAimbotCleanup = function()
                connection:Disconnect()
            end
        elseif guardAimbotCleanup then
            guardAimbotCleanup()
            guardAimbotCleanup = nil
        end
    end
})

Combat:Toggle({
    Title = "Player Aimbot",
    Desc = "Automatically aims at the nearest player",
    Value = false,
    Callback = function(state)
        if state then
            local cleanup = PlayerAimbot()
            -- Store cleanup function to disable later
            getgenv().PlayerAimbotCleanup = cleanup
        else
            if getgenv().PlayerAimbotCleanup then
                getgenv().PlayerAimbotCleanup()
                getgenv().PlayerAimbotCleanup = nil
            end
        end
    end
})

-- Add this to the Combat tab section
Combat:Section({Title = "Hitbox Expander"})
Combat:Divider()

-- Hitbox variables
local hitboxEnabled = false
local hitboxSize = 5 -- Default size multiplier
local hitboxTransparency = 0.7
local hitboxColor = Color3.fromRGB(255, 0, 0)
local hitboxConnections = {}
local hitboxParts = {}

-- Function to create/update hitbox for a guard
local function updateHitbox(guard)
    if not guard:IsA("Model") then return end
    local hrp = guard:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Clear existing hitbox if any
    if hitboxParts[guard] then
        hitboxParts[guard]:Destroy()
        hitboxParts[guard] = nil
    end
    
    if not hitboxEnabled then return end
    
    -- Create a new invisible part that will act as the hitbox
    local hitbox = Instance.new("Part")
    hitbox.Name = "ExpandedHitbox"
    hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hitbox.Transparency = hitboxTransparency
    hitbox.Color = hitboxColor
    hitbox.Material = Enum.Material.ForceField
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.CFrame = hrp.CFrame
    
    -- Weld to the guard's HRP
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = hitbox
    weld.Parent = hitbox
    
    hitbox.Parent = guard
    hitboxParts[guard] = hitbox
    
    -- Make the original HRP invisible and non-collidable
    hrp.Transparency = 1
    hrp.CanCollide = false
    
    -- Cleanup when guard is removed
    hitboxConnections[guard] = guard.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if hitboxParts[guard] then
                hitboxParts[guard]:Destroy()
                hitboxParts[guard] = nil
            end
            if hitboxConnections[guard] then
                hitboxConnections[guard]:Disconnect()
                hitboxConnections[guard] = nil
            end
            -- Restore original HRP properties if guard still exists
            if guard.Parent then
                if hrp then
                    hrp.Transparency = 0
                    hrp.CanCollide = true
                end
            end
        end
    end)
end

-- Function to setup hitboxes for all guards
local function setupHitboxes()
    -- Clear existing hitboxes
    for guard, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
        -- Restore original HRP properties
        if guard and guard.Parent then
            local hrp = guard:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Transparency = 0
                hrp.CanCollide = true
            end
        end
    end
    table.clear(hitboxParts)
    
    for guard, conn in pairs(hitboxConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(hitboxConnections)

    if not hitboxEnabled then return end
    
    -- Find all existing guards
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and 
           (obj.Name:lower():find("guard") or obj.Name:lower():find("triangle") or 
            obj.Name:lower():find("squid") or obj.Name:lower():find("circle")) then
            updateHitbox(obj)
        end
    end
    
    -- Listen for new guards
    hitboxConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and 
           (obj.Name:lower():find("guard") or obj.Name:lower():find("triangle") or 
            obj.Name:lower():find("squid") or obj.Name:lower():find("circle")) then
            updateHitbox(obj)
        end
    end)
end

-- Main toggle for hitboxes
Combat:Toggle({
    Title = "Guard Hitbox Expander",
    Desc = "Makes guards easier to hit by expanding their hitbox",
    Value = false,
    Callback = function(state)
        hitboxEnabled = state
        setupHitboxes()
    end
})

Combat:Slider({
    Title = "Guard Hitbox Size",
    Value = {
        Min = 1,
        Max = 20,
        Default = 5,
    },
    Callback = function(value)
        hitboxSize = value
        if hitboxEnabled then
            for guard, hitbox in pairs(hitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                end
            end
        end
    end
})

Combat:Slider({
    Title = "Guard Hitbox Transparency",
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.7,
    },
    Callback = function(value)
        hitboxTransparency = value
        if hitboxEnabled then
            for guard, hitbox in pairs(hitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Transparency = hitboxTransparency
                end
            end
        end
    end
})

-- Color picker
Combat:Colorpicker({
    Title = "Guard Hitbox Color",
    Default = Color3.fromRGB(255, 0, 0), -- Red
    Callback = function(color)
        hitboxColor = color
        if hitboxEnabled then
            -- Update all existing hitboxes
            for guard, hitbox in pairs(hitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Color = hitboxColor
                end
            end
        end
    end
})

-- Auto-update when character respawns
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if hitboxEnabled then
        task.wait(1) -- Wait for character to load
        setupHitboxes()
    end
end)

-- Utility Tab
Utility:Section({Title = "Power"})
Utility:Divider()
-- Phantom Step Button
Utility:Button({
    Title = "Change to Phantom Step",
    Desc = "Equips the Phantom Step power",
    Callback = function()
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            player:SetAttribute("_EquippedPower", "PHANTOM STEP")
        end)
    end
})

Utility:Section({Title = "Utilities"})
Utility:Divider()

-- Invisibility Toggle
local invisibilityEnabled = false
local invisibilityCleanup

Utility:Toggle({
    Title = "Invisibility",
    Desc = "Makes your character transparent and float",
    Value = false,
    Callback = function(state)
        invisibilityEnabled = state
        if state then
            local char = LocalPlayer.Character
            if not char then return end

            -- Store original properties
            local original = {
                transparency = {},
                material = {},
                decals = {}
            }

            -- Make character transparent
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    original.transparency[part] = part.Transparency
                    original.material[part] = part.Material
                    part.Transparency = 0.7
                    part.Material = Enum.Material.Glass
                elseif part:IsA("Decal") then
                    original.decals[part] = part.Transparency
                    part.Transparency = 1
                end
            end

            -- Floating animation
            local floatHeight = 2
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = true
            end

            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, floatHeight, 0)
                bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                bodyVelocity.Parent = root

                -- Store cleanup function
                invisibilityCleanup = function()
                    for part, transparency in pairs(original.transparency) do
                        part.Transparency = transparency
                    end
                    for part, material in pairs(original.material) do
                        part.Material = material
                    end
                    for decal, transparency in pairs(original.decals) do
                        decal.Transparency = transparency
                    end
                    if humanoid then
                        humanoid.PlatformStand = false
                    end
                    if bodyVelocity then
                        bodyVelocity:Destroy()
                    end
                end
            end
        elseif invisibilityCleanup then
            invisibilityCleanup()
            invisibilityCleanup = nil
        end
    end
})

Utility:Input({
    Title = "Change Number Tag",
    Desc = "Enter desired tag number (1-456)",
    Default = "123",
    Numeric = true,
    Finished = false,
    Callback = function(value)
        getgenv().DESIRED_TAG = tonumber(value) or 123
    end
})

Utility:Button({
    Title = "Apply Number Tag",
    Desc = "Click to apply the entered tag number",
    Callback = function()
        local DESIRED_TAG = getgenv().DESIRED_TAG or 123
        if game.PlaceId == 125009265613167 then return end

        -- SERVICES
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        -- SETUP
        local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local clickedButtonRemote = ReplicatedStorage.Remotes.ClickedButton
        local args = {{buttonname = "leave"}}

        -- CONFIG (using the same CFrame you provided)
        local TARGET_CFRAME = CFrame.new(210.02560424804688, 55.94557189941406, -20.839000701904297)

        -- OPTIMIZED FUNCTIONS
        local function hasDesiredTag()
            local tag = localPlayer:FindFirstChild("PlayerTagValue")
            return tag and tag.Value == DESIRED_TAG
        end

        local function attemptTagChange()
            local character = localPlayer.Character
            if not character then return false end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return false end
            
            -- Execute all actions in one frame with no delays
            character:PivotTo(TARGET_CFRAME)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            clickedButtonRemote:FireServer(unpack(args))
            
            return hasDesiredTag()
        end

        -- Create a connection only if one doesn't exist
        if not getgenv().tagChangeConnection then
            getgenv().tagChangeConnection = RunService.Heartbeat:Connect(function()
                if not hasDesiredTag() then
                    attemptTagChange()
                else
                    -- Disconnect when we get the desired tag
                    if getgenv().tagChangeConnection then
                        getgenv().tagChangeConnection:Disconnect()
                        getgenv().tagChangeConnection = nil
                    end
                end
            end)
        end

        -- Initial immediate attempt
        attemptTagChange()
    end
})

Utility:Toggle({
    Title = "Auto Skip Cutscenes",
    Desc = "Automatically skips all cutscenes and dialogue",
    Value = false,
    Callback = function(state)
        if state then
            getgenv().skipCutsceneConnection = RunService.Heartbeat:Connect(function()
                
                local args = {"Skipped"}
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack(args))
                end)
            end)
        else
            if getgenv().skipCutsceneConnection then
                getgenv().skipCutsceneConnection:Disconnect()
                getgenv().skipCutsceneConnection = nil
            end
        end
    end
})

local function onCharacterAdded(character)
    if getgenv().currentWalkSpeed then
        task.wait(1)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = getgenv().currentWalkSpeed
        end
    end
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Misc
Misc:Section({Title = "Safe"})
Misc:Divider()
local lastPosition = nil
local safeZoneFolder = nil

local function createSafeZone()
    -- Delete existing safezone if it exists
    if safeZoneFolder then
        safeZoneFolder:Destroy()
    end
    
    -- Create new safezone folder
    safeZoneFolder = Instance.new("Folder", workspace)
    safeZoneFolder.Name = "SAFEZONEMAP"
    
    -- Create main platform (thicker to prevent glitching)
    local platform = Instance.new("Part", safeZoneFolder)
    platform.Name = "SafePlatform"
    platform.Size = Vector3.new(100, 5, 100) -- Thicker (5 studs tall)
    platform.Position = Vector3.new(0, 5000, 0) -- Still far away
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Slate
    platform.Color = Color3.fromRGB(150, 150, 150)
    
    -- Add protective wooden walls around the edges
    local wallHeight = 20
    local wallThickness = 2
    
    -- North wall
    local northWall = Instance.new("Part", safeZoneFolder)
    northWall.Size = Vector3.new(100 + wallThickness*2, wallHeight, wallThickness)
    northWall.Position = platform.Position + Vector3.new(0, wallHeight/2, 50 + wallThickness/2)
    northWall.Anchored = true
    northWall.CanCollide = true
    northWall.Material = Enum.Material.WoodPlanks
    northWall.Color = Color3.fromRGB(102, 70, 42)
    
    -- South wall
    local southWall = northWall:Clone()
    southWall.Parent = safeZoneFolder
    southWall.Position = platform.Position + Vector3.new(0, wallHeight/2, -50 - wallThickness/2)
    
    -- East wall
    local eastWall = Instance.new("Part", safeZoneFolder)
    eastWall.Size = Vector3.new(wallThickness, wallHeight, 100)
    eastWall.Position = platform.Position + Vector3.new(50 + wallThickness/2, wallHeight/2, 0)
    eastWall.Anchored = true
    eastWall.CanCollide = true
    eastWall.Material = Enum.Material.WoodPlanks
    eastWall.Color = northWall.Color
    eastWall.Parent = safeZoneFolder
    
    -- West wall
    local westWall = eastWall:Clone()
    westWall.Parent = safeZoneFolder
    westWall.Position = platform.Position + Vector3.new(-50 - wallThickness/2, wallHeight/2, 0)
    
    -- Add wooden border (decorative)
    local border = Instance.new("Part", safeZoneFolder)
    border.Size = Vector3.new(104, 1, 104)
    border.Position = platform.Position + Vector3.new(0, 2.5, 0)
    border.Anchored = true
    border.CanCollide = true
    border.Material = Enum.Material.WoodPlanks
    border.Color = Color3.fromRGB(102, 70, 42)
    
    -- Add some grass patches (on top of the platform)
    local grassColors = {
        Color3.fromRGB(34, 139, 34),
        Color3.fromRGB(0, 100, 0),
        Color3.fromRGB(50, 205, 50)
    }
    
    for i = 1, 15 do
        local grassPatch = Instance.new("Part", safeZoneFolder)
        grassPatch.Size = Vector3.new(math.random(8, 15), 0.5, math.random(8, 15))
        grassPatch.Position = platform.Position + Vector3.new(
            math.random(-40, 40),
            2.6, -- On top of platform
            math.random(-40, 40)
        )
        grassPatch.Anchored = true
        grassPatch.CanCollide = false
        grassPatch.Material = Enum.Material.Grass
        grassPatch.Color = grassColors[math.random(1, #grassColors)]
        
        -- Add some small rocks
        if math.random() > 0.7 then
            local rock = Instance.new("Part", safeZoneFolder)
            rock.Size = Vector3.new(math.random(2, 4), math.random(1, 2), math.random(2, 4))
            rock.Position = grassPatch.Position + Vector3.new(0, 0.5, 0)
            rock.Anchored = true
            rock.CanCollide = true
            rock.Material = Enum.Material.Slate
            rock.Color = Color3.fromRGB(100, 100, 100)
        end
    end
    
    -- Add a cozy chair
    local chair = Instance.new("Part", safeZoneFolder)
    chair.Name = "Chair"
    chair.Size = Vector3.new(4, 3, 4)
    chair.Position = platform.Position + Vector3.new(20, 2.5, 0)
    chair.Anchored = true
    chair.CanCollide = true
    chair.Material = Enum.Material.Wood
    chair.Color = Color3.fromRGB(139, 69, 19) -- Brown
    
    -- Chair backrest
    local backrest = Instance.new("Part", safeZoneFolder)
    backrest.Size = Vector3.new(4, 6, 0.5)
    backrest.Position = chair.Position + Vector3.new(0, 3, -2)
    backrest.Anchored = true
    backrest.CanCollide = true
    backrest.Material = Enum.Material.Wood
    backrest.Color = chair.Color
    
    -- Add some trees
    for i = 1, 4 do
        local treePos = platform.Position + Vector3.new(
            math.random(-35, 35),
            0,
            math.random(-35, 35)
        )
        
        -- Tree trunk
        local trunk = Instance.new("Part", safeZoneFolder)
        trunk.Size = Vector3.new(3, 10, 3)
        trunk.Position = treePos + Vector3.new(0, 5, 0)
        trunk.Anchored = true
        trunk.CanCollide = true
        trunk.Material = Enum.Material.Wood
        trunk.Color = Color3.fromRGB(101, 67, 33)
        
        -- Tree leaves
        local leaves = Instance.new("Part", safeZoneFolder)
        leaves.Size = Vector3.new(12, 8, 12)
        leaves.Position = trunk.Position + Vector3.new(0, 8, 0)
        leaves.Anchored = true
        leaves.CanCollide = true
        leaves.Material = Enum.Material.Sand
        leaves.Color = Color3.fromRGB(34, 139, 34)
        leaves.Shape = Enum.PartType.Ball
    end
    
    -- Add a campfire
    local fireBase = Instance.new("Part", safeZoneFolder)
    fireBase.Size = Vector3.new(6, 1, 6)
    fireBase.Position = platform.Position + Vector3.new(-20, 2.6, 0)
    fireBase.Anchored = true
    fireBase.CanCollide = true
    fireBase.Material = Enum.Material.Slate
    fireBase.Color = Color3.fromRGB(80, 80, 80)
    
    -- Actual fire effect
    local fire = Instance.new("Fire", fireBase)
    fire.Heat = 10
    fire.Size = 5
    fire.Color = Color3.new(1, 0.5, 0.1)
    fire.SecondaryColor = Color3.new(1, 0.8, 0)
    
    -- Add subtle lighting
    local light = Instance.new("PointLight", fireBase)
    light.Brightness = 5
    light.Range = 20
    light.Color = Color3.new(1, 0.6, 0.3)
    
    -- Spawn position (near the chair, above platform)
    return platform.Position + Vector3.new(20, 7, 0)
end

Misc:Button({
    Title = "Teleport to SafeZone",
    Desc = "Teleports you to a safezone",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            lastPosition = character.HumanoidRootPart.CFrame
            local safeZonePos = createSafeZone()
            character.HumanoidRootPart.CFrame = CFrame.new(safeZonePos)
        end
    end
})

Misc:Button({
    Title = "Teleport Back",
    Desc = "Returns you to where you were",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and lastPosition then
            character.HumanoidRootPart.CFrame = lastPosition
            if safeZoneFolder then
                safeZoneFolder:Destroy()
                safeZoneFolder = nil
            end
        end
    end
})

-- Improved Anti-Void System
local antiVoidEnabled = false
local antiVoidPart = nil
local antiVoidLoop = nil
local lastSafePosition = nil

local function createAntiVoid()
    -- Create a smarter anti-void platform
    antiVoidPart = Instance.new("Part")
    antiVoidPart.Name = "AntiVoidPlatform"
    antiVoidPart.Anchored = true
    antiVoidPart.CanCollide = true
    antiVoidPart.Size = Vector3.new(2000, 2, 2000) -- Wider coverage
    antiVoidPart.Transparency = 0.7
    antiVoidPart.Material = Enum.Material.Neon
    antiVoidPart.Color = Color3.fromRGB(0, 255, 255)
    antiVoidPart.Parent = workspace

    -- Add safety forcefield
    local forceField = Instance.new("ForceField")
    forceField.Visible = false
    forceField.Parent = antiVoidPart

    -- Better bounce pad effect
    local bouncePad = Instance.new("BodyVelocity")
    bouncePad.MaxForce = Vector3.new(0, math.huge, 0)
    bouncePad.Velocity = Vector3.new(0, 150, 0) -- Stronger bounce
    bouncePad.Parent = antiVoidPart
end

local function updateAntiVoid()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local character = LocalPlayer.Character
    local rootPart = character.HumanoidRootPart
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, antiVoidPart}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    -- Track safe position when not falling
    if rootPart.Velocity.Y > -50 then -- Only update if not falling fast
        lastSafePosition = rootPart.Position
    end

    -- Dynamic platform positioning
    local rayOrigin = rootPart.Position
    local rayDirection = Vector3.new(0, -1000, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if raycastResult then
        -- Position platform 10 studs below the detected surface
        antiVoidPart.Position = Vector3.new(
            lastSafePosition.X, 
            raycastResult.Position.Y - 15, 
            lastSafePosition.Z
        )
    elseif lastSafePosition then
        -- Fallback to last safe position if no raycast hit
        antiVoidPart.Position = Vector3.new(
            lastSafePosition.X, 
            rootPart.Position.Y - 50, 
            lastSafePosition.Z
        )
    end

    -- Emergency teleport if falling too fast
    if rootPart.Velocity.Y < -100 then
        character:PivotTo(CFrame.new(lastSafePosition + Vector3.new(0, 5, 0)))
    end
end

Misc:Toggle({
    Title = "Anti-Void",
    Desc = "Prevents falling through the map",
    Value = false,
    Callback = function(state)
        antiVoidEnabled = state
        if state then
            createAntiVoid()
            antiVoidLoop = RunService.Heartbeat:Connect(updateAntiVoid)
            
            -- Initialize last safe position
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                lastSafePosition = LocalPlayer.Character.HumanoidRootPart.Position
            end
        else
            if antiVoidLoop then
                antiVoidLoop:Disconnect()
                antiVoidLoop = nil
            end
            if antiVoidPart then
                antiVoidPart:Destroy()
                antiVoidPart = nil
            end
            lastSafePosition = nil
        end
    end
})

-- Auto-reinitialize on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    if antiVoidEnabled then
        task.wait(1) -- Wait for character to load
        createAntiVoid()
        if not antiVoidLoop then
            antiVoidLoop = RunService.Heartbeat:Connect(updateAntiVoid)
        end
    end
end)

Misc:Section({Title = "Character Modifications"})
Misc:Divider()

-- Disable Injuries Toggle
local disableInjuriesEnabled = false
local injuriesConnection

Misc:Toggle({
    Title = "Disable Injuries",
    Desc = "Removes injured walking",
    Value = false,
    Callback = function(state)
        disableInjuriesEnabled = state
        if state then
            injuriesConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    -- Add small delay between checks
                    task.wait(0.3)
                    
                    local player = Players.LocalPlayer
                    local character = workspace.Live:FindFirstChild(player.Name)
                    if character then
                        local injuredWalking = character:FindFirstChild("InjuredWalking")
                        if injuredWalking then
                            injuredWalking:Destroy()
                        end
                    end
                end)
            end)
        else
            if injuriesConnection then
                injuriesConnection:Disconnect()
                injuriesConnection = nil
            end
        end
    end
})

-- Disable Stun/Slow Toggle
local disableStunEnabled = false
local stunConnection

Misc:Toggle({
    Title = "Disable Stun/Slow",
    Desc = "Removes stun and slow effects",
    Value = false,
    Callback = function(state)
        disableStunEnabled = state
        if state then
            stunConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    -- Add small delay between checks
                    task.wait(0.3)
                    
                    local player = Players.LocalPlayer
                    local character = workspace.Live:FindFirstChild(player.Name)
                    if character then
                        for _, descendant in pairs(character:GetDescendants()) do
                            if string.find(string.lower(descendant.Name), "stun") then
                                descendant:Destroy()
                            end
                        end
                    end
                end)
            end)
            
            -- Also check when character is added
            Players.LocalPlayer.CharacterAdded:Connect(function(character)
                if disableStunEnabled then
                    task.wait(1) -- Wait for character to fully load
                    for _, descendant in pairs(character:GetDescendants()) do
                        if string.find(string.lower(descendant.Name), "stun") then
                            descendant:Destroy()
                        end
                    end
                end
            end)
        else
            if stunConnection then
                stunConnection:Disconnect()
                stunConnection = nil
            end
        end
    end
})

Misc:Slider({
    Title = "Walk Speed",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        getgenv().currentWalkSpeed = value
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

Misc:Slider({
    Title = "Jump Power",
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = value
        end
    end
})

-- Anti AFK Toggle
local antiAFKEnabled = false
local antiAFKConnection

Misc:Toggle({
    Title = "Anti AFK",
    Desc = "Prevents you from being kicked for inactivity",
    Value = false,
    Callback = function(state)
        antiAFKEnabled = state
        if state then
            -- Simulate activity by moving the mouse slightly
            antiAFKConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    -- Move mouse slightly every 30 seconds to prevent AFK
                    if tick() % 30 < 0.1 then
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendMouseMoveEvent(1, 1, game:GetService("Players").LocalPlayer.PlayerGui)
                    end
                    
                    -- Alternative method using VirtualUser
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController()
                    VirtualUser:SetKeyDown("0x01") -- Left mouse button
                    VirtualUser:SetKeyUp("0x01")
                end)
            end)
            
            -- Also connect to the game's idle event
            Players.LocalPlayer.Idled:Connect(function()
                if antiAFKEnabled then
                    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
    end
})

-- NoClip Toggle
local noclipEnabled = false
local noclipConnection

local function noclipLoop()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

Misc:Toggle({
    Title = "NoClip",
    Desc = "Walk through walls and objects",
    Value = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            -- Enable NoClip
            noclipConnection = RunService.Stepped:Connect(noclipLoop)
            
            -- Handle character respawns
            LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5) -- Wait for character to fully load
                if noclipEnabled then
                    noclipLoop()
                end
            end)
        else
            -- Disable NoClip
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- Restore collision if character exists
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- Visual Tab
Visual:Section({Title = "ESP"})
Visual:Divider()

-- ESP Players
local playerESPEnabled = false
local playerESPConnections = {}
local playerHighlights = {}
local playerBillboards = {}

local function CreatePlayerESP(player)
    if not player.Character then return end

    -- Clear existing ESP if any
    if playerHighlights[player] then
        playerHighlights[player]:Destroy()
        playerHighlights[player] = nil
    end
    if playerBillboards[player] then
        playerBillboards[player]:Destroy()
        playerBillboards[player] = nil
    end

    if not playerESPEnabled then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP"
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(0, 170, 255)  -- Blue
    highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = player.Character
    playerHighlights[player] = highlight

    -- Floating text with health
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = player.Character:WaitForChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Text = player.Name .. " (HP: 100)"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Parent = billboard
    billboard.Parent = player.Character
    playerBillboards[player] = billboard

    -- Update health display
    local healthConnection
    if player.Character:FindFirstChild("Humanoid") then
        healthConnection = player.Character.Humanoid.HealthChanged:Connect(function(health)
            label.Text = player.Name .. " (HP: " .. math.floor(health) .. ")"
        end)
    end

    -- Cleanup function
    local function cleanup()
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        if healthConnection then
            healthConnection:Disconnect()
        end
        playerHighlights[player] = nil
        playerBillboards[player] = nil
    end

    -- Track character changes
    playerESPConnections[player] = player.CharacterAdded:Connect(function(newChar)
        cleanup()
        CreatePlayerESP(player)  -- Recreate for new character
    end)

    -- Auto-cleanup when player leaves
    playerESPConnections[player.."Removing"] = player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
            if playerESPConnections[player] then
                playerESPConnections[player]:Disconnect()
                playerESPConnections[player] = nil
            end
        end
    end)
end

local function SetupPlayerESP()
    -- Clear existing ESP
    for player, highlight in pairs(playerHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(playerHighlights)
    
    for player, billboard in pairs(playerBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(playerBillboards)
    
    for player, conn in pairs(playerESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(playerESPConnections)

    if not playerESPEnabled then return end

    -- Initialize for all players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then  -- Skip local player
            CreatePlayerESP(player)
        end
    end

    -- Track new players
    playerESPConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
        CreatePlayerESP(player)
    end)
end

Visual:Toggle({
    Title = "ESP Players",
    Desc = "Highlights all players with health display",
    Value = false,
    Callback = function(state)
        playerESPEnabled = state
        SetupPlayerESP()
    end
})

-- ESP Guards
local guardESPEnabled = false
local guardESPConnections = {}
local guardHighlights = {}
local guardBillboards = {}

local function CreateGuardESP(guardModel)
    if not guardModel:FindFirstChild("Humanoid") then return end

    -- Clear existing ESP if any
    if guardHighlights[guardModel] then
        guardHighlights[guardModel]:Destroy()
        guardHighlights[guardModel] = nil
    end
    if guardBillboards[guardModel] then
        guardBillboards[guardModel]:Destroy()
        guardBillboards[guardModel] = nil
    end

    if not guardESPEnabled then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GuardESP"
    highlight.Adornee = guardModel
    highlight.FillColor = Color3.fromRGB(255, 100, 0)  -- Orange
    highlight.OutlineColor = Color3.fromRGB(200, 50, 0)
    highlight.FillTransparency = 0.4
    highlight.Parent = guardModel
    guardHighlights[guardModel] = highlight

    -- Floating text
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = guardModel:WaitForChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Text = "GUARD"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Parent = billboard
    billboard.Parent = guardModel
    guardBillboards[guardModel] = billboard

    -- Cleanup function
    local function cleanup()
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        guardHighlights[guardModel] = nil
        guardBillboards[guardModel] = nil
    end

    -- Auto-remove when guard dies
    guardESPConnections[guardModel] = guardModel.Humanoid.Died:Connect(cleanup)

    -- Auto-remove when guard is removed
    guardESPConnections[guardModel.."Removing"] = guardModel.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
            if guardESPConnections[guardModel] then
                guardESPConnections[guardModel]:Disconnect()
                guardESPConnections[guardModel] = nil
            end
        end
    end)
end

local function SetupGuardESP()
    -- Clear existing ESP
    for guard, highlight in pairs(guardHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(guardHighlights)
    
    for guard, billboard in pairs(guardBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(guardBillboards)
    
    for guard, conn in pairs(guardESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(guardESPConnections)

    if not guardESPEnabled then return end

    -- Find existing guards
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():find("guard") then
            CreateGuardESP(obj)
        end
    end

    -- Detect new guards
    guardESPConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():find("guard") then
            CreateGuardESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Guards",
    Desc = "Highlights all guards in the game",
    Value = false,
    Callback = function(state)
        guardESPEnabled = state
        SetupGuardESP()
    end
})

Visual:Section({Title = "Hide and Seek"})
Visual:Divider()

-- ESP Variables
local hiderESPEnabled = false
local hunterESPEnabled = false
local hiderHighlights = {}
local hunterHighlights = {}

-- ESP Functions (exactly as you provided)
local function HiderESP(player)
    if player:GetAttribute("IsHider") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Clear existing highlight if any
        if hiderHighlights[player] then
            hiderHighlights[player]:Destroy()
            hiderHighlights[player] = nil
        end

        if not hiderESPEnabled then return end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Green for hiders
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.Parent = player.Character
        hiderHighlights[player] = highlight

        -- Cleanup when player is no longer a hider
        player:GetAttributeChangedSignal("IsHider"):Connect(function()
            if hiderHighlights[player] then 
                hiderHighlights[player]:Destroy()
                hiderHighlights[player] = nil
            end
        end)
    end
end

local function HunterESP(player)
    if player:GetAttribute("IsHunter") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Clear existing highlight if any
        if hunterHighlights[player] then
            hunterHighlights[player]:Destroy()
            hunterHighlights[player] = nil
        end

        if not hunterESPEnabled then return end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red for hunters
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.Parent = player.Character
        hunterHighlights[player] = highlight

        -- Cleanup when player is no longer a hunter
        player:GetAttributeChangedSignal("IsHunter"):Connect(function()
            if hunterHighlights[player] then 
                hunterHighlights[player]:Destroy()
                hunterHighlights[player] = nil
            end
        end)
    end
end

-- Apply ESP to all players
local function ApplyHideAndSeekESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            HiderESP(player)
            HunterESP(player)
        end
    end
end

-- Cleanup all ESP
local function CleanupHideAndSeekESP()
    for player, highlight in pairs(hiderHighlights) do
        if highlight then highlight:Destroy() end
    end
    for player, highlight in pairs(hunterHighlights) do
        if highlight then highlight:Destroy() end
    end
    table.clear(hiderHighlights)
    table.clear(hunterHighlights)
end

-- Player Added/Removed Handlers
local function OnPlayerAdded(player)
    if player ~= LocalPlayer then
        HiderESP(player)
        HunterESP(player)
    end
end

local function OnPlayerRemoving(player)
    if hiderHighlights[player] then
        hiderHighlights[player]:Destroy()
        hiderHighlights[player] = nil
    end
    if hunterHighlights[player] then
        hunterHighlights[player]:Destroy()
        hunterHighlights[player] = nil
    end
end

-- Initialize ESP connections
local function InitializeESP()
    -- Cleanup existing ESP
    CleanupHideAndSeekESP()
    
    -- Apply to existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            HiderESP(player)
            HunterESP(player)
        end
    end
    
    -- Connect signals
    Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(OnPlayerRemoving)
    
    -- Track attribute changes
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player:GetAttributeChangedSignal("IsHider"):Connect(function()
                HiderESP(player)
            end)
            player:GetAttributeChangedSignal("IsHunter"):Connect(function()
                HunterESP(player)
            end)
        end
    end
end

-- Toggles
Visual:Toggle({
    Title = "ESP Hiders",
    Desc = "Highlights hiders in green",
    Value = false,
    Callback = function(state)
        hiderESPEnabled = state
        if state then
            InitializeESP()
        else
            -- Only clean up hider highlights
            for player, highlight in pairs(hiderHighlights) do
                if highlight then highlight:Destroy() end
            end
            table.clear(hiderHighlights)
        end
    end
})

Visual:Toggle({
    Title = "ESP Hunters",
    Desc = "Highlights hunters in red",
    Value = false,
    Callback = function(state)
        hunterESPEnabled = state
        if state then
            InitializeESP()
        else
            -- Only clean up hunter highlights
            for player, highlight in pairs(hunterHighlights) do
                if highlight then highlight:Destroy() end
            end
            table.clear(hunterHighlights)
        end
    end
})

-- Add Key ESP toggle
local keyESPEnabled = false
local keyESPConnections = {}
local keyHighlights = {}

local function KeyESP(keyModel)
    if not keyModel or not keyModel:IsA("Model") or not keyModel.PrimaryPart then
        return
    end

    -- Create Highlight for the key
    local highlight = Instance.new("Highlight")
    highlight.Name = "KeyESP"
    highlight.Adornee = keyModel
    highlight.FillColor = Color3.fromRGB(255, 255, 0)  -- Yellow color for keys
    highlight.OutlineColor = Color3.fromRGB(255, 215, 0) -- Gold outline
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Parent = keyModel
    keyHighlights[keyModel] = highlight

    -- Clean up if the key is destroyed or removed
    local connection
    connection = keyModel.AncestryChanged:Connect(function(_, parent)
        if not parent or not keyModel:IsDescendantOf(game) then
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
            if connection then
                connection:Disconnect()
            end
            keyHighlights[keyModel] = nil
        end
    end)

    keyESPConnections[keyModel] = connection
end

local function SetupKeyESP()
    -- Clear existing highlights and connections
    for key, highlight in pairs(keyHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(keyHighlights)
    
    for key, conn in pairs(keyESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(keyESPConnections)

    if not keyESPEnabled then return end

    -- Scan existing keys in workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("key") and obj:IsA("Model") then
            KeyESP(obj)
        end
    end

    -- Listen for new keys
    keyESPConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj.Name:lower():find("key") and obj:IsA("Model") then
            KeyESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Key",
    Desc = "Highlights keys in Hide and Seek",
    Value = false,
    Callback = function(state)
        keyESPEnabled = state
        SetupKeyESP()
    end
})

-- Improved Escape Door ESP
local escapeDoorESPEnabled = false
local escapeDoorHighlights = {}
local escapeDoorBillboards = {}
local escapeDoorConnections = {}

local function EscapeDoorESP(door)
    -- Validate the door object
    if not door or not door:IsA("Model") then return end
    if not door.PrimaryPart then return end
    
    -- Check if this door already has ESP
    if escapeDoorHighlights[door] or escapeDoorBillboards[door] then return end

    -- Create visual elements
    local highlight = Instance.new("Highlight")
    highlight.Adornee = door
    highlight.FillColor = Color3.fromRGB(0, 255, 0)  -- Green for escape
    highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = door
    escapeDoorHighlights[door] = highlight

    -- Add a floating text label
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = door.PrimaryPart
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Text = "ESCAPE DOOR"
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextSize = 14
    label.Font = Enum.Font.Oswald
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = billboard
    billboard.Parent = door
    escapeDoorBillboards[door] = billboard

    -- Cleanup function
    local function cleanup()
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        escapeDoorHighlights[door] = nil
        escapeDoorBillboards[door] = nil
    end

    -- Auto-cleanup when door is removed
    escapeDoorConnections[door] = door.AncestryChanged:Connect(function(_, parent)
        if not parent then cleanup() end
    end)
end

local function SetupEscapeDoorESP()
    -- Clear existing ESP
    for door, highlight in pairs(escapeDoorHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(escapeDoorHighlights)
    
    for door, billboard in pairs(escapeDoorBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(escapeDoorBillboards)
    
    for door, conn in pairs(escapeDoorConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(escapeDoorConnections)

    if not escapeDoorESPEnabled then return end

    -- Check existing doors
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "EXITDOOR" then
            EscapeDoorESP(obj)
        end
    end

    -- Monitor for new doors
    escapeDoorConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj.Name == "EXITDOOR" then
            EscapeDoorESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Escape Doors",
    Desc = "Highlights escape doors in Hide and Seek",
    Value = false,
    Callback = function(state)
        escapeDoorESPEnabled = state
        SetupEscapeDoorESP()
    end
})

-- Add Door ESP toggle
local doorESPEnabled = false
local doorESPConnections = {}
local doorHighlights = {}
local doorBillboards = {}

local function DoorESP(door)
    if not door:IsA("Model") or not door.PrimaryPart then return end
    
    -- Only target door models (adjust names as needed)
    if not (door.Name:find("Door") or door.Name:find("door")) then return end

    -- Clear existing ESP if any
    if doorHighlights[door] then
        doorHighlights[door]:Destroy()
        doorHighlights[door] = nil
    end
    if doorBillboards[door] then
        doorBillboards[door]:Destroy()
        doorBillboards[door] = nil
    end

    if not doorESPEnabled then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DoorESP"
    highlight.Adornee = door
    highlight.FillColor = Color3.fromRGB(255, 165, 0)  -- Orange
    highlight.OutlineColor = Color3.fromRGB(255, 100, 0)
    highlight.FillTransparency = 0.6
    highlight.Parent = door
    doorHighlights[door] = highlight

    -- Show required key if available
    local keyNeeded = door:GetAttribute("KeyNeeded") or "Unknown"
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = door.PrimaryPart
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Text = "DOOR (Key: "..keyNeeded..")"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Parent = billboard
    billboard.Parent = door
    doorBillboards[door] = billboard

    -- Cleanup function
    local function cleanup()
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        doorHighlights[door] = nil
        doorBillboards[door] = nil
    end

    -- Auto-cleanup when door is removed
    doorESPConnections[door] = door.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
            if doorESPConnections[door] then
                doorESPConnections[door]:Disconnect()
                doorESPConnections[door] = nil
            end
        end
    end)
end

local function SetupDoorESP()
    -- Clear existing ESP
    for door, highlight in pairs(doorHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(doorHighlights)
    
    for door, billboard in pairs(doorBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(doorBillboards)
    
    for door, conn in pairs(doorESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(doorESPConnections)

    if not doorESPEnabled then return end

    -- Find existing doors
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            DoorESP(obj)
        end
    end

    -- Detect new doors
    doorESPConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            DoorESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Door and Required Key",
    Desc = "Highlights doors and shows required key",
    Value = false,
    Callback = function(state)
        doorESPEnabled = state
        SetupDoorESP()
    end
})

-- Handle character respawns for all toggles
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1) -- Wait for character to load
    
    if invisibilityEnabled then
        -- Reapply invisibility
        local toggle = Utility:FindFirstChild("Invisibility")
        if toggle then toggle.Callback(true) end
    end
    
    if guardAimbotEnabled then
        -- Reapply guard aimbot
        local toggle = Combat:FindFirstChild("Guard Aimbot")
        if toggle then toggle.Callback(true) end
    end
end)

if not hookmetamethod then
    WindUI:Notify({
    Title = "Error",
    Description = "Your executor doesn't support hookmetamethod",
    Duration = 10,
    Callback = function() end
})
    return
end