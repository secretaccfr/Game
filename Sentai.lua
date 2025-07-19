-- Main Script with WindUI Library
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local toolArgs = {
    ["Shovel"] = {vector = Vector3.new(-0.23033662140369415, -0.6159319281578064, 0.7533742785453796)},
    ["Vampire Knife"] = {vector = Vector3.new(-0.28402915596961975, -0.4615946114063263, -0.8403915762901306)},
    ["Pickaxe"] = {vector = Vector3.new(-0.9183021187782288, -0.19974133372306824, 0.34179601073265076)},
    ["Tomahawk"] = {vector = Vector3.new(-0.9304590225219727, -0.19116199016571045, 0.3125746548175812)},
    ["Jade Sword"] = {vector = Vector3.new(0.279857337474823, -0.6576632261276245, -0.6993991136550903)},
    ["Cavalry Sword"] = {vector = Vector3.new(-0.9210650324821472, -0.18309099972248077, 0.3436812162399292)},
    ["Excalibur"] = {vector = Vector3.new(-0.9210650324821472, -0.18309099972248077, 0.3436812162399292)}
}
local MeleeActive = false
local SwingSpeed = 10
local SwingThread = nil
local OneHitSwingActive = false
local OneHitSwingThread = nil

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Tuff Guys | Dead Rails V1.5",
    Icon = "rbxassetid://130506306640152",
    IconThemed = true,
    Author = "Tuff Agsy",
    Folder = "Deadrailstuff",
    Size = UDim2.fromOffset(580, 380),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
})

Window:SetBackgroundImage("rbxassetid://130506306640152")
Window:SetBackgroundImageTransparency(0.8)
Window:DisableTopbarButtons({"Fullscreen"})

Window:EditOpenButton({
    Title = "Tuff Guys | Dead Rails V1.5",
    Icon = "train-front",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),   -- Green
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) -- White
}),
    Enabled = true,
    Draggable = true,
})

-- Add this configuration near your other auto-collect configurations
local AutoPickupMelees = {
    Enabled = false,
    Connection = nil
}

-- Item ESP Configuration
local ItemESP = {
    Enabled = false,
    Color = Color3.fromRGB(255, 170, 0),
    FillTransparency = 0.8,
    OutlineTransparency = 0,
    ShowName = true,
    ShowDistance = true
}

-- NPC Lock Configuration
local NPCLock = {
    Enabled = false,
    LastTarget = nil,
    ToggleLoop = nil
}

-- Unicorn ESP Configuration
local UnicornESP = {
    Enabled = false,
    HighlightColor = Color3.fromRGB(255, 105, 180),
    TextColor = Color3.fromRGB(255, 182, 193),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    ShowName = true,
    ShowDistance = true
}

-- Auto Collect MoneyBags Configuration
local AutoCollectMoneyBags = {
    Enabled = false,
    OriginalHoldDurations = {},
    Connections = {}
}

-- Auto Collect All Configuration
local AutoCollectAll = {
    Enabled = false,
    Connection = nil
}

-- Auto Pickup Snake Oil & Bandages Configuration
local AutoPickupSnakeOilBandages = {
    Enabled = false,
    Connection = nil
}

-- Instant Prompt Configuration
local InstantPrompt = {
    Enabled = false,
    Connection = nil
}

-- NoClip Configuration
local NoClip = {
    Enabled = false,
    Connection = nil
}

-- Anti Void Configuration
local AntiVoid = {
    Enabled = false,
    Connection = nil
}

-- Gun Aura Configuration
local GunAura = {
    Enabled = false,
    Connection = nil,
    REACH_DISTANCE = 250,
    SHOT_DELAY = 0.01,
    TARGET_PART = "Head",
    Mode = "Fast", -- "Fast" or "Normal"
    AntiLagTable = {} -- Stores valid targets
}

-- Fuel ESP Configuration
local FuelESP = {
    Enabled = false,
    HighlightColor = Color3.fromRGB(255, 165, 0), -- Orange color
    TextColor = Color3.fromRGB(255, 200, 100),
    FillTransparency = 0.7,
    OutlineTransparency = 0,
    ShowFuelAmount = true,
    ShowDistance = true
}

-- Train ESP Configuration
local TrainESP = {
    Enabled = false,
    HighlightColor = Color3.fromRGB(0, 170, 255), -- Blue color
    TextColor = Color3.fromRGB(200, 230, 255),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    ShowDistance = true,
    ShowTrainDistance = true,
    ShowTime = true
}

-- Auto Collect Guns Configuration
local AutoCollectGuns = {
    Enabled = false,
    Connection = nil,
    GunTypes = {
        ["Revolver"] = true, 
        ["Shotgun"] = true, 
        ["Rifle"] = true, 
        ["Navy Revolver"] = true, 
        ["Mauser C96"] = true, 
        ["Bolt Action Rifle"] = true, 
        ["Electrocutioner"] = true, 
        ["Sawed-Off Shotgun"] = true
    }
}

-- Auto Collect Bonds Configuration
local AutoCollectBonds = {
    Enabled = false,
    Connection = nil
}

-- Auto Collect Ammos Configuration
local AutoCollectAmmos = {
    Enabled = false,
    Connection = nil,
    AmmoTypes = {
        "RevolverAmmo",
        "Revolver Ammo",
        "Shotgun Shells",
        "ShotgunShells",
        "RifleAmmo",
        "Rifle Ammo"
    }
}

-- Safe Zones Configuration
local BASE_TELEPORTS = {
    ["Spawn"] = CFrame.new(56.6396217, 3.24999976, 29936.3516),
    ["10 KM"] = CFrame.new(- 160.576843, 2.99617577, 19913.252),
    ["20 KM"] = CFrame.new(- 556.92572, 2.98922157, 9956.79883),
    ["30 KM"] = CFrame.new(- 569.779663, 2.99999976, 47.5958443),
    ["40 KM"] = CFrame.new(- 184.494064, 3.14674306, - 9899.91797),
    ["50 KM"] = CFrame.new(55.228714, 3.19885039, - 19842.3789),
    ["60 KM"] = CFrame.new(- 199.620743, 3.14927387, - 29733.9453),
    ["70 KM"] = CFrame.new(- 577.781921, 3.49909163, - 39654.2148)
}

local ItemCache = {}
local UnicornCache = {}


-- FullBright Configuration
local FullBrightSettings = {
    Enabled = false,
    OriginalValues = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient
    },
    Connection = nil
}

-- No Fog Configuration
local NoFogSettings = {
    Enabled = false,
    OriginalValues = {
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        Atmospheres = {}
    },
    Connection = nil
}

-- Creates visual ESP for an item
local function CreateItemHighlight(item)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = ItemESP.Color
    highlight.OutlineColor = ItemESP.Color
    highlight.FillTransparency = ItemESP.FillTransparency
    highlight.OutlineTransparency = ItemESP.OutlineTransparency
    highlight.Adornee = item
    highlight.Enabled = ItemESP.Enabled
    highlight.Parent = item

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = item
    billboard.Size = UDim2.fromOffset(200, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    billboard.Enabled = ItemESP.Enabled
    billboard.Parent = game:GetService("CoreGui")

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = ItemESP.Color
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    local entry = {
        highlight = highlight,
        billboard = billboard,
        textLabel = textLabel,
        connection = item.AncestryChanged:Connect(function()
            if not item.Parent then
                highlight:Destroy()
                billboard:Destroy()
                ItemCache[item] = nil
            end
        end)
    }

    entry.renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not ItemESP.Enabled or not item.Parent then
            billboard.Enabled = false
            return
        end

        billboard.Enabled = true
        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        local infoParts = {}
        if ItemESP.ShowName then
            table.insert(infoParts, item.Name)
        end
        if ItemESP.ShowDistance and playerRoot then
            local distance = (playerRoot.Position - item:GetPivot().Position).Magnitude
            table.insert(infoParts, string.format("[%dm]", math.floor(distance)))
        end
        
        textLabel.Text = table.concat(infoParts, " ")
        textLabel.TextColor3 = ItemESP.Color
    end)

    ItemCache[item] = entry
end

-- Initializes Item ESP
local function SetupItemESP()
    local runtimeItems = workspace:WaitForChild("RuntimeItems")
    if not runtimeItems then
        warn("Item ESP Error: RuntimeItems not found in workspace")
        return
    end

    for _, item in pairs(runtimeItems:GetChildren()) do
        if item:IsA("Model") then
            CreateItemHighlight(item)
        end
    end

    runtimeItems.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            CreateItemHighlight(child)
        end
    end)
end

-- Add this function to handle melee pickup
local function ToggleAutoPickupMelees(state)
    AutoPickupMelees.Enabled = state
    
    if state then
        local function pickupMeleeTool(tool)
            if tool and tool:IsA("Model") and toolArgs[tool.Name] then
                rs.Remotes.Tool.PickUpTool:FireServer(tool)
            end
        end
        

        for _, tool in ipairs(workspace:WaitForChild("RuntimeItems"):GetChildren()) do
            pickupMeleeTool(tool)
        end
        

        AutoPickupMelees.Connection = workspace:WaitForChild("RuntimeItems").ChildAdded:Connect(function(tool)
            if AutoPickupMelees.Enabled then
                pickupMeleeTool(tool)
            end
        end)
    else

        if AutoPickupMelees.Connection then
            AutoPickupMelees.Connection:Disconnect()
            AutoPickupMelees.Connection = nil
        end
    end
end

-- New Bank ESP Function
function BankEsp(a)
    if a:FindFirstChild("Vault") and a.Vault:FindFirstChild("Union") then
        -- Highlight
        if _G.EspHighlight then
            if not a.Vault.Union:FindFirstChild("Esp_Highlight") then
                local Highlight = Instance.new("Highlight")
                Highlight.Name = "Esp_Highlight"
                Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                Highlight.FillTransparency = 0.5
                Highlight.OutlineTransparency = 0
                Highlight.Adornee = a.Vault.Union
                Highlight.Parent = a.Vault.Union
            end
        elseif a.Vault.Union:FindFirstChild("Esp_Highlight") then
            a.Vault.Union:FindFirstChild("Esp_Highlight"):Destroy()
        end

        -- GUI (Displays bank code)
        if _G.EspGui then
            if not a.Vault.Union:FindFirstChild("Esp_Gui") then
                local GuiBankEsp = Instance.new("BillboardGui", a.Vault.Union)
                GuiBankEsp.Adornee = a.Vault.Union
                GuiBankEsp.Name = "Esp_Gui"
                GuiBankEsp.Size = UDim2.new(0, 10, 0, 10)
                GuiBankEsp.AlwaysOnTop = true
                GuiBankEsp.StudsOffset = Vector3.new(0, 3, 0)
                
                local GuiBankEspText = Instance.new("TextLabel", GuiBankEsp)
               GuiBankEspText.BackgroundTransparency = 1
               GuiBankEspText.Size = UDim2.new(1, 0, 1, 0)
               GuiBankEspText.TextSize = 15
               GuiBankEspText.TextColor3 = Color3.new(1, 0, 0) -- red
               GuiBankEspText.TextStrokeTransparency = 0.5
               GuiBankEspText.Text = ""
                
                local UIStroke = Instance.new("UIStroke")
                UIStroke.Color = Color3.new(0, 0, 0)
                UIStroke.Thickness = 1.5
                UIStroke.Parent = GuiBankEspText
            end
            -- Update text (bank code)
            if a.Vault.Union:FindFirstChild("Esp_Gui") then
                a.Vault.Union["Esp_Gui"].TextLabel.Text = 
                    "Bank | "..a.Vault:FindFirstChild("Combination").Value ..
                    (_G.EspDistance and "\nDistance [ "..string.format("%.1f", (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Vault.Union.Position).Magnitude).." ]" or "")
            end
        elseif a.Vault.Union:FindFirstChild("Esp_Gui") then
            a.Vault.Union:FindFirstChild("Esp_Gui"):Destroy()
        end
    end
end

-- Fast melee function
local function swingTool(toolName)
    local character = player.Character
    if character and character:FindFirstChild(toolName) then
        local toolData = toolArgs[toolName] or {vector = Vector3.new(0, 0, 0)}
        local args = {
            character:FindFirstChild(toolName),
            os.clock(),
            toolData.vector
        }
        rs:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("SwingMelee"):FireServer(unpack(args))
    end
end

-- Instant kill func
local function AutoChargeSwing(Weapon)
    while OneHitSwingActive and Weapon.Parent do
        -- Charge phase
        local chargeStart = os.clock()
        for i = 1, 1000 do
            game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.ChargeMelee:FireServer(
                Weapon,
                chargeStart + (i * 0.0005) -- Small variation in charge time
            )
        end

        -- Swing phase
        local swingStart = os.clock()
        for i = 1, 1000 do
            game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.SwingMelee:FireServer(
                Weapon,
                swingStart + (i * 0.0005), -- Small variation in swing time
                Vector3.new(-0.998, 0.0018, 0.0566):Lerp(
                    Vector3.new(-0.95, 0.005, 0.1), -- Alternate angle
                    math.random() * 0.2 -- Small variation
                )
            )
        end

        -- Small delay between cycles
        task.wait(0.01)
    end
end

local function FullBright(enable)
    FullBrightSettings.Enabled = enable
    
    if enable then
        -- Store original values if not already stored
        if not FullBrightSettings.OriginalValues then
            FullBrightSettings.OriginalValues = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                OutdoorAmbient = Lighting.OutdoorAmbient
            }
        end
        
        -- Start the brightness loop
        FullBrightSettings.Connection = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end)
    else
        -- Stop the brightness loop
        if FullBrightSettings.Connection then
            FullBrightSettings.Connection:Disconnect()
            FullBrightSettings.Connection = nil
        end
        
        -- Restore original values
        if FullBrightSettings.OriginalValues then
            Lighting.Brightness = FullBrightSettings.OriginalValues.Brightness
            Lighting.ClockTime = FullBrightSettings.OriginalValues.ClockTime
            Lighting.FogEnd = FullBrightSettings.OriginalValues.FogEnd
            Lighting.GlobalShadows = FullBrightSettings.OriginalValues.GlobalShadows
            Lighting.OutdoorAmbient = FullBrightSettings.OriginalValues.OutdoorAmbient
        end
    end
end

local function NoFog(enable)
    NoFogSettings.Enabled = enable
    
    if enable then
        -- Store original values if not already stored
        if not NoFogSettings.OriginalValues then
            NoFogSettings.OriginalValues = {
                FogStart = Lighting.FogStart,
                FogEnd = Lighting.FogEnd,
                Atmospheres = {}
            }
            
            -- Store atmosphere settings
            for _, atmosphere in ipairs(Lighting:GetChildren()) do
                if atmosphere:IsA("Atmosphere") then
                    table.insert(NoFogSettings.OriginalValues.Atmospheres, {
                        Object = atmosphere,
                        Density = atmosphere.Density,
                        Haze = atmosphere.Haze
                    })
                end
            end
        end
        
        -- Start the no fog loop
        NoFogSettings.Connection = RunService.RenderStepped:Connect(function()
            Lighting.FogStart = 100000
            Lighting.FogEnd = 200000
            for _, atmosphere in ipairs(Lighting:GetChildren()) do
                if atmosphere:IsA("Atmosphere") then
                    atmosphere.Density = 0
                    atmosphere.Haze = 0
                end
            end
        end)
    else
        -- Stop the no fog loop
        if NoFogSettings.Connection then
            NoFogSettings.Connection:Disconnect()
            NoFogSettings.Connection = nil
        end
        
        -- Restore original values
        if NoFogSettings.OriginalValues then
            Lighting.FogStart = NoFogSettings.OriginalValues.FogStart
            Lighting.FogEnd = NoFogSettings.OriginalValues.FogEnd
            
            -- Restore atmosphere settings
            for _, atmosphereData in ipairs(NoFogSettings.OriginalValues.Atmospheres) do
                if atmosphereData.Object and atmosphereData.Object.Parent then
                    atmosphereData.Object.Density = atmosphereData.Density
                    atmosphereData.Object.Haze = atmosphereData.Haze
                end
            end
        end
    end
end

local function AutoReload()
    while true do
        for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:FindFirstChild("ClientWeaponState") and v.ClientWeaponState:FindFirstChild("CurrentAmmo") then
                game.ReplicatedStorage.Remotes.Weapon.Reload:FireServer(game.Workspace:GetServerTimeNow(), v)
            end
        end
        task.wait()
    end
end

-- New Ore ESP Function
local function EspOre()
    while _G.EspOrb do
        if game.Workspace:FindFirstChild("Ore") then
            for i, v in pairs(game.Workspace.Ore:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Health") and v:FindFirstChild("Boulder_a") then
                    -- Highlight
                    if _G.EspHighlight then
                        if not v["Boulder_a"]:FindFirstChild("Esp_Highlight") then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Name = "Esp_Highlight"
                            Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Highlight.FillTransparency = 0.5
                            Highlight.OutlineTransparency = 0
                            Highlight.Adornee = v
                            Highlight.Parent = v["Boulder_a"]
                        end
                    elseif v["Boulder_a"]:FindFirstChild("Esp_Highlight") then
                        v["Boulder_a"]:FindFirstChild("Esp_Highlight"):Destroy()
                    end

                    -- GUI (Displays ore name, health, distance)
                    if _G.EspGui then
                        if not v["Boulder_a"]:FindFirstChild("Esp_Gui") then
                            local GuiOreEsp = Instance.new("BillboardGui", v["Boulder_a"])
                            GuiOreEsp.Adornee = v
                            GuiOreEsp.Name = "Esp_Gui"
                            GuiOreEsp.Size = UDim2.new(0, 100, 0, 150)
                            GuiOreEsp.AlwaysOnTop = true
                            GuiOreEsp.StudsOffset = Vector3.new(0, 3, 0)
                            
                            local GuiOreEspText = Instance.new("TextLabel", GuiOreEsp)
                            GuiOreEspText.BackgroundTransparency = 1
                            GuiOreEspText.Size = UDim2.new(0, 100, 0, 100)
                            GuiOreEspText.TextSize = 15
                            GuiOreEspText.TextColor3 = Color3.new(0, 0, 0)
                            GuiOreEspText.TextStrokeTransparency = 0.5
                            GuiOreEspText.Text = ""
                            
                            local UIStroke = Instance.new("UIStroke")
                            UIStroke.Color = Color3.new(0, 0, 0)
                            UIStroke.Thickness = 1.5
                            UIStroke.Parent = GuiOreEspText
                        end
                        -- Update text
                        if v["Boulder_a"]:FindFirstChild("Esp_Gui") then
                            v["Boulder_a"]["Esp_Gui"].TextLabel.Text = 
                                (_G.EspName and v.Name or "") ..
                                (_G.EspDistance and "\nDistance [ "..string.format("%.1f", (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v["Boulder_a"].Position).Magnitude).." ]" or "") ..
                                (_G.EspHealth and "\nHealth [ "..v.Health.Value.." ]" or "")
                        end
                    elseif v["Boulder_a"]:FindFirstChild("Esp_Gui") then
                        v["Boulder_a"]:FindFirstChild("Esp_Gui"):Destroy()
                    end
                end
            end
        end
        task.wait()
    end
end

local function FindFirstChildOfType(instance, className)
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA(className) then
            return child
        end
    end
    return nil
end

-- Create visual ESP for fuel containers
local function CreateFuelHighlight(fuelContainer)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = FuelESP.HighlightColor
    highlight.OutlineColor = FuelESP.HighlightColor
    highlight.FillTransparency = FuelESP.FillTransparency
    highlight.OutlineTransparency = FuelESP.OutlineTransparency
    highlight.Adornee = fuelContainer
    highlight.Enabled = FuelESP.Enabled
    highlight.Parent = fuelContainer

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = fuelContainer
    billboard.Size = UDim2.fromOffset(200, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    billboard.Enabled = FuelESP.Enabled
    billboard.Parent = game:GetService("CoreGui")

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = FuelESP.TextColor
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    local entry = {
        highlight = highlight,
        billboard = billboard,
        textLabel = textLabel,
        connection = fuelContainer.AncestryChanged:Connect(function()
            if not fuelContainer.Parent then
                highlight:Destroy()
                billboard:Destroy()
            end
        end)
    }

    entry.renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not FuelESP.Enabled or not fuelContainer.Parent then
            billboard.Enabled = false
            highlight.Enabled = false
            return
        end

        billboard.Enabled = true
        highlight.Enabled = true
        
        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local fuelAmount = fuelContainer:GetAttribute("Fuel") or 0
        
        local infoParts = {}
        if FuelESP.ShowFuelAmount then
            table.insert(infoParts, string.format("Fuel: %d", fuelAmount))
        end
        if FuelESP.ShowDistance and playerRoot then
            local distance = (playerRoot.Position - fuelContainer:GetPivot().Position).Magnitude
            table.insert(infoParts, string.format("[%dm]", math.floor(distance)))
        end
        
        textLabel.Text = table.concat(infoParts, " ")
    end)

    return entry
end

-- Initialize Fuel ESP
local function SetupFuelESP()
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:GetAttribute("Fuel") then
            CreateFuelHighlight(instance)
        end
    end

    workspace.DescendantAdded:Connect(function(instance)
        if instance:GetAttribute("Fuel") then
            CreateFuelHighlight(instance)
        end
    end)
end

-- NPC Lock Functions
local function getClosestNPC()
    local closestNPC = nil
    local closestDistance = math.huge

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Model") then
            local humanoid = object:FindFirstChild("Humanoid") or object:FindFirstChildWhichIsA("Humanoid")
            local hrp = object:FindFirstChild("HumanoidRootPart") or object.PrimaryPart
            if humanoid and hrp and humanoid.Health > 0 and object.Name ~= "Horse" then
                local isPlayer = false
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl.Character == object then
                        isPlayer = true
                        break
                    end
                end
                if not isPlayer then
                    local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestNPC = object
                    end
                end
            end
        end
    end

    return closestNPC
end

local function ToggleNPCLock(state)
    NPCLock.Enabled = state
    
    if state then
        NPCLock.ToggleLoop = RunService.RenderStepped:Connect(function()
            local npc = getClosestNPC()
            if npc and npc:FindFirstChild("Humanoid") then
                local npcHumanoid = npc:FindFirstChild("Humanoid")
                if npcHumanoid.Health > 0 then
                    workspace.CurrentCamera.CameraSubject = npcHumanoid
                    NPCLock.LastTarget = npc
                else
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Killed NPC",
                        Text = npc.Name,
                        Duration = 0.4
                    })
                    NPCLock.LastTarget = nil
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
                    end
                end
            else
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
                end
                NPCLock.LastTarget = nil
            end
        end)
    else
        if NPCLock.ToggleLoop then
            NPCLock.ToggleLoop:Disconnect()
            NPCLock.ToggleLoop = nil
        end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        end
    end
end

-- Auto Collect MoneyBags Functions
local function skipHoldPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent.Name == "MoneyBag" then
        if not AutoCollectMoneyBags.OriginalHoldDurations[prompt] then
            AutoCollectMoneyBags.OriginalHoldDurations[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    end
end

local function handleMoneyBag(v)
    if not AutoCollectMoneyBags.Enabled then
        return
    end
    if v:IsA("Model") and v.Name == "Moneybag" and v:FindFirstChild("MoneyBag") then
        local prompt = v.MoneyBag:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            skipHoldPrompt(prompt)
        end
    end
end

local function collectMoneyBags()
    if not AutoCollectMoneyBags.Enabled then
        return
    end
    
    -- Clear existing connections
    for _, connection in pairs(AutoCollectMoneyBags.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    AutoCollectMoneyBags.Connections = {}

    -- Process existing money bags
    for _, v in ipairs(workspace:WaitForChild("RuntimeItems"):GetChildren()) do
        handleMoneyBag(v)
    end

    -- Add connection for new money bags
    local childAddedConnection = workspace:WaitForChild("RuntimeItems").ChildAdded:Connect(function(v)
        handleMoneyBag(v)
    end)
    table.insert(AutoCollectMoneyBags.Connections, childAddedConnection)

    -- Add connection for collecting
    local heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not AutoCollectMoneyBags.Enabled then
            return
        end
        for _, v in ipairs(workspace:WaitForChild("RuntimeItems"):GetChildren()) do
            if v:IsA("Model") and v.Name == "Moneybag" and v:FindFirstChild("MoneyBag") then
                local prompt = v.MoneyBag:FindFirstChildOfClass("ProximityPrompt")
                if prompt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (v.MoneyBag.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= prompt.MaxActivationDistance then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
    end)
    table.insert(AutoCollectMoneyBags.Connections, heartbeatConnection)
end

local function ToggleAutoCollectMoneyBags(state)
    AutoCollectMoneyBags.Enabled = state
    if state then
        collectMoneyBags()
    else
        -- Restore original hold durations
        for prompt, duration in pairs(AutoCollectMoneyBags.OriginalHoldDurations) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = duration
            end
        end
        AutoCollectMoneyBags.OriginalHoldDurations = {}
        
        -- Disconnect all connections
        for _, connection in pairs(AutoCollectMoneyBags.Connections) do
            if connection then
                connection:Disconnect()
            end
        end
        AutoCollectMoneyBags.Connections = {}
    end
end

-- Auto Pickup Snake Oil & Bandages Function
local function ToggleAutoPickupSnakeOilBandages(state)
    AutoPickupSnakeOilBandages.Enabled = state
    
    if state then
        AutoPickupSnakeOilBandages.Connection = task.spawn(function()
            local ReplicatedStorage1 = game:GetService("ReplicatedStorage")
            local RuntimeItems1 = workspace:WaitForChild("RuntimeItems")
            local PickUpTool = ReplicatedStorage1.Remotes.Tool.PickUpTool
            
            while AutoPickupSnakeOilBandages.Enabled do
                for _, itemName in ipairs({
                    "Bandage",
                    "Snake Oil"
                }) do
                    local item = RuntimeItems1:FindFirstChild(itemName)
                    if item then
                        PickUpTool:FireServer(item)
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        if AutoPickupSnakeOilBandages.Connection then
            task.cancel(AutoPickupSnakeOilBandages.Connection)
            AutoPickupSnakeOilBandages.Connection = nil
        end
    end
end

-- Instant Prompt Function
local function ToggleInstantPrompt(state)
    InstantPrompt.Enabled = state
    
    if state then
        InstantPrompt.Connection = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                descendant.HoldDuration = 0
            end
        end)
        
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end
    else
        if InstantPrompt.Connection then
            InstantPrompt.Connection:Disconnect()
            InstantPrompt.Connection = nil
        end
    end
end

-- NoClip Function
local function ToggleNoClip(state)
    NoClip.Enabled = state
    
    if state then
        NoClip.Connection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClip.Connection then
            NoClip.Connection:Disconnect()
            NoClip.Connection = nil
        end
        
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Anti Void Function
local function ToggleAntiVoid(state)
    AntiVoid.Enabled = state
    
    if state then
        AntiVoid.Connection = game:GetService("RunService").Stepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                if rootPart.Position.Y < - 1 then
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWTPTRAIN.github.io/refs/heads/main/TRAIN.LUA"))()
                end
            end
        end)
    else
        if AntiVoid.Connection then
            AntiVoid.Connection:Disconnect()
            AntiVoid.Connection = nil
        end
    end
end

-- Auto Collect Guns Function
local function ToggleAutoCollectGuns(state)
    AutoCollectGuns.Enabled = state
    
    local runtimeItems = workspace:WaitForChild("RuntimeItems")
    local pickUpRemote = rs.Remotes.Tool.PickUpTool
    
    local function collectGun(gun)
        if gun and gun:IsA("Model") and AutoCollectGuns.GunTypes[gun.Name] then
            pcall(function()
                pickUpRemote:FireServer(gun)
            end)
        end
    end
    
    local function collectGuns()
        for _, item in ipairs(runtimeItems:GetChildren()) do
            collectGun(item)
        end
    end
    
    if state then
        collectGuns()
        AutoCollectGuns.Connection = runtimeItems.ChildAdded:Connect(function(child)
            if AutoCollectGuns.Enabled then
                task.wait(0.1)
                collectGun(child)
            end
        end)
        
        runtimeItems.ChildRemoved:Connect(function()
            if AutoCollectGuns.Enabled then
                collectGuns()
            end
        end)
    else
        if AutoCollectGuns.Connection then
            AutoCollectGuns.Connection:Disconnect()
            AutoCollectGuns.Connection = nil
        end
    end
end

-- Auto Collect Bonds Function
local function CollectBonds()
    local activateRemote
    for _, name in ipairs({
        "C_ActivateObject",
        "S_C_ActivateObject"
    }) do
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild(name) or game:GetService("ReplicatedStorage"):FindFirstChild("Shared"):FindFirstChild("Network"):FindFirstChild("RemotePromise"):FindFirstChild("Remotes"):FindFirstChild(name)
        if remote then
            activateRemote = remote
            break
        end
    end

    if not activateRemote then
        return
    end

    for _, item in ipairs(game:GetService("Workspace"):WaitForChild("RuntimeItems"):GetChildren()) do
        if item.Name:match("Bond") then
            pcall(function()
                if activateRemote:IsA("RemoteFunction") then
                    activateRemote:InvokeServer(item)
                else
                    activateRemote:FireServer(item)
                end
            end)
            task.wait(0.1)
        end
    end
end

local function ToggleAutoCollectBonds(state)
    AutoCollectBonds.Enabled = state
    
    if state then
        AutoCollectBonds.Connection = RunService.Heartbeat:Connect(function()
            CollectBonds()
        end)
    else
        if AutoCollectBonds.Connection then
            AutoCollectBonds.Connection:Disconnect()
            AutoCollectBonds.Connection = nil
        end
    end
end

-- Auto Collect Ammos Function
local function CollectAmmo()
    local activateRemote
    for _, name in ipairs({
        "C_ActivateObject",
        "S_C_ActivateObject"
    }) do
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild(name) or game:GetService("ReplicatedStorage"):FindFirstChild("Shared"):FindFirstChild("Network"):FindFirstChild("RemotePromise"):FindFirstChild("Remotes"):FindFirstChild(name)
        if remote then
            activateRemote = remote
            break
        end
    end

    if not activateRemote then
        return
    end

    -- check runtime
    for _, item in ipairs(game:GetService("Workspace"):WaitForChild("RuntimeItems"):GetChildren()) do
        for _, ammoName in ipairs(AutoCollectAmmos.AmmoTypes) do
            if item.Name:lower() == ammoName:lower() then
                pcall(function()
                    if activateRemote:IsA("RemoteFunction") then
                        activateRemote:InvokeServer(item)
                    else
                        activateRemote:FireServer(item)
                    end
                end)
                task.wait(0.1)
                break
            end
        end
    end
end

local function ToggleAutoCollectAmmos(state)
    AutoCollectAmmos.Enabled = state
    
    if state then
        AutoCollectAmmos.Connection = RunService.Heartbeat:Connect(function()
            CollectAmmo()
        end)
    else
        if AutoCollectAmmos.Connection then
            AutoCollectAmmos.Connection:Disconnect()
            AutoCollectAmmos.Connection = nil
        end
    end
end

-- Gun Aura Functions
-- Shotgun spread angles (optimized for Fast Mode)
local ShotgunSpread = {14, 8, 2, 5, 11, 17}

-- Gun Aura Fast Mode Function
local function GunAuraFastMode()
    while GunAura.Enabled and task.wait(GunAura.SHOT_DELAY) do
        -- Find closest valid target
        local closestTarget, closestHumanoid, closestDistance = nil, nil, math.huge
        
        for _, enemy in pairs(GunAura.AntiLagTable) do
            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                
                if distance < closestDistance and distance < GunAura.REACH_DISTANCE then
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        closestTarget = enemy:FindFirstChild(GunAura.TARGET_PART) or enemy.HumanoidRootPart
                        closestHumanoid = enemy.Humanoid
                        closestDistance = distance
                    end
                end
            end
        end

        -- Shooting logic
        if closestTarget and closestHumanoid then
            for _, weapon in pairs(player.Character:GetChildren()) do
                if weapon:FindFirstChild("ClientWeaponState") then
                    local hitData = {}
                    
                    -- Shotgun spread pattern
                    if weapon.Name:match("Shotgun") then
                        for _, angle in pairs(ShotgunSpread) do
                            hitData[angle] = closestHumanoid
                        end
                    else -- Single-shot weapons
                        hitData["2"] = closestHumanoid
                    end

                    -- Force shoot (bypasses ammo checks)
                    game:GetService("ReplicatedStorage").Remotes.Weapon.Shoot:FireServer(
                        os.clock(), -- Current time
                        weapon, -- Weapon instance
                        CFrame.new(closestTarget.Position), -- Target position
                        hitData -- Damage data
                    )

                    -- Instant reload (critical for Fast Mode)
                    game:GetService("ReplicatedStorage").Remotes.Weapon.Reload:FireServer(
                        os.clock(),
                        weapon
                    )
                end
            end
        end
    end
end

-- Target Tracking
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
        if not game.Players:GetPlayerFromCharacter(v) then
            table.insert(GunAura.AntiLagTable, v)
        end
    end
end)

-- Cleanup dead targets
game:GetService("RunService").Heartbeat:Connect(function()
    for i = #GunAura.AntiLagTable, 1, -1 do
        local enemy = GunAura.AntiLagTable[i]
        if not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 then
            table.remove(GunAura.AntiLagTable, i)
        end
    end
end)

-- Toggle Gun Aura Function
local function ToggleGunAura(state)
    GunAura.Enabled = state
    
    if state then
        GunAura.Connection = task.spawn(GunAuraFastMode)
    else
        if GunAura.Connection then
            task.cancel(GunAura.Connection)
            GunAura.Connection = nil
        end
    end
end

local function NotificationUnicorn()
    spawn(function()
        for i, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:find("Unicorn") and v:FindFirstChild("HumanoidRootPart") and not game.Players:GetPlayerFromCharacter(v) then
                if v:FindFirstChild("Esp_Unicorn") == nil or v:FindFirstChild("Esp_UnicornGui") == nil then
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        WindUI:Notify({
                            Title = "Unicorn Spawned",
                            Content = string.format("Health: %d", v.Humanoid.Health),
                            Duration = 7,
                            Icon = "unicorn" -- Add appropriate icon if available
                        })
                    else
                        WindUI:Notify({
                            Title = "Unicorn Spawned",
                            Content = "Unicorn is dead",
                            Duration = 7,
                            Icon = "skull" -- Add appropriate icon if available
                        })
                    end
                    repeat task.wait() 
                        if v:FindFirstChild("Esp_UnicornGui") == nil then
                            local GuiItemEsp = Instance.new("BillboardGui", v)
                            GuiItemEsp.Adornee = v
                            GuiItemEsp.Name = "Esp_UnicornGui"
                            GuiItemEsp.Size = UDim2.new(0, 50, 0, 50)
                            GuiItemEsp.AlwaysOnTop = true
                            GuiItemEsp.StudsOffset = Vector3.new(0, 3, 0)
                            local GuiItemEspFrame = Instance.new("Frame", GuiItemEsp)
                            GuiItemEspFrame.BackgroundTransparency = 1
                            GuiItemEspFrame.Size = UDim2.new(1, 0, 1, 0)
                            local GuiItemUICorner = Instance.new("UICorner")
                            GuiItemUICorner.CornerRadius = UDim.new(2, 0)
                            GuiItemUICorner.Parent = GuiItemEspFrame
                            local GuiItemUIStroke = Instance.new("UIStroke")
                            GuiItemUIStroke.Color = Color3.fromRGB(0, 255, 0)
                            GuiItemUIStroke.Thickness = 2
                            GuiItemUIStroke.Parent = GuiItemEspFrame
                        end
                        if v:FindFirstChild("Esp_Unicorn") == nil then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Name = "Esp_Unicorn"
                            Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Highlight.FillTransparency = 0.5
                            Highlight.OutlineTransparency = 0
                            Highlight.Adornee = v
                            Highlight.Parent = v
                        end
                    until v:FindFirstChild("HumanoidRootPart") == nil or v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0
                    if v:FindFirstChild("Esp_Unicorn") then v:FindFirstChild("Esp_Unicorn"):Destroy() end
                    if v:FindFirstChild("Esp_UnicornGui") then v:FindFirstChild("Esp_UnicornGui"):Destroy() end
                end
            end
        end
    end)

    local NotificationUnicornGet = workspace.DescendantAdded:Connect(function(v)
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and not game.Players:GetPlayerFromCharacter(v) then
            if v.Name:find("Unicorn") then
                if v:FindFirstChild("Esp_Unicorn") == nil or v:FindFirstChild("Esp_UnicornGui") == nil then
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        WindUI:Notify({
                            Title = "Unicorn Spawned",
                            Content = string.format("Health: %d", v.Humanoid.Health),
                            Duration = 7,
                            Icon = "unicorn"
                        })
                    else
                        WindUI:Notify({
                            Title = "Unicorn Spawned",
                            Content = "Unicorn is dead",
                            Duration = 7,
                            Icon = "skull"
                        })
                    end
                    repeat task.wait() 
                        if v:FindFirstChild("Esp_UnicornGui") == nil then
                            local GuiItemEsp = Instance.new("BillboardGui", v)
                            GuiItemEsp.Adornee = v
                            GuiItemEsp.Name = "Esp_UnicornGui"
                            GuiItemEsp.Size = UDim2.new(0, 50, 0, 50)
                            GuiItemEsp.AlwaysOnTop = true
                            local GuiItemEspFrame = Instance.new("Frame", GuiItemEsp)
                            GuiItemEspFrame.BackgroundTransparency = 1
                            GuiItemEspFrame.Size = UDim2.new(1, 0, 1, 0)
                            local GuiItemUICorner = Instance.new("UICorner")
                            GuiItemUICorner.CornerRadius = UDim.new(2, 0)
                            GuiItemUICorner.Parent = GuiItemEspFrame
                            local GuiItemUIStroke = Instance.new("UIStroke")
                            GuiItemUIStroke.Color = Color3.fromRGB(0, 255, 0)
                            GuiItemUIStroke.Thickness = 2
                            GuiItemUIStroke.Parent = GuiItemEspFrame
                        end
                        if v:FindFirstChild("Esp_Unicorn") == nil then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Name = "Esp_Unicorn"
                            Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Highlight.FillTransparency = 0.5
                            Highlight.OutlineTransparency = 0
                            Highlight.Adornee = v
                            Highlight.Parent = v
                        end
                    until v:FindFirstChild("HumanoidRootPart") == nil or v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0
                    if v:FindFirstChild("Esp_Unicorn") then v:FindFirstChild("Esp_Unicorn"):Destroy() end
                    if v:FindFirstChild("Esp_UnicornGui") then v:FindFirstChild("Esp_UnicornGui"):Destroy() end
                end
            end
        end
    end)
    return NotificationUnicornGet
end

-- Time ESP Function
local function EspTime()
    -- Only works if game has TimeHour value in ReplicatedStorage
    if not game:GetService("ReplicatedStorage"):FindFirstChild("TimeHour") then return end
    
    local timeValue = game:GetService("ReplicatedStorage").TimeHour.Value
    local text = "Time: "..tostring(timeValue)
    
    -- Create at the top of the screen
    if not game:GetService("CoreGui"):FindFirstChild("TimeEsp") then
        local gui = Instance.new("ScreenGui")
        gui.Name = "TimeEsp"
        gui.Parent = game:GetService("CoreGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 50)
        frame.Position = UDim2.new(0.5, -100, 0, 10)
        frame.BackgroundTransparency = 0.7
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.Parent = gui
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = text
        textLabel.Font = Enum.Font.Code
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.BackgroundTransparency = 1
        textLabel.Parent = frame
        
        -- Update it continuously
        game:GetService("RunService").Heartbeat:Connect(function()
            if gui.Parent then
                textLabel.Text = "Time: "..tostring(game:GetService("ReplicatedStorage").TimeHour.Value)
            end
        end)
    end
end

-- Money ESP Function
local function EspMoney()
    for _, item in pairs(workspace:WaitForChild("RuntimeItems"):GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("ObjectInfo") then
            -- Check if item has money value
            local value = item:GetAttribute("Value") or item:GetAttribute("Bounty")
            
            if value then
                -- Create or update ESP GUI
                if not item:FindFirstChild("MoneyEspGui") then
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "MoneyEspGui"
                    gui.Adornee = item.PrimaryPart or item:FindFirstChild("HumanoidRootPart") or item:WaitForChild("PrimaryPart", 1)
                    gui.Size = UDim2.new(0, 100, 0, 50)
                    gui.AlwaysOnTop = true
                    gui.StudsOffset = Vector3.new(0, 2, 0)
                    
                    local text = Instance.new("TextLabel")
                    text.BackgroundTransparency = 1
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.Text = "$"..tostring(value)
                    text.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green money text
                    text.TextStrokeTransparency = 0.5
                    text.Font = Enum.Font.Code
                    text.Parent = gui
                    
                    gui.Parent = item
                else
                    item.MoneyEspGui.TextLabel.Text = "$"..tostring(value)
                end
            elseif item:FindFirstChild("MoneyEspGui") then
                item.MoneyEspGui:Destroy()
            end
        end
    end
end

-- Safe Zones Teleport Function
local function findNearestVehicleSeat(position)
    local closestSeat, minDistance = nil, math.huge
    for _, seat in ipairs(workspace:GetDescendants()) do
        if seat:IsA("VehicleSeat") then
            local distance = (position - seat.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                closestSeat = seat
            end
        end
    end
    return closestSeat
end

local function teleportToBase(baseName)
    if not BASE_TELEPORTS[baseName] then
        return
    end
    
    local character = player.Character
    if not character then
        return
    end
    
    local Humanoid = character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        return
    end

    local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        return
    end

    local originalWalkSpeed = Humanoid.WalkSpeed
    Humanoid.WalkSpeed = 0
    
    HumanoidRootPart.CFrame = BASE_TELEPORTS[baseName]
    HumanoidRootPart.Anchored = true
    
    task.wait(0.5)
    local seat = findNearestVehicleSeat(HumanoidRootPart.Position)
    if seat then
        HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.15)
        HumanoidRootPart.Anchored = false
        task.wait(0.5)
        seat:Sit(Humanoid)
    else
        HumanoidRootPart.Anchored = false
    end
    
    task.wait(1)
    Humanoid.WalkSpeed = originalWalkSpeed
end

-- Teleport Functions
local function TeleportToTrain()
    local c = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    for _, m in ipairs(game:GetDescendants()) do
        if m:IsA("Model") and m.Name == "ConductorSeat" then
            local s = m:FindFirstChildWhichIsA("VehicleSeat", true)
            if s then
                c:MoveTo(s.Position)
                break
            end
        end
    end
end

local function createWeldButton()
    if game.CoreGui:FindFirstChild("WeldButton") then
        return
    end

    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "WeldButton"
    gui.Enabled = true

    -- Frame
    local Frame1 = Instance.new("Frame")
    Frame1.Name = "Frame1"
    Frame1.Size = UDim2.new(0, 50, 0, 50)
    Frame1.Position = UDim2.new(0.9, 0, 0.3, 0)
    Frame1.BackgroundColor3 = Color3.new(0, 0, 0)
    Frame1.BorderColor3 = Color3.new(0, 0, 0)
    Frame1.BorderSizePixel = 1
    Frame1.Active = true
    Frame1.BackgroundTransparency = 0.85  -- Semi-transparent
    Frame1.Draggable = true
    Frame1.Parent = gui

    -- Rounded Corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Frame1

    -- Weld Button
    local TextButton = Instance.new("TextButton")
    TextButton.Size = UDim2.new(1, 0, 1, 0)
    TextButton.Position = UDim2.new(0, 0, 0, 0)
    TextButton.BackgroundColor3 = Color3.new(0, 0, 0)
    TextButton.BorderColor3 = Color3.new(0, 0, 0)
    TextButton.BorderSizePixel = 1
    TextButton.Text = "Weld"
    TextButton.TextSize = 18
    TextButton.FontFace = Font.new("rbxassetid://12187372175", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    TextButton.BackgroundTransparency = 0.5
    TextButton.TextColor3 = Color3.new(1, 1, 1)
    TextButton.Parent = Frame1

    -- Button Click Logic
    TextButton.MouseButton1Click:Connect(function()
        if workspace:FindFirstChild("RuntimeItems") then
            for _, item in pairs(workspace.RuntimeItems:GetChildren()) do
                if item:IsA("Model") and item.PrimaryPart and item.PrimaryPart:FindFirstChild("DragAlignPosition") then
                    for _, train in pairs(workspace:GetChildren()) do
                        if train:IsA("Model") and train:FindFirstChild("RequiredComponents") then
                            local base = train.RequiredComponents:FindFirstChild("Base")
                            if base and not item.PrimaryPart:FindFirstChild("DragWeldConstraint") then
                                game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.RequestWeld:FireServer(item, base)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Button Corner Styling
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(1, 0)
    UICorner2.Parent = TextButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.new(0, 0, 0)
    UIStroke.Thickness = 2.5
    UIStroke.Parent = Frame1

    -- Dragging Logic
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Frame1.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    TextButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame1.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TextButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            update(input)
        end
    end)
end

local function TeleportToTesla()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/Lab'))()
end

local function TeleportToCastle()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/VampCastle"))()
end

local function TeleportToFort()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/Fort"))()
end

local function TeleportToEnd()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/End"))()
end

local function InfiniteYield()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end

local function CopyDiscordInvite()
    setclipboard("https://discord.gg/tuffguys")
end

local function AutBonds()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HeadHarse/DeadRails/refs/heads/main/AutoFarmBonds"))()
end

local function Town1()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/Tuwn1", true))()
end

-- Create tabs with icons
local discordTab = Window:Tab({
    Title = "Important",
    Icon = "bell"
})
local farmTab = Window:Tab({
    Title = "Farm",
    Icon = "tractor"
})
local mainTab = Window:Tab({
    Title = "Main",
    Icon = "settings"
})
local itemsTab = Window:Tab({
    Title = "Items",
    Icon = "shield"
})
local weaponsTab = Window:Tab({
    Title = "Weapons",
    Icon = "swords"
})
local teleportsTab = Window:Tab({
    Title = "Teleports",
    Icon = "map-pinned"
})
local visualTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye"
})
local othersTab = Window:Tab({
    Title = "Others",
    Icon = "spade"
})

Window:SelectTab(1)

-- Discord Tab
discordTab:Paragraph({
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

-- Farm Tab
farmTab:Section({
    Title = "Farming"
})
farmTab:Divider()
farmTab:Button({
    Title = "Auto Bonds",
    Callback = AutBonds,
    Icon = "dollar-sign"
})

farmTab:Button({
    Title = "Auto Win",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/HeadHarse/Dusty/refs/heads/main/AUTOWIN"))()
    end,
    Icon = "trophy"
})

farmTab:Button({
    Title = "Auto Complete Scorched Earth",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/HeadHarse/Dusty/refs/heads/main/SCORCHEDEARTH"))()
    end,
    Icon = "flame"
})

-- Main Tab
mainTab:Section({
    Title = "Main Functions"
})
mainTab:Divider()

mainTab:Button({
    Title = "Weld Anywhere Button",
    Callback = function()
        createWeldButton()
    end,
    Icon = "wrench"
})

mainTab:Toggle({
    Title = "Notify Unicorn Spawns",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            NotificationUnicorn()
        else
            -- Clean up any existing unicorn ESP
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:find("Unicorn") then
                    if v:FindFirstChild("Esp_Unicorn") then v:FindFirstChild("Esp_Unicorn"):Destroy() end
                    if v:FindFirstChild("Esp_UnicornGui") then v:FindFirstChild("Esp_UnicornGui"):Destroy() end
                end
            end
        end
    end,
    Icon = "bell"
})

mainTab:Toggle({
    Title = "Anti Void",
    Type = "Checkbox",
    Value = AntiVoid.Enabled,
    Callback = ToggleAntiVoid,
    Icon = "shield"
})

mainTab:Toggle({
    Title = "NoClip",
    Type = "Checkbox",
    Value = NoClip.Enabled,
    Callback = ToggleNoClip,
    Icon = "move"
})

mainTab:Toggle({
    Title = "Instant Prompt",
    Type = "Checkbox",
    Value = InstantPrompt.Enabled,
    Callback = ToggleInstantPrompt,
    Icon = "zap"
})

-- Items Tab
itemsTab:Section({
    Title = "Bring Items"
})
itemsTab:Divider()
local selectedItem = "None"

itemsTab:Dropdown({
    Title = "Select Item to Bring",
    Values = {"None", "Gold", "Silver", "Coal", "Bandage", "Bond", "Snake Oil"},
    Default = "None",
    Callback = function(selected)
        selectedItem = selected
    end,
    Icon = "package"
})

itemsTab:Button({
    Title = "Bring Item",
    Callback = function()
        if selectedItem ~= "None" then
            getgenv().bringitem = selectedItem
            loadstring(game:HttpGet('https://raw.githubusercontent.com/HeadHarse/Things/refs/heads/main/AlotOfThings'))()
        end
    end,
    Icon = "box"
})

itemsTab:Section({
    Title = "Auto"
})
itemsTab:Divider()

itemsTab:Toggle({
    Title = "Auto Collect MoneyBags",
    Type = "Checkbox",
    Value = AutoCollectMoneyBags.Enabled,
    Callback = ToggleAutoCollectMoneyBags,
    Icon = "dollar-sign"
})

itemsTab:Toggle({
    Title = "Auto Collect Guns",
    Type = "Checkbox",
    Value = AutoCollectGuns.Enabled,
    Callback = ToggleAutoCollectGuns,
    Icon = "package"
})

itemsTab:Toggle({
    Title = "Auto Pickup Melees",
    Type = "Checkbox",
    Value = AutoPickupMelees.Enabled,
    Callback = ToggleAutoPickupMelees,
    Icon = "sword"
})

itemsTab:Toggle({
    Title = "Auto Collect Bonds",
    Type = "Checkbox",
    Value = AutoCollectBonds.Enabled,
    Callback = ToggleAutoCollectBonds,
    Icon = "dollar-sign"
})

itemsTab:Toggle({
    Title = "Auto Pickup Snake Oil & Bandages",
    Type = "Checkbox",
    Value = AutoPickupSnakeOilBandages.Enabled,
    Callback = ToggleAutoPickupSnakeOilBandages,
    Icon = "bandage"
})

itemsTab:Toggle({
    Title = "Auto Collect Ammos",
    Type = "Checkbox",
    Value = AutoCollectAmmos.Enabled,
    Callback = ToggleAutoCollectAmmos,
    Icon = "package"
})

-- Weapons Tab
weaponsTab:Section({
    Title = "Melee"
})
weaponsTab:Divider()

-- Add the swing speed input field
weaponsTab:Input({
    Title = "Swing Speed (1-1000)",
    Value = tostring(SwingSpeed),
    Placeholder = "Enter swings per second",
    Callback = function(input)
        local num = tonumber(input) or 10
        SwingSpeed = math.clamp(num, 1, 1000)
    end
})

-- Add the Fast Melee toggle
weaponsTab:Toggle({
    Title = "Fast Melee",
    Type = "Checkbox",
    Value = MeleeActive,
    Callback = function(state)
        MeleeActive = state
        
        if MeleeActive then
            -- Start swinging thread
            SwingThread = task.spawn(function()
                while MeleeActive and player.Character do
                    -- Swing all valid melee tools
                    for toolName, _ in pairs(toolArgs) do
                        if player.Character:FindFirstChild(toolName) then
                            swingTool(toolName)
                        end
                    end
                    -- Calculate delay based on swing speed
                    task.wait(1/SwingSpeed)
                end
            end)
        else
            -- Stop swinging thread
            if SwingThread then
                task.cancel(SwingThread)
                SwingThread = nil
            end
        end
    end,
    Icon = "sword"
})

weaponsTab:Toggle({
    Title = "Instant Kill",
    Type = "Checkbox",
    Value = OneHitSwingActive,
    Callback = function(state)
        OneHitSwingActive = state
        
        if OneHitSwingActive then
            -- Prevent both toggles from being active
            if MeleeActive then
                MeleeActive = false
                if SwingThread then
                    task.cancel(SwingThread)
                    SwingThread = nil
                end
                -- Update the Fast Melee toggle visually
                for _, tab in pairs(Window.Tabs) do
                    if tab.Title == "Weapons" then
                        for _, element in pairs(tab.Elements) do
                            if element.Title == "Fast Melee" then
                                element:SetValue(false)
                                break
                            end
                        end
                        break
                    end
                end
            end
            
            -- Start instant kill thread
            OneHitSwingThread = task.spawn(function()
                while OneHitSwingActive and player.Character do
                    for toolName, _ in pairs(toolArgs) do
                        local weapon = player.Character:FindFirstChild(toolName)
                        if weapon then
                            AutoChargeSwing(weapon)
                        end
                    end
                    task.wait()
                end
            end)
        else
            -- Stop instant kill thread
            if OneHitSwingThread then
                task.cancel(OneHitSwingThread)
                OneHitSwingThread = nil
            end
        end
    end,
    Icon = "skull"
})

weaponsTab:Section({
    Title = "Gun"
})
weaponsTab:Divider()

weaponsTab:Toggle({
    Title = "Gun Aura",
    Type = "Checkbox",
    Value = GunAura.Enabled,
    Callback = ToggleGunAura,
    Icon = "target"
})

weaponsTab:Toggle({
    Title = "Auto Reload",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            AutoReload()
        end
    end,
    Icon = "refresh-cw"
})

weaponsTab:Toggle({
    Title = "NPC Lock",
    Type = "Checkbox",
    Value = NPCLock.Enabled,
    Callback = ToggleNPCLock,
    Icon = "crosshair"
})

-- Teleports Tab
teleportsTab:Section({
    Title = "Teleports"
})
teleportsTab:Divider()
teleportsTab:Dropdown({
    Title = "Base's",
    Values = {
        "Spawn",
        "10 KM",
        "20 KM",
        "30 KM",
        "40 KM",
        "50 KM",
        "60 KM",
        "70 KM"
    },
    Callback = teleportToBase,
    Icon = "shield"
})

teleportsTab:Dropdown({
    Title = "Towns",
    Values = {"Town 1", "Town 2", "Town 3", "Town 4", "Town 5", "Town 6"},
    Callback = function(selectedTown)
        local townNum = selectedTown:match("%d+") -- Extract the number
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/Tuwn"..townNum
        ))()
    end,
    Icon = "map-pinned"
})

teleportsTab:Button({
    Title = "TP to Train",
    Callback = TeleportToTrain,
    Icon = "train"
})

teleportsTab:Button({
    Title = "TP to Sterling",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Sentaidusty/dustyrails/refs/heads/main/Sterling'))()
    end,
    Icon = "map-pin"
})

teleportsTab:Button({
    Title = "Tp to Outlaw Camp",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fjruie/newshortcamp.github.io/refs/heads/main/ringtashort.lua"))()
    end,
    Icon = "sword"
})

teleportsTab:Button({
    Title = "TP to Tesla",
    Callback = TeleportToTesla,
    Icon = "zap"
})

teleportsTab:Button({
    Title = "TP to Castle",
    Callback = TeleportToCastle,
    Icon = "castle"
})

teleportsTab:Button({
    Title = "TP to End",
    Callback = TeleportToEnd,
    Icon = "flag"
})

teleportsTab:Button({
    Title = "TP to Fort",
    Callback = TeleportToFort,
    Icon = "shield-off"
})

-- Others Tab
othersTab:Button({
    Title = "Infinite Yield",
    Callback = InfiniteYield,
    Icon = "chevrons-left-right-ellipsis"
})

-- Visual Tab
visualTab:Section({
    Title = "Main"
})
visualTab:Divider()

visualTab:Toggle({
    Title = "FullBright",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        FullBright(state)
    end,
    Icon = "sun"
})

visualTab:Toggle({
    Title = "No Fog",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        NoFog(state)
    end,
    Icon = "cloud"
})

visualTab:Section({
    Title = "ESP Features"
})
visualTab:Divider()

visualTab:Toggle({
    Title = "Fuel ESP Items",
    Type = "Checkbox",
    Value = FuelESP.Enabled,
    Callback = function(state)
        FuelESP.Enabled = state
        if state then
            SetupFuelESP()
        else
            -- Clean up existing highlights
            for _, instance in pairs(workspace:GetDescendants()) do
                if instance:GetAttribute("Fuel") then
                    local highlight = FindFirstChildOfType(instance, "Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                    local billboard = FindFirstChildOfType(instance, "BillboardGui")
                    if billboard then
                        billboard:Destroy()
                    end
                end
            end
        end
    end,
    Icon = "fuel"
})

visualTab:Toggle({
    Title = "Show Code Bank",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.EspHighlight = state
        _G.EspGui = state
        _G.EspDistance = state
        
        for _, bankModel in pairs(workspace:GetDescendants()) do
            if bankModel:IsA("Model") and bankModel.Name == "Bank" and bankModel:FindFirstChild("Vault") then
                BankEsp(bankModel)
            end
        end
        
        -- Add listener for new banks
        if state then
            workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Model") and descendant.Name == "Bank" and descendant:FindFirstChild("Vault") then
                    BankEsp(descendant)
                end
            end)
        end
    end,
    Icon = "vault"
})

visualTab:Toggle({
    Title = "Time ESP",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            EspTime()
        else
            local gui = game:GetService("CoreGui"):FindFirstChild("TimeEsp")
            if gui then
                gui:Destroy()
            end
        end
    end,
    Icon = "clock"
})

visualTab:Toggle({
    Title = "Item ESP",
    Type = "Checkbox",
    Value = ItemESP.Enabled,
    Callback = function(state)
        ItemESP.Enabled = state
        for item, data in pairs(ItemCache) do
            if data.highlight then
                data.highlight.Enabled = state
                data.billboard.Enabled = state
            end
        end
        if state and not next(ItemCache) then
            SetupItemESP()
        end
    end,
    Icon = "eye"
})

visualTab:Toggle({
    Title = "Items Value ESP",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            -- Run initial scan
            EspMoney()
            
            -- Set up listener for new money items
            workspace:WaitForChild("RuntimeItems").ChildAdded:Connect(function(child)
                if child:IsA("Model") then
                    EspMoney()
                end
            end)
        else
            -- Clean up all money ESP
            for _, item in pairs(workspace:WaitForChild("RuntimeItems"):GetChildren()) do
                if item:FindFirstChild("MoneyEspGui") then
                    item.MoneyEspGui:Destroy()
                end
            end
        end
    end,
    Icon = "dollar-sign"
})

visualTab:Toggle({
    Title = "Ore ESP",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.EspHighlight = state
        _G.EspGui = state
        _G.EspName = state
        _G.EspDistance = state
        _G.EspHealth = state
        _G.EspOrb = state
        
        if state then
            task.spawn(EspOre)
        end
    end,
    Icon = "mountain"
})

visualTab:Section({
    Title = "Camera"
})
visualTab:Divider()

visualTab:Button({
    Title = "Unlock 3rd Person",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character then
            game.Workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = math.huge
            player.CameraMinZoomDistance = 0
        else
            player.CharacterAdded:Connect(function()
                game.Workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
                player.CameraMode = Enum.CameraMode.Classic
                player.CameraMaxZoomDistance = math.huge
                player.CameraMinZoomDistance = 0
            end)
        end
    end,
    Icon = "camera"
})