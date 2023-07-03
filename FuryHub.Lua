local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "FuryHub",
   LoadingTitle = "Nexus Fury",
   LoadingSubtitle = "By Saurav",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Fury Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("Player", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Visuals, Aims, Etc.")

local Tab = Window:CreateTab("Miscellaneous", nil) -- Title, Image
local Section = Tab:CreateSection("DevEx,BTools,Etc")

Rayfield:Notify({
   Title    = "Notification",
   Content  = "Script Has Executed Succesfully!!!! Enjoy",
   Duration = 0.5,
   Image    = nil,
   Actions  = { -- Notification Buttons
      Ignore = {
      Name   = "Done!",
         Callback = function()
         print("The user tapped Okay!")
      end
   },
},
})

local Toggle = MainTab:CreateToggle({
   Name = "Esp",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   --[[
A distribution of https://wearedevs.net/scripts
Created August 17, 2021, Last updated August 17, 2021

Description: Draws boxes around each player.

Credits to "Real Panda" for their ESP library

Instruction: Edit the settings as desired below and execute the script.

Settings: 
Replace "nil" with "true" to enable the setting, or "false" to disable the setting. Without the quotes. 
If you do not change "nil", the defaults will take place.
]]
_G.WRDESPEnabled = nil --Enables the ESP (Defaults to true)
_G.WRDESPBoxes = nil --Draws boxes around other players (Defaults to true)
_G.WRDESPTeamColors = nil --Distinguish different teams by their team color. If the game sets one. (Defaults to true)
_G.WRDESPTracers = false --Displays lines leading to other players (Defaults to false)
_G.WRDESPNames = false --Displays the names of the players within the ESP box (Defaults to true)

--Dont edit below

--Only ever load the script once
if not _G.WRDESPLoaded then    
    ----[[ First- Load Kiriot ESP Library ]]----

    --Settings--
    local ESP = {
        Enabled = false,
        Boxes = true,
        BoxShift = CFrame.new(0,-1.5,0),
        BoxSize = Vector3.new(4,6,0),
        Color = Color3.fromRGB(255, 170, 0),
        FaceCamera = false,
        Names = true,
        TeamColor = true,
        Thickness = 2,
        AttachShift = 1,
        TeamMates = true,
        Players = true,
        
        Objects = setmetatable({}, {__mode="kv"}),
        Overrides = {}
    }

    --Declarations--
    local cam = workspace.CurrentCamera
    local plrs = game:GetService("Players")
    local plr = plrs.LocalPlayer
    local mouse = plr:GetMouse()

    local V3new = Vector3.new
    local WorldToViewportPoint = cam.WorldToViewportPoint

    --Functions--
    local function Draw(obj, props)
        local new = Drawing.new(obj)
        
        props = props or {}
        for i,v in pairs(props) do
            new[i] = v
        end
        return new
    end

    function ESP:GetTeam(p)
        local ov = self.Overrides.GetTeam
        if ov then
            return ov(p)
        end
        
        return p and p.Team
    end

    function ESP:IsTeamMate(p)
        local ov = self.Overrides.IsTeamMate
        if ov then
            return ov(p)
        end
        
        return self:GetTeam(p) == self:GetTeam(plr)
    end

    function ESP:GetColor(obj)
        local ov = self.Overrides.GetColor
        if ov then
            return ov(obj)
        end
        local p = self:GetPlrFromChar(obj)
        return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
    end

    function ESP:GetPlrFromChar(char)
        local ov = self.Overrides.GetPlrFromChar
        if ov then
            return ov(char)
        end
        
        return plrs:GetPlayerFromCharacter(char)
    end

    function ESP:Toggle(bool)
        self.Enabled = bool
        if not bool then
            for i,v in pairs(self.Objects) do
                if v.Type == "Box" then --fov circle etc
                    if v.Temporary then
                        v:Remove()
                    else
                        for i,v in pairs(v.Components) do
                            v.Visible = false
                        end
                    end
                end
            end
        end
    end

    function ESP:GetBox(obj)
        return self.Objects[obj]
    end

    function ESP:AddObjectListener(parent, options)
        local function NewListener(c)
            if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
                if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
                    if not options.Validator or options.Validator(c) then
                        local box = ESP:Add(c, {
                            PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
                            Color = type(options.Color) == "function" and options.Color(c) or options.Color,
                            ColorDynamic = options.ColorDynamic,
                            Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
                            IsEnabled = options.IsEnabled,
                            RenderInNil = options.RenderInNil
                        })
                        --TODO: add a better way of passing options
                        if options.OnAdded then
                            coroutine.wrap(options.OnAdded)(box)
                        end
                    end
                end
            end
        end

        if options.Recursive then
            parent.DescendantAdded:Connect(NewListener)
            for i,v in pairs(parent:GetDescendants()) do
                coroutine.wrap(NewListener)(v)
            end
        else
            parent.ChildAdded:Connect(NewListener)
            for i,v in pairs(parent:GetChildren()) do
                coroutine.wrap(NewListener)(v)
            end
        end
    end

    local boxBase = {}
    boxBase.__index = boxBase

    function boxBase:Remove()
        ESP.Objects[self.Object] = nil
        for i,v in pairs(self.Components) do
            v.Visible = false
            v:Remove()
            self.Components[i] = nil
        end
    end

    function boxBase:Update()
        if not self.PrimaryPart then
            --warn("not supposed to print", self.Object)
            return self:Remove()
        end

        local color
        if ESP.Highlighted == self.Object then
        color = ESP.HighlightColor
        else
            color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color
        end

        local allow = true
        if ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self) then
            allow = false
        end
        if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
            allow = false
        end
        if self.Player and not ESP.Players then
            allow = false
        end
        if self.IsEnabled and (type(self.IsEnabled) == "string" and not ESP[self.IsEnabled] or type(self.IsEnabled) == "function" and not self:IsEnabled()) then
            allow = false
        end
        if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
            allow = false
        end

        if not allow then
            for i,v in pairs(self.Components) do
                v.Visible = false
            end
            return
        end

        if ESP.Highlighted == self.Object then
            color = ESP.HighlightColor
        end

        --calculations--
        local cf = self.PrimaryPart.CFrame
        if ESP.FaceCamera then
            cf = CFrame.new(cf.p, cam.CFrame.p)
        end
        local size = self.Size
        local locs = {
            TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
            TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
            BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
            BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0),
            TagPos = cf * ESP.BoxShift * CFrame.new(0,size.Y/2,0),
            Torso = cf * ESP.BoxShift
        }

        if ESP.Boxes then
            local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
            local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
            local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
            local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

            if self.Components.Quad then
                if Vis1 or Vis2 or Vis3 or Vis4 then
                    self.Components.Quad.Visible = true
                    self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y)
                    self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
                    self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
                    self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
                    self.Components.Quad.Color = color
                else
                    self.Components.Quad.Visible = false
                end
            end
        else
            self.Components.Quad.Visible = false
        end

        if ESP.Names then
            local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)
            
            if Vis5 then
                self.Components.Name.Visible = true
                self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y)
                self.Components.Name.Text = self.Name
                self.Components.Name.Color = color
                
                self.Components.Distance.Visible = true
                self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14)
                self.Components.Distance.Text = math.floor((cam.CFrame.p - cf.p).magnitude) .."m away"
                self.Components.Distance.Color = color
            else
                self.Components.Name.Visible = false
                self.Components.Distance.Visible = false
            end
        else
            self.Components.Name.Visible = false
            self.Components.Distance.Visible = false
        end
        
        if ESP.Tracers then
            local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

            if Vis6 then
                self.Components.Tracer.Visible = true
                self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y)
                self.Components.Tracer.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
                self.Components.Tracer.Color = color
            else
                self.Components.Tracer.Visible = false
            end
        else
            self.Components.Tracer.Visible = false
        end
    end

    function ESP:Add(obj, options)
        if not obj.Parent and not options.RenderInNil then
            return warn(obj, "has no parent")
        end

        local box = setmetatable({
            Name = options.Name or obj.Name,
            Type = "Box",
            Color = options.Color --[[or self:GetColor(obj)]],
            Size = options.Size or self.BoxSize,
            Object = obj,
            Player = options.Player or plrs:GetPlayerFromCharacter(obj),
            PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
            Components = {},
            IsEnabled = options.IsEnabled,
            Temporary = options.Temporary,
            ColorDynamic = options.ColorDynamic,
            RenderInNil = options.RenderInNil
        }, boxBase)

        if self:GetBox(obj) then
            self:GetBox(obj):Remove()
        end

        box.Components["Quad"] = Draw("Quad", {
            Thickness = self.Thickness,
            Color = color,
            Transparency = 1,
            Filled = false,
            Visible = self.Enabled and self.Boxes
        })
        box.Components["Name"] = Draw("Text", {
            Text = box.Name,
            Color = box.Color,
            Center = true,
            Outline = true,
            Size = 19,
            Visible = self.Enabled and self.Names
        })
        box.Components["Distance"] = Draw("Text", {
            Color = box.Color,
            Center = true,
            Outline = true,
            Size = 19,
            Visible = self.Enabled and self.Names
        })
        
        box.Components["Tracer"] = Draw("Line", {
            Thickness = ESP.Thickness,
            Color = box.Color,
            Transparency = 1,
            Visible = self.Enabled and self.Tracers
        })
        self.Objects[obj] = box
        
        obj.AncestryChanged:Connect(function(_, parent)
            if parent == nil and ESP.AutoRemove ~= false then
                box:Remove()
            end
        end)
        obj:GetPropertyChangedSignal("Parent"):Connect(function()
            if obj.Parent == nil and ESP.AutoRemove ~= false then
                box:Remove()
            end
        end)

        local hum = obj:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                if ESP.AutoRemove ~= false then
                    box:Remove()
                end
            end)
        end

        return box
    end

    local function CharAdded(char)
        local p = plrs:GetPlayerFromCharacter(char)
        if not char:FindFirstChild("HumanoidRootPart") then
            local ev
            ev = char.ChildAdded:Connect(function(c)
                if c.Name == "HumanoidRootPart" then
                    ev:Disconnect()
                    ESP:Add(char, {
                        Name = p.Name,
                        Player = p,
                        PrimaryPart = c
                    })
                end
            end)
        else
            ESP:Add(char, {
                Name = p.Name,
                Player = p,
                PrimaryPart = char.HumanoidRootPart
            })
        end
    end
    local function PlayerAdded(p)
        p.CharacterAdded:Connect(CharAdded)
        if p.Character then
            coroutine.wrap(CharAdded)(p.Character)
        end
    end
    plrs.PlayerAdded:Connect(PlayerAdded)
    for i,v in pairs(plrs:GetPlayers()) do
        if v ~= plr then
            PlayerAdded(v)
        end
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        cam = workspace.CurrentCamera
        for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
            if v.Update then
                local s,e = pcall(v.Update, v)
                if not s then warn("[EU]", e, v.Object:GetFullName()) end
            end
        end
    end)

    ----[[ Now Begins WRD's modification for implementation ]]----

    --Sets defaults where required
    if _G.WRDESPEnabled == nil then _G.WRDESPEnabled = true end
    if _G.WRDESPBoxes == nil then _G.WRDESPBoxes = true end
    if _G.WRDESPTeamColors == nil then _G.WRDESPTeamColors = true end
    if _G.WRDESPTracers == nil then _G.WRDESPTracers = false end
    if _G.WRDESPNames == nil then _G.WRDESPNames = true end
    
    --Hacky way to keep up with setting changes
    while wait(.1) do
        ESP:Toggle(_G.WRDESPEnabled or false)
        ESP.Boxes = _G.WRDESPBoxes or false
        ESP.TeamColors = _G.WRDESPTeamColors or false
        ESP.Tracers = _G.WRDESPTracers or false
        ESP.Names = _G.WRDESPNames or false
    end

    _G.WRDESPLoaded = true
end
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

_G.AimbotEnabled = true
_G.TeamCheck = true -- If set to true then the script would only lock your aim at enemy team members.
_G.AimPart = "Head" -- Where the aimbot script would lock at.
_G.Sensitivity = 0 -- How many seconds it takes for the aimbot script to officially lock onto the target's aimpart.

local function GetClosestPlayer()
    local MaximumDistance = math.huge
    local Target = nil
  
    coroutine.wrap(function()
        wait(20)
        MaximumDistance = math.huge -- Reset the MaximumDistance so that the Aimbot doesn't remember it as a very small variable and stop capturing players...
    end)()

    for _, v in next, Players:GetPlayers() do
        if v.Name ~= LocalPlayer.Name then
            if _G.TeamCheck == true and v.Team ~= LocalPlayer.Team then
                if v.Character ~= nil then
                    if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                        if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                            local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                            local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                            
                            if VectorDistance < MaximumDistance then
                                Target = v
                                MaximumDistance = VectorDistance
                            end
                        end
                    end
                end
            elseif _G.TeamCheck == false then
                if v.Character ~= nil then
                    if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                        if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                            local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                            local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                            
                            if VectorDistance < MaximumDistance then
                                Target = v
                                MaximumDistance = VectorDistance
                            end
                        end
                    end
                end
            end
        end
    end

    return Target
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Holding == true and _G.AimbotEnabled == true then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer then
            TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character[_G.AimPart].Position)}):Play()
        end
    end
end)

   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Teleport [CTRL + CLick to Teleport]",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Click%20Teleport.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Invisibility",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   character = game:GetService("Players").LocalPlayer.Character

-- Set transparency for body parts
character.Head.Transparency = 1

-- R6 Rigs
local torso = character:FindFirstChild("Torso")
if torso then torso.Transparency = 1 end

local leftArm = character:FindFirstChild("Left Arm")
if leftArm then leftArm.Transparency = 1 end
local rightArm = character:FindFirstChild("Right Arm")
if rightArm then rightArm.Transparency = 1 end

local leftLeg = character:FindFirstChild("Left Leg")
if leftLeg then leftLeg.Transparency = 1 end
local rightLeg = character:FindFirstChild("Right Leg")
if rightLeg then rightLeg.Transparency = 1 end

-- R15 Rigs
local upperTorso = character:FindFirstChild("UpperTorso")
if upperTorso then upperTorso.Transparency = 1 end
local lowerTorso = character:FindFirstChild("LowerTorso")
if lowerTorso then lowerTorso.Transparency = 1 end

local leftUpperArm = character:FindFirstChild("LeftUpperArm")
if leftUpperArm then leftUpperArm.Transparency = 1 end
local leftLowerArm = character:FindFirstChild("LeftLowerArm")
if leftLowerArm then leftLowerArm.Transparency = 1 end
local leftHand = character:FindFirstChild("LeftHand")
if leftHand then leftHand.Transparency = 1 end
local rightUpperArm = character:FindFirstChild("RightUpperArm")
if rightUpperArm then rightUpperArm.Transparency = 1 end
local rightLowerArm = character:FindFirstChild("RightLowerArm")
if rightLowerArm then rightLowerArm.Transparency = 1 end
local rightHand = character:FindFirstChild("RightHand")
if rightHand then rightHand.Transparency = 1 end

local leftUpperLeg = character:FindFirstChild("LeftUpperLeg")
if leftUpperLeg then leftUpperLeg.Transparency = 1 end
local leftLowerLeg = character:FindFirstChild("LeftLowerLeg")
if leftLowerLeg then leftLowerLeg.Transparency = 1 end
local leftFoot = character:FindFirstChild("LeftFoot")
if leftFoot then leftFoot.Transparency = 1 end
local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
if rightUpperLeg then rightUpperLeg.Transparency = 1 end
local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
if rightLowerLeg then rightLowerLeg.Transparency = 1 end
local rightFoot = character:FindFirstChild("RightFoot")
if rightFoot then rightFoot.Transparency = 1 end

-- Hair transparency
local hair = character:FindFirstChild("Pal hair")
if hair then hair.Transparency = 1 end

   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Fly [Hold Space To Fly]",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The actual infinite jump
local function infiniteJump()
    local player = game:GetService('Players').LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild('Humanoid')

    local isJumping = false

    game:GetService('UserInputService').InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            isJumping = true
            humanoid:ChangeState('Jumping')
        end
    end)

    game:GetService('UserInputService').InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            isJumping = false
            humanoid:ChangeState('Seated')
        end
    end)

    game:GetService('RunService').RenderStepped:Connect(function()
        if isJumping then
            humanoid:ChangeState('Jumping')
        end
    end)
end

infiniteJump()

   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "BTools",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/BTools.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "DevEx",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex%20Explorer.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Night Mode Toggle",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Night%20Time%20Toggle.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Gravity",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Gravity%20Switch.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Float",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Float%20Character.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Human FlashLight",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Human%20Flashlight.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "High Hips",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/High%20Hips.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Rapid Fire",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        -- Rapid fire script
local userInputService = game:GetService('UserInputService')
local mouse = game:GetService('Players').LocalPlayer:GetMouse()
local isFiring = false

local function startFire()
    isFiring = true
    while isFiring do
        mouse.Button1Down:wait()
        mouse.Button1Up:wait()
        if isFiring then
            mouse.Button1Down:wait()
        end
    end
end

userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        startFire()
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isFiring = false
    end
end)

   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Unlock WorkSpace BasePart",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Unlock%20Workspace%20Baseparts.txt"))()
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
       loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Infinite%20Jump.txt"))() 
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})


local Slider = MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {0, 150},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})



