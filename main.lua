-- Fluent UI Setup
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Town of Salem Role Detection",
    SubTitle = "by YourNameHere",
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


Tabs.Player:AddButton({
    Title = "TP Up ( get above house )",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local HRP = character:FindFirstChild("HumanoidRootPart")
        local newPosition = HRP.Position + Vector3.new(0, 200, 0)
        HRP.CFrame = CFrame.new(newPosition)
        end
})

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService") -- For smooth transitions
local TpToJail = Tabs.Player:AddButton({
    Title = "TP To Jail",
    Callback = function()
        local player = Players.LocalPlayer
        local character = player.Character
        local HRP = character and character:FindFirstChild("HumanoidRootPart")
        local JailCam2 = workspace:FindFirstChild("ExeCameras", true):FindFirstChild("JailCam2")

        if HRP and JailCam2 then
            local targetPosition = JailCam2.Position + Vector3.new(0, 2, 0) -- Adjusted position

            -- Create a TweenInfo for smooth transition
            local tweenInfo = TweenInfo.new(
                1, -- Duration in seconds (adjust as needed)
                Enum.EasingStyle.Quad, -- Easing style for a smoother effect
                Enum.EasingDirection.Out -- Easing direction
            )

            -- Create the tween
            local tween = TweenService:Create(HRP, tweenInfo, {CFrame = CFrame.new(targetPosition)})

            -- Start the tween
            tween:Play()
        end
    end
})

local TpToJailCell = Tabs.Player:AddButton({
    Title = "TP To Jail Cell",
    Callback = function()
        -- (Same logic as TpToJail, but change JailCam2 to JailCam1)
        local player = Players.LocalPlayer
        local character = player.Character
        local HRP = character and character:FindFirstChild("HumanoidRootPart")
        local JailCam1 = workspace:FindFirstChild("ExeCameras", true):FindFirstChild("JailCam1")

        if HRP and JailCam1 then
            local targetPosition = JailCam1.Position + Vector3.new(0, 2, 0) -- Adjusted position

            -- Create a TweenInfo for smooth transition (same as above)
            local tweenInfo = TweenInfo.new(
                1, 
                Enum.EasingStyle.Quad, 
                Enum.EasingDirection.Out 
            )

            -- Create the tween
            local tween = TweenService:Create(HRP, tweenInfo, {CFrame = CFrame.new(targetPosition)})

            -- Start the tween
            tween:Play()
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
    sendmsg("{Town}[" .. playerName .. "]: Role Detection Activated")
    bypac()
    wait(2)
    sendmsg("{Town}[" .. playerName .. "]: Anticheat bypassed!")
    wait(1)
    sendmsg("{Town}[" .. playerName .. "]: Looking for roles..")

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
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)  -- Start on the Main tab

SaveManager:LoadAutoloadConfig() 
