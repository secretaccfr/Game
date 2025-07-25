local function SendWebhookNotification()
    local player = game:GetService("Players").LocalPlayer
    local webhookUrl = "https://discord.com/api/webhooks/1396067534477725816/46ZmAgoTKL9VR1c9tokF3yNw37STOc7TpGCyi9sUsA8GgVVq8g0DpF9WTXk7p4s4A-PZ"
    
    local embed = {
        {
            ["title"] = "Ink Game V4.2 Executed",
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
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
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
    Title = "Tuff Guys | Ink Game V4.2",
    Icon = "rbxassetid://130506306640152",
    IconThemed = true,
    Author = "Tuff Agsy",
    Folder = "InkGameAgsy",
    Size = UDim2.fromOffset(580, 380),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
})

Window:SetBackgroundImage("rbxassetid://130506306640152")
Window:SetBackgroundImageTransparency(0.8)
Window:DisableTopbarButtons({"Fullscreen"})

Window:EditOpenButton({
    Title = "Tuff Guys | Ink Game V4.2",
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
    Title = "Changelogs V4.2",
    Desc = "[~] Improved Key ESP\n[~] Improved Auto Perfect Jump\n[~] Improved Anti Fall\n[~] Improved Auto Pull Rope\n[+] Added Auto SafeZone\n[+] Added Player Teleport",
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

Window:SelectTab(1)

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

local function AntiFallJumpRope()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Workspace = game:GetService("Workspace")
    
    -- Destroy fall detection parts immediately
    local function destroyFallParts()
        local jumpRope = Workspace:FindFirstChild("JumpRope")
        if not jumpRope then return end
        
        -- List of parts to destroy
        local partsToDestroy = {
            "FallColllisionYClient",
            "FallColllisionY", 
            "COLLISIONCHECK"
        }
        
        -- Also destroy COLLISION1 if it exists in Effects
        if Workspace:FindFirstChild("Effects") then
            local collision1 = Workspace.Effects:FindFirstChild("COLLISION1")
            if collision1 then
                collision1:Destroy()
            end
        end
        
        for _, partName in ipairs(partsToDestroy) do
            local part = jumpRope:FindFirstChild(partName)
            if part then
                part:Destroy()
            end
        end
    end

    -- Anti-fall protection
    local connection
    local function preventFalling()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Adjust Y threshold based on the game's map
        if humanoidRootPart.Position.Y < 100 then
            humanoidRootPart.CFrame = CFrame.new(
                humanoidRootPart.Position.X, 
                150, 
                humanoidRootPart.Position.Z
            )
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end

    -- Initial destruction of parts
    destroyFallParts()
    
    -- Monitor for parts being recreated
    local jumpRope = Workspace:WaitForChild("JumpRope", 5)
    if jumpRope then
        jumpRope.ChildAdded:Connect(function(child)
            if table.find({"FallColllisionYClient", "FallColllisionY", "COLLISIONCHECK"}, child.Name) then
                task.wait(0.1) -- Small delay to ensure part is fully initialized
                child:Destroy()
            end
        end)
    end
    
    -- Also monitor Effects folder for COLLISION1 recreation
    if Workspace:FindFirstChild("Effects") then
        Workspace.Effects.ChildAdded:Connect(function(child)
            if child.Name == "COLLISION1" then
                task.wait(0.1)
                child:Destroy()
            end
        end)
    end
    
    -- Start fall prevention
    connection = RunService.Heartbeat:Connect(preventFalling)
    
    -- Cleanup function
    return function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end

function AntiCheatPatch()
    if not hookmetamethod then
        warn("Your executor doesn't support hookmetamethod!")
        return function() end
    end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    
    -- Store original functions
    local originalIndex
    local originalNewIndex
    local originalNamecall
    
    -- Velocity spoofing
    local function newIndex(self, key, value)
        if not checkcaller() and self:IsA("BasePart") and (key == "Velocity" or key == "AssemblyLinearVelocity") then
            return
        end
        return originalNewIndex(self, key, value)
    end

    -- Remote blocking with optimized checks
    local function namecall(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" then
            local remoteName = tostring(self)
            
            -- Optimized remote checks
            if remoteName == "TemporaryReachedBindable" then
                local args = {...}
                if args[1] and type(args[1]) == "table" and (args[1].FallingPlayer or args[1].funnydeath) then
                    return nil
                end
            elseif remoteName == "RandomOtherRemotes" then
                local args = {...}
                if args[1] and type(args[1]) == "table" and args[1].FallenOffMap then
                    return nil
                end
            end
        end
        
        return originalNamecall(self, ...)
    end

    -- Sub patch function for blocking anticheat remotes
    local function BlockAnticheatRemote(call)
        if call then
            if not hookmetamethod then
                return false
            end
            
            local AnticheatHook
            AnticheatHook = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()

                if tostring(self) == "TemporaryReachedBindable" and method == "FireServer" then
                    if args[1] ~= nil and type(args[1]) == "table" and (args[1].FallingPlayer ~= nil or args[1].funnydeath ~= nil) then
                        return nil
                    end
                end

                if tostring(self) == "RandomOtherRemotes" and method == "FireServer" then
                    if args[1] ~= nil and type(args[1]) == "table" and args[1].FallenOffMap ~= nil then
                        return nil
                    end
                end
                
                return AnticheatHook(self, ...)
            end)
            
            return AnticheatHook
        else
            if not hookmetamethod then return false end
            if not getgenv().AnticheatHook then return false end
            hookmetamethod(game, '__namecall', getgenv().AnticheatHook)
            return true
        end
    end

    -- Prevent anchoring with optimized checks
    local anchorConnection
    local function onCharacterAdded(character)
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 2)
        if humanoidRootPart then
            if anchorConnection then
                anchorConnection:Disconnect()
            end
            -- Only create connection if part exists
            anchorConnection = humanoidRootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
                if humanoidRootPart.Anchored then
                    humanoidRootPart.Anchored = false
                end
            end)
        end
    end

    -- Apply hooks with protection
    local success1, msg1 = pcall(function()
        originalNewIndex = hookmetamethod(game, "__newindex", newIndex)
    end)
    
    local success2, msg2 = pcall(function()
        originalNamecall = hookmetamethod(game, "__namecall", namecall)
    end)
    
    -- Apply the additional anticheat remote block
    local success3 = pcall(function()
        getgenv().AnticheatHook = BlockAnticheatRemote(true)
    end)
    
    if not success1 or not success2 or not success3 then
        return function() end
    end
    
    -- Setup character monitoring with protection
    local charAddedConn
    if LocalPlayer.Character then
        pcall(onCharacterAdded, LocalPlayer.Character)
    end
    
    local success4, msg4 = pcall(function()
        charAddedConn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    end)
    
    if not success4 then
    end

    -- Cleanup function
    return function()
        -- Only attempt to restore if we successfully hooked
        if originalNewIndex then
            pcall(function()
                hookmetamethod(game, "__newindex", originalNewIndex)
            end)
        end
        
        if originalNamecall then
            pcall(function()
                hookmetamethod(game, "__namecall", originalNamecall)
            end)
        end
        
        -- Cleanup the additional anticheat remote block
        pcall(function()
            BlockAnticheatRemote(false)
        end)
        
        if charAddedConn then
            pcall(charAddedConn.Disconnect, charAddedConn)
        end
        
        if anchorConnection then
            pcall(anchorConnection.Disconnect, anchorConnection)
        end
    end
end

local function AutoPerfectJumpRope()
    -- Check if jump rope game exists
    local ropeEffects = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("ropetesting")
    if not ropeEffects then return end
    
    -- Find the rope's root part
    local ropeRoot = ropeEffects:FindFirstChild("RootPart")
    if not ropeRoot then return end
    
    -- Find all bone attachments (by name, case insensitive)
    local boneAttachments = {}
    for _, descendant in pairs(ropeRoot:GetDescendants()) do
        if descendant.Name:lower():find("bone") and not descendant.Name:lower():find("^ok") then
            table.insert(boneAttachments, descendant)
        end
    end
    
    -- If no bone attachments found, return
    if #boneAttachments == 0 then return end
    
    -- Get player character and humanoid
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Check distance to all bone attachments
    local shouldJump = false
    for _, bone in ipairs(boneAttachments) do
        if bone.WorldPosition then
            local distance = (bone.WorldPosition - rootPart.Position).Magnitude
            if distance <= 1 then
                shouldJump = true
                break
            end
        end
    end
    
    -- Jump if any bone is close
    if shouldJump then
        -- Jump using humanoid
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        -- Fire the falling player remote every 0.45 seconds
        if not getgenv().lastJumpTime or (tick() - getgenv().lastJumpTime) >= 0.45 then
            local args = {
                {
                    FallingPlayer = true
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer(unpack(args))
            getgenv().lastJumpTime = tick()
        end
    end
end

local function CopyDiscordInvite()
    setclipboard("https://discord.gg/tuffguys")
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
        AntiCheatPatch()
        WindUI:Notify({Title = "Anti Cheat Bypass", Desc = "Tuff Anti Cheat Activated", Duration = 5})
    end
})

local touchFlingEnabled = false
local touchFlingConnection = nil
local touchFlingAntiCheatHook = nil

Main:Toggle({
    Title = "Fling Aura [BUGGED]",
    Desc = "Fling anyone who touches you",
    Value = false,
    Callback = function(state)
        touchFlingEnabled = state
        if state then
            -- Hook anti-cheat detection
            local function hookAntiFling()
                if not LocalPlayer.Character then return end
                local Main = LocalPlayer.Character:FindFirstChild("Main")
                if Main then
                    Main.Enabled = false
                    Main.Disabled = true
                    touchFlingAntiCheatHook = Main:GetPropertyChangedSignal("Enabled"):Connect(function()
                        Main.Enabled = false
                        Main.Disabled = true
                    end)
                end
            end
            
            -- Connect to touched event
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            
            -- Fling aura logic
            local movel = 0.1
            touchFlingConnection = RunService.Heartbeat:Connect(function()
                if not touchFlingEnabled then return end
                
                -- Anti-cheat hook
                if not touchFlingAntiCheatHook then
                    hookAntiFling()
                end
                
                -- Fling velocity manipulation
                if character and hrp then
                    local originalVel = hrp.Velocity
                    hrp.Velocity = originalVel * 10000 + Vector3.new(0, 10000, 0)
                    task.wait()
                    if character and hrp then
                        hrp.Velocity = originalVel + Vector3.new(0, movel, 0)
                        movel = -movel
                    end
                end
            end)
            
            -- Re-hook on character respawn
            LocalPlayer.CharacterAdded:Connect(function(newChar)
                if touchFlingEnabled then
                    character = newChar
                    hrp = character:WaitForChild("HumanoidRootPart")
                    hookAntiFling()
                end
            end)
            
            -- Initial anti-cheat hook
            hookAntiFling()
        else
            -- Clean up
            if touchFlingConnection then
                touchFlingConnection:Disconnect()
                touchFlingConnection = nil
            end
            
            if touchFlingAntiCheatHook then
                touchFlingAntiCheatHook:Disconnect()
                touchFlingAntiCheatHook = nil
                
                -- Restore Main script if it exists
                if LocalPlayer.Character then
                    local Main = LocalPlayer.Character:FindFirstChild("Main")
                    if Main then
                        Main.Enabled = true
                        Main.Disabled = false
                    end
                end
            end
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
        -- Clean up any existing connections first
        if rlglModule._CleanupFunction then
            rlglModule._CleanupFunction()
            rlglModule._CleanupFunction = nil
        end

        if state then
            -- Show notification about executor compatibility
            WindUI:Notify({
                Title = "RLGL Godmode", 
                Content = "If godmode RLGL doesn't work, your executor is bad",
                Duration = 5
            })

            if not hookmetamethod then
                return
            end

            -- Initialize module state
            rlglModule._IsGreenLight = true
            rlglModule._LastRootPartCFrame = nil

            -- Function to update light state and player position
            local function updateLightState(EffectsData)
                if EffectsData.EffectName == "TrafficLight" then
                    rlglModule._IsGreenLight = EffectsData.GreenLight == true
                    
                    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rlglModule._LastRootPartCFrame = rootPart.CFrame
                    end
                end
            end

            -- Connect to light changes
            rlglModule._Connection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(updateLightState)

            -- Hook __namecall to prevent movement during red light
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

            -- Store cleanup function
            rlglModule._CleanupFunction = function()
                -- Disconnect light state listener
                if rlglModule._Connection then
                    rlglModule._Connection:Disconnect()
                    rlglModule._Connection = nil
                end
                
                -- Restore original __namecall
                if rawmt and rlglModule._OriginalNamecall then
                    setreadonly(rawmt, false)
                    rawmt.__namecall = rlglModule._OriginalNamecall
                    setreadonly(rawmt, true)
                    rlglModule._OriginalNamecall = nil
                end
            end

            -- Initial state check
            local TrafficLightImage = LocalPlayer.PlayerGui:FindFirstChild("ImpactFrames") and
                LocalPlayer.PlayerGui.ImpactFrames:FindFirstChild("TrafficLightEmpty")
            if TrafficLightImage and ReplicatedStorage:FindFirstChild("Effects") then
                local lights = ReplicatedStorage.Effects:FindFirstChild("Images")
                if lights and lights:FindFirstChild("TrafficLights") and lights.TrafficLights:FindFirstChild("GreenLight") then
                    rlglModule._IsGreenLight = TrafficLightImage.Image == lights.TrafficLights.GreenLight.Image
                end
            end

            -- Initial position capture
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                rlglModule._LastRootPartCFrame = root.CFrame
            end
        end
    end
})

Main:Toggle({
    Title = "Help Injured",
    Desc = "Automatically helps downed players in RLGL",
    Value = false,
    Callback = function(state)
        if state then
            -- Create a table to track recently helped players
            getgenv().recentlyHelpedPlayers = {}
            local HELP_COOLDOWN = 30 -- seconds before helping same player again
            local FINISH_POSITION = CFrame.new(-46, 1024, 110) -- Same as Complete RLGL button
            
            -- Define the polygon area where helping is allowed
            local polygon = {
                Vector2.new(-52, -515),
                Vector2.new(115, -515),
                Vector2.new(115, 84),
                Vector2.new(-216, 84)
            }
            
            local function isPointInPolygon(point, poly)
                local inside = false
                local j = #poly
                for i = 1, #poly do
                    local xi, zi = poly[i].X, poly[i].Y
                    local xj, zj = poly[j].X, poly[j].Y
                    if ((zi > point.Y) ~= (zj > point.Y)) and
                        (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 1e-9) + xi) then
                        inside = not inside
                    end
                    j = i
                end
                return inside
            end

            -- Function to find an injured player
            local function FindInjuredPlayer()
                for _, plr in pairs(Players:GetPlayers()) do
                    -- Skip conditions
                    if plr == LocalPlayer then continue end
                    if not plr.Character then continue end
                    if not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
                    if plr:GetAttribute("IsDead") then continue end
                    if plr.Character:GetAttribute("SafeRedLightGreenLight") then continue end -- Already safe
                    if plr.Character:FindFirstChild("IsBeingHeld") then continue end
                    if getgenv().recentlyHelpedPlayers[plr.UserId] then continue end -- Recently helped

                    -- Check if player is within the polygon area
                    local playerPos = plr.Character.HumanoidRootPart.Position
                    local playerPos2D = Vector2.new(playerPos.X, playerPos.Z)
                    if not isPointInPolygon(playerPos2D, polygon) then
                        continue -- Player is outside the polygon
                    end

                    -- Check for carry prompt
                    local CarryPrompt = plr.Character.HumanoidRootPart:FindFirstChild("CarryPrompt")
                    if CarryPrompt then
                        return plr, CarryPrompt
                    end
                end
                return nil
            end

            -- Main helper function
            local function HelpInjuredPlayer()
                local injuredPlayer, carryPrompt = FindInjuredPlayer()
                if not injuredPlayer then
                    return false
                end

                -- Store helped player
                getgenv().recentlyHelpedPlayers[injuredPlayer.UserId] = os.time()
                
                -- Temporarily disable AntiFling if enabled
                local wasAntiFlingEnabled = false
                if antiFlingConnection then
                    wasAntiFlingEnabled = true
                    antiFlingConnection:Disconnect()
                    antiFlingConnection = nil
                end

                -- Execute help sequence
                local success = true
                pcall(function()
                    -- Teleport to player
                    LocalPlayer.Character:PivotTo(injuredPlayer.Character:GetPrimaryPartCFrame())
                    task.wait(0.2)
                    
                    -- Pick them up
                    carryPrompt.HoldDuration = 0  -- Set hold time to zero
                    fireproximityprompt(carryPrompt)
                    task.wait(0.5)
                    
                    -- Teleport to finish line (same as Complete RLGL button)
                    LocalPlayer.Character:PivotTo(FINISH_POSITION)
                    task.wait(0.5)
                    
                    -- Release player
                    game:GetService("ReplicatedStorage").Remotes.ClickedButton:FireServer({tryingtoleave = true})
                end)

                -- Restore AntiFling if it was enabled
                if wasAntiFlingEnabled then
                    antiFlingConnection = RunService.Heartbeat:Connect(function()
                        pcall(function()
                            local character = LocalPlayer.Character
                            if character then
                                local hrp = character:FindFirstChild("HumanoidRootPart")
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                
                                if hrp and humanoid then
                                    local currentVel = hrp.Velocity
                                    hrp.Velocity = Vector3.new(currentVel.X * 0.5, currentVel.Y, currentVel.Z * 0.5)
                                    hrp.RotVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end)
                    end)
                end

                return success
            end

            -- Cleanup old entries periodically
            task.spawn(function()
                while task.wait(10) and getgenv().helpInjuredEnabled do
                    local currentTime = os.time()
                    for userId, helpTime in pairs(getgenv().recentlyHelpedPlayers) do
                        if currentTime - helpTime > HELP_COOLDOWN then
                            getgenv().recentlyHelpedPlayers[userId] = nil
                        end
                    end
                end
            end)

            -- Create the main loop
            getgenv().helpInjuredEnabled = true
            getgenv().helpInjuredLoop = task.spawn(function()
                while task.wait(1) and getgenv().helpInjuredEnabled do
                    HelpInjuredPlayer()
                end
            end)
        else
            -- Clean up
            getgenv().helpInjuredEnabled = false
            if getgenv().helpInjuredLoop then
                task.cancel(getgenv().helpInjuredLoop)
                getgenv().helpInjuredLoop = nil
            end
            getgenv().recentlyHelpedPlayers = nil
        end
    end
})

Main:Toggle({
    Title = "Bring Injured to Start",
    Desc = "Automatically brings injured players to start position",
    Value = false,
    Callback = function(state)
        if state then
            -- Create a table to track recently helped players
            getgenv().recentlyHelpedPlayers = {}
            local HELP_COOLDOWN = 30 -- seconds before helping same player again
            
            -- Updated correct finish position for current game version
            local START_POSITION = CFrame.new(66.0978928, 1023.05371, -571.360046)
            
            -- Define the polygon area where helping is allowed (updated coordinates)
            local polygon = {
                Vector2.new(-100, -600),  -- Adjusted coordinates
                Vector2.new(150, -600),
                Vector2.new(150, 100),
                Vector2.new(-250, 100)
            }
            
            local function isPointInPolygon(point, poly)
                local inside = false
                local j = #poly
                for i = 1, #poly do
                    local xi, zi = poly[i].X, poly[i].Y
                    local xj, zj = poly[j].X, poly[j].Y
                    if ((zi > point.Y) ~= (zj > point.Y)) and
                        (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 1e-9) + xi) then
                        inside = not inside
                    end
                    j = i
                end
                return inside
            end

            -- Function to find an injured player
            local function FindInjuredPlayer()
                for _, plr in pairs(Players:GetPlayers()) do
                    -- Skip conditions
                    if plr == LocalPlayer then continue end
                    if not plr.Character then continue end
                    if not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
                    if plr:GetAttribute("IsDead") then continue end
                    if plr.Character:GetAttribute("SafeRedLightGreenLight") then continue end -- Already safe
                    if plr.Character:FindFirstChild("IsBeingHeld") then continue end
                    if getgenv().recentlyHelpedPlayers[plr.UserId] then continue end -- Recently helped

                    -- Check if player is within the polygon area
                    local playerPos = plr.Character.HumanoidRootPart.Position
                    local playerPos2D = Vector2.new(playerPos.X, playerPos.Z)
                    if not isPointInPolygon(playerPos2D, polygon) then
                        continue -- Player is outside the polygon
                    end

                    -- Check for carry prompt
                    local CarryPrompt = plr.Character.HumanoidRootPart:FindFirstChild("CarryPrompt")
                    if CarryPrompt then
                        return plr, CarryPrompt
                    end
                end
                return nil
            end

            -- Main helper function
            local function HelpInjuredPlayer()
                local injuredPlayer, carryPrompt = FindInjuredPlayer()
                if not injuredPlayer then
                    return false
                end

                -- Store helped player
                getgenv().recentlyHelpedPlayers[injuredPlayer.UserId] = os.time()
                
                -- Temporarily disable AntiFling if enabled
                local wasAntiFlingEnabled = false
                if antiFlingConnection then
                    wasAntiFlingEnabled = true
                    antiFlingConnection:Disconnect()
                    antiFlingConnection = nil
                end

                -- Execute help sequence
                local success = true
                pcall(function()
                    -- Teleport to player
                    LocalPlayer.Character:PivotTo(injuredPlayer.Character:GetPrimaryPartCFrame())
                    task.wait(0.2)
                    
                    -- Pick them up
                    carryPrompt.HoldDuration = 0  -- Set hold time to zero
                    fireproximityprompt(carryPrompt)
                    task.wait(0.5)
                    
                    -- Teleport to finish line (updated position)
                    LocalPlayer.Character:PivotTo(START_POSITION)
                    task.wait(0.5)
                    
                    -- Release player
                    game:GetService("ReplicatedStorage").Remotes.ClickedButton:FireServer({tryingtoleave = true})
                end)

                -- Restore AntiFling if it was enabled
                if wasAntiFlingEnabled then
                    antiFlingConnection = RunService.Heartbeat:Connect(function()
                        pcall(function()
                            local character = LocalPlayer.Character
                            if character then
                                local hrp = character:FindFirstChild("HumanoidRootPart")
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                
                                if hrp and humanoid then
                                    local currentVel = hrp.Velocity
                                    hrp.Velocity = Vector3.new(currentVel.X * 0.5, currentVel.Y, currentVel.Z * 0.5)
                                    hrp.RotVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end)
                    end)
                end

                return success
            end

            -- Cleanup old entries periodically
            task.spawn(function()
                while task.wait(10) and getgenv().helpInjuredEnabled do
                    local currentTime = os.time()
                    for userId, helpTime in pairs(getgenv().recentlyHelpedPlayers) do
                        if currentTime - helpTime > HELP_COOLDOWN then
                            getgenv().recentlyHelpedPlayers[userId] = nil
                        end
                    end
                end
            end)

            -- Create the main loop
            getgenv().helpInjuredEnabled = true
            getgenv().helpInjuredLoop = task.spawn(function()
                while task.wait(1) and getgenv().helpInjuredEnabled do
                    HelpInjuredPlayer()
                end
            end)
        else
            -- Clean up
            getgenv().helpInjuredEnabled = false
            if getgenv().helpInjuredLoop then
                task.cancel(getgenv().helpInjuredLoop)
                getgenv().helpInjuredLoop = nil
            end
            getgenv().recentlyHelpedPlayers = nil
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

-- Add this to the Glass Bridge section in the Main tab
Main:Toggle({
    Title = "Don't Fall On Wrong Glasses",
    Desc = "You dont fall on wrong glasses",
    Value = false,
    Callback = function(state)
        local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not glassHolder then return end

        if state then
            -- Anchor all glass tiles
            for _, tilePair in pairs(glassHolder:GetChildren()) do
                for _, tileModel in pairs(tilePair:GetChildren()) do
                    if tileModel:IsA("Model") then
                        for _, part in pairs(tileModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                                part.CanCollide = true
                                -- Remove any break scripts
                                for _, script in pairs(part:GetDescendants()) do
                                    if script:IsA("Script") or script:IsA("LocalScript") then
                                        script:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Monitor for new glass tiles
            getgenv().glassAnchorConnection = glassHolder.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("BasePart") then
                    descendant.Anchored = true
                    descendant.CanCollide = true
                end
            end)
        else
            -- Unanchor all glass tiles
            for _, tilePair in pairs(glassHolder:GetChildren()) do
                for _, tileModel in pairs(tilePair:GetChildren()) do
                    if tileModel:IsA("Model") then
                        for _, part in pairs(tileModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                end
            end

            -- Clean up connection
            if getgenv().glassAnchorConnection then
                getgenv().glassAnchorConnection:Disconnect()
                getgenv().glassAnchorConnection = nil
            end
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


-- Dalgona Crack Immunity System
local dalgonaImmuneEnabled = false
local originalDalgonaHook = nil
local dalgonaRemoteName = "DALGONATEMPREMPTE"  -- Remote name for Dalgona game
local dalgonaCompletionConnection = nil

local function AutoCompleteDalgona()
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

local function SetDalgonaImmune(enabled)
    if enabled then
        -- Check if hookmetamethod is available
        if not hookmetamethod then
            WindUI:Notify({
                Title = "Error", 
                Desc = "Your executor doesn't support hookmetamethod!", 
                Duration = 5
            })
            return false
        end

        -- Hook to block crack attempts
        originalDalgonaHook = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            -- Block crack attempts silently
            if tostring(self) == dalgonaRemoteName and method == "FireServer" then
                if type(args[1]) == "table" and args[1].CrackAmount ~= nil then
                    WindUI:Notify({
                        Title = "Dalgona", 
                        Desc = "Prevented your cookie from cracking!", 
                        Duration = 3
                    })
                    return nil  -- Block the crack
                end
            end

            return originalDalgonaHook(self, ...)
        end)

        -- Auto-completion system
        dalgonaCompletionConnection = workspace.ChildAdded:Connect(function(child)
            if child.Name == "DalgonaGame" or child.Name == "Effects" then
                task.wait(0.5)  -- Wait for game to initialize
                AutoCompleteDalgona()
            end
        end)

        -- Also check existing instances
        for _, child in pairs(workspace:GetChildren()) do
            if child.Name == "DalgonaGame" or child.Name == "Effects" then
                AutoCompleteDalgona()
                break
            end
        end

        
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

-- Add this to your Dalgona section in the Main tab
Main:Toggle({
    Title = "Crack Immunity (Re-Enable if not work)",
    Desc = "Prevents your Dalgona from cracking and auto-completes",
    Value = false,
    Callback = function(state)
        dalgonaImmuneEnabled = state
        SetDalgonaImmune(state)
    end
})

-- Auto-reapply on character respawn
LocalPlayer.CharacterAdded:Connect(function()
    if dalgonaImmuneEnabled then
        task.wait(1)  -- Wait for character to load
        SetDalgonaImmune(true)
    end
end)

-- Auto-reapply on character respawn
LocalPlayer.CharacterAdded:Connect(function()
    if dalgonaImmuneEnabled then
        task.wait(1)
        setDalgonaImmune(true)
    end
end)

-- Add this to the Jump Rope section in the Main tab
Main:Section({Title = "Jump Rope"})
Main:Divider()

-- Complete Jump Rope Button
Main:Button({
    Title = "Complete Jump Rope",
    Desc = "Teleports to finish line position",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = Vector3.new(
                723.2041015625, 
                197.14407348632812 + 3,
                922.08349609375
            )
            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
    end
})

Main:Toggle({
    Title = "Auto Perfect Jump [BETA]",
    Desc = "Automatically jumps when rope is close",
    Value = false,
    Callback = function(state)
        autoPerfectJumpEnabled = state
        if state then
            autoPerfectJumpConnection = RunService.Heartbeat:Connect(function()
                AutoPerfectJumpRope()
            end)
        else
            if autoPerfectJumpConnection then
                autoPerfectJumpConnection:Disconnect()
                autoPerfectJumpConnection = nil
            end
            getgenv().lastJumpTime = nil
        end
    end
})

-- Anti Fall Toggle with the new function
local antiFallEnabled = false
local antiFallCleanup

Main:Toggle({
    Title = "Anti Fall [BETA]",
    Desc = "Prevents falling during jump rope",
    Value = false,
    Callback = function(state)
        antiFallEnabled = state
        if state then
            antiFallCleanup = AntiFallJumpRope()
        else
            if antiFallCleanup then
                antiFallCleanup()
                antiFallCleanup = nil
            end
        end
    end
})

-- Auto-reconnect on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1) -- Wait for character to load
    
    if autoPerfectJumpEnabled then
        autoPerfectJumpCleanup = AutoPerfectJumpRope()
    end
    
    if antiFallEnabled then
        antiFallCleanup = AntiFallJumpRope()
    end
end)

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

-- Optimized Hider Kill Aura (Uses IsHider Attribute)
local hiderKillauraEnabled = false
local hiderKillauraLoop = nil
local hiderKillauraSpeed = 0.01 -- Adjust for faster/slower teleportation

local function getKnife()
    -- Check character first
    local knife = LocalPlayer.Character:FindFirstChild("Knife")
    if knife then return knife end
    
    -- Check backpack as fallback (but prioritize equipped)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        knife = backpack:FindFirstChild("Knife")
        if knife then return knife end
    end
    
    return nil
end

local function attackHider(knife, targetCharacter)
    -- Auto-equip if needed
    if knife.Parent ~= LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:EquipTool(knife)
    end
    
    -- Simulate M1 click
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- Fire attack remote
    local args = {"UsingMoveCustom", knife, nil, {Clicked = true}}
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.UsedTool:FireServer(unpack(args))
    end)
end

local function EnhancedHiderKillaura(enabled)
    if enabled then
        hiderKillauraLoop = task.spawn(function()
            while task.wait(hiderKillauraSpeed) do
                local knife = getKnife()
                if not knife then continue end
                
                -- Find closest living hider using IsHider attribute
                local closestHider, closestDistance = nil, math.huge
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                
                for _, player in ipairs(Players:GetPlayers()) do
                    -- Check IsHider attribute instead of name
                    if player ~= LocalPlayer and player:GetAttribute("IsHider") == true and player.Character then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid and humanoid.Health > 0 and targetRoot then
                            local distance = (targetRoot.Position - myRoot.Position).Magnitude
                            if distance < closestDistance then
                                closestHider = player
                                closestDistance = distance
                            end
                        end
                    end
                end
                
                -- Attack if valid hider found
                if closestHider and closestHider.Character then
                    local targetRoot = closestHider.Character.HumanoidRootPart
                    
                    -- Calculate position 1 stud behind hider
                    local behindOffset = targetRoot.CFrame.LookVector * -0.4
                    local targetCFrame = CFrame.new(targetRoot.Position + behindOffset, targetRoot.Position)
                    
                    -- Instant teleport (no tweening)
                    LocalPlayer.Character:PivotTo(targetCFrame)
                    
                    -- Continuous attack
                    attackHider(knife, closestHider.Character)
                end
            end
        end)
    else
        if hiderKillauraLoop then
            task.cancel(hiderKillauraLoop)
            hiderKillauraLoop = nil
        end
    end
end

Main:Toggle({
    Title = "Hider Killaura",
    Desc = "Teleports behind and continuously attacks nearest hider",
    Value = false,
    Callback = function(state)
        hiderKillauraEnabled = state
        EnhancedHiderKillaura(state)
        
        -- Reconnect on respawn
        if state then
            LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1) -- Wait for character to load
                if hiderKillauraEnabled then EnhancedHiderKillaura(true) end
            end)
        end
    end
})

-- Add this to the Hide and Seek section in the Main tab
Main:Button({
    Title = "Teleport To Hider",
    Desc = "Teleports behind the nearest hider",
    Callback = function()
        if not LocalPlayer.Character then 
            return
        end
        
        local hider = nil
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player:GetAttribute("IsHider") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        hider = player.Character
                        break
                    end
                end
            end
        end
        
        if not hider then
            return
        end
        
        -- Get positions
        local hiderRoot = hider:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not hiderRoot or not myRoot then
            return
        end
        
        -- Calculate position behind hider
        local hiderCFrame = hiderRoot.CFrame
        local behindOffset = hiderCFrame.LookVector * -3  -- 3 studs behind
        local targetPosition = hiderCFrame.Position + behindOffset
        
        -- Teleport to hider
        LocalPlayer.Character:PivotTo(CFrame.new(targetPosition, hiderCFrame.Position))
        
    end
})

Main:Keybind({
    Title = "Teleport To Hider Keybind",
    Desc = "Keybind to teleport to nearest hider",
    Value = "H",
    Callback = function(v)
        local keyCode = Enum.KeyCode[v]
        
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == keyCode then
                if not LocalPlayer.Character then return end
                
                local hider = nil
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player:GetAttribute("IsHider") then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                hider = player.Character
                                break
                            end
                        end
                    end
                end
                
                if hider and hider:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hiderCFrame = hider.HumanoidRootPart.CFrame
                    local behindOffset = hiderCFrame.LookVector * -3
                    LocalPlayer.Character:PivotTo(CFrame.new(hiderCFrame.Position + behindOffset, hiderCFrame.Position))
                end
            end
        end)
    end
})

-- Tug of War Section
Main:Section({Title = "Tug of War"})
Main:Divider()

local autoPullEnabled = false
local autoPullCleanup
local autoPullMode = "Blatant" -- Default mode

function AutoPullRope(perfectPull)
    if autoPullMode == "Blatant" then
        -- Original blatant mode code
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RunService = game:GetService("RunService")
        local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable")
        
        -- Show notification when activated
        WindUI:Notify({
            Title = "Auto Pull Rope",
            Content = "Pulling Rope Automatically You will see the percentage fly for your team you will carry",
            Duration = 5,
        })

        local connection
        local function pull()
            -- Faster pulling with optimized args
            local args = perfectPull and {{GameQTE = true, Perfect = true}} or {{Failed = true}}
            Remote:FireServer(unpack(args))
            
            -- Additional fire for faster effect (adjust delay as needed)
            task.wait(0.03)
            Remote:FireServer(unpack(args))
        end

        -- Use RenderStepped for maximum speed
        connection = RunService.RenderStepped:Connect(pull)
        
        -- Cleanup function
        return function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    else
        -- New legit mode code
        local connection
        local function checkAndPull()
            local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
            if not playerGui:FindFirstChild("QTEEvents") then return end
            
            local progress = playerGui.QTEEvents.Progress
            if not progress or not progress:FindFirstChild("GoalDot") or not progress:FindFirstChild("CrossHair") then return end
            
            local goalDot = progress.GoalDot
            local crossHair = progress.CrossHair
            
            -- Check if crosshair rotation matches goal dot rotation
            if math.abs(crossHair.AbsoluteRotation - goalDot.AbsoluteRotation) < 5 then -- Small tolerance
                -- Simulate mouse click
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end

        connection = RunService.RenderStepped:Connect(checkAndPull)
        
        return function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
end

-- Add the mode dropdown
Main:Dropdown({
    Title = "Pull Mode",
    Values = {"Blatant", "Legit"},
    Default = "Blatant",
    Callback = function(selected)
        autoPullMode = selected
        -- If auto pull is already running, restart it with new mode
        if autoPullEnabled and autoPullCleanup then
            autoPullCleanup()
            autoPullCleanup = AutoPullRope(true)
        end
    end
})

Main:Toggle({
    Title = "Auto Pull Rope",
    Desc = "Automatically pulls the rope with perfect timing",
    Value = false,
    Callback = function(state)
        autoPullEnabled = state
        if state then
            autoPullCleanup = AutoPullRope(true) -- true for perfect pulls
        else
            if autoPullCleanup then
                autoPullCleanup()
                autoPullCleanup = nil
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

-- Enhanced Kill Aura with Loop Teleport
local killAuraEnabled = false
local killAuraLoop = nil
local killAuraSpeed = 0.01 -- Adjust for faster/slower teleportation (lower = faster)

local function getEquippedWeapon()
    -- Check character first
    for _, weaponName in pairs({"Knife", "Bottle", "Fork", "Power Hold"}) do
        local weapon = LocalPlayer.Character:FindFirstChild(weaponName)
        if weapon then return weapon end
    end
    
    -- Check backpack if not equipped
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, weaponName in pairs({"Knife", "Bottle", "Fork", "Power Hold"}) do
            local weapon = backpack:FindFirstChild(weaponName)
            if weapon then return weapon end
        end
    end
    
    return nil
end

local function attackTarget(weapon, target)
    -- Auto-equip if needed
    if weapon.Parent ~= LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:EquipTool(weapon)
    end
    
    -- Simulate M1 click
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- Fire attack remote
    local args = {"UsingMoveCustom", weapon, nil, {Clicked = true}}
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.UsedTool:FireServer(unpack(args))
    end)
end

local function EnhancedKillAura(enabled)
    if enabled then
        killAuraLoop = task.spawn(function()
            while task.wait(killAuraSpeed) do
                local weapon = getEquippedWeapon()
                if not weapon then continue end
                
                -- Find closest living player
                local closestPlayer, closestDistance = nil, math.huge
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid and humanoid.Health > 0 and targetRoot then
                            local distance = (targetRoot.Position - myRoot.Position).Magnitude
                            if distance < closestDistance then
                                closestPlayer = player
                                closestDistance = distance
                            end
                        end
                    end
                end
                
                -- Attack if valid target
                if closestPlayer and closestPlayer.Character then
                    local targetRoot = closestPlayer.Character.HumanoidRootPart
                    
                    -- Calculate position 1 stud behind target
                    local behindOffset = targetRoot.CFrame.LookVector * -0.4
                    local targetCFrame = CFrame.new(targetRoot.Position + behindOffset, targetRoot.Position)
                    
                    -- Instant teleport (no tweening)
                    LocalPlayer.Character:PivotTo(targetCFrame)
                    
                    -- Continuous attack
                    attackTarget(weapon, closestPlayer.Character)
                end
            end
        end)
    else
        if killAuraLoop then
            task.cancel(killAuraLoop)
            killAuraLoop = nil
        end
    end
end

Combat:Toggle({
    Title = "Kill Aura",
    Desc = "Teleports behind and continuously attacks nearest player",
    Value = false,
    Callback = function(state)
        killAuraEnabled = state
        EnhancedKillAura(state)
        
        -- Reconnect on respawn
        if state then
            LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1)
                if killAuraEnabled then EnhancedKillAura(true) end
            end)
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

-- Add this to the Combat tab section
Combat:Section({Title = "Player"})
Combat:Divider()

-- Player Hitbox variables
local playerHitboxEnabled = false
local playerHitboxSize = 5 -- Default size multiplier
local playerHitboxTransparency = 0.7
local playerHitboxColor = Color3.fromRGB(255, 0, 255) -- Purple color for players
local playerHitboxConnections = {}
local playerHitboxParts = {}

-- Function to create/update hitbox for a player
local function updatePlayerHitbox(player)
    if not player:IsA("Model") or player == LocalPlayer.Character then return end
    local hrp = player:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Clear existing hitbox if any
    if playerHitboxParts[player] then
        playerHitboxParts[player]:Destroy()
        playerHitboxParts[player] = nil
    end
    
    if not playerHitboxEnabled then return end
    
    -- Create a new invisible part that will act as the hitbox
    local hitbox = Instance.new("Part")
    hitbox.Name = "PlayerExpandedHitbox"
    hitbox.Size = Vector3.new(playerHitboxSize, playerHitboxSize, playerHitboxSize)
    hitbox.Transparency = playerHitboxTransparency
    hitbox.Color = playerHitboxColor
    hitbox.Material = Enum.Material.ForceField
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.CFrame = hrp.CFrame
    
    -- Weld to the player's HRP
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = hitbox
    weld.Parent = hitbox
    
    hitbox.Parent = player
    playerHitboxParts[player] = hitbox
    
    -- Make the original HRP invisible and non-collidable
    hrp.Transparency = 1
    hrp.CanCollide = false
    
    -- Cleanup when player is removed
    playerHitboxConnections[player] = player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if playerHitboxParts[player] then
                playerHitboxParts[player]:Destroy()
                playerHitboxParts[player] = nil
            end
            if playerHitboxConnections[player] then
                playerHitboxConnections[player]:Disconnect()
                playerHitboxConnections[player] = nil
            end
            -- Restore original HRP properties if player still exists
            if player.Parent then
                if hrp then
                    hrp.Transparency = 0
                    hrp.CanCollide = true
                end
            end
        end
    end)
end

-- Function to setup hitboxes for all players
local function setupPlayerHitboxes()
    -- Clear existing hitboxes
    for player, hitbox in pairs(playerHitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
        -- Restore original HRP properties
        if player and player.Parent then
            local hrp = player:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Transparency = 0
                hrp.CanCollide = true
            end
        end
    end
    table.clear(playerHitboxParts)
    
    for player, conn in pairs(playerHitboxConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(playerHitboxConnections)

    if not playerHitboxEnabled then return end
    
    -- Find all existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            updatePlayerHitbox(player.Character)
        end
    end
    
    -- Listen for new players and their characters
    playerHitboxConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            updatePlayerHitbox(character)
        end)
    end)
    
    -- Also track existing players' character changes
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            playerHitboxConnections[player] = player.CharacterAdded:Connect(function(character)
                updatePlayerHitbox(character)
            end)
        end
    end
end

-- Main toggle for player hitboxes
Combat:Toggle({
    Title = "Player Hitbox Expander",
    Desc = "Makes players easier to hit by expanding their hitbox",
    Value = false,
    Callback = function(state)
        playerHitboxEnabled = state
        setupPlayerHitboxes()
    end
})

Combat:Slider({
    Title = "Player Hitbox Size",
    Value = {
        Min = 1,
        Max = 20,
        Default = 5,
    },
    Callback = function(value)
        playerHitboxSize = value
        if playerHitboxEnabled then
            for player, hitbox in pairs(playerHitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Size = Vector3.new(playerHitboxSize, playerHitboxSize, playerHitboxSize)
                end
            end
        end
    end
})

Combat:Slider({
    Title = "Player Hitbox Transparency",
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.7,
    },
    Callback = function(value)
        playerHitboxTransparency = value
        if playerHitboxEnabled then
            for player, hitbox in pairs(playerHitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Transparency = playerHitboxTransparency
                end
            end
        end
    end
})

-- Color picker for player hitboxes
Combat:Colorpicker({
    Title = "Player Hitbox Color",
    Default = Color3.fromRGB(255, 0, 255), -- Purple
    Callback = function(color)
        playerHitboxColor = color
        if playerHitboxEnabled then
            -- Update all existing hitboxes
            for player, hitbox in pairs(playerHitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Color = playerHitboxColor
                end
            end
        end
    end
})

-- Auto-update when character respawns
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if playerHitboxEnabled then
        task.wait(1) -- Wait for character to load
        setupPlayerHitboxes()
    end
end)

Combat:Section({Title = "Guard"})
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
-- Add this to the Utility tab section
Utility:Section({Title = "Emotes"})
Utility:Divider()

-- Initialize emote variables
local emoteList = {}
local currentEmoteTrack = nil
local selectedEmote = nil -- Track the selected emote

-- Function to load emotes
local function loadEmotes()
    table.clear(emoteList)
    
    local Animations = ReplicatedStorage:WaitForChild("Animations", 10)
    if not Animations then return end
    
    local Emotes = Animations:WaitForChild("Emotes", 10)
    if not Emotes then return end

    for _, anim in pairs(Emotes:GetChildren()) do
        if anim:IsA("Animation") and anim.AnimationId ~= "" then
            emoteList[anim.Name] = anim.AnimationId
        end
    end
end

-- Function to play emote
local function playEmote(emoteName)
    -- Get character and humanoid
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Stop current emote if playing
    if currentEmoteTrack then
        currentEmoteTrack:Stop()
        currentEmoteTrack = nil
    end

    -- Load emote animation
    local animId = emoteList[emoteName]
    if not animId then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId

    -- Play animation
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    
    -- Store reference
    currentEmoteTrack = track
end

-- Function to stop emote
local function stopEmote()
    if currentEmoteTrack then
        currentEmoteTrack:Stop()
        currentEmoteTrack = nil
    end
end

-- Create dropdown for emotes
local emoteDropdown = Utility:Dropdown({
    Title = "Emotes",
    Values = {}, -- Will be populated after loading
    Callback = function(selected)
        selectedEmote = selected -- Store the selected emote
    end
})

-- Create play and stop buttons
Utility:Button({
    Title = "Play Emote",
    Callback = function()
        if selectedEmote then
            playEmote(selectedEmote)
        end
    end
})

Utility:Button({
    Title = "Stop Emote",
    Callback = stopEmote
})

-- Initialize emotes on game load
task.spawn(function()
    loadEmotes()
    
    -- Update dropdown with loaded emotes
    local emoteNames = {}
    for name, _ in pairs(emoteList) do
        table.insert(emoteNames, name)
    end
    table.sort(emoteNames)
    emoteDropdown:Refresh(emoteNames, true)
    
    -- Update when new emotes are added
    local Animations = ReplicatedStorage:WaitForChild("Animations", 10)
    if Animations then
        local Emotes = Animations:WaitForChild("Emotes", 10)
        if Emotes then
            Emotes.ChildAdded:Connect(function()
                task.wait()
                loadEmotes()
                
                -- Update dropdown again
                local newEmoteNames = {}
                for name, _ in pairs(emoteList) do
                    table.insert(newEmoteNames, name)
                end
                table.sort(newEmoteNames)
                emoteDropdown:Refresh(newEmoteNames, true)
            end)
        end
    end
end)

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

local playerDropdown = Utility:Dropdown({
    Title = "Player To Go",
    Values = {}, -- Will be populated
    Callback = function(selected)
        -- Store the selected player
        getgenv().selectedPlayerToTeleport = selected
    end
})

local function updatePlayerDropdown()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    table.sort(playerNames)
    playerDropdown:Refresh(playerNames, true)
end

-- Initial update
updatePlayerDropdown()

-- Update when players join/leave
Players.PlayerAdded:Connect(function()
    task.wait() -- Small delay to ensure player is fully added
    updatePlayerDropdown()
end)

Players.PlayerRemoving:Connect(function()
    task.wait() -- Small delay to ensure player is fully removed
    updatePlayerDropdown()
end)

Utility:Button({
    Title = "Go to Player",
    Desc = "Teleports to the selected player",
    Callback = function()
        local selectedName = getgenv().selectedPlayerToTeleport
        if not selectedName then
            WindUI:Notify({Title = "Error", Content = "No player selected", Duration = 3})
            return
        end
        
        local targetPlayer = Players:FindFirstChild(selectedName)
        if not targetPlayer then
            WindUI:Notify({Title = "Error", Content = "Player not found", Duration = 3})
            return
        end
        
        local character = LocalPlayer.Character
        local targetCharacter = targetPlayer.Character
        if not character or not targetCharacter then
            WindUI:Notify({Title = "Error", Content = "Character not found", Duration = 3})
            return
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart or not targetRootPart then
            WindUI:Notify({Title = "Error", Content = "Root part not found!", Duration = 3})
            return
        end
        
        -- Calculate position 5 studs behind the target
        local targetCFrame = targetRootPart.CFrame
        local behindOffset = targetCFrame.LookVector * -2
        local targetPosition = targetCFrame.Position + behindOffset
        
        -- Teleport to the calculated position
        character:PivotTo(CFrame.new(targetPosition, targetCFrame.Position))
    end
})

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

Misc:Slider({
    Title = "Teleport to Safezone If Health Below",
    Desc = "Health threshold to auto teleport to safezone",
    Value = {
        Min = 1,
        Max = 100,
        Default = 30,
    },
    Callback = function(value)
        getgenv().safeZoneHealthThreshold = value
    end
})

Misc:Slider({
    Title = "Teleport Back If Health Above",
    Desc = "Health threshold to return from safezone",
    Value = {
        Min = 1,
        Max = 100,
        Default = 80,
    },
    Callback = function(value)
        getgenv().returnHealthThreshold = value
    end
})

local autoSafeZoneEnabled = false
local autoSafeZoneConnection = nil
local lastPositionBeforeSafeZone = nil

-- In the Auto Safezone section, replace the checkHealthAndTeleport function with this:
local function checkHealthAndTeleport()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Check if we're currently in safezone
    local inSafeZone = safeZoneFolder and safeZoneFolder.Parent ~= nil
    
    -- If health is low and not in safezone, teleport to safezone
    if not inSafeZone and humanoid.Health <= getgenv().safeZoneHealthThreshold then
        -- Store current position and rotation
        lastPositionBeforeSafeZone = rootPart.CFrame
        local safeZonePos = createSafeZone()
        character:PivotTo(CFrame.new(safeZonePos))
        WindUI:Notify({Title = "Auto Safezone", Content = "Teleported to safezone due to low health", Duration = 3})
    end
    
    -- If health is restored and in safezone, teleport back
    if inSafeZone and humanoid.Health >= getgenv().returnHealthThreshold and lastPositionBeforeSafeZone then
        -- Check if the original position is safe (not in void)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local rayOrigin = lastPositionBeforeSafeZone.Position + Vector3.new(0, 5, 0)
        local rayDirection = Vector3.new(0, -100, 0)
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if raycastResult then
            character:PivotTo(lastPositionBeforeSafeZone)
            if safeZoneFolder then
                safeZoneFolder:Destroy()
                safeZoneFolder = nil
            end
            WindUI:Notify({Title = "Auto Safezone", Content = "Returned from safezone - health restored", Duration = 3})
            lastPositionBeforeSafeZone = nil
        else
        end
    end
end

Misc:Toggle({
    Title = "Auto Safezone",
    Desc = "Automatically teleports to safezone when health is low",
    Value = false,
    Callback = function(state)
        autoSafeZoneEnabled = state
        if state then
            -- Initialize default values if not set
            if not getgenv().safeZoneHealthThreshold then
                getgenv().safeZoneHealthThreshold = 30
            end
            if not getgenv().returnHealthThreshold then
                getgenv().returnHealthThreshold = 80
            end
            
            autoSafeZoneConnection = RunService.Heartbeat:Connect(function()
                checkHealthAndTeleport()
            end)
            
            -- Also check when character respawns
            LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1) -- Wait for character to load
                if autoSafeZoneEnabled then
                    checkHealthAndTeleport()
                end
            end)
        else
            if autoSafeZoneConnection then
                autoSafeZoneConnection:Disconnect()
                autoSafeZoneConnection = nil
            end
        end
    end
})

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

-- Anti Ragdoll Toggle
local antiRagdollEnabled = false
local antiRagdollConnections = {}

local function BypassRagdoll()
    local character = LocalPlayer.Character
    if not character then return end

    -- Remove existing ragdolls/stuns
    for _, child in ipairs(character:GetChildren()) do
        if child.Name == "Ragdoll" then
            child:Destroy()
        elseif table.find({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}, child.Name) then
            child:Destroy()
        end
    end

    -- Prevent new ragdolls
    if antiRagdollConnections[character] then
        antiRagdollConnections[character]:Disconnect()
    end
    
    antiRagdollConnections[character] = character.ChildAdded:Connect(function(child)
        if child.Name == "Ragdoll" then
            task.spawn(function()
                child:Destroy()
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        elseif table.find({"Stun", "RotateDisabled"}, child.Name) then
            task.spawn(function() child:Destroy() end)
        end
    end)

    -- Fix joints and constraints
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        for _, obj in ipairs(humanoidRootPart:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
                obj:Destroy()
            end
        end
    end

    -- Repair motor6D joints
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        for _, jointName in ipairs({"Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"}) do
            local motor = torso:FindFirstChild(jointName)
            if motor and motor:IsA("Motor6D") and not motor.Part0 then
                motor.Part0 = torso
            end
        end
    end

    -- Remove bone constraints
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
            part.BoneCustom:Destroy()
        end
    end
end

Misc:Toggle({
    Title = "Anti Ragdoll",
    Desc = "Prevents ragdoll effects and stuns",
    Value = false,
    Callback = function(state)
        antiRagdollEnabled = state
        if state then
            -- Apply immediately
            BypassRagdoll()
            
            -- Reapply when character respawns
            antiRagdollConnections.charAdded = LocalPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- Wait for character to fully load
                BypassRagdoll()
            end)
        else
            -- Clean up connections
            for _, conn in pairs(antiRagdollConnections) do
                if conn then conn:Disconnect() end
            end
            antiRagdollConnections = {}
        end
    end
})

-- Speed Boost Toggle
local speedBoostEnabled = false
local originalSpeedValue = nil

Misc:Toggle({
    Title = "Speed Boost",
    Desc = "Boosts your speed",
    Value = false,
    Callback = function(state)
        speedBoostEnabled = state
        pcall(function()
            local boosts = game:GetService("Players").LocalPlayer:WaitForChild("Boosts")
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            
            if fasterSprint then
                if state then
                    -- Store original value if not already stored
                    if originalSpeedValue == nil then
                        originalSpeedValue = fasterSprint.Value
                    end
                    -- Apply boost
                    fasterSprint.Value = 10
                else
                    -- Restore original value if available
                    if originalSpeedValue then
                        fasterSprint.Value = originalSpeedValue
                    else
                        -- Default to reasonable value if original wasn't stored
                        fasterSprint.Value = 1
                    end
                end
            end
        end)
    end
})

-- Auto-reapply on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    if speedBoostEnabled then
        task.wait(1) -- Wait for character to load
        pcall(function()
            local boosts = game:GetService("Players").LocalPlayer:WaitForChild("Boosts")
            if boosts:FindFirstChild("Faster Sprint") then
                boosts["Faster Sprint"].Value = 10
            end
        end)
    end
end)

-- Jump Boost Slider
Misc:Slider({
    Title = "Jump Boost",
    Desc = "Boosts your jump power",
    Value = {
        Min = 50,
        Max = 100,
        Default = 50,
    },
    Callback = function(value)
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local character = workspace.Live:FindFirstChild(player.Name)
            if character then
                local jumpPower = character:FindFirstChild("JumpPowerAmount")
                if jumpPower then
                    jumpPower.Value = value
                end
            end
        end)
    end
})

-- Auto-reapply on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1) -- Wait for character to load
    local slider = Misc:FindFirstChild("Jump Boost")
    if slider then
        -- Reapply the current slider value
        slider.Callback(slider:GetValue())
    end
end)

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

-- Fixed Player ESP Function
local playerESPEnabled = false
local playerHighlights = {}
local playerConnections = {}

local function createPlayerESP(player)
    if not player or player == LocalPlayer then return end

    -- Clean up existing ESP if any
    if playerHighlights[player] then
        playerHighlights[player]:Destroy()
        playerHighlights[player] = nil
    end

    if not playerESPEnabled then return end

    local function setupESP(character)
        if not character or not character:FindFirstChild("Humanoid") then return end

        -- Create highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(0, 170, 255) -- Blue
        highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
        highlight.FillTransparency = 0.5
        highlight.Parent = character
        playerHighlights[player] = highlight

        -- Track character changes
        playerConnections[player] = character:GetPropertyChangedSignal("Parent"):Connect(function()
            if not character.Parent then
                highlight:Destroy()
                playerHighlights[player] = nil
            end
        end)
    end

    -- Setup ESP for current character
    if player.Character then
        setupESP(player.Character)
    end

    -- Track new characters
    playerConnections[player.."Added"] = player.CharacterAdded:Connect(setupESP)
end

local function updatePlayerESP()
    -- Clear existing ESP
    for player, highlight in pairs(playerHighlights) do
        if highlight then highlight:Destroy() end
    end
    table.clear(playerHighlights)

    for player, conn in pairs(playerConnections) do
        if conn then conn:Disconnect() end
    end
    table.clear(playerConnections)

    if not playerESPEnabled then return end

    -- Setup ESP for all players
    for _, player in ipairs(Players:GetPlayers()) do
        createPlayerESP(player)
    end

    -- Track new players
    playerConnections.playerAdded = Players.PlayerAdded:Connect(createPlayerESP)
end

Visual:Toggle({
    Title = "ESP Players",
    Desc = "Highlights all players in the game",
    Value = false,
    Callback = function(state)
        playerESPEnabled = state
        updatePlayerESP()
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

-- Enhanced Hider/Hunter ESP with Billboards
local HidersESPEnabled = false
local HuntersESPEnabled = false
local hiderHighlights = {}
local hunterHighlights = {}
local hiderBillboards = {}
local hunterBillboards = {}

-- Colors
local HIDER_COLOR = Color3.fromRGB(0, 170, 255)  -- Blue
local HUNTER_COLOR = Color3.fromRGB(255, 50, 50) -- Red

local function applyESP(player)
    if player == LocalPlayer then return end -- Skip self

    -- Cleanup old ESP
    if hiderHighlights[player] then
        hiderHighlights[player]:Destroy()
        hiderHighlights[player] = nil
    end
    if hunterHighlights[player] then
        hunterHighlights[player]:Destroy()
        hunterHighlights[player] = nil
    end
    if hiderBillboards[player] then
        hiderBillboards[player]:Destroy()
        hiderBillboards[player] = nil
    end
    if hunterBillboards[player] then
        hunterBillboards[player]:Destroy()
        hunterBillboards[player] = nil
    end

    local character = player.Character or player.CharacterAdded:Wait()
    if not character then return end

    -- Check attributes for role
    local isHider = player:GetAttribute("IsHider")
    local isHunter = player:GetAttribute("IsHunter")

    -- Create highlight if enabled
    if (isHider and HidersESPEnabled) or (isHunter and HuntersESPEnabled) then
        -- Create highlight
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = isHider and HIDER_COLOR or HUNTER_COLOR
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.Parent = character

        -- Create billboard label
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RoleLabel"
        billboard.Adornee = character:WaitForChild("Head") or character:WaitForChild("HumanoidRootPart")
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 1
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local label = Instance.new("TextLabel")
        label.Text = isHider and "HIDER" or "HUNTER"
        label.TextColor3 = isHider and HIDER_COLOR or HUNTER_COLOR
        label.TextSize = 14
        label.Font = Enum.Font.Oswald
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Parent = billboard
        billboard.Parent = character

        -- Store in correct tables
        if isHider then
            hiderHighlights[player] = highlight
            hiderBillboards[player] = billboard
        else
            hunterHighlights[player] = highlight
            hunterBillboards[player] = billboard
        end
    end

    -- Track attribute changes
    player:GetAttributeChangedSignal("IsHider"):Connect(function()
        applyESP(player) -- Refresh ESP when attribute changes
    end)
    player:GetAttributeChangedSignal("IsHunter"):Connect(function()
        applyESP(player) -- Refresh ESP when attribute changes
    end)
end

local function updateAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        applyESP(player)
    end
end

-- Initialize
Players.PlayerAdded:Connect(applyESP)
Players.PlayerRemoving:Connect(function(player)
    if hiderHighlights[player] then
        hiderHighlights[player]:Destroy()
        hiderHighlights[player] = nil
    end
    if hunterHighlights[player] then
        hunterHighlights[player]:Destroy()
        hunterHighlights[player] = nil
    end
    if hiderBillboards[player] then
        hiderBillboards[player]:Destroy()
        hiderBillboards[player] = nil
    end
    if hunterBillboards[player] then
        hunterBillboards[player]:Destroy()
        hunterBillboards[player] = nil
    end
end)

-- Add to Visual Tab
Visual:Toggle({
    Title = "ESP Hiders",
    Desc = "Highlights hiders",
    Value = false,
    Callback = function(state)
        HidersESPEnabled = state
        updateAllESP()
    end
})

Visual:Toggle({
    Title = "ESP Hunters",
    Desc = "Highlights hunters",
    Value = false,
    Callback = function(state)
        HuntersESPEnabled = state
        updateAllESP()
    end
})

-- Initial scan
for _, player in ipairs(Players:GetPlayers()) do
    applyESP(player)
end

-- Initial scan
for _, player in ipairs(Players:GetPlayers()) do
    applyESP(player)
end

-- Add Key ESP toggle with Billboard
local keyESPEnabled = false
local keyESPConnections = {}
local keyHighlights = {}
local keyBillboards = {}

local function KeyESP(keyModel)
    if not keyModel or not keyModel:IsA("Model") or not keyModel.PrimaryPart then
        return
    end

    -- Clean up existing ESP if any
    if keyHighlights[keyModel] then
        keyHighlights[keyModel]:Destroy()
        keyHighlights[keyModel] = nil
    end
    if keyBillboards[keyModel] then
        keyBillboards[keyModel]:Destroy()
        keyBillboards[keyModel] = nil
    end

    if not keyESPEnabled then return end

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

    -- Create Billboard with yellow text
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "KeyLabel"
    billboard.Adornee = keyModel.PrimaryPart
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 1
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local label = Instance.new("TextLabel")
    label.Text = "KEY"
    label.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow text
    label.TextSize = 14
    label.Font = Enum.Font.Oswald
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0) -- Black outline for better visibility
    label.Parent = billboard
    billboard.Parent = keyModel
    keyBillboards[keyModel] = billboard

    -- Clean up if the key is destroyed or removed
    local connection
    connection = keyModel.AncestryChanged:Connect(function(_, parent)
        if not parent or not keyModel:IsDescendantOf(game) then
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
            if connection then
                connection:Disconnect()
            end
            keyHighlights[keyModel] = nil
            keyBillboards[keyModel] = nil
        end
    end)

    keyESPConnections[keyModel] = connection
end

local function SetupKeyESP()
    -- Clear existing ESP
    for key, highlight in pairs(keyHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(keyHighlights)
    
    for key, billboard in pairs(keyBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(keyBillboards)
    
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
    Desc = "Highlights keys in Hide and Seek with billboard text",
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