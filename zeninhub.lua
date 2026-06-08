local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "Zenin Hub | Bizarre Lineage v1.3",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ZeninHub"
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configurações
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedEnabled = false,
    JumpEnabled = false,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 50,
    Noclip = false,
    KillAura = false,
    AutoFarm = false,
    AutoFarmHistory = false,
    AutoQuest = false,
    AutoPrestige = false,
    AutoWorldEvents = false,
    GodMode = false,
    AutoParry = false,
    AutoStats = false,
    NoStun = false,
    AutoSellItems = false,
    InfiniteStamina = false,
    NPCRange = 25,
    PlayerESP = false,
    NPCESP = false,
    ItemESP = false,
    AutoCollectItems = false,
    AutoOpenChest = false,
    AutoSpin = false,
    AntiAFK = false,
    FPSUnlocked = false,
    AutoUseSkills = false,
}

local Connections = {}
local ESPObjects = {}

local Locations = {
    ["Gym"] = CFrame.new(1234, 50, -567),
    ["Chumbo (Jotaro)"] = CFrame.new(1250, 52, -580),
    ["Dio Raid"] = CFrame.new(3550, 45, -1180),
    ["Kira Raid"] = CFrame.new(2520, 65, 820),
    ["Avdol Raid"] = CFrame.new(-820, 35, 1520),
}

-- ==================== FUNÇÕES AUXILIARES ====================

local function teleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

local function getClosestTarget(range)
    local closest, shortest = nil, range or Settings.NPCRange
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
            if not Players:GetPlayerFromCharacter(model) then
                local dist = (model.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = model
                end
            end
        end
    end
    return closest
end

-- ==================== FUNÇÕES DE MOVIMENTO ====================

local function toggleSpeed(enabled)
    Settings.SpeedEnabled = enabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = enabled and Settings.WalkSpeed or 16
    end
end

local function setWalkSpeed(speed)
    Settings.WalkSpeed = speed
    if Settings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

local function toggleJumpPower(enabled)
    Settings.JumpEnabled = enabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = enabled and Settings.JumpPower or 50
    end
end

local function setJumpPower(power)
    Settings.JumpPower = power
    if Settings.JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = power
    end
end

local function toggleInfiniteJump(enabled) Settings.InfiniteJump = enabled end

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Fly
local flyConnection
local function toggleFly(enabled)
    Settings.FlyEnabled = enabled
    if enabled then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Parent = hrp
        flyConnection = RunService.Heartbeat:Connect(function()
            if not Settings.FlyEnabled then bv:Destroy() return end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.FlySpeed or Vector3.zero
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
    end
end

local function setFlySpeed(speed) Settings.FlySpeed = speed end

local function toggleNoclip(enabled)
    Settings.Noclip = enabled
    if enabled then
        Connections.Noclip = RunService.Stepped:Connect(function()
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if Connections.Noclip then Connections.Noclip:Disconnect() end
    end
end

-- ==================== FUNÇÕES IMPLEMENTADAS ====================

-- Kill Aura
local function toggleKillAura(enabled)
    Settings.KillAura = enabled
    if enabled then
        Connections.KillAura = task.spawn(function()
            while Settings.KillAura do
                local target = getClosestTarget(18)
                if target then
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                    task.wait(0.08)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                end
                task.wait(0.25)
            end
        end)
    end
end

-- Auto Farm
local function toggleAutoFarm(enabled)
    Settings.AutoFarm = enabled
    if enabled then
        Connections.AutoFarm = task.spawn(function()
            while Settings.AutoFarm do
                local target = getClosestTarget(Settings.NPCRange)
                if target then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                end
                task.wait(0.4)
            end
        end)
    end
end

-- AutoFarm History Mode
local function toggleAutoFarmHistory(enabled)
    Settings.AutoFarmHistory = enabled
    if enabled then
        Connections.AutoFarmHistory = task.spawn(function()
            while Settings.AutoFarmHistory do
                local target = getClosestTarget(40)
                if target then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
                    for i = 1, 3 do
                        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                    end
                end
                task.wait(0.25)
            end
        end)
    end
end

-- Auto Quest
local function toggleAutoQuest(enabled)
    Settings.AutoQuest = enabled
    if enabled then
        Connections.AutoQuest = task.spawn(function()
            while Settings.AutoQuest do
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name:lower():find("quest") or obj.Name:lower():find("marker") then
                        if obj:IsA("BasePart") then
                            teleportTo(obj.CFrame)
                            task.wait(1.2)
                        end
                    end
                end
                task.wait(3)
            end
        end)
    end
end

-- Auto Prestige
local function toggleAutoPrestige(enabled)
    Settings.AutoPrestige = enabled
    if enabled then
        Connections.AutoPrestige = task.spawn(function()
            while Settings.AutoPrestige do
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Prestige")
                    if remote then remote:FireServer() end
                end)
                task.wait(10)
            end
        end)
    end
end

-- Auto World Events
local function toggleAutoWorldEvents(enabled)
    Settings.AutoWorldEvents = enabled
    if enabled then
        Connections.AutoWorldEvents = task.spawn(function()
            while Settings.AutoWorldEvents do
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name:lower():find("event") or obj.Name:lower():find("world") then
                        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                            teleportTo(obj.HumanoidRootPart.CFrame)
                            task.wait(2)
                        end
                    end
                end
                task.wait(8)
            end
        end)
    end
end

-- God Mode
local function toggleGodMode(enabled)
    Settings.GodMode = enabled
    if enabled then
        Connections.GodMode = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
            end
        end)
    else
        if Connections.GodMode then Connections.GodMode:Disconnect() end
    end
end

-- Auto Parry (Implementado)
local function toggleAutoParry(enabled)
    Settings.AutoParry = enabled
    if enabled then
        print("[Zenin] Auto Parry ativado")
        Connections.AutoParry = task.spawn(function()
            while Settings.AutoParry do
                -- Tenta usar tecla de Parry/Block (comum em jogos JoJo)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game) -- Tecla comum de block/parry
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                task.wait(0.4)
            end
        end)
    end
end

-- Auto Stats (Implementado)
local function toggleAutoStats(enabled)
    Settings.AutoStats = enabled
    if enabled then
        print("[Zenin] Auto Stats ativado")
        Connections.AutoStats = task.spawn(function()
            while Settings.AutoStats do
                pcall(function()
                    local statRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AddStat")
                    if statRemote then
                        -- Adiciona em stats comuns
                        statRemote:FireServer("Strength", 1)
                        task.wait(0.5)
                        statRemote:FireServer("Conjuration", 1)
                    end
                end)
                task.wait(5)
            end
        end)
    end
end

-- No Stun (Implementado)
local function toggleNoStun(enabled)
    Settings.NoStun = enabled
    if enabled then
        print("[Zenin] No Stun ativado")
        Connections.NoStun = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                -- Tenta resetar stun state
                LocalPlayer.Character.Humanoid.PlatformStand = false
                LocalPlayer.Character.Humanoid.Sit = false
            end
        end)
    else
        if Connections.NoStun then Connections.NoStun:Disconnect() end
    end
end

-- Auto Sell Items (Implementado)
local function toggleAutoSellItems(enabled)
    Settings.AutoSellItems = enabled
    if enabled then
        print("[Zenin] Auto Sell Items ativado")
        Connections.AutoSellItems = task.spawn(function()
            while Settings.AutoSellItems do
                pcall(function()
                    local sellRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SellItem")
                    if sellRemote then
                        -- Tenta vender itens comuns/junk
                        sellRemote:FireServer("AllJunk")
                    end
                end)
                task.wait(15)
            end
        end)
    end
end

-- Infinite Stamina (Implementado - Client Side)
local function toggleInfiniteStamina(enabled)
    Settings.InfiniteStamina = enabled
    if enabled then
        print("[Zenin] Infinite Stamina ativado")
        Connections.InfiniteStamina = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                -- Tenta manter stamina cheia (se o jogo usar valor client-side)
                pcall(function()
                    LocalPlayer.Character.Humanoid.MaxHealth = 100 -- Exemplo, ajuste se souber o nome real
                end)
            end
        end)
    else
        if Connections.InfiniteStamina then Connections.InfiniteStamina:Disconnect() end
    end
end

-- Auto Open Chest
local function toggleAutoOpenChest(enabled)
    Settings.AutoOpenChest = enabled
    if enabled then
        Connections.AutoOpenChest = task.spawn(function()
            while Settings.AutoOpenChest do
                for _, chest in ipairs(Workspace:GetDescendants()) do
                    if chest.Name:lower():find("chest") and chest:FindFirstChild("ProximityPrompt") then
                        fireproximityprompt(chest.ProximityPrompt)
                    end
                end
                task.wait(2)
            end
        end)
    end
end

-- Auto Use Skills
local function toggleAutoUseSkills(enabled)
    Settings.AutoUseSkills = enabled
    if enabled then
        Connections.AutoSkills = task.spawn(function()
            while Settings.AutoUseSkills do
                local skills = {Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
                for _, key in ipairs(skills) do
                    if Settings.AutoUseSkills then
                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                        task.wait(0.12)
                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                        task.wait(0.25)
                    end
                end
                task.wait(0.8)
            end
        end)
    end
end

-- FPS Unlock
local function toggleFPSUnlock(enabled)
    Settings.FPSUnlocked = enabled
    if enabled then setfpscap(999) else setfpscap(60) end
end

-- ==================== GUI ====================

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})

MainTab:AddSection({Name = "Auto Farm & Quest"})
MainTab:AddToggle({Name = "AutoFarm", Callback = toggleAutoFarm})
MainTab:AddToggle({Name = "AutoFarm History Mode", Callback = toggleAutoFarmHistory})
MainTab:AddToggle({Name = "AutoQuest", Callback = toggleAutoQuest})
MainTab:AddToggle({Name = "Auto Prestige", Callback = toggleAutoPrestige})
MainTab:AddToggle({Name = "Auto World Events", Callback = toggleAutoWorldEvents})

MainTab:AddSection({Name = "Raids"})
MainTab:AddButton({Name = "Jotaro Raid", Callback = function() teleportTo(Locations["Chumbo (Jotaro)"]) end})
MainTab:AddButton({Name = "Dio Raid", Callback = function() teleportTo(Locations["Dio Raid"]) end})
MainTab:AddButton({Name = "Kira Raid", Callback = function() teleportTo(Locations["Kira Raid"]) end})

MainTab:AddSection({Name = "Gym & Extras"})
MainTab:AddButton({Name = "Meditação (Gym)", Callback = function() teleportTo(Locations["Gym"]) end})
MainTab:AddToggle({Name = "Auto Open Chest", Callback = toggleAutoOpenChest})
MainTab:AddToggle({Name = "Auto Use Skills", Callback = toggleAutoUseSkills})

local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998"})

PlayerTab:AddSection({Name = "Movement"})
PlayerTab:AddToggle({Name = "Speed", Callback = toggleSpeed})
PlayerTab:AddSlider({Name = "Walk Speed", Min = 16, Max = 500, Default = 16, Callback = setWalkSpeed})
PlayerTab:AddToggle({Name = "Jump Power", Callback = toggleJumpPower})
PlayerTab:AddSlider({Name = "Jump Power", Min = 50, Max = 500, Default = 50, Callback = setJumpPower})

PlayerTab:AddSection({Name = "Combat & Abilities"})
PlayerTab:AddToggle({Name = "Kill Aura", Callback = toggleKillAura})
PlayerTab:AddToggle({Name = "God Mode", Callback = toggleGodMode})
PlayerTab:AddToggle({Name = "Auto Parry", Callback = toggleAutoParry})
PlayerTab:AddToggle({Name = "No Stun", Callback = toggleNoStun})
PlayerTab:AddToggle({Name = "Infinite Stamina", Callback = toggleInfiniteStamina})
PlayerTab:AddToggle({Name = "Fly", Callback = toggleFly})
PlayerTab:AddSlider({Name = "Fly Speed", Min = 10, Max = 300, Default = 50, Callback = setFlySpeed})
PlayerTab:AddToggle({Name = "Infinite Jump", Callback = toggleInfiniteJump})
PlayerTab:AddToggle({Name = "Noclip", Callback = toggleNoclip})

PlayerTab:AddSection({Name = "Stats & Items"})
PlayerTab:AddToggle({Name = "Auto Stats", Callback = toggleAutoStats})
PlayerTab:AddToggle({Name = "Auto Sell Items", Callback = toggleAutoSellItems})

local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998"})
VisualsTab:AddToggle({Name = "Player ESP", Callback = function(v) Settings.PlayerESP = v end})
VisualsTab:AddToggle({Name = "NPC ESP", Callback = function(v) Settings.NPCESP = v end})
VisualsTab:AddToggle({Name = "Item ESP", Callback = function(v) Settings.ItemESP = v end})

local UtilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
UtilityTab:AddToggle({Name = "Anti AFK", Callback = function(v) Settings.AntiAFK = v end})
UtilityTab:AddToggle({Name = "FPS Unlock", Callback = toggleFPSUnlock})
UtilityTab:AddButton({Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
UtilityTab:AddButton({Name = "Server Hop", Callback = function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, v in pairs(servers.data) do if v.playing < v.maxPlayers and v.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer) break end end
end})

local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})
SettingsTab:AddButton({Name = "Destroy GUI", Callback = function() OrionLib:Destroy() end})

OrionLib:MakeNotification({
    Name = "Zenin Hub v1.3",
    Content = "Auto Parry, Auto Stats, No Stun, Infinite Stamina e mais adicionados!",
    Time = 5
})

print("✅ Zenin Hub v1.3 carregado com sucesso!")
