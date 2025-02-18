-- Fluent UI Setup
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "BIG DADDY ZA HUB",
    SubTitle = "BY BIG DADDY ZA",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}
-- UI Toggle to Activate the Script
local Toggle = Tabs.Main:AddToggle("ScriptEnabled", {
    Title = "Activate Role Finder",
    Default = false,
    Callback = function(Value)
        if Value then
            initiateRoleDetection() 
        else
            sendmsg("Script Deactivated")
        end
    end
})

local Noclip = nil
local Clip = false

local NoclipToggle = Tabs.Player:AddToggle("NoclipEnabled", {
    Title = "Enable Noclip",
    Default = false,
    Callback = function(Value)
        Clip = not Value -- Invert the value for noclip logic

        if not Clip and game.Players.LocalPlayer.Character ~= nil then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide then
                    v.CanCollide = false
                end
            end

        else
            if Noclip then 
                Noclip:Disconnect() 
            end
        end
    end
})

-- Run Noclip Check Every Step
game:GetService('RunService').Stepped:Connect(function()
    if not Clip and game.Players.LocalPlayer.Character ~= nil then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA('BasePart') and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

local function forceNoclipOnSpawn()
    if NoclipToggle.Value then -- Check the toggle's current state
        NoclipToggle:Callback(true) -- Re-trigger the callback to apply noclip
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(forceNoclipOnSpawn)
game.Players.LocalPlayer.CharacterAppearanceLoaded:Connect(forceNoclipOnSpawn)

local platform = nil  -- Declare platform outside to track its existence
local connection = nil

Tabs.Player:AddButton({
    Title = "TP Up (get above house)",
    Callback = function()
        local player = game.Players.LocalPlayer
        local HRP = player.Character.HumanoidRootPart
        local currentPos = HRP.Position
        local newPos = Vector3.new(currentPos.X, currentPos.Y + 200, currentPos.Z)
        HRP.CFrame = CFrame.new(newPos)
        -- create part under player
        local part = Instance.new("Part")
        part.Name = "TPPart"
        part.Size = Vector3.new(7,1,7)
        part.Position = HRP.Position - Vector3.new(0,2,0)
        part.Anchored = true
        part.CanCollide = true
        part.Parent = game.Workspace
        end
})

Tabs.Player:AddButton({
    Title = "TP Down ( under map ) ",
    Callback = function()
         local player = game.Players.LocalPlayer
        local HRP = player.Character.HumanoidRootPart
        local currentPos = HRP.Position
        local newPos = Vector3.new(currentPos.X, currentPos.Y - 205, currentPos.Z)
        HRP.CFrame = CFrame.new(newPos)
        -- create part under player
        local part = Instance.new("Part")
        part.Name = "TPPart"
        part.Size = Vector3.new(7,1,7)
        part.Position = HRP.Position - Vector3.new(0,2,0)
        part.Anchored = true
        part.CanCollide = true
        part.Parent = game.Workspace
        end
})

Tabs.Player:AddButton({
    Title = "Join Biggest Server",
    Callback = function ()
            local synapse = syn
            local http = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")

            local gameId = game.PlaceId
            local serversUrl = "https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"

            local response = synapse.request({
                Url = serversUrl,
                Method = "GET"
            }).Body

            local serverData = http:JSONDecode(response)
            local largestServer = nil
            local maxPlayers = 0

            for _, server in ipairs(serverData.data) do
                if server.playing ~= server.maxPlayers and server.playing > maxPlayers then 
                    largestServer = server
                    maxPlayers = server.playing
                end
            end

            if largestServer then
                synapse.queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/EEBroadband/Bloxston/main/main.lua'))()")  
                TeleportService:TeleportToPlaceInstance(gameId, largestServer.id)
            else
                warn("No suitable server found.") 
            end
end
})



-- Main Script Functions

function sendmsg(msg, delay)
    wait(delay or 2)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = msg;
    })
end

local rolesandcolors = {
    ["Mafia"] = Color3.fromRGB(135, 5, 5),
    ["Vampire"] = Color3.fromRGB(240, 29, 29),
    ["Coven"] = Color3.fromRGB(128, 4, 184),
    ["Werewolf"] = Color3.fromRGB(77, 46, 31),
    ["Bodyguard"] = Color3.fromRGB(0, 0, 255),
    ["Doctor"] = Color3.fromRGB(132, 255, 0),
    ["GA"] = Color3.fromRGB(223, 224, 225),
    ["Vigilante"] = Color3.fromRGB(132, 255, 0),
    ["Liberator"] = Color3.fromRGB(132, 255, 0),
    ["Veteran"] = Color3.fromRGB(132, 255, 0),
    ["Bounty Hunter"] = Color3.fromRGB(132, 255, 0),
}

local gunsandroles = {
    ["Shield"] = "Bodyguard",
    ["Knife"] = "Killer",
    ["GuardianSword"] = "GA",
    ["Revolver"] = "Vigilante",
    ["Katana"] = "Assassin",
    ["ShieldK"] = "Liberator",
    ["Medkit"] = "Doctor",
    ["Pistol"] = "Veteran",
    ["Winchester"] = "Bounty Hunter",
}

function bypac()
    local ACRemote = game:GetService("ReplicatedStorage").Remotes.FinishAudio
    local ACBypass
    ACBypass = hookmetamethod(game, "__namecall", function(...)
        local method = getnamecallmethod();
        local args = ...;

        if not checkcaller() then
            if typeof(self) == "Instance" and self == ACRemote and method == "FireServer" then
                return wait(9e9);
            end
        end
        return ACBypass(...)
    end)
end

function initiateRoleDetection()
    local playerName = game.Players.LocalPlayer.Name
    sendmsg("{Town} [" .. playerName .. "]: Role Detection Activated")
    bypac()
    wait(2)
    sendmsg("{Town} [" .. playerName .. "]: Anticheat bypassed!")
    wait(1)
    sendmsg("{Town} [" .. playerName .. "]: Looking for roles..")

    -- Role Detection Logic
    for i,v in pairs(game:GetService("Workspace").Game:GetChildren()) do
        local folder = v.Name
        v.ChildAdded:Connect(function(p)
            local plr = game.Players:FindFirstChild(p.Name)
            if folder == "Mafia" or folder == "Vampire" or folder == "Coven" or folder == "Medium" then
                if not plr:GetAttribute("NSXFA") then
                    plr:SetAttribute("NSXFA",folder)
                    sendmsg('[' .. plr:GetAttribute("NSXFA") .. "] (" .. plr.PlayerData.DisplayName.Value .. ")[" .. plr.PlayerData.Number.Value .. "] has been exposed \n")
                end
                p.ChildAdded:Connect(function(ai)
                    if ai == "WerewolfVal" then
                        if not plr:GetAttribute("NSXFA") then
                            plr:SetAttribute("NSXFA","Werewolf")
                            sendmsg('[' .. plr:GetAttribute("NSXFA") .. "] (" .. plr.PlayerData.DisplayName.Value .. ")[" .. plr.PlayerData.Number.Value .. "] has been exposed \n")
                        end
                    end
                end)
            end
        end)
    end

    game.Players.DescendantAdded:Connect(function(t)
        if t:IsA("Tool") then
            local plr = t.Parent.Parent
            local tool = t
            if not game.Players:FindFirstChild(t.Parent.Parent.Name):GetAttribute("NSXFA") then
                if gunsandroles[t.Name] ~= nil then
                    plr:SetAttribute("NSXFA",gunsandroles[t.Name])
                end
                wait()
                sendmsg("[" .. (plr:GetAttribute("NSXFA") or "Unknown") .. "] (" .. plr.PlayerData.DisplayName.Value .. ")[" .. plr.PlayerData.Number.Value .. "] was found with " .. tool.Name .. '\n')
            end
        end
    end)

    -- Overhead Display Logic
    for i,plr in pairs(game.Players:GetChildren()) do 
        local v = plr
        if plr:GetAttribute("NSXFA") then 
            sendmsg('[' .. plr:GetAttribute("NSXFA") .. "] (" .. plr.PlayerData.DisplayName.Value .. ")[" .. plr.PlayerData.Number.Value .. "] has been exposed \n")
        end

        spawn(function()
            while wait() do 
                local charr = v.Character or v.CharacterAdded:Wait()

                local oh = charr:FindFirstChild("Overhead",true)
                if oh then 
                    oh.AlwaysOnTop = true
                    if v == game.Players.LocalPlayer then
                        oh.PlayerName.Text = '[' .. plr.PlayerData.Number.Value .. '] ' .. plr.PlayerData.DisplayName.Value
                        oh.PlayerName.TextColor3 = Color3.fromRGB(255,80,192)
                    elseif v:GetAttribute("NSXFA")~= nil and rolesandcolors[v:GetAttribute("NSXFA")] ~= nil then 
                        oh.PlayerName.Text = '[' .. plr.PlayerData.Number.Value .. '] ' .. plr.PlayerData.DisplayName.Value
                        oh.PlayerName.TextColor3 = rolesandcolors[v:GetAttribute("NSXFA")]
                    else
                        oh.PlayerName.Text = '[' .. plr.PlayerData.Number.Value .. '] ' .. plr.PlayerData.DisplayName.Value
                        oh.PlayerName.TextColor3 = Color3.fromRGB(255,255,255)
                    end 
                end 
            end 
        end)
    end
end


-- Fluent Addons Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Arvums")
SaveManager:SetFolder("Arvums/Bloxston")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)  -- Start on the Main tab

SaveManager:LoadAutoloadConfig()
