-- Fluent UI Library Setup 
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

-- Main Window Creation
local Window = Fluent:CreateWindow({
    Title = "Town of Salem Role Snooper",
    SubTitle = "By BoxTon",
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
})

-- Tab Creation
local Tab = Window:AddTab({Title = "Roles", Icon = "users"})

-- Helper Variables
local rolesAndColors = {
    ["Mafia"] = Color3.fromRGB(255,0,0),
    ["Vampire"] = Color3.fromRGB(0,255,0),
    ["Coven"] = Color3.fromRGB(255,255,0),
    ["Werewolf"] = Color3.fromRGB(64,64,64),
    ['Bodyguard'] = Color3.fromRGB(0,0,255),
    ['Medic'] = Color3.fromRGB(0,0,255),
    ['Guardian'] = Color3.fromRGB(0,0,255),
    ['Vigilante'] = Color3.fromRGB(0,0,255),
    ['Liberator'] = Color3.fromRGB(0,0,255),
    ['Veteran'] = Color3.fromRGB(0,0,255),
    ['Bounty Hunter'] = Color3.fromRGB(0,0,255),
}
local gunsAndRoles = {
    ["Shield"] = "Bodyguard",
    ["Knife"] = "Killer",
    ["GuardianSword"] = "Guardian",
    ["Revolver"] = "Vigilante",
    ["Katana"] = "Assassin",
    ["ShieldK"] = "Liberator",
    ["Medkit"] = "Medic",
    ["Pistol"] = "Veteran",
    ["Winchester"] = "Bounty Hunter",
}

-- Function to Display Roles
local function displayRoles()
    Tab:Clear() -- Clear previous content

    for _, player in pairs(game.Players:GetPlayers()) do
        local role = player:GetAttribute("NSXFA") or "Unknown"

        -- Create a label for each player with their role and number
        Tab:AddLabel({Text = string.format("[%d] %s: %s", player.PlayerData.Number.Value, player.PlayerData.DisplayName.Value, role)})
    end
end
-- AC Bypass Function (USE WITH CAUTION)
function bypassAC()
    local ACRemote = game:GetService("ReplicatedStorage").Remotes.FinishAudio
    hookmetamethod(game, "__namecall", function(self, ...)
        if not checkcaller() and self == ACRemote and getnamecallmethod() == "FireServer" then
            return wait(9e9)
        end
        return bypassAC(self, ...) -- Call the original function
    end)
end


-- Role Snooping Function (USE WITH CAUTION)
function snoopRoles()
    for _, folder in pairs(game:GetService("Workspace").Game:GetChildren()) do
        folder.ChildAdded:Connect(function(p)
            local player = game.Players:FindFirstChild(p.Name)
            if player and (folder.Name == "Mafia" or folder.Name == "Vampire" or folder.Name == "Coven" or folder.Name == "Medium") then
                if not player:GetAttribute("NSXFA") then
                    player:SetAttribute("NSXFA", folder.Name)
                    displayRoles()
                end
                p.ChildAdded:Connect(function(ai)
                    if ai.Name == "WerewolfVal" and not player:GetAttribute("NSXFA") then
                        player:SetAttribute("NSXFA", "Werewolf")
                        displayRoles()
                    end
                end)
            end
        end)
    end

    game.Players.DescendantAdded:Connect(function(t)
        if t:IsA("Tool") then
            local player = t.Parent.Parent
            if not player:GetAttribute("NSXFA") and gunsAndRoles[t.Name] then
                player:SetAttribute("NSXFA", gunsAndRoles[t.Name])
                displayRoles()
            end
        end
    end)
end


-- Overhead Name Modification Function
function modifyOverheadNames()
    for _, player in pairs(game.Players:GetPlayers()) do
        spawn(function() -- Use spawn to handle each player concurrently
            while true do
                local character = player.Character or player.CharacterAdded:Wait()
                local overhead = character:FindFirstChild("Overhead", true)
                if overhead then
                    overhead.AlwaysOnTop = true
                    local role = player:GetAttribute("NSXFA")
                    if player == game.Players.LocalPlayer then
                        overhead.PlayerName.Text = string.format("[%d] %s", player.PlayerData.Number.Value, player.PlayerData.DisplayName.Value)
                        overhead.PlayerName.TextColor3 = Color3.fromRGB(255, 80, 192)
                    elseif role and rolesAndColors[role] then
                        overhead.PlayerName.Text = string.format("[%d] %s", player.PlayerData.Number.Value, player.PlayerData.DisplayName.Value)
                        overhead.PlayerName.TextColor3 = rolesAndColors[role]
                    else
                        overhead.PlayerName.Text = string.format("[%d] %s", player.PlayerData.Number.Value, player.PlayerData.DisplayName.Value)
                        overhead.PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
                wait() -- Avoid excessive CPU usage
            end
        end)
    end
end


-- Initial Setup
displayRoles()
snoopRoles()
modifyOverheadNames()

-- Automatic Updates on Role Changes
game.Players.PlayerAdded:Connect(function(player)
    displayRoles()
    player:GetAttributeChangedSignal("NSXFA"):Connect(displayRoles)
end)
game.Players.PlayerRemoving:Connect(displayRoles)

-- Additional UI Elements
Tab:AddButton({
    Title = "Refresh",
    Description = "Manually refresh the role list",
    Callback = displayRoles
})
Tab:AddToggle("BypassAC", {
    Title = "Bypass Anticheat (Use with caution!)",
    Default = false,
    Callback = function(value)
        if value then
            bypassAC()
        end -- You might need to add a way to disable the bypass if desired
    end
})
-- Save Manager (Optional, for persisting settings)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tab) 
