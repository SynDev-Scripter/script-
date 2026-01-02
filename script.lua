local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ CONFIG ]] --
local UserID = game.Players.LocalPlayer.UserId
local IsPremium = (UserID == 9638738002)

-- We use os.time() so GitHub doesn't show an old "cached" version of your keys
local KeyURL = "https://raw.githubusercontent.com/SynDev-Scripter/STFO-Key-Database/refs/heads/main/keys.txt?t=" .. os.time()

local Window = Rayfield:CreateWindow({
   Name = "Steal Infinite",
   LoadingTitle = "Loading Steal Infinite...",
   KeySystem = false,
   KeySettings = {
      Title = "Key System",
      Subtitle = "Join Discord for Key",
      Note = "Use /key in our Discord server to get access!",
      FileName = "StealInfinite_Key", 
      SaveKey = true, 
      GrabKeyFromSite = true,
      Key = {KeyURL} -- Fixed: Now uses the variable with quotes
   }
})

-- [[ AUTO-BYPASS FOR YOU ]] --
if IsPremium then
    Rayfield:Notify({Title = "Owner Login", Content = "Premium detected. Welcome back!"})
    -- Note: Rayfield will still show the key UI for a second, then close it if the ID matches.
end

-- [[ VARIABLES ]] --
local lp = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local SelectedTarget = nil
local ReachEnabled = false
local HitboxSize = 2
local KillTime = 0.4 

-- [[ BYPASS TELEPORT (TWEEN) ]] --
local function bypassTP(targetCFrame)
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = lp.Character.HumanoidRootPart
    local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Linear) 
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait()
end

-- [[ HITBOX / REACH LOGIC ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    if ReachEnabled then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                hrp.Transparency = 1
                hrp.CanCollide = false
            end
        end
    end
end)

-- [[ COMBAT TAB ]] --
local Combat = Window:CreateTab("Combat", 4483345998)

Combat:CreateInput({
   Name = "Target Username",
   PlaceholderText = "Type part of name...",
   Callback = function(Text)
       for _, v in pairs(game.Players:GetPlayers()) do
           if v.Name:lower():find(Text:lower()) then
               SelectedTarget = v
               Rayfield:Notify({Title = "Locked", Content = "Target: " .. v.Name})
               break
           end
       end
   end,
})

Combat:CreateToggle({
   Name = "Spectate Target",
   CurrentValue = false,
   Callback = function(Value)
       if Value and SelectedTarget and SelectedTarget.Character then
           Camera.CameraSubject = SelectedTarget.Character.Humanoid
       else
           Camera.CameraSubject = lp.Character.Humanoid
       end
   end,
})

Combat:CreateButton({
   Name = "🔥 BYPASS KILL 🔥",
   Callback = function()
       if not SelectedTarget or not SelectedTarget.Character or not SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then 
           Rayfield:Notify({Title = "Error", Content = "No target selected!"})
           return 
       end
       
       local hrp = lp.Character.HumanoidRootPart
       local oldPos = hrp.CFrame
       
       bypassTP(SelectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
       
       local tool = lp.Backpack:FindFirstChildOfClass("Tool") or lp.Character:FindFirstChildOfClass("Tool")
       if tool then
           lp.Character.Humanoid:EquipTool(tool)
           local start = tick()
           while tick() - start < KillTime do
               tool:Activate()
               if SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
                   hrp.CFrame = SelectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
               end
               task.wait()
           end
       end
       
       bypassTP(oldPos)
   end,
})

-- [[ REACH TAB ]] --
local ReachTab = Window:CreateTab("Reach", 4483345998)

ReachTab:CreateToggle({
   Name = "Enable Reach",
   CurrentValue = false,
   Callback = function(Value) ReachEnabled = Value end,
})

ReachTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {2, 25},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(Value) HitboxSize = Value end,
})

-- [[ ANTI-KICK BYPASS ]] --
local BypassTab = Window:CreateTab("Bypasses", 4483345998)

BypassTab:CreateButton({
   Name = "Load Internal Anti-Kick",
   Callback = function()
       local mt = getrawmetatable(game)
       local old = mt.__namecall
       setreadonly(mt, false)
       mt.__namecall = newcclosure(function(self, ...)
           local method = getnamecallmethod()
           if method == "Kick" then return nil end
           return old(self, ...)
       end)
       Rayfield:Notify({Title = "Success", Content = "Anti-Kick bypass injected."})
   end,
})
