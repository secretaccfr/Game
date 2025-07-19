get_service = setmetatable({}, {
    __index = function(self, index)
        return cloneref(game.GetService(game, index))
    end
})

local proximityprompt_service = get_service.ProximityPromptService
local marketplace_service = get_service.MarketplaceService
local replicated_storage = get_service.ReplicatedStorage
local user_input_service = get_service.UserInputService
local virtual_user = get_service.VirtualUser
local run_service = get_service.RunService
local workspace = get_service.Workspace
local players = get_service.Players
local stats = get_service.Stats

local auto_farm = false

local info = marketplace_service:GetProductInfo(game.PlaceId)
local local_player = players.LocalPlayer
local backpack = local_player.Backpack

local world = workspace:FindFirstChild("World")

if not world then
    return local_player:Kick("World folder not found")
end

local npcs = world:FindFirstChild("NPCs")

if not npcs then
    return local_player:Kick("NPCs folder not found")
end

local zones = world:FindFirstChild("Zones"):FindFirstChild("_Ambience")

if not zones then
    return local_player:Kick("Zones folder not found")
end

local hole_folders = world:FindFirstChild("Zones"):FindFirstChild("_NoDig")

if not hole_folders then
    return local_player:Kick("Holes folder not found")
end

local totems = workspace:FindFirstChild("Active"):FindFirstChild("Totems")

if not totems then
    return local_player:Kick("Totems folder not found")
end

local bosses = workspace:FindFirstChild("Spawns"):FindFirstChild("BossSpawns")

if not bosses then
    return local_player:Kick("Bosses folder not found")
end

local purchaseable_names = {}
local boss_names = {}
local zone_names = {}
local npc_names = {}

local staff_option = "Notify"
local dig_method = "Fire Signal"
local dig_option = "Legit"

local auto_sell_delay = 5
local tp_walk_speed = 10

local auto_pizza = false
local anti_staff = false
local auto_sell = false
local auto_hole = false
local inf_jump = false
local anti_afk = false
local auto_dig = false

function get_tool()
    return local_player.Character:FindFirstChildOfClass("Tool")
end

function closest_totem()
    local totem = nil
    local dist = 9e99

    for _, v in totems:GetChildren() do
        if v:GetAttribute("IsActive") then
            local distance = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
            if distance < dist then
                dist = distance
                totem = v
            end
        end
    end

    return totem
end

local anti_afk_connections = local_player.Idled:Connect(function()
    if anti_afk then
        virtual_user:CaptureController()
        virtual_user:ClickButton2(Vector2.new())
    end
end)

local dig_connection = local_player.PlayerGui.ChildAdded:Connect(function(v)
    if auto_dig and not auto_pizza and v.Name == "Dig" then
        local strong_hit = v:FindFirstChild("Safezone"):FindFirstChild("Holder"):FindFirstChild("Area_Strong")
        local player_bar = v:FindFirstChild("Safezone"):FindFirstChild("Holder"):FindFirstChild("PlayerBar")
        local mobile_button = v:FindFirstChild("MobileClick")
        local minigame_connection = player_bar:GetPropertyChangedSignal("Position"):Connect(function()
            if not auto_dig or auto_pizza then return end
            if dig_option == "Legit" and math.abs(player_bar.Position.X.Scale - strong_hit.Position.X.Scale) <= 0.04 then
                if dig_method == "Fire Signal" then
                    firesignal(mobile_button.Activated)
                    task.wait()
                elseif dig_method == "Tool Activate" then
                    local tool = get_tool()
                    if tool then
                        tool:Activate()
                        task.wait()
                    end
                end
            elseif dig_option == "Blatant" then
                player_bar.Position = UDim2.new(strong_hit.Position.X.Scale, 0, 0, 0)
                if dig_method == "Fire Signal" then
                    firesignal(mobile_button.Activated)
                    task.wait()
                elseif dig_method == "Tool Activate" then
                    local tool = get_tool()
                    if tool then
                        tool:Activate()
                        task.wait()
                    end
                end
            end
        end)
    end
end)

user_input_service.JumpRequest:Connect(function()
    if inf_jump and not tweeksiscute then
        tweeksiscute = true
        local_player.Character:FindFirstChild("Humanoid"):ChangeState("Jumping")
        wait()
        tweeksiscute = false
    end
end)

local movement_connection = run_service.Heartbeat:Connect(function()
    if tp_walk and local_player.Character:FindFirstChild("Humanoid") then
        if local_player.Character.Humanoid.MoveDirection.Magnitude > 0 then
            local_player.Character:TranslateBy(local_player.Character.Humanoid.MoveDirection * tp_walk_speed / 10)
        end
    end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Tuff Guys | Dig V1",
    Icon = "rbxassetid://130506306640152",
    IconThemed = true,
    Author = "Tuff Agsy",
    Folder = "DigTuff",
    Size = UDim2.fromOffset(580, 380),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
})

Window:SetBackgroundImage("rbxassetid://130506306640152")
Window:SetBackgroundImageTransparency(0.8)
Window:DisableTopbarButtons({"Fullscreen"})

Window:EditOpenButton({
    Title = "Tuff Guys | Dig V1",
    Icon = "shovel",
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

local discordTab = Window:Tab({
    Title = "Important",
    Icon = "bell"
})

local farm_tab = Window:Tab({
    Title = "Farm",
    Icon = "tractor",
    Locked = false,
})

local misc_tab = Window:Tab({
    Title = "Misc",
    Icon = "cog",
    Locked = false,
})

local inventory_tab = Window:Tab({
    Title = "Inventory",
    Icon = "backpack",
    Locked = false,
})

local teleport_tab = Window:Tab({
    Title = "Teleport",
    Icon = "flip-horizontal-2",
    Locked = false,
})

Window:SelectTab(1)

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

farm_tab:Section(
    {
        Title = "Dig Settings",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

farm_tab:Toggle({
    Title = "Auto Dig Minigame",
    Desc = "Automatically does the dig minigame for you",
    Icon = "check",
    Type = "Checkbox",
    Default = auto_dig,
    Callback = function(value)
        auto_dig = value
        if value then
            if local_player.PlayerGui:FindFirstChild("Dig") and not auto_pizza then
                local strong_hit = local_player.PlayerGui.Dig:FindFirstChild("Safezone"):FindFirstChild("Holder"):FindFirstChild("Area_Strong")
                local player_bar = local_player.PlayerGui.Dig:FindFirstChild("Safezone"):FindFirstChild("Holder"):FindFirstChild("PlayerBar")
                local mobile_button = local_player.PlayerGui.Dig:FindFirstChild("MobileClick")
                local minigame_connection = player_bar:GetPropertyChangedSignal("Position"):Connect(function()
                    if not auto_dig then return end
                    if dig_option == "Legit" and math.abs(player_bar.Position.X.Scale - strong_hit.Position.X.Scale) <= 0.04 then
                        if dig_method == "Fire Signal" then
                            firesignal(mobile_button.Activated)
                            task.wait()
                        elseif dig_method == "Tool Activate" then
                            local tool = get_tool()
                            if tool then
                                tool:Activate()
                                task.wait()
                            end
                        end
                    elseif dig_option == "Blatant" then
                        player_bar.Position = UDim2.new(strong_hit.Position.X.Scale, 0, 0, 0)
                        if dig_method == "Fire Signal" then
                            firesignal(mobile_button.Activated)
                            task.wait()
                        elseif dig_method == "Tool Activate" then
                            local tool = get_tool()
                            if tool then
                                tool:Activate()
                                task.wait()
                            end
                        end
                    end
                end)
            end
        end
    end
})

Instance.new("RemoteEvent", replicated_storage:FindFirstChild("Remotes")).Name = "bWFkZSBieSBAa3lsb3NpbGx5IG9uIGRpc2NvcmQgPDM"

farm_tab:Toggle({
    Title = "Auto Holes",
    Desc = "Creates holes if not in dig minigame",
    Icon = "check",
    Type = "Checkbox",
    Default = auto_hole,
    Callback = function(value) 
        auto_hole = value
        if value then
            repeat
                if not auto_pizza then
                    local tool = get_tool()
                    if not tool or not tool.Name:find("Shovel") then
                        for _, v in backpack:GetChildren() do
                            if v.Name:find("Shovel") then
                                v.Parent = local_player.Character
                            end
                        end
                    end
                    if hole_folders:FindFirstChild(local_player.Name.."_Crater_Hitbox") then
                        hole_folders[local_player.Name.."_Crater_Hitbox"]:Destroy()
                    end
                    if not local_player.PlayerGui:FindFirstChild("Dig") then
                        tool:Activate()
                    end
                end
                task.wait(.5)
            until not auto_hole
        end
    end
})

farm_tab:Dropdown({
    Title = "Choose Dig Option:",
    Values = { "Legit", "Blatant"},
    Value = dig_option,
    Callback = function(value)
        dig_option = value
    end
})

farm_tab:Section(
    {
        Title = "Farm Settings",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

farm_tab:Toggle({
    Title = "Auto Pizza Delivery",
    Desc = "Automatically does pizza deliverys",
    Icon = "check",
    Type = "Checkbox",
    Default = auto_pizza,
    Callback = function(value) 
        auto_pizza = value
        if value then
            repeat
                replicated_storage:WaitForChild("Remotes"):WaitForChild("Change_Zone"):FireServer("Penguins Pizza")
                replicated_storage:WaitForChild("DialogueRemotes"):WaitForChild("StartInfiniteQuest"):InvokeServer("Pizza Penguin")
                wait(math.random(1, 3))
                local_player.Character:MoveTo(workspace:FindFirstChild("Active"):FindFirstChild("PizzaCustomers"):FindFirstChildOfClass("Model"):GetPivot().Position)
                wait(math.random(2, 5))
                replicated_storage:WaitForChild("Remotes"):WaitForChild("Quest_DeliverPizza"):InvokeServer()
                wait(math.random(1, 3))
                replicated_storage:WaitForChild("Remotes"):WaitForChild("Change_Zone"):FireServer("Penguins Pizza")
                replicated_storage:WaitForChild("DialogueRemotes"):WaitForChild("CompleteInfiniteQuest"):InvokeServer("Pizza Penguin")
                task.wait(math.random(60, 90))
            until not auto_pizza
        end
    end
})

misc_tab:Section(
    {
        Title = "Staff Settings",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

function is_staff(v)
    local rank = v:GetRankInGroup(35289532)
    local role = v:GetRoleInGroup(35289532)
    if rank >= 2 then
        if staff_warn_method == "Kick" then
            local_player:Kick(role.." detected! Username: "..v.DisplayName)
        elseif staff_warn_method == "Notify" then
            WindUI:Notify(
                {
                    Title = "Staff Detected!",
                    Content = role.." detected! Username: "..v.DisplayName,
                    Icon = "message-circle-warning",
                    Duration = 5
                }
            )
        end
    end
end

local player_join_connection = players.PlayerAdded:Connect(function(v)
    is_staff(v)
end)

misc_tab:Toggle({
    Title = "Anti Staff",
    Desc = "Kicks/Notifies you when staff joins",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(value) 
        anti_staff = value
        if value then
            for _, v in players:GetPlayers() do
                if v ~= local_player then
                    is_staff(v)
                end
            end
        end
    end
})

misc_tab:Dropdown({
    Title = "Choose Staff Method:",
    Values = { "Notify", "Kick" },
    Value = staff_option,
    Callback = function(value) 
        staff_option = value
    end
})

misc_tab:Section(
    {
        Title = "Anti Afk Settings",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

misc_tab:Toggle({
    Title = "Anti Afk",
    Desc = "Wont disconnect you after 20 minutes",
    Icon = "check",
    Type = "Checkbox",
    Default = anti_afk,
    Callback = function(value) 
        anti_afk = value
    end
})

misc_tab:Section(
    {
        Title = "LocalPlayer Settings",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

misc_tab:Toggle({
    Title = "Inf Jump",
    Desc = "Lets you jump infinitely",
    Icon = "check",
    Type = "Checkbox",
    Default = inf_jump,
    Callback = function(value) 
        inf_jump = value
    end
})

misc_tab:Toggle({
    Title = "Tp Walk",
    Desc = "Lets You Move Fast",
    Icon = "check",
    Type = "Checkbox",
    Default = tp_walk,
    Callback = function(value) 
        tp_walk = value
    end
})

misc_tab:Slider({
    Title = "Tp Walk Speed:",
    Step = 1,
    
    Value = {
        Min = 1,
        Max = 100,
        Default = tp_walk_speed,
    },
    Callback = function(value)
        tp_walk_speed = tonumber(value)
    end
})

inventory_tab:Section(
    {
        Title = "Sell Settings",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

inventory_tab:Toggle({
    Title = "Auto Sell",
    Desc = "Automatically sells every item in your inventory",
    Icon = "check",
    Type = "Checkbox",
    Default = auto_sell,
    Callback = function(value) 
        auto_sell = value
        if value then
            repeat
                for _, v in backpack:GetChildren() do
                    replicated_storage:WaitForChild("DialogueRemotes"):WaitForChild("SellHeldItem"):FireServer(v)
                end
                task.wait(sell_delay)
            until not auto_sell
        end
    end
})

inventory_tab:Slider({
    Title = "Auto Sell Delay:",
    Step = 1,
    
    Value = {
        Min = 1,
        Max = 60,
        Default = sell_delay,
    },
    Callback = function(value)
        sell_delay = tonumber(value)
    end
})

inventory_tab:Button({
    Title = "Sell All Items Once",
    Desc = "Sells all items in your inventory",
    Locked = false,
    Callback = function()
        for _, v in backpack:GetChildren() do
            replicated_storage:WaitForChild("DialogueRemotes"):WaitForChild("SellHeldItem"):FireServer(v)
        end
    end
})

inventory_tab:Button({
    Title = "Sell Held Item",
    Desc = "Sells held item",
    Locked = false,
    Callback = function()
        local tool = get_tool()
        if not tool then
            return WindUI:Notify(
                {
                    Title = "No Tool",
                    Content = "No Tool Found!",
                    Icon = "message-circle-warning",
                    Duration = 5
                }
            )
        end
        if not tool:GetAttribute("InventoryLink") then
            return WindUI:Notify(
                {
                    Title = "Cant Sell!",
                    Content = "Cant Sell This Item!",
                    Icon = "message-circle-warning",
                    Duration = 5
                }
            )
        end
        replicated_storage:WaitForChild("DialogueRemotes"):WaitForChild("SellHeldItem"):FireServer(tool)
    end
})

inventory_tab:Section(
    {
        Title = "Journal Settings",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

inventory_tab:Button({
    Title = "Claim Unclaimed Discovered Items",
    Desc = "Claims every unclaimed Discovered item in journal",
    Locked = false,
    Callback = function()
        for _, v in local_player.PlayerGui:FindFirstChild("HUD"):FindFirstChild("Frame"):FindFirstChild("Journal"):FindFirstChild("Scroller"):GetChildren() do
            if v:IsA("ImageButton") and v:FindFirstChild("Discovered").Visible then
                firesignal(v.MouseButton1Click)
            end
        end
    end
})

teleport_tab:Section(
    {
        Title = "Misc Teleports",
        TextXAlignment = "Left",
        TextSize = 17
    }
)

teleport_tab:Button({
    Title = "Teleport To Merchant",
    Desc = "Teleports to merchant",
    Locked = false,
    Callback = function()
        local_player.Character:MoveTo(npcs:FindFirstChild("Merchant Cart"):GetPivot().Position)
    end
})

teleport_tab:Button({
    Title = "Teleport To Meteor",
    Desc = "Teleports to meteor",
    Locked = false,
    Callback = function()
        if workspace:FindFirstChild("Active"):FindFirstChild("ActiveMeteor") then
            local_player.Character:MoveTo(workspace.Active.ActiveMeteor:GetPivot().Position)
        else
            WindUI:Notify(
                {
                    Title = "No Meteor",
                    Content = "No Meteor Found!",
                    Icon = "message-circle-warning",
                    Duration = 5
                }
            )
        end
    end
})

teleport_tab:Button({
    Title = "Teleport To Enchantment Altar",
    Desc = "Teleports to EnchantmentAltar",
    Locked = false,
    Callback = function()
        local_player.Character:MoveTo(world:FindFirstChild("Interactive"):FindFirstChild("Enchanting"):FindFirstChild("EnchantmentAltar"):FindFirstChild("EnchantPart"):GetPivot().Position)
    end
})

teleport_tab:Button({
    Title = "Teleport To Active Totem",
    Desc = "Teleports to closest active totem",
    Locked = false,
    Callback = function()
        local totem = closest_totem()
        if not totem then
            return WindUI:Notify(
                {
                    Title = "No Totem",
                    Content = "No Active Totem Found!",
                    Icon = "message-circle-warning",
                    Duration = 5
                }
            )
        end
        local_player.Character:MoveTo(totem:GetPivot().Position)
    end
})