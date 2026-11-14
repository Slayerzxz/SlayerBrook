--[[
    NOTICE OF INTELLECTUAL PROPERTY PROTECTION

    Any unauthorized modification, alteration, redistribution, relocation,
    reproduction, or other form of interference with this script, in whole
    or in part, is strictly prohibited.

  #  THE REMOVAL OF CREDITS FROM (BAZUKA AND RICK) IS EXTREMELY PROHIBITED

    Unauthorized use or modification may result in appropriate legal action,
    as well as formal takedown requests submitted to the hosting provider
    or platform responsible for distributing the script.

    AVISO DE PROTEÇÃO À PROPRIEDADE INTELECTUAL

    Qualquer modificação, alteração, redistribuição, transferência,
    reprodução ou qualquer outra forma de intervenção não autorizada
    neste script, total ou parcialmente, é expressamente proibida.

  #  É EXTREMAMENTE PROIBIDO A REMOÇÃO DOS CRÉDITOS DE (BAZUKA AND RICK)

    O uso ou a modificação sem autorização poderá resultar na adoção
    das medidas legais cabíveis, bem como no envio de solicitações
    formais de remoção à plataforma ou ao provedor responsável
    pela hospedagem e distribuição do script.
]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/Slayerzxz/slayerAdmin/refs/heads/main/brookhaven.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Terrain = Workspace.Terrain
local player = Players.LocalPlayer

local PISCINA_ID = 82940833560521
local SPAWN_POS = Vector3.new(316, 88, -1063)

local Settings = {}
Settings["Fade In"] = 0.1
Settings["Fade Out"] = 0.1
Settings["Weight"] = 1
Settings["Speed"] = 1

local POSES = {
    ["Pose 1"] = "99169466290816",
    ["Pose 2"] = "85875089814466",
    ["Pose 3"] = "77428784990570",
    ["Pose 4"] = "79802706082611",
    ["Pose 5"] = "128961031551930",
    ["Pose 6"] = "107799482155621",
    ["Pose 7"] = "105016815489641",
    ["Pose 8"] = "113546798537900",
}

local function getHumanoid()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function loadTrack(animationId, state)
    local humanoid = getHumanoid()
    if not humanoid then return end

    if state.CurrentTrack then
        state.CurrentTrack:Stop(Settings["Fade Out"])
        state.CurrentTrack = nil
    end

    local animId
    local ok, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(animationId))
    end)

    if ok and result and #result > 0 then
        local anim = result[1]
        if anim:IsA("Animation") then
            animId = anim.AnimationId
        else
            animId = "rbxassetid://" .. tostring(animationId)
        end
    else
        animId = "rbxassetid://" .. tostring(animationId)
    end

    local newAnim = Instance.new("Animation")
    newAnim.AnimationId = animId
    local newTrack = humanoid:LoadAnimation(newAnim)
    newTrack.Priority = Enum.AnimationPriority.Action4

    local weight = Settings["Weight"]
    if weight == 0 then weight = 0.001 end

    newTrack:Play(Settings["Fade In"], weight, Settings["Speed"])
    state.CurrentTrack = newTrack
    state.CurrentTrack.Priority = Enum.AnimationPriority.Action4

    return newTrack
end

local function stopEmote(state)
    if state.CurrentTrack then
        state.CurrentTrack:Stop(Settings["Fade Out"])
        state.CurrentTrack = nil
    end
end

local function getParts(model)
    local t = {}
    if not model then return t end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            table.insert(t, p)
        end
    end
    return t
end

local function reactivateScripts(model)
    if not model then return end
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local source = obj.Source
            local className = obj.ClassName
            local name = obj.Name
            local parent = obj.Parent
            obj:Destroy()
            if source and source ~= "" then
                local newScript = Instance.new(className)
                newScript.Name = name
                newScript.Source = source
                newScript.Parent = parent
                if className == "LocalScript" then
                    newScript.Parent = player.PlayerGui
                end
            end
        end
    end
end

local success, piscina = pcall(function()
    return game:GetObjects("rbxassetid://"..PISCINA_ID)[1]
end)

if not success or not piscina then return end

piscina.Name = "Piscina"
piscina.Parent = workspace

local allParts = getParts(piscina)
if #allParts == 0 then return end

local centerPart = allParts[1]
for _, p in ipairs(allParts) do
    if p.Name == "HumanoidRootPart" or p.Name == "PrimaryPart" then
        centerPart = p
        break
    end
end

local spawnCFrame = CFrame.new(SPAWN_POS) * centerPart.CFrame.Rotation
local offset = spawnCFrame * centerPart.CFrame:Inverse()

for _, part in ipairs(allParts) do
    part.Anchored = true
    part.CanCollide = true
    part.CFrame = offset * part.CFrame
end

pcall(function() reactivateScripts(piscina) end)

for _, obj in ipairs(piscina:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        pcall(function() obj:FireServer() end)
    end
end

task.wait(1)

local waterFolder = piscina:FindFirstChild("Water", true)
local waterBlock = nil

if waterFolder then
    local wb = piscina:FindFirstChild("Water Blocks", true)
    if wb then
        waterBlock = wb:FindFirstChild("Water Block", true)
        wb:Destroy()
    else
        waterBlock = waterFolder:FindFirstChildWhichIsA("BasePart", true)
    end
else
    local wb = piscina:FindFirstChild("Water Blocks", true)
    if wb then
        waterBlock = wb:FindFirstChild("Water Block", true)
        wb:Destroy()
    end
end

if waterBlock then
    local blockPosition = waterBlock.Position
    local blockSize = waterBlock.Size
    Terrain:FillBlock(CFrame.new(blockPosition), blockSize, Enum.Material.Water)
end

local pillow = piscina:FindFirstChild("Pillow", true)
if pillow then
    for _, obj in ipairs(pillow:GetDescendants()) do
        if obj:IsA("Seat") then
            local newSeat = Instance.new("VehicleSeat")
            newSeat.Name = obj.Name
            newSeat.Size = obj.Size
            newSeat.CFrame = obj.CFrame
            newSeat.Transparency = obj.Transparency
            newSeat.Anchored = obj.Anchored
            newSeat.CanCollide = obj.CanCollide
            newSeat.Parent = obj.Parent
            obj:Destroy()
        end
    end
end

local function SetupCharacter(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    Humanoid.JumpPower = 50
    Humanoid.UseJumpPower = true
end

if player.Character then
    SetupCharacter(player.Character)
end

player.CharacterAdded:Connect(SetupCharacter)

task.wait(1)

local toolsAtivas = {}
local posesCriadas = false

local function criarPoses()
    if posesCriadas then return end
    posesCriadas = true
    
    for poseName, animId in pairs(POSES) do
        local state = { CurrentTrack = nil }

        local tool = Instance.new("Tool")
        tool.Name = poseName
        tool.RequiresHandle = false
        tool.CanBeDropped = false
        tool.Parent = player.Backpack

        tool.Equipped:Connect(function()
            loadTrack(animId, state)
        end)

        tool.Unequipped:Connect(function()
            stopEmote(state)
        end)

        table.insert(toolsAtivas, { tool = tool, state = state })
    end
end

local function removerPoses()
    if not posesCriadas then return end
    posesCriadas = false

    for _, data in ipairs(toolsAtivas) do
        if data.tool and data.tool.Parent then
            data.tool:Destroy()
        end
    end
    toolsAtivas = {}
end

local function ConnectSeatSystem(newChar)
    local humanoid = newChar:WaitForChild("Humanoid")
    local root = newChar:WaitForChild("HumanoidRootPart")
    
    local cooldown = false
    local conexoes = {}

    local function monitorarSeat(seat)
        if not seat or (not seat:IsA("Seat") and not seat:IsA("VehicleSeat")) then return end
        if conexoes[seat] then return end

        local hitbox = Instance.new("Part")
        hitbox.Name = "HitboxInvisivel"
        hitbox.Size = Vector3.new(2, 2, 2)
        hitbox.Transparency = 1
        hitbox.CanCollide = false
        hitbox.Anchored = true
        hitbox.CFrame = seat.CFrame * CFrame.new(0, 1, 0)
        hitbox.Parent = seat

        conexoes[seat] = hitbox.Touched:Connect(function(hit)
            if cooldown or humanoid.SeatPart or humanoid.Health <= 0 then return end
            if not hit:IsDescendantOf(newChar) then return end
            if seat.Occupant then return end
            
            local temToolEquipada = false
            for _, child in ipairs(newChar:GetChildren()) do
                if child:IsA("Tool") then
                    temToolEquipada = true
                    break
                end
            end

            if temToolEquipada then return end

            cooldown = true
            
            root.Anchored = true
            root.CFrame = seat.CFrame * CFrame.new(0, 1.5, 0)
            humanoid.Sit = true
            
            task.delay(0.2, function()
                root.Anchored = false
            end)
            
            task.delay(3, function()
                cooldown = false
            end)
        end)
    end

    for _, obj in ipairs(piscina:GetDescendants()) do
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            monitorarSeat(obj)
        end
    end

    local addedConn = piscina.DescendantAdded:Connect(function(obj)
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            monitorarSeat(obj)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not newChar.Parent or humanoid.Health <= 0 then return end
        
        local piscinaAtual = workspace:FindFirstChild("Piscina")
        if not piscinaAtual then return end

        local maisProximo = nil
        local menorDistancia = 30

        for _, obj in ipairs(piscinaAtual:GetDescendants()) do
            if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and obj.Parent then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < menorDistancia then
                    menorDistancia = dist
                    maisProximo = obj
                end
            end
        end

        if maisProximo then
            criarPoses()
        else
            removerPoses()
        end
    end)
    
    newChar.AncestryChanged:Connect(function()
        if not newChar:IsDescendantOf(workspace) then
            addedConn:Disconnect()
            for _, conn in pairs(conexoes) do
                conn:Disconnect()
            end
            conexoes = {}
            removerPoses()
        end
    end)
end

if player.Character then
    ConnectSeatSystem(player.Character)
end

player.CharacterAdded:Connect(ConnectSeatSystem)

do
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local ZOMBIE_ID = 71046314092719
    local SPAWN_POS = Vector3.new(97, 14, -27)

    local function getParts(model)
        local t = {}
        if not model then return t end
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                table.insert(t, p)
            end
        end
        return t
    end

    local function reactivateScripts(model)
        if not model then return end
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local source = obj.Source
                local className = obj.ClassName
                local name = obj.Name
                local parent = obj.Parent
                obj:Destroy()
                if source and source ~= "" then
                    local newScript = Instance.new(className)
                    newScript.Name = name
                    newScript.Source = source
                    newScript.Parent = parent
                    if className == "LocalScript" then
                        newScript.Parent = player.PlayerGui
                    end
                end
            end
        end
    end

    local success, zombie = pcall(function()
        return game:GetObjects("rbxassetid://"..ZOMBIE_ID)[1]
    end)

    if not success or not zombie then return end

    zombie.Name = "Zombie"
    zombie.Parent = workspace

    local allParts = getParts(zombie)
    if #allParts == 0 then return end

    local centerPart = allParts[1]
    for _, p in ipairs(allParts) do
        if p.Name == "HumanoidRootPart" or p.Name == "PrimaryPart" then
            centerPart = p
            break
        end
    end

    local spawnCFrame = CFrame.new(SPAWN_POS) * centerPart.CFrame.Rotation * CFrame.Angles(0, math.rad(-90), 0)
    local offset = spawnCFrame * centerPart.CFrame:Inverse()

    for _, part in ipairs(allParts) do
        part.Anchored = true
        part.CanCollide = true
        part.CFrame = offset * part.CFrame
    end

    pcall(function() reactivateScripts(zombie) end)

    for _, obj in ipairs(zombie:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function() obj:FireServer() end)
        end
    end
end

local HttpService = game:GetService("HttpService")

pcall(function()
    HttpService:RequestAsync({
        Url = "https://slayerhub.lovable.app/api/public/executions",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = "{}"
    })
end)
local Libary = loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/CxbLYclujQ7trDko/raw"))()
workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = " Slayer Hub ",
    SubTitle = "by: Bazuka and Rick",
    LoadText = "hi voldex",
    Flags = "Slayer Hubb"
})

local MinimizeButtonRef = Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://94197497057242", BackgroundTransparency = 1 },
    Corner = { CornerRadius = UDim.new(55, 1) },
})

local MinimizeButtonImage = MinimizeButtonRef.Button

task.delay(1, function()
    Window:Dialog({
        Title = "Slayer Hub | Admin",
        Text = "Compre agora o melhor painel admin do mercado pelo menor preço (clique em Discord)",
        Options = {
            {
                "Discord",
                function()
                    local discordLink = "https://discord.gg/KSNnDfd6sW"
                    if setclipboard then
                        setclipboard(discordLink)
                        Libary:Notify({
                            Title = "Slayer Hub",
                            Text = "Link do Discord copiado com sucesso!",
                            Duration = 5
                        })
                    else
                        Libary:Notify({
                            Title = "Slayer Hub",
                            Text = "Seu executor não permite copiar texto automaticamente.",
                            Duration = 5
                        })
                    end
                end
            },
            {
                "Open",
                function()
                    Libary:Notify({
                        Title = "Slayer Hub",
                        Text = "Welcome to the best Hub!",
                        Duration = 5
                    })
                end
            }
        }
    })
end)



local SugestionTab = Window:MakeTab({ "Options News", "eye" })

SugestionTab:AddSection({ "Price Skins" })

SugestionTab:AddButton({
    Name = "View Price Skins",
    Callback = function()
       local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local IMAGE_BACKGROUND = "rbxassetid://104871363875385"
local SEARCH_ICON = "rbxassetid://79859235777238"

local WHITE = Color3.fromRGB(255, 255, 255)
local SOFT = Color3.fromRGB(220, 220, 225)
local GRAY = Color3.fromRGB(150, 150, 158)
local MUTED = Color3.fromRGB(120, 120, 128)
local DARK = Color3.fromRGB(14, 14, 16)
local DARKER = Color3.fromRGB(6, 6, 8)

local old = PlayerGui:FindFirstChild("PlayerCatalog")
if old then
    old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerCatalog"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.42, 0, 0.72, 0)
Main.Position = UDim2.new(0.29, 0, 0.14, 0)
Main.BackgroundColor3 = DARKER
Main.BackgroundTransparency = 0
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local Scale = Instance.new("UIScale")
Scale.Parent = Main

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    Scale.Scale = math.clamp(math.min(viewport.X / 1100, viewport.Y / 800), 0.42, 1)
end

updateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local Background = Instance.new("ImageLabel")
Background.Name = "Background"
Background.Size = UDim2.fromScale(1, 1)
Background.Position = UDim2.fromScale(0, 0)
Background.BackgroundColor3 = DARKER
Background.BackgroundTransparency = 0
Background.BorderSizePixel = 0
Background.Image = IMAGE_BACKGROUND
Background.ImageTransparency = 0.5
Background.ScaleType = Enum.ScaleType.Crop
Background.ZIndex = 1
Background.Parent = Main

local BackgroundCorner = Instance.new("UICorner")
BackgroundCorner.CornerRadius = UDim.new(0, 16)
BackgroundCorner.Parent = Background

local DarkOverlay = Instance.new("Frame")
DarkOverlay.Name = "DarkOverlay"
DarkOverlay.Size = UDim2.fromScale(1, 1)
DarkOverlay.Position = UDim2.fromScale(0, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkOverlay.BackgroundTransparency = 0.6
DarkOverlay.BorderSizePixel = 0
DarkOverlay.ZIndex = 2
DarkOverlay.Parent = Main

local DarkOverlayCorner = Instance.new("UICorner")
DarkOverlayCorner.CornerRadius = UDim.new(0, 16)
DarkOverlayCorner.Parent = DarkOverlay

local Border = Instance.new("UIStroke")
Border.Color = WHITE
Border.Thickness = 1.5
Border.Transparency = 0.15
Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Border.Parent = Main

local Header = Instance.new("TextLabel")
Header.Name = "Title"
Header.Size = UDim2.new(1, -76, 0, 28)
Header.Position = UDim2.new(0, 12, 0, 8)
Header.BackgroundTransparency = 1
Header.Text = "View Price Skins"
Header.TextColor3 = WHITE
Header.Font = Enum.Font.Gotham
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.ZIndex = 4
Header.Parent = Main

local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.Size = UDim2.fromOffset(22, 22)
Minimize.Position = UDim2.new(1, -56, 0, 8)
Minimize.BackgroundColor3 = DARK
Minimize.BackgroundTransparency = 0.2
Minimize.Text = "−"
Minimize.TextColor3 = WHITE
Minimize.TextSize = 14
Minimize.Font = Enum.Font.GothamBold
Minimize.ZIndex = 5
Minimize.Parent = Main

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = Minimize

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Color = WHITE
MinimizeStroke.Thickness = 1
MinimizeStroke.Transparency = 0.4
MinimizeStroke.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Size = UDim2.fromOffset(22, 22)
Close.Position = UDim2.new(1, -30, 0, 8)
Close.BackgroundColor3 = DARK
Close.BackgroundTransparency = 0.2
Close.Text = "X"
Close.TextColor3 = WHITE
Close.TextSize = 11
Close.Font = Enum.Font.Gotham
Close.ZIndex = 5
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = WHITE
CloseStroke.Thickness = 1
CloseStroke.Transparency = 0.4
CloseStroke.Parent = Close

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -42)
Content.Position = UDim2.new(0, 0, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ZIndex = 3
Content.Parent = Main

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "PlayerSearch"
SearchBox.Size = UDim2.new(1, -60, 0, 28)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundColor3 = DARK
SearchBox.BackgroundTransparency = 0.2
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "Nick ou DisplayName..."
SearchBox.PlaceholderColor3 = MUTED
SearchBox.Text = ""
SearchBox.TextColor3 = WHITE
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 4
SearchBox.Parent = Content

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = WHITE
SearchStroke.Thickness = 1
SearchStroke.Transparency = 0.35
SearchStroke.Parent = SearchBox

local SearchButton = Instance.new("ImageButton")
SearchButton.Name = "SearchButton"
SearchButton.Size = UDim2.fromOffset(28, 28)
SearchButton.Position = UDim2.new(1, -40, 0, 0)
SearchButton.BackgroundColor3 = DARK
SearchButton.BackgroundTransparency = 0.15
SearchButton.Image = SEARCH_ICON
SearchButton.ScaleType = Enum.ScaleType.Fit
SearchButton.ZIndex = 5
SearchButton.Parent = Content

local SearchCorner2 = Instance.new("UICorner")
SearchCorner2.CornerRadius = UDim.new(0, 8)
SearchCorner2.Parent = SearchButton

local SearchStroke2 = Instance.new("UIStroke")
SearchStroke2.Color = WHITE
SearchStroke2.Thickness = 1
SearchStroke2.Transparency = 0.35
SearchStroke2.Parent = SearchButton

local ProfileCard = Instance.new("Frame")
ProfileCard.Name = "ProfileCard"
ProfileCard.Size = UDim2.new(1, -20, 0, 66)
ProfileCard.Position = UDim2.new(0, 10, 0, 36)
ProfileCard.BackgroundColor3 = DARK
ProfileCard.BackgroundTransparency = 0.3
ProfileCard.BorderSizePixel = 0
ProfileCard.ZIndex = 3
ProfileCard.Parent = Content

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 12)
ProfileCorner.Parent = ProfileCard

local ProfileStroke = Instance.new("UIStroke")
ProfileStroke.Color = WHITE
ProfileStroke.Thickness = 1.2
ProfileStroke.Transparency = 0.35
ProfileStroke.Parent = ProfileCard

local Avatar = Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.Size = UDim2.fromOffset(46, 46)
Avatar.Position = UDim2.new(0, 10, 0, 10)
Avatar.BackgroundTransparency = 1
Avatar.Image = ""
Avatar.ZIndex = 4
Avatar.Parent = ProfileCard

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 10)
AvatarCorner.Parent = Avatar

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = WHITE
AvatarStroke.Thickness = 1
AvatarStroke.Transparency = 0.3
AvatarStroke.Parent = Avatar

local ProfileName = Instance.new("TextLabel")
ProfileName.Name = "ProfileName"
ProfileName.Size = UDim2.new(1, -76, 0, 20)
ProfileName.Position = UDim2.new(0, 66, 0, 12)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = "Nenhum jogador selecionado"
ProfileName.TextColor3 = WHITE
ProfileName.Font = Enum.Font.GothamMedium
ProfileName.TextSize = 11
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.TextTruncate = Enum.TextTruncate.AtEnd
ProfileName.ZIndex = 4
ProfileName.Parent = ProfileCard

local ProfileUser = Instance.new("TextLabel")
ProfileUser.Name = "ProfileUser"
ProfileUser.Size = UDim2.new(1, -76, 0, 16)
ProfileUser.Position = UDim2.new(0, 66, 0, 34)
ProfileUser.BackgroundTransparency = 1
ProfileUser.Text = ""
ProfileUser.TextColor3 = GRAY
ProfileUser.Font = Enum.Font.Gotham
ProfileUser.TextSize = 9
ProfileUser.TextXAlignment = Enum.TextXAlignment.Left
ProfileUser.TextTruncate = Enum.TextTruncate.AtEnd
ProfileUser.ZIndex = 4
ProfileUser.Parent = ProfileCard

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 16)
Status.Position = UDim2.new(0, 10, 0, 108)
Status.BackgroundTransparency = 1
Status.Text = "Pesquise um jogador para listar os itens."
Status.TextColor3 = SOFT
Status.Font = Enum.Font.Gotham
Status.TextSize = 9
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextTruncate = Enum.TextTruncate.AtEnd
Status.ZIndex = 4
Status.Parent = Content

local List = Instance.new("ScrollingFrame")
List.Name = "Results"
List.Size = UDim2.new(1, -20, 1, -130)
List.Position = UDim2.new(0, 10, 0, 128)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 3
List.ScrollBarImageColor3 = WHITE
List.ScrollBarImageTransparency = 0.4
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
List.ScrollingDirection = Enum.ScrollingDirection.Y
List.ZIndex = 3
List.Parent = Content

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0, 6)
Padding.Parent = List

local minimized = false

Minimize.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        Content.Visible = false
        Main.Size = UDim2.new(0.42, 0, 0, 42)
        Minimize.Text = "+"
    else
        Content.Visible = true
        Main.Size = UDim2.new(0.42, 0, 0.72, 0)
        Minimize.Text = "−"
    end
end)

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = object
end

local function addStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or WHITE
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.35
    stroke.Parent = object
end

local function clearResults()
    for _, child in ipairs(List:GetChildren()) do
        if child ~= Layout and child ~= Padding then
            child:Destroy()
        end
    end
end

local function addResult(itemName, itemType, assetId, price, creatorName)
    local row = Instance.new("Frame")
    row.Name = "Item"
    row.Size = UDim2.new(1, -6, 0, 96)
    row.BackgroundTransparency = 0.25
    row.BackgroundColor3 = DARK
    row.BorderSizePixel = 0
    row.ZIndex = 4
    row.Parent = List

    addCorner(row, 12)
    addStroke(row, WHITE, 1, 0.4)

    local thumbnail = Instance.new("ImageLabel")
    thumbnail.Name = "Thumbnail"
    thumbnail.Size = UDim2.fromOffset(50, 50)
    thumbnail.Position = UDim2.new(0, 10, 0, 10)
    thumbnail.BackgroundTransparency = 1
    thumbnail.Image = "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=150&h=150"
    thumbnail.ScaleType = Enum.ScaleType.Fit
    thumbnail.ZIndex = 5
    thumbnail.Parent = row

    addCorner(thumbnail, 8)

    local name = Instance.new("TextLabel")
    name.Name = "ItemName"
    name.Size = UDim2.new(1, -150, 0, 20)
    name.Position = UDim2.new(0, 70, 0, 8)
    name.BackgroundTransparency = 1
    name.Text = tostring(itemName)
    name.TextColor3 = WHITE
    name.Font = Enum.Font.GothamMedium
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.ZIndex = 5
    name.Parent = row

    local details = Instance.new("TextLabel")
    details.Name = "Details"
    details.Size = UDim2.new(1, -150, 0, 14)
    details.Position = UDim2.new(0, 70, 0, 28)
    details.BackgroundTransparency = 1
    details.Text = tostring(itemType) .. " | " .. tostring(creatorName or "Desconhecido")
    details.TextColor3 = GRAY
    details.Font = Enum.Font.Gotham
    details.TextSize = 9
    details.TextXAlignment = Enum.TextXAlignment.Left
    details.TextTruncate = Enum.TextTruncate.AtEnd
    details.ZIndex = 5
    details.Parent = row

    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "AssetId"
    idLabel.Size = UDim2.new(1, -150, 0, 14)
    idLabel.Position = UDim2.new(0, 70, 0, 44)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "ID: " .. tostring(assetId)
    idLabel.TextColor3 = SOFT
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 9
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.TextTruncate = Enum.TextTruncate.AtEnd
    idLabel.ZIndex = 5
    idLabel.Parent = row

    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "Price"
    priceLabel.Size = UDim2.new(0, 68, 0, 14)
    priceLabel.Position = UDim2.new(1, -78, 0, 8)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = price == nil and "Indisponível" or (price == 0 and "Grátis" or (tostring(price) .. " R$"))
    priceLabel.TextColor3 = SOFT
    priceLabel.Font = Enum.Font.GothamMedium
    priceLabel.TextSize = 9
    priceLabel.TextXAlignment = Enum.TextXAlignment.Right
    priceLabel.ZIndex = 5
    priceLabel.Parent = row

    local openButton = Instance.new("TextButton")
    openButton.Name = "OpenItem"
    openButton.Size = UDim2.new(0, 68, 0, 20)
    openButton.Position = UDim2.new(1, -78, 0, 26)
    openButton.BackgroundColor3 = DARKER
    openButton.BackgroundTransparency = 0.15
    openButton.Text = "VER ITEM"
    openButton.TextColor3 = WHITE
    openButton.Font = Enum.Font.GothamMedium
    openButton.TextSize = 8
    openButton.ZIndex = 6
    openButton.Parent = row

    addCorner(openButton, 8)
    addStroke(openButton, WHITE, 1, 0.35)

    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyId"
    copyButton.Size = UDim2.new(0, 68, 0, 20)
    copyButton.Position = UDim2.new(1, -78, 0, 50)
    copyButton.BackgroundColor3 = DARKER
    copyButton.BackgroundTransparency = 0.15
    copyButton.Text = "COPIAR ID"
    copyButton.TextColor3 = WHITE
    copyButton.Font = Enum.Font.GothamMedium
    copyButton.TextSize = 8
    copyButton.ZIndex = 6
    copyButton.Parent = row

    addCorner(copyButton, 8)
    addStroke(copyButton, WHITE, 1, 0.35)

    openButton.Activated:Connect(function()
        local url = "https://www.roblox.com/catalog/" .. tostring(assetId)

        if typeof(setclipboard) == "function" then
            pcall(setclipboard, url)
            Status.Text = "Link copiado: " .. tostring(itemName)
        else
            Status.Text = url
        end
    end)

    copyButton.Activated:Connect(function()
        if typeof(setclipboard) == "function" then
            pcall(setclipboard, tostring(assetId))
            Status.Text = "ID copiado: " .. tostring(assetId)
        else
            Status.Text = "ID: " .. tostring(assetId)
        end
    end)
end

local function getPrice(assetId)
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
    end)

    if success and info then
        return info.PriceInRobux, info.Creator and info.Creator.Name or "Roblox"
    end

    return nil, "Desconhecido"
end

local function addAsset(assetId, itemName, itemType)
    if not assetId or assetId <= 0 then
        return
    end

    local price, creator = getPrice(assetId)
    addResult(itemName, itemType, assetId, price, creator)
end

local function getPlayerBySearch(query)
    local lowered = string.lower(query)

    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == lowered
            or string.lower(player.DisplayName) == lowered then
            return player.UserId, player.Name, player.DisplayName
        end
    end

    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(query)
    end)

    if success and userId then
        return userId, query, query
    end

    return nil
end

local busy = false

local function searchPlayer()
    if busy then return end

    local query = string.gsub(SearchBox.Text, "^%s*(.-)%s*$", "%1")

    if query == "" then
        Status.Text = "Digite um nick ou DisplayName."
        return
    end

    busy = true
    clearResults()
    Avatar.Image = ""
    ProfileName.Text = "Pesquisando..."
    ProfileUser.Text = ""
    Status.Text = "Buscando jogador..."

    task.spawn(function()
        local userId, username, displayName = getPlayerBySearch(query)

        if not userId then
            ProfileName.Text = "Jogador não encontrado"
            ProfileUser.Text = ""
            Status.Text = "Confira o username e tente novamente."
            busy = false
            return
        end

        ProfileName.Text = displayName or username
        ProfileUser.Text = "@" .. tostring(username) .. " | ID: " .. tostring(userId)
        Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
        Status.Text = "Carregando corpo, roupas e acessórios..."

        local success, description = pcall(function()
            return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
        end)

        if not success or not description then
            Status.Text = "Não foi possível carregar o avatar."
            busy = false
            return
        end

        local found = 0

        local bodyParts = {
            {name = "Cabeça (Head)", id = description.Head, kind = "Parte do corpo"},
            {name = "Torso", id = description.Torso, kind = "Parte do corpo"},
            {name = "Braço Esquerdo", id = description.LeftArm, kind = "Parte do corpo"},
            {name = "Braço Direito", id = description.RightArm, kind = "Parte do corpo"},
            {name = "Perna Esquerda", id = description.LeftLeg, kind = "Parte do corpo"},
            {name = "Perna Direita", id = description.RightLeg, kind = "Parte do corpo"},
            {name = "Camisa clássica", id = description.Shirt, kind = "Roupa"},
            {name = "Calça clássica", id = description.Pants, kind = "Roupa"},
            {name = "Camiseta clássica", id = description.GraphicTShirt, kind = "Roupa"},
            {name = "Rosto", id = description.Face, kind = "Corpo"}
        }

        for _, item in ipairs(bodyParts) do
            if item.id and item.id > 0 then
                addAsset(item.id, item.name, item.kind)
                found = found + 1
                task.wait(0.05)
            end
        end

        local successAccessories, accessories = pcall(function()
            return description:GetAccessories(true)
        end)

        if successAccessories and accessories then
            for _, accessory in ipairs(accessories) do
                local assetId = accessory.AssetId

                if assetId and assetId > 0 then
                    addAsset(assetId, tostring(accessory.AccessoryType or "Acessório"), "Acessório")
                    found = found + 1
                    task.wait(0.05)
                end
            end
        end

        local successEmotes, emotes = pcall(function()
            return description:GetEmotes()
        end)

        if successEmotes and emotes then
            for _, emote in ipairs(emotes) do
                local assetId = emote.AssetId

                if assetId and assetId > 0 then
                    addAsset(assetId, "Emote", "Emote")
                    found = found + 1
                    task.wait(0.05)
                end
            end
        end

        if found == 0 then
            Status.Text = "Nenhum item encontrado."
        else
            Status.Text = tostring(found) .. " itens encontrados."
        end

        busy = false
    end)
end

SearchButton.Activated:Connect(searchPlayer)

SearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        searchPlayer()
    end
end)

Close.Activated:Connect(function()
    ScreenGui:Destroy()
end)

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
    end
})

SugestionTab:AddSection({ "Chat Translator" })


SugestionTab:AddButton({
    Name = "Abrir Tradutor",
    Callback = function()
        local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("TranslatorHub")
if old then old:Destroy() end
local oldBtn = playerGui:FindFirstChild("TranslatorHubToggle")
if oldBtn then oldBtn:Destroy() end

local function urlEncode(str)
    return (str:gsub("([^%w%-%_%.%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

local function doRequest(url)
    local opts = {Url = url, Method = "GET"}
    local methods = {
        function() return syn and syn.request and syn.request(opts) end,
        function() return http_request and http_request(opts) end,
        function() return request and request(opts) end,
        function() return http and http.request and http.request(opts) end,
        function() return fluxus and fluxus.request and fluxus.request(opts) end,
    }
    for _, fn in ipairs(methods) do
        local ok, res = pcall(fn)
        if ok and res and res.Body then return res end
    end
    return nil
end

local cache = {}

local function translate(text, target)
    local key = target .. "|" .. text
    if cache[key] then return cache[key] end

    local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl="
        .. target .. "&dt=t&q=" .. urlEncode(text)

    local res = doRequest(url)
    if not res then return nil end

    local ok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if not ok or type(data) ~= "table" or type(data[1]) ~= "table" then return nil end

    local t = ""
    for _, part in ipairs(data[1]) do
        if type(part) == "table" and type(part[1]) == "string" then t = t .. part[1] end
    end

    if t == "" then return nil end
    cache[key] = t
    return t
end

local languages = {
    {n="Português (Brasil)",c="pt"},{n="English",c="en"},{n="Español",c="es"},{n="Français",c="fr"},
    {n="Deutsch",c="de"},{n="Italiano",c="it"},{n="日本語",c="ja"},{n="한국어",c="ko"},
    {n="中文 (简体)",c="zh-CN"},{n="中文 (繁體)",c="zh-TW"},{n="Русский",c="ru"},{n="العربية",c="ar"},
    {n="हिन्दी",c="hi"},{n="Türkçe",c="tr"},{n="Nederlands",c="nl"},{n="Polski",c="pl"},
    {n="Українська",c="uk"},{n="ไทย",c="th"},{n="Tiếng Việt",c="vi"},{n="Indonesia",c="id"},
    {n="עברית",c="he"},{n="Ελληνικά",c="el"},{n="Čeština",c="cs"},{n="Română",c="ro"},
    {n="Magyar",c="hu"},{n="Svenska",c="sv"},{n="Dansk",c="da"},{n="Suomi",c="fi"},
    {n="Norsk",c="no"},{n="Български",c="bg"},{n="Српски",c="sr"},{n="Hrvatski",c="hr"},
    {n="Slovenčina",c="sk"},{n="Slovenščina",c="sl"},{n="বাংলা",c="bn"},{n="اردو",c="ur"},
    {n="فارسی",c="fa"},{n="தமிழ்",c="ta"},{n="తెలుగు",c="te"},{n="मराठी",c="mr"},
    {n="ગુજરાતી",c="gu"},{n="ಕನ್ನಡ",c="kn"},{n="മലയാളം",c="ml"},{n="ਪੰਜਾਬੀ",c="pa"},
    {n="नेपाली",c="ne"},{n="සිංහල",c="si"},{n="မြန်မာ",c="my"},{n="ខ្មែរ",c="km"},
    {n="ລາວ",c="lo"},{n="Монгол",c="mn"},{n="Қазақша",c="kk"},{n="O‘zbekcha",c="uz"},
    {n="Azərbaycan",c="az"},{n="ქართული",c="ka"},{n="Հայերեն",c="hy"},{n="Eesti",c="et"},
    {n="Latviešu",c="lv"},{n="Lietuvių",c="lt"},{n="Català",c="ca"},{n="Galego",c="gl"},
    {n="Euskara",c="eu"},{n="Afrikaans",c="af"},{n="Kiswahili",c="sw"},{n="Filipino",c="tl"},
    {n="Shqip",c="sq"},{n="Bosanski",c="bs"},{n="Македонски",c="mk"},{n="Íslenska",c="is"},
    {n="Irish",c="ga"},{n="Cymraeg",c="cy"},{n="Malti",c="mt"},{n="Esperanto",c="eo"},
    {n="Amharic",c="am"},{n="Armenian",c="hy"},{n="Assamese",c="as"},{n="Aymara",c="ay"},
    {n="Bambara",c="bm"},{n="Belarusian",c="be"},{n="Bhojpuri",c="bho"},{n="Cebuano",c="ceb"},
    {n="Chichewa",c="ny"},{n="Corsican",c="co"},{n="Dhivehi",c="dv"},{n="Dogri",c="doi"},
    {n="Ewe",c="ee"},{n="Frisian",c="fy"},{n="Guarani",c="gn"},{n="Haitian Creole",c="ht"},
    {n="Hausa",c="ha"},{n="Hawaiian",c="haw"},{n="Hmong",c="hmn"},{n="Igbo",c="ig"},
    {n="Ilocano",c="ilo"},{n="Javanese",c="jw"},{n="Kinyarwanda",c="rw"},{n="Konkani",c="gom"},
    {n="Krio",c="kri"},{n="Kurdish (Kurmanji)",c="ku"},{n="Kurdish (Sorani)",c="ckb"},{n="Kyrgyz",c="ky"},
    {n="Latin",c="la"},{n="Lingala",c="ln"},{n="Luganda",c="lg"},{n="Luxembourgish",c="lb"},
    {n="Maithili",c="mai"},{n="Malagasy",c="mg"},{n="Malay",c="ms"},{n="Maori",c="mi"},
    {n="Meiteilon",c="mni-Mtei"},{n="Mizo",c="lus"},{n="Odia",c="or"},{n="Oromo",c="om"},
    {n="Pashto",c="ps"},{n="Punjabi",c="pa"},{n="Quechua",c="qu"},{n="Samoan",c="sm"},
    {n="Sanskrit",c="sa"},{n="Scots Gaelic",c="gd"},{n="Sepedi",c="nso"},{n="Sesotho",c="st"},
    {n="Shona",c="sn"},{n="Sindhi",c="sd"},{n="Somali",c="so"},{n="Sundanese",c="su"},
    {n="Tajik",c="tg"},{n="Tatar",c="tt"},{n="Tigrinya",c="ti"},{n="Tsonga",c="ts"},
    {n="Turkmen",c="tk"},{n="Twi",c="ak"},{n="Uyghur",c="ug"},{n="Welsh",c="cy"},
    {n="Xhosa",c="xh"},{n="Yiddish",c="yi"},{n="Yoruba",c="yo"},{n="Zulu",c="zu"},
    {n="Acehnese",c="ace"},{n="Acholi",c="ach"},{n="Adyghe",c="ady"},{n="Afar",c="aa"},
    {n="Alur",c="alz"},{n="Angika",c="anp"},{n="Avar",c="av"},{n="Awadhi",c="awa"},
    {n="Balinese",c="ban"},{n="Baluchi",c="bal"},{n="Baoulé",c="bci"},{n="Bashkir",c="ba"},
    {n="Batak Karo",c="btx"},{n="Batak Simalungun",c="bts"},{n="Batak Toba",c="bbc"},{n="Bemba",c="bem"},
    {n="Betawi",c="bew"},{n="Bikol",c="bik"},{n="Breton",c="br"},{n="Buryat",c="bua"},
    {n="Cantonese",c="yue"},{n="Chamorro",c="ch"},{n="Chechen",c="ce"},{n="Chuukese",c="chk"},
    {n="Chuvash",c="cv"},{n="Crimean Tatar",c="crh"},{n="Dari",c="prs"},{n="Dinka",c="din"},
    {n="Dombe",c="dov"},{n="Dyula",c="dyu"},{n="Dzongkha",c="dz"},{n="Faroese",c="fo"},
    {n="Fijian",c="fj"},{n="Fon",c="fon"},{n="Friulian",c="fur"},{n="Fulani",c="ff"},
    {n="Ga",c="gaa"},{n="Gagauz",c="gag"},{n="Gilbertese",c="gil"},{n="Hakha Chin",c="cnh"},
    {n="Hiligaynon",c="hil"},{n="Hunsrik",c="hrx"},{n="Iban",c="iba"},{n="Idoma",c="idu"},
    {n="Inuktut",c="iu"},{n="Ibanag",c="ibg"},{n="Jamaican Patois",c="jam"},{n="Jingpo",c="kac"},
    {n="Kalaallisut",c="kl"},{n="Kamba",c="kam"},{n="Kanuri",c="knc"},{n="Kapampangan",c="pam"},
    {n="Karakalpak",c="kaa"},{n="Kashmiri",c="ks"},{n="Kikongo",c="kg"},{n="Kituba",c="ktu"},
    {n="Komi",c="kv"},{n="Kongo",c="kon"},{n="Kreol Morisien",c="mfe"},{n="Ligurian",c="lij"},
    {n="Limburgish",c="li"},{n="Lombard",c="lmo"},{n="Luo",c="luo"},{n="Madurese",c="mad"},
    {n="Makassar",c="mak"},{n="Mam",c="mam"},{n="Manx",c="gv"},{n="Marshallese",c="mh"},
    {n="Marwari",c="mwr"},{n="Minangkabau",c="min"},{n="Nahuatl",c="nah"},{n="Ndau",c="ndc"},
    {n="Ndebele (South)",c="nr"},{n="Nepalbhasa",c="new"},{n="NKo",c="nqo"},{n="Nuer",c="nus"},
    {n="Occitan",c="oc"},{n="Ossetian",c="os"},{n="Pangasinan",c="pag"},{n="Papiamento",c="pap"},
    {n="Pontic",c="pnt"},{n="Romani",c="rom"},{n="Rundi",c="rn"},{n="Sami (North)",c="se"},
    {n="Sango",c="sg"},{n="Santali",c="sat"},{n="Sardinian",c="sc"},{n="Sicilian",c="scn"},
    {n="Silesian",c="szl"},{n="Sranan Tongo",c="srn"},{n="Susu",c="sus"},{n="Tahitian",c="ty"},
    {n="Tamashek",c="tmh"},{n="Tamazight",c="ber"},{n="Tetum",c="tet"},{n="Tigre",c="tig"},
    {n="Tiv",c="tiv"},{n="Tok Pisin",c="tpi"},{n="Tongan",c="to"},{n="Tshiluba",c="lua"},
    {n="Tumbuka",c="tum"},{n="Tuvaluan",c="tvl"},{n="Udmurt",c="udm"},{n="Umbundu",c="umb"},
    {n="Venda",c="ve"},{n="Venetian",c="vec"},{n="Waray",c="war"},{n="Wolof",c="wo"},
    {n="Yakut",c="sah"},{n="Yucatec Maya",c="yua"},{n="Zapotec",c="zap"},{n="Zaza",c="zza"},
    {n="Abkhaz",c="ab"},{n="Akan",c="ak"},{n="Asturian",c="ast"},{n="Bislama",c="bi"},
    {n="Braj",c="bra"},{n="Burmese",c="my"},{n="Chhattisgarhi",c="hne"},{n="Dholuo",c="luo"},
    {n="Efik",c="efi"},{n="Fante",c="fat"},{n="Fula",c="ff"},{n="Ganda",c="lg"},
    {n="Gilaki",c="glk"},{n="Gorontalo",c="gor"},{n="Gusii",c="guz"},{n="Haryanvi",c="bgc"},
    {n="Herero",c="hz"},{n="Hiri Motu",c="ho"},{n="Ijoo",c="ijc"},{n="Inuktitut",c="iu"},
    {n="Kabardian",c="kbd"},{n="Kabyle",c="kab"},{n="Kalenjin",c="kln"},{n="Kashubian",c="csb"},
    {n="Kekchi",c="kek"},{n="Kikuyu",c="ki"},{n="Kimbundu",c="kmb"},{n="Kirundi",c="rn"},
    {n="Komi-Permyak",c="koi"},{n="Kumaoni",c="kfy"},{n="Kurukh",c="kru"},{n="Kwanyama",c="kj"},
    {n="Ladino",c="lad"},{n="Lango",c="laj"},{n="Luba-Katanga",c="lu"},{n="Luba-Lulua",c="lua"},
    {n="Lunda",c="lun"},{n="Magahi",c="mag"},{n="Mandinka",c="mnk"},{n="Mansi",c="mns"},
    {n="Mazanderani",c="mzn"},{n="Mende",c="men"},{n="Meru",c="mer"},{n="Moksha",c="mdf"},
    {n="Mongo",c="lol"},{n="Mossi",c="mos"},{n="Nama",c="naq"},{n="Ndebele (North)",c="nd"},
    {n="Ndonga",c="ng"},{n="Neapolitan",c="nap"},{n="Newari",c="new"},{n="Nias",c="nia"},
    {n="Nyankole",c="nyn"},{n="Nzema",c="nzi"},{n="Ojibwe",c="oj"},{n="Palauan",c="pau"},
    {n="Pohnpeian",c="pon"},{n="Rarotongan",c="rar"},{n="Rombo",c="rof"},{n="Rukiga",c="cgg"},
    {n="Rutoro",c="ttj"},{n="Saho",c="ssy"},{n="Samburu",c="saq"},{n="Sena",c="seh"},
    {n="Serer",c="srr"},{n="Shan",c="shn"},{n="Shilha",c="shi"},{n="Sidamo",c="sid"},
    {n="Soga",c="xog"},{n="Soninke",c="snk"},{n="Sukuma",c="suk"},{n="Tachelhit",c="shi"},
    {n="Tagalog",c="tl"},{n="Tswana",c="tn"},{n="Yao",c="yao"},{n="Yapese",c="yap"},
    {n="Zarma",c="dje"},{n="Zazaki",c="zza"}
}

local sizes = {
    {n="P",  w=520, h=300, chatW=360},
    {n="M",  w=680, h=400, chatW=460},
    {n="G",  w=820, h=480, chatW=560},
    {n="GG", w=960, h=560, chatW=660}
}
local currentSize = 2

local selectedLang1 = "pt"
local selectedLang2 = "pt"
local chatOpen = false
local dd1Open, dd2Open = false, false
local autoTranslate = true
local uiVisible = true

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local WHITE = Color3.fromRGB(255,255,255)
local BLACK = Color3.fromRGB(0,0,0)
local DARK = Color3.fromRGB(18,18,22)
local DARK2 = Color3.fromRGB(28,28,34)
local LIGHT = Color3.fromRGB(220,220,225)

local gui = create("ScreenGui", {
    Name = "TranslatorHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local function T(parent, props)
    local base = {
        BackgroundTransparency = 1,
        TextColor3 = WHITE,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 10
    }
    for k,v in pairs(props) do base[k] = v end
    local label = create("TextLabel", base, parent)
    create("UIStroke", {
        Color = BLACK,
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Round
    }, label)
    return label
end

local function B(parent, props, radius)
    local base = {
        BackgroundColor3 = DARK,
        BorderSizePixel = 0,
        TextColor3 = WHITE,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 8,
        AutoButtonColor = false
    }
    for k,v in pairs(props) do base[k] = v end
    local btn = create("TextButton", base, parent)
    create("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, btn)
    create("UIStroke", {Color = WHITE, Thickness = 1.5, Transparency = 0.5}, btn)
    create("UIStroke", {
        Color = BLACK,
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Round
    }, btn)
    local orig = base.BackgroundColor3
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = DARK2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = orig}):Play()
    end)
    return btn
end

local toggleGui = create("ScreenGui", {
    Name = "TranslatorHubToggle",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local toggleBtn = create("ImageButton", {
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.new(0, 30, 0.5, -28),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.15,
    Image = "rbxassetid://4801560936",
    ImageColor3 = WHITE,
    ScaleType = Enum.ScaleType.Fit,
    AutoButtonColor = false,
    Active = true,
    ZIndex = 100
}, toggleGui)
create("UICorner", {CornerRadius = UDim.new(1, 0)}, toggleBtn)
create("UIStroke", {Color = WHITE, Thickness = 2, Transparency = 0.15}, toggleBtn)
create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
}, toggleBtn)

local btnDragging = false
local btnDragStart, btnStartPos
local btnMoved = false

toggleBtn.InputBegan:Connect(function(io)
    if io.UserInputType == Enum.UserInputType.MouseButton1
        or io.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnMoved = false
        btnDragStart = io.Position
        btnStartPos = toggleBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(io)
    if btnDragging and (io.UserInputType == Enum.UserInputType.MouseMovement
        or io.UserInputType == Enum.UserInputType.Touch) then
        local delta = io.Position - btnDragStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
            btnMoved = true
        end
        toggleBtn.Position = UDim2.new(
            btnStartPos.X.Scale,
            btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale,
            btnStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(io)
    if io.UserInputType == Enum.UserInputType.MouseButton1
        or io.UserInputType == Enum.UserInputType.Touch then
        if btnDragging and not btnMoved then
            uiVisible = not uiVisible
            gui.Enabled = uiVisible
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                BackgroundTransparency = uiVisible and 0.15 or 0.5
            }):Play()
        end
        btnDragging = false
    end
end)

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(sizes[currentSize].w, sizes[currentSize].h),
    Position = UDim2.new(0.5, -sizes[currentSize].w/2, 0.5, -sizes[currentSize].h/2),
    BackgroundColor3 = BLACK,
    BorderSizePixel = 0,
    ClipsDescendants = false,
    Active = true
}, gui)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, main)
create("UIStroke", {Color = WHITE, Thickness = 2, Transparency = 0.15}, main)
create("ImageLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = "rbxassetid://96950435500656",
    ImageTransparency = 0.5,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 1
}, main)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, main:FindFirstChildWhichIsA("ImageLabel"))
create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 2
}, main)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, main:FindFirstChildWhichIsA("Frame"))

local titleBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 3
}, main)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, titleBar)
create("Frame", {
    Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 3
}, titleBar)

T(main, {
    Position = UDim2.fromOffset(20, 12),
    Size = UDim2.new(0, 400, 0, 26),
    Text = "TRANSLATOR HUB",
    Font = Enum.Font.GothamBold,
    TextSize = 22
})
T(main, {
    Position = UDim2.fromOffset(20, 36),
    Size = UDim2.new(0, 400, 0, 18),
    Text = "350+ idiomas",
    TextSize = 11
})

local close = B(main, {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -46, 0, 13),
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 22
}, 10)

local sizeNames = {"P", "M", "G", "GG"}
local sizeButtons = {}
local sizeBar = create("Frame", {
    Position = UDim2.new(1, -230, 0, 17),
    Size = UDim2.fromOffset(180, 26),
    BackgroundTransparency = 1,
    ZIndex = 6
}, main)
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
}, sizeBar)
for i = 1, 4 do
    local b = B(sizeBar, {
        Size = UDim2.fromOffset(42, 26),
        Text = sizeNames[i],
        TextSize = 12,
        LayoutOrder = i
    }, 8)
    sizeButtons[i] = b
end

local input = create("TextBox", {
    Position = UDim2.fromOffset(20, 80),
    Size = UDim2.new(1, -218, 0, 128),
    BackgroundColor3 = DARK,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    MultiLine = true,
    Text = "",
    PlaceholderText = "Escreva sua mensagem aqui...",
    PlaceholderColor3 = LIGHT,
    TextColor3 = WHITE,
    TextSize = 15,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 4
}, main)
create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
}, input)
create("UICorner", {CornerRadius = UDim.new(0, 10)}, input)
create("UIStroke", {Color = WHITE, Thickness = 1.5, Transparency = 0.4}, input)

local langBtn1 = B(main, {
    Position = UDim2.new(1, -188, 0, 80),
    Size = UDim2.fromOffset(168, 40),
    Text = "Português (Brasil) ▼",
    TextSize = 12
}, 10)
langBtn1.TextTruncate = Enum.TextTruncate.AtEnd

local send = B(main, {
    Position = UDim2.new(1, -188, 0, 126),
    Size = UDim2.fromOffset(168, 52),
    Text = "ENVIAR",
    Font = Enum.Font.GothamBold,
    TextSize = 13
}, 10)
send.BackgroundColor3 = WHITE
send.TextColor3 = BLACK
send.MouseEnter:Connect(function()
    TweenService:Create(send, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230,230,230)}):Play()
end)
send.MouseLeave:Connect(function()
    TweenService:Create(send, TweenInfo.new(0.15), {BackgroundColor3 = WHITE}):Play()
end)

local status = T(main, {
    Position = UDim2.fromOffset(20, 218),
    Size = UDim2.new(1, -50, 0, 20),
    Text = "Pronto para traduzir",
    TextSize = 12
})

local autoBtn = B(main, {
    Position = UDim2.fromOffset(20, 244),
    Size = UDim2.fromOffset(200, 30),
    Text = "Auto-tradução: LIGADA",
    TextSize = 12
}, 10)

local openChatBtn = B(main, {
    Position = UDim2.new(1, -50, 1, -44),
    Size = UDim2.fromOffset(34, 30),
    Text = ">",
    Font = Enum.Font.GothamBold,
    TextSize = 18
}, 10)

local dd1 = create("Frame", {
    Position = UDim2.new(1, -188, 0, 122),
    Size = UDim2.fromOffset(168, 280),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20
}, main)
create("UICorner", {CornerRadius = UDim.new(0, 10)}, dd1)
create("UIStroke", {Color = WHITE, Thickness = 1.5, Transparency = 0.3}, dd1)

local dd1Search = create("TextBox", {
    Position = UDim2.fromOffset(6, 6),
    Size = UDim2.new(1, -12, 0, 26),
    BackgroundColor3 = DARK2,
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "Buscar...",
    PlaceholderColor3 = LIGHT,
    TextColor3 = WHITE,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    ClearTextOnFocus = false,
    ZIndex = 22
}, dd1)
create("UICorner", {CornerRadius = UDim.new(0, 6)}, dd1Search)
create("UIStroke", {Color = WHITE, Thickness = 1, Transparency = 0.5}, dd1Search)
create("UIPadding", {PaddingLeft = UDim.new(0, 8)}, dd1Search)

local dd1Scroll = create("ScrollingFrame", {
    Position = UDim2.fromOffset(6, 36),
    Size = UDim2.new(1, -12, 1, -42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = WHITE,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 21
}, dd1)
create("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, dd1Scroll)

local dd1Entries = {}
local function renderDd1(filter)
    for _, e in ipairs(dd1Entries) do e:Destroy() end
    dd1Entries = {}
    filter = (filter or ""):lower()
    for i, lang in ipairs(languages) do
        if filter == "" or lang.n:lower():find(filter, 1, true) then
            local b = B(dd1Scroll, {
                Size = UDim2.new(1, -4, 0, 26),
                Text = lang.n,
                TextSize = 11,
                LayoutOrder = i
            }, 6)
            b.TextTruncate = Enum.TextTruncate.AtEnd
            b.MouseButton1Click:Connect(function()
                selectedLang1 = lang.c
                langBtn1.Text = lang.n .. " ▼"
                dd1.Visible = false
                dd1Open = false
            end)
            table.insert(dd1Entries, b)
        end
    end
end
renderDd1("")
dd1Search:GetPropertyChangedSignal("Text"):Connect(function()
    renderDd1(dd1Search.Text)
end)

local chat = create("Frame", {
    Name = "Chat",
    Size = UDim2.fromOffset(0, sizes[currentSize].h),
    Position = UDim2.new(0.5, sizes[currentSize].w/2 + 16, 0.5, -sizes[currentSize].h/2),
    BackgroundColor3 = BLACK,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true
}, gui)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, chat)
create("UIStroke", {Color = WHITE, Thickness = 2, Transparency = 0.15}, chat)
create("ImageLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = "rbxassetid://96950435500656",
    ImageTransparency = 0.5,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 1
}, chat)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, chat:FindFirstChildWhichIsA("ImageLabel"))
create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    ZIndex = 2
}, chat)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, chat:FindFirstChildWhichIsA("Frame"))

local chatHeader = create("Frame", {
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 3
}, chat)
create("UICorner", {CornerRadius = UDim.new(0, 16)}, chatHeader)
create("Frame", {
    Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 3
}, chatHeader)

T(chat, {
    Position = UDim2.fromOffset(20, 12),
    Size = UDim2.new(1, -80, 0, 24),
    Text = "CHAT TRADUZIDO",
    Font = Enum.Font.GothamBold,
    TextSize = 18
})
T(chat, {
    Position = UDim2.fromOffset(20, 36),
    Size = UDim2.new(1, -80, 0, 16),
    Text = "Traduzindo mensagens recebidas",
    TextSize = 11
})

local closeChat = B(chat, {
    Position = UDim2.new(1, -46, 0, 13),
    Size = UDim2.fromOffset(34, 34),
    Text = "<",
    Font = Enum.Font.GothamBold,
    TextSize = 18
}, 10)

local langBtn2 = B(chat, {
    Position = UDim2.fromOffset(20, 76),
    Size = UDim2.new(1, -40, 0, 36),
    Text = "Traduzir para: Português (Brasil) ▼",
    TextSize = 12
}, 10)
langBtn2.TextTruncate = Enum.TextTruncate.AtEnd

local dd2 = create("Frame", {
    Position = UDim2.fromOffset(20, 116),
    Size = UDim2.new(1, -40, 0, 340),
    BackgroundColor3 = BLACK,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20
}, chat)
create("UICorner", {CornerRadius = UDim.new(0, 10)}, dd2)
create("UIStroke", {Color = WHITE, Thickness = 1.5, Transparency = 0.3}, dd2)

local dd2Search = create("TextBox", {
    Position = UDim2.fromOffset(6, 6),
    Size = UDim2.new(1, -12, 0, 26),
    BackgroundColor3 = DARK2,
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "Buscar...",
    PlaceholderColor3 = LIGHT,
    TextColor3 = WHITE,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    ClearTextOnFocus = false,
    ZIndex = 22
}, dd2)
create("UICorner", {CornerRadius = UDim.new(0, 6)}, dd2Search)
create("UIStroke", {Color = WHITE, Thickness = 1, Transparency = 0.5}, dd2Search)
create("UIPadding", {PaddingLeft = UDim.new(0, 8)}, dd2Search)

local dd2Scroll = create("ScrollingFrame", {
    Position = UDim2.fromOffset(6, 36),
    Size = UDim2.new(1, -12, 1, -42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = WHITE,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 21
}, dd2)
create("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, dd2Scroll)

local dd2Entries = {}
local function renderDd2(filter)
    for _, e in ipairs(dd2Entries) do e:Destroy() end
    dd2Entries = {}
    filter = (filter or ""):lower()
    for i, lang in ipairs(languages) do
        if filter == "" or lang.n:lower():find(filter, 1, true) then
            local b = B(dd2Scroll, {
                Size = UDim2.new(1, -4, 0, 26),
                Text = lang.n,
                TextSize = 11,
                LayoutOrder = i
            }, 6)
            b.TextTruncate = Enum.TextTruncate.AtEnd
            b.MouseButton1Click:Connect(function()
                selectedLang2 = lang.c
                langBtn2.Text = "Traduzir para: " .. lang.n .. " ▼"
                dd2.Visible = false
                dd2Open = false
            end)
            table.insert(dd2Entries, b)
        end
    end
end
renderDd2("")
dd2Search:GetPropertyChangedSignal("Text"):Connect(function()
    renderDd2(dd2Search.Text)
end)

local messages = create("ScrollingFrame", {
    Position = UDim2.fromOffset(16, 122),
    Size = UDim2.new(1, -32, 1, -140),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = WHITE,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 8
}, chat)
create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, messages)

local function addMessage(author, original, translated)
    local card = create("Frame", {
        Size = UDim2.new(1, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = DARK,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 9
    }, messages)
    create("UICorner", {CornerRadius = UDim.new(0, 10)}, card)
    create("UIStroke", {Color = WHITE, Thickness = 1, Transparency = 0.55}, card)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    }, card)
    create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, card)

    T(card, {
        Size = UDim2.new(1, 0, 0, 16),
        Text = author,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        LayoutOrder = 1
    })
    T(card, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = original,
        TextSize = 12,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2
    })
    if translated and translated ~= "" then
        T(card, {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "→ " .. translated,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 3
        })
    end

    task.defer(function()
        messages.CanvasPosition = Vector2.new(0, math.max(0, messages.AbsoluteCanvasSize.Y - messages.AbsoluteSize.Y))
    end)
    local kids = {}
    for _, c in ipairs(messages:GetChildren()) do
        if c:IsA("Frame") then table.insert(kids, c) end
    end
    while #kids > 60 do
        kids[1]:Destroy()
        table.remove(kids, 1)
    end
end

local function applySize(idx)
    currentSize = idx
    local s = sizes[idx]
    main.Size = UDim2.fromOffset(s.w, s.h)
    chat.Size = UDim2.fromOffset(chatOpen and s.chatW or 0, s.h)
    for i, b in ipairs(sizeButtons) do
        if i == idx then
            b.BackgroundColor3 = WHITE
            b.TextColor3 = BLACK
        else
            b.BackgroundColor3 = DARK
            b.TextColor3 = WHITE
        end
    end
    local vp = workspace.CurrentCamera.ViewportSize
    local baseX = (vp.X - s.w) / 2
    local baseY = (vp.Y - s.h) / 2
    main.Position = UDim2.fromOffset(baseX, baseY)
    chat.Position = UDim2.fromOffset(baseX + s.w + 16, baseY)
end
for i, b in ipairs(sizeButtons) do
    b.MouseButton1Click:Connect(function() applySize(i) end)
end

langBtn1.MouseButton1Click:Connect(function()
    dd1Open = not dd1Open
    dd1.Visible = dd1Open
    if dd1Open then dd2.Visible = false; dd2Open = false end
end)
langBtn2.MouseButton1Click:Connect(function()
    dd2Open = not dd2Open
    dd2.Visible = dd2Open
    if dd2Open then dd1.Visible = false; dd1Open = false end
end)

autoBtn.MouseButton1Click:Connect(function()
    autoTranslate = not autoTranslate
    autoBtn.Text = autoTranslate and "Auto-tradução: LIGADA" or "Auto-tradução: DESLIGADA"
end)

openChatBtn.MouseButton1Click:Connect(function()
    chatOpen = true
    openChatBtn.Visible = false
    TweenService:Create(chat, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(sizes[currentSize].chatW, sizes[currentSize].h)
    }):Play()
end)
closeChat.MouseButton1Click:Connect(function()
    chatOpen = false
    local t = TweenService:Create(chat, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, sizes[currentSize].h)
    })
    t:Play()
    t.Completed:Connect(function()
        if not chatOpen then openChatBtn.Visible = true end
    end)
end)

send.MouseButton1Click:Connect(function()
    local text = input.Text
    if text:gsub("%s", "") == "" then
        status.Text = "Digite uma mensagem primeiro"
        return
    end
    send.Active = false
    status.Text = "Traduzindo..."
    task.spawn(function()
        local t = translate(text, selectedLang1)
        if t then
            local channels = TextChatService:FindFirstChild("TextChannels")
            local general = channels and channels:FindFirstChild("RBXGeneral")
            local sent = false
            if general then sent = pcall(function() general:SendAsync(t) end) end
            status.Text = sent and "Mensagem enviada!" or "Tradução pronta (copie)"
            addMessage("Você", text, t)
            input.Text = ""
        else
            status.Text = "Falha na tradução"
        end
        send.Active = true
    end)
end)

local dragging = false
local dragStart, startMain, startChat
titleBar.InputBegan:Connect(function(io)
    if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = io.Position
        startMain = main.Position
        startChat = chat.Position
    end
end)
UserInputService.InputChanged:Connect(function(io)
    if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
        local d = io.Position - dragStart
        main.Position = UDim2.new(startMain.X.Scale, startMain.X.Offset + d.X, startMain.Y.Scale, startMain.Y.Offset + d.Y)
        chat.Position = UDim2.new(startChat.X.Scale, startChat.X.Offset + d.X, startChat.Y.Scale, startChat.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(io)
    if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

close.MouseButton1Click:Connect(function()
    uiVisible = false
    gui.Enabled = false
end)

TextChatService.MessageReceived:Connect(function(message)
    if not autoTranslate then return end
    if not message.TextSource then return end
    if message.TextSource.UserId == player.UserId then return end
    local original = message.Text
    local author = "Jogador"
    local speaker = Players:GetPlayerByUserId(message.TextSource.UserId)
    if speaker then
        author = speaker.DisplayName .. " (@" .. speaker.Name .. ")"
    elseif message.PrefixText and message.PrefixText ~= "" then
        author = message.PrefixText
    end
    task.spawn(function()
        local t = translate(original, selectedLang2)
        addMessage(author, original, t or "?")
    end)
end)

applySize(currentSize)
    end
})



local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local SRV_FILE = "saved_servers.json"
local Servers = {}

local function loadServers()
    if not isfile(SRV_FILE) then return {} end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(SRV_FILE))
    end)
    return ok and data or {}
end

local function saveServers()
    pcall(function()
        writefile(SRV_FILE, HttpService:JSONEncode(Servers))
    end)
end

Servers = loadServers()

local tempServerName = nil
local serversDropdownRef = nil
local serverList = {}
local serverLookup = {}

local function buildServerList()
    serverList = {}
    serverLookup = {}
    local nomes = {}
    for nome, _ in pairs(Servers) do
        table.insert(nomes, nome)
    end
    table.sort(nomes)
    for _, nome in ipairs(nomes) do
        local label = string.format("%s  [%d]", nome, Servers[nome].placeId)
        table.insert(serverList, label)
        serverLookup[label] = Servers[nome]
    end
end

local function joinServer(info)
    if not info or not info.placeId or not info.jobId then return end
    pcall(function()
        TeleportService:TeleportToPlaceInstance(info.placeId, info.jobId, Players.LocalPlayer)
    end)
end

SugestionTab:AddSection({ "Salvar Server" })


SugestionTab:AddTextBox({
    Name = "Nome do server",
    PlaceholderText = "ex: Server 1",
    Callback = function(value)
        tempServerName = value
    end
})

SugestionTab:AddButton({
    Name = "Salvar server atual",
    Callback = function()
        if not tempServerName or tempServerName == "" then return end

        local placeId = game.PlaceId
        local jobId = game.JobId

        if jobId == "" then return end

        Servers[tempServerName] = {
            placeId = placeId,
            jobId = tostring(jobId)
        }
        saveServers()

        buildServerList()
        if serversDropdownRef and serversDropdownRef.Refresh then
            serversDropdownRef:Refresh(serverList)
        end
    end
})

SugestionTab:AddSection({ "Entrar em Server Salvo" })

buildServerList()

serversDropdownRef = SugestionTab:AddDropdown({
    Name = "Servers salvos",
    Description = "clique pra entrar",
    Options = serverList,
    Multi = false,
    Callback = function(escolhido)
        joinServer(serverLookup[escolhido])
    end
})

SugestionTab:AddSection({ "Remover Server (nome exato)" })

SugestionTab:AddTextBox({
    Name = "Remover server",
    PlaceholderText = "ex: Server 1",
    Callback = function(value)
        if value and Servers[value] then
            Servers[value] = nil
            saveServers()
            buildServerList()
            if serversDropdownRef and serversDropdownRef.Refresh then
                serversDropdownRef:Refresh(serverList)
            end
        end
    end
})



local InfoTab = Window:MakeTab({ "Informations", "info" })

InfoTab:AddSection({ "Internet Things" })

InfoTab:AddDiscordInvite({
    Name = "Slayer Hub",
    Description = "Compre seu painel admin abaixo",
    Logo = "rbxassetid://103236620685520",
    Invite = "https://discord.gg/KSNnDfd6sW",
})


InfoTab:AddSection({ "Credits" })
InfoTab:AddParagraph({ "Owners", "Bazuka, Beca and Rick" })
InfoTab:AddParagraph({ "Programmer", "Bazuka and Rick" })
InfoTab:AddParagraph({ "functions", "Nexus, Luscaa and Ghost." })


do

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local RE = ReplicatedStorage:WaitForChild("RE")
local VirtualInputManager = game:GetService("VirtualInputManager")
local cam = Workspace.CurrentCamera

local RemoteClearTools = RE:FindFirstChild("1Clea1rTool1s")
local RemoteTools = RE:FindFirstChild("1Too1l")
local RemoteCar = RE:FindFirstChild("1Ca1r")

if not RemoteClearTools then
    RemoteClearTools = { FireServer = function() end }
end
if not RemoteTools then
    RemoteTools = { InvokeServer = function() end }
end
if not RemoteCar then
    RemoteCar = { FireServer = function() end }
end

workspace.FallenPartsDestroyHeight = -math.huge
local Target = nil
local CameraConnection = nil
local Network = nil
local OldPos = nil
local selectedPlayerName = nil
local methodKill = nil
local Character = LocalPlayer.Character
local Humanoid = Character and Character:WaitForChild("Humanoid")
local RootPart = Character and Character:WaitForChild("HumanoidRootPart")

local function cleanupCouch()
    local char = LocalPlayer.Character
    if char then
        local couch = char:FindFirstChild("Nova_Couch") or LocalPlayer.Backpack:FindFirstChild("Nova_Couch")
        if couch then couch:Destroy() end
    end
    RemoteClearTools:FireServer("ClearAllTools")
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    RootPart = newCharacter:WaitForChild("HumanoidRootPart")
    cleanupCouch()
    Humanoid.Died:Connect(cleanupCouch)
end)

if Humanoid then Humanoid.Died:Connect(cleanupCouch) end

local function CouchActionV2(actionType)
    local targetPlayer = Players:FindFirstChild(Target)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return warn("Error: Invalid target player")
    end
    RemoteClearTools:FireServer("ClearAllTools")
    RemoteTools:InvokeServer("PickingTools", "Couch")
    local couch = LocalPlayer.Backpack:WaitForChild("Couch", 2)
    if not couch then return warn("Error: Couch not found in Backpack") end
    couch.Name = (actionType == "kill") and "Nova_Couch" or couch.Name
    local seat1, seat2, handle = couch:FindFirstChild("Seat1"), couch:FindFirstChild("Seat2"), couch:FindFirstChild("Handle")
    if seat1 and seat2 and handle then
        seat1.Disabled, seat2.Disabled, handle.Name = true, true, "Handle "
    else
        return warn("Error: Couch components not found")
    end
    couch.Parent = LocalPlayer.Character
    local tet = Instance.new("BodyVelocity", seat1)
    tet.MaxForce, tet.P, tet.Velocity = Vector3.new(math.huge, math.huge, math.huge), 1250, Vector3.new()
    tet.Name = "#Hexagon"
    repeat
        for m = 1, 35 do
            local tRoot = targetPlayer.Character and targetPlayer.Character.HumanoidRootPart
            if not tRoot then break end
            local pos = tRoot.Position + (tRoot.Velocity / 2)
            seat1.CFrame = CFrame.new(pos) * CFrame.new(-2, 2, 0)
            task.wait()
        end
        tet:Destroy()
        couch.Parent = LocalPlayer.Backpack
        task.wait()
        couch:FindFirstChild("Handle ").Name = "Handle"
        task.wait(0.2)
        couch.Parent = LocalPlayer.Character
        task.wait()
        couch.Parent = LocalPlayer.Backpack
        couch.Handle.Name = "Handle "
        task.wait(0.2)
        couch.Parent = LocalPlayer.Character
        tet = Instance.new("BodyVelocity", seat1)
        tet.MaxForce, tet.P, tet.Velocity = Vector3.new(math.huge, math.huge, math.huge), 1250, Vector3.new()
        tet.Name = "#Hexagon"
    until targetPlayer.Character and targetPlayer.Character.Humanoid and targetPlayer.Character.Humanoid.Sit == true
    task.wait()
    if actionType == "kill" then
        couch.Parent = LocalPlayer.Backpack
        seat1.CFrame, seat2.CFrame = CFrame.new(Vector3.new(9999, -450, 9999)), CFrame.new(Vector3.new(9999, -450, 9999))
        couch.Parent = LocalPlayer.Character
        task.wait(0.1)
        couch.Parent = LocalPlayer.Backpack
        task.wait(2)
        local bv = seat1:FindFirstChild("#Hexagon")
        if bv then bv:Destroy() end
    else
        tet:Destroy()
        couch.Parent = LocalPlayer.Backpack
        task.wait()
        couch:FindFirstChild("Handle ").Name = "Handle"
        task.wait(0.3)
        couch.Parent = LocalPlayer.Character
        task.wait(0.3)
        couch.Grip = CFrame.new()
        task.wait(0.3)
    end
    RemoteClearTools:FireServer("ClearAllTools")
end

local Troll = Window:MakeTab({ Title = "Troll PLayers", Icon = "rbxassetid://17718995610" })

Troll:AddSection({ Name = "Options Players" })

local function getPlayerList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then names[#names + 1] = p.Name end
    end
    table.sort(names)
    return names
end

local killDropdown = Troll:AddDropdown({
    Name = "Select Player",
    Options = getPlayerList(),
    Default = "",
    Callback = function(value)
        selectedPlayerName = value
        Target = value
    end
})

Troll:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        local newPlayers = getPlayerList()
        if killDropdown then
            killDropdown:Set(newPlayers)
            if selectedPlayerName and not Players:FindFirstChild(selectedPlayerName) then
                selectedPlayerName, Target = nil, nil
                killDropdown:SetValue("")
            end
        end
    end
})

Troll:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        if not selectedPlayerName or not Players:FindFirstChild(selectedPlayerName) then return end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tRoot = Players[selectedPlayerName].Character and Players[selectedPlayerName].Character:FindFirstChild("HumanoidRootPart")
        if root and tRoot then root.CFrame = tRoot.CFrame end
    end
})

Troll:AddToggle({
    Name = "Spectate Player",
    Default = false,
    Callback = function(value)
        local function UpdateCamera()
            local targetHum = value and Players:FindFirstChild(selectedPlayerName) and Players[selectedPlayerName].Character and Players[selectedPlayerName].Character:FindFirstChild("Humanoid")
            cam.CameraSubject = targetHum or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) or cam.CameraSubject
        end
        if value then
            if not CameraConnection then CameraConnection = RunService.Heartbeat:Connect(UpdateCamera) end
        else
            if CameraConnection then CameraConnection:Disconnect(); CameraConnection = nil end
            UpdateCamera()
        end
    end
})



Troll:AddSection({ Name = "Methods" })

Troll:AddDropdown({
    Name = "Select Kill Method",
    Options = {"Bus", "Couch V2"},
    Default = "",
    Callback = function(value) methodKill = value end
})

Troll:AddButton({
    Name = "Kill Player",
    Callback = function()
        if not selectedPlayerName or not Players:FindFirstChild(selectedPlayerName) then return end
        if methodKill == "Couch V2" then
            CouchActionV2("kill")
        else
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            local originalPosition = humanoidRootPart.CFrame
            local function GetBus()
                local vehicles = Workspace:FindFirstChild("Vehicles")
                return vehicles and vehicles:FindFirstChild(LocalPlayer.Name .. "Car") or nil
            end
            local bus = GetBus()
            if not bus then
                humanoidRootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
                task.wait(0.5)
                RemoteCar:FireServer("PickingCar", "SchoolBus")
                task.wait(1)
                bus = GetBus()
            end
            if bus then
                local seat = bus:FindFirstChild("Body") and bus.Body:FindFirstChild("VehicleSeat")
                if seat and character:FindFirstChildOfClass("Humanoid") and not character.Humanoid.Sit then
                    repeat
                        humanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
                        task.wait()
                    until character.Humanoid.Sit or not bus.Parent
                    if character.Humanoid.Sit or not bus.Parent then
                        for _, v in ipairs(bus.Body:GetChildren()) do
                            if v:IsA("Seat") then v.CanTouch = false end
                        end
                    end
                end
            end
            task.spawn(function()
                while true do
                    if selectedPlayerName then
                        local targetPlayer = Players:FindFirstChild(selectedPlayerName)
                        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if targetHumanoid and targetHumanoid.Sit then
                                if character.Humanoid then
                                    bus:PivotTo(CFrame.new(9999, -450, 9999))
                                    task.wait(0.2)
                                    if character and character:FindFirstChildWhichIsA("Humanoid") then
                                        character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    task.wait(0.5)
                                    humanoidRootPart.CFrame = originalPosition
                                end
                                break
                            else
                                local targetRoot = targetPlayer.Character.HumanoidRootPart
                                local time = tick() * 35
                                bus:PivotTo(targetRoot.CFrame * CFrame.new(math.sin(time) * 4, 0, math.cos(time) * 20))
                            end
                        end
                    end
                    RunService.RenderStepped:Wait()
                end
            end)
        end
    end
})

local flingActive = false

Troll:AddToggle({
    Name = "Auto Fling",
    Default = false,
    Callback = function(state)
        flingActive = state
        if state and selectedPlayerName then
            local target = Players:FindFirstChild(selectedPlayerName)
            if not target or not target.Character then return end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if not root or not tRoot then return end
            local char = LocalPlayer.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local original = root.CFrame
            RemoteClearTools:FireServer("ClearAllTools")
            task.wait(0.2)
            RemoteTools:InvokeServer("PickingTools", "Couch")
            task.wait(0.3)
            local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
            if tool then tool.Parent = char end
            task.wait(0.2)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.25)
            workspace.FallenPartsDestroyHeight = 0/0
            local bv = Instance.new("BodyVelocity")
            bv.Name, bv.Velocity, bv.MaxForce = "FlingForce", Vector3.new(9e8, 9e8, 9e8), Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = root
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            hum.PlatformStand = false
            cam.CameraSubject = target.Character:FindFirstChild("Head") or tRoot or hum
            task.spawn(function()
                local angle = 0
                while flingActive and target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") do
                    local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                    if tHum.Sit then break end
                    angle = 50
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local pos = hrp.Position + (hrp.Velocity / 1.5)
                        root.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(angle), 0, 0)
                    end
                    root.Velocity, root.RotVelocity = Vector3.new(9e8, 9e8, 9e8), Vector3.new(9e8, 9e8, 9e8)
                    task.wait()
                end
                flingActive = false
                bv:Destroy()
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                hum.PlatformStand = false
                root.CFrame = original
                cam.CameraSubject = hum
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.Velocity, p.RotVelocity = Vector3.zero, Vector3.zero end
                end
                hum:UnequipTools()
                RemoteTools:InvokeServer("PickingTools", "Couch")
            end)
        end
    end
})

local function isItemInInventory(itemName) return LocalPlayer.Backpack:FindFirstChild(itemName) ~= nil end
local function equipItem(itemName) local item = LocalPlayer.Backpack:FindFirstChild(itemName); if item then LocalPlayer.Character.Humanoid:EquipTool(item) end end
local function unequipItem(itemName) local item = LocalPlayer.Character:FindFirstChild(itemName); if item then item.Parent = LocalPlayer.Backpack end end

Troll:AddSection({Name = "Aura"})

Troll:AddToggle({
    Name = "Doors Aura",
    Callback = function(state)
        if state then
            local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            local BlackHole = Instance.new("Part")
            BlackHole.Size, BlackHole.Transparency, BlackHole.Anchored, BlackHole.CanCollide = Vector3.new(100000, 100000, 100000), 1, true, false
            BlackHole.Name, BlackHole.Parent = "BlackHoleTarget", Workspace
            local baseAttachment = Instance.new("Attachment", BlackHole)
            baseAttachment.Name = "Luscaa_BlackHoleAttachment"
            RunService.Heartbeat:Connect(function() BlackHole.CFrame = HRP.CFrame end)
            local ControlledDoors = {}
            local function SetupPart(part)
                if not part:IsA("BasePart") or part.Anchored or not string.find(part.Name, "Door") then return end
                if part:FindFirstChild("Bazuka_Attached") then return end
                part.CanCollide = false
                for _, obj in ipairs(part:GetChildren()) do
                    if obj:IsA("AlignPosition") or obj:IsA("Torque") or obj:IsA("Attachment") then obj:Destroy() end
                end
                local marker = Instance.new("BoolValue", part)
                marker.Name = "Bazuka_Attached"
                local a1 = Instance.new("Attachment", part)
                local align = Instance.new("AlignPosition", part)
                align.Attachment0, align.Attachment1 = a1, baseAttachment
                align.MaxForce, align.MaxVelocity, align.Responsiveness = 1e20, math.huge, 99999
                local torque = Instance.new("Torque", part)
                torque.Attachment0, torque.RelativeTo = a1, Enum.ActuatorRelativeTo.World
                torque.Torque = Vector3.new(math.random(-10e5, 10e5)*10000, math.random(-10e5, 10e5)*10000, math.random(-10e5, 10e5)*10000)
                table.insert(ControlledDoors, {Part = part, Align = align})
            end
            for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("BasePart") and string.find(obj.Name, "Door") then SetupPart(obj) end end
            Workspace.DescendantAdded:Connect(function(obj) if obj:IsA("BasePart") and string.find(obj.Name, "Door") then SetupPart(obj) end end)
            local function FlingPlayer(player)
                local char = player.Character
                if not char then return end
                local targetHRP = char:FindFirstChild("HumanoidRootPart")
                if not targetHRP then return end
                local targetAttachment = targetHRP:FindFirstChild("SHNMAX_TargetAttachment") or Instance.new("Attachment", targetHRP)
                targetAttachment.Name = "SHNMAX_TargetAttachment"
                for _, data in ipairs(ControlledDoors) do if data.Align then data.Align.Attachment1 = targetAttachment end end
                local start = tick()
                while tick() - start < 5 do
                    if targetHRP.Velocity.Magnitude >= 20 then break end
                    RunService.Heartbeat:Wait()
                end
                for _, data in ipairs(ControlledDoors) do if data.Align then data.Align.Attachment1 = baseAttachment end end
            end
            UserInputService.TouchTap:Connect(function(touchPositions, processed)
                if processed then return end
                local pos = touchPositions[1]
                local unitRay = cam:ScreenPointToRay(pos.X, pos.Y)
                local raycast = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
                if raycast and raycast.Instance then
                    local player = Players:GetPlayerFromCharacter(raycast.Instance:FindFirstAncestorOfClass("Model"))
                    if player and player ~= LocalPlayer then FlingPlayer(player) end
                end
            end)
        else
            local blackHole = Workspace:FindFirstChild("BlackHoleTarget")
            if blackHole then blackHole:Destroy() end
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and string.find(part.Name, "Door") then
                    local marker = part:FindFirstChild("Bazuka_Attached")
                    if marker then marker:Destroy() end
                    for _, obj in ipairs(part:GetChildren()) do
                        if obj:IsA("AlignPosition") or obj:IsA("Torque") or obj:IsA("Attachment") then
                            obj:Destroy()
                        end
                    end
                    part.CanCollide = true
                end
            end
        end
    end
})

Troll:AddSection({Name = "All methods"})
local killBusActive = false
local killBusThreads = {}

Troll:AddToggle({
    Name = "Kill All Bus",
    Callback = function(state)
        if state then
            killBusActive = true
            local destination = Vector3.new(145.51, -374.09, 21.58) 
            local originalPosition = nil  
            
            local function GetBus()  
                local vehicles = Workspace:FindFirstChild("Vehicles")  
                return vehicles and vehicles:FindFirstChild(LocalPlayer.Name.."Car") or nil  
            end  
            
            local function TrackPlayer(selectedPlayerName, callback)
                while killBusActive do  
                    if selectedPlayerName then  
                        local targetPlayer = Players:FindFirstChild(selectedPlayerName)  
                        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then  
                            local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")  
                            if targetHumanoid and targetHumanoid.Sit then  
                                local bus = GetBus()
                                if bus then
                                    bus:PivotTo(CFrame.new(destination))
                                    task.wait(0.2)  
                                    local function simulateJump()  
                                        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")  
                                        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end  
                                    end  
                                    simulateJump()  
                                    task.wait(0.4)  
                                    simulateJump()
                                    task.wait(0.5)
                                    if originalPosition then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition  
                                        task.wait(0.1)
                                        RemoteCar:FireServer("DeleteAllVehicles")
                                    end
                                end
                                break  
                            else  
                                local targetRoot = targetPlayer.Character.HumanoidRootPart  
                                local time = tick() * 35
                                local bus = GetBus()
                                if bus then
                                    bus:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, math.cos(time) * 20))
                                end
                            end  
                        end  
                    end  
                    RunService.RenderStepped:Wait()  
                end
                if callback and killBusActive then callback() end
            end  
            
            local function StartKillBus(playerName, callback)
                if not killBusActive then return end
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")  
                originalPosition = humanoidRootPart.CFrame  
                local bus = GetBus()  
                if not bus then  
                    humanoidRootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)  
                    task.wait(0.5)  
                    RemoteCar:FireServer("PickingCar", "SchoolBus")  
                    task.wait(1)  
                    bus = GetBus()  
                end  
                if bus then  
                    local seat = bus:FindFirstChild("Body") and bus.Body:FindFirstChild("VehicleSeat")  
                    if seat and character:FindFirstChildOfClass("Humanoid") and not character.Humanoid.Sit then  
                        repeat  
                            humanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 2, 0)  
                            task.wait()  
                        until character.Humanoid.Sit or not bus.Parent  
                    end  
                end  
                task.spawn(function() TrackPlayer(playerName, callback) end)
            end
            
            local function PerformActionForAllPlayers(playersList)
                if not killBusActive or #playersList == 0 then return end
                local p = table.remove(playersList, 1)
                StartKillBus(p.Name, function()
                    task.wait(0.5)
                    if killBusActive then PerformActionForAllPlayers(playersList) end
                end)
            end
            
            PerformActionForAllPlayers(Players:GetPlayers())
        else
            killBusActive = false
            for _, thread in ipairs(killBusThreads) do
                if thread and coroutine.status(thread) ~= "dead" then
                    coroutine.close(thread)
                end
            end
            killBusThreads = {}
            RemoteCar:FireServer("DeleteAllVehicles")
        end
    end
})

local houseBanActive = false

Troll:AddToggle({
    Name = "House Ban Kill All",
    Callback = function(state)
        if state then
            houseBanActive = true
            local function executeScriptForPlayer(targetPlayer)
                if not houseBanActive then return end
                local Player = Players.LocalPlayer
                local Character = Player.Character
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                local Houses = Workspace:FindFirstChild("001_Lots")
                local Vehicles = Workspace.Vehicles
                if not (Player and Character and Humanoid and RootPart and Vehicles) then return end
                local House = Houses:FindFirstChild(Player.Name.."House")
                if not House then
                    local EHouse
                    for _, Lot in ipairs(Houses:GetChildren()) do
                        if Lot.Name == "For Sale" then
                            for _, num in ipairs(Lot:GetDescendants()) do
                                if num:IsA("NumberValue") and num.Name == "Number" and num.Value < 25 and num.Value > 10 then
                                    EHouse = Lot; break
                                end
                            end
                        end
                    end
                    local BuyDetector = EHouse and EHouse:FindFirstChild("BuyHouse")
                    if BuyDetector and BuyDetector:IsA("BasePart") then
                        RootPart.CFrame = BuyDetector.CFrame + Vector3.new(0, -6, 0)
                        task.wait(0.5)
                        local ClickDetector = BuyDetector:FindFirstChild("ClickDetector")
                        if ClickDetector then fireclickdetector(ClickDetector) end
                    end
                end
                task.wait(0.5)
                local PreHouse = Houses:FindFirstChild(Player.Name .. "House")
                if PreHouse then
                    task.wait(0.5)
                    local Number
                    for _, x in ipairs(PreHouse:GetDescendants()) do
                        if x.Name == "Number" and x:IsA("NumberValue") then Number = x; break end
                    end
                    task.wait(0.5)
                    if Number then RE:FindFirstChild("1Gettin1gHous1e"):FireServer("PickingCustomHouse", "049_House", Number.Value) end
                end
                task.wait(0.5)
                local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
                if not PCar then
                    RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
                    task.wait(0.5)
                    RemoteCar:FireServer("PickingCar", "SchoolBus")
                    task.wait(1)
                    PCar = Vehicles:FindFirstChild(Player.Name.."Car")
                end
                if PCar and not Humanoid.Sit then
                    local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
                    if Seat then
                        repeat
                            task.wait()
                            RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                        until Humanoid.Sit or not houseBanActive
                    end
                end
                local TargetC = targetPlayer.Character
                local TargetH = TargetC and TargetC:FindFirstChildOfClass("Humanoid")
                local TargetRP = TargetC and TargetC:FindFirstChild("HumanoidRootPart")
                if TargetC and TargetH and TargetRP then
                    local Angles = 0
                    if not TargetH.Sit then
                        while not TargetH.Sit and houseBanActive do
                            task.wait()
                            Angles = Angles + 100
                            local function Fling(alvo, pos, angulo) PCar:PivotTo(CFrame.new(alvo.Position) * pos * angulo) end
                            local dir = TargetH.MoveDirection * (TargetRP.Velocity.Magnitude / 1.10)
                            Fling(TargetRP, CFrame.new(0, 1.5, 0) + dir, CFrame.Angles(math.rad(Angles), 0, 0))
                            Fling(TargetRP, CFrame.new(0, -1.5, 0) + dir, CFrame.Angles(math.rad(Angles), 0, 0))
                            Fling(TargetRP, CFrame.new(2.25, 1.5, -2.25) + dir, CFrame.Angles(math.rad(Angles), 0, 0))
                            Fling(TargetRP, CFrame.new(-2.25, -1.5, 2.25) + dir, CFrame.Angles(math.rad(Angles), 0, 0))
                        end
                        task.wait(0.2)
                        local h = Houses:FindFirstChild(Player.Name.."House")
                        if h then PCar:PivotTo(CFrame.new(h.HouseSpawnPosition.Position)) end
                        task.wait(0.2)
                        local pedro = Region3.new(LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(30,30,30), LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(30,30,30))
                        local a = Workspace:FindPartsInRegion3(pedro, LocalPlayer.Character.HumanoidRootPart, math.huge)
                        for _, v in ipairs(a) do
                            if v.Name == "HumanoidRootPart" then
                                local b = Players:FindFirstChild(v.Parent.Name)
                                RE:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer("BanPlayerFromHouse", b, v.Parent)
                            end
                        end
                    end
                end
            end
            RemoteCar:FireServer("DeleteAllVehicles")
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and houseBanActive then
                    executeScriptForPlayer(player)
                    task.wait(2)
                end
            end
        else
            houseBanActive = false
            RemoteCar:FireServer("DeleteAllVehicles")
        end
    end
})

local flingBoatActive = false

Troll:AddToggle({
    Name = "Fling Boat All",
    Callback = function(state)
        if state then
            flingBoatActive = true
            local Character = LocalPlayer.Character
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            local Vehicles = Workspace:FindFirstChild("Vehicles")
            local OldPos = RootPart.CFrame
            local PCar = Vehicles:FindFirstChild(LocalPlayer.Name.."Car")
            if not PCar and RootPart then  
                RootPart.CFrame = CFrame.new(1754, -2, 58)  
                task.wait(0.5)  
                RemoteCar:FireServer("PickingBoat", "MilitaryBoatFree")  
                task.wait(0.5)  
                PCar = Vehicles:FindFirstChild(LocalPlayer.Name.."Car")  
                task.wait(0.5)  
                local Seat = PCar and PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")  
                if Seat then  
                    repeat task.wait(); RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0) until Humanoid.Sit or not flingBoatActive  
                end  
            end  
            task.wait(0.5)  
            PCar = Vehicles:FindFirstChild(LocalPlayer.Name.."Car")  
            if PCar and not Humanoid.Sit then  
                local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")  
                if Seat then repeat task.wait(); RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0) until Humanoid.Sit or not flingBoatActive end  
            end  
            local SpinGyro = Instance.new("BodyGyro")  
            SpinGyro.Parent = PCar.PrimaryPart  
            SpinGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)  
            SpinGyro.P = 1e7  
            SpinGyro.CFrame = PCar.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(90), 0)  
            local function flingPlayer(TargetC, TargetRP, TargetH)
                local Angles = 0  
                local endTime = tick() + 1  
                while tick() < endTime and flingBoatActive do  
                    Angles = Angles + 100  
                    task.wait()  
                    local function kill(alvo, pos, angulo) PCar:PivotTo(CFrame.new(alvo.Position) * pos * angulo) end
                    kill(TargetRP, CFrame.new(0, 3, 0), CFrame.Angles(math.rad(Angles), 0, 0))  
                    kill(TargetRP, CFrame.new(0, -1.5, 2), CFrame.Angles(math.rad(Angles), 0, 0))  
                    kill(TargetRP, CFrame.new(2, 1.5, 2.25), CFrame.Angles(math.rad(50), 0, 0))  
                    kill(TargetRP, CFrame.new(-2.25, -1.5, 2.25), CFrame.Angles(math.rad(30), 0, 0))  
                end  
            end  
            for _, Target in ipairs(Players:GetPlayers()) do  
                if Target ~= LocalPlayer and flingBoatActive then  
                    local TargetC = Target.Character  
                    local TargetH = TargetC and TargetC:FindFirstChildOfClass("Humanoid")  
                    local TargetRP = TargetC and TargetC:FindFirstChild("HumanoidRootPart")  
                    if TargetC and TargetH and TargetRP then flingPlayer(TargetC, TargetRP, TargetH) end  
                end  
            end  
            task.wait(0.5)  
            PCar:PivotTo(CFrame.new(0, 0, 0))  
            task.wait(0.5)  
            Humanoid.Sit = false  
            task.wait(0.5)  
            RootPart.CFrame = OldPos  
            SpinGyro:Destroy()  
        else
            flingBoatActive = false
        end
    end
})

local autoFlingActive = false
local autoFlingThreads = {}

Troll:AddToggle({
    Name = "Auto Fling All",
    Callback = function(state)
        if state then
            autoFlingActive = true
            local function ProcessPlayer(target)
                if not autoFlingActive or not target or not target.Character or target == LocalPlayer then return end
                local flingActive = true
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                if not root or not tRoot then return end
                local char = LocalPlayer.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local original = root.CFrame
                RemoteClearTools:FireServer("ClearAllTools")
                task.wait(0.2)
                RemoteTools:InvokeServer("PickingTools", "Couch")
                task.wait(0.3)
                local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
                if tool then tool.Parent = char end
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.25)
                workspace.FallenPartsDestroyHeight = 0/0
                local bv = Instance.new("BodyVelocity")
                bv.Name, bv.Velocity, bv.MaxForce = "FlingForce", Vector3.new(9e8, 9e8, 9e8), Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = root
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                hum.PlatformStand = false
                cam.CameraSubject = target.Character:FindFirstChild("Head") or tRoot or hum
                task.spawn(function()
                    local angle = 0
                    while flingActive and autoFlingActive and target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") do
                        local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                        if tHum.Sit then break end
                        angle = angle + 50
                        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local pos = hrp.Position + hrp.Velocity / 1.5
                            root.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(angle), 0, 0)
                        end
                        root.Velocity, root.RotVelocity = Vector3.new(9e8, 9e8, 9e8), Vector3.new(9e8, 9e8, 9e8)
                        task.wait()
                    end
                    flingActive = false
                    bv:Destroy()
                    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                    hum.PlatformStand = false
                    root.CFrame = original
                    cam.CameraSubject = hum
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.Velocity, p.RotVelocity = Vector3.zero, Vector3.zero end
                    end
                    hum:UnequipTools()
                    RemoteTools:InvokeServer("PickingTools", "Couch")
                end)
                while flingActive and autoFlingActive do task.wait() end
            end
            for _, player in ipairs(Players:GetPlayers()) do 
                if autoFlingActive then 
                    local thread = task.spawn(function() ProcessPlayer(player) end)
                    table.insert(autoFlingThreads, thread)
                end
            end
        else
            autoFlingActive = false
            for _, thread in ipairs(autoFlingThreads) do
                if thread and coroutine.status(thread) ~= "dead" then
                    coroutine.close(thread)
                end
            end
            autoFlingThreads = {}
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local playerName = LocalPlayer.Name

local toggleEnabled = false
local flingConnections = {}

Troll:AddToggle({
    Name = "Fling Ball All",
    Default = false,
    Callback = function(state)
        toggleEnabled = state

        if state then
            local args = {"PickingTools", "SoccerBall"}
            game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args))

            task.spawn(function()
                while toggleEnabled do
                    task.wait(3)
                    local char = LocalPlayer.Character
                    if not char then continue end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local ball = char:FindFirstChild("SoccerBall")
                    if hrp and ball then
                        ball:WaitForChild("FootballInteraction"):FireServer(hrp.CFrame * CFrame.new(0, -2, -3))
                    end
                end
            end)

            task.spawn(function()
                while toggleEnabled do
                    task.wait(7)
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChild("SoccerBall")
                        if tool then
                            tool.Parent = LocalPlayer.Backpack
                        end
                        task.wait(2)
                        local backpackTool = LocalPlayer.Backpack:FindFirstChild("SoccerBall")
                        if backpackTool and toggleEnabled then
                            backpackTool.Parent = LocalPlayer.Character
                        end
                    end
                end
            end)

            task.spawn(function()
                local equipped = false
                while toggleEnabled do
                    task.wait(1)
                    local myChar = LocalPlayer.Character
                    if myChar then
                        local tool = myChar:FindFirstChild("SoccerBall")
                        local backpackTool = LocalPlayer.Backpack:FindFirstChild("SoccerBall")
                        if not equipped and not myChar:FindFirstChild("SoccerBall") then
                            if backpackTool then
                                backpackTool.Parent = myChar
                                equipped = true
                            end
                        end
                    end
                end
            end)

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    task.spawn(function()
                        local connection
                        connection = RunService.Heartbeat:Connect(function()
                            if not toggleEnabled then
                                if connection then connection:Disconnect() end
                                return
                            end

                            local targetChar = player.Character
                            if not targetChar then return end

                            local soccerBallsContainer = workspace.WorkspaceCom and workspace.WorkspaceCom["001_SoccerBalls"]
                            if not soccerBallsContainer then return end

                            local ball = nil
                            for _, child in ipairs(soccerBallsContainer:GetChildren()) do
                                if child.Name == "Soccer" .. playerName then
                                    ball = child
                                    break
                                end
                            end

                            if not ball then
                                for _, child in ipairs(soccerBallsContainer:GetChildren()) do
                                    if string.find(child.Name, "Soccer") and string.find(child.Name, playerName) then
                                        ball = child
                                        break
                                    end
                                end
                            end

                            if not (targetChar and ball and targetChar:FindFirstChild("HumanoidRootPart")) then return end

                            local hrp = targetChar.HumanoidRootPart

                            ball.AssemblyLinearVelocity = Vector3.zero
                            ball.AssemblyAngularVelocity = Vector3.zero
                            ball.CFrame = hrp.CFrame
                            ball.AssemblyAngularVelocity = Vector3.new(500, 11000, 250)
                            ball.AssemblyLinearVelocity = Vector3.new(0, -90000, 0)
                        end)
                        table.insert(flingConnections, connection)
                    end)
                end
            end

        else
            toggleEnabled = false
            for _, connection in ipairs(flingConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            flingConnections = {}
        end
    end
})


Troll:AddSection("Funções Extras Hxg")

local flingAtivo = false
local fposOriginal = nil

local function startFatalFling()
    coroutine.wrap(function()
        while flingAtivo do
            pcall(function()
                local selected = Target
                if not selected then return end
                local TargetPlayer = Players:FindFirstChild(selected)
                if not TargetPlayer or TargetPlayer == LocalPlayer then return end
                local Character = LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local RootPart = Humanoid and Character:FindFirstChild("HumanoidRootPart")
                local TChar = TargetPlayer.Character
                local THumanoid = TChar and TChar:FindFirstChildOfClass("Humanoid")
                local TRoot = THumanoid and TChar:FindFirstChild("HumanoidRootPart")
                local THead = TChar and TChar:FindFirstChild("Head")
                local Accessory = TChar and TChar:FindFirstChildOfClass("Accessory")
                local Handle = Accessory and Accessory:FindFirstChild("Handle")
                if Character and Humanoid and RootPart and TChar then
                    local function FPos(BasePart, Pos, Ang)
                        if not flingAtivo then return end
                        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                        Character:PivotTo(RootPart.CFrame)
                        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                    end
                    local function SFBasePart(BasePart)
                        local t0 = tick()
                        local Angle = 0
                        repeat
                            if not flingAtivo then break end
                            if BasePart.Velocity.Magnitude < 50 then
                                Angle = 900
                                local vel = BasePart.Velocity.Magnitude / 1.25
                                local dir = THumanoid.MoveDirection
                                FPos(BasePart, CFrame.new(0, 1.5, 0) + dir * vel, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0) + dir * vel, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                            else
                                FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); task.wait()
                            end
                        until BasePart.Velocity.Magnitude > 900 or tick() > t0 + 2
                    end
                    workspace.FallenPartsDestroyHeight = 0/0
                    local BV = Instance.new("BodyVelocity", RootPart)
                    BV.Velocity, BV.MaxForce = Vector3.new(9e8, 9e8, 9e8), Vector3.new(math.huge, math.huge, math.huge)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    if TRoot and THead then
                        SFBasePart((TRoot.Position - THead.Position).Magnitude > 5 and THead or TRoot)
                    elseif TRoot then
                        SFBasePart(TRoot)
                    elseif THead then
                        SFBasePart(THead)
                    elseif Handle then
                        SFBasePart(Handle)
                    end
                    BV:Destroy()
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                end
            end)
            task.wait(1)
        end
    end)()
end

Troll:AddToggle({
    Name = "Fatal Fling (Best)",
    Default = false,
    Callback = function(ativo)
        flingAtivo = ativo
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local selected = Target
        if ativo and selected then
            if hrp then fposOriginal = hrp.CFrame end
            local temCouch = LocalPlayer.Backpack:FindFirstChild("Couch") or (char and char:FindFirstChild("Couch"))
            if not temCouch then
                pcall(function() RemoteTools:InvokeServer("PickingTools", "Couch") end)
            end
            task.spawn(function()
                local maxTries, tries = 30, 0
                repeat
                    task.wait(0.1)
                    tries = tries + 1
                until LocalPlayer.Backpack:FindFirstChild("Couch") or tries >= maxTries
                local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
                if tool and not (char and char:FindFirstChild("Couch")) then
                    tool.Parent = char
                end
            end)
            startFatalFling()
        else
            local tool = char and char:FindFirstChild("Couch")
            if tool then tool.Parent = LocalPlayer.Backpack end
            if hrp and fposOriginal then
                hrp.Velocity, hrp.RotVelocity = Vector3.zero, Vector3.zero
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("BodyVelocity") then v:Destroy() end
                end
                task.wait(0.1)
                hrp.CFrame = fposOriginal
            end
        end
    end
})

local blackHoleActive = false
local DescendantAddedConnection
local followConnection
local Folder = Instance.new("Folder", Workspace)
Folder.Name = "BringPartsFolder"
local Part = Instance.new("Part", Folder)
Part.Anchored, Part.CanCollide, Part.Transparency = true, false, 1
local Attachment1 = Instance.new("Attachment", Part)

local function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
        end
        if v:FindFirstChild("Attachment") then v:FindFirstChild("Attachment"):Destroy() end
        if v:FindFirstChild("AlignPosition") then v:FindFirstChild("AlignPosition"):Destroy() end
        if v:FindFirstChild("Torque") then v:FindFirstChild("Torque"):Destroy() end
        v.CanCollide = false
        local torque = Instance.new("Torque", v)
        torque.Torque = Vector3.new(9e9, 9e9, 9e9)
        local align = Instance.new("AlignPosition", v)
        local att = Instance.new("Attachment", v)
        torque.Attachment0 = att
        align.MaxForce, align.MaxVelocity, align.Responsiveness = 1e12, 1e12, 1e12
        align.Attachment0, align.Attachment1 = att, Attachment1
    end
end

if not Network then
    Network = {
        BaseParts = {},
        Velocity = Vector3.new(1e8, 1e8, 1e8)
    }
    Network.RetainPart = function(targetPart)
        if typeof(targetPart) == "Instance" and targetPart:IsA("BasePart") and targetPart:IsDescendantOf(Workspace) then
            local exists = false
            for _, p in ipairs(Network.BaseParts) do if p == targetPart then exists = true break end end
            if not exists then
                table.insert(Network.BaseParts, targetPart)
                targetPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                targetPart.CanCollide = false
            end
        end
    end
    RunService.Heartbeat:Connect(function()
        pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
        for _, part in ipairs(Network.BaseParts) do
            if part:IsDescendantOf(Workspace) then part.Velocity = Network.Velocity end
        end
    end)
end

local function monitorPlayer(player)
    if followConnection then followConnection:Disconnect(); followConnection = nil end
    followConnection = RunService.RenderStepped:Connect(function()
        if blackHoleActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            Attachment1.WorldCFrame = player.Character.HumanoidRootPart.CFrame
        end
    end)
end

local function updateFollow()
    local player = Players:FindFirstChild(Target)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        monitorPlayer(player)
    else
        if followConnection then followConnection:Disconnect(); followConnection = nil end
    end
end

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        local player = Players:FindFirstChild(Target)
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            blackHoleActive = false
            return
        end
        monitorPlayer(player)
        for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end
        DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then ForcePart(v) end
        end)
    else
        if DescendantAddedConnection then DescendantAddedConnection:Disconnect(); DescendantAddedConnection = nil end
        if followConnection then followConnection:Disconnect(); followConnection = nil end
    end
end

Troll:AddToggle({
    Name = "Black Hole Fling player",
    Default = false,
    Callback = function(state)
        if not Target or Target == "" then
            return
        end
        if blackHoleActive ~= state then toggleBlackHole() end
    end
})

local blackHole999Active = false

local function setUltraCollision(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(1000, 0.3, 0, 1000, 1000)
            part.CanCollide, part.Massless = true, false
        end
    end
end

local function getTruckModel()
    for _, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer and v.Name:lower():find("semi") then 
            return v 
        end
    end
    return nil
end

local function flingTruck(model)
    if not model.PrimaryPart then
        model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
        if not model.PrimaryPart then return end
    end
    setUltraCollision(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then 
            part:SetNetworkOwner(nil)
            part.Anchored = false 
        end
    end
    task.spawn(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        while blackHole999Active and model and model.Parent and hrp do
            local direction = (hrp.Position - model.PrimaryPart.Position).Unit
            model.PrimaryPart.AssemblyLinearVelocity = direction * 1500
            RunService.Heartbeat:Wait()
        end
    end)
end

local bh999Connection = nil
local bh999DescendantConnection = nil

local function toggleBlackHole999()
    blackHole999Active = not blackHole999Active
    if blackHole999Active then
        for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end
        bh999DescendantConnection = Workspace.DescendantAdded:Connect(function(v) 
            if blackHole999Active then ForcePart(v) end 
        end)
        bh999Connection = RunService.RenderStepped:Connect(function()
            if not blackHole999Active then return end
            local truck = getTruckModel()
            if truck then flingTruck(truck) end
            local radius = 7
            local angle = tick() * 10
            local offset = CFrame.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then 
                Attachment1.WorldCFrame = hrp.CFrame * offset 
            end
        end)
    else
        if bh999Connection then 
            bh999Connection:Disconnect() 
            bh999Connection = nil 
        end
        if bh999DescendantConnection then 
            bh999DescendantConnection:Disconnect() 
            bh999DescendantConnection = nil 
        end
    end
end

Troll:AddToggle({
    Name ="Gravity Orbit",
    Default = false,
    Callback = function(state)
        if blackHole999Active ~= state then toggleBlackHole999() end
    end
})

Troll:AddSection("abaixo tem a continuação da aba")


local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService")
}

local LocalPlayer = Services.Players.LocalPlayer

local function IsPlayerSitting(player)
    local success, result = pcall(function()
        if not player or not player.Character then return false end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        if humanoid.Sit then return true end
        if humanoid.SeatPart then return true end
        return false
    end)
    return success and result or false
end

local function DeleteAllVehicles()
    pcall(function()
        Services.ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer("DeleteAllVehicles")
    end)
end

local function ClearAllTools()
    pcall(function()
        Services.ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
    end)
end

local function GetAndEquipCouch()
    local success = pcall(function()
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.Name == "Couch" then
                v.Grip = CFrame.new(0, 2, -2.5)
                v.Parent = LocalPlayer.Character
                return true
            end
        end
        
        Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
        
        local startTime = tick()
        while tick() - startTime < 0.5 do
            for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") and v.Name == "Couch" then
                    v.Grip = CFrame.new(0, 2, -2.5)
                    v.Parent = LocalPlayer.Character
                    return true
                end
            end
            task.wait(0.1)
        end
    end)
    return success or false
end

local lockedTargetFlings = nil
local selectedPlayerNameFlings = nil
local isUpdatingFlings = false

local function getPlayersList()
    local list = {}
    pcall(function()
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(list, player.Name)
            end
        end
    end)
    return list
end

local killDropdown = Troll:AddDropdown({
    Name = "Target",
    Options = getPlayersList(),
    Default = "",
    Callback = function(value)
        pcall(function()
            if isUpdatingFlings then return end
            
            if value and value ~= "" then
                lockedTargetFlings = value
                selectedPlayerNameFlings = value
            else
                lockedTargetFlings = nil
                selectedPlayerNameFlings = nil
            end
        end)
    end
})

Troll:AddButton({
    Name = "Atualizar Lista",
    Callback = function()
        pcall(function()
            if not killDropdown then return end
            
            isUpdatingFlings = true
            
            local newPlayers = getPlayersList()
            pcall(function() killDropdown:Refresh(newPlayers) end)
            pcall(function() killDropdown:Set(newPlayers) end)
            
            lockedTargetFlings = nil
            selectedPlayerNameFlings = nil
            
            isUpdatingFlings = false
        end)
    end
})

task.spawn(function()
    task.wait(1)
    pcall(function()
        local initialPlayers = getPlayersList()
        killDropdown:Refresh(initialPlayers)
        killDropdown:Set(initialPlayers)
    end)
end)

local selectedMethod = "Ball"
Troll:AddDropdown({
    Name = "Method",
    Options = {"Ball", "Couch", "Boat", "PoliceBoat", "Bus", "TowTruck"},
    Default = "Ball",
    Callback = function(value)
        pcall(function()
            selectedMethod = value
        end)
    end
})

local function FlingBall(target)
    pcall(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local ServerBalls = Services.Workspace.WorkspaceCom:WaitForChild("001_SoccerBalls")

        local function GetBall()
            if not backpack:FindFirstChild("SoccerBall") then
                Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "SoccerBall")
            end
            repeat task.wait() until backpack:FindFirstChild("SoccerBall")
            backpack.SoccerBall.Parent = character
            repeat task.wait() until ServerBalls:FindFirstChild("Soccer" .. LocalPlayer.Name)
            character.SoccerBall.Parent = backpack
            return ServerBalls:FindFirstChild("Soccer" .. LocalPlayer.Name)
        end

        local Ball = ServerBalls:FindFirstChild("Soccer" .. LocalPlayer.Name) or GetBall()
        Ball.CanCollide = false
        Ball.Massless = true
        Ball.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0)

        local tchar = target.Character
        if tchar and tchar:FindFirstChild("HumanoidRootPart") and tchar:FindFirstChild("Humanoid") then
            local troot = tchar.HumanoidRootPart
            local thum = tchar.Humanoid

            if Ball:FindFirstChildWhichIsA("BodyVelocity") then
                Ball:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
            end

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(3.15e10, 3.15e10, 3.15e10)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.P = 9e900
            bv.Parent = Ball

            Services.Workspace.CurrentCamera.CameraSubject = thum
            
            repeat
                if troot.Velocity.Magnitude > 0 then
                    local pos_x = troot.Position.X + (troot.Velocity.X / 1.5)
                    local pos_y = troot.Position.Y + (troot.Velocity.Y / 1.5)
                    local pos_z = troot.Position.Z + (troot.Velocity.Z / 1.5)
                    Ball.CFrame = CFrame.new(pos_x, pos_y, pos_z)
                    Ball.Orientation = Ball.Orientation + Vector3.new(45, 60, 30)
                else
                    for _, v in pairs(tchar:GetChildren()) do
                        if v:IsA("BasePart") and v.CanCollide and not v.Anchored then
                            Ball.CFrame = v.CFrame
                            task.wait(1/6000)
                        end
                    end
                end
                task.wait(1/6000)
            until troot.Velocity.Magnitude > 1000 or thum.Health <= 0 or not tchar:IsDescendantOf(Services.Workspace)
            
            Services.Workspace.CurrentCamera.CameraSubject = humanoid
        end
    end)
end

local function SkidFling(TargetPlayer, originalPosition)
    pcall(function()
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = TargetPlayer.Character
        local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter and TCharacter:FindFirstChild("Head")
        
        if not (Character and Humanoid and RootPart and TCharacter and THumanoid and TRootPart) then return end
        
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THead then
            Services.Workspace.CurrentCamera.CameraSubject = THead
        elseif THumanoid then
            Services.Workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(3.15e9, 3.15e10, 3.15e9)
            RootPart.RotVelocity = Vector3.new(3.15e10, 3.15e10, 3.15e10)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 5
            local Time = tick()
            local Angle = 0
            
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0,0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0,0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or not BasePart.Parent or not TargetPlayer.Character or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
        
        local BV = Instance.new("BodyVelocity")
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
        elseif TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        Services.Workspace.CurrentCamera.CameraSubject = Humanoid
        
        task.wait(0.5)
        ClearAllTools()
        
        if originalPosition and RootPart then
            RootPart.CFrame = originalPosition
            RootPart.Velocity = Vector3.new(0, 0, 0)
            RootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        task.wait(0.3)
        ClearAllTools()
        Services.Workspace.FallenPartsDestroyHeight = -500
    end)
end

local function KillCouch(target)
    pcall(function()
        if IsPlayerSitting(target) then
            return
        end
        
        local RootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then return end
        
        local originalPosition = RootPart.CFrame
        Services.Workspace.FallenPartsDestroyHeight = 0/0
        
        if not GetAndEquipCouch() then
            Services.Workspace.FallenPartsDestroyHeight = -500
            return
        end
        
        while not target.Character do task.wait(0.1) end
        SkidFling(target, originalPosition)
    end)
end

local function BringCouch(target)
    pcall(function()
        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local args = { [1] = "ClearAllTools" }
        Services.ReplicatedStorage.RE["1Clea1rTool1s"]:FireServer(unpack(args))
        
        local args = { [1] = "PickingTools", [2] = "Couch" }
        Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(unpack(args))

        local couch = LocalPlayer.Backpack:WaitForChild("Couch", 2)
        if not couch then
            return
        end

        couch.Name = "Chaos.Couch"
        local seat1 = couch:FindFirstChild("Seat1")
        local seat2 = couch:FindFirstChild("Seat2")
        local handle = couch:FindFirstChild("Handle")
        
        if seat1 and seat2 and handle then
            seat1.Disabled = true
            seat2.Disabled = true
            handle.Name = "Handle "
        else
            return
        end
        
        couch.Parent = LocalPlayer.Character

        local tet = Instance.new("BodyVelocity", seat1)
        tet.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        tet.P = 1250
        tet.Velocity = Vector3.new(0, 0, 0)
        tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

        repeat
            for m = 1, 35 do
                local pos = { x = 0, y = 0, z = 0 }
                local tRoot = target.Character and target.Character.HumanoidRootPart
                if not tRoot then break end
                
                pos.x = tRoot.Position.X + (tRoot.Velocity.X / 2)
                pos.y = tRoot.Position.Y + (tRoot.Velocity.Y / 2)
                pos.z = tRoot.Position.Z + (tRoot.Velocity.Z / 2)
                
                seat1.CFrame = CFrame.new(Vector3.new(pos.x, pos.y, pos.z)) * CFrame.new(-2, 2, 0)
                task.wait()
            end
            
            tet:Destroy()
            couch.Parent = LocalPlayer.Backpack
            task.wait()
            couch:FindFirstChild("Handle ").Name = "Handle"
            task.wait(0.2)
            couch.Parent = LocalPlayer.Character
            task.wait()
            couch.Parent = LocalPlayer.Backpack
            couch.Handle.Name = "Handle "
            task.wait(0.2)
            couch.Parent = LocalPlayer.Character
            
            tet = Instance.new("BodyVelocity", seat1)
            tet.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            tet.P = 1250
            tet.Velocity = Vector3.new(0, 0, 0)
            tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
            
        until target.Character and target.Character.Humanoid and target.Character.Humanoid.Sit == true

        task.wait()
        tet:Destroy()
        couch.Parent = LocalPlayer.Backpack
        task.wait()
        couch:FindFirstChild("Handle ").Name = "Handle"
        task.wait(0.3)
        couch.Parent = LocalPlayer.Character
        task.wait(0.3)
        couch.Grip = CFrame.new(Vector3.new(0, 0, 0))
        task.wait(0.3)
        Services.ReplicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    end)
end

local function KillVehicle(target, vehicleType)
    pcall(function()
        if IsPlayerSitting(target) then
            return
        end
        
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if not humanoidRootPart or not humanoid then return end
        
        local originalPosition = humanoidRootPart.CFrame
        local Vehicles = Services.Workspace:FindFirstChild("Vehicles")
        
        if vehicleType == "Boat" then
            humanoidRootPart.CFrame = CFrame.new(1754, -2, 58)
            task.wait(0.5)
            Services.ReplicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer("PickingBoat", "MilitaryBoatFree")
        elseif vehicleType == "PoliceBoat" then
            humanoidRootPart.CFrame = CFrame.new(1754, -2, 58)
            task.wait(0.5)
            local args = {"PickingBoat", "PoliceBoatChangeable"}
            Services.ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
        else
            humanoidRootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            local args = vehicleType == "Bus" and {"PickingCar", "SchoolBus"} or {"PickingCar", "TowTruck"}
            Services.ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
        end
        
        task.wait(1.5)
        
        local vehicle = Vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
        if not vehicle then
            humanoidRootPart.CFrame = originalPosition
            return
        end
        
        local seat
        if vehicleType == "Boat" or vehicleType == "PoliceBoat" then
            seat = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("VehicleSeat")
        else
            seat = vehicle:FindFirstChild("Seats") and vehicle.Seats:FindFirstChild("VehicleSeat")
            if not seat then
                seat = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("VehicleSeat")
            end
        end
        
        if not seat then
            DeleteAllVehicles()
            humanoidRootPart.CFrame = originalPosition
            return
        end
        
        local attempts = 0
        repeat
            humanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.1)
            attempts = attempts + 1
        until humanoid.Sit or attempts > 50 or not vehicle.Parent
        
        if not humanoid.Sit then
            DeleteAllVehicles()
            humanoidRootPart.CFrame = originalPosition
            return
        end
        
        for _, container in pairs({vehicle:FindFirstChild("Body"), vehicle:FindFirstChild("Seats")}) do
            if container then
                for _, v in pairs(container:GetChildren()) do
                    if v:IsA("Seat") or v:IsA("VehicleSeat") then
                        v.CanTouch = false
                    end
                end
            end
        end
        
        Services.Workspace.FallenPartsDestroyHeight = 0/0
        
        local Spin
        if vehicleType == "Boat" or vehicleType == "PoliceBoat" then
            Spin = Instance.new("BodyAngularVelocity")
            Spin.Parent = vehicle.PrimaryPart
            Spin.MaxTorque = Vector3.new(0, math.huge, 0)
            Spin.AngularVelocity = Vector3.new(0, 1000, 0)
        end
        
        local flingActive = true
        local targetInVoid = false
        
        task.spawn(function()
            local startTime = tick()
            local maxTime = (vehicleType == "Boat" or vehicleType == "PoliceBoat") and 15 or 20
            
            while flingActive and vehicle and vehicle.Parent do
                local targetChar = target.Character
                if not targetChar then break end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then break end
                
                if targetRoot.Position.Y < -100 then
                    targetInVoid = true
                    break
                end
                
                if targetHumanoid.Sit then
                    vehicle:SetPrimaryPartCFrame(CFrame.new(9999, -450, 9999))
                    targetInVoid = true
                    task.wait(0.3)
                    break
                end
                
                if vehicleType == "Boat" or vehicleType == "PoliceBoat" then
                    local angle = (tick() - startTime) * 50
                    if targetRoot.Velocity.Magnitude < 50 then
                        local movePatterns = {
                            {pos = CFrame.new(0, 1.5, 0) + targetHumanoid.MoveDirection * targetRoot.Velocity.Magnitude / 2, rot = CFrame.Angles(math.rad(angle), 0, 0)},
                            {pos = CFrame.new(0, -1.5, 0) + targetHumanoid.MoveDirection * targetRoot.Velocity.Magnitude / 2, rot = CFrame.Angles(math.rad(angle), 0, 0)},
                            {pos = CFrame.new(1.5, 1.5, -1.5) + targetHumanoid.MoveDirection * targetRoot.Velocity.Magnitude / 2, rot = CFrame.Angles(math.rad(angle), 0, 0)},
                            {pos = CFrame.new(-1.5, -1.5, 1.5) + targetHumanoid.MoveDirection * targetRoot.Velocity.Magnitude / 2, rot = CFrame.Angles(math.rad(angle), 0, 0)},
                        }
                        for _, pattern in ipairs(movePatterns) do
                            if not flingActive then break end
                            vehicle:SetPrimaryPartCFrame(CFrame.new(targetRoot.Position) * pattern.pos * pattern.rot)
                            task.wait(0.1)
                        end
                    else
                        local speedPatterns = {
                            CFrame.new(0, 1.5, targetHumanoid.WalkSpeed),
                            CFrame.new(0, -1.5, -targetHumanoid.WalkSpeed),
                            CFrame.new(0, 1.5, targetRoot.Velocity.Magnitude / 2),
                            CFrame.new(0, -1.5, -targetRoot.Velocity.Magnitude / 2),
                        }
                        for _, offset in ipairs(speedPatterns) do
                            if not flingActive then break end
                            vehicle:SetPrimaryPartCFrame(CFrame.new(targetRoot.Position) * offset * CFrame.Angles(math.rad(90), 0, 0))
                            task.wait(0.1)
                        end
                    end
                    task.wait(0.05)
                else
                    local time = tick() * 35
                    local lateralOffset = math.sin(time) * 4
                    local frontBackOffset = math.cos(time) * 20
                    vehicle:SetPrimaryPartCFrame(targetRoot.CFrame * CFrame.new(lateralOffset, 0, frontBackOffset))
                end
                
                if tick() - startTime > maxTime then break end
                Services.RunService.RenderStepped:Wait()
            end
            flingActive = false
        end)
        
        while flingActive do task.wait(0.1) end
        
        if Spin then Spin:Destroy() end
        
        task.wait(0.3)
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        
        task.wait(0.7)
        if humanoidRootPart then
            humanoidRootPart.CFrame = originalPosition
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        task.wait(0.5)
        DeleteAllVehicles()
        Services.Workspace.FallenPartsDestroyHeight = -500
    end)
end

local function BringVehicle(target, vehicleType)
    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if not humanoidRootPart or not humanoid then return end
        
        local originalPosition = humanoidRootPart.CFrame
        local Vehicles = Services.Workspace:FindFirstChild("Vehicles")
        
        if vehicleType == "Boat" then
            humanoidRootPart.CFrame = CFrame.new(1754, -2, 58)
            task.wait(0.5)
            Services.ReplicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer("PickingBoat", "MilitaryBoatFree")
        elseif vehicleType == "PoliceBoat" then
            humanoidRootPart.CFrame = CFrame.new(1754, -2, 58)
            task.wait(0.5)
            Services.ReplicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer("PickingBoat", "PoliceBoatChangeable")
        else
            humanoidRootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            local args = vehicleType == "Bus" and {"PickingCar", "SchoolBus"} or {"PickingCar", "TowTruck"}
            Services.ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
        end
        
        task.wait(1.5)
        
        local vehicle = Vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
        if not vehicle then
            humanoidRootPart.CFrame = originalPosition
            return
        end
        
        local seats = {}
        for _, container in pairs({vehicle:FindFirstChild("Body"), vehicle:FindFirstChild("Seats")}) do
            if container then
                for _, v in pairs(container:GetChildren()) do
                    if v:IsA("Seat") or v:IsA("VehicleSeat") then
                        table.insert(seats, v)
                    end
                end
            end
        end
        
        if #seats == 0 then
            DeleteAllVehicles()
            humanoidRootPart.CFrame = originalPosition
            return
        end
        
        local mySeat = seats[1]
        
        local attempts = 0
        repeat
            humanoidRootPart.CFrame = mySeat.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.1)
            attempts = attempts + 1
        until humanoid.Sit or attempts > 50 or not vehicle.Parent
        
        if not humanoid.Sit then
            DeleteAllVehicles()
            humanoidRootPart.CFrame = originalPosition
            return
        end
        
        Services.Workspace.FallenPartsDestroyHeight = 0/0
        
        local flingActive = true
        local brought = false
        
        task.spawn(function()
            local startTime = tick()
            local maxTime = 30
            
            while flingActive and vehicle and vehicle.Parent do
                local targetChar = target.Character
                if not targetChar then break end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then break end
                
                if targetHumanoid.Sit then
                    for i = 1, 30 do
                        vehicle:SetPrimaryPartCFrame(originalPosition * CFrame.new(0, 5, -3))
                        task.wait(0.03)
                        
                        local distance = (targetRoot.Position - originalPosition.Position).Magnitude
                        if distance < 10 then
                            brought = true
                            break
                        end
                    end
                    break
                end
                
                local distance = (targetRoot.Position - originalPosition.Position).Magnitude
                if distance < 10 then
                    brought = true
                    break
                end
                
                for idx, seat in pairs(seats) do
                    local angle = (tick() * 100 + (idx * 60)) % 360
                    local rad = math.rad(angle)
                    local offsetX = math.cos(rad) * 3
                    local offsetZ = math.sin(rad) * 3
                    
                    seat.CFrame = targetRoot.CFrame * CFrame.new(offsetX, 2, offsetZ)
                    seat.Velocity = Vector3.new(0, 50, 0)
                    seat.CanTouch = false
                end
                
                if tick() - startTime > maxTime then 
                    break 
                end
                
                Services.RunService.RenderStepped:Wait()
            end
            flingActive = false
        end)
        
        while flingActive do task.wait(0.1) end
        
        task.wait(0.3)
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        
        task.wait(0.7)
        if humanoidRootPart then
            humanoidRootPart.CFrame = originalPosition
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        task.wait(0.5)
        DeleteAllVehicles()
        Services.Workspace.FallenPartsDestroyHeight = -500
    end)
end

Troll:AddButton({
    Name = "Kill",
    Callback = function()
        pcall(function()
            if not selectedPlayerNameFlings or selectedPlayerNameFlings == "" then
                return
            end
            
            local target = Services.Players:FindFirstChild(selectedPlayerNameFlings)
            if not target then
                return
            end
            
            if IsPlayerSitting(target) then
                return
            end
            
            if selectedMethod == "Ball" then
                FlingBall(target)
            elseif selectedMethod == "Couch" then
                KillCouch(target)
            elseif selectedMethod == "Boat" then
                KillVehicle(target, "Boat")
            elseif selectedMethod == "PoliceBoat" then
                KillVehicle(target, "PoliceBoat")
            elseif selectedMethod == "Bus" then
                KillVehicle(target, "Bus")
            elseif selectedMethod == "TowTruck" then
                KillVehicle(target, "TowTruck")
            end
        end)
    end
})

Troll:AddButton({
    Name = "Bring",
    Callback = function()
        pcall(function()
            if not selectedPlayerNameFlings or selectedPlayerNameFlings == "" then
                return
            end
            
            local target = Services.Players:FindFirstChild(selectedPlayerNameFlings)
            if not target then
                return
            end
            
            if selectedMethod == "Couch" then
                BringCouch(target)
            elseif selectedMethod == "Boat" then
                BringVehicle(target, "Boat")
            elseif selectedMethod == "PoliceBoat" then
                BringVehicle(target, "PoliceBoat")
            elseif selectedMethod == "Bus" then
                BringVehicle(target, "Bus")
            elseif selectedMethod == "TowTruck" then
                BringVehicle(target, "TowTruck")
            end
        end)
    end
})

Troll:AddButton({
    Name = "Go To",
    Callback = function()
        pcall(function()
            if not selectedPlayerNameFlings then return end
            local target = Services.Players:FindFirstChild(selectedPlayerNameFlings)
            if target and target.Character then
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and targetHRP then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end)
    end
})

local viewActive = false
local viewConnection

Troll:AddToggle({
    Name = "View",
    Default = false,
    Callback = function(value)
        pcall(function()
            viewActive = value
            
            if value then
                if not lockedTargetFlings or lockedTargetFlings == "" then
                    viewActive = false
                    return
                end
                
                viewConnection = Services.RunService.Heartbeat:Connect(function()
                    if not viewActive then return end
                    
                    local target = Services.Players:FindFirstChild(lockedTargetFlings)
                    if target and target.Character then
                        local hum = target.Character:FindFirstChild("Humanoid")
                        if hum then
                            Services.Workspace.CurrentCamera.CameraSubject = hum
                        end
                    end
                end)
            else
                if viewConnection then
                    viewConnection:Disconnect()
                    viewConnection = nil
                end
                
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then
                        Services.Workspace.CurrentCamera.CameraSubject = hum
                    end
                end
            end
        end)
    end
})

local autoFlingActive = false

Troll:AddToggle({
    Name = "Auto Fling",
    Default = false,
    Callback = function(value)
        pcall(function()
            autoFlingActive = value
            
            if value then
                if not lockedTargetFlings or lockedTargetFlings == "" then
                    autoFlingActive = false
                    return
                end
                
                local target = Services.Players:FindFirstChild(lockedTargetFlings)
                if not target then
                    autoFlingActive = false
                    return
                end
                
                task.spawn(function()
                    while autoFlingActive do
                        task.wait(1)
                        
                        if not lockedTargetFlings or lockedTargetFlings == "" then
                            autoFlingActive = false
                            break
                        end
                        
                        local currentTarget = Services.Players:FindFirstChild(lockedTargetFlings)
                        
                        if not currentTarget then
                            autoFlingActive = false
                            break
                        end
                        
                        local waitTime = 0
                        while (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and waitTime < 10 do
                            task.wait(0.5)
                            waitTime = waitTime + 0.5
                        end
                        
                        if not LocalPlayer.Character or not currentTarget.Character then
                            task.wait(1)
                        end
                        
                        if not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                            task.wait(1)
                        end
                        
                        if selectedMethod == "Ball" then
                            FlingBall(currentTarget)
                            task.wait(2)
                            
                        elseif selectedMethod == "Couch" then
                            if not IsPlayerSitting(currentTarget) then
                                KillCouch(currentTarget)
                            end
                            task.wait(3)
                            
                        elseif selectedMethod == "Boat" then
                            if not IsPlayerSitting(currentTarget) then
                                KillVehicle(currentTarget, "Boat")
                            end
                            task.wait(5)
                            
                        elseif selectedMethod == "PoliceBoat" then
                            if not IsPlayerSitting(currentTarget) then
                                KillVehicle(currentTarget, "PoliceBoat")
                            end
                            task.wait(5)
                            
                        elseif selectedMethod == "Bus" then
                            if not IsPlayerSitting(currentTarget) then
                                KillVehicle(currentTarget, "Bus")
                            end
                            task.wait(5)
                            
                        elseif selectedMethod == "TowTruck" then
                            if not IsPlayerSitting(currentTarget) then
                                KillVehicle(currentTarget, "TowTruck")
                            end
                            task.wait(5)
                        end
                    end
                end)
            end
        end)
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    pcall(function()
        if autoFlingActive then
            task.wait(2)
        end
    end)
end)



Troll:AddSection({"Novos Métodos"})

local englishFlingActive = false

Troll:AddToggle({
    Name = "Fling Couch Method one",
    Default = false,
    Callback = function(state)
        pcall(function()
            englishFlingActive = state
            if englishFlingActive then
                task.spawn(function()
                    while englishFlingActive do
                        if selectedPlayerNameFlings then
                            local target = Services.Players:FindFirstChild(selectedPlayerNameFlings)
                            if target and target.Character then
                                local char = LocalPlayer.Character
                                local root = char and char:FindFirstChild("HumanoidRootPart")
                                local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                                local hum = char and char:FindFirstChildOfClass("Humanoid")
                                
                                if root and tRoot and tHum and hum then
                                    local args = {[1]="ClearAllTools"}
                                    if Services.ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s") then
                                        Services.ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s"):FireServer(unpack(args))
                                    end
                                    task.wait(0.3)
                                    
                                    if Services.ReplicatedStorage.RE:FindFirstChild("1Too1l") then
                                        Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools","Couch")
                                    end
                                    
                                    local original = root.CFrame
                                    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                    if tool then tool.Parent = char end
                                    
                                    Services.Workspace.FallenPartsDestroyHeight = -math.huge
                                    local bv = Instance.new("BodyVelocity")
                                    bv.Name = "FlingForce"
                                    bv.Velocity = Vector3.new(9e8,9e8,9e8)
                                    bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                                    bv.Parent = root
                                    
                                    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
                                    hum.PlatformStand = false
                                    Services.Workspace.CurrentCamera.CameraSubject = tRoot
                                    
                                    local angle = 0
                                    while englishFlingActive and target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") do
                                        tHum = target.Character:FindFirstChildOfClass("Humanoid")
                                        tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                                        if not tRoot or tHum.Sit or tRoot.Position.Y>=70000 then break end
                                        
                                        local moveDir = tHum.MoveDirection
                                        local offset = Vector3.new(0,0,0)
                                        if moveDir.Magnitude>=0.01 then
                                            local speed = tHum.WalkSpeed
                                            local studs = 13
                                            if speed>16 then studs = studs + math.floor((speed-16)/9)*9 end
                                            offset = moveDir.Unit*studs
                                        end
                                        
                                        angle = 0
                                        root.CFrame = CFrame.new(tRoot.Position+offset+Vector3.new(0,1,0))*CFrame.Angles(math.rad(angle),0,0)
                                        root.Velocity = Vector3.new(9e8,9e8,9e8)
                                        root.RotVelocity = Vector3.new(9e8,9e8,9e8)
                                        task.wait()
                                    end
                                    
                                    bv:Destroy()
                                    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
                                    hum.PlatformStand=false
                                    root.CFrame=original
                                    Services.Workspace.CurrentCamera.CameraSubject=hum
                                    
                                    for _,p in pairs(char:GetDescendants()) do 
                                        if p:IsA("BasePart") then 
                                            p.Velocity=Vector3.zero 
                                            p.RotVelocity=Vector3.zero 
                                        end 
                                    end
                                    
                                    hum:UnequipTools()
                                    if Services.ReplicatedStorage.RE:FindFirstChild("1Too1l") then
                                        Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools","Couch")
                                    end
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end)
    end
})


Troll:AddToggle({
    Name = "Fling Couch Rápido",
    Default = false,
    Callback = function(state)
        pcall(function()
            flingCouchFastActive = state
            task.spawn(function()
                while flingCouchFastActive do
                    if selectedPlayerNameFlings then
                        local target = Services.Players:FindFirstChild(selectedPlayerNameFlings)
                        if target and target.Character then
                            local char = LocalPlayer.Character
                            local root = char and char:FindFirstChild("HumanoidRootPart")
                            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            if root and tRoot and tHum and hum then
                                Services.ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s"):FireServer("ClearAllTools")
                                task.wait(0.1)
                                Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                                task.wait(0.1)
                                local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                if tool then tool.Parent = char end
                                local originalCFrame = root.CFrame
                                local originalAnchored = root.Anchored
                                Services.Workspace.FallenPartsDestroyHeight = -math.huge
                                root.Anchored = false
                                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                                hum.PlatformStand = true
                                hum.Sit = false
                                local bv = Instance.new("BodyVelocity")
                                bv.Name = "FlingForce"
                                bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
                                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bv.Parent = root
                                local bav = Instance.new("BodyAngularVelocity")
                                bav.Name = "FlingSpin"
                                bav.AngularVelocity = Vector3.new(9e8, 9e8, 9e8)
                                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                bav.Parent = root
                                local bg = Instance.new("BodyGyro")
                                bg.Name = "FlingGyro"
                                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                bg.P = 9e8
                                bg.D = 9e8
                                bg.Parent = root
                                Services.Workspace.CurrentCamera.CameraSubject = tRoot
                                local angle = 0
                                local spinAngle = 0
                                while flingCouchFastActive and target and target.Character do
                                    tHum = target.Character:FindFirstChildOfClass("Humanoid")
                                    tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                                    if not tRoot or not tHum or tHum.Sit or tRoot.Position.Y >= 70000 then break end
                                    local moveDir = tHum.MoveDirection
                                    local offset = Vector3.new(0, 0, 0)
                                    if moveDir.Magnitude >= 0.01 then
                                        local speed = tHum.WalkSpeed
                                        local studs = 13
                                        if speed > 16 then studs = studs + math.floor((speed - 16) / 9) * 9 end
                                        offset = moveDir.Unit * studs
                                    end
                                    angle = 90
                                    spinAngle = spinAngle + 30
                                    root.CFrame = CFrame.new(tRoot.Position + offset + Vector3.new(0, 3, 0)) * CFrame.Angles(math.rad(angle), math.rad(spinAngle), math.rad(spinAngle))
                                    root.Velocity = Vector3.new(9e8, 9e8, 9e8)
                                    root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                                    bg.CFrame = CFrame.new(tRoot.Position + offset) * CFrame.Angles(math.rad(angle), math.rad(spinAngle), math.rad(spinAngle))
                                    task.wait(0.01)
                                end
                                if bv then bv:Destroy() end
                                if bav then bav:Destroy() end
                                if bg then bg:Destroy() end
                                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                                hum.PlatformStand = false
                                root.CFrame = originalCFrame
                                root.Anchored = originalAnchored
                                Services.Workspace.CurrentCamera.CameraSubject = hum
                                for _, p in pairs(char:GetDescendants()) do
                                    if p:IsA("BasePart") then
                                        p.Velocity = Vector3.zero
                                        p.RotVelocity = Vector3.zero
                                    end
                                end
                                hum:UnequipTools()
                                Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end)
    end
})

Troll:AddButton({
    Name = "Fling Portas",
    Callback = function()
        pcall(function()
            if not selectedPlayerNameFlings then return end
            local TargetPlayer = Services.Players:FindFirstChild(selectedPlayerNameFlings)
            if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return
            end
            
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local HRP = Character:WaitForChild("HumanoidRootPart")
            
            local BlackHole = Services.Workspace:FindFirstChild("RedzHub_BlackHoleTarget") or Instance.new("Part")
            BlackHole.Size = Vector3.new(100000, 100000, 100000)
            BlackHole.Transparency = 1
            BlackHole.Anchored = true
            BlackHole.CanCollide = false
            BlackHole.Name = "RedzHub_BlackHoleTarget"
            BlackHole.Parent = Services.Workspace
            
            local baseAttachment = BlackHole:FindFirstChild("RedzHub_BlackHoleAttachment") or Instance.new("Attachment")
            baseAttachment.Name = "RedzHub_BlackHoleAttachment"
            baseAttachment.Parent = BlackHole
            
            Services.RunService.Heartbeat:Connect(function()
                pcall(function()
                    if Character and Character:FindFirstChild("HumanoidRootPart") then
                        BlackHole.CFrame = HRP.CFrame
                    end
                end)
            end)
            
            local ConTrolledDoors = {}
            
            local function SetupDoor(part)
                if not part:IsA("BasePart") or part.Anchored or not string.find(part.Name, "Door") then return end
                if part:FindFirstChild("RedzHub_Attached") then return end
                part.CanCollide = false
                for _, obj in ipairs(part:GetChildren()) do
                    if obj:IsA("AlignPosition") or obj:IsA("Torque") or obj:IsA("Attachment") then
                        obj:Destroy()
                    end
                end
                local marker = Instance.new("BoolValue", part)
                marker.Name = "RedzHub_Attached"
                local a1 = Instance.new("Attachment", part)
                local align = Instance.new("AlignPosition", part)
                align.Attachment0 = a1
                align.Attachment1 = baseAttachment
                align.MaxForce = 1e20
                align.MaxVelocity = math.huge
                align.Responsiveness = 99999
                local torque = Instance.new("Torque", part)
                torque.Attachment0 = a1
                torque.RelativeTo = Enum.ActuatorRelativeTo.World
                torque.Torque = Vector3.new(
                    math.random(-10e5, 10e5) * 1000,
                    math.random(-10e5, 10e5) * 10000,
                    math.random(-10e5, 10e5) * 100
                )
                table.insert(ConTrolledDoors, {Part = part, Align = align})
            end
            
            for _, obj in ipairs(Services.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(obj.Name, "Door") then
                    SetupDoor(obj)
                end
            end
            
            Services.Workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("BasePart") and string.find(obj.Name, "Door") then
                    SetupDoor(obj)
                end
            end)
            
            local function FlingPlayer(player)
                local char = player.Character
                if not char then return end
                local targetHRP = char:FindFirstChild("HumanoidRootPart")
                if not targetHRP then return end
                local targetAttachment = targetHRP:FindFirstChild("RedzHub_TargetAttachment")
                if not targetAttachment then
                    targetAttachment = Instance.new("Attachment", targetHRP)
                    targetAttachment.Name = "RedzHub_TargetAttachment"
                end
                for _, data in ipairs(ConTrolledDoors) do
                    if data.Align then
                        data.Align.Attachment1 = targetAttachment
                    end
                end
                local start = tick()
                while tick() - start < 6 do
                    if not Character or not HRP or not player.Character or not targetHRP then break end
                    local distance = (HRP.Position - targetHRP.Position).Magnitude
                    BlackHole.CFrame = targetHRP.CFrame
                    if distance >= 3000 then
                        break
                    end
                    Services.RunService.Heartbeat:Wait()
                end
                for _, data in ipairs(ConTrolledDoors) do
                    if data.Align then
                        data.Align.Attachment1 = baseAttachment
                    end
                end
                BlackHole.CFrame = HRP.CFrame
            end
            
            task.defer(function()
                FlingPlayer(TargetPlayer)
            end)
        end)
    end
})

Troll:AddButton({
    Name = "Fling Ball Car",
    Callback = function()
        pcall(function()
            if not selectedPlayerNameFlings then return end
            local targetPlayer = Services.Players:FindFirstChild(selectedPlayerNameFlings)
            if not targetPlayer then return end
            
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local backpack = LocalPlayer:WaitForChild("Backpack")
            local serverBalls = Services.Workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_SoccerBalls")
            
            if not backpack:FindFirstChild("SoccerBall") and not character:FindFirstChild("SoccerBall") then
                Services.ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "SoccerBall")
            end
            
            repeat task.wait() until backpack:FindFirstChild("SoccerBall") or character:FindFirstChild("SoccerBall")
            
            local ballTool = backpack:FindFirstChild("SoccerBall")
            if ballTool then
                ballTool.Parent = character
            end
            
            repeat task.wait() until serverBalls:FindFirstChild("Soccer"..LocalPlayer.Name)
            local Ball = serverBalls:FindFirstChild("Soccer"..LocalPlayer.Name)
            
            Ball.CanCollide = false
            Ball.Massless = true
            Ball.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0)
            
            local vehicleFolder = Services.Workspace:FindFirstChild("Vehicles")
            if not vehicleFolder then return end
            
            local targetCar = vehicleFolder:FindFirstChild(targetPlayer.Name.."Car")
            if not targetCar then return end
            
            if Ball:FindFirstChildWhichIsA("BodyVelocity") then
                Ball:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
            end
            
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlingPower"
            bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.P = 9e900
            bv.Parent = Ball
            
            task.spawn(function()
                while targetCar and targetCar:IsDescendantOf(Services.Workspace) and targetPlayer.Parent == Services.Players do
                    if targetCar.PrimaryPart then
                        local pos = targetCar.PrimaryPart.Position + Vector3.new(0, math.sin(tick() * 3) * 2, 0)
                        Ball.CFrame = CFrame.new(pos) * CFrame.Angles(0, tick() * 2, 0)
                    else
                        local part = targetCar:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local pos = part.Position + Vector3.new(0, math.sin(tick() * 3) * 2, 0)
                            Ball.CFrame = CFrame.new(pos)
                        end
                    end
                    task.wait(1/60)
                end
            end)
        end)
    end
})

Troll:AddSection("Prison")

local boatSelectedTarget = nil
local boatDropdown

local function getBoatPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

boatDropdown = Troll:AddDropdown({
    Name = "Selecionar Jogador",
    Options = getBoatPlayerList(),
    Default = "",
    Callback = function(value)
        if value and value ~= "" then
            boatSelectedTarget = value
        else
            boatSelectedTarget = nil
        end
    end
})

Troll:AddButton({
    Name = "Atualizar Lista",
    Callback = function()
        if not boatDropdown then return end
        local newPlayers = getBoatPlayerList()
        pcall(function() boatDropdown:Refresh(newPlayers) end)
        pcall(function() boatDropdown:Set(newPlayers) end)
        boatSelectedTarget = nil
    end
})

Troll:AddButton({
    Name = "Boat Jail Players",
    Callback = function()
        task.spawn(function()
            pcall(function()
                if not boatSelectedTarget or boatSelectedTarget == "" then
                    return
                end

                local RS = game:GetService("ReplicatedStorage")

                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local posicaoOriginal = character:GetPivot()

                character:PivotTo(CFrame.new(3194, -3, -2434))
                task.wait(0.3)

                local args = {
                    [1] = "PickingBoat",
                    [2] = "PirateFree",
                    [3] = "Boat"
                }

                RS:WaitForChild("RE", 9e9):WaitForChild("1Ca1r", 9e9):FireServer(unpack(args))

                local alvo = Players:WaitForChild(boatSelectedTarget, 5)
                if not alvo then
                    character:PivotTo(posicaoOriginal)
                    return
                end

                local charAlvo = alvo.Character or alvo.CharacterAdded:Wait()
                local root = charAlvo:WaitForChild("HumanoidRootPart", 5)
                if not root then
                    character:PivotTo(posicaoOriginal)
                    return
                end

                local fim = tick() + 2
                while tick() < fim do
                    local car = workspace.Vehicles:FindFirstChild("TrollLinuxCar")
                    if car and car.Parent then
                        if car:IsA("Model") then
                            car:PivotTo(root.CFrame * CFrame.new(0, 8, 0))
                        elseif car:IsA("BasePart") then
                            car.CFrame = root.CFrame * CFrame.new(0, 8, 0)
                        end
                    end
                    task.wait()
                end

                character:PivotTo(posicaoOriginal)
            end)
        end)
    end
})

do
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    Troll:AddSection({Name = "Kill and Flings - Metodos"})

    local function getPlayerList()
        local playerList = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name ~= LocalPlayer.Name then
                table.insert(playerList, player.Name)
            end
        end
        return playerList
    end

    local selectedPlayerName = nil
    getgenv().Target = nil

    local targetDropdown = Troll:AddDropdown({
        Name = "Selecionar Jogador",
        Options = getPlayerList(),
        Default = "",
        Callback = function(value)
            selectedPlayerName = value
            getgenv().Target = value
        end
    })

    Troll:AddButton({
        Name = "Atualizar Lista de Jogadores",
        Callback = function()
            local tablePlayers = Players:GetPlayers()
            local newPlayers = {}
            if targetDropdown and #tablePlayers > 0 then
                for _, player in ipairs(tablePlayers) do
                    if player.Name ~= LocalPlayer.Name then
                        table.insert(newPlayers, player.Name)
                    end
                end
                targetDropdown:Set(newPlayers)
                if selectedPlayerName and not Players:FindFirstChild(selectedPlayerName) then
                    selectedPlayerName = nil
                    getgenv().Target = nil
                    targetDropdown:SetValue("")
                end
            end
        end
    })

    local function getMyCar()
        local vehicles = Workspace:FindFirstChild("Vehicles")
        if not vehicles then return nil end
        return vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
    end

    local function getTarget()
        local name = getgenv().Target
        if not name then return nil end
        return Players:FindFirstChild(name)
    end

    local function getTargetRoot()
        local target = getTarget()
        if not target or not target.Character then return nil end
        return target.Character:FindFirstChild("HumanoidRootPart")
    end

    local function getTargetTorso()
        local target = getTarget()
        if not target or not target.Character then return nil end
        return target.Character:FindFirstChild("UpperTorso")
            or target.Character:FindFirstChild("Torso")
            or target.Character:FindFirstChild("HumanoidRootPart")
    end

    local function getCarParts(car)
        local parts = {}
        for _, obj in ipairs(car:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(parts, obj)
            end
        end
        return parts
    end

    local function getVehicleSeat(car)
        if not car then return nil end
        local seats = car:FindFirstChild("Seats")
        if seats then
            local seat = seats:FindFirstChild("VehicleSeat")
            if seat then return seat end
        end
        for _, obj in ipairs(car:GetDescendants()) do
            if obj:IsA("VehicleSeat") then
                return obj
            end
        end
        return nil
    end

    local function getCarRoot(car)
        if not car then return nil end
        return car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
    end

    local function deleteAllVehicles()
        local args = { [1] = "DeleteAllVehicles" }
        ReplicatedStorage:WaitForChild("RE", 9e9):WaitForChild("1Ca1r", 9e9):FireServer(unpack(args))
    end

    local Methods = {}
    local ActiveMethods = {}
    local MethodStoppers = {}

    Methods[1] = function()
        local CONFIG = { STICK_DURATION = 5, FORCE_POWER = 99999 }
        local stickConnection, stickActive = nil, false
        local stopFlag = false

        local function stickToTarget()
            if stickActive then return end
            stickActive = true
            local car = getMyCar()
            if not car then stickActive = false return end
            local startTime = tick()
            stickConnection = RunService.Heartbeat:Connect(function()
                if stopFlag then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                if tick() - startTime > CONFIG.STICK_DURATION then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                local targetTorso = getTargetTorso()
                if not targetTorso then return end
                local targetCFrame = targetTorso.CFrame
                for _, part in ipairs(getCarParts(car)) do
                    part.CFrame = targetCFrame
                    part.AssemblyLinearVelocity = Vector3.new(
                        math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER),
                        math.random(0, CONFIG.FORCE_POWER),
                        math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER)
                    )
                    part.AssemblyAngularVelocity = Vector3.new(
                        math.random(-1000, 1000),
                        math.random(-1000, 1000),
                        math.random(-1000, 1000)
                    )
                end
            end)
        end

        local function flingPlayer()
            local targetTorso = getTargetTorso()
            if not targetTorso then return end
            local car = getMyCar()
            if not car then return end
            local targetCFrame = targetTorso.CFrame
            for _, part in ipairs(getCarParts(car)) do
                part.CFrame = targetCFrame
            end
            stickToTarget()
        end

        return function()
            stopFlag = true
            stickActive = false
            if stickConnection then stickConnection:Disconnect() stickConnection = nil end
        end, flingPlayer, stickActive
    end

    Methods[2] = function()
        local CONFIG = { STICK_DURATION = 5, FORCE_POWER = 99999 }
        local stickConnection, stickActive = nil, false
        local stopFlag = false

        local function stickToTarget()
            if stickActive then return end
            stickActive = true
            local car = getMyCar()
            if not car then stickActive = false return end
            local seat = getVehicleSeat(car)
            if not seat then stickActive = false return end
            local startTime = tick()
            stickConnection = RunService.Heartbeat:Connect(function()
                if stopFlag then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                if tick() - startTime > CONFIG.STICK_DURATION then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                local targetRoot = getTargetRoot()
                if not targetRoot then return end
                seat.CFrame = CFrame.new(targetRoot.Position)
                seat.AssemblyLinearVelocity = Vector3.new(
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER),
                    math.random(0, CONFIG.FORCE_POWER),
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER)
                )
                seat.AssemblyAngularVelocity = Vector3.new(
                    math.random(-100, 100),
                    math.random(-100, 100),
                    math.random(-100, 100)
                )
            end)
        end

        local function flingPlayer()
            local targetRoot = getTargetRoot()
            if not targetRoot then return end
            local car = getMyCar()
            if not car then return end
            local seat = getVehicleSeat(car)
            if not seat then return end
            seat.CFrame = CFrame.new(targetRoot.Position)
            stickToTarget()
        end

        return function()
            stopFlag = true
            stickActive = false
            if stickConnection then stickConnection:Disconnect() stickConnection = nil end
        end, flingPlayer, stickActive
    end

    Methods[3] = function()
        local CONFIG = { STICK_DURATION = 5, STICK_DISTANCE = 3, FORCE_POWER = 99999 }
        local stickConnection, stickActive = nil, false
        local stopFlag = false

        local function stickToTarget()
            if stickActive then return end
            stickActive = true
            local car = getMyCar()
            if not car then stickActive = false return end
            local carRoot = getCarRoot(car)
            if not carRoot then stickActive = false return end
            local startTime = tick()
            stickConnection = RunService.Heartbeat:Connect(function()
                if stopFlag then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                if tick() - startTime > CONFIG.STICK_DURATION then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                local targetRoot = getTargetRoot()
                if not targetRoot then return end
                local targetPos = targetRoot.Position
                local lookVector = targetRoot.CFrame.LookVector
                local stickPos = targetPos + Vector3.new(0, CONFIG.STICK_DISTANCE, 0) - lookVector * 2
                carRoot.CFrame = CFrame.new(stickPos, targetPos)
                carRoot.AssemblyLinearVelocity = Vector3.new(
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER),
                    math.random(0, CONFIG.FORCE_POWER),
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER)
                )
                carRoot.AssemblyAngularVelocity = Vector3.new(
                    math.random(-100, 100),
                    math.random(-100, 100),
                    math.random(-100, 100)
                )
            end)
        end

        local function flingPlayer()
            local targetRoot = getTargetRoot()
            if not targetRoot then return end
            local car = getMyCar()
            if not car then return end
            local carRoot = getCarRoot(car)
            if not carRoot then return end
            carRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 5, 0))
            stickToTarget()
        end

        return function()
            stopFlag = true
            stickActive = false
            if stickConnection then stickConnection:Disconnect() stickConnection = nil end
        end, flingPlayer, stickActive
    end

    Methods[4] = function()
        local CONFIG = { STICK_DURATION = 5, FORCE_POWER = 99999 }
        local stickConnection, stickActive = nil, false
        local stopFlag = false

        local function stickToTarget()
            if stickActive then return end
            stickActive = true
            local car = getMyCar()
            if not car then stickActive = false return end
            local seat = getVehicleSeat(car)
            if not seat then stickActive = false return end
            local startTime = tick()
            stickConnection = RunService.Heartbeat:Connect(function()
                if stopFlag then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                if tick() - startTime > CONFIG.STICK_DURATION then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                local targetTorso = getTargetTorso()
                if not targetTorso then return end
                seat.CFrame = targetTorso.CFrame
                seat.AssemblyLinearVelocity = Vector3.new(
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER),
                    math.random(0, CONFIG.FORCE_POWER),
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER)
                )
                seat.AssemblyAngularVelocity = Vector3.new(
                    math.random(-500, 500),
                    math.random(-500, 500),
                    math.random(-500, 500)
                )
            end)
        end

        local function flingPlayer()
            local targetTorso = getTargetTorso()
            if not targetTorso then return end
            local car = getMyCar()
            if not car then return end
            local seat = getVehicleSeat(car)
            if not seat then return end
            seat.CFrame = targetTorso.CFrame
            stickToTarget()
        end

        return function()
            stopFlag = true
            stickActive = false
            if stickConnection then stickConnection:Disconnect() stickConnection = nil end
        end, flingPlayer, stickActive
    end

    Methods[5] = function()
        local CONFIG = { STICK_DURATION = 5, FORCE_POWER = 99999 }
        local stickConnection, stickActive = nil, false
        local stopFlag = false

        local function stickToTarget()
            if stickActive then return end
            stickActive = true
            local car = getMyCar()
            if not car then stickActive = false return end
            local carRoot = getCarRoot(car)
            if not carRoot then stickActive = false return end
            local startTime = tick()
            stickConnection = RunService.Heartbeat:Connect(function()
                if stopFlag then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                if tick() - startTime > CONFIG.STICK_DURATION then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                local targetRoot = getTargetRoot()
                if not targetRoot then return end
                carRoot.CFrame = CFrame.new(targetRoot.Position)
                carRoot.AssemblyLinearVelocity = Vector3.new(
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER),
                    math.random(0, CONFIG.FORCE_POWER),
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER)
                )
                carRoot.AssemblyAngularVelocity = Vector3.new(
                    math.random(-100, 100),
                    math.random(-100, 100),
                    math.random(-100, 100)
                )
            end)
        end

        local function flingPlayer()
            local targetRoot = getTargetRoot()
            if not targetRoot then return end
            local car = getMyCar()
            if not car then return end
            local carRoot = getCarRoot(car)
            if not carRoot then return end
            carRoot.CFrame = CFrame.new(targetRoot.Position)
            stickToTarget()
        end

        return function()
            stopFlag = true
            stickActive = false
            if stickConnection then stickConnection:Disconnect() stickConnection = nil end
        end, flingPlayer, stickActive
    end

    Methods[6] = function()
        local CONFIG = { STICK_DURATION = 5, FORCE_POWER = 99999 }
        local stickConnection, stickActive = nil, false
        local stopFlag = false

        local function stickToTarget()
            if stickActive then return end
            stickActive = true
            local car = getMyCar()
            if not car then stickActive = false return end
            local parts = getCarParts(car)
            if #parts == 0 then stickActive = false return end
            local startTime = tick()
            stickConnection = RunService.Heartbeat:Connect(function()
                if stopFlag then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                if tick() - startTime > CONFIG.STICK_DURATION then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                local targetRoot = getTargetRoot()
                if not targetRoot then return end
                local targetPos = targetRoot.Position
                local offset = Vector3.new(0, 3, 0)
                for i, part in ipairs(parts) do
                    part.CFrame = CFrame.new(targetPos + offset + Vector3.new(0, i * 0.5, 0))
                    part.AssemblyLinearVelocity = Vector3.new(
                        math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER),
                        math.random(0, CONFIG.FORCE_POWER),
                        math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER)
                    )
                end
            end)
        end

        local function flingPlayer()
            local targetRoot = getTargetRoot()
            if not targetRoot then return end
            local car = getMyCar()
            if not car then return end
            local parts = getCarParts(car)
            if #parts == 0 then return end
            local targetPos = targetRoot.Position
            for i, part in ipairs(parts) do
                part.CFrame = CFrame.new(targetPos + Vector3.new(0, 3 + i * 0.5, 0))
            end
            stickToTarget()
        end

        return function()
            stopFlag = true
            stickActive = false
            if stickConnection then stickConnection:Disconnect() stickConnection = nil end
        end, flingPlayer, stickActive
    end

    Methods[7] = function()
        local CONFIG = { STICK_DURATION = 5, FORCE_POWER = 99999 }
        local stickConnection, stickActive = nil, false
        local stopFlag = false

        local function stickToTarget()
            if stickActive then return end
            stickActive = true
            local car = getMyCar()
            if not car then stickActive = false return end
            local seat = getVehicleSeat(car)
            if not seat then stickActive = false return end
            local startTime = tick()
            stickConnection = RunService.Heartbeat:Connect(function()
                if stopFlag then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                if tick() - startTime > CONFIG.STICK_DURATION then
                    stickActive = false
                    if stickConnection then stickConnection:Disconnect() stickConnection = nil end
                    return
                end
                local targetRoot = getTargetRoot()
                if not targetRoot then return end
                local targetCF = CFrame.new(targetRoot.Position) * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))
                seat.CFrame = targetCF
                seat.AssemblyLinearVelocity = Vector3.new(
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER),
                    math.random(0, CONFIG.FORCE_POWER),
                    math.random(-CONFIG.FORCE_POWER, CONFIG.FORCE_POWER)
                )
                seat.AssemblyAngularVelocity = Vector3.new(
                    math.random(-2000, 2000),
                    math.random(-2000, 2000),
                    math.random(-2000, 2000)
                )
            end)
        end

        local function flingPlayer()
            local targetRoot = getTargetRoot()
            if not targetRoot then return end
            local car = getMyCar()
            if not car then return end
            local seat = getVehicleSeat(car)
            if not seat then return end
            seat.CFrame = CFrame.new(targetRoot.Position)
            stickToTarget()
        end

        return function()
            stopFlag = true
            stickActive = false
            if stickConnection then stickConnection:Disconnect() stickConnection = nil end
        end, flingPlayer, stickActive
    end

    for i = 1, 7 do
        local methodIndex = i
        ActiveMethods[methodIndex] = false

        Troll:AddToggle({
            Name = "Metodo " .. methodIndex,
            Default = false,
            Callback = function(state)
                ActiveMethods[methodIndex] = state

                if state then
                    local methodSetup = Methods[methodIndex]
                    if methodSetup then
                        local stopFunc, flingFunc = methodSetup()
                        MethodStoppers[methodIndex] = stopFunc

                        task.spawn(function()
                            local car = getMyCar()
                            if not car then
                                task.wait(0.5)
                                car = getMyCar()
                            end

                            if car then
                                flingFunc()
                            end

                            local nextDeleteTime = tick() + 6

                            while ActiveMethods[methodIndex] do
                                task.wait(0.1)

                                local now = tick()
                                if now >= nextDeleteTime then
                                    deleteAllVehicles()
                                    nextDeleteTime = now + 6
                                end

                                local targetTorso = getTargetTorso()
                                local targetRoot = getTargetRoot()
                                if (targetTorso or targetRoot) and getMyCar() then
                                    flingFunc()
                                end
                            end

                            if MethodStoppers[methodIndex] then
                                MethodStoppers[methodIndex]()
                                MethodStoppers[methodIndex] = nil
                            end
                        end)
                    end
                else
                    if MethodStoppers[methodIndex] then
                        MethodStoppers[methodIndex]()
                        MethodStoppers[methodIndex] = nil
                    end
                end
            end
        })
    end
end

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    Troll:AddSection({Name = "Fling Op Car new - Spawn Car to work"})

    local function getPlayerList()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name ~= LocalPlayer.Name then
                table.insert(list, p.Name)
            end
        end
        return list
    end

    local selectedPlayerName = nil

    local targetDropdown = Troll:AddDropdown({
        Name = "Select Player",
        Options = getPlayerList(),
        Default = "",
        Callback = function(value)
            selectedPlayerName = value
        end
    })

    Troll:AddButton({
        Name = "Refresh Player List",
        Callback = function()
            local newPlayers = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name ~= LocalPlayer.Name then
                    table.insert(newPlayers, p.Name)
                end
            end
            targetDropdown:Set(newPlayers)
            if selectedPlayerName and not Players:FindFirstChild(selectedPlayerName) then
                selectedPlayerName = nil
                targetDropdown:SetValue("")
            end
        end
    })

    local active = false
    local loopThread = nil
    local heartbeatConn = nil
    local bv = nil
    local brv = nil
    local currentCar = nil
    local currentSeat = nil

    local FLING = 1e16

    local function getMyCar()
        local vehicles = Workspace:FindFirstChild("Vehicles")
        if not vehicles then return nil end
        return vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
    end

    local function getSeat(car)
        if not car then return nil end
        local seats = car:FindFirstChild("Seats")
        if seats then
            local s = seats:FindFirstChild("VehicleSeat")
            if s then return s end
        end
        for _, obj in ipairs(car:GetDescendants()) do
            if obj:IsA("VehicleSeat") then return obj end
        end
        return nil
    end

    local function flingCharacter(char)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum.PlatformStand = true end)
        end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                part.CanCollide = false
                part.Velocity = Vector3.new(FLING, FLING, FLING)
                part.RotVelocity = Vector3.new(FLING, FLING, FLING)
            end
        end
    end

    local function cleanup()
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
        if bv then
            pcall(function() bv:Destroy() end)
            bv = nil
        end
        if brv then
            pcall(function() brv:Destroy() end)
            brv = nil
        end
        if currentSeat then
            for _, v in ipairs(currentSeat:GetChildren()) do
                if v:IsA("BodyMover") or v:IsA("RocketPropulsion") then
                    pcall(function() v:Destroy() end)
                end
            end
        end
        currentCar = nil
        currentSeat = nil
    end

    local function attachAndStart()
        local car = getMyCar()
        if not car then return false end

        local seat = getSeat(car)
        if not seat then return false end

        if not car.PrimaryPart then
            car.PrimaryPart = seat
        end

        for _, v in ipairs(seat:GetChildren()) do
            if v:IsA("BodyMover") or v:IsA("RocketPropulsion") then
                pcall(function() v:Destroy() end)
            end
        end

        bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(FLING, FLING, FLING)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = 1e14
        bv.Parent = seat

        brv = Instance.new("BodyAngularVelocity")
        brv.AngularVelocity = Vector3.new(FLING, FLING, FLING)
        brv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        brv.P = 1e14
        brv.Parent = seat

        currentCar = car
        currentSeat = seat

        local time = 0

        heartbeatConn = RunService.Heartbeat:Connect(function(dt)
            if not active then return end
            if not currentCar or not currentCar.Parent then
                cleanup()
                return
            end
            if not currentSeat or not currentSeat.Parent then
                cleanup()
                return
            end
            if not selectedPlayerName then return end

            local target = Players:FindFirstChild(selectedPlayerName)
            if not target or not target.Character then return end

            local char = target.Character
            local torso = char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso")
                or char:FindFirstChild("HumanoidRootPart")
            if not torso then return end

            time = time + dt
            local verticalOffset = math.sin(time * 12) * 2
            local rotationAngle = time * 2160

            pcall(function()
                local targetCFrame = torso.CFrame * CFrame.new(0, verticalOffset, 0) * CFrame.Angles(0, 0, math.rad(rotationAngle))
                currentCar:PivotTo(targetCFrame)
                currentSeat.Velocity = Vector3.new(FLING, FLING, FLING)
                currentSeat.RotVelocity = Vector3.new(FLING, FLING, FLING)
            end)

            if currentSeat.Occupant then
                local occupantChar = currentSeat.Occupant.Parent
                flingCharacter(occupantChar)
            end

            flingCharacter(char)
        end)

        return true
    end

    local function start()
        if active then return end
        active = true

        loopThread = task.spawn(function()
            while active do
                if not currentCar or not currentCar.Parent or not currentSeat or not currentSeat.Parent then
                    cleanup()
                    attachAndStart()
                end
                task.wait(0.2)
            end
        end)
    end

    local function stop()
        active = false
        if loopThread then
            task.cancel(loopThread)
            loopThread = nil
        end
        cleanup()
    end

    Troll:AddToggle({
        Name = "Fling Op Car new",
        Default = false,
        Callback = function(state)
            if state then
                start()
            else
                stop()
            end
        end
    })
end

Troll:AddSection("Props Options")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local selectedPlayerName = nil
local propQuantity = 15

local KillBallPropActive = false
local BringActive = false
local KillSingleActive = false
local KillAllActive = false
local BringAllActive = false

local function ClearAllProps()
    local args = {"ClearAllProps"}
    pcall(function()
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer(unpack(args))
    end)
end

local function getMyProps()
    local PropFolder = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
    if not PropFolder then return {} end
    
    local props = {}
    for _, child in ipairs(PropFolder:GetChildren()) do
        if child.Name:find(LocalPlayer.Name, 1, true) and child:FindFirstChild("SetCurrentCFrame") then
            table.insert(props, child)
        end
    end
    return props
end

local function hasMyProps()
    return #getMyProps() > 0
end

local function getPositionInFront()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local footPosition = rootPart.Position - Vector3.new(0, rootPart.Size.Y / 2 + 3, 0)
    local frontDirection = rootPart.CFrame.LookVector
    return footPosition + (frontDirection * 6)
end

local function getTargetPart()
    local model = workspace:WaitForChild("Model", 9e9)
    if model then
        local children = model:GetChildren()
        if children[74] then
            local subChildren = children[74]:GetChildren()
            if subChildren[21] then
                return subChildren[21]
            end
        end
    end
    return nil
end

local function anyToggleActive()
    return KillBallPropActive or BringActive or KillSingleActive or KillAllActive or BringAllActive
end

local function setupPropsWithQuantity(quantity, useLights, callback)
    task.spawn(function()
        local RE = ReplicatedStorage:WaitForChild("RE", 9e9)

        pcall(function()
            RE:WaitForChild("1Too1l", 9e9):InvokeServer("PickingTools", "PropMaker")
        end)

        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local backpack = LocalPlayer:WaitForChild("Backpack")

        local tool = backpack:WaitForChild("PropMaker", 10)
        if tool then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
        end

        task.wait(0.5)

        if useLights then
            pcall(function()
                RE:WaitForChild("1Clea1rTool1s", 9e9):FireServer("RequestingPropName", "LightsSpotLightWhite", "Lights")
            end)
        else
            local args = {"RequestingPropName", "FurnitureBleachers", "Furniture"}
            pcall(function()
                RE:WaitForChild("1Clea1rTool1s", 9e9):FireServer(unpack(args))
            end)
        end

        task.wait(0.5)

        local propMaker
        local startWait = tick()
        while tick() - startWait < 5 do
            local playerFolder = workspace:FindFirstChild(LocalPlayer.Name)
            if playerFolder then
                local pm = playerFolder:FindFirstChild("PropMaker")
                if pm then
                    local tpm = pm:FindFirstChild("Tool_PropMake")
                    if tpm then
                        propMaker = tpm
                        break
                    end
                end
            end
            task.wait(0.1)
        end

        if not propMaker then
            callback()
            return
        end

        for i = 1, quantity do
            if not anyToggleActive() then
                break
            end

            local targetPart = getTargetPart()
            if targetPart then
                local args = {
                    [1] = targetPart;
                    [2] = getPositionInFront()
                }

                pcall(function()
                    propMaker:FireServer(unpack(args))
                end)
            else
                character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")
                local spawnPosition = root.Position - root.CFrame.LookVector * 7

                local baseplate = workspace
                    :WaitForChild("__DEV", 9e9)
                    :WaitForChild("SwappableWorld", 9e9)
                    :WaitForChild("SideArea", 9e9)
                    :WaitForChild("ToBeSwapped", 9e9)
                    :WaitForChild("Baseplate", 9e9)

                local spawnArgs = {
                    [1] = baseplate;
                    [2] = Vector3.new(
                        spawnPosition.X,
                        baseplate.Position.Y + baseplate.Size.Y / 2,
                        spawnPosition.Z
                    );
                }

                pcall(function()
                    propMaker:FireServer(unpack(spawnArgs))
                end)
            end

            task.wait(1)
        end

        callback()
    end)
end

local function getPlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name ~= LocalPlayer.Name then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

Troll:AddTextBox({
    Name = "Quantidade de Props",
    PlaceholderText = "ex: 15",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 and num <= 500 then
            propQuantity = math.floor(num)
            getgenv().PropQuantity = propQuantity
        end
    end
})

local killDropdown = Troll:AddDropdown({
    Name = "Selecionar Jogador",
    Options = getPlayerList(),
    Default = "",
    Callback = function(value)
        selectedPlayerName = value
        getgenv().Target = value
    end
})

Troll:AddButton({
    Name = "Atualizar Lista de Jogadores",
    Callback = function()
        local tablePlayers = Players:GetPlayers()
        local newPlayers = {}
        if killDropdown and #tablePlayers > 0 then
            for _, player in ipairs(tablePlayers) do
                if player.Name ~= LocalPlayer.Name then
                    table.insert(newPlayers, player.Name)
                end
            end
            killDropdown:Set(newPlayers)
            if selectedPlayerName and not Players:FindFirstChild(selectedPlayerName) then
                selectedPlayerName = nil
                getgenv().Target = nil
                killDropdown:SetValue("")
            end
        end
    end
})

local ReferenciasKillBall = {
    {
        Pos = Vector3.new(68.200333, 4.374997, -84.972992),
        Rot = Vector3.new(-3.451946, 168.328072, -177.030580)
    },
    {
        Pos = Vector3.new(66.038391, 5.974998, -80.990944),
        Rot = Vector3.new(80.810441, -9.885520, -179.993175)
    },
    {
        Pos = Vector3.new(68.072609, 11.974998, -84.903893),
        Rot = Vector3.new(-3.451946, 168.328072, -177.030580)
    },
    {
        Pos = Vector3.new(68.636192, 5.974998, -90.477768),
        Rot = Vector3.new(61.620888, -9.887068, 0.002076)
    }
}

local function CriarCFrameKillBall(d)
    return CFrame.new(d.Pos) * CFrame.Angles(
        math.rad(d.Rot.X),
        math.rad(d.Rot.Y),
        math.rad(d.Rot.Z)
    )
end

local ReferenciasLocalKillBall = {}
do
    local BaseRef = CriarCFrameKillBall(ReferenciasKillBall[1])
    for i, d in ipairs(ReferenciasKillBall) do
        ReferenciasLocalKillBall[i] = BaseRef:ToObjectSpace(CriarCFrameKillBall(d))
    end
end

local EsferaKillBall = {
    Vector3.new(0, 0, -1),
    Vector3.new(0.707, 0.707, -0.707),
    Vector3.new(-0.707, 0.707, -0.707),
    Vector3.new(0.707, -0.707, -0.707),
    Vector3.new(-0.707, -0.707, -0.707),
    Vector3.new(1, 0, 0),
    Vector3.new(-1, 0, 0),
    Vector3.new(0, 1, 0),
    Vector3.new(0, -1, 0),
    Vector3.new(0.707, 0.707, 0.707),
    Vector3.new(-0.707, 0.707, 0.707),
    Vector3.new(0.707, -0.707, 0.707),
    Vector3.new(-0.707, -0.707, 0.707),
    Vector3.new(0.382, 0, 0.924),
    Vector3.new(-0.382, 0, 0.924)
}

local function KillBallPertenceAoPlayer(prop)
    local atributos = {
        prop:GetAttribute("Player"),
        prop:GetAttribute("Owner"),
        prop:GetAttribute("OwnerUserId")
    }

    for _, valor in ipairs(atributos) do
        if valor ~= nil then
            if tostring(valor):lower() == LocalPlayer.Name:lower() then
                return true
            end
            if tonumber(valor) == LocalPlayer.UserId then
                return true
            end
        end
    end

    return false
end

local function KillBallPegarParte(obj)
    if obj:IsA("BasePart") then
        return obj
    end
    if obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart
        end
        return obj:FindFirstChildWhichIsA("BasePart", true)
    end
end

local function KillBallPegarRemote(obj)
    local remote = obj:FindFirstChild("SetCurrentCFrame", true)
    if remote and remote:IsA("RemoteFunction") then
        return remote
    end
end

local KillBallPropThread = nil
local KillBallPropToggle
local KillBallSittingState = false

KillBallPropToggle = Troll:AddToggle({
    Name = "KillBall Prop",
    Default = false,
    Callback = function(state)
        KillBallPropActive = state

        if not state then
            if KillBallPropThread then
                pcall(coroutine.close, KillBallPropThread)
                KillBallPropThread = nil
            end
            KillBallSittingState = false
            ClearAllProps()
            return
        end

        if not selectedPlayerName or not Players:FindFirstChild(selectedPlayerName) then
            KillBallPropToggle:Set(false)
            return
        end

        setupPropsWithQuantity(propQuantity, false, function()
            if not KillBallPropActive then return end

            local PropFolder = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
            if not PropFolder then
                KillBallPropToggle:Set(false)
                return
            end

            local target = Players:FindFirstChild(selectedPlayerName)
            if not target then
                KillBallPropToggle:Set(false)
                return
            end

            local Props = {}

            for _, obj in ipairs(PropFolder:GetDescendants()) do
                if KillBallPertenceAoPlayer(obj) then
                    local parte = KillBallPegarParte(obj)
                    local remote = KillBallPegarRemote(obj)
                    if parte and remote then
                        table.insert(Props, {
                            Object = obj,
                            Part = parte,
                            Remote = remote
                        })
                    end
                end
            end

            table.sort(Props, function(a, b)
                return a.Part.Position.Y < b.Part.Position.Y
            end)

            while #Props > propQuantity do
                table.remove(Props)
            end

            if #Props == 0 then
                KillBallPropToggle:Set(false)
                return
            end

            KillBallPropThread = task.spawn(function()
                local INTERVALO = 0.1
                local RAIO = 3.2
                local VELOCIDADE_ROTACAO = 1.8
                local VELOCIDADE_OSCILACAO = 2

                local acumulado = 0
                local angulo = 0

                while KillBallPropActive do
                    if not Players:FindFirstChild(selectedPlayerName) then
                        break
                    end

                    local dt = RunService.Heartbeat:Wait()
                    acumulado = acumulado + dt

                    if acumulado < INTERVALO then
                        continue
                    end

                    acumulado = 0
                    angulo = angulo + VELOCIDADE_ROTACAO * INTERVALO

                    local currentTarget = Players:FindFirstChild(selectedPlayerName)
                    if not currentTarget or not currentTarget.Character then
                        continue
                    end

                    local hum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
                    local root = currentTarget.Character:FindFirstChild("HumanoidRootPart")

                    if not hum or not root or hum.Health <= 0 then
                        continue
                    end

                    if hum.Sit then
                        local voidCF = CFrame.new(0, -9999, 0)
                        for _, prop in ipairs(Props) do
                            if prop.Object.Parent then
                                task.spawn(function()
                                    pcall(function()
                                        prop.Remote:InvokeServer(voidCF)
                                    end)
                                end)
                            end
                        end
                        KillBallSittingState = true
                        continue
                    end

                    if KillBallSittingState then
                        KillBallSittingState = false
                    end

                    local tempo = os.clock()
                    local oscilacao = math.sin(tempo * VELOCIDADE_OSCILACAO) * 0.35
                    local centro = root.Position + Vector3.new(0, oscilacao, 0)

                    local base = CFrame.new(centro) * CFrame.Angles(0, angulo, 0)

                    for i, prop in ipairs(Props) do
                        if not prop.Object.Parent then
                            continue
                        end

                        local direcao = EsferaKillBall[((i - 1) % #EsferaKillBall) + 1]

                        local camada = 1
                        if i <= 4 then
                            camada = 0.82
                        elseif i >= 12 then
                            camada = 1.08
                        end

                        local posicao = direcao.Unit * (RAIO * camada)

                        local movimento = CFrame.new(posicao) * CFrame.Angles(
                            math.sin(tempo * 2 + i) * 0.25,
                            tempo * 1.5 + i * 0.4,
                            math.cos(tempo * 2.3 + i) * 0.25
                        )

                        local cf = base
                            * CFrame.new(posicao)
                            * CFrame.Angles(movimento:ToEulerAnglesXYZ())
                            * CFrame.Angles(0, math.rad(ReferenciasKillBall[((i - 1) % 4) + 1].Rot.Y), 0)

                        task.spawn(function()
                            pcall(function()
                                prop.Remote:InvokeServer(cf)
                            end)
                        end)
                    end
                end

                KillBallPropThread = nil
                if KillBallPropActive then
                    KillBallPropToggle:Set(false)
                end
                KillBallPropActive = false
                KillBallSittingState = false
            end)
        end)
    end
})

local BringThread = nil
local BringToggle
local BringSittingState = false

BringToggle = Troll:AddToggle({
    Name = "Bring com Prop",
    Default = false,
    Callback = function(state)
        BringActive = state
        
        if not state then
            if BringThread then
                pcall(coroutine.close, BringThread)
                BringThread = nil
            end
            BringSittingState = false
            ClearAllProps()
            return
        end

        if not selectedPlayerName or not Players:FindFirstChild(selectedPlayerName) then
            BringToggle:Set(false)
            return
        end

        setupPropsWithQuantity(propQuantity, false, function()
            if not BringActive then return end

            local PropFolder = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
            if not PropFolder then
                BringToggle:Set(false)
                return
            end

            local target = Players:FindFirstChild(selectedPlayerName)
            if not target then
                BringToggle:Set(false)
                return
            end

            local Props = {}
            for _, child in ipairs(PropFolder:GetChildren()) do
                if child.Name:find(LocalPlayer.Name, 1, true) and child:FindFirstChild("SetCurrentCFrame") then
                    table.insert(Props, {
                        Object = child,
                        Remote = child:FindFirstChild("SetCurrentCFrame")
                    })
                end
            end

            if #Props == 0 then
                BringToggle:Set(false)
                return
            end

            BringThread = task.spawn(function()
                while BringActive do
                    if not Players:FindFirstChild(selectedPlayerName) then
                        break
                    end

                    local target = Players:FindFirstChild(selectedPlayerName)
                    if target and target.Character then
                        local myChar = LocalPlayer.Character
                        if myChar then
                            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                            local myHRP = myChar:FindFirstChild("HumanoidRootPart")

                            if hrp and humanoid and myHRP and humanoid.Health > 0 then
                                if humanoid.Sit then
                                    if not BringSittingState then
                                        BringSittingState = true
                                        for _, prop in ipairs(Props) do
                                            task.spawn(function()
                                                pcall(function()
                                                    prop.Remote:InvokeServer(myHRP.CFrame * CFrame.new(0, 0, -2))
                                                end)
                                            end)
                                        end
                                    end
                                else
                                    if BringSittingState then
                                        BringSittingState = false
                                        for _, prop in ipairs(Props) do
                                            task.spawn(function()
                                                pcall(function()
                                                    prop.Remote:InvokeServer(hrp.CFrame * CFrame.new(2, 0, 0))
                                                end)
                                            end)
                                        end
                                    end
                                    
                                    local isMoving = humanoid.MoveDirection.Magnitude > 0.1
                                    local offset = isMoving and 6 or 0.1
                                    local followCF = hrp.CFrame * CFrame.new(0, -1, -offset)
                                    
                                    for _, prop in ipairs(Props) do
                                        task.spawn(function()
                                            pcall(function()
                                                prop.Remote:InvokeServer(followCF)
                                            end)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
                BringThread = nil
                if BringActive then
                    BringToggle:Set(false)
                end
                BringActive = false
                BringSittingState = false
            end)
        end)
    end
})

local KillSingleThread = nil
local KillSingleToggle
local KillSingleSittingState = false

KillSingleToggle = Troll:AddToggle({
    Name = "Kill player Prop",
    Default = false,
    Callback = function(state)
        KillSingleActive = state
        
        if not state then
            if KillSingleThread then
                pcall(coroutine.close, KillSingleThread)
                KillSingleThread = nil
            end
            KillSingleSittingState = false
            ClearAllProps()
            return
        end

        if not selectedPlayerName or not Players:FindFirstChild(selectedPlayerName) then
            KillSingleToggle:Set(false)
            return
        end

        setupPropsWithQuantity(propQuantity, false, function()
            if not KillSingleActive then return end

            local PropFolder = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
            if not PropFolder then
                KillSingleToggle:Set(false)
                return
            end

            local target = Players:FindFirstChild(selectedPlayerName)
            if not target then
                KillSingleToggle:Set(false)
                return
            end

            local Props = {}
            for _, child in ipairs(PropFolder:GetChildren()) do
                if child.Name:find(LocalPlayer.Name, 1, true) and child:FindFirstChild("SetCurrentCFrame") then
                    table.insert(Props, {
                        Object = child,
                        Remote = child:FindFirstChild("SetCurrentCFrame")
                    })
                end
            end

            if #Props == 0 then
                KillSingleToggle:Set(false)
                return
            end

            KillSingleThread = task.spawn(function()
                while KillSingleActive do
                    if not Players:FindFirstChild(selectedPlayerName) then
                        break
                    end

                    local target = Players:FindFirstChild(selectedPlayerName)
                    if target and target.Character then
                        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                        local hrp = target.Character:FindFirstChild("HumanoidRootPart")

                        if hrp and humanoid and humanoid.Health > 0 then
                            if humanoid.Sit then
                                KillSingleSittingState = true
                                for _, prop in ipairs(Props) do
                                    task.spawn(function()
                                        pcall(function()
                                            prop.Remote:InvokeServer(CFrame.new(0, -9999, 0))
                                        end)
                                    end)
                                end
                            else
                                if KillSingleSittingState then
                                    KillSingleSittingState = false
                                    for _, prop in ipairs(Props) do
                                        task.spawn(function()
                                            pcall(function()
                                                prop.Remote:InvokeServer(hrp.CFrame * CFrame.new(2, 0, 0))
                                            end)
                                        end)
                                    end
                                end
                                
                                local isMoving = humanoid.MoveDirection.Magnitude > 0.1
                                local offset = isMoving and 6 or 0.1
                                local followCF = hrp.CFrame * CFrame.new(0, -1, -offset)
                                
                                for _, prop in ipairs(Props) do
                                    task.spawn(function()
                                        pcall(function()
                                            prop.Remote:InvokeServer(followCF)
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
                KillSingleThread = nil
                if KillSingleActive then
                    KillSingleToggle:Set(false)
                end
                KillSingleActive = false
                KillSingleSittingState = false
            end)
        end)
    end
})

local KillAllThread = nil
local KillAllToggle = nil
local KillAllPlayerThreads = {}
local KillAllSittingStates = {}

local function KillAllStopTrackingPlayer(player)
    if KillAllPlayerThreads[player] then
        local thread = KillAllPlayerThreads[player]
        KillAllPlayerThreads[player] = nil
        pcall(coroutine.close, thread)
    end
    KillAllSittingStates[player] = nil
end

local function KillAllStartTrackingPlayer(player, Remote)
    if KillAllPlayerThreads[player] then
        KillAllStopTrackingPlayer(player)
    end

    KillAllSittingStates[player] = false

    KillAllPlayerThreads[player] = task.spawn(function()
        while KillAllActive do
            if not Players:FindFirstChild(player.Name) then
                break
            end

            if not player.Character or not player.Character.Parent then
                break
            end

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")

            if not hrp or not humanoid or humanoid.Health <= 0 then
                break
            end

            if humanoid.Sit then
                KillAllSittingStates[player] = true
                task.spawn(function()
                    pcall(function()
                        Remote:InvokeServer(CFrame.new(0, -9999, 0))
                    end)
                end)
            else
                if KillAllSittingStates[player] then
                    KillAllSittingStates[player] = false
                    Remote:InvokeServer(hrp.CFrame * CFrame.new(2, 0, 0))
                end
                
                local isMoving = humanoid.MoveDirection.Magnitude > 0.1
                local offset = isMoving and 6 or 0.1
                local followCF = hrp.CFrame * CFrame.new(0, -1, -offset)
                
                Remote:InvokeServer(followCF)
            end

            task.wait(0.05)
        end

        if KillAllActive then
            KillAllStopTrackingPlayer(player)
        end
    end)
end

local function KillAllRedistributeProps()
    local toStop = {}
    for player, _ in pairs(KillAllPlayerThreads) do
        if not Players:FindFirstChild(player.Name) 
            or not player.Character 
            or not player.Character:FindFirstChild("Humanoid")
            or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            table.insert(toStop, player)
        end
    end
    for _, player in ipairs(toStop) do
        KillAllStopTrackingPlayer(player)
    end

    local myProps = getMyProps()
    if #myProps == 0 then return end

    local playersToTrack = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer 
            and player.Character 
            and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(playersToTrack, player)
            end
        end
    end

    local propIndex = 1
    for _, player in ipairs(playersToTrack) do
        if propIndex > #myProps then break end

        if not KillAllPlayerThreads[player] then
            local prop = myProps[propIndex]
            local Remote = prop:FindFirstChild("SetCurrentCFrame")
            if Remote then
                KillAllStartTrackingPlayer(player, Remote)
                propIndex = propIndex + 1
            end
        else
            propIndex = propIndex + 1
        end
    end
end

KillAllToggle = Troll:AddToggle({
    Name = "Kill All Players Prop",
    Default = false,
    Callback = function(state)
        KillAllActive = state

        if not state then
            local toStop = {}
            for player, _ in pairs(KillAllPlayerThreads) do
                table.insert(toStop, player)
            end
            for _, player in ipairs(toStop) do
                KillAllStopTrackingPlayer(player)
            end

            if KillAllThread then
                local thread = KillAllThread
                KillAllThread = nil
                pcall(coroutine.close, thread)
            end
            ClearAllProps()
            return
        end

        setupPropsWithQuantity(propQuantity, false, function()
            if not KillAllActive then return end

            local myProps = getMyProps()
            if #myProps == 0 then
                KillAllToggle:Set(false)
                return
            end

            KillAllThread = task.spawn(function()
                while KillAllActive do
                    KillAllRedistributeProps()
                    task.wait(0.5)
                end
                KillAllThread = nil
            end)
        end)
    end
})

local BringAllThread = nil
local BringAllToggle = nil
local BringActiveThreads = {}
local BringSittingStates = {}
local BringPropAssignment = {}

local function getMyBringProps()
    local PropFolder = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
    if not PropFolder then return {} end
    
    local props = {}
    for _, child in ipairs(PropFolder:GetChildren()) do
        if child.Name:find(LocalPlayer.Name, 1, true) and child:FindFirstChild("SetCurrentCFrame") then
            table.insert(props, child)
        end
    end
    return props
end

local function BringStopTrackingPlayer(player)
    if BringActiveThreads[player] then
        local thread = BringActiveThreads[player]
        BringActiveThreads[player] = nil
        pcall(coroutine.close, thread)
    end
    BringSittingStates[player] = nil
    BringPropAssignment[player] = nil
end

local function BringStartTrackingPlayer(player, Remote)
    if BringActiveThreads[player] then
        BringStopTrackingPlayer(player)
    end

    BringSittingStates[player] = false

    BringActiveThreads[player] = task.spawn(function()
        while BringAllActive do
            if not Players:FindFirstChild(player.Name) then
                break
            end

            if not player.Character or not player.Character.Parent then
                break
            end

            local myChar = LocalPlayer.Character
            if not myChar then break end

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = myChar:FindFirstChild("HumanoidRootPart")

            if not hrp or not humanoid or not myHRP or humanoid.Health <= 0 then
                break
            end

            if humanoid.Sit then
                BringSittingStates[player] = true
                task.spawn(function()
                    pcall(function()
                        Remote:InvokeServer(myHRP.CFrame * CFrame.new(0, 0, -2))
                    end)
                end)
            else
                if BringSittingStates[player] then
                    BringSittingStates[player] = false
                    Remote:InvokeServer(hrp.CFrame * CFrame.new(2, 0, 0))
                end

                local isMobileMoving = humanoid.MoveDirection.Magnitude > 0.1
                local offset = isMobileMoving and 6 or 0.1
                local followCF = hrp.CFrame * CFrame.new(0, -1, -offset)

                Remote:InvokeServer(followCF)
            end

            task.wait(0.005)
        end

        if BringAllActive then
            BringStopTrackingPlayer(player)
        end
    end)
end

local function BringRedistributeProps()
    local toStop = {}
    for player, _ in pairs(BringActiveThreads) do
        if not Players:FindFirstChild(player.Name) or not player.Character then
            table.insert(toStop, player)
        end
    end
    for _, player in ipairs(toStop) do
        BringStopTrackingPlayer(player)
    end

    local myProps = getMyBringProps()
    if #myProps == 0 then return end

    local playersToTrack = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(playersToTrack, player)
            end
        end
    end

    local propIndex = 1
    for _, player in ipairs(playersToTrack) do
        if propIndex > #myProps then break end

        if not BringActiveThreads[player] then
            local prop = myProps[propIndex]
            local Remote = prop:FindFirstChild("SetCurrentCFrame")
            if Remote then
                BringPropAssignment[player] = prop
                BringStartTrackingPlayer(player, Remote)
                propIndex = propIndex + 1
            end
        else
            propIndex = propIndex + 1
        end
    end

    local currentPlayers = {}
    for player, _ in pairs(BringActiveThreads) do
        table.insert(currentPlayers, player)
    end
    for _, player in ipairs(currentPlayers) do
        local stillValid = false
        for _, target in ipairs(playersToTrack) do
            if target == player then
                stillValid = true
                break
            end
        end
        if not stillValid then
            BringStopTrackingPlayer(player)
        end
    end
end

BringAllToggle = Troll:AddToggle({
    Name = "Bring All Players Props",
    Default = false,
    Callback = function(state)
        BringAllActive = state

        if not state then
            local toStop = {}
            for player, _ in pairs(BringActiveThreads) do
                table.insert(toStop, player)
            end
            for _, player in ipairs(toStop) do
                BringStopTrackingPlayer(player)
            end

            if BringAllThread then
                local thread = BringAllThread
                BringAllThread = nil
                pcall(coroutine.close, thread)
            end
            ClearAllProps()
            return
        end

        setupPropsWithQuantity(propQuantity, false, function()
            if not BringAllActive then return end

            local myProps = getMyBringProps()
            if #myProps == 0 then
                BringAllToggle:Set(false)
                return
            end

            BringAllThread = task.spawn(function()
                while BringAllActive do
                    BringRedistributeProps()
                    task.wait(0.5)
                end
                BringAllThread = nil
            end)
        end)
    end
})
end



local TabCar = Window:MakeTab({"Vehicles", "car"})

local Section = TabCar:AddSection({"Speed Car Functions"})

local speedValue = 200
local turboValue = 11.3

local function getAllCars()
    local cars = {}
    if workspace:FindFirstChild("Vehicles") then
        for _, vehicle in pairs(workspace.Vehicles:GetChildren()) do
            if vehicle:FindFirstChild("Seats") and vehicle.Seats:FindFirstChild("VehicleSeat") then
                table.insert(cars, vehicle)
            end
        end
    end
    return cars
end

local function applyToAllCars(valueType, value)
    local cars = getAllCars()
    local carsModified = 0

    for _, car in pairs(cars) do
        local seat = car.Seats.VehicleSeat
        local target = seat:FindFirstChild(valueType)

        if target and target.Value ~= nil then
            target.Value = value
            carsModified = 1
        else
            pcall(function()
                seat[valueType] = value
                carsModified = 1
            end)
        end
    end

    newNotify("Slayer Hub", "Slayer Hub " .. carsModified .. " cars modified")
end

TabCar:AddTextBox({
    Title = "Car Speed",
    Placeholder = "Example: 300",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            speedValue = num
            newNotify("Slayer Hub", "Speed set to: " .. num)
        else
            newNotify("Slayer Hub", "Invalid number")
        end
    end
})

TabCar:AddTextBox({
    Title = "Turbo Power",
    Placeholder = "Example: 15",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            turboValue = num
            newNotify("Slayer Hub", "Turbo set to: " .. num)
        else
            newNotify("Slayer Hub", "Invalid number")
        end
    end
})

TabCar:AddButton({
    Title = "Apply Speed",
    Callback = function()
        applyToAllCars("MaxSpeed", speedValue)
    end
})

TabCar:AddButton({
    Title = "Apply Turbo",
    Callback = function()
        applyToAllCars("Turbo", turboValue)
    end
})

local Section = TabCar:AddSection({"all car functions"})


local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local TeleportCarro = {}
TeleportCarro.Players = Players
TeleportCarro.Workspace = Workspace
TeleportCarro.LocalPlayer = LocalPlayer
TeleportCarro.Camera = Camera

function TeleportCarro:MostrarNotificacao(mensagem)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Aviso",
            Text = mensagem,
            Duration = 5
        })
    end)
end

function TeleportCarro:ToggleFallDamage(disable)
    if not self.LocalPlayer.Character or not self.LocalPlayer.Character:FindFirstChild("Humanoid") then return false end
    local humanoid = self.LocalPlayer.Character.Humanoid
    if disable then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        humanoid.PlatformStand = false
        return true
    else
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        return false
    end
end

function TeleportCarro:TeleportToSeat(seat, car)
    if not self.LocalPlayer.Character or not self.LocalPlayer.Character:FindFirstChild("Humanoid") then
        self:MostrarNotificacao("Personagem não encontrado!")
        return false
    end
    local humanoid = self.LocalPlayer.Character.Humanoid
    local rootPart = self.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        self:MostrarNotificacao("Parte raiz do personagem não encontrada!")
        return false
    end

    humanoid.Sit = false
    task.wait(0.1)

    rootPart.CFrame = seat.CFrame + Vector3.new(0, 5, 0)
    task.wait(0.1)

    seat:Sit(humanoid)
    task.wait(0.5)
    return humanoid.SeatPart == seat
end

function TeleportCarro:TeleportToVoid(car)
    if not car then
        self:MostrarNotificacao("Veículo inválido!")
        return
    end
    if not car.PrimaryPart then
        local body = car:FindFirstChild("Body", true) or car:FindFirstChild("Chassis", true)
        if body and body:IsA("BasePart") then
            car.PrimaryPart = body
        else
            self:MostrarNotificacao("Parte principal do veículo não encontrada!")
            return
        end
    end
    local voidPosition = Vector3.new(0, -1000, 0)
    car:SetPrimaryPartCFrame(CFrame.new(voidPosition))
    task.wait(0.5)
end

function TeleportCarro:TeleportToPlayer(car, playerPos)
    if not car then
        self:MostrarNotificacao("Veículo inválido!")
        return
    end
    if not car.PrimaryPart then
        local body = car:FindFirstChild("Body", true) or car:FindFirstChild("Chassis", true)
        if body and body:IsA("BasePart") then
            car.PrimaryPart = body
        else
            self:MostrarNotificacao("Parte principal do veículo não encontrada!")
            return
        end
    end
    local targetPos = playerPos + Vector3.new(5, 0, 5)
    car:SetPrimaryPartCFrame(CFrame.new(targetPos))
    task.wait(0.5)
end

function TeleportCarro:ExitCarAndReturn(originalPos)
    if not self.LocalPlayer.Character or not self.LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = self.LocalPlayer.Character.Humanoid
    if humanoid.SeatPart then
        humanoid.Sit = false
    end
    task.wait(0.1)
    if originalPos then
        self.LocalPlayer.Character:PivotTo(CFrame.new(originalPos))
    end
end

function TeleportCarro:AtualizarListaCarros()
    local pastaVeiculos = self.Workspace:FindFirstChild("Vehicles")
    local listaCarros = {}
    
    if pastaVeiculos then
        for _, carro in ipairs(pastaVeiculos:GetChildren()) do
            if carro.Name:match("Car$") then
                table.insert(listaCarros, carro.Name)
            end
        end
    end
    
    return listaCarros
end


TabCar:AddToggle({
    Name = "Matar todos os carros do server",
    Description = "Teleporta os carros vazios para o void sequencialmente",
    Default = false,
    Callback = function(state)
        _G.KillAllCarsActive = state 

        if state then
            spawn(function()
                local player = TeleportCarro.LocalPlayer
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    TeleportCarro:MostrarNotificacao("Personagem não encontrado!")
                    return
                end

                local originalPosition = character.HumanoidRootPart.Position
                local vehiclesFolder = TeleportCarro.Workspace:FindFirstChild("Vehicles")
                
                if not vehiclesFolder then
                    TeleportCarro:MostrarNotificacao("Pasta de veículos não encontrada!")
                    return
                end

                TeleportCarro:ToggleFallDamage(true)

                local cars = vehiclesFolder:GetChildren()

                for _, car in ipairs(cars) do
                    if not _G.KillAllCarsActive then break end

                    if car.Name:match("Car$") or car:IsA("Model") then
                        local vehicleSeat = car:FindFirstChildWhichIsA("VehicleSeat", true)
                        
                        if vehicleSeat and not vehicleSeat.Occupant then
                            local success = TeleportCarro:TeleportToSeat(vehicleSeat, car)
                            
                            if success then
                                task.wait(0.1) 
                                TeleportCarro:TeleportToVoid(car)
                                TeleportCarro:ExitCarAndReturn(originalPosition)
                                task.wait(0.5)
                            end
                        end
                    end
                end

                TeleportCarro:ToggleFallDamage(false)
                TeleportCarro:MostrarNotificacao("Limpeza de carros finalizada!")
            end)
        else
            _G.KillAllCarsActive = false
            TeleportCarro:ToggleFallDamage(false)
        end
    end
})

TabCar:AddButton({
    Name = "Trazer Todos os Carros",
    Description = "Teleporta todos os carros do servidor para sua posição",
    Callback = function()
        local originalPos
        if TeleportCarro.LocalPlayer.Character and TeleportCarro.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            originalPos = TeleportCarro.LocalPlayer.Character.HumanoidRootPart.Position
        else
            TeleportCarro:MostrarNotificacao("Personagem do jogador não encontrado!")
            return
        end

        local vehiclesFolder = TeleportCarro.Workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then
            TeleportCarro:MostrarNotificacao("Pasta de veículos não encontrada!")
            return
        end

        local isFallDamageOff = TeleportCarro:ToggleFallDamage(true)
        local cars = {}
        for _, car in ipairs(vehiclesFolder:GetChildren()) do
            if car.Name:match("Car$") then
                table.insert(cars, car)
            end
        end

        for _, car in ipairs(cars) do
            local vehicleSeat = car:FindFirstChildWhichIsA("VehicleSeat", true)
            if vehicleSeat and vehicleSeat.Occupant == nil then
                local success = TeleportCarro:TeleportToSeat(vehicleSeat, car)
                if success then
                    TeleportCarro:TeleportToPlayer(car, originalPos)
                    TeleportCarro:ExitCarAndReturn(originalPos)
                    TeleportCarro:MostrarNotificacao("Carro " .. car.Name .. " foi teleportado para você!")
                    task.wait(1)
                else
                    TeleportCarro:MostrarNotificacao("Falha ao sentar no carro " .. car.Name .. "!")
                end
            else
                if vehicleSeat then
                    TeleportCarro:MostrarNotificacao("Carro " .. car.Name .. " ignorado: alguém está no assento do motorista!")
                else
                    TeleportCarro:MostrarNotificacao("Carro " .. car.Name .. " ignorado: assento não encontrado!")
                end
            end
        end

        TeleportCarro:ToggleFallDamage(false)
        if #cars == 0 then
            TeleportCarro:MostrarNotificacao("Nenhum carro disponível para teleportar!")
        end
    end
})

local fallDamageDisabled = false
TeleportCarro.LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if fallDamageDisabled then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        humanoid.PlatformStand = false
    else
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
end)

TabCar:AddButton({
    Name = "Fly Car",
    Callback = function()
        loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/WA68ktqqmy242pfY/raw"))()
    end
})

local FunRemake = Window:MakeTab({"Fun Remake", "fun"})


local Section2 = FunRemake:AddSection({

    Name = "Placa"

})

local texto = ""

local function trocaplaca(all, txt)
if all then
for _,v in next, game:GetService("Players"):GetPlayers() do
if v.Character and v.Character:FindFirstChild("Sign") then
v.Character:FindFirstChild("Sign").ToolSound:FireServer("Sign", "SignWords", txt)
end
end
else
if selectedHeadSit.Character and selectedHeadSit.Character:FindFirstChild("Sign") then
selectedHeadSit.Character:FindFirstChild("Sign").ToolSound:FireServer("Sign", "SignWords", txt)
end
end
end

FunRemake:AddTextBox({
    Name = "Texto",
    PlaceholderText = "Texto da placa",
    Callback = function(value)
        texto = value
    end
})

FunRemake:AddButton({
    Name = "Placa troca all",
    Callback = function(value)
        trocaplaca(true, texto)
    end
})


FunRemake:AddSection({
    Name = "Celular para Musicas"
})

FunRemake:AddButton({
    Name = "Celular",
    Callback = function(value)
        local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ANIMATION_ID = "110513918364936"
local WEAR_ITEM_ID = 15162014784

local APP_ICON_IMAGE = "rbxassetid://90019827067389"
local VOLUME_ICON_IMAGE = "rbxassetid://16601518608"
local WALLPAPER_IMAGE = "rbxassetid://135864322179987"

local Settings = {}
Settings["Fade In"] = 0.1
Settings["Fade Out"] = 0.1
Settings["Weight"] = 1
Settings["Speed"] = 1

local CurrentTrack = nil
local phoneGui = nil
local phoneTool = nil
local changingToBoombox = false
local boomboxAtiva = false
local musicaPendente = nil
local currentVolume = 100

local function getHumanoid()
	local character = player.Character

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function equipItem()
	local args = {
		[1] = WEAR_ITEM_ID
	}

	pcall(function()
		ReplicatedStorage
			:WaitForChild("Remotes", 9e9)
			:WaitForChild("Wear", 9e9)
			:InvokeServer(unpack(args))
	end)
end

local function unequipItem()
	local args = {
		[1] = WEAR_ITEM_ID
	}

	pcall(function()
		ReplicatedStorage
			:WaitForChild("Remotes", 9e9)
			:WaitForChild("Wear", 9e9)
			:InvokeServer(unpack(args))
	end)
end

local function stopPhoneAnimation()
	if CurrentTrack then
		pcall(function()
			CurrentTrack:Stop(Settings["Fade Out"])
		end)

		CurrentTrack = nil
	end
end

local function loadPhoneAnimation()
	local humanoid = getHumanoid()

	if not humanoid then
		return nil
	end

	stopPhoneAnimation()

	local animId = "rbxassetid://" .. tostring(ANIMATION_ID)

	local ok, result = pcall(function()
		return game:GetObjects(animId)
	end)

	if ok and result and #result > 0 then
		local anim = result[1]

		if anim:IsA("Animation") then
			animId = anim.AnimationId
		end
	end

	local newAnim = Instance.new("Animation")
	newAnim.AnimationId = animId

	local newTrack

	pcall(function()
		newTrack = humanoid:LoadAnimation(newAnim)
	end)

	if not newTrack then
		newAnim:Destroy()
		return nil
	end

	newTrack.Priority = Enum.AnimationPriority.Action4

	local weight = Settings["Weight"]

	if weight == 0 then
		weight = 0.001
	end

	newTrack:Play(
		Settings["Fade In"],
		weight,
		Settings["Speed"]
	)

	CurrentTrack = newTrack

	newAnim:Destroy()

	return newTrack
end

local function encontrarBoombox()
	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")
	local starterGear = player:FindFirstChild("StarterGear")

	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") and string.find(string.lower(item.Name), "boombox", 1, true) then
				return item
			end
		end
	end

	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") and string.find(string.lower(item.Name), "boombox", 1, true) then
				return item
			end
		end
	end

	if starterGear then
		for _, item in ipairs(starterGear:GetChildren()) do
			if item:IsA("Tool") and string.find(string.lower(item.Name), "boombox", 1, true) then
				return item
			end
		end
	end

	return nil
end

local function equiparBoombox()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false
	end

	local boombox = encontrarBoombox()

	if not boombox then
		return false
	end

	if boombox.Parent == character then
		boomboxAtiva = true
		return true
	end

	humanoid:EquipTool(boombox)

	local limite = os.clock() + 3

	while os.clock() < limite do
		if boombox.Parent == character then
			boomboxAtiva = true
			return true
		end

		task.wait(0.05)
	end

	if boombox.Parent == character then
		boomboxAtiva = true
		return true
	end

	return false
end

local function obterBoombox()
	local encontrada = encontrarBoombox()

	if encontrada then
		return equiparBoombox()
	end

	local args = {
		[1] = "PickingTools",
		[2] = "Boombox"
	}

	local sucesso = pcall(function()
		ReplicatedStorage
			:WaitForChild("RE", 9e9)
			:WaitForChild("1Too1l", 9e9)
			:InvokeServer(unpack(args))
	end)

	if not sucesso then
		return false
	end

	local limite = os.clock() + 5

	while os.clock() < limite do
		local boombox = encontrarBoombox()

		if boombox then
			return equiparBoombox()
		end

		task.wait(0.05)
	end

	return false
end

local function enviarMusica(id)
	local re = ReplicatedStorage:WaitForChild("RE", 9e9)
	local musica = tostring(id)

	pcall(function()
		re:WaitForChild("PlayerToolEvent", 9e9):FireServer(
			"ToolMusicText",
			musica
		)
	end)

	pcall(function()
		re:WaitForChild("1Player1sHous1e", 9e9):FireServer(
			"PickHouseMusicText",
			musica
		)
	end)

	pcall(function()
		re:WaitForChild("1Player1sCa1r", 9e9):FireServer(
			"PickingCarMusicText",
			musica
		)
	end)

	pcall(function()
		re:WaitForChild("1NoMoto1rVehicle1s", 9e9):FireServer(
			"PickingScooterMusicText",
			musica
		)
	end)
end

local function enviarVolume(valor)
	local numero = tonumber(valor)

	if not numero then
		return false
	end

	numero = math.clamp(math.floor(numero), 1, 100)
	currentVolume = numero

	local args = {
		[1] = numero
	}

	local sucesso = pcall(function()
		player
			:WaitForChild("PlayerGui", 9e9)
			:WaitForChild("MainGUIHandler", 9e9)
			:WaitForChild("MainAudio", 9e9)
			:WaitForChild("Catalog", 9e9)
			:WaitForChild("Header", 9e9)
			:WaitForChild("VolumeContainer", 9e9)
			:WaitForChild("VolumeChangeRequest", 9e9)
			:FireServer(unpack(args))
	end)

	return sucesso
end

local function tocarMusica(id)
	if changingToBoombox then
		return
	end

	local musica = tostring(id)

	if musica == "" then
		return
	end

	if not string.match(musica, "^%d+$") then
		return
	end

	changingToBoombox = true
	musicaPendente = musica

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and phoneTool and phoneTool.Parent == character then
		humanoid:UnequipTools()
	end

	stopPhoneAnimation()

	if phoneGui then
		phoneGui:Destroy()
		phoneGui = nil
	end

	unequipItem()

	task.wait(0.15)

	local equipada = obterBoombox()

	if equipada then
		task.wait(0.15)

		if musicaPendente then
			enviarMusica(musicaPendente)
			musicaPendente = nil
		end

		task.wait(0.15)

		enviarVolume(currentVolume)
	end

	changingToBoombox = false
end

local function pararMusica()
	local character = workspace:FindFirstChild(player.Name)

	if character then
		local boombox = character:FindFirstChild("Boombox")

		if boombox then
			local quickDelete = boombox:FindFirstChild("QuickDelete")

			if quickDelete then
				pcall(function()
					quickDelete:FireServer(unpack({}))
				end)
			end
		end
	end

	boomboxAtiva = false
	musicaPendente = nil
end

local MUSIC_LIST_URL = "https://raw.githubusercontent.com/Luckzzxw/musicsss/refs/heads/main/musics.lua"

_G.musicOptions = {}

local success, result = pcall(function()
    local source = game:HttpGet(MUSIC_LIST_URL)
    local chunk = loadstring(source)

    if not chunk then
        error("Não foi possível compilar musicas.lua")
    end

    return chunk()
end)

if success and type(result) == "table" then
    _G.musicOptions = result
else
    warn("Não foi possível carregar a lista de músicas.")
    warn("[Music] Erro:", tostring(result))
end

do
    local totalCategorias = 0
    for _ in pairs(_G.musicOptions) do
        totalCategorias = totalCategorias + 1
    end
    print("[Music] _G.musicOptions carregado. Categorias encontradas: " .. totalCategorias)
end

local function criarCaixaPesquisa(parent, placeholder, position)
	local searchBox = Instance.new("TextBox")

	searchBox.Size = UDim2.fromScale(0.92, 0.075)
	searchBox.Position = position
	searchBox.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
	searchBox.BackgroundTransparency = 0.1
	searchBox.BorderSizePixel = 0
	searchBox.PlaceholderText = placeholder
	searchBox.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
	searchBox.Text = ""
	searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBox.TextSize = 12
	searchBox.Font = Enum.Font.Gotham
	searchBox.ClearTextOnFocus = false
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.TextYAlignment = Enum.TextYAlignment.Center
	searchBox.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.18, 0)
	corner.Parent = searchBox

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 0.8
	stroke.Transparency = 0.2
	stroke.Parent = searchBox

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = searchBox

	return searchBox
end

local function criarLista(parent, position, size)
	local list = Instance.new("ScrollingFrame")

	list.Name = ""
	list.Size = size
	list.Position = position
	list.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
	list.BackgroundTransparency = 0.2
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 3
	list.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.04, 0)
	corner.Parent = list

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = list

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 3)
	padding.PaddingRight = UDim.new(0, 3)
	padding.Parent = list

	return list
end

local function limparLista(list)
	for _, child in ipairs(list:GetChildren()) do
		if not child:IsA("UIListLayout")
			and not child:IsA("UIPadding") then

			child:Destroy()
		end
	end
end

local function criarBotaoMusica(parent, music)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(0.94, 0, 0, 38)
	button.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	button.BackgroundTransparency = 0.05
	button.BorderSizePixel = 0
	button.Text = music.name
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 11
	button.Font = Enum.Font.Gotham
	button.TextScaled = false
	button.TextWrapped = false
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextYAlignment = Enum.TextYAlignment.Center
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.16, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 0.7
	stroke.Transparency = 0.35
	stroke.Parent = button

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = button

	button.Activated:Connect(function()
		tocarMusica(music.id)
	end)

	return button
end

local function criarTopBar(parent, title)
	local top = Instance.new("Frame")

	top.Size = UDim2.fromScale(0.92, 0.09)
	top.Position = UDim2.fromScale(0.04, 0)
	top.BackgroundTransparency = 1
	top.Parent = parent

	local titleLabel = Instance.new("TextLabel")

	titleLabel.Size = UDim2.fromScale(0.72, 1)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = false
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamMedium
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Parent = top

	local back = Instance.new("TextButton")

	back.Size = UDim2.fromOffset(34, 27)
	back.Position = UDim2.fromScale(0.88, 0.15)
	back.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
	back.BackgroundTransparency = 0.1
	back.BorderSizePixel = 0
	back.Text = "Voltar"
	back.TextColor3 = Color3.fromRGB(255, 255, 255)
	back.TextScaled = false
	back.TextSize = 8
	back.Font = Enum.Font.Gotham
	back.Parent = top

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = back

	back.Activated:Connect(function()
		local pageFolder = parent.Parent

		for _, page in ipairs(pageFolder:GetChildren()) do
			if page:IsA("Frame") then
				page.Visible = false
			end
		end

		local homePage = pageFolder:FindFirstChild("HomePage")

		if homePage then
			homePage.Visible = true
		end
	end)
end

local function criarBotaoPrincipal(parent, text, position)
	local button = Instance.new("TextButton")

	button.Size = UDim2.fromScale(0.92, 0.075)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
	button.BackgroundTransparency = 0.05
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = false
	button.TextSize = 12
	button.Font = Enum.Font.GothamMedium
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.18, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 0.8
	stroke.Transparency = 0.15
	stroke.Parent = button

	return button
end

local function criarCelular()
	if phoneGui then
		phoneGui:Destroy()
		phoneGui = nil
	end

	local screenGui = Instance.new("ScreenGui")

	screenGui.Name = "TabletGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	phoneGui = screenGui

	local tabletFrame = Instance.new("Frame")

	tabletFrame.Name = "TabletFrame"
	tabletFrame.Size = UDim2.fromOffset(315, 450)
	tabletFrame.Position = UDim2.fromScale(0.5, 0.5)
	tabletFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	tabletFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	tabletFrame.BorderSizePixel = 0
	tabletFrame.Active = true
	tabletFrame.Selectable = true
	tabletFrame.Parent = screenGui

	local tabletCorner = Instance.new("UICorner")
	tabletCorner.CornerRadius = UDim.new(0.08, 0)
	tabletCorner.Parent = tabletFrame

	local tabletStroke = Instance.new("UIStroke")
	tabletStroke.Color = Color3.fromRGB(255, 255, 255)
	tabletStroke.Thickness = 2
	tabletStroke.Parent = tabletFrame

	local wallpaper = Instance.new("ImageLabel")

	wallpaper.Name = ""
	wallpaper.Size = UDim2.fromScale(1, 1)
	wallpaper.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	wallpaper.BorderSizePixel = 0
	wallpaper.Image = WALLPAPER_IMAGE
	wallpaper.ScaleType = Enum.ScaleType.Crop
	wallpaper.Active = false
	wallpaper.Parent = tabletFrame

	local wallpaperCorner = Instance.new("UICorner")
	wallpaperCorner.CornerRadius = UDim.new(0.08, 0)
	wallpaperCorner.Parent = wallpaper

	local contentHolder = Instance.new("Frame")

	contentHolder.Size = UDim2.fromScale(1, 1)
	contentHolder.BackgroundTransparency = 1
	contentHolder.Active = false
	contentHolder.Parent = tabletFrame

	local notch = Instance.new("Frame")

	notch.Size = UDim2.fromScale(0.15, 0.025)
	notch.Position = UDim2.fromScale(0.5, 0.015)
	notch.AnchorPoint = Vector2.new(0.5, 0)
	notch.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	notch.BorderSizePixel = 0
	notch.Parent = contentHolder

	local notchCorner = Instance.new("UICorner")
	notchCorner.CornerRadius = UDim.new(0.5, 0)
	notchCorner.Parent = notch

	local camera = Instance.new("Frame")

	camera.Size = UDim2.fromOffset(5, 5)
	camera.Position = UDim2.fromScale(0.3, 0.5)
	camera.AnchorPoint = Vector2.new(0.5, 0.5)
	camera.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	camera.BorderSizePixel = 0
	camera.Parent = notch

	local cameraCorner = Instance.new("UICorner")
	cameraCorner.CornerRadius = UDim.new(1, 0)
	cameraCorner.Parent = camera

	local pages = {}

	local function createPage(name)
		local page = Instance.new("Frame")

		page.Name = name
		page.Size = UDim2.fromScale(1, 0.80)
		page.Position = UDim2.fromScale(0, 0.095)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.Parent = contentHolder

		pages[name] = page

		return page
	end

	local homePage = createPage("HomePage")
	local musicPage = createPage("MusicPage")
	local searchPage = createPage("SearchPage")
	local idsPage = createPage("IdsPage")
	local volumePage = createPage("VolumePage")

	homePage.Visible = true

	local function showPage(page)
		for _, otherPage in pairs(pages) do
			otherPage.Visible = false
		end

		page.Visible = true
	end

	criarTopBar(musicPage, "Música")
	criarTopBar(searchPage, "Pesquisar")
	criarTopBar(idsPage, "Por IDs")
	criarTopBar(volumePage, "Volume")

	local idsInput = Instance.new("TextBox")

	idsInput.Size = UDim2.fromScale(0.92, 0.10)
	idsInput.Position = UDim2.fromScale(0.04, 0.15)
	idsInput.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
	idsInput.BackgroundTransparency = 0.1
	idsInput.BorderSizePixel = 0
	idsInput.PlaceholderText = "Digite o ID da música..."
	idsInput.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
	idsInput.Text = ""
	idsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	idsInput.TextSize = 13
	idsInput.Font = Enum.Font.Gotham
	idsInput.ClearTextOnFocus = false
	idsInput.TextXAlignment = Enum.TextXAlignment.Left
	idsInput.TextYAlignment = Enum.TextYAlignment.Center
	idsInput.Parent = idsPage

	local idsCorner = Instance.new("UICorner")
	idsCorner.CornerRadius = UDim.new(0.18, 0)
	idsCorner.Parent = idsInput

	local idsStroke = Instance.new("UIStroke")
	idsStroke.Color = Color3.fromRGB(255, 255, 255)
	idsStroke.Thickness = 0.8
	idsStroke.Transparency = 0.15
	idsStroke.Parent = idsInput

	local idsPadding = Instance.new("UIPadding")
	idsPadding.PaddingLeft = UDim.new(0, 12)
	idsPadding.PaddingRight = UDim.new(0, 12)
	idsPadding.Parent = idsInput

	local activateButton = criarBotaoPrincipal(
		idsPage,
		"Ativar Som",
		UDim2.fromScale(0.04, 0.28)
	)

	activateButton.Activated:Connect(function()
		local id = tostring(idsInput.Text)

		if id == "" then
			return
		end

		if not string.match(id, "^%d+$") then
			return
		end

		tocarMusica(id)
	end)

	local volumeInfo = Instance.new("TextLabel")

	volumeInfo.Size = UDim2.fromScale(0.92, 0.08)
	volumeInfo.Position = UDim2.fromScale(0.04, 0.14)
	volumeInfo.BackgroundTransparency = 1
	volumeInfo.Text = "Escolha o volume"
	volumeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
	volumeInfo.TextSize = 14
	volumeInfo.Font = Enum.Font.GothamMedium
	volumeInfo.TextXAlignment = Enum.TextXAlignment.Left
	volumeInfo.Parent = volumePage

	local volumeInput = Instance.new("TextBox")

	volumeInput.Size = UDim2.fromScale(0.92, 0.10)
	volumeInput.Position = UDim2.fromScale(0.04, 0.24)
	volumeInput.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
	volumeInput.BackgroundTransparency = 0.1
	volumeInput.BorderSizePixel = 0
	volumeInput.PlaceholderText = "Digite o volume de 1 a 100"
	volumeInput.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
	volumeInput.Text = tostring(currentVolume)
	volumeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	volumeInput.TextSize = 13
	volumeInput.Font = Enum.Font.Gotham
	volumeInput.ClearTextOnFocus = false
	volumeInput.TextXAlignment = Enum.TextXAlignment.Center
	volumeInput.TextYAlignment = Enum.TextYAlignment.Center
	volumeInput.Parent = volumePage

	local volumeInputCorner = Instance.new("UICorner")
	volumeInputCorner.CornerRadius = UDim.new(0.18, 0)
	volumeInputCorner.Parent = volumeInput

	local volumeInputStroke = Instance.new("UIStroke")
	volumeInputStroke.Color = Color3.fromRGB(255, 255, 255)
	volumeInputStroke.Thickness = 0.8
	volumeInputStroke.Transparency = 0.15
	volumeInputStroke.Parent = volumeInput

	local volumeButton = criarBotaoPrincipal(
		volumePage,
		"Aplicar Volume",
		UDim2.fromScale(0.04, 0.37)
	)

	local volumeStatus = Instance.new("TextLabel")

	volumeStatus.Size = UDim2.fromScale(0.92, 0.08)
	volumeStatus.Position = UDim2.fromScale(0.04, 0.46)
	volumeStatus.BackgroundTransparency = 1
	volumeStatus.Text = "Volume atual: " .. tostring(currentVolume)
	volumeStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
	volumeStatus.TextSize = 10
	volumeStatus.Font = Enum.Font.Gotham
	volumeStatus.TextXAlignment = Enum.TextXAlignment.Center
	volumeStatus.Parent = volumePage

	volumeButton.Activated:Connect(function()
		local valor = tonumber(volumeInput.Text)

		if not valor then
			volumeInput.Text = tostring(currentVolume)
			return
		end

		valor = math.clamp(math.floor(valor), 1, 100)

		currentVolume = valor
		volumeInput.Text = tostring(currentVolume)
		volumeStatus.Text = "Volume atual: " .. tostring(currentVolume)

		enviarVolume(currentVolume)
	end)

	volumeInput.FocusLost:Connect(function()
		local valor = tonumber(volumeInput.Text)

		if valor then
			valor = math.clamp(math.floor(valor), 1, 100)

			currentVolume = valor
			volumeInput.Text = tostring(currentVolume)
			volumeStatus.Text = "Volume atual: " .. tostring(currentVolume)
		else
			volumeInput.Text = tostring(currentVolume)
		end
	end)

	local function loadCategory(category)
		for _, child in ipairs(musicPage:GetChildren()) do
			if child.Name == "CategorySearchBox"
				or child.Name == "CategoryMusicList" then

				child:Destroy()
			end
		end

		local searchBox = criarCaixaPesquisa(
			musicPage,
			"Pesquisar em " .. category .. "...",
			UDim2.fromScale(0.04, 0.10)
		)

		searchBox.Name = "CategorySearchBox"

		local musicList = criarLista(
			musicPage,
			UDim2.fromScale(0.04, 0.19),
			UDim2.fromScale(0.92, 0.70)
		)

		musicList.Name = "CategoryMusicList"

		local songs = _G.musicOptions[category] or {}

		local function atualizarLista()
			limparLista(musicList)

			local pesquisa = string.lower(searchBox.Text)

			for _, music in ipairs(songs) do
				local nome = string.lower(music.name)

				if pesquisa == ""
					or string.find(nome, pesquisa, 1, true) then

					criarBotaoMusica(musicList, music)
				end
			end
		end

		searchBox:GetPropertyChangedSignal("Text"):Connect(atualizarLista)

		atualizarLista()
		showPage(musicPage)
	end

	local globalSearchBox = criarCaixaPesquisa(
		searchPage,
		"Pesquisar em todas as músicas...",
		UDim2.fromScale(0.04, 0.10)
	)

	local globalMusicList = criarLista(
		searchPage,
		UDim2.fromScale(0.04, 0.19),
		UDim2.fromScale(0.92, 0.70)
	)

	local function atualizarBuscaGlobal()
		limparLista(globalMusicList)

		local pesquisa = string.lower(globalSearchBox.Text)

		for category, songs in pairs(_G.musicOptions) do
			for _, music in ipairs(songs) do
				local nome = string.lower(music.name)
				local categoria = string.lower(category)

				if pesquisa == ""
					or string.find(nome, pesquisa, 1, true)
					or string.find(categoria, pesquisa, 1, true) then

					local button = criarBotaoMusica(globalMusicList, music)

					if pesquisa ~= "" then
						button.Text = music.name .. " - " .. category
					end
				end
			end
		end
	end

	globalSearchBox:GetPropertyChangedSignal("Text"):Connect(atualizarBuscaGlobal)

	atualizarBuscaGlobal()

	local homeLayout = Instance.new("UIGridLayout")

	homeLayout.CellSize = UDim2.fromOffset(68, 78)
	homeLayout.CellPadding = UDim2.fromOffset(5, 7)
	homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	homeLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	homeLayout.Parent = homePage

	local function createStyleApp(name, imageId)
		local holder = Instance.new("Frame")

		holder.Name = name
		holder.Size = UDim2.fromOffset(68, 78)
		holder.BackgroundTransparency = 1
		holder.Parent = homePage

		local button = Instance.new("ImageButton")

		button.Size = UDim2.fromOffset(54, 54)
		button.Position = UDim2.fromOffset(7, 0)
		button.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
		button.BorderSizePixel = 0
		button.Image = imageId
		button.ScaleType = Enum.ScaleType.Crop
		button.Parent = holder

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.25, 0)
		corner.Parent = button

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Thickness = 1.2
		stroke.Transparency = 0.05
		stroke.Parent = button

		local label = Instance.new("TextLabel")

		label.Size = UDim2.new(1, 4, 0, 20)
		label.Position = UDim2.fromOffset(-2, 57)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = false
		label.TextWrapped = false
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Parent = holder

		if name == "Forró e Sertanejo" then
			label.TextSize = 7
		else
			label.TextSize = 8
		end

		button.Activated:Connect(function()
			if name == "Pesquisar" then
				globalSearchBox.Text = ""
				atualizarBuscaGlobal()
				showPage(searchPage)

			elseif name == "Por IDs" then
				idsInput.Text = ""
				showPage(idsPage)

			elseif name == "Volume" then
				volumeInput.Text = tostring(currentVolume)
				volumeStatus.Text = "Volume atual: " .. tostring(currentVolume)
				showPage(volumePage)

			else
				loadCategory(name)
			end
		end)
	end

	createStyleApp("Forró e Sertanejo", APP_ICON_IMAGE)

	local stopHolder = Instance.new("Frame")

	stopHolder.Name = "StopHolder"
	stopHolder.Size = UDim2.fromOffset(68, 78)
	stopHolder.BackgroundTransparency = 1
	stopHolder.Parent = homePage

	local stopButton = Instance.new("TextButton")

	stopButton.Size = UDim2.fromOffset(54, 54)
	stopButton.Position = UDim2.fromOffset(7, 0)
	stopButton.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
	stopButton.BackgroundTransparency = 0.08
	stopButton.BorderSizePixel = 0
	stopButton.Text = "STOP"
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.TextScaled = false
	stopButton.TextSize = 11
	stopButton.Font = Enum.Font.GothamMedium
	stopButton.Parent = stopHolder

	local stopCorner = Instance.new("UICorner")
	stopCorner.CornerRadius = UDim.new(0.25, 0)
	stopCorner.Parent = stopButton

	local stopStroke = Instance.new("UIStroke")
	stopStroke.Color = Color3.fromRGB(255, 255, 255)
	stopStroke.Thickness = 1.2
	stopStroke.Parent = stopButton

	stopButton.Activated:Connect(pararMusica)

	createStyleApp("Trap", APP_ICON_IMAGE)
	createStyleApp("Por IDs", APP_ICON_IMAGE)
	createStyleApp("Funk", APP_ICON_IMAGE)
	createStyleApp("Phonk", APP_ICON_IMAGE)
	createStyleApp("Pesquisar", APP_ICON_IMAGE)
	createStyleApp("Volume", VOLUME_ICON_IMAGE)

	local home = Instance.new("TextButton")

	home.Name = "Home"
	home.Size = UDim2.fromScale(0.25, 0.03)
	home.Position = UDim2.fromScale(0.5, 0.94)
	home.AnchorPoint = Vector2.new(0.5, 0)
	home.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	home.BackgroundTransparency = 0.2
	home.BorderSizePixel = 0
	home.Text = ""
	home.Parent = contentHolder

	local homeCorner = Instance.new("UICorner")
	homeCorner.CornerRadius = UDim.new(0.5, 0)
	homeCorner.Parent = home

	home.Activated:Connect(function()
		showPage(homePage)
	end)

	local dragging = false
	local dragStart = nil
	local startPosition = nil
	local dragInput = nil

	local function updateDrag(input)
		local delta = input.Position - dragStart

		tabletFrame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end

	tabletFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = tabletFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
				end
			end)
		end
	end)

	tabletFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			updateDrag(input)
		end
	end)

	local cameraConnection

	local function reposition()
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local viewport = currentCamera.ViewportSize

		if UserInputService.TouchEnabled then
			local width = math.min(viewport.X * 0.62, 390)
			local height = math.min(viewport.Y * 0.62, 480)

			width = math.clamp(width, 270, 390)
			height = math.clamp(height, 330, 480)

			tabletFrame.Size = UDim2.fromOffset(width, height)
		else
			tabletFrame.Size = UDim2.fromOffset(315, 450)
		end
	end

	local function connectCamera()
		if cameraConnection then
			cameraConnection:Disconnect()
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			cameraConnection =
				currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(reposition)
		end

		reposition()
	end

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectCamera)

	connectCamera()

	return screenGui
end

local function ativarTelefone()
	if changingToBoombox then
		return
	end

	equipItem()

	task.wait(0.1)

	loadPhoneAnimation()
	criarCelular()
end

local function desativarTelefone()
	if changingToBoombox then
		return
	end

	stopPhoneAnimation()

	if phoneGui then
		phoneGui:Destroy()
		phoneGui = nil
	end

	unequipItem()
end

phoneTool = Instance.new("Tool")

phoneTool.Name = "Phone"
phoneTool.RequiresHandle = false
phoneTool.CanBeDropped = false
phoneTool.ManualActivationOnly = true
phoneTool.Parent = player:WaitForChild("Backpack")

phoneTool.Equipped:Connect(function()
	if changingToBoombox then
		return
	end

	ativarTelefone()
end)

phoneTool.Unequipped:Connect(function()
	if changingToBoombox then
		return
	end

	desativarTelefone()
end)

player.CharacterAdded:Connect(function()
	boomboxAtiva = false
	musicaPendente = nil
	changingToBoombox = false

	if phoneGui then
		phoneGui:Destroy()
		phoneGui = nil
	end

	CurrentTrack = nil

	task.wait(0.5)

	if phoneTool then
		phoneTool.Parent = player:WaitForChild("Backpack")
	end
end)
    end
})



local TabSound = Window:MakeTab({"Sound All", "box"})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local function tocarGlobalmente(soundId)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local args = {
                [1] = hrp,
                [2] = hrp,
                [3] = Vector3.new(0, -1, 0),
                [4] = Vector3.new(0, 0, 0),
                [5] = hrp,
                [6] = hrp,
                [7] = tostring(soundId),
                [8] = tostring(soundId),
                [9] = { [1] = true },
                [10] = {
                    [1] = 25,
                    [2] = Vector3.new(0.25, 0.25, 100),
                    [3] = BrickColor.new(24),
                    [4] = 0.25,
                    [5] = Enum.Material.SmoothPlastic,
                    [6] = 0.25
                },
                [11] = true,
                [12] = false
            }

            local remote = ReplicatedStorage:FindFirstChild("RE")
            if remote and remote:FindFirstChild("1Gu1n") then
                pcall(function()
                    remote["1Gu1n"]:FireServer(unpack(args))
                end)
            end
        end
    end
end

local loopAtivo = false
local InputID = ""

TabSound:AddTextBox({
    Name = "Insira o ID Audio All",
    Description = "Digite o ID do som que deseja tocar globalmente",
    PlaceholderText = "Exemplo: 1234567890",
    ClearTextOnFocus = true,
    Callback = function(text)
        InputID = tonumber(text)
    end
})

TabSound:AddButton({
    Name = "Tocar Som Global",
    Description = "Toca o áudio para todos os jogadores",
    Callback = function()
        if InputID then
            tocarGlobalmente(InputID)

            local globalSound = Instance.new("Sound")
            globalSound.Parent = Workspace
            globalSound.SoundId = "rbxassetid://" .. InputID
            globalSound.Volume = 3
            globalSound.Looped = false
            globalSound:Play()

            task.delay(5, function()
                globalSound:Destroy()
            end)
        end
    end
})

TabSound:AddToggle({
    Name = "Loop Global",
    Description = "Repetir som globalmente",
    Default = false,
    Callback = function(state)
        loopAtivo = state
        if loopAtivo then
            task.spawn(function()
                while loopAtivo do
                    if InputID then
                        tocarGlobalmente(InputID)

                        local globalSound = Instance.new("Sound")
                        globalSound.Parent = Workspace
                        globalSound.SoundId = "rbxassetid://" .. InputID
                        globalSound.Volume = 3
                        globalSound.Looped = false
                        globalSound:Play()

                        task.delay(5, function()
                            globalSound:Destroy()
                        end)
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

TabSound:AddSection({ "memes" })

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local function tocarGlobalmente(soundId)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local args = {
                [1] = hrp,
                [2] = hrp,
                [3] = Vector3.new(0, -1, 0),
                [4] = Vector3.new(0, 0, 0),
                [5] = hrp,
                [6] = hrp,
                [7] = tostring(soundId),
                [8] = tostring(soundId),
                [9] = { [1] = true },
                [10] = {
                    [1] = 25,
                    [2] = Vector3.new(0.25, 0.25, 100),
                    [3] = BrickColor.new(24),
                    [4] = 0.25,
                    [5] = Enum.Material.SmoothPlastic,
                    [6] = 0.25
                },
                [11] = true,
                [12] = false
            }

            local remote = ReplicatedStorage:FindFirstChild("RE")
            if remote and remote:FindFirstChild("1Gu1n") then
                pcall(function()
                    remote["1Gu1n"]:FireServer(unpack(args))
                end)
            end
        end
    end
end

local sonsMemes = {
    {name = "Trollface laugh", id = "73753120048787"},
    {name = "troll face sussy", id = "9098738774"},
    {name = "troll cut", id = "8389041427"},
    {name = "troll transition", id = "7705506391"},
    {name = "troll laugh", id = "7816195044"},
    {name = "Magic2", id = "9066733515"},
    {name = "homero brasileo", id = "115224076671067"},
    {name = "LOUD Youve been trolled", id = "6787686247"},
    {name = "Fart Meme Sound", id = "6454805792"},
    {name = "Metal Rattle 2 SFX", id = "9116788555"},
    {name = "Hentai wiaaaaan", id = "88332347208779"},
    {name = "iamete cunasai", id = "108494476595033"},
    {name = "dodichan onnn...", id = "134640594695384"},
    {name = "Toma jack", id = "132603645477541"},
    {name = "Toma jackV2", id = "100446887985203"},
    {name = "Toma jack no sol quente", id = "97476487963273"},
    {name = "ifood", id = "133843750864059"},
    {name = "pelo geito ela ta querendo ram", id = "94395705857835"},
    {name = "lula vai todo mundo", id = "136804576009416"},
    {name = "coringa", id = "84663543883498"},
    {name = "shoope", id = "8747441609"},
    {name = "quenojo", id = "103440368630269"},
    {name = "sai dai lava prato", id = "101232400175829"},
    {name = "se e loko numconpeça", id = "78442476709262"},
    {name = "mita sequer que eu too uma", id = "94889439372168"},
    {name = "Hoje vou ser tua mulher e tu", id = "90844637105538"},
    {name = "Deita aqui eu mandei vc deitar sirens", id = "100291188941582"},
    {name = "miau", id = "131804436682424"},
    {name = "skibidi", id = "128771670035179"},
    {name = "BIRULEIBI", id = "121569761604968"},
    {name = "sai", id = "121169949217007"},
    {name = "risada boa dms", id = "127589011971759"},
    {name = "vacilo perna de pau", id = "106809680656199"},
    {name = "gomo gomo no!!!", id = "137067472449625"},
    {name = "arroto", id = "140203378050178"},
    {name = "iraaaa", id = "136752451575091"},
    {name = "não fica se achando muito não", id = "101588606280167"},
    {name = "WhatsApp notificação", id = "107004225739474"},
    {name = "Samsung", id = "123767635061073"},
    {name = "Shiiii", id = "120566727202986"},
    {name = "ai_tomaa miku", id = "139770074770361"},
    {name = "kuru_kuru", id = "122465710753374"},
    {name = "PM ROCAM", id = "96161547081609"},
    {name = "cavalo!!", id = "78871573440184"},
    {name = "deixa os garoto brinca", id = "80291355054807"},
    {name = "flamengo", id = "137774355552052"},
    {name = "sai do mei satnas", id = "127944706557246"},
    {name = "namoral agora e a hora", id = "120677947987369"},
    {name = "n pode me chutar pq seu celebro e burro", id = "82284055473737"},
    {name = "vc ta fudido vou te pegar", id = "120214772725166"},
    {name = "deley", id = "102906880476838"},
    {name = "Tu e um beta", id = "130233956349541"},
    {name = "Porfavor n tira eu nao", id = "85321374020324"},
    {name = "Olá beleza vc pode me dá muitos", id = "74235334504693"},
    {name = "Discord sus", id = "122662798976905"},
    {name = "rojao apito", id = "6549021381"},
    {name = "off", id = "1778829098"},
    {name = "Kazuma kazuma", id = "127954653962405"},
    {name = "sometourado", id = "123592956882621"},
    {name = "Estouradoespad", id = "136179020015211"},
    {name = "Alaku bommm", id = "110796593805268"},
    {name = "busss", id = "139841197791567"},
    {name = "Estourado wItb", id = "137478052262430"},
    {name = "sla", id = "116672405522828"},
    {name = "HA HA HA", id = "138236682866721"}
}

local nomesSons = {}
local mapaSons = {}
for _, v in ipairs(sonsMemes) do
    table.insert(nomesSons, v.name)
    mapaSons[v.name] = v.id
end

local loopDropdownAtivo = false
local somSelecionado = nil

TabSound:AddDropdown({
    Name = "Memes Sons Globais",
    Description = "Escolha um som para tocar globalmente",
    Default = nomesSons[1],
    Options = nomesSons,
    Callback = function(valor)
        somSelecionado = mapaSons[valor]
    end
})

TabSound:AddButton({
    Name = "Tocar Som Selecionado",
    Description = "Toca o som globalmente",
    Callback = function()
        if somSelecionado then
            tocarGlobalmente(somSelecionado)
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. somSelecionado
            s.Volume = 3
            s.Looped = false
            s.Parent = Workspace
            s:Play()
            task.delay(5, function() s:Destroy() end)
        end
    end
})

TabSound:AddToggle({
    Name = "Loop Som Global",
    Description = "Repete o som selecionado globalmente",
    Default = false,
    Callback = function(estado)
        loopDropdownAtivo = estado
        if loopDropdownAtivo then
            task.spawn(function()
                while loopDropdownAtivo do
                    if somSelecionado then
                        tocarGlobalmente(somSelecionado)
                        local s = Instance.new("Sound")
                        s.SoundId = "rbxassetid://" .. somSelecionado
                        s.Volume = 3
                        s.Looped = false
                        s.Parent = Workspace
                        s:Play()
                        task.delay(5, function() s:Destroy() end)
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local Tab = Window:MakeTab({"Music", "music"})

Tab:AddParagraph({ "Musica Nao foi? nos informe no discord." })

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FAVORITES_FILE = "music_favorites.json"

local Favorites = {}

local function loadFavorites()
    if not (isfile and readfile) then
        return {}
    end
    if not isfile(FAVORITES_FILE) then
        return {}
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(FAVORITES_FILE))
    end)
    if ok and type(data) == "table" then
        return data
    end
    return {}
end

local function saveFavorites()
    if not writefile then return end
    local ok, json = pcall(function()
        return HttpService:JSONEncode(Favorites)
    end)
    if ok then
        pcall(writefile, FAVORITES_FILE, json)
    end
end

Favorites = loadFavorites()

local function tocarMusica(id)
    local argsRadio = {
        [1] = "ToolMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("PlayerToolEvent"):FireServer(unpack(argsRadio))

    local argsCasa = {
        [1] = "PickHouseMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Player1sHous1e"):FireServer(unpack(argsCasa))

    local argsCarro = {
        [1] = "PickingCarMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Player1sCa1r"):FireServer(unpack(argsCarro))

    local argsScooter = {
        [1] = "PickingScooterMusicText",
        [2] = id
    }
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1NoMoto1rVehicle1s"):FireServer(unpack(argsScooter))
end

local function isValidMusicId(value)
    return value and value ~= "" and value ~= "Option 1" and not value:match("novas musica adds") and not value:match("musica brasil") and not value:match("musica do meu interece") and not value:match("musica dls por elas") and not value:match("meme abaixo") and not value:match("estourada")
end

Tab:AddTextBox({
    Name = "ID da música",
    PlaceholderText = "Digite o ID e pressione Enter",
    Callback = function(value)
        if value and value ~= "" then
            tocarMusica(tostring(value))
        end
    end
})

local function createMusicDropdown(title, categorySongs)
    local musicNames = {}
    local musicMap = {}

    for _, music in ipairs(categorySongs or {}) do
        if music.name and music.id then
            local displayName = tostring(music.name)

            if musicMap[displayName] then
                displayName = displayName .. " [" .. tostring(music.id) .. "]"

                local suffix = 2
                while musicMap[displayName] do
                    displayName = tostring(music.name) .. " [" .. tostring(music.id) .. "] (" .. suffix .. ")"
                    suffix = suffix + 1
                end
            end

            table.insert(musicNames, displayName)
            musicMap[displayName] = tostring(music.id)
        end
    end

    Tab:AddDropdown({
        Name = title,
        Description = "all",
        Default = "",
        Multi = false,
        Options = musicNames,

        Callback = function(selectedSound)
            local soundId = musicMap[selectedSound]

            if soundId and soundId ~= "" and soundId ~= "4354908569" then
                tocarMusica(tostring(soundId))
            end
        end
    })
end


local MUSIC_TAB_LIST_URL = "https://raw.githubusercontent.com/Luckzzxw/musicsss/refs/heads/main/musics.lua"

local function loadMusicTabOptions()
    local ok, result = pcall(function()
        local source = game:HttpGet(MUSIC_TAB_LIST_URL)
        local chunk = loadstring(source)

        if not chunk then
            error("Não foi possível compilar a lista de músicas.")
        end

        return chunk()
    end)

    if ok and type(result) == "table" then
        return result
    end

    warn("[Music] Não foi possível carregar a lista remota:", tostring(result))
    return _G.musicOptions or {}
end

local musicTabOptions = loadMusicTabOptions()


local allMusicForTab = {}
local categoryNamesForTab = {}

for category, songs in pairs(musicTabOptions) do
    if type(songs) == "table" then
        table.insert(categoryNamesForTab, tostring(category))

        for _, music in ipairs(songs) do
            if type(music) == "table" and music.name and music.id then
                table.insert(allMusicForTab, {
                    name = tostring(music.name),
                    id = tostring(music.id)
                })
            end
        end
    end
end

table.sort(categoryNamesForTab, function(a, b)
    return string.lower(a) < string.lower(b)
end)


createMusicDropdown("Todas as músicas", allMusicForTab)


for _, categoryName in ipairs(categoryNamesForTab) do
    local songs = musicTabOptions[categoryName]

    if type(songs) == "table" and #songs > 0 then
        local ok, err = pcall(function()
            createMusicDropdown(categoryName, songs)
        end)

        if not ok then
            warn("[Music] Falha ao criar dropdown '" .. categoryName .. "':", tostring(err))
        end
    end
end

Tab:AddParagraph({ "Por nome e id" })

local tempName = nil
local tempId = nil
local favoritesDropdownRef = nil

Tab:AddTextBox({
    Name = "Nome da música",
    PlaceholderText = "ex: funk brabo",
    Callback = function(value)
        tempName = value
    end
})

Tab:AddTextBox({
    Name = "ID da música",
    PlaceholderText = "cole o ID aqui",
    Callback = function(value)
        tempId = value
    end
})
Tab:AddParagraph({ "Salvar" })

Tab:AddButton({
    Name = "Salvar favorito",
    Description = "Salva nome + ID ",
    Callback = function()
        if not tempName or tempName == "" then
            return
        end
        if not tempId or tempId == "" then
            return
        end
        Favorites[tempName] = tostring(tempId)
        saveFavorites()
        print("[Music] Salvo: " .. tempName .. " -> " .. tempId)
    end
})

Tab:AddParagraph({ "Remova com o nome exato" })

Tab:AddTextBox({
    Name = "Remover favorito (nome exato)",
    PlaceholderText = "ex: funk brabo",
    Callback = function(value)
        if value and Favorites[value] then
            Favorites[value] = nil
            saveFavorites()
            print("[Music] Removido: " .. value)
        end
    end
})

Tab:AddParagraph({ "Lista de favoritos" })

do
    local nomes = {}
    for nome, _ in pairs(Favorites) do
        table.insert(nomes, nome)
    end
    table.sort(nomes)

    favoritesDropdownRef = Tab:AddDropdown({
        Name = "Meus Favoritos",
        Description = "clique pra tocar",
        Options = nomes,
        Multi = false,
        Callback = function(escolhido)
            if escolhido and Favorites[escolhido] then
                tocarMusica(tostring(Favorites[escolhido]))
            end
        end
    })
end

Tab:AddParagraph({ "Parar Todas Músicas" })

Tab:AddButton({
    Name = "Stop",
    Description = "ALL music",
    Callback = function()
        tocarMusica("")
    end
})

local Tab = Window:MakeTab({"Rgbs", "brush"})

local rgbSpeed = 1

Tab:AddSlider({
    Name = "Velocidade RGB",
    Description = "Aumenta a velocidade do efeito RGB",
    Min = 1,
    Max = 5,
    Increase = 1,
    Default = 3,
    Callback = function(Value)
        rgbSpeed = Value
    end
})

local function getRainbowColor(speedMultiplier)
    local h = (tick() * speedMultiplier % 5) / 5 
    return Color3.fromHSV(h, 1, 1)
end

local function fireServer(eventName, args)
    local event = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
    if event and event:FindFirstChild(eventName) then
        pcall(function()
            event[eventName]:FireServer(unpack(args))
        end)
    end
end

local Section = Tab:AddSection({"RGB para usar em você"})

local nameBioRGBActive = false
Tab:AddToggle({
    Name = "Nome + Bio RGB",
    Default = false,
    Callback = function(state)
        nameBioRGBActive = state
        if state then
            task.spawn(function()
                while nameBioRGBActive and LocalPlayer.Character do
                    local color = getRainbowColor(rgbSpeed)
                    fireServer("1RPNam1eColo1r", { "PickingRPNameColor", color })
                    fireServer("1RPNam1eColo1r", { "PickingRPBioColor", color })
                    task.wait(0.03)
                end
            end)
        end
    end
})

local isNameActive = false

local isBioActive = false

local SectionRGBName = Tab:AddSection({

    Name = "Name and Bio"

})

Tab:AddToggle({

    Name = "Name RGB",

    Description = "Make the Name colorful",

    Default = false,

    Callback = function(value)
        isNameActive = value

    end

})

Tab:AddToggle({

    Name = "Bio RGB",

    Description = "Make the Bio colorful",

    Default = false,

    Callback = function(value)
        isBioActive = value

    end

})

local vibrantColors = {

    Color3.fromRGB(255, 0, 0),

    Color3.fromRGB(0, 255, 0),

    Color3.fromRGB(0, 0, 255),

    Color3.fromRGB(255, 255, 0),

    Color3.fromRGB(255, 0, 255),

    Color3.fromRGB(0, 255, 255),

    Color3.fromRGB(255, 165, 0),

    Color3.fromRGB(128, 0, 128),

    Color3.fromRGB(255, 20, 147)

}



spawn(function()

    while true do

        if isNameActive then

            local randomColor = vibrantColors[math.random(#vibrantColors)]

            local args = {

                [1] = "PickingRPNameColor",

                [2] = randomColor

            }

            game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eColo1r"):FireServer(unpack(args))

        end

        wait(0.1)

    end

end)



spawn(function()

    while true do

        if isBioActive then

            local randomColor = vibrantColors[math.random(#vibrantColors)]

            local args = {

                [1] = "PickingRPBioColor",

                [2] = randomColor

            }

            game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eColo1r"):FireServer(unpack(args))

        end

        wait(0.1)

    end

end)

Tab:AddSection({

    Name = "others"

})

local ToggleBicicleta = Tab:AddToggle({
    Name = "RGB Bicicleta",
    Description = "RGB na bicicleta",
    Default = false
})
ToggleBicicleta:Callback(function(Value)
    getgenv().rgbBicicleta = Value
    task.spawn(function()
        while getgenv().rgbBicicleta do
            fireServer("1Player1sCa1r", {
                "NoMotorColor",
                getRainbowColor(rgbSpeed)
            })
            task.wait(0.1)
        end
    end)
end)

local radioRGBActive = false
Tab:AddToggle({
    Name = "Rádio RGB",
    Default = false,
    Callback = function(state)
        radioRGBActive = state
        if state then
            task.spawn(function()
                while radioRGBActive and LocalPlayer.Character do
                    local color = getRainbowColor(rgbSpeed)
                    local success, remote = pcall(function()
                        return LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ToolGui"):WaitForChild("ToolSettings"):WaitForChild("Settings"):WaitForChild("PropsColor"):WaitForChild("SetColor")
                    end)
                    if success and remote then
                        pcall(function()
                            remote:FireServer(color)
                        end)
                    end
                    task.wait(0.03)
                end
            end)
        end
    end
})

Tab:AddSection({ "Character" })

local colors = { "Bright red", "Lime green", "Bright blue", "Bright yellow", "Bright cyan", "Hot pink", "Royal purple" }

local rgbEnabled = false



local function changeColor(color)

    local args = { color }

    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeBodyColor"):FireServer(unpack(args))

end



local function toggleRGBCharacter(enabled)

    rgbEnabled = enabled

    if rgbEnabled then

        while rgbEnabled do

            for _, color in ipairs(colors) do

                if not rgbEnabled then return end

                changeColor(color)

                wait(0.5)

            end

        end

    end

end

Tab:AddToggle({

    Name = "RGB Character",

    Description = "Make your character RGB",

    Default = false,

    Callback = function(value)
        toggleRGBCharacter(value)

    end

})

local Tab = Window:MakeTab({"Itens", "swords"})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local RE = ReplicatedStorage:WaitForChild("RE")

local ToolEvent = RE:WaitForChild("1Playe1rTrigge1rEven1t")
local ToolRemote = RE:WaitForChild("1Too1l")

local function CreateToolButton(title, toolName, remoteType)
   Tab:AddButton({
      Title = title,
      Locked = false,
      Callback = function()

        if remoteType == "Function" then
           ToolRemote:InvokeServer(
              "PickingTools",
              toolName
           )

        else
           ToolEvent:FireServer(
              "AcceptedToolToServer",
              toolName,
              LocalPlayer
           )
        end
      end
   })
end

local Tools = {
   {
      Title = "Planador",
      Tool = "Glider"
   },

   {
      Title = "Canhão",
      Tool = "Cannon"
   },

   {
      Title = "Bola de Basquete Dourada",
      Tool = "GoldenBasketball"
   },

   {
      Title = "Balão de Água",
      Tool = "Water Balloon",
      Type = "Function"
   },

   {
      Title = "Lançador de Ovo",
      Tool = "EggLauncher"
   },

   {
      Title = "Cristal Verde",
      Tool = "UraniumRod"
   },

   {
      Title = "Serra Elétrica",
      Tool = "Chainsaw"
   },

   {
      Title = "Ski",
      Tool = "Skis"
   },

   {
      Title = "Money Gun",
      Tool = "MoneyGun"
   },

   {
      Title = "Snowboard",
      Tool = "Snowboard"
   }
}

for _, tool in ipairs(Tools) do
   CreateToolButton(
      tool.Title,
      tool.Tool,
      tool.Type
   )
end

local ScrTab = Window:MakeTab({ "Scripts", "codesandbox" })

ScrTab:AddSection({ "Random Scripts" })

ScrTab:AddButton({
    Name = "Enable Shaders (Irreversible)",
    Callback = function()
        loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/GkhMtEaOCVNAt8EL/raw"))()
    end
})

ScrTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

ScrTab:AddSection({ "Copy Avatar" })

ScrTab:AddButton({
    Name = "Copy Avatar",
    Callback = function()
        loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/xMMxQ3vT0QKKgIRR/raw"))()
    end
})

ScrTab:AddSection({ "Emotes Scripts" })

ScrTab:AddButton({
    Name = "KitK4t Emotes",
    Callback = function()
        loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/qehrlb7Oh8oLOgu3/raw"))()
    end
})

ScrTab:AddButton({
    Name = "Gazes Emotes",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Gaze-stuff/refs/heads/main/Gaze%20emote"))()
    end
})

ScrTab:AddSection({ "Mickey Chat" })

ScrTab:AddButton({
    Name = "Mickey Chat",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gaurav-0196/Mickey-Chat/refs/heads/main/MickeyChat"))()
    end
})

ScrTab:AddSection({ "Scripts" })

ScrTab:AddButton({
    Name = "Jerk r15 and r6",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/FWwdST5Y"))()
    end
})

ScrTab:AddButton({
    Name = "Slayer Fly",
    Callback = function()
        loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/DF5ohwz7Y23VPawx/raw"))()
    end
})

ScrTab:AddButton({
    Name = "Drone do Lyra",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BRENOPOOF/drone/refs/heads/main/Main.txt"))()
    end
})
do
local HouseTab = Window:MakeTab({ "House", "home" })

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Remotes = require(ReplicatedStorage.Packages.Remotes)

local function findAllHouses()
    local houses = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:HasTag("PropertyPermissions") then
            table.insert(houses, obj)
        end
    end
    return houses
end

local function tryBecomeRoommateAll()
    for _, house in ipairs(findAllHouses()) do
        pcall(function()
            Remotes.fireServerComponent(house, "Permissions:AddRoommate", LocalPlayer)
        end)
    end
end

local function tryUnblockAll()
    for _, house in ipairs(findAllHouses()) do
        pcall(function()
            Remotes.invokeServerComponent(house, "Permissions:SetPropPlacementBlockedForOthers", false)
        end)
    end
end

HouseTab:AddSection({ "Bypass Props" })

HouseTab:AddButton({
    Name = "Bypass Props",
    Callback = function()
        task.spawn(function()
            tryBecomeRoommateAll()
            task.wait(0.5)
            tryUnblockAll()
        end)
    end
})

HouseTab:AddSection({ "Remove Ban" })

HouseTab:AddButton({
    Name = "Remove Ban All Houses",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local lots = workspace:FindFirstChild("001_Lots")
                if lots then
                    for _, obj in ipairs(lots:GetDescendants()) do
                        if obj.Name == "BannedBlock" then
                            pcall(function()
                                obj:Destroy()
                            end)
                        end
                    end
                end
            end)

            pcall(function()
                for _, child in ipairs(workspace:GetChildren()) do
                    if child.Name == "LotLazyLoadingTriggerAreas" then
                        pcall(function()
                            child:Destroy()
                        end)
                    end
                end
            end)
        end)
    end
})
end

local Tab13 = Window:MakeTab({"Protections", "shield"})

local lp = game:GetService("Players").LocalPlayer
local xy

local a = {}
local b
local function c(d)
    pcall(function()
        if d:IsA("BasePart") and not d.Anchored and not a[d] then
            a[d] = true
            d.CanCollide = false
        end
    end)
end

local function e()
    pcall(function()
        for _, f in ipairs(workspace:GetDescendants()) do
            c(f)
        end
        b = workspace.DescendantAdded:Connect(function(f)
            c(f)
        end)
    end)
end

local function g()
    pcall(function()
        if b then b:Disconnect() b = nil end
        for d in pairs(a) do
            if d and d.Parent then
                d.CanCollide = true
            end
        end
        a = {}
    end)
end

function EnableAntiSit()
    pcall(function()
        local function zq()
            local aa = lp.Character or lp.CharacterAdded:Wait()
            local bb = aa:WaitForChild("Humanoid")
            bb:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end
        zq()
        xy = lp.CharacterAdded:Connect(function()
            zq()
        end)
    end)
end

function DisableAntiSit()
    pcall(function()
        if xy then
            xy:Disconnect()
            xy = nil
        end
        local cc = lp.Character
        if cc and cc:FindFirstChild("Humanoid") then
            cc.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        end
    end)
end

local function EnableAntiCrash()
    pcall(function()
        local bulletScript = lp.PlayerScripts:FindFirstChild("BulletVisualizerScript")
        if bulletScript then
            bulletScript.Disabled = true
        end
    end)
end

local function DisableAntiCrash()
    pcall(function()
        local bulletScript = lp.PlayerScripts:FindFirstChild("BulletVisualizerScript")
        if bulletScript then
            bulletScript.Disabled = false
        end
    end)
end

local function EnableAntiVoid()
    pcall(function()
        workspace.FallenPartsDestroyHeight = 0/0 
    end)
end

local function DisableAntiVoid()
    pcall(function()
        workspace.FallenPartsDestroyHeight = -500
    end)
end

local AntiLagServerEnabled = false

local function DeleteDupeTools(player)
    pcall(function()
        local backpack = player:FindFirstChildOfClass("Backpack")
        local char = player.Character
        if not (backpack or char) then return end
        local containers = {backpack, char}
        local count = {}
        
        for _, container in ipairs(containers) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        count[tool.Name] = (count[tool.Name] or 0) + 1
                    end
                end
            end
        end
        
        for toolName, num in pairs(count) do
            if num >= 5 then
                local toDelete = num - 1
                for _, container in ipairs(containers) do
                    if container then
                        for _, tool in ipairs(container:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name == toolName and toDelete > 0 then
                                tool:Destroy()
                                toDelete = toDelete - 1
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function MonitorPlayer(player)
    pcall(function()
        local function watchContainer(container)
            container.ChildAdded:Connect(function(child)
                if AntiLagServerEnabled and child:IsA("Tool") then
                    DeleteDupeTools(player)
                end
            end)
        end
        
        local function setupCharacter(char)
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then watchContainer(backpack) end
            watchContainer(char)
        end
        
        player.CharacterAdded:Connect(setupCharacter)
        if player.Character then setupCharacter(player.Character) end
    end)
end

for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
    MonitorPlayer(p)
end

game:GetService("Players").PlayerAdded:Connect(MonitorPlayer)

if Tab13 then
    Tab13:AddSection("Proteções")
    
    Tab13:AddToggle({
        Name = "Anti Collision",
        Default = false,
        Callback = function(Value)
            pcall(function()
                if Value then
                    e()
                else
                    g()
                end
            end)
        end
    })
    
    Tab13:AddToggle({
        Name = "Anti Sit",
        Default = false,
        Callback = function(Value)
            pcall(function()
                if Value then
                    EnableAntiSit()
                else
                    DisableAntiSit()
                end
            end)
        end
    })
    
    Tab13:AddToggle({
        Name = "Anti Crash",
        Default = false,
        Callback = function(Value)
            pcall(function()
                if Value then
                    EnableAntiCrash()
                else
                    DisableAntiCrash()
                end
            end)
        end
    })
    
    Tab13:AddToggle({
        Name = "Anti Void",
        Default = false,
        Callback = function(Value)
            pcall(function()
                if Value then
                    EnableAntiVoid()
                else
                    DisableAntiVoid()
                end
            end)
        end
    })
    
    Tab13:AddToggle({
        Name = "Anti Lag Server",
        Default = false,
        Callback = function(Value)
            pcall(function()
                AntiLagServerEnabled = Value
            end)
        end
    })
end
local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local backupTables = {
    Vehicles = {},
    Canoes = {},
    Jets = {},
    Helis = {},
    Balls = {}
}

local TeleportCarro = {}
function TeleportCarro:MostrarNotificacao(msg)
end

local function AntiFlingLoop(name, getFolderFunc)
    local active = false
    task.spawn(function()
        while true do
            if active and LocalPlayer.Character then
                local folder = getFolderFunc()
                if folder then
                    for _, item in ipairs(folder:GetChildren()) do
                        local isMine = false
                        if name == "Vehicles" then
                            for _, seat in ipairs(item:GetDescendants()) do
                                if (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and seat.Occupant and seat.Occupant.Parent == LocalPlayer.Character then
                                    isMine = true
                                    break
                                end
                            end
                        elseif name == "Canoes" then
                            local owner = item:FindFirstChild("Owner")
                            isMine = owner and owner.Value == LocalPlayer
                        elseif name == "Jets" or name == "Helis" then
                            isMine = item.Name == LocalPlayer.Name
                        end
                        if not isMine then
                            table.insert(backupTables[name], item:Clone())
                            item:Destroy()
                        end
                    end
                end
            end
            task.wait(0.03)
        end
    end)
    return function(state)
        active = state
        TeleportCarro:MostrarNotificacao(name.." "..(state and "ativado!" or "desativado!"))
        if not state then
            for _, item in ipairs(backupTables[name]) do
                local parentFolder = getFolderFunc()
                if parentFolder then item.Parent = parentFolder end
            end
            backupTables[name] = {}
        end
    end
end

Tab13:AddToggle({
    Name = "Anti Scripters (2)",
    Default = false,
    Callback = AntiFlingLoop("Vehicles", function()
        return Workspace:FindFirstChild("Vehicles")
    end)
})

Tab13:AddToggle({
    Name = "Anti Fling Canoes (2)",
    Default = false,
    Callback = AntiFlingLoop("Canoes", function()
        local workspaceCom = Workspace:FindFirstChild("WorkspaceCom")
        return workspaceCom and workspaceCom:FindFirstChild("001_CanoeStorage")
    end)
})

Tab13:AddToggle({
    Name = "Anti Fling Jatinhos e outros (2)",
    Default = false,
    Callback = AntiFlingLoop("Jets", function()
        local folder = Workspace:FindFirstChild("WorkspaceCom")
        if folder and folder:FindFirstChild("001_Airport") then
            local storage = folder["001_Airport"]:FindFirstChild("AirportHanger")
            if storage then return storage:FindFirstChild("001_JetStorage") and storage["001_JetStorage"]:FindFirstChild("JetAirport") end
        end
    end)
})

Tab13:AddToggle({
    Name = "Anti Fling Helicopteros (2)",
    Default = false,
    Callback = AntiFlingLoop("Helis", function()
        local folder = Workspace:FindFirstChild("WorkspaceCom")
        return folder and folder:FindFirstChild("001_HeliStorage") and folder["001_HeliStorage"]:FindFirstChild("PoliceStationHeli")
    end)
})

Tab13:AddToggle({
    Name = "Anti Fling Ball (2)",
    Default = false,
    Callback = AntiFlingLoop("Balls", function()
        local folder = Workspace:FindFirstChild("WorkspaceCom")
        return folder and folder:FindFirstChild("001_SoccerBalls")
    end)
})

local antiSitActive = false
Tab13:AddToggle({
    Name = "Anti Sit (2)",
    Default = false,
    Callback = function(state)
        antiSitActive = state
        TeleportCarro:MostrarNotificacao("Anti Sit "..(state and "ativado!" or "desativado!"))
        task.spawn(function()
            while antiSitActive and LocalPlayer.Character do
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    if humanoid:GetState() == Enum.HumanoidStateType.Seated then
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                task.wait(0.05)
            end
            if not antiSitActive then
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                end
            end
        end)
    end
})


Tab13:AddToggle({
    Name = "Ant Doors (2)",
    Default = false,
    Callback = function(state)
        if not _G.hiddenDoors then _G.hiddenDoors = {} end
        if state then
            _G.hiddenDoors = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("door") then
                    local doorData = {
                        door = obj,
                        originalTransparency = obj.Transparency,
                        originalCanCollide = obj.CanCollide,
                        originalCastShadow = obj.CastShadow
                    }
                    obj.Transparency = 1
                    obj.CanCollide = false
                    obj.CastShadow = false
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BasePart") then
                            child.Transparency = 1
                            child.CanCollide = false
                        elseif child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
                            child.Enabled = false
                        end
                    end
                    table.insert(_G.hiddenDoors, doorData)
                end
            end
        else
            for _, doorData in ipairs(_G.hiddenDoors or {}) do
                if doorData.door and doorData.door.Parent then
                    doorData.door.Transparency = doorData.originalTransparency
                    doorData.door.CanCollide = doorData.originalCanCollide
                    doorData.door.CastShadow = doorData.originalCastShadow
                    for _, child in ipairs(doorData.door:GetChildren()) do
                        if child:IsA("BasePart") then
                            child.Transparency = 0
                            child.CanCollide = true
                        elseif child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
                            child.Enabled = true
                        end
                    end
                end
            end
            _G.hiddenDoors = {}
        end
    end
})

Tab13:AddToggle({
    Name = "Ant Banana",
    Default = false,
    Callback = function(state)
        if state then
            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")

            local player = Players.LocalPlayer
            local playerName = player.Name

            local CONFIG = {
                BLOCK_OTHERS_ONLY = true,
                ALLOW_SELF = true,
                REMOVE_EXISTING = true,
                PREVENT_NEW = true,
                SWEEP_INTERVAL = 5,
                MAX_DESCENDANTS = 5000,
                USE_CACHE = true,
            }

            local checkedCache = {}
            local cacheSize = 0
            local MAX_CACHE = 1000

            local function addToCache(instance)
                if not CONFIG.USE_CACHE then return end
                if cacheSize >= MAX_CACHE then
                    checkedCache = {}
                    cacheSize = 0
                end
                checkedCache[instance] = true
                cacheSize = cacheSize + 1
            end

            local function isCached(instance)
                if not CONFIG.USE_CACHE then return false end
                return checkedCache[instance] == true
            end

            local function isBananaRelated(instance)
                if not instance or not instance.Name then
                    return false
                end
                local name = instance.Name
                if string.find(name, "Banana") or string.find(name, "banana") then
                    return true
                end
                if instance:HasTag("Minions2026_BananaPeel") then
                    return true
                end
                return false
            end

            local function isFromLocalPlayer(instance)
                if instance.Name and string.find(instance.Name, playerName) then
                    return true
                end
                local character = player.Character
                if character and instance:IsDescendantOf(character) then
                    return true
                end
                local backpack = player:FindFirstChild("Backpack")
                if backpack and instance:IsDescendantOf(backpack) then
                    return true
                end
                return false
            end

            local function destroyOtherPlayerBanana(instance)
                if not instance or not instance.Parent then
                    return
                end
                if isCached(instance) then
                    return
                end
                if not isBananaRelated(instance) then
                    return
                end
                if isFromLocalPlayer(instance) then
                    return
                end
                addToCache(instance)
                pcall(function()
                    instance:Destroy()
                end)
            end

            local function sweepOtherPlayerBananas()
                for _, descendant in ipairs(Workspace:GetChildren()) do
                    destroyOtherPlayerBanana(descendant)
                    for _, child in ipairs(descendant:GetChildren()) do
                        destroyOtherPlayerBanana(child)
                    end
                end
            end

            local connections = {}

            table.insert(connections, Workspace.ChildAdded:Connect(function(child)
                if CONFIG.PREVENT_NEW then
                    task.defer(function()
                        destroyOtherPlayerBanana(child)
                    end)
                end
            end))

            table.insert(connections, Players.PlayerAdded:Connect(function(otherPlayer)
                if otherPlayer == player then return end
                table.insert(connections, otherPlayer.CharacterAdded:Connect(function(character)
                    table.insert(connections, character.ChildAdded:Connect(function(child)
                        if CONFIG.PREVENT_NEW then
                            task.defer(function()
                                destroyOtherPlayerBanana(child)
                            end)
                        end
                    end))
                end))
            end))

            if CONFIG.REMOVE_EXISTING then
                sweepOtherPlayerBananas()
            end

            local sweepThread = task.spawn(function()
                while true do
                    task.wait(CONFIG.SWEEP_INTERVAL)
                    sweepOtherPlayerBananas()
                end
            end)

            _G.BananaBlocker = {
                CONFIG = CONFIG,
                Connections = connections,
                SweepThread = sweepThread,
                Sweep = sweepOtherPlayerBananas,
                Status = function()
                    return CONFIG
                end,
                Unblock = function()
                    CONFIG.PREVENT_NEW = false
                    CONFIG.REMOVE_EXISTING = false
                end,
                ClearCache = function()
                    checkedCache = {}
                    cacheSize = 0
                end,
            }
        else
            if _G.BananaBlocker then
                _G.BananaBlocker.Unblock()

                for _, conn in ipairs(_G.BananaBlocker.Connections or {}) do
                    pcall(function()
                        conn:Disconnect()
                    end)
                end

                if _G.BananaBlocker.SweepThread then
                    pcall(function()
                        task.cancel(_G.BananaBlocker.SweepThread)
                    end)
                end

                _G.BananaBlocker = nil
            end
        end
    end
})
do
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

Tab13:AddSection("Anti Exploiter (Cliente)")

local selectedAntiTarget = nil
local selectedAntiType = "Username"
local nickManual = ""

local function getAntiPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local antiDropdown = Tab13:AddDropdown({
    Name = "Selecionar Player",
    Options = getAntiPlayerList(),
    Default = "",
    Callback = function(value)
        selectedAntiTarget = (value and value ~= "") and value or nil
    end
})

Tab13:AddDropdown({
    Name = "Tipo",
    Options = { "Nome completo do player", "Nome de exibição do player", "Ou os dois" },
    Default = "Nome completo do player",
    Callback = function(value)
        if value == "Nome de exibição do player" then
            selectedAntiType = "DisplayName"
        elseif value == "Ou os dois" then
            selectedAntiType = "Both"
        else
            selectedAntiType = "Username"
        end
    end
})

Tab13:AddTextBox({
    Name = "Nick manual (opcional)",
    PlaceholderText = "Digite o nick...",
    Callback = function(text)
        nickManual = text or ""
    end
})

Tab13:AddButton({
    Name = "Atualizar Lista",
    Callback = function()
        if not antiDropdown then return end
        local newPlayers = getAntiPlayerList()
        pcall(function() antiDropdown:Refresh(newPlayers) end)
        selectedAntiTarget = nil
    end
})

local alvoLower = nil
local typeMode = "Username"

local function contemNome(nome)
    if typeof(nome) ~= "string" or not alvoLower then return false end
    return string.find(string.lower(nome), alvoLower, 1, true) ~= nil
end

local fila = {}
local processando = false

local function processarFila()
    if processando then return end
    processando = true
    task.spawn(function()
        while #fila > 0 do
            local obj = table.remove(fila, 1)
            if obj and obj.Parent and contemNome(obj.Name) then
                obj:Destroy()
            end
            if #fila % 50 == 0 then
                task.wait()
            end
        end
        processando = false
    end)
end

local function enfileirar(obj)
    table.insert(fila, obj)
    processarFila()
end

local conexaoDescendant = nil

local function varrerInicial()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if contemNome(obj.Name) then
            obj:Destroy()
        end
    end
end

Tab13:AddButton({
    Name = "Ant Exploiter (aplicar)",
    Callback = function()
        local alvoNome = (nickManual ~= "" and nickManual) or selectedAntiTarget
        if not alvoNome or alvoNome == "" then
            return
        end
        if conexaoDescendant then conexaoDescendant:Disconnect(); conexaoDescendant = nil end
        fila = {}
        alvoLower = string.lower(alvoNome)
        typeMode = selectedAntiType
        varrerInicial()
        conexaoDescendant = Workspace.DescendantAdded:Connect(function(obj)
            if contemNome(obj.Name) then
                enfileirar(obj)
            end
        end)
    end
})
end

local TabAvatar = Window:MakeTab({"Avatar", "star"})
do
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local WearRemote = Remotes:WaitForChild("Wear")
local WearShirtRemote = Remotes:WaitForChild("WearShirt")
local WearPantsRemote = Remotes:WaitForChild("WearPants")
local REFolder = ReplicatedStorage:WaitForChild("RE")
local RPTextRemote = REFolder:WaitForChild("1RPNam1eTex1t")
local RPColorRemote = REFolder:WaitForChild("1RPNam1eColo1r")

local URL_CORPOS = "https://raw.githubusercontent.com/XuungMath20/corpos/refs/heads/main/corpos.json"

local Target = nil
local SelectedBody = nil
local atualizandoLista = false

local bodyCache = {}
local nomesCorpos = {}

pcall(function()
    local raw = game:HttpGet(URL_CORPOS, true)
    bodyCache = HttpService:JSONDecode(raw)
    for k, _ in pairs(bodyCache) do
        table.insert(nomesCorpos, k)
    end
    table.sort(nomesCorpos)
end)

local function GetPlayerNames()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name ~= LP.Name then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local function CapturarDadosCompletos(charObj)
    local Character = charObj
    local Humanoid = Character:WaitForChild("Humanoid", 2)
    if not Humanoid then return nil end
    local Desc = Humanoid:GetAppliedDescription()

    local data = {
        shirt = tonumber(Desc.Shirt) or 0,
        pants = tonumber(Desc.Pants) or 0,
        tshirt = tonumber(Desc.GraphicTShirt) or 0,
        face = tonumber(Desc.Face) or 0,
        idle = tonumber(Desc.IdleAnimation) or 0,
        walk = tonumber(Desc.WalkAnimation) or 0,
        run = tonumber(Desc.RunAnimation) or 0,
        jump = tonumber(Desc.JumpAnimation) or 0,
        fall = tonumber(Desc.FallAnimation) or 0,
        climb = tonumber(Desc.ClimbAnimation) or 0,
        swim = tonumber(Desc.SwimAnimation) or 0
    }

    local accs = {}
    for _, v in ipairs(Desc:GetAccessories(true)) do
        local id = tonumber(v.AssetId)
        if id and id > 0 then table.insert(accs, id) end
    end
    
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Accessory") then
            if child:FindFirstChild("AssetId") then
                local id = tonumber(child.AssetId.Value)
                if id and id > 0 then
                    table.insert(accs, id)
                end
            end
            local handle = child:FindFirstChild("Handle")
            if handle then
                for _, mesh in ipairs(handle:GetDescendants()) do
                    if mesh:IsA("SpecialMesh") or mesh:IsA("BlockMesh") or mesh:IsA("CylinderMesh") then
                        if mesh.MeshId and mesh.MeshId ~= "" then
                            local id = tonumber(string.match(mesh.MeshId, "(%d+)"))
                            if id and id > 0 then
                                table.insert(accs, id)
                            end
                        end
                    end
                end
            end
        end
    end

    local uniqueAccs = {}
    local finalAccs = {}
    for _, id in ipairs(accs) do
        if not uniqueAccs[id] then
            uniqueAccs[id] = true
            table.insert(finalAccs, id)
        end
    end
    accs = finalAccs

    local skinColor = "Bright yellow"
    if Character:FindFirstChild("Body Colors") then
        skinColor = tostring(Character["Body Colors"].HeadColor)
    end

    return {
        data = data,
        accs = accs,
        skin = skinColor,
        body = { tonumber(Desc.Torso) or 0, tonumber(Desc.RightArm) or 0, tonumber(Desc.LeftArm) or 0, tonumber(Desc.RightLeg) or 0, tonumber(Desc.LeftLeg) or 0, tonumber(Desc.Head) or 0 }
    }
end

TabAvatar:AddSection("Copiar Avatar de outro jogador")

TabAvatar:AddDropdown({
    Name = "Tipo de Corpo",
    Options = nomesCorpos,
    Default = nomesCorpos[1],
    Callback = function(option)
        SelectedBody = bodyCache[option]
    end
})

local PlayerDropdown = TabAvatar:AddDropdown({
    Name = "Players List",
    Options = GetPlayerNames(),
    Default = "",
    Callback = function(playername)
        if atualizandoLista then return end
        Target = playername
    end
})

TabAvatar:AddButton({
    Name = "Atualizar lista",
    Callback = function()
        pcall(function()
            if not PlayerDropdown then return end
            atualizandoLista = true
            local novosJogadores = GetPlayerNames()
            pcall(function() PlayerDropdown:Refresh(novosJogadores) end)
            Target = nil
            atualizandoLista = false
        end)
    end
})

TabAvatar:AddButton({
    Name = "Copy Avatar",
    Callback = function()
        if not Target then return end
        if not SelectedBody then
            SelectedBody = bodyCache[nomesCorpos[1]]
        end

        local TPlayer = Players:FindFirstChild(Target)

        if TPlayer and TPlayer.Character then
            local pacote = CapturarDadosCompletos(TPlayer.Character)
            if not pacote then return end

            local function ForceEquip(remote, id)
                if not id or id <= 0 then return end
                pcall(function() remote:InvokeServer(id) end)
                task.wait(2.15)
            end

            pcall(function()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Status",
                    Text = "Copiando skin de " .. TPlayer.Name,
                    Duration = 3
                })
            end)

            local argsLoad = { "Load", SelectedBody }
            pcall(function() Remotes:WaitForChild("AvatarEditorOutfitCodes"):InvokeServer(unpack(argsLoad)) end)
            task.wait(2.15)

            pcall(function() Remotes.ChangeCharacterBody:InvokeServer(pacote.body) end)
            task.wait(2.15)

            pcall(function() Remotes.ChangeBodyColor:FireServer(pacote.skin) end)
            task.wait(2.15)

            ForceEquip(WearShirtRemote, pacote.data.shirt)
            ForceEquip(WearPantsRemote, pacote.data.pants)
            ForceEquip(WearRemote, pacote.data.tshirt)
            ForceEquip(WearRemote, pacote.data.face)

            for _, id in ipairs(pacote.accs) do
                ForceEquip(WearRemote, id)
            end

            local anims = {
                pacote.data.idle, pacote.data.walk, pacote.data.run,
                pacote.data.jump, pacote.data.fall, pacote.data.climb, pacote.data.swim
            }
            for _, id in ipairs(anims) do
                ForceEquip(WearRemote, id)
            end

            local Bag = TPlayer:FindFirstChild("PlayersBag")
            if Bag then
                task.spawn(function()
                    if Bag:FindFirstChild("RPName") and Bag.RPName.Value ~= "" then
                        pcall(function() RPTextRemote:FireServer("RolePlayName", Bag.RPName.Value) end)
                    end
                    if Bag:FindFirstChild("RPBio") and Bag.RPBio.Value ~= "" then
                        pcall(function() RPTextRemote:FireServer("RolePlayBio", Bag.RPBio.Value) end)
                    end
                    if Bag:FindFirstChild("RPNameColor") then
                        pcall(function() RPColorRemote:FireServer("PickingRPNameColor", Bag.RPNameColor.Value) end)
                    end
                    if Bag:FindFirstChild("RPBioColor") then
                        pcall(function() RPColorRemote:FireServer("PickingRPBioColor", Bag.RPBioColor.Value) end)
                    end
                end)
            end

            pcall(function()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sucesso",
                    Text = "Avatar copiado com sucesso! (" .. #pacote.accs .. " acessórios)",
                    Duration = 5
                })
            end)
        end
    end
})
end
do
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Remotes = require(ReplicatedStorage.Packages.Remotes)
    local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)

    local MAX_SLOTS = 500
    local START_SLOT = 26
    local MAX_NAME_LENGTH = 15
    local OUTFITS_FILE = "outfits_saved.json"

    local outfitsData = {}
    local currentSlot = nil
    local currentName = ""
    local deleteName = ""
    local quantidadeSlots = 100

    local function loadFromFile()
        if not (isfile and readfile) then return {} end
        if not isfile(OUTFITS_FILE) then return {} end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(OUTFITS_FILE))
        end)
        if ok and type(data) == "table" then
            return data
        end
        return {}
    end

    local function saveToFile()
        if not writefile then return end
        local ok, json = pcall(function()
            return HttpService:JSONEncode(outfitsData)
        end)
        if ok then
            pcall(writefile, OUTFITS_FILE, json)
        end
    end

    outfitsData = loadFromFile()

    local function getSlotName(slot)
        return outfitsData[tostring(slot)] or ""
    end

    local function setSlotName(slot, name)
        outfitsData[tostring(slot)] = name
        saveToFile()
    end

    local function clearSlotName(slot)
        outfitsData[tostring(slot)] = nil
        saveToFile()
    end

    local function getFirstFreeSlot()
        for i = START_SLOT, START_SLOT + quantidadeSlots - 1 do
            if getSlotName(i) == "" then
                return i
            end
        end
        return nil
    end

    local function findSlotByName(name)
        for i = START_SLOT, START_SLOT + quantidadeSlots - 1 do
            if getSlotName(i) == name then
                return i
            end
        end
        return nil
    end

    local function getSavedSlotList()
        local list = {}
        for i = START_SLOT, MAX_SLOTS do
            local name = getSlotName(i)
            if name ~= "" then
                table.insert(list, "Slot " .. i .. ": " .. name)
            end
        end
        return list
    end

    local function saveOutfit(slot, name)
        if slot < 1 or slot > MAX_SLOTS then return false end
        if #name > MAX_NAME_LENGTH then
            name = name:sub(1, MAX_NAME_LENGTH)
        end

        local success = Remotes.invokeServer(AvatarEditorRequests.SAVE_OUTFIT, slot, name)
        if success then
            setSlotName(slot, name)
        end
        return success
    end

    local function loadOutfit(slot)
        if slot < 1 or slot > MAX_SLOTS then return false end
        return Remotes.invokeServer(AvatarEditorRequests.LOAD_OUTFIT, slot)
    end

    local function renameOutfit(slot, newName)
        if slot < 1 or slot > MAX_SLOTS then return false end
        if #newName > MAX_NAME_LENGTH then
            newName = newName:sub(1, MAX_NAME_LENGTH)
        end

        local success, _, finalName = Remotes.invokeServer(AvatarEditorRequests.RENAME_SAVED_SLOT, slot, newName)
        if success then
            setSlotName(slot, finalName or newName)
        end
        return success
    end

    local function deleteOutfit(slot)
        if slot < 1 or slot > MAX_SLOTS then return false end
        local success = renameOutfit(slot, "")
        if success then
            clearSlotName(slot)
        end
        return success
    end

    task.spawn(function()
        pcall(function()
            Remotes.connect(AvatarEditorRequests.LOAD_SAVED_SLOTS, function(slots)
                if type(slots) == "table" then
                    for slot, name in pairs(slots) do
                        local slotNum = tonumber(slot)
                        if slotNum and slotNum >= START_SLOT and name and name ~= "" then
                            outfitsData[tostring(slot)] = tostring(name)
                        end
                    end
                    saveToFile()
                end
            end)

            Remotes.fireServer(AvatarEditorRequests.LOAD_SAVED_SLOTS)
        end)
    end)

    local slotDropdown

    local function refreshSlotDropdown()
        if not slotDropdown then return end
        local options = getSavedSlotList()
        pcall(function() slotDropdown:Refresh(options) end)
        pcall(function() slotDropdown:Set(options) end)
    end

    TabAvatar:AddSection("Save Skins")

    TabAvatar:AddTextBox({
        Name = "Quantidade de Slots",
        PlaceholderText = "ex: 100",
        Default = "100",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 and num <= MAX_SLOTS then
                quantidadeSlots = math.floor(num)
            end
        end
    })

    TabAvatar:AddButton({
        Name = "Remover Todos os Slots do Jogo",
        Callback = function()
            task.spawn(function()
                for slot = 1, MAX_SLOTS do
                    pcall(function()
                        Remotes.invokeServer(AvatarEditorRequests.RENAME_SAVED_SLOT, slot, "")
                    end)
                    outfitsData[tostring(slot)] = nil
                    task.wait(0.05)
                end
                saveToFile()
                refreshSlotDropdown()
            end)
        end
    })

    slotDropdown = TabAvatar:AddDropdown({
        Name = "Outfit Salvo",
        Options = getSavedSlotList(),
        Default = "",
        Callback = function(value)
            if value and value ~= "" then
                local num = tonumber(value:match("Slot (%d+):"))
                if num then
                    currentSlot = num
                end
            else
                currentSlot = nil
            end
        end
    })

    TabAvatar:AddTextBox({
        Name = "Nome do Outfit",
        PlaceholderText = "ex: Casual",
        Callback = function(text)
            currentName = text or ""
        end
    })

    TabAvatar:AddButton({
        Name = "Salvar Outfit",
        Callback = function()
            if currentName == "" then return end

            local slot = getFirstFreeSlot()
            if not slot then return end

            saveOutfit(slot, currentName)
            task.wait(0.2)
            refreshSlotDropdown()
        end
    })

    TabAvatar:AddButton({
        Name = "Carregar Skin",
        Callback = function()
            if not currentSlot then return end
            loadOutfit(currentSlot)
        end
    })

    TabAvatar:AddButton({
        Name = "Renomear Skin",
        Callback = function()
            if not currentSlot then return end
            if currentName == "" then return end
            renameOutfit(currentSlot, currentName)
            task.wait(0.2)
            refreshSlotDropdown()
        end
    })

    TabAvatar:AddTextBox({
        Name = "Deletar (nome exato)",
        PlaceholderText = "digite o nome da skin",
        Callback = function(text)
            deleteName = text or ""
        end
    })

    TabAvatar:AddButton({
        Name = "Deletar Skin",
        Callback = function()
            if deleteName == "" then return end
            local slot = findSlotByName(deleteName)
            if not slot then return end
            deleteOutfit(slot)
            task.wait(0.2)
            refreshSlotDropdown()
        end
    })

    TabAvatar:AddButton({
        Name = "Atualizar Lista",
        Callback = function()
            pcall(function()
                Remotes.fireServer(AvatarEditorRequests.LOAD_SAVED_SLOTS)
            end)
            task.wait(0.3)
            refreshSlotDropdown()
        end
    })

    TabAvatar:AddButton({
        Name = "Limpar Todos os Slots",
        Callback = function()
            task.spawn(function()
                for slot = 1, MAX_SLOTS do
                    pcall(function()
                        Remotes.invokeServer(AvatarEditorRequests.RENAME_SAVED_SLOT, slot, "")
                    end)
                    clearSlotName(slot)
                    task.wait(0.05)
                end
                saveToFile()
                refreshSlotDropdown()
            end)
        end
    })
end

TabAvatar:AddSection("Ver ids das skins do povo")

TabAvatar:AddButton({
    Name = "Ver ids do povo",
        Callback = function()
           local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local IMAGE_BACKGROUND = "rbxassetid://97651093276695"
local SEARCH_ICON = "rbxassetid://79859235777238"

local COLOR_HUB_1 = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(5, 0, 0)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(20, 0, 0)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(5, 0, 0))
})
local COLOR_HUB_2 = Color3.fromRGB(8, 0, 0)
local COLOR_STROKE = Color3.fromRGB(220, 20, 30)
local COLOR_THEME = Color3.fromRGB(255, 40, 40)
local COLOR_TEXT = Color3.fromRGB(255, 230, 230)
local COLOR_DARK_TEXT = Color3.fromRGB(200, 120, 120)
local COLOR_ELEMENT = Color3.fromRGB(15, 0, 0)
local COLOR_ELEMENT_STROKE = Color3.fromRGB(180, 20, 20)

local old = PlayerGui:FindFirstChild("PlayerCatalog")
if old then
    old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerCatalog"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.42, 0, 0.72, 0)
Main.Position = UDim2.new(0.29, 0, 0.14, 0)
Main.BackgroundColor3 = COLOR_HUB_2
Main.BackgroundTransparency = 0
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local Scale = Instance.new("UIScale")
Scale.Parent = Main

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    Scale.Scale = math.clamp(math.min(viewport.X / 1100, viewport.Y / 800), 0.42, 1)
end

updateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local Background = Instance.new("ImageLabel")
Background.Name = "Background"
Background.Size = UDim2.fromScale(1, 1)
Background.Position = UDim2.fromScale(0, 0)
Background.BackgroundColor3 = COLOR_HUB_2
Background.BackgroundTransparency = 0
Background.BorderSizePixel = 0
Background.Image = IMAGE_BACKGROUND
Background.ImageTransparency = 0
Background.ScaleType = Enum.ScaleType.Crop
Background.ZIndex = 1
Background.Parent = Main

local BackgroundCorner = Instance.new("UICorner")
BackgroundCorner.CornerRadius = UDim.new(0, 16)
BackgroundCorner.Parent = Background

local DarkOverlay = Instance.new("Frame")
DarkOverlay.Name = "DarkOverlay"
DarkOverlay.Size = UDim2.fromScale(1, 1)
DarkOverlay.Position = UDim2.fromScale(0, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkOverlay.BackgroundTransparency = 0.55
DarkOverlay.BorderSizePixel = 0
DarkOverlay.ZIndex = 2
DarkOverlay.Parent = Main

local DarkOverlayCorner = Instance.new("UICorner")
DarkOverlayCorner.CornerRadius = UDim.new(0, 16)
DarkOverlayCorner.Parent = DarkOverlay

local Border = Instance.new("UIStroke")
Border.Color = COLOR_STROKE
Border.Thickness = 1.5
Border.Transparency = 0.15
Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Border.Parent = Main

local Header = Instance.new("TextLabel")
Header.Name = "Title"
Header.Size = UDim2.new(1, -76, 0, 28)
Header.Position = UDim2.new(0, 12, 0, 8)
Header.BackgroundTransparency = 1
Header.Text = "Avatar Store IDs"
Header.TextColor3 = COLOR_TEXT
Header.Font = Enum.Font.Gotham
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.ZIndex = 4
Header.Parent = Main

local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.Size = UDim2.fromOffset(22, 22)
Minimize.Position = UDim2.new(1, -56, 0, 8)
Minimize.BackgroundColor3 = COLOR_ELEMENT
Minimize.BackgroundTransparency = 0.2
Minimize.Text = "−"
Minimize.TextColor3 = COLOR_TEXT
Minimize.TextSize = 14
Minimize.Font = Enum.Font.GothamBold
Minimize.ZIndex = 5
Minimize.Parent = Main

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = Minimize

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Color = COLOR_ELEMENT_STROKE
MinimizeStroke.Thickness = 1
MinimizeStroke.Transparency = 0.3
MinimizeStroke.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Size = UDim2.fromOffset(22, 22)
Close.Position = UDim2.new(1, -30, 0, 8)
Close.BackgroundColor3 = COLOR_ELEMENT
Close.BackgroundTransparency = 0.2
Close.Text = "X"
Close.TextColor3 = COLOR_TEXT
Close.TextSize = 11
Close.Font = Enum.Font.Gotham
Close.ZIndex = 5
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = COLOR_ELEMENT_STROKE
CloseStroke.Thickness = 1
CloseStroke.Transparency = 0.3
CloseStroke.Parent = Close

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -42)
Content.Position = UDim2.new(0, 0, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ZIndex = 3
Content.Parent = Main

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "ObjectSearch"
SearchBox.Size = UDim2.new(1, -60, 0, 28)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundColor3 = COLOR_ELEMENT
SearchBox.BackgroundTransparency = 0.2
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "Nome do jogador (vazio = todos)"
SearchBox.PlaceholderColor3 = COLOR_DARK_TEXT
SearchBox.Text = ""
SearchBox.TextColor3 = COLOR_TEXT
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 4
SearchBox.Parent = Content

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = COLOR_ELEMENT_STROKE
SearchStroke.Thickness = 1
SearchStroke.Transparency = 0.3
SearchStroke.Parent = SearchBox

local SearchButton = Instance.new("ImageButton")
SearchButton.Name = "SearchButton"
SearchButton.Size = UDim2.fromOffset(28, 28)
SearchButton.Position = UDim2.new(1, -40, 0, 0)
SearchButton.BackgroundColor3 = COLOR_ELEMENT
SearchButton.BackgroundTransparency = 0.15
SearchButton.Image = SEARCH_ICON
SearchButton.ScaleType = Enum.ScaleType.Fit
SearchButton.ImageColor3 = COLOR_THEME
SearchButton.ZIndex = 5
SearchButton.Parent = Content

local SearchCorner2 = Instance.new("UICorner")
SearchCorner2.CornerRadius = UDim.new(0, 8)
SearchCorner2.Parent = SearchButton

local SearchStroke2 = Instance.new("UIStroke")
SearchStroke2.Color = COLOR_ELEMENT_STROKE
SearchStroke2.Thickness = 1
SearchStroke2.Transparency = 0.3
SearchStroke2.Parent = SearchButton

local ProfileCard = Instance.new("Frame")
ProfileCard.Name = "ProfileCard"
ProfileCard.Size = UDim2.new(1, -20, 0, 66)
ProfileCard.Position = UDim2.new(0, 10, 0, 36)
ProfileCard.BackgroundColor3 = COLOR_ELEMENT
ProfileCard.BackgroundTransparency = 0.3
ProfileCard.BorderSizePixel = 0
ProfileCard.ZIndex = 3
ProfileCard.Parent = Content

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 12)
ProfileCorner.Parent = ProfileCard

local ProfileStroke = Instance.new("UIStroke")
ProfileStroke.Color = COLOR_ELEMENT_STROKE
ProfileStroke.Thickness = 1.2
ProfileStroke.Transparency = 0.3
ProfileStroke.Parent = ProfileCard

local Avatar = Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.Size = UDim2.fromOffset(46, 46)
Avatar.Position = UDim2.new(0, 10, 0, 10)
Avatar.BackgroundTransparency = 1
Avatar.Image = ""
Avatar.ZIndex = 4
Avatar.Parent = ProfileCard

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 10)
AvatarCorner.Parent = Avatar

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = COLOR_ELEMENT_STROKE
AvatarStroke.Thickness = 1
AvatarStroke.Transparency = 0.25
AvatarStroke.Parent = Avatar

local ProfileName = Instance.new("TextLabel")
ProfileName.Name = "ProfileName"
ProfileName.Size = UDim2.new(1, -76, 0, 20)
ProfileName.Position = UDim2.new(0, 66, 0, 12)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = "Nenhuma busca feita"
ProfileName.TextColor3 = COLOR_TEXT
ProfileName.Font = Enum.Font.GothamMedium
ProfileName.TextSize = 11
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.TextTruncate = Enum.TextTruncate.AtEnd
ProfileName.ZIndex = 4
ProfileName.Parent = ProfileCard

local ProfileUser = Instance.new("TextLabel")
ProfileUser.Name = "ProfileUser"
ProfileUser.Size = UDim2.new(1, -76, 0, 16)
ProfileUser.Position = UDim2.new(0, 66, 0, 34)
ProfileUser.BackgroundTransparency = 1
ProfileUser.Text = ""
ProfileUser.TextColor3 = COLOR_DARK_TEXT
ProfileUser.Font = Enum.Font.Gotham
ProfileUser.TextSize = 9
ProfileUser.TextXAlignment = Enum.TextXAlignment.Left
ProfileUser.TextTruncate = Enum.TextTruncate.AtEnd
ProfileUser.ZIndex = 4
ProfileUser.Parent = ProfileCard

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 16)
Status.Position = UDim2.new(0, 10, 0, 108)
Status.BackgroundTransparency = 1
Status.Text = "Pesquise um jogador ou deixe vazio para escanear todos."
Status.TextColor3 = COLOR_TEXT
Status.Font = Enum.Font.Gotham
Status.TextSize = 9
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextTruncate = Enum.TextTruncate.AtEnd
Status.ZIndex = 4
Status.Parent = Content

local List = Instance.new("ScrollingFrame")
List.Name = "Results"
List.Size = UDim2.new(1, -20, 1, -130)
List.Position = UDim2.new(0, 10, 0, 128)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 3
List.ScrollBarImageColor3 = COLOR_THEME
List.ScrollBarImageTransparency = 0.3
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
List.ScrollingDirection = Enum.ScrollingDirection.Y
List.ZIndex = 3
List.Parent = Content

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0, 6)
Padding.Parent = List

local minimized = false

Minimize.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        Content.Visible = false
        Main.Size = UDim2.new(0.42, 0, 0, 42)
        Minimize.Text = "+"
    else
        Content.Visible = true
        Main.Size = UDim2.new(0.42, 0, 0.72, 0)
        Minimize.Text = "−"
    end
end)

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = object
end

local function addStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLOR_ELEMENT_STROKE
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.3
    stroke.Parent = object
end

local function clearResults()
    for _, child in ipairs(List:GetChildren()) do
        if child ~= Layout and child ~= Padding then
            child:Destroy()
        end
    end
end

local function addResult(itemName, itemType, assetId, source)
    local row = Instance.new("Frame")
    row.Name = "Item"
    row.Size = UDim2.new(1, -6, 0, 96)
    row.BackgroundTransparency = 0.25
    row.BackgroundColor3 = COLOR_ELEMENT
    row.BorderSizePixel = 0
    row.ZIndex = 4
    row.Parent = List

    addCorner(row, 12)
    addStroke(row, COLOR_ELEMENT_STROKE, 1, 0.3)

    local thumbnail = Instance.new("ImageLabel")
    thumbnail.Name = "Thumbnail"
    thumbnail.Size = UDim2.fromOffset(50, 50)
    thumbnail.Position = UDim2.new(0, 10, 0, 10)
    thumbnail.BackgroundTransparency = 1
    thumbnail.Image = "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=150&h=150"
    thumbnail.ScaleType = Enum.ScaleType.Fit
    thumbnail.ZIndex = 5
    thumbnail.Parent = row

    addCorner(thumbnail, 8)

    local name = Instance.new("TextLabel")
    name.Name = "ItemName"
    name.Size = UDim2.new(1, -150, 0, 20)
    name.Position = UDim2.new(0, 70, 0, 8)
    name.BackgroundTransparency = 1
    name.Text = tostring(itemName)
    name.TextColor3 = COLOR_TEXT
    name.Font = Enum.Font.GothamMedium
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.ZIndex = 5
    name.Parent = row

    local details = Instance.new("TextLabel")
    details.Name = "Details"
    details.Size = UDim2.new(1, -150, 0, 14)
    details.Position = UDim2.new(0, 70, 0, 28)
    details.BackgroundTransparency = 1
    details.Text = tostring(itemType) .. " | " .. tostring(source or "")
    details.TextColor3 = COLOR_DARK_TEXT
    details.Font = Enum.Font.Gotham
    details.TextSize = 9
    details.TextXAlignment = Enum.TextXAlignment.Left
    details.TextTruncate = Enum.TextTruncate.AtEnd
    details.ZIndex = 5
    details.Parent = row

    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "AssetId"
    idLabel.Size = UDim2.new(1, -150, 0, 14)
    idLabel.Position = UDim2.new(0, 70, 0, 44)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "ID: " .. tostring(assetId)
    idLabel.TextColor3 = COLOR_THEME
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 9
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.TextTruncate = Enum.TextTruncate.AtEnd
    idLabel.ZIndex = 5
    idLabel.Parent = row

    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyId"
    copyButton.Size = UDim2.new(0, 68, 0, 20)
    copyButton.Position = UDim2.new(1, -78, 0, 50)
    copyButton.BackgroundColor3 = COLOR_HUB_2
    copyButton.BackgroundTransparency = 0.15
    copyButton.Text = "COPIAR ID"
    copyButton.TextColor3 = COLOR_TEXT
    copyButton.Font = Enum.Font.GothamMedium
    copyButton.TextSize = 8
    copyButton.ZIndex = 6
    copyButton.Parent = row

    addCorner(copyButton, 8)
    addStroke(copyButton, COLOR_ELEMENT_STROKE, 1, 0.3)

    copyButton.Activated:Connect(function()
        if typeof(setclipboard) == "function" then
            pcall(setclipboard, tostring(assetId))
            Status.Text = "ID copiado: " .. tostring(assetId)
        else
            Status.Text = "ID: " .. tostring(assetId)
        end
    end)
end

local function extractId(value)
    if not value then return nil end
    if type(value) == "number" then
        return value > 0 and value or nil
    end
    local id = string.match(tostring(value), "%d+")
    if id then
        local num = tonumber(id)
        if num and num > 0 then
            return num
        end
    end
    return nil
end

local productCache = {}

local function isValidStoreAsset(assetId)
    if productCache[assetId] ~= nil then
        return productCache[assetId]
    end

    local success = pcall(function()
        return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
    end)

    productCache[assetId] = success
    return success
end

local bodyPartMap = {
    Head = "Cabeça",
    Torso = "Torso",
    LeftArm = "Braço Esquerdo",
    RightArm = "Braço Direito",
    LeftLeg = "Perna Esquerda",
    RightLeg = "Perna Direita",
    UpperTorso = "Torso Superior",
    LowerTorso = "Torso Inferior",
    LeftHand = "Mão Esquerda",
    RightHand = "Mão Direita"
}

local function addUnique(results, seen, item)
    local key = tostring(item.id)
    if not seen[key] then
        seen[key] = true
        table.insert(results, item)
    end
end

local function scanHumanoidDescription(desc, results, seen, ownerName)
    local fields = {
        "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg",
        "UpperTorso", "LowerTorso", "LeftHand", "RightHand",
        "Shirt", "Pants", "GraphicTShirt", "Face"
    }

    for _, field in ipairs(fields) do
        local success, value = pcall(function()
            return desc[field]
        end)

        if success and value then
            local id = extractId(value)
            if id and isValidStoreAsset(id) then
                local label = bodyPartMap[field] or field
                local tipo = "Corpo"
                if field == "Shirt" then tipo = "Camisa" end
                if field == "Pants" then tipo = "Calça" end
                if field == "GraphicTShirt" then tipo = "Camiseta" end
                if field == "Face" then tipo = "Rosto" end

                addUnique(results, seen, {
                    name = label,
                    type = tipo,
                    id = id,
                    source = ownerName .. " | " .. field
                })
            end
        end
    end

    local successAcc, accessories = pcall(function()
        return desc:GetAccessories(true)
    end)

    if successAcc and accessories then
        for _, accessory in ipairs(accessories) do
            local assetId = extractId(accessory.AssetId)
            if assetId and isValidStoreAsset(assetId) then
                addUnique(results, seen, {
                    name = tostring(accessory.AccessoryType or "Acessório"),
                    type = "Acessório",
                    id = assetId,
                    source = ownerName .. " | Accessory"
                })
            end
        end
    end

    local successEmotes, emotes = pcall(function()
        return desc:GetEmotes()
    end)

    if successEmotes and emotes then
        for _, emote in ipairs(emotes) do
            local assetId = extractId(emote.AssetId)
            if assetId and isValidStoreAsset(assetId) then
                addUnique(results, seen, {
                    name = "Emote",
                    type = "Emote",
                    id = assetId,
                    source = ownerName .. " | Emote"
                })
            end
        end
    end
end

local function scanCharacter(char, results, seen, ownerName)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local desc = humanoid:FindFirstChildOfClass("HumanoidDescription")
        if desc then
            scanHumanoidDescription(desc, results, seen, ownerName)
        end
    end

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Shirt") then
            local id = extractId(obj.ShirtTemplate)
            if id and isValidStoreAsset(id) then
                addUnique(results, seen, {
                    name = obj.Name,
                    type = "Camisa",
                    id = id,
                    source = ownerName .. " | Shirt"
                })
            end
        elseif obj:IsA("Pants") then
            local id = extractId(obj.PantsTemplate)
            if id and isValidStoreAsset(id) then
                addUnique(results, seen, {
                    name = obj.Name,
                    type = "Calça",
                    id = id,
                    source = ownerName .. " | Pants"
                })
            end
        elseif obj:IsA("ShirtGraphic") then
            local id = extractId(obj.Graphic)
            if id and isValidStoreAsset(id) then
                addUnique(results, seen, {
                    name = obj.Name,
                    type = "Camiseta",
                    id = id,
                    source = ownerName .. " | GraphicTShirt"
                })
            end
        elseif obj:IsA("Accessory") then
            local attr = obj:GetAttribute("AssetId")
            if attr then
                local id = extractId(attr)
                if id and isValidStoreAsset(id) then
                    addUnique(results, seen, {
                        name = obj.Name,
                        type = "Acessório",
                        id = id,
                        source = ownerName .. " | Accessory"
                    })
                end
            end
        end
    end
end

local function searchAvatars(query)
    local results = {}
    local seen = {}
    local lowered = string.lower(query)

    for _, player in ipairs(Players:GetPlayers()) do
        local match = query == ""
            or string.find(string.lower(player.Name), lowered, 1, true)
            or string.find(string.lower(player.DisplayName), lowered, 1, true)

        if match then
            local char = player.Character
            if char then
                scanCharacter(char, results, seen, player.Name)
            end
        end
    end

    return results
end

local busy = false

local function doSearch()
    if busy then return end

    local query = string.gsub(SearchBox.Text, "^%s*(.-)%s*$", "%1")

    busy = true
    clearResults()
    ProfileName.Text = "Buscando..."
    ProfileUser.Text = query == "" and "Escaneando todos os avatares..." or ("Jogador: " .. query)
    Status.Text = "Procurando AssetIds de loja..."

    task.spawn(function()
        local results = searchAvatars(query)

        if #results == 0 then
            ProfileName.Text = "Nenhum resultado"
            ProfileUser.Text = ""
            Status.Text = "Nenhum AssetId de loja encontrado."
            busy = false
            return
        end

        ProfileName.Text = tostring(#results) .. " IDs encontrados"
        ProfileUser.Text = query == "" and "Todos os avatares" or ("Jogador: " .. query)

        for _, item in ipairs(results) do
            addResult(item.name, item.type, item.id, item.source)
            task.wait(0.02)
        end

        Status.Text = tostring(#results) .. " IDs encontrados."
        busy = false
    end)
end

SearchButton.Activated:Connect(doSearch)

SearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        doSearch()
    end
end)

Close.Activated:Connect(function()
    ScreenGui:Destroy()
end)

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
        end
    })

TabAvatar:AddSection("Outros")


TabAvatar:AddButton({
    Name = "Headless Head",
    Callback = function()
        local args = { [1] = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 134082579 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddButton({
    Name = "Korblox 2",
    Callback = function()
        local args = { [1] = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 16580493236 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddButton({
    Name = "Passa fome",
    Callback = function()
        local args = { [1] = { [1] = 82491774691726, [2] = 99519402284266, [3] = 115905570886697, [4] = 84418052877367, [5] = 124343282827669, [6] = 0 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddButton({
    Name = "Rato de academia",
    Callback = function()
        local args = { [1] = { [1] = 121532625082697, [2] = 119216187383922, [3] = 121634444400488, [4] = 100229264383618, [5] = 126161096503611, [6] = 0 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddSection("Skins Grandes")


TabAvatar:AddButton({
    Name = "Gigante Cinzento",
    Callback = function()
        local args = { { 15976071359, 15976074883, 15976074123, 15976074125, 15976074171, 15976074135 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddButton({
    Name = "Golem Grande",
    Callback = function()
        local args = { { 15489582363, 15489584734, 15489584622, 15489582354, 15489584682, 15489582340 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddSection("Skins Masculinas humanas ")


TabAvatar:AddButton({
    Name = "Mini Garoto v1",
    Callback = function()
        local args = { { 120973199097564, 112849465115864, 118345433416023, 106586789635639, 78321005147549, 0 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddButton({
    Name = "Garoto Nanico v2",
    Callback = function()
        local args = { { 101678129797722, 74948603903648, 114267907635155, 101387518276175, 100840538291335, 0 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

TabAvatar:AddButton({
    Name = "Homem Invisível",
    Callback = function()
        local args = { { 15312911732, 14532583477, 14532583469, 14532583517, 14532583483, 15093053680 } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeCharacterBody"):InvokeServer(unpack(args))
    end
})

do
    local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local TabNames = Window:MakeTab({"NameAndBio", "rbxassetid://4673498741"})

local inputName = ""
local inputBio = ""
local fonteSelecionada = "Nenhuma"

local function criarMapa(mapa)
    return function(texto)
        local resultado = ""
        for i = 1, #texto do
            local char = texto:sub(i, i)
            resultado = resultado .. (mapa[char] or char)
        end
        return resultado
    end
end

local function aplicarGlitchado(texto)
    local resultado = ""
    for i = 1, #texto do
        local char = texto:sub(i, i)
        resultado = resultado .. "\210\137" .. char
    end
    return resultado
end

local function aplicarGlitchado2(texto)
    local resultado = ""
    for i = 1, #texto do
        local char = texto:sub(i, i)
        resultado = resultado .. "\226\131\165" .. char
    end
    return resultado
end

local function aplicarGlitchado3(texto)
    local resultado = ""
    for i = 1, #texto do
        local char = texto:sub(i, i)
        resultado = resultado .. "\204\136" .. char
    end
    return resultado
end

local fontes = {
    ["Nenhuma"] = function(t) return t end,
    ["Letras Glitchadas"] = aplicarGlitchado,
    ["Glitchado 2"] = aplicarGlitchado2,
    ["Glitchado 3"] = aplicarGlitchado3,

    ["Circulado"] = criarMapa({
        a="ⓐ", b="ⓑ", c="ⓒ", d="ⓓ", e="ⓔ", f="ⓕ", g="ⓖ", h="ⓗ", i="ⓘ", j="ⓙ",
        k="ⓚ", l="ⓛ", m="ⓜ", n="ⓝ", o="ⓞ", p="ⓟ", q="ⓠ", r="ⓡ", s="ⓢ", t="ⓣ",
        u="ⓤ", v="ⓥ", w="ⓦ", x="ⓧ", y="ⓨ", z="ⓩ",
        A="Ⓐ", B="Ⓑ", C="Ⓒ", D="Ⓓ", E="Ⓔ", F="Ⓕ", G="Ⓖ", H="Ⓗ", I="Ⓘ", J="Ⓙ",
        K="Ⓚ", L="Ⓛ", M="Ⓜ", N="Ⓝ", O="Ⓞ", P="Ⓟ", Q="Ⓠ", R="Ⓡ", S="Ⓢ", T="Ⓣ",
        U="Ⓤ", V="Ⓥ", W="Ⓦ", X="Ⓧ", Y="Ⓨ", Z="Ⓩ"
    }),

    ["Quadrado"] = criarMapa({
        a="🅰", b="🅱", c="🅲", d="🅳", e="🅴", f="🅵", g="🅶", h="🅷", i="🅸", j="🅹",
        k="🅺", l="🅻", m="🅼", n="🅽", o="🅾", p="🅿", q="🆀", r="🆁", s="🆂", t="🆃",
        u="🆄", v="🆅", w="🆆", x="🆇", y="🆈", z="🆉"
    }),

    ["Negrito"] = criarMapa({
        a="𝐚", b="𝐛", c="𝐜", d="𝐝", e="𝐞", f="𝐟", g="𝐠", h="𝐡", i="𝐢", j="𝐣",
        k="𝐤", l="𝐥", m="𝐦", n="𝐧", o="𝐨", p="𝐩", q="𝐪", r="𝐫", s="𝐬", t="𝐭",
        u="𝐮", v="𝐯", w="𝐰", x="𝐱", y="𝐲", z="𝐳",
        A="𝐀", B="𝐁", C="𝐂", D="𝐃", E="𝐄", F="𝐅", G="𝐆", H="𝐇", I="𝐈", J="𝐉",
        K="𝐊", L="𝐋", M="𝐌", N="𝐍", O="𝐎", P="𝐏", Q="𝐐", R="𝐑", S="𝐒", T="𝐓",
        U="𝐔", V="𝐕", W="𝐖", X="𝐗", Y="𝐘", Z="𝐙"
    }),

    ["Italico"] = criarMapa({
        a="𝑎", b="𝑏", c="𝑐", d="𝑑", e="𝑒", f="𝑓", g="𝑔", h="ℎ", i="𝑖", j="𝑗",
        k="𝑘", l="𝑙", m="𝑚", n="𝑛", o="𝑜", p="𝑝", q="𝑞", r="𝑟", s="𝑠", t="𝑡",
        u="𝑢", v="𝑣", w="𝑤", x="𝑥", y="𝑦", z="𝑧",
        A="𝐴", B="𝐵", C="𝐶", D="𝐷", E="𝐸", F="𝐹", G="𝐺", H="𝐻", I="𝐼", J="𝐽",
        K="𝐾", L="𝐿", M="𝑀", N="𝑁", O="𝑂", P="𝑃", Q="𝑄", R="𝑅", S="𝑆", T="𝑇",
        U="𝑈", V="𝑉", W="𝑊", X="𝑋", Y="𝑌", Z="𝑍"
    }),

    ["Negrito Italico"] = criarMapa({
        a="𝒂", b="𝒃", c="𝒄", d="𝒅", e="𝒆", f="𝒇", g="𝒈", h="𝒉", i="𝒊", j="𝒋",
        k="𝒌", l="𝒍", m="𝒎", n="𝒏", o="𝒐", p="𝒑", q="𝒒", r="𝒓", s="𝒔", t="𝒕",
        u="𝒖", v="𝒗", w="𝒘", x="𝒙", y="𝒚", z="𝒛",
        A="𝑨", B="𝑩", C="𝑪", D="𝑫", E="𝑬", F="𝑭", G="𝑮", H="𝑯", I="𝑰", J="𝑱",
        K="𝑲", L="𝑳", M="𝑴", N="𝑵", O="𝑶", P="𝑷", Q="𝑸", R="𝑹", S="𝑺", T="𝑻",
        U="𝑼", V="𝑽", W="𝑾", X="𝑿", Y="𝒀", Z="𝒁"
    }),

    ["Script"] = criarMapa({
        a="𝒶", b="𝒷", c="𝒸", d="𝒹", e="ℯ", f="𝒻", g="ℊ", h="𝒽", i="𝒾", j="𝒿",
        k="𝓀", l="𝓁", m="𝓂", n="𝓃", o="ℴ", p="𝓅", q="𝓆", r="𝓇", s="𝓈", t="𝓉",
        u="𝓊", v="𝓋", w="𝓌", x="𝓍", y="𝓎", z="𝓏",
        A="𝒜", B="ℬ", C="𝒞", D="𝒟", E="ℰ", F="ℱ", G="𝒢", H="ℋ", I="ℐ", J="𝒥",
        K="𝒦", L="ℒ", M="ℳ", N="𝒩", O="𝒪", P="𝒫", Q="𝒬", R="ℛ", S="𝒮", T="𝒯",
        U="𝒰", V="𝒱", W="𝒲", X="𝒳", Y="𝒴", Z="𝒵"
    }),

    ["Negrito Script"] = criarMapa({
        a="𝓪", b="𝓫", c="𝓬", d="𝓭", e="𝓮", f="𝓯", g="𝓰", h="𝓱", i="𝓲", j="𝓳",
        k="𝓴", l="𝓵", m="𝓶", n="𝓷", o="𝓸", p="𝓹", q="𝓺", r="𝓻", s="𝓼", t="𝓽",
        u="𝓾", v="𝓿", w="𝔀", x="𝔁", y="𝔂", z="𝔃",
        A="𝓐", B="𝓑", C="𝓒", D="𝓓", E="𝓔", F="𝓕", G="𝓖", H="𝓗", I="𝓘", J="𝓙",
        K="𝓚", L="𝓛", M="𝓜", N="𝓝", O="𝓞", P="𝓟", Q="𝓠", R="𝓡", S="𝓢", T="𝓣",
        U="𝓤", V="𝓥", W="𝓦", X="𝓧", Y="𝓨", Z="𝓩"
    }),

    ["Fraktur"] = criarMapa({
        a="𝔞", b="𝔟", c="𝔠", d="𝔡", e="𝔢", f="𝔣", g="𝔤", h="𝔥", i="𝔦", j="𝔧",
        k="𝔨", l="𝔩", m="𝔪", n="𝔫", o="𝔬", p="𝔭", q="𝔮", r="𝔯", s="𝔰", t="𝔱",
        u="𝔲", v="𝔳", w="𝔴", x="𝔵", y="𝔶", z="𝔷",
        A="𝔄", B="𝔅", C="ℭ", D="𝔇", E="𝔈", F="𝔉", G="𝔊", H="ℌ", I="ℑ", J="𝔍",
        K="𝔎", L="𝔏", M="𝔐", N="𝔑", O="𝔒", P="𝔓", Q="𝔔", R="ℜ", S="𝔖", T="𝔗",
        U="𝔘", V="𝔙", W="𝔚", X="𝔛", Y="𝔜", Z="ℨ"
    }),

    ["Negrito Fraktur"] = criarMapa({
        a="𝖆", b="𝖇", c="𝖈", d="𝖉", e="𝖊", f="𝖋", g="𝖌", h="𝖍", i="𝖎", j="𝖏",
        k="𝖐", l="𝖑", m="𝖒", n="𝖓", o="𝖔", p="𝖕", q="𝖖", r="𝖗", s="𝖘", t="𝖙",
        u="𝖚", v="𝖛", w="𝖜", x="𝖝", y="𝖞", z="𝖟",
        A="𝕬", B="𝕭", C="𝕮", D="𝕯", E="𝕰", F="𝕱", G="𝕲", H="𝕳", I="𝕴", J="𝕵",
        K="𝕶", L="𝕷", M="𝕸", N="𝕹", O="𝕺", P="𝕻", Q="𝕼", R="𝕽", S="𝕾", T="𝕿",
        U="𝖀", V="𝖁", W="𝖂", X="𝖃", Y="𝖄", Z="𝖅"
    }),

    ["Double Struck"] = criarMapa({
        a="𝕒", b="𝕓", c="𝕔", d="𝕕", e="𝕖", f="𝕗", g="𝕘", h="𝕙", i="𝕚", j="𝕛",
        k="𝕜", l="𝕝", m="𝕞", n="𝕟", o="𝕠", p="𝕡", q="𝕢", r="𝕣", s="𝕤", t="𝕥",
        u="𝕦", v="𝕧", w="𝕨", x="𝕩", y="𝕪", z="𝕫",
        A="𝔸", B="𝔹", C="ℂ", D="𝔻", E="𝔼", F="𝔽", G="𝔾", H="ℍ", I="𝕀", J="𝕁",
        K="𝕂", L="𝕃", M="𝕄", N="ℕ", O="𝕆", P="ℙ", Q="ℚ", R="ℝ", S="𝕊", T="𝕋",
        U="𝕌", V="𝕍", W="𝕎", X="𝕏", Y="𝕐", Z="ℤ"
    }),

    ["Monoespaco"] = criarMapa({
        a="𝚊", b="𝚋", c="𝚌", d="𝚍", e="𝚎", f="𝚏", g="𝚐", h="𝚑", i="𝚒", j="𝚓",
        k="𝚔", l="𝚕", m="𝚖", n="𝚗", o="𝚘", p="𝚙", q="𝚚", r="𝚛", s="𝚜", t="𝚝",
        u="𝚞", v="𝚟", w="𝚠", x="𝚡", y="𝚢", z="𝚣",
        A="𝙰", B="𝙱", C="𝙲", D="𝙳", E="𝙴", F="𝙵", G="𝙶", H="𝙷", I="𝙸", J="𝙹",
        K="𝙺", L="𝙻", M="𝙼", N="𝙽", O="𝙾", P="𝙿", Q="𝚀", R="𝚁", S="𝚂", T="𝚃",
        U="𝚄", V="𝚅", W="𝚆", X="𝚇", Y="𝚈", Z="𝚉"
    }),

    ["Pequeno Caps"] = criarMapa({
        a="ᴀ", b="ʙ", c="ᴄ", d="ᴅ", e="ᴇ", f="ꜰ", g="ɢ", h="ʜ", i="ɪ", j="ᴊ",
        k="ᴋ", l="ʟ", m="ᴍ", n="ɴ", o="ᴏ", p="ᴘ", q="ǫ", r="ʀ", s="ꜱ", t="ᴛ",
        u="ᴜ", v="ᴠ", w="ᴡ", x="x", y="ʏ", z="ᴢ"
    }),

    ["Super Escrito"] = criarMapa({
        a="ᵃ", b="ᵇ", c="ᶜ", d="ᵈ", e="ᵉ", f="ᶠ", g="ᵍ", h="ʰ", i="ⁱ", j="ʲ",
        k="ᵏ", l="ˡ", m="ᵐ", n="ⁿ", o="ᵒ", p="ᵖ", q="۹", r="ʳ", s="ˢ", t="ᵗ",
        u="ᵘ", v="ᵛ", w="ʷ", x="ˣ", y="ʸ", z="ᶻ"
    }),

    ["Sub Escrito"] = criarMapa({
        a="ₐ", b="♭", c="꜀", d="ᑯ", e="ₑ", f="բ", g="₉", h="ₕ", i="ᵢ", j="ⱼ",
        k="ₖ", l="ₗ", m="ₘ", n="ₙ", o="ₒ", p="ₚ", q="۹", r="ᵣ", s="ₛ", t="ₜ",
        u="ᵤ", v="ᵥ", w="ᵥᵥ", x="ₓ", y="ᵧ", z="₂"
    }),

    ["Parenteses"] = criarMapa({
        a="⒜", b="⒝", c="⒞", d="⒟", e="⒠", f="⒡", g="⒢", h="⒣", i="⒤", j="⒥",
        k="⒦", l="⒧", m="⒨", n="⒩", o="⒪", p="⒫", q="⒬", r="⒭", s="⒮", t="⒯",
        u="⒰", v="⒱", w="⒲", x="⒳", y="⒴", z="⒵"
    }),

    ["Invertido"] = criarMapa({
        a="ɐ", b="q", c="ɔ", d="p", e="ǝ", f="ɟ", g="ƃ", h="ɥ", i="ᴉ", j="ɾ",
        k="ʞ", l="l", m="ɯ", n="u", o="o", p="d", q="b", r="ɹ", s="s", t="ʇ",
        u="n", v="ʌ", w="ʍ", x="x", y="ʎ", z="z"
    }),

    ["Wide"] = criarMapa({
        a="ａ", b="ｂ", c="ｃ", d="ｄ", e="ｅ", f="ｆ", g="ｇ", h="ｈ", i="ｉ", j="ｊ",
        k="ｋ", l="ｌ", m="ｍ", n="ｎ", o="ｏ", p="ｐ", q="ｑ", r="ｒ", s="ｓ", t="ｔ",
        u="ｕ", v="ｖ", w="ｗ", x="ｘ", y="ｙ", z="ｚ",
        A="Ａ", B="Ｂ", C="Ｃ", D="Ｄ", E="Ｅ", F="Ｆ", G="Ｇ", H="Ｈ", I="Ｉ", J="Ｊ",
        K="Ｋ", L="Ｌ", M="Ｍ", N="Ｎ", O="Ｏ", P="Ｐ", Q="Ｑ", R="Ｒ", S="Ｓ", T="Ｔ",
        U="Ｕ", V="Ｖ", W="Ｗ", X="Ｘ", Y="Ｙ", Z="Ｚ"
    }),

    ["Wide Negrito"] = criarMapa({
        a="𝐚", b="𝐛", c="𝐜", d="𝐝", e="𝐞", f="𝐟", g="𝐠", h="𝐡", i="𝐢", j="𝐣",
        k="𝐤", l="𝐥", m="𝐦", n="𝐧", o="𝐨", p="𝐩", q="𝐪", r="𝐫", s="𝐬", t="𝐭",
        u="𝐮", v="𝐯", w="𝐰", x="𝐱", y="𝐲", z="𝐳"
    }),

    ["Negrito Circulado"] = criarMapa({
        a="🅐", b="🅑", c="🅒", d="🅓", e="🅔", f="🅕", g="🅖", h="🅗", i="🅘", j="🅙",
        k="🅚", l="🅛", m="🅜", n="🅝", o="🅞", p="🅟", q="🅠", r="🅡", s="🅢", t="🅣",
        u="🅤", v="🅥", w="🅦", x="🅧", y="🅨", z="🅩"
    }),

    ["Negativo Circulado"] = criarMapa({
        a="🅰", b="🅱", c="🅲", d="🅳", e="🅴", f="🅵", g="🅶", h="🅷", i="🅸", j="🅹",
        k="🅺", l="🅻", m="🅼", n="🅽", o="🅾", p="🅿", q="🆀", r="🆁", s="🆂", t="🆃",
        u="🆄", v="🆅", w="🆆", x="🆇", y="🆈", z="🆉"
    }),

    ["Regional A"] = criarMapa({
        a="🇦", b="🇧", c="🇨", d="🇩", e="🇪", f="🇫", g="🇬", h="🇭", i="🇮", j="🇯",
        k="🇰", l="🇱", m="🇲", n="🇳", o="🇴", p="🇵", q="🇶", r="🇷", s="🇸", t="🇹",
        u="🇺", v="🇻", w="🇼", x="🇽", y="🇾", z="🇿"
    }),

    ["Fullwidth Mini"] = criarMapa({
        a="ᵃ", b="ᵇ", c="ᶜ", d="ᵈ", e="ᵉ", f="ᶠ", g="ᵍ", h="ʰ", i="ⁱ", j="ʲ",
        k="ᵏ", l="ˡ", m="ᵐ", n="ⁿ", o="ᵒ", p="ᵖ", q="۹", r="ʳ", s="ˢ", t="ᵗ",
        u="ᵘ", v="ᵛ", w="ʷ", x="ˣ", y="ʸ", z="ᶻ"
    }),

    ["Parenteses Negrito"] = criarMapa({
        a="🄰", b="🄱", c="🄲", d="🄳", e="🄴", f="🄵", g="🄶", h="🄷", i="🄸", j="🄹",
        k="🄺", l="🄻", m="🄼", n="🄽", o="🄾", p="🄿", q="🅀", r="🅁", s="🅂", t="🅃",
        u="🅄", v="🅅", w="🅆", x="🅇", y="🅈", z="🅉"
    }),

    ["Quadrado Escuro"] = criarMapa({
        a="🄰", b="🄱", c="🄲", d="🄳", e="🄴", f="🄵", g="🄶", h="🄷", i="🄸", j="🄹",
        k="🄺", l="🄻", m="🄼", n="🄽", o="🄾", p="🄿", q="🅀", r="🅁", s="🅂", t="🅃",
        u="🅄", v="🅅", w="🅆", x="🅇", y="🅈", z="🅉"
    }),

    ["Circulo Pequeno"] = criarMapa({
        a="ᵃ", b="ᵇ", c="ᶜ", d="ᵈ", e="ᵉ", f="ᶠ", g="ᵍ", h="ʰ", i="ⁱ", j="ʲ",
        k="ᵏ", l="ˡ", m="ᵐ", n="ⁿ", o="ᵒ", p="ᵖ", q="۹", r="ʳ", s="ˢ", t="ᵗ",
        u="ᵘ", v="ᵛ", w="ʷ", x="ˣ", y="ʸ", z="ᶻ"
    }),

    ["Circulo Negro"] = criarMapa({
        a="🅐", b="🅑", c="🅒", d="🅓", e="🅔", f="🅕", g="🅖", h="🅗", i="🅘", j="🅙",
        k="🅚", l="🅛", m="🅜", n="🅝", o="🅞", p="🅟", q="🅠", r="🅡", s="🅢", t="🅣",
        u="🅤", v="🅥", w="🅦", x="🅧", y="🅨", z="🅩"
    }),

    ["Squared Negrito"] = criarMapa({
        a="🅰", b="🅱", c="🅲", d="🅳", e="🅴", f="🅵", g="🅶", h="🅷", i="🅸", j="🅹",
        k="🅺", l="🅻", m="🅼", n="🅽", o="🅾", p="🅿", q="🆀", r="🆁", s="🆂", t="🆃",
        u="🆄", v="🆅", w="🆆", x="🆇", y="🆈", z="🆉"
    }),

    ["Alt Circulo"] = criarMapa({
        a="Ⓐ", b="Ⓑ", c="Ⓒ", d="Ⓓ", e="Ⓔ", f="Ⓕ", g="Ⓖ", h="Ⓗ", i="Ⓘ", j="Ⓙ",
        k="Ⓚ", l="Ⓛ", m="Ⓜ", n="Ⓝ", o="Ⓞ", p="Ⓟ", q="Ⓠ", r="Ⓡ", s="Ⓢ", t="Ⓣ",
        u="Ⓤ", v="Ⓥ", w="Ⓦ", x="Ⓧ", y="Ⓨ", z="Ⓩ"
    }),

    ["Parenteses Negro"] = criarMapa({
        a="🄐", b="🄑", c="🄒", d="🄓", e="🄔", f="🄕", g="🄖", h="🄗", i="🄘", j="🄙",
        k="🄚", l="🄛", m="🄜", n="🄝", o="🄞", p="🄟", q="🄠", r="🄡", s="🄢", t="🄣",
        u="🄤", v="🄥", w="🄦", x="🄧", y="🄨", z="🄩"
    }),

    ["Caps Invertido"] = criarMapa({
        a="∀", b="𐐒", c="Ɔ", d="ᗡ", e="Ǝ", f="Ⅎ", g="⅁", h="H", i="I", j="ſ",
        k="ʞ", l="⅂", m="W", n="N", o="O", p="Ԁ", q="Ό", r="ᴚ", s="S", t="⊥",
        u="∩", v="Λ", w="M", x="X", y="⅄", z="Z"
    }),

    ["Circulo Cheio"] = criarMapa({
        a="🅰", b="🅱", c="🅲", d="🅳", e="🅴", f="🅵", g="🅶", h="🅷", i="🅸", j="🅹",
        k="🅺", l="🅻", m="🅼", n="🅽", o="🅾", p="🅿", q="🆀", r="🆁", s="🆂", t="🆃",
        u="🆄", v="🆅", w="🆆", x="🆇", y="🆈", z="🆉"
    }),
}

local function SetarNome(texto)
    local r = RS:FindFirstChild("RE") and RS.RE:FindFirstChild("1RPNam1eTex1t")
    if r then
        local nomeFinal = fontes[fonteSelecionada] and fontes[fonteSelecionada](texto) or texto
        r:FireServer("RolePlayName", nomeFinal)
    end
end

local function SetarBio(texto)
    local r = RS:FindFirstChild("RE") and RS.RE:FindFirstChild("1RPNam1eTex1t")
    if r then
        local bioFinal = fontes[fonteSelecionada] and fontes[fonteSelecionada](texto) or texto
        r:FireServer("RolePlayBio", bioFinal)
    end
end

local nomesFontes = {}
for nome, _ in pairs(fontes) do
    table.insert(nomesFontes, nome)
end
table.sort(nomesFontes)

TabNames:AddSection("Names")

TabNames:AddDropdown({
    Name = "Fonte",
    Options = nomesFontes,
    Default = "Nenhuma",
    Callback = function(value)
        if value and value ~= "" then
            fonteSelecionada = value
        end
    end
})

TabNames:AddTextBox({
    Name = "Nome RP",
    PlaceholderText = "Digite seu nome...",
    Callback = function(text)
        inputName = text
    end
})

TabNames:AddButton({
    Name = "Setar Nome",
    Callback = function()
        if inputName ~= "" then
            SetarNome(inputName)
        end
    end
})

TabNames:AddTextBox({
    Name = "Bio RP",
    PlaceholderText = "Digite sua bio...",
    Callback = function(text)
        inputBio = text
    end
})

TabNames:AddButton({
    Name = "Setar Bio",
    Callback = function()
        if inputBio ~= "" then
            SetarBio(inputBio)
        end
    end
})

TabNames:AddButton({
    Name = "Set Name and Bio",
    Callback = function()
        if inputName ~= "" and inputBio ~= "" then
            SetarNome(inputName)
            task.wait(0.2)
            SetarBio(inputBio)
        end
    end
})
end

local TabProps = Window:MakeTab({"Props", "menu"})

function getKeys(tbl)
    local keys = {}
    for k, v in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Folder = workspace:FindFirstChild("WorkspaceCom")
if Folder then
    Folder = Folder:FindFirstChild("001_TrafficCones")
end

local function getMyProps()
    local PropFolder = Workspace:FindFirstChild("WorkspaceCom") and Workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
    if not PropFolder then return {} end
    local props = {}
    for _, child in ipairs(PropFolder:GetChildren()) do
        if child.Name:find(player.Name, 1, true) and child:FindFirstChild("SetCurrentCFrame") then
            table.insert(props, child)
        end
    end
    return props
end

local function prepararProps()
    local propRemotes = {}
    local allProps = getMyProps()
    for i = 1, 15 do
        if allProps[i] and allProps[i]:FindFirstChild("SetCurrentCFrame") then
            table.insert(propRemotes, allProps[i].SetCurrentCFrame)
        end
    end
    return propRemotes
end

local function IsMyProp(prop)
    local UserId = player.UserId
    local Nick = player.Name
    
    local playerAttribute = prop:GetAttribute("Player")
    if playerAttribute ~= nil then
        if tonumber(playerAttribute) == UserId then return true end
        if tostring(playerAttribute) == Nick then return true end
    end
    
    local owner = prop:GetAttribute("Owner")
    if owner ~= nil then
        if tonumber(owner) == UserId then return true end
        if tostring(owner) == Nick then return true end
    end
    
    local ownerUserId = prop:GetAttribute("OwnerUserId")
    if ownerUserId ~= nil then
        if tonumber(ownerUserId) == UserId then return true end
    end
    
    return false
end

local function GetRemote(prop)
    local remote = prop:FindFirstChild("SetCurrentCFrame")
    if remote and remote:IsA("RemoteFunction") then
        return remote
    end
    return nil
end

do
    local propOptions = {
        ["Luzes Giratórias"] = {"RequestingPropName", "LightsSpotLightWhite", "Lights"},
        ["Poste de Luz"] = {"RequestingPropName", "SoccerLights", "Lights"},
        ["Pilares"] = {"RequestingPropName", "WoodRome", "WoodWall"},
        ["Puff Fofinho"] = {"RequestingPropName", "GirlyBeanBagPink", "Girly"},
        ["Casa de Lixo"] = {"RequestingPropName", "BigGunBunker", "Big"},
        ["Banheiro"] = {"RequestingPropName", "BigOutToilet", "Big"},
        ["Cadeira de Madeira"] = {"RequestingPropName", "FurnitureChairBrown", "Furniture"},
        ["Cadeira de Rico"] = {"RequestingPropName", "FurnitureRockingChair", "Furniture"},
        ["Vaso"] = {"RequestingPropName", "FurnitureToilet", "Furniture"},
        ["Puff Branco"] = {"RequestingPropName", "FurnitureBeanBag", "Furniture"},
        ["Rede"] = {"RequestingPropName", "Hammock", "Furniture"},
        ["Balanço 1"] = {"RequestingPropName", "SingleTireSwing", "Furniture"},
        ["Balanço 2"] = {"RequestingPropName", "SharedTireSwing", "Furniture"},
        ["Sofá"] = {"RequestingPropName", "FurnitureCouchBrown", "Furniture"},
        ["Arquibancada"] = {"RequestingPropName", "FurnitureBleachers", "Furniture"},
        ["Trono"] = {"RequestingPropName", "FurnitureSilverThrone", "Furniture"},
        ["Cama de Rico"] = {"RequestingPropName", "CastleFancyBed", "Furniture"},
        ["Hidrante"] = {"RequestingPropFeatureName", "Lego2026_FireHydrant", "Lego"},
        ["Cone"] = {"RequestingPropName", "ConstructionConeSingle", "Construction"},
        ["Barreira"] = {"RequestingPropName", "ConstructionBarBig", "Construction"},
        ["Placa de Construção"] = {"RequestingPropName", "ConstructionSign", "Construction"},
        ["Cadeira de Ferias"] = {"RequestingPropName", "FurnitureChairWhite", "Furniture"},
        ["Cadeira Alta"] = {"RequestingPropName", "WickerChair", "Furniture"},
        ["Estrela Branca"] = {"RequestingPropName", "ShapeStarWhite", "Shape"},
        ["Estrela Azul"] = {"RequestingPropName", "ShapeStarToothpaste", "Shape"},
        ["Estrela Amarela"] = {"RequestingPropName", "ShapeStarYellow", "Shape"},
        ["Lua"] = {"RequestingPropName", "ShapeMoonWhite", "Shape"},
        ["Coração"] = {"RequestingPropName", "ShapeHeartRed", "Shape"}
    }

    local selectedProp = nil
    local selectedQuantity = 15

    TabProps:AddDropdown({
        Name = "Escolher Prop",
        Options = getKeys(propOptions),
        Default = "",
        Callback = function(value)
            if value and value ~= "" then
                selectedProp = propOptions[value]
            else
                selectedProp = nil
            end
        end
    })

    local quantityOptions = {}
    for i = 1, 15 do
        table.insert(quantityOptions, tostring(i))
    end

    TabProps:AddDropdown({
        Name = "Quantidade de Props",
        Options = quantityOptions,
        Default = "15",
        Callback = function(value)
            if value and value ~= "" then
                selectedQuantity = tonumber(value) or 15
            else
                selectedQuantity = 15
            end
        end
    })

    TabProps:AddButton({
        Name = "Colocar Props",
        Callback = function()
            pcall(function()
                if not selectedProp then return end
                
                local backpack = player:WaitForChild("Backpack")
                local RE = ReplicatedStorage:WaitForChild("RE")
                local ToolRemote = RE:WaitForChild("1Too1l")
                local PropRemote = RE:WaitForChild("1Clea1rTool1s")

                local function EquipPropMaker()
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoid = character:WaitForChild("Humanoid")
                    ToolRemote:InvokeServer("PickingTools", "PropMaker")
                    local tool = backpack:WaitForChild("PropMaker")
                    humanoid:EquipTool(tool)
                    repeat task.wait() until character:FindFirstChild("PropMaker")
                    return character
                end

                local character = EquipPropMaker()
                PropRemote:FireServer(unpack(selectedProp))
                local root = character:WaitForChild("HumanoidRootPart")
                local remote = character:WaitForChild("PropMaker"):WaitForChild("Tool_PropMake")
                local color = workspace:WaitForChild("Model"):WaitForChild("001_SpawnColor"):WaitForChild("Color1")

                for i = 1, selectedQuantity do
                    local pos = root.Position + (root.CFrame.LookVector * 5)
                    pos = Vector3.new(pos.X, root.Position.Y - 3, pos.Z)
                    remote:FireServer(color, pos)
                    task.wait(1)
                end
            end)
        end
    })
end

do
    local selectedColor = nil

    local colorOptions = {
        ["Vermelho"] = Color3.new(1, 0, 0),
        ["Vermelho Escuro"] = Color3.new(0.5, 0, 0),
        ["Vermelho Claro"] = Color3.new(1, 0.5, 0.5),
        ["Azul"] = Color3.new(0, 0, 1),
        ["Azul Escuro"] = Color3.new(0, 0, 0.5),
        ["Azul Claro"] = Color3.new(0.5, 0.5, 1),
        ["Verde"] = Color3.new(0, 1, 0),
        ["Verde Escuro"] = Color3.new(0, 0.5, 0),
        ["Verde Claro"] = Color3.new(0.5, 1, 0.5),
        ["Amarelo"] = Color3.new(1, 1, 0),
        ["Amarelo Escuro"] = Color3.new(0.5, 0.5, 0),
        ["Amarelo Claro"] = Color3.new(1, 1, 0.5),
        ["Laranja"] = Color3.new(1, 0.5, 0),
        ["Laranja Escuro"] = Color3.new(0.5, 0.25, 0),
        ["Laranja Claro"] = Color3.new(1, 0.75, 0.5),
        ["Roxo"] = Color3.new(0.5, 0, 1),
        ["Roxo Escuro"] = Color3.new(0.25, 0, 0.5),
        ["Roxo Claro"] = Color3.new(0.75, 0.5, 1),
        ["Rosa"] = Color3.new(1, 0.5, 0.75),
        ["Rosa Escuro"] = Color3.new(0.5, 0, 0.25),
        ["Rosa Claro"] = Color3.new(1, 0.75, 0.875),
        ["Marrom"] = Color3.new(0.5, 0.25, 0),
        ["Marrom Escuro"] = Color3.new(0.25, 0.125, 0),
        ["Marrom Claro"] = Color3.new(0.75, 0.5, 0.25),
        ["Cinza"] = Color3.new(0.5, 0.5, 0.5),
        ["Cinza Escuro"] = Color3.new(0.25, 0.25, 0.25),
        ["Cinza Claro"] = Color3.new(0.75, 0.75, 0.75),
        ["Branco"] = Color3.new(1, 1, 1),
        ["Preto"] = Color3.new(0, 0, 0),
        ["Ciano"] = Color3.new(0, 1, 1),
        ["Ciano Escuro"] = Color3.new(0, 0.5, 0.5),
        ["Ciano Claro"] = Color3.new(0.5, 1, 1),
        ["Magenta"] = Color3.new(1, 0, 1),
        ["Magenta Escuro"] = Color3.new(0.5, 0, 0.5),
        ["Magenta Claro"] = Color3.new(1, 0.5, 1),
        ["Limão"] = Color3.new(0.5, 1, 0),
        ["Limão Escuro"] = Color3.new(0.25, 0.5, 0),
        ["Limão Claro"] = Color3.new(0.75, 1, 0.5),
        ["Turquesa"] = Color3.new(0, 1, 0.5),
        ["Turquesa Escuro"] = Color3.new(0, 0.5, 0.25),
        ["Turquesa Claro"] = Color3.new(0.5, 1, 0.75),
        ["Lavanda"] = Color3.new(0.75, 0.5, 1),
        ["Lavanda Escuro"] = Color3.new(0.375, 0.25, 0.5),
        ["Lavanda Claro"] = Color3.new(0.875, 0.75, 1),
        ["Salmão"] = Color3.new(1, 0.5, 0.5),
        ["Salmão Escuro"] = Color3.new(0.5, 0.25, 0.25),
        ["Salmão Claro"] = Color3.new(1, 0.75, 0.75),
        ["Ouro"] = Color3.new(1, 0.75, 0),
        ["Ouro Escuro"] = Color3.new(0.5, 0.375, 0),
        ["Ouro Claro"] = Color3.new(1, 0.875, 0.5),
        ["Prata"] = Color3.new(0.75, 0.75, 0.75),
        ["Prata Escuro"] = Color3.new(0.375, 0.375, 0.375),
        ["Prata Claro"] = Color3.new(0.875, 0.875, 0.875)
    }

    TabProps:AddDropdown({
        Name = "Escolher Cor",
        Options = getKeys(colorOptions),
        Default = "",
        Callback = function(value)
            if value and value ~= "" then
                selectedColor = colorOptions[value]
            else
                selectedColor = nil
            end
        end
    })

    TabProps:AddButton({
        Name = "Aplicar Cor em Todos os Props",
        Callback = function()
            pcall(function()
                if not selectedColor then return end
                
                local args = {selectedColor}
                local trafficCones = workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_TrafficCones")
                
                for _, prop in ipairs(trafficCones:GetChildren()) do
                    local changePropColor = prop:FindFirstChild("ChangePropColor")
                    if changePropColor then
                        changePropColor:InvokeServer(unpack(args))
                    end
                end
                
                game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler"):WaitForChild("PropColorPicker"):WaitForChild("SetColor"):FireServer(unpack(args))
            end)
        end
    })
end

do
    local InfestacaoAtivo = false
    local targetPlayerInfestacao = nil
    local infestacaoThread = nil
    local propRemotesInfestacao = {}

    local function iniciarInfestacao(alvo)
        if infestacaoThread then task.cancel(infestacaoThread) end
        
        infestacaoThread = task.spawn(function()
            local offsets = {}
            for i = 1, 15 do
                local row = math.floor((i - 1) / 3)
                local col = (i - 1) % 3
                local x = (col - 1) * 2
                local y = -2 + row * 2.5
                local z = (row % 2) * 1.5
                offsets[i] = Vector3.new(x, y, z)
            end
            
            while InfestacaoAtivo and alvo and alvo.Parent and alvo.Character do
                local targetChar = alvo.Character
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    for i, remote in ipairs(propRemotesInfestacao) do
                        local offset = offsets[i] or Vector3.new(0, -2 + (i - 1) * 2, 0)
                        local infestCF = hrp.CFrame * CFrame.new(offset)
                        pcall(function() remote:InvokeServer(infestCF) end)
                    end
                end
                task.wait(0.016)
            end
        end)
    end

    mouse.Button1Down:Connect(function()
        if not InfestacaoAtivo then return end
        local target = mouse.Target
        if target and target.Parent then
            local targetPlr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
            if targetPlr and targetPlr ~= player then
                targetPlayerInfestacao = targetPlr
                propRemotesInfestacao = prepararProps()
                if #propRemotesInfestacao >= 15 then
                    iniciarInfestacao(targetPlayerInfestacao)
                end
            end
        end
    end)

    TabProps:AddToggle({
        Name = "Infestação",
        Default = false,
        Callback = function(Value)
            InfestacaoAtivo = Value
            if InfestacaoAtivo then
                propRemotesInfestacao = prepararProps()
            else
                targetPlayerInfestacao = nil
                if infestacaoThread then task.cancel(infestacaoThread) infestacaoThread = nil end
            end
        end
    })
end

do
    local PrisonAtivo = false
    local targetPlayerPrison = nil
    local prisonThread = nil
    local propRemotesPrison = {}
    local prisonPositions = {}

    local function iniciarPrison(alvo)
        if prisonThread then task.cancel(prisonThread) end
        
        local offsets = {
            Vector3.new(0, 4.2, 0), Vector3.new(-1.5, 2.5, 0), Vector3.new(1.5, 2.5, 0),
            Vector3.new(0, 2.5, 1.5), Vector3.new(0, 2.5, -1.5), Vector3.new(-1.5, 0.5, 0),
            Vector3.new(1.5, 0.5, 0), Vector3.new(0, 0.5, 1.5), Vector3.new(0, 0.5, -1.5),
            Vector3.new(-1.5, -1.5, 0), Vector3.new(1.5, -1.5, 0), Vector3.new(0, -1.5, 1.5),
            Vector3.new(0, -1.5, -1.5), Vector3.new(-1.5, -4.5, 0), Vector3.new(1.5, -4.5, 0)
        }
        
        local targetChar = alvo.Character
        local hrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            prisonPositions = {}
            for i, remote in ipairs(propRemotesPrison) do
                local offset = offsets[i] or Vector3.new(0, 0, 0)
                prisonPositions[i] = hrp.Position + offset
                pcall(function() remote:InvokeServer(CFrame.new(prisonPositions[i])) end)
            end
        end
        
        prisonThread = task.spawn(function()
            while PrisonAtivo and alvo and alvo.Parent and alvo.Character do
                local targetChar = alvo.Character
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    local currentPos = hrp.Position
                    local teleported = false
                    
                    for i, pos in pairs(prisonPositions) do
                        if (currentPos - pos).Magnitude > 10 then
                            teleported = true
                            break
                        end
                    end
                    
                    if teleported then
                        for i, remote in ipairs(propRemotesPrison) do
                            local offset = offsets[i] or Vector3.new(0, 0, 0)
                            prisonPositions[i] = hrp.Position + offset
                            pcall(function() remote:InvokeServer(CFrame.new(prisonPositions[i])) end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end

    mouse.Button1Down:Connect(function()
        if not PrisonAtivo then return end
        local target = mouse.Target
        if target and target.Parent then
            local targetPlr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
            if targetPlr and targetPlr ~= player then
                targetPlayerPrison = targetPlr
                propRemotesPrison = prepararProps()
                if #propRemotesPrison >= 15 then
                    iniciarPrison(targetPlayerPrison)
                end
            end
        end
    end)

    TabProps:AddToggle({
        Name = "Prison",
        Default = false,
        Callback = function(Value)
            PrisonAtivo = Value
            if PrisonAtivo then
                propRemotesPrison = prepararProps()
            else
                targetPlayerPrison = nil
                if prisonThread then task.cancel(prisonThread) prisonThread = nil end
                prisonPositions = {}
            end
        end
    })
end

do
    local CastigoCruelAtivo = false
    local targetPlayerCruel = nil
    local cruelThread = nil
    local propRemotesCruel = {}

    local function getPlayerSize(alvo)
        local targetChar = alvo.Character
        if not targetChar then return 1 end
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not humanoid then return 1 end
        local scale = 1
        local humanoidRootPart = targetChar:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local rootSize = humanoidRootPart.Size
            scale = (rootSize.X + rootSize.Z) / 4
        end
        if scale < 0.7 then scale = 0.7 end
        if scale > 1.8 then scale = 1.8 end
        return scale
    end

    local function iniciarCastigoCruel(alvo)
        if cruelThread then task.cancel(cruelThread) end
        
        cruelThread = task.spawn(function()
            local scale = getPlayerSize(alvo)
            local extraSpace = 0.2
            
            local baseOffsets = {
                Vector3.new(0, 4.8, 0), Vector3.new(-1.5, 3.0, 0), Vector3.new(1.5, 3.0, 0),
                Vector3.new(0, 3.0, 1.5), Vector3.new(0, 3.0, -1.5), Vector3.new(-1.5, 1.0, 0),
                Vector3.new(1.5, 1.0, 0), Vector3.new(0, 1.0, 1.5), Vector3.new(0, 1.0, -1.5),
                Vector3.new(-1.5, -1.0, 0), Vector3.new(1.5, -1.0, 0), Vector3.new(0, -1.0, 1.5),
                Vector3.new(0, -1.0, -1.5), Vector3.new(-1.5, -4.0, 0), Vector3.new(1.5, -4.0, 0)
            }
            
            local minScale = 0.7
            local adjustedScale = math.max(scale, minScale)
            
            local offsets = {}
            for i, offset in ipairs(baseOffsets) do
                local scaledOffset = Vector3.new(
                    offset.X * adjustedScale + (offset.X > 0 and extraSpace or -extraSpace),
                    offset.Y,
                    offset.Z * adjustedScale + (offset.Z > 0 and extraSpace or -extraSpace)
                )
                offsets[i] = scaledOffset
            end
            
            local prisonPositions = {}
            local desceu = false
            local bolaAtiva = false
            local bolaThread = nil
            
            while CastigoCruelAtivo and alvo and alvo.Parent and alvo.Character do
                local targetChar = alvo.Character
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    if not desceu then
                        for i, remote in ipairs(propRemotesCruel) do
                            local offset = offsets[i] or Vector3.new(0, 0, 0)
                            prisonPositions[i] = hrp.Position + offset
                            pcall(function() remote:InvokeServer(CFrame.new(prisonPositions[i])) end)
                        end
                        desceu = true
                    end
                    
                    local newScale = getPlayerSize(alvo)
                    local newAdjustedScale = math.max(newScale, minScale)
                    
                    if newAdjustedScale ~= adjustedScale then
                        adjustedScale = newAdjustedScale
                        for i, offset in ipairs(baseOffsets) do
                            local scaledOffset = Vector3.new(
                                offset.X * adjustedScale + (offset.X > 0 and extraSpace or -extraSpace),
                                offset.Y,
                                offset.Z * adjustedScale + (offset.Z > 0 and extraSpace or -extraSpace)
                            )
                            offsets[i] = scaledOffset
                        end
                        
                        for i, remote in ipairs(propRemotesCruel) do
                            local offset = offsets[i] or Vector3.new(0, 0, 0)
                            prisonPositions[i] = hrp.Position + offset
                            pcall(function() remote:InvokeServer(CFrame.new(prisonPositions[i])) end)
                        end
                    end
                    
                    local currentPos = hrp.Position
                    local teleported = false
                    
                    for i, pos in pairs(prisonPositions) do
                        if (currentPos - pos).Magnitude > 10 then
                            teleported = true
                            break
                        end
                    end
                    
                    if teleported then
                        for i, remote in ipairs(propRemotesCruel) do
                            local offset = offsets[i] or Vector3.new(0, 0, 0)
                            prisonPositions[i] = hrp.Position + offset
                            pcall(function() remote:InvokeServer(CFrame.new(prisonPositions[i])) end)
                        end
                    end
                    
                    if not bolaAtiva then
                        bolaAtiva = true
                        bolaThread = task.spawn(function()
                            local serverBalls = workspace.WorkspaceCom:WaitForChild("001_SoccerBalls")
                            local bola = serverBalls:FindFirstChild("Soccer" .. player.Name)
                            
                            if not bola then
                                local backpack = player:WaitForChild("Backpack")
                                if not backpack:FindFirstChild("SoccerBall") then
                                    pcall(function()
                                        ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "SoccerBall")
                                    end)
                                end
                                repeat task.wait() until backpack:FindFirstChild("SoccerBall")
                                backpack.SoccerBall.Parent = player.Character
                                repeat task.wait() until serverBalls:FindFirstChild("Soccer" .. player.Name)
                                if player.Character and player.Character:FindFirstChild("SoccerBall") then
                                    player.Character.SoccerBall.Parent = backpack
                                end
                                bola = serverBalls:FindFirstChild("Soccer" .. player.Name)
                            end
                            
                            if bola then
                                bola.CanCollide = false
                                bola.Massless = true
                                bola.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0)
                                
                                if bola:FindFirstChildWhichIsA("BodyVelocity") then
                                    bola:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
                                end
                                
                                local bv = Instance.new("BodyVelocity")
                                bv.Velocity = Vector3.new(3.15e10, 3.15e10, 3.15e10)
                                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bv.P = 9e900
                                bv.Parent = bola
                                
                                while CastigoCruelAtivo and alvo and alvo.Parent and alvo.Character do
                                    local targetChar = alvo.Character
                                    local troot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                                    if troot then
                                        if troot.Velocity.Magnitude > 0 then
                                            bola.CFrame = CFrame.new(
                                                troot.Position.X + (troot.Velocity.X / 1.5),
                                                troot.Position.Y + (troot.Velocity.Y / 1.5),
                                                troot.Position.Z + (troot.Velocity.Z / 1.5)
                                            )
                                            bola.Orientation = bola.Orientation + Vector3.new(45, 60, 30)
                                        else
                                            for _, v in pairs(targetChar:GetChildren()) do
                                                if v:IsA("BasePart") and v.CanCollide and not v.Anchored then
                                                    bola.CFrame = v.CFrame
                                                    task.wait(1/6000)
                                                end
                                            end
                                        end
                                    end
                                    task.wait(1/6000)
                                end
                                bv:Destroy()
                            end
                        end)
                    end
                end
                task.wait(0.05)
            end
            
            if bolaThread then task.cancel(bolaThread) end
        end)
    end

    mouse.Button1Down:Connect(function()
        if not CastigoCruelAtivo then return end
        local target = mouse.Target
        if target and target.Parent then
            local targetPlr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
            if targetPlr and targetPlr ~= player then
                targetPlayerCruel = targetPlr
                propRemotesCruel = prepararProps()
                if #propRemotesCruel >= 15 then
                    iniciarCastigoCruel(targetPlayerCruel)
                end
            end
        end
    end)

    TabProps:AddToggle({
        Name = "Castigo Cruel",
        Default = false,
        Callback = function(Value)
            CastigoCruelAtivo = Value
            if CastigoCruelAtivo then
                propRemotesCruel = prepararProps()
            else
                targetPlayerCruel = nil
                if cruelThread then task.cancel(cruelThread) cruelThread = nil end
            end
        end
    })
end

do
    local PropKillAtivo = false
    local targetPlayerKill = nil
    local killThread = nil
    local propRemotesKill = {}

    local function ataqueInstantaneo(alvo)
        if killThread then task.cancel(killThread) end
        
        killThread = task.spawn(function()
            local infiniteUp = CFrame.new(0, math.huge, 0)
            local infiniteDown = CFrame.new(0, -math.huge, 0)
            
            local offsets = {
                Vector3.new(0, -2, 0), Vector3.new(0, -2, 0), Vector3.new(0, -2, 0),
                Vector3.new(0, -2, 0), Vector3.new(0, -2, 0), Vector3.new(0, -2, 0),
                Vector3.new(0, -2, 0), Vector3.new(2, -2, 0), Vector3.new(2, -2, 0),
                Vector3.new(-2, -2, 0), Vector3.new(-2, -2, 0), Vector3.new(0, -2, 2),
                Vector3.new(0, -2, -2), Vector3.new(1.5, -2, 1.5), Vector3.new(-1.5, -2, -1.5)
            }
            
            while PropKillAtivo and alvo and alvo.Parent and alvo.Character do
                local targetChar = alvo.Character
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    if humanoid.Sit then
                        for _, remote in ipairs(propRemotesKill) do
                            pcall(function() remote:InvokeServer(infiniteDown) end)
                        end
                        task.wait()
                        for _, remote in ipairs(propRemotesKill) do
                            pcall(function() remote:InvokeServer(infiniteUp) end)
                        end
                    else
                        for i, remote in ipairs(propRemotesKill) do
                            local offset = offsets[i] or Vector3.new(0, -2, 0)
                            local followCF = hrp.CFrame * CFrame.new(offset)
                            pcall(function() remote:InvokeServer(followCF) end)
                        end
                    end
                end
                task.wait()
            end
        end)
    end

    mouse.Button1Down:Connect(function()
        if not PropKillAtivo then return end
        local target = mouse.Target
        if target and target.Parent then
            local targetPlr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
            if targetPlr and targetPlr ~= player then
                targetPlayerKill = targetPlr
                propRemotesKill = prepararProps()
                if #propRemotesKill >= 15 then
                    ataqueInstantaneo(targetPlayerKill)
                end
            end
        end
    end)

    TabProps:AddToggle({
        Name = "PropKill",
        Default = false,
        Callback = function(Value)
            PropKillAtivo = Value
            if PropKillAtivo then
                propRemotesKill = prepararProps()
            else
                targetPlayerKill = nil
                if killThread then task.cancel(killThread) killThread = nil end
            end
        end
    })
end

do
    local TrollBuxAtivo = false
    local targetPlayerTroll = nil
    local trollThread = nil
    local propRemotesTroll = {}

    local function iniciarTroll(alvo)
        if trollThread then task.cancel(trollThread) end
        
        trollThread = task.spawn(function()
            local time = 0
            
            while TrollBuxAtivo and alvo and alvo.Parent and alvo.Character do
                local targetChar = alvo.Character
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    time = time + 0.016
                    local radius = 3
                    local angle = time * 3
                    
                    for i, remote in ipairs(propRemotesTroll) do
                        local offsetAngle = angle + (i / #propRemotesTroll) * math.pi * 2
                        local x = math.cos(offsetAngle) * radius
                        local z = math.sin(offsetAngle) * radius
                        local y = math.sin(time * 2 + i) * 3
                        
                        local trollCF = hrp.CFrame * CFrame.new(x, y - 2, z)
                        pcall(function() remote:InvokeServer(trollCF) end)
                    end
                end
                task.wait(0.016)
            end
        end)
    end

    mouse.Button1Down:Connect(function()
        if not TrollBuxAtivo then return end
        local target = mouse.Target
        if target and target.Parent then
            local targetPlr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
            if targetPlr and targetPlr ~= player then
                targetPlayerTroll = targetPlr
                propRemotesTroll = prepararProps()
                if #propRemotesTroll >= 15 then
                    iniciarTroll(targetPlayerTroll)
                end
            end
        end
    end)

    TabProps:AddToggle({
        Name = "TrollBux",
        Default = false,
        Callback = function(Value)
            TrollBuxAtivo = Value
            if TrollBuxAtivo then
                propRemotesTroll = prepararProps()
            else
                targetPlayerTroll = nil
                if trollThread then task.cancel(trollThread) trollThread = nil end
            end
        end
    })
end

do
    local espiralAtivo = false
    local targetPlayerEspiral = nil
    local conexaoHeartbeatEspiral = nil
    local PropsEspiral = {}
    local INTERVALO = 0.18
    local ALTURA_MIN = -2.7
    local ALTURA_MAX = 3.2
    local RAIO_MIN = 1.1
    local RAIO_MAX = 2.0
    local VELOCIDADE_SUBIDA = 1.4
    local VELOCIDADE_ROTACAO = 0.5
    local tempoEspiral = 0
    local acumuladoEspiral = 0

    local function adicionarProp(prop)
        if PropsEspiral[prop] then return end
        local Remote = prop:FindFirstChild("SetCurrentCFrame")
        if not Remote or not Remote:IsA("RemoteFunction") then return end
        local BeginPreview = prop:FindFirstChild("BeginPreview")
        PropsEspiral[prop] = {
            Remote = Remote,
            BeginPreview = BeginPreview,
            Fase = math.random() * math.pi * 2,
            Rotacao = math.random() * math.pi * 2
        }
        if BeginPreview then
            pcall(function() BeginPreview:InvokeServer() end)
        end
    end

    if Folder then
        for _, prop in ipairs(Folder:GetChildren()) do
            adicionarProp(prop)
        end
        Folder.ChildAdded:Connect(function(prop)
            task.wait(0.1)
            adicionarProp(prop)
        end)
        Folder.ChildRemoved:Connect(function(prop)
            PropsEspiral[prop] = nil
        end)
    end

    local function iniciarEspiral(alvo)
        if conexaoHeartbeatEspiral then
            conexaoHeartbeatEspiral:Disconnect()
            conexaoHeartbeatEspiral = nil
        end
        
        tempoEspiral = 0
        acumuladoEspiral = 0
        
        conexaoHeartbeatEspiral = game:GetService("RunService").Heartbeat:Connect(function(dt)
            if not espiralAtivo or not alvo or not alvo.Parent or not alvo.Character then return end
            
            tempoEspiral = tempoEspiral + dt
            acumuladoEspiral = acumuladoEspiral + dt
            
            if acumuladoEspiral < INTERVALO then return end
            acumuladoEspiral = 0
            
            local targetChar = alvo.Character
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local lista = {}
            for prop, data in pairs(PropsEspiral) do
                if prop.Parent then
                    table.insert(lista, {Prop = prop, Data = data})
                else
                    PropsEspiral[prop] = nil
                end
            end
            
            local total = #lista
            if total == 0 then return end
            
            for i, item in ipairs(lista) do
                local data = item.Data
                local progresso = (total == 1) and 0.5 or (i - 1) / (total - 1)
                
                local altura = ALTURA_MAX + (ALTURA_MIN - ALTURA_MAX) * progresso
                altura = altura + math.sin(tempoEspiral * VELOCIDADE_SUBIDA + data.Fase) * 0.35
                
                local raio = RAIO_MIN + math.sin(progresso * math.pi) * (RAIO_MAX - RAIO_MIN)
                local angulo = data.Rotacao + tempoEspiral * VELOCIDADE_ROTACAO + progresso * math.pi * 4
                
                local x = math.cos(angulo) * raio
                local z = math.sin(angulo) * raio
                
                local posicao = hrp.Position + Vector3.new(x, altura, z)
                local cframe = CFrame.new(posicao) * CFrame.Angles(0, -angulo, 0)
                
                pcall(function() data.Remote:InvokeServer(cframe) end)
            end
        end)
    end

    mouse.Button1Down:Connect(function()
        if not espiralAtivo then return end
        local target = mouse.Target
        if target and target.Parent then
            local targetPlr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
            if targetPlr and targetPlr ~= player then
                targetPlayerEspiral = targetPlr
                iniciarEspiral(targetPlayerEspiral)
            end
        end
    end)

    TabProps:AddToggle({
        Name = "Espiral de Cones",
        Default = false,
        Callback = function(Value)
            espiralAtivo = Value
            if not Value then
                targetPlayerEspiral = nil
                if conexaoHeartbeatEspiral then
                    conexaoHeartbeatEspiral:Disconnect()
                    conexaoHeartbeatEspiral = nil
                end
            end
        end
    })
end

do
    local infernusAtivo = false
    local targetPlayerInfernus = nil
    local conexaoHeartbeatInfernus = nil
    local PropsInfernus = {}
    local MAX_PROPS = 15
    local UPDATE_RATE = 0.06
    local SIDE = 2.0
    local FRONT_BACK = 2.0
    local FOOT_Y = -2.8
    local LEG_Y = -1.4
    local WAIST_Y = 0
    local TORSO_Y = 1.0
    local UPPER_TORSO_Y = 2.0
    local ROTATION_X = 2.5
    local ROTATION_Y = 4.0
    local ROTATION_Z = 2.0
    local TimeInfernus = 0
    local AccumulatorInfernus = 0

    local Positions = {
        Vector3.new(-SIDE * 0.5, FOOT_Y, -FRONT_BACK), Vector3.new(SIDE * 0.5, FOOT_Y, -FRONT_BACK),
        Vector3.new(0, FOOT_Y, FRONT_BACK), Vector3.new(-SIDE, LEG_Y, 0), Vector3.new(SIDE, LEG_Y, 0),
        Vector3.new(0, LEG_Y, -FRONT_BACK), Vector3.new(-SIDE, WAIST_Y, 0), Vector3.new(SIDE, WAIST_Y, 0),
        Vector3.new(0, WAIST_Y, FRONT_BACK), Vector3.new(-SIDE, TORSO_Y, 0), Vector3.new(SIDE, TORSO_Y, 0),
        Vector3.new(0, TORSO_Y, -FRONT_BACK), Vector3.new(-SIDE * 0.85, UPPER_TORSO_Y, 0),
        Vector3.new(SIDE * 0.85, UPPER_TORSO_Y, 0), Vector3.new(0, UPPER_TORSO_Y, FRONT_BACK * 0.8)
    }

    local function RefreshPropsInfernus()
        table.clear(PropsInfernus)
        if not Folder then return end
        for _, prop in ipairs(Folder:GetChildren()) do
            if IsMyProp(prop) then
                local remote = GetRemote(prop)
                if remote then
                    table.insert(PropsInfernus, {Prop = prop, Remote = remote})
                    if #PropsInfernus >= MAX_PROPS then break end
                end
            end
        end
    end

    local function GetRootInfernus(player)
        local Character = player.Character
        if not Character then return nil end
        return Character:FindFirstChild("HumanoidRootPart")
    end

    local function iniciarInfernus(alvo)
        if conexaoHeartbeatInfernus then
            conexaoHeartbeatInfernus:Disconnect()
            conexaoHeartbeatInfernus = nil
        end
        
        RefreshPropsInfernus()
        TimeInfernus = 0
        AccumulatorInfernus = 0
        
        if #PropsInfernus < MAX_PROPS then
            RefreshPropsInfernus()
            return
        end
        
        conexaoHeartbeatInfernus = game:GetService("RunService").Heartbeat:Connect(function(dt)
            if not infernusAtivo or not alvo or not alvo.Parent or not alvo.Character then return end
            
            if #PropsInfernus < MAX_PROPS then
                RefreshPropsInfernus()
                return
            end
            
            AccumulatorInfernus = AccumulatorInfernus + dt
            if AccumulatorInfernus < UPDATE_RATE then return end
            
            TimeInfernus = TimeInfernus + AccumulatorInfernus
            AccumulatorInfernus = 0
            
            local Root = GetRootInfernus(alvo)
            if not Root then return end
            
            for i = 1, MAX_PROPS do
                local LocalPosition = Positions[i]
                local WorldPosition = Root.CFrame:PointToWorldSpace(LocalPosition)
                local Direction = Root.Position + Vector3.new(0, 0.2, 0) - WorldPosition
                
                if Direction.Magnitude > 0 then
                    local BaseCFrame = CFrame.lookAt(WorldPosition, WorldPosition + Direction)
                    local Phase = TimeInfernus + (i * 0.37)
                    local Rotation = CFrame.Angles(math.sin(Phase * 1.3) * ROTATION_X, Phase * ROTATION_Y, math.cos(Phase * 1.7) * ROTATION_Z)
                    local FinalCFrame = BaseCFrame * Rotation
                    
                    pcall(function() PropsInfernus[i].Remote:InvokeServer(FinalCFrame) end)
                end
            end
        end)
    end

    mouse.Button1Down:Connect(function()
        if not infernusAtivo then return end
        local target = mouse.Target
        if target and target.Parent then
            local targetPlr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
            if targetPlr and targetPlr ~= player then
                targetPlayerInfernus = targetPlr
                iniciarInfernus(targetPlayerInfernus)
            end
        end
    end)

    TabProps:AddToggle({
        Name = "Infernus Lightnario",
        Default = false,
        Callback = function(Value)
            infernusAtivo = Value
            if not Value then
                targetPlayerInfernus = nil
                if conexaoHeartbeatInfernus then
                    conexaoHeartbeatInfernus:Disconnect()
                    conexaoHeartbeatInfernus = nil
                end
            end
        end
    })
end

do
    local RodaAtivo = false
    local rodaThread = nil
    local propRemotesRoda = {}

    local function iniciarRoda()
        if rodaThread then task.cancel(rodaThread) end
        
        rodaThread = task.spawn(function()
            local radius = 5
            local angles = {}
            
            for i = 1, 15 do
                angles[i] = (i - 1) * (2 * math.pi / 15)
            end
            
            local speed = 20
            local time = 0
            
            while RodaAtivo do
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    time = time + 0.008
                    local currentAngle = time * speed
                    
                    for i, remote in ipairs(propRemotesRoda) do
                        local angle = angles[i] + currentAngle
                        local x = radius * math.cos(angle)
                        local z = radius * math.sin(angle)
                        local offset = Vector3.new(x, 0, z)
                        local rodaCF = hrp.CFrame * CFrame.new(offset)
                        rodaCF = rodaCF * CFrame.Angles(math.rad(90), 0, -angle)
                        pcall(function() remote:InvokeServer(rodaCF) end)
                    end
                end
                task.wait(0.008)
            end
        end)
    end

    local function pararRoda()
        RodaAtivo = false
        if rodaThread then
            task.cancel(rodaThread)
            rodaThread = nil
        end
    end

    TabProps:AddToggle({
        Name = "Saturno V2",
        Default = false,
        Callback = function(Value)
            RodaAtivo = Value
            if RodaAtivo then
                propRemotesRoda = prepararProps()
                if #propRemotesRoda >= 15 then
                    iniciarRoda()
                end
            else
                pararRoda()
            end
        end
    })
end

do
    local RingAtivo = false
    local ringThread = nil
    local propRemotesRing = {}
    local propsEmUso = {}
    local propsDisponiveis = {}

    local function getRemoteDisponivel()
        for i, remote in ipairs(propsDisponiveis) do
            if not propsEmUso[remote] then
                return remote, i
            end
        end
        return nil, nil
    end

    local function marcarPropEmUso(remote)
        propsEmUso[remote] = true
        for i, r in ipairs(propsDisponiveis) do
            if r == remote then
                table.remove(propsDisponiveis, i)
                break
            end
        end
    end

    local function liberarProp(remote)
        propsEmUso[remote] = nil
        table.insert(propsDisponiveis, remote)
    end

    local function iniciarRing()
        if ringThread then task.cancel(ringThread) end
        
        ringThread = task.spawn(function()
            local radius = 14
            local angles = {}
            
            for i = 1, 15 do
                angles[i] = (i - 1) * (2 * math.pi / 15)
            end
            
            local speed = 0.15
            local time = 0
            local propsAtivos = {}
            
            while RingAtivo do
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    time = time + 0.016
                    local currentAngle = time * speed
                    
                    for i = 1, 15 do
                        if #propsDisponiveis > 0 then
                            local remote, index = getRemoteDisponivel()
                            if remote then
                                marcarPropEmUso(remote)
                                propsAtivos[remote] = {
                                    index = i,
                                    angle = angles[i] + currentAngle
                                }
                            end
                        end
                    end
                    
                    for remote, data in pairs(propsAtivos) do
                        local angle = data.angle
                        local x = radius * math.cos(angle)
                        local z = radius * math.sin(angle)
                        local offset = Vector3.new(x, -2, z)
                        local ringCF = hrp.CFrame * CFrame.new(offset)
                        pcall(function() remote:InvokeServer(ringCF) end)
                    end
                end
                task.wait(0.016)
            end
            
            for remote in pairs(propsAtivos) do
                liberarProp(remote)
            end
        end)
    end

    local function pararRing()
        RingAtivo = false
        if ringThread then
            task.cancel(ringThread)
            ringThread = nil
        end
        propsEmUso = {}
        propsDisponiveis = {}
        for _, remote in ipairs(propRemotesRing) do
            table.insert(propsDisponiveis, remote)
        end
    end

    TabProps:AddToggle({
        Name = "PropSaturno",
        Default = false,
        Callback = function(Value)
            RingAtivo = Value
            if RingAtivo then
                propRemotesRing = prepararProps()
                propsDisponiveis = {}
                for _, remote in ipairs(propRemotesRing) do
                    table.insert(propsDisponiveis, remote)
                end
                if #propRemotesRing >= 15 then
                    iniciarRing()
                end
            else
                pararRing()
            end
        end
    })
end

do
    local PropTorreAtivo = false
    local torreThread = nil
    local propRemotesTorre = {}

    local function iniciarTorre()
        if torreThread then task.cancel(torreThread) end
        
        torreThread = task.spawn(function()
            local alturaBase = 0
            local distanciaAtras = -12
            local offsets = {}
            
            for i = 1, 15 do
                local altura = alturaBase + (i - 1) * 3
                offsets[i] = Vector3.new(0, altura - 5, distanciaAtras)
            end
            
            while PropTorreAtivo do
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for i, remote in ipairs(propRemotesTorre) do
                        local offset = offsets[i] or Vector3.new(0, (i - 1) * 3 - 5, distanciaAtras)
                        local torreCF = hrp.CFrame * CFrame.new(offset)
                        pcall(function() remote:InvokeServer(torreCF) end)
                    end
                end
                task.wait(0.016)
            end
        end)
    end

    local function pararTorre()
        PropTorreAtivo = false
        if torreThread then
            task.cancel(torreThread)
            torreThread = nil
        end
    end

    TabProps:AddToggle({
        Name = "Torre de Props",
        Default = false,
        Callback = function(Value)
            PropTorreAtivo = Value
            if PropTorreAtivo then
                propRemotesTorre = prepararProps()
                if #propRemotesTorre >= 15 then
                    iniciarTorre()
                end
            else
                pararTorre()
            end
        end
    })
end

do
    TabProps:AddSection({
        Name = "Robô - Options"
    })

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local LP = Players.LocalPlayer

    local C = {}
    C.RoboAtivo = false
    C.RoboConnection = nil
    C.PosicaoRobo = "Na minha frente"
    C.Props = {}
    C.LastNetworkUpdate = 0

    TabProps:AddButton({
        Name = "Spawnar as Peças do Robô",
        Callback = function()
            do
                local backpack = LP:WaitForChild("Backpack")
                local character = LP.Character or LP.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                local root = character:WaitForChild("HumanoidRootPart")
                local RE = ReplicatedStorage:WaitForChild("RE", 9e9)

                RE:WaitForChild("1Too1l", 9e9):InvokeServer("PickingTools", "PropMaker")

                local tool = backpack:WaitForChild("PropMaker", 10)
                if tool then humanoid:EquipTool(tool) end

                task.wait(0.5)

                RE:WaitForChild("1Clea1rTool1s", 9e9):FireServer("RequestingPropName", "PowerTurbine", "Barrel")

                task.wait(0.5)

                local baseplate = workspace
                    :WaitForChild("__DEV", 9e9)
                    :WaitForChild("SwappableWorld", 9e9)
                    :WaitForChild("SideArea", 9e9)
                    :WaitForChild("ToBeSwapped", 9e9)
                    :WaitForChild("Baseplate", 9e9)

                local propMaker = workspace
                    :WaitForChild(LP.Name, 9e9)
                    :WaitForChild("PropMaker", 9e9)
                    :WaitForChild("Tool_PropMake", 9e9)

                for i = 1, 15 do
                    character = LP.Character or LP.CharacterAdded:Wait()
                    root = character:WaitForChild("HumanoidRootPart")
                    local posicao = root.Position - Vector3.new(0, root.Size.Y / 2 + 1, 0)
                    propMaker:FireServer(baseplate, posicao)
                    task.wait(1)
                end
            end
        end
    })

    TabProps:AddDropdown({
        Name = "Posição do Robô",
        Options = {
            "Na minha frente",
            "Nas minhas costas",
            "No meu lado direito",
            "No meu lado esquerdo",
        },
        CurrentOption = "Na minha frente",
        Callback = function(Value)
            if type(Value) == "table" then Value = Value[1] end
            C.PosicaoRobo = Value
        end
    })

    TabProps:AddToggle({
        Name = "Ativar o Robô",
        Default = false,
        Callback = function(Value)
            do
                C.RoboAtivo = Value

                if C.RoboConnection then
                    C.RoboConnection:Disconnect()
                    C.RoboConnection = nil
                end

                if not C.RoboAtivo then return end

                local character = LP.Character or LP.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                local root = character:WaitForChild("HumanoidRootPart")

                local PropsFolder = workspace
                    :WaitForChild("WorkspaceCom")
                    :WaitForChild("001_TrafficCones")

                local TOTAL_PROPS = 15
                local DISTANCIA = 8

                local ROT_X = math.rad(-90)
                local ROT_Y = math.rad(-6.32)
                local ROT_Z = 0

                local parts = {
                    Vector3.new(0, 44, 0),
                    Vector3.new(0, 34, 0),
                    Vector3.new(0, 25, 0),
                    Vector3.new(0, 16, 0),
                    Vector3.new(-9, 32, 0),
                    Vector3.new(-14, 23, 4),
                    Vector3.new(-17, 14, 7),
                    Vector3.new(9, 32, 0),
                    Vector3.new(14, 23, 4),
                    Vector3.new(17, 14, 7),
                    Vector3.new(-5, 7, 0),
                    Vector3.new(-5, 0, 0),
                    Vector3.new(5, 7, 0),
                    Vector3.new(5, 0, 0),
                    Vector3.new(0, 39, 0)
                }

                local function IsMyProp(prop)
                    local a = prop:GetAttribute("Player")
                    local b = prop:GetAttribute("Owner")
                    local c = prop:GetAttribute("OwnerUserId")
                    if a ~= nil and (tostring(a) == LP.Name or tonumber(a) == LP.UserId) then return true end
                    if b ~= nil and (tostring(b) == LP.Name or tonumber(b) == LP.UserId) then return true end
                    if c ~= nil and tonumber(c) == LP.UserId then return true end
                    return false
                end

                local function GetPart(prop)
                    if prop:IsA("BasePart") then return prop end
                    if prop:IsA("Model") then return prop.PrimaryPart or prop:FindFirstChildWhichIsA("BasePart") end
                end

                local function GetRemote(prop)
                    local remote = prop:FindFirstChild("SetCurrentCFrame", true)
                    if remote and remote:IsA("RemoteFunction") then return remote end
                end

                C.Props = {}
                for _, prop in ipairs(PropsFolder:GetChildren()) do
                    if IsMyProp(prop) then
                        local part = GetPart(prop)
                        local remote = GetRemote(prop)
                        if part and remote then
                            C.Props[#C.Props + 1] = { Part = part, Remote = remote }
                        end
                        if #C.Props >= TOTAL_PROPS then break end
                    end
                end

                if #C.Props < TOTAL_PROPS then return end

                local function MoveProp(data, cf)
                    if not data or not data.Part or not data.Part.Parent then return end
                    local cfR = data.Remote
                    if cfR then
                        pcall(function() cfR:InvokeServer(cf) end)
                    end
                end

                local function FindMotor(names)
                    for _, name in ipairs(names) do
                        local motor = character:FindFirstChild(name, true)
                        if motor and motor:IsA("Motor6D") then return motor end
                    end
                end

                local Neck = FindMotor({"Neck"})
                local Waist = FindMotor({"Waist", "RootJoint"})
                local LeftShoulder = FindMotor({"LeftShoulder", "Left Shoulder"})
                local RightShoulder = FindMotor({"RightShoulder", "Right Shoulder"})
                local LeftElbow = FindMotor({"LeftElbow", "Left Elbow"})
                local RightElbow = FindMotor({"RightElbow", "Right Elbow"})
                local LeftHip = FindMotor({"LeftHip", "Left Hip"})
                local RightHip = FindMotor({"RightHip", "Right Hip"})
                local LeftKnee = FindMotor({"LeftKnee", "Left Knee"})
                local RightKnee = FindMotor({"RightKnee", "Right Knee"})

                local function JointRotation(motor)
                    if not motor then return CFrame.identity end
                    return motor.Transform
                end

                local function GetRobotBase()
                    local look = root.CFrame.LookVector
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude < 0.001 then flatLook = Vector3.new(0, 0, -1)
                    else flatLook = flatLook.Unit end
                    local right = Vector3.new(-flatLook.Z, 0, flatLook.X)
                    local offset
                    if C.PosicaoRobo == "Na minha frente" then offset = flatLook * DISTANCIA
                    elseif C.PosicaoRobo == "Nas minhas costas" then offset = -flatLook * DISTANCIA
                    elseif C.PosicaoRobo == "No meu lado esquerdo" then offset = -right * DISTANCIA
                    elseif C.PosicaoRobo == "No meu lado direito" then offset = right * DISTANCIA
                    else offset = flatLook * DISTANCIA end
                    local position = root.Position + offset
                    return CFrame.lookAt(position, position + flatLook, Vector3.yAxis)
                end

                local baseRot = CFrame.Angles(ROT_X, ROT_Y, ROT_Z)
                C.LastNetworkUpdate = 0

                C.RoboConnection = RunService.Heartbeat:Connect(function(dt)
                    if not C.RoboAtivo then return end
                    if not character or not character.Parent then return end

                    root = character:FindFirstChild("HumanoidRootPart")
                    humanoid = character:FindFirstChildOfClass("Humanoid")
                    if not root or not humanoid then return end

                    local t = tick()
                    if t - C.LastNetworkUpdate < 0.014 then return end
                    C.LastNetworkUpdate = t

                    local baseCFrame = GetRobotBase()

                    local neckRotation = JointRotation(Neck)
                    local waistRotation = JointRotation(Waist)
                    local leftShoulderRotation = JointRotation(LeftShoulder)
                    local rightShoulderRotation = JointRotation(RightShoulder)
                    local leftElbowRotation = JointRotation(LeftElbow)
                    local rightElbowRotation = JointRotation(RightElbow)
                    local leftHipRotation = JointRotation(LeftHip)
                    local rightHipRotation = JointRotation(RightHip)
                    local leftKneeRotation = JointRotation(LeftKnee)
                    local rightKneeRotation = JointRotation(RightKnee)

                    local rotations = {
                        neckRotation,
                        waistRotation,
                        waistRotation,
                        waistRotation,
                        leftShoulderRotation,
                        leftElbowRotation,
                        leftShoulderRotation * leftElbowRotation,
                        rightShoulderRotation,
                        rightElbowRotation,
                        rightShoulderRotation * rightElbowRotation,
                        leftHipRotation,
                        leftHipRotation * leftKneeRotation,
                        rightHipRotation,
                        rightHipRotation * rightKneeRotation,
                        neckRotation
                    }

                    for i = 1, TOTAL_PROPS do
                        local data = C.Props[i]
                        if data and data.Part and data.Part.Parent then
                            local pos = parts[i]
                            local px, py, pz = rotations[i]:ToOrientation()
                            local rotation = baseRot * CFrame.Angles(px, py, pz)
                            local worldPosition =
                                baseCFrame.Position
                                + baseCFrame.RightVector * pos.X
                                + baseCFrame.UpVector * pos.Y
                                + baseCFrame.LookVector * pos.Z
                            local cf = CFrame.new(worldPosition) * baseCFrame.Rotation * rotation

                            task.spawn(function()
                                MoveProp(data, cf)
                            end)
                        end
                    end
                end)
            end
        end
    })
end

TabProps:AddSection("Verity")

do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RS = game:GetService("RunService")
    local LP = Players.LocalPlayer

    local C = {}
    C.OwnerName = LP.Name
    C.petMode = false
    C.rampageMode = false
    C.camoMode = false
    C.verityMode = false
    C.wingRemoteCache = {}
    C.PERMANENT_PROP_LOCK = {}
    C.currentCFrames = {}
    C.lastNetworkUpdate = 0
    C.lastColorUpdate = 0
    C.lastValidationTime = 0
    C.colorIndex = 1
    C.engineActiveState = false
    C.savedPositionsOnDisable = {}
    C.snapNextFrame = false
    C.witherCurrentPos = Vector3.zero
    C.lastLookAtPos = Vector3.zero
    C.isMovingState = false
    C.HEIGHT_IDLE_LOCK = 40
    C.HEIGHT_WALK_LOCK = 25
    C.HEIGHT_VERITY_LOCK = -2.5
    C.currentRuntimeHeight = -2.5
    C.CHASE_SPEED = 20
    C.BASE_ANIM_SPEED = 0.30
    C.LERP_ALPHA = 1.5
    C.TIMER_TARGET_ALL = 15.0
    C.TARGET_AREA = 50
    C.HAND_FLY_SPEED = 80
    C.GRAB_COOLDOWN = 7
    C.VOID_TIME = 15
    C.DEEP_VOID_Y = -9e9
    C.WALK_OFFSET = 0
    C.MAX_HEIGHT_THRESHOLD = 15
    C.STR_FRONT_OFFSET = 8
    C.PET_OFFSET = Vector3.new(0, 0, 12)
    C.MANUAL_ROTATION = Vector3.new(-16, 180, 0)
    C.AUTONOMOUS_BUFFER_RADIUS = 3.5
    C.MAX_VERTICAL_SPEED = 140
    C.BREATH_SPEED = 0.12
    C.BREATH_HEIGHT = 0.12
    C.GLITCH_CHANCE = 0.3
    C.GLITCH_MAX_ROT = 1
    C.verityTransitionAlpha = 0
    C.rollingRotationAngle = 0
    C.actualRollingSpeed = 0
    C.dynamicAnimTime = 0
    C.TargetPlayer = nil
    C.lastTargetSwitchTime = 0
    C.currentWalkWeight = 0
    C.movementBlend = 0
    C.multiGlitchCF = {}
    C.nextGlitchCheckFrame = {}

    do
        for i = 1, 15 do
            C.multiGlitchCF[i] = CFrame.new()
            C.nextGlitchCheckFrame[i] = 0
        end
    end

    C.handGrabState = {}
    do
        C.handGrabState[3] = { active = false, currentPos = Vector3.zero, lastTrackedCF = CFrame.new(), voidTimer = 0, isBanishActive = false }
        C.handGrabState[4] = { active = false, currentPos = Vector3.zero, lastTrackedCF = CFrame.new(), voidTimer = 0, isBanishActive = false }
    end
    C.lastGrabAttackTime = 0

    C.COLORS = {}
    do
        C.COLORS.AbyssGreen = Color3.fromRGB(255, 210, 0)
        C.COLORS.DarkAbyss = Color3.fromRGB(65, 50, 5)
        C.COLORS.Void = Color3.fromRGB(255, 210, 0)
        C.COLORS.WarningRed = Color3.fromRGB(255, 60, 0)
        C.COLORS.CamoDefault = Color3.fromRGB(120, 110, 80)
    end

    C.IdleGroup = {}
    C.WalkGroup1 = {}
    C.WalkGroup2 = {}

    do
        local function getOff(base, target) return base:ToObjectSpace(target) end
        local baseRef = CFrame.new(120.64956665039062, 47.43954086303711, -62.3380126953125, -0.9988315105438232, -0.021625487133860588, -0.04331721365451813, -0.009868338704109192, 0.966853678226471, -0.25513970851898193, 0.04739895835518837, -0.25441333651542664, -0.965937077999115)
        local baseRefW1 = CFrame.new(126.49830627441406, 29.594470977783203, -92.46394348144531, -0.9998490810394287, 0.0025938472244888544, -0.017252106219530106, 0.007644623517990112, 0.9540321230888367, -0.29960694909095764, 0.015681922435760498, -0.2996933162212372, -0.9539082646369934)
        local baseRefW2 = CFrame.new(126.49830627441406, 29.594470977783203, -92.46394348144531, -0.9998514652252197, 0.0025937585160136223, -0.017252152785658836, 0.0076445965096354485, 0.9540310502052307, -0.29961007833480835, 0.015681959688663483, -0.29969653487205505, -0.953910231590271)

        do
            C.IdleGroup[1] = getOff(baseRef, CFrame.new(120.64956665039062, 47.43954086303711, -62.3380126953125, -0.9988315105438232, -0.021625487133860588, -0.04331721365451813, -0.009868338704109192, 0.966853678226471, -0.25513970851898193, 0.04739895835518837, -0.25441333651542664, -0.965937077999115))
            C.IdleGroup[2] = getOff(baseRef, CFrame.new(120.68500518798828, 47.03154754638672, -61.574092864990234, 0.998996376991272, -0.012319700792431831, 0.04306390881538391, -0.000013122892596584279, 0.961350679397583, 0.27532726526260376, -0.044791460037231445, -0.27505069971084595, 0.9603856801986694))
            C.IdleGroup[3] = getOff(baseRef, CFrame.new(126.67286682128906, 14.04328727722168, -61.09851837158203, 0.06900809705257416, -0.9681389331817627, 0.24072611331939697, 0.9976152181625366, 0.06756940484046936, -0.014233428984880447, -0.0024867714382708073, 0.24113479256629944, 0.9704886674880981))
            C.IdleGroup[4] = getOff(baseRef, CFrame.new(113.5669937133789, 14.496644020080566, -59.124839782714844, 0.0712994933128357, 0.9913008213043213, 0.11064765602350235, -0.9941493272781372, 0.07964956760406494, -0.07295994460582733, -0.08113829046487808, -0.10479786992073059, 0.9911780953407288))
            C.IdleGroup[5] = getOff(baseRef, CFrame.new(120.71379089355469, 44.3861198425293, -61.2296142578125, 0.98240727186203, 0, -0.18675090372562408, 0, 1, 0, 0.18675090372562408, 0, 0.9824063777923584))
            C.IdleGroup[6] = getOff(baseRef, CFrame.new(120.046630859375, 29.903175354003906, -61.180877685546875, 0.06075763702392578, 0.11513201892375946, -0.991490364074707, 0.000028607435524463654, 0.9933252930641174, 0.11534685641527176, 0.9981545209884644, -0.007036857306957245, 0.06034940481185913))
            C.IdleGroup[7] = getOff(baseRef, CFrame.new(120.78498077392578, 29.8851318359375, -61.23984909057617, 0.07702977955341339, -0.06877829879522324, -0.9946557879447937, -0.00002514259540475905, 0.9976166486740112, -0.06898494809865952, 0.9970309138298035, 0.0053390879184007645, 0.07684440165758133))
            C.IdleGroup[8] = getOff(baseRef, CFrame.new(118.25951385498047, 44.634159088134766, -61.09712600708008, -0.05752766132354736, -0.19833369553089142, -0.9784463047981262, -0.06380493938922882, -0.9773316383361816, 0.20185993611812592, -0.9963029026985168, 0.07404212653636932, 0.0435698926448822))
            C.IdleGroup[9] = getOff(baseRef, CFrame.new(123.21612548828125, 44.286563873291016, -61.45082473754883, -0.06820593774318695, 0.11992166936397552, -0.9904376864433289, -0.020711660385131836, -0.9927074909210205, -0.11876999586820602, -0.9974562525749207, 0.01241290383040905, 0.07019199430942535))
            C.IdleGroup[10] = getOff(baseRef, CFrame.new(115.3191146850586, 30.09535026550293, -60.06383514404297, -0.8742965459823608, -0.12554612755775452, -0.46887898445129395, 0.08046010881662369, -0.9900954365730286, 0.11507555097341537, -0.47868093848228455, 0.06288398802280426, 0.8757346272468567))
            C.IdleGroup[11] = getOff(baseRef, CFrame.new(124.9299545288086, 29.92043113708496, -61.196922302246094, 0.46473950147628784, 0.10953525453805923, -0.8786476254463196, 0.025647558271884918, -0.9935659170150757, -0.11029602587223053, -0.885076105594635, 0.028723787516355515, -0.46455949544906616))
            C.IdleGroup[12] = getOff(baseRef, CFrame.new(121.61201477050781, 30.220687866210938, -61.414588928222656, 0.046316370368003845, 0.04518207162618637, 0.9979044795036316, 0.000010356996426708065, -0.9989765882492065, 0.045230135321617126, 0.9989268183708191, -0.002084625419229269, -0.04627080261707306))
            C.IdleGroup[13] = getOff(baseRef, CFrame.new(119.42765808105469, 30.299821853637695, -61.33236312866211, 0.048100247979164124, -0.08080373704433441, 0.9955679774284363, -0.00011639761214610189, -0.9967212677001953, -0.08089178055524826, 0.9988400936126709, 0.0037748897448182106, -0.0479513444006443))
            C.IdleGroup[14] = getOff(baseRef, CFrame.new(122.32905578613281, 0.4186230003833771, -60.64160919189453, -0.998123288154602, -0.005412478465586901, -0.06104670464992523, -0.0020048581063747406, 0.9984431266784668, -0.055743779987096786, 0.061253372579813004, -0.05551658570766449, -0.9965807199478149))
            C.IdleGroup[15] = getOff(baseRef, CFrame.new(118.22999572753906, 15.556686401367188, -61.3809700012207, -0.9938544631004333, -0.07136587053537369, 0.08466947823762894, 0.07325080037117004, -0.9971297979354858, 0.019366269931197166, 0.08304401487112045, 0.025449300184845924, 0.9962209463119507))
        end

        do
            C.WalkGroup1[1] = getOff(baseRefW1, CFrame.new(126.49830627441406, 29.594470977783203, -92.46394348144531, -0.9998490810394287, 0.0025938472244888544, -0.017252106219530106, 0.007644623517990112, 0.9540321230888367, -0.29960694909095764, 0.015681922435760498, -0.2996933162212372, -0.9539082646369934))
            C.WalkGroup1[2] = getOff(baseRefW1, CFrame.new(126.49246215820312, 29.275135040283203, -91.71905517578125, -0.022311288863420486, 0.017802033573389053, 0.9995925426483154, -0.3070925176143646, 0.9513811469078064, -0.023798085749149323, -0.9514171481132507, -0.30749836564064026, -0.01576201245188713))
            C.WalkGroup1[3] = getOff(baseRefW1, CFrame.new(131.03775024414062, 2.031785726547241, -103.8714828491211, -0.9985194206237793, -0.042536213994026184, -0.034046731889247894, -0.02315164916217327, -0.23442454636096954, 0.9718611240386963, -0.0493205189704895, 0.9712064862251282, 0.23308655619621277))
            C.WalkGroup1[4] = getOff(baseRefW1, CFrame.new(119.06922912597656, 0.18550749123096466, -86.95842742919922, 0.09176713228225708, 0.6149283051490784, -0.783225953578949, -0.9936701655387878, 0.0053681377321481705, -0.11220884323120117, -0.0647953450679779, 0.7885667681694031, 0.6115278005599976))
            C.WalkGroup1[5] = getOff(baseRefW1, CFrame.new(126.38916015625, 27.61347007751465, -90.03245544433594, 0.9956316351890564, 0.05551417917013168, -0.07507216185331345, 0.007379494607448578, 0.7547398805618286, 0.6559826731681824, 0.09307663142681122, -0.6536710858345032, 0.7510332465171814))
            C.WalkGroup1[6] = getOff(baseRefW1, CFrame.new(125.73442077636719, 22.751529693603516, -76.30439758300781, -0.9916914105415344, 0.10410591959953308, 0.07555291056632996, -0.036597251892089844, 0.3347315490245819, -0.9416024088859558, -0.12331625074148178, -0.9365449547767639, -0.3281416594982147))
            C.WalkGroup1[7] = getOff(baseRefW1, CFrame.new(125.51589965820312, 22.73541259765625, -76.28203582763672, -0.99981689453125, -0.012845861725509167, 0.014273214153945446, -0.017732663080096245, 0.3324262797832489, -0.9429624676704407, 0.00736838446045599, -0.9430423378944397, -0.33259326219558716))
            C.WalkGroup1[8] = getOff(baseRefW1, CFrame.new(124.04273986816406, 28.202518463134766, -90.11971282958984, 0.9430281519889832, -0.32027125358581543, -0.09013251960277557, -0.33133769035339355, -0.8794008493423462, -0.34186235070228577, 0.030226171016693115, 0.3522501289844513, -0.935416579246521))
            C.WalkGroup1[9] = getOff(baseRefW1, CFrame.new(128.30386352539062, 28.102333068847656, -89.46344757080078, 0.9608992338180542, 0.208899587392807, -0.1817515790462494, 0.25180667638778687, -0.932266116142273, 0.25975263118743896, -0.11517826467752457, -0.29536134004592896, -0.9484161138534546))
            C.WalkGroup1[10] = getOff(baseRefW1, CFrame.new(119.2117919921875, 15.249920845031738, -84.94314575195312, 0.9943095445632935, 0.017796030268073082, -0.10503261536359787, 0.028687644749879837, -0.994256854057312, 0.10311679542064667, -0.10259410738945007, -0.10554315149784088, -0.9891075491905212))
            C.WalkGroup1[11] = getOff(baseRefW1, CFrame.new(131.2987060546875, 14.502906799316406, -93.74832153320312, 0.9973878860473633, -0.027913875877857208, -0.06662031263113022, 0.020270831882953644, -0.7770786881446838, 0.629075825214386, -0.06932926923036575, -0.6287821531295776, -0.7744839191436768))
            C.WalkGroup1[12] = getOff(baseRefW1, CFrame.new(127.072998046875, 23.333717346191406, -76.7569351196289, 0.9817987680435181, 0.18005992472171783, 0.060408201068639755, 0.18935826420783997, -0.952558159828186, -0.23829339444637299, 0.01463509351015091, 0.24539482593536377, -0.9693166017532349))
            C.WalkGroup1[13] = getOff(baseRefW1, CFrame.new(124.34113311767578, 23.690364837646484, -76.7562255859375, 0.9857381582260132, -0.08913993835449219, 0.14273914694786072, -0.1324753761291504, -0.9341053366661072, 0.33151546120643616, 0.10378171503543854, -0.34569698572158813, -0.9325920939445496))
            C.WalkGroup1[14] = getOff(baseRefW1, CFrame.new(128.67425537109375, -1.330122470855713, -63.095497131347656, 0.995278537273407, 0.07170845568180084, -0.0654103010892868, -0.00692090904340148, 0.724632978439331, 0.6890980005264282, 0.09681262075901031, -0.6853917837142944, 0.7217090129852295))
            C.WalkGroup1[15] = getOff(baseRefW1, CFrame.new(122.96495819091797, 9.598209381103516, -82.35009002685547, 0.997429370880127, -0.052172236144542694, -0.0491195023059845, -0.07160086929798126, -0.6986374855041504, -0.7118854522705078, 0.0028239600360393524, 0.7135725021362305, -0.700575053691864))
        end

        do
            C.WalkGroup2[1] = getOff(baseRefW2, CFrame.new(126.49830627441406, 29.594470977783203, -92.46394348144531, -0.9998514652252197, 0.0025937585160136223, -0.017252152785658836, 0.0076445965096354485, 0.9540310502052307, -0.29961007833480835, 0.015681959688663483, -0.29969653487205505, -0.953910231590271))
            C.WalkGroup2[2] = getOff(baseRefW2, CFrame.new(126.53009033203125, 29.275135040283203, -91.70267486572266, -0.022311203181743622, 0.017802052199840546, 0.9995925426483154, -0.30709248781204224, 0.9513811087303161, -0.02379809319972992, -0.951417088508606, -0.30749833583831787, -0.015762098133563995))
            C.WalkGroup2[3] = getOff(baseRefW2, CFrame.new(132.22059631347656, 1.995898962020874, -90.79121398925781, -0.9985146522521973, -0.042534489184617996, -0.034049078822135925, -0.023148924112319946, -0.23452624678611755, 0.9718342423439026, -0.0493217371404171, 0.9711807370185852, 0.2331928014755249))
            C.WalkGroup2[4] = getOff(baseRefW2, CFrame.new(119.32237243652344, 1.8937989473342896, -103.31941986083984, 0.11586364358663559, 0.10886246711015701, -0.987281322479248, -0.9897393584251404, -0.07102220505475998, -0.1239846795797348, -0.08361426740884781, 0.9915185570716858, 0.09951663762331009))
            C.WalkGroup2[5] = getOff(baseRefW2, CFrame.new(126.38916015625, 27.61347007751465, -90.03245544433594, 0.9956316351890564, 0.055514223873615265, -0.07507220655679703, 0.007379494607448578, 0.7547398805618286, 0.6559826731681824, 0.09307654201984406, -0.6536710858345032, 0.7510332465171814))
            C.WalkGroup2[6] = getOff(baseRefW2, CFrame.new(125.73442077636719, 22.751529693603516, -76.30439758300781, -0.9916908740997314, 0.10410591959953308, 0.07555291056632996, -0.036597251892089844, 0.3347312808036804, -0.9416024088859558, -0.12331618368625641, -0.9365449547767639, -0.3281419277191162))
            C.WalkGroup2[7] = getOff(baseRefW2, CFrame.new(125.51589965820312, 22.73541259765625, -76.28203582763672, -0.9998155832290649, -0.01284581795334816, 0.014273129403591156, -0.017732571810483932, 0.3324250876903534, -0.9429630041122437, 0.0073683844947947025, -0.9430422186851501, -0.33259156346321106))
            C.WalkGroup2[8] = getOff(baseRefW2, CFrame.new(124.04273986816406, 28.202518463134766, -90.11971282958984, 0.9430636763572693, -0.3022449314594269, 0.13885022699832916, -0.3312376141548157, -0.8913412094116211, 0.3095170557498932, 0.030212700366973877, -0.3378865718841553, -0.9407062530517578))
            C.WalkGroup2[9] = getOff(baseRefW2, CFrame.new(128.30386352539062, 28.102333068847656, -89.46344757080078, 0.9609078168869019, 0.2764838933944702, 0.014569987542927265, 0.25177404284477234, -0.8507171869277954, -0.4613998234272003, -0.11517467349767685, 0.44703131914138794, -0.8870722651481628))
            C.WalkGroup2[10] = getOff(baseRefW2, CFrame.new(119.67819213867188, 15.331889152526855, -94.51163482666016, 0.9943045973777771, -0.03331932798027992, -0.1012267917394638, 0.028701134026050568, -0.831045925617218, 0.5554617643356323, -0.10263171046972275, -0.5552045702934265, -0.8253591060638428))
            C.WalkGroup2[11] = getOff(baseRefW2, CFrame.new(132.52810668945312, 15.628028869628906, -82.0294418334961, 0.9973894953727722, -0.021877866238355637, -0.0688156932592392, 0.020227424800395966, -0.8301950693130493, 0.5571044087409973, -0.06931855529546738, -0.557045042514801, -0.8275853395462036))
            C.WalkGroup2[12] = getOff(baseRefW2, CFrame.new(127.072998046875, 23.333717346191406, -76.7569351196289, 0.9818053841590881, 0.18467366695404053, -0.04420299455523491, 0.18932312726974487, -0.9340088367462158, 0.3029642403125763, 0.014663513749837875, -0.3058205544948578, -0.9519778490066528))
            C.WalkGroup2[13] = getOff(baseRefW2, CFrame.new(124.34113311767578, 23.690364837646484, -76.7562255859375, 0.9857377409934998, -0.15272948145866394, 0.07067477703094482, -0.13246934115886688, -0.9632024765014648, -0.23387481272220612, 0.10379339009523392, 0.22117699682712555, -0.9696969985961914))
            C.WalkGroup2[14] = getOff(baseRefW2, CFrame.new(128.68243408203125, -1.3301281929016113, -70.8410873413086, 0.995278537273407, 0.07170845568180084, -0.0654103010892868, -0.00692090904340148, 0.7246330380439758, 0.689098060131073, 0.09681262820959091, -0.6853918433189392, 0.7217090129852295))
            C.WalkGroup2[15] = getOff(baseRefW2, CFrame.new(122.27103424072266, 9.802433013916016, -74.06238555908203, 0.997429370880127, -0.05217228829860687, -0.0491195023059845, -0.07160086929798126, -0.6986383199691772, -0.7118854522705078, 0.002823973074555397, 0.7135725021362305, -0.7005746364593506))
        end
    end

    local function ValidateAndLockProps()
        local trafficCones = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
        if not trafficCones then return false end
        local targetName = (C.OwnerName == "terasiremik") and "Propterasiremik" or ("Prop" .. C.OwnerName)
        local rawProps = {}
        for _, v in ipairs(trafficCones:GetChildren()) do
            if v.Name == targetName then table.insert(rawProps, v) end
        end
        local changed = false
        for id, storedProp in pairs(C.PERMANENT_PROP_LOCK) do
            if not storedProp or not storedProp.Parent then
                C.PERMANENT_PROP_LOCK[id] = nil
                C.currentCFrames[id] = nil
                changed = true
            end
        end
        for _, prop in ipairs(rawProps) do
            local alreadyRegistered = false
            for id, storedProp in pairs(C.PERMANENT_PROP_LOCK) do
                if storedProp == prop then alreadyRegistered = true break end
            end
            if not alreadyRegistered then
                for id = 1, #C.IdleGroup do
                    if not C.PERMANENT_PROP_LOCK[id] then
                        C.PERMANENT_PROP_LOCK[id] = prop
                        C.currentCFrames[id] = nil
                        changed = true
                        break
                    end
                end
            end
        end
        if changed then
            C.wingRemoteCache = {}
            for id = 1, #C.IdleGroup do
                if C.PERMANENT_PROP_LOCK[id] and C.PERMANENT_PROP_LOCK[id].Parent then
                    C.wingRemoteCache[id] = C.PERMANENT_PROP_LOCK[id]
                end
            end
        end
        return true
    end

    local function FindNearestPrey()
        local nearestPlayer = nil
        local shortestDistance = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local torso = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and torso then
                    local dist = (C.witherCurrentPos - torso.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        nearestPlayer = p
                    end
                end
            end
        end
        return nearestPlayer
    end

    local function GetGroundColor()
        local castOrigin = C.witherCurrentPos
        local castDirection = Vector3.new(0, -100, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local ignoreList = {LP.Character}
        for _, prop in pairs(C.PERMANENT_PROP_LOCK) do
            if prop then table.insert(ignoreList, prop) end
        end
        raycastParams.FilterDescendantsInstances = ignoreList
        local raycastResult = workspace:Raycast(castOrigin, castDirection, raycastParams)
        if raycastResult and raycastResult.Instance then
            return raycastResult.Instance.Color
        end
        return C.COLORS.CamoDefault
    end

    local function getTerrorColor(t, offset)
        if not C.engineActiveState then return C.COLORS.DarkAbyss end
        if C.camoMode then return GetGroundColor()
        elseif C.rampageMode then
            local cycle = (t * 2 + (offset * 0.1)) % 1
            if cycle < 0.5 then return C.COLORS.WarningRed:Lerp(C.COLORS.Void, cycle * 2)
            else return C.COLORS.Void:Lerp(C.COLORS.WarningRed, (cycle - 0.5) * 2) end
        else
            local cycle = (t * 0.5 + (offset * 0.1)) % 1
            if cycle < 0.5 then return C.COLORS.AbyssGreen:Lerp(C.COLORS.DarkAbyss, cycle * 2)
            else return C.COLORS.DarkAbyss:Lerp(C.COLORS.Void, (cycle - 0.5) * 2) end
        end
    end

    local function getTargetTorso(player)
        if not player or not player.Character or not player.Character.Parent then return nil end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        return player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    end

    local function ToggleVerityEngine(state)
        if state then
            C.engineActiveState = true
            C.petMode = true
            C.snapNextFrame = true
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local ownerRoot = char.HumanoidRootPart
                C.witherCurrentPos = ownerRoot.Position + Vector3.new(0, C.HEIGHT_VERITY_LOCK, -C.PET_OFFSET.Z)
                C.lastLookAtPos = ownerRoot.Position
            end
            ValidateAndLockProps()
            table.clear(C.savedPositionsOnDisable)
            C.verityMode = true
        else
            C.engineActiveState = false
            C.petMode = false
            table.clear(C.savedPositionsOnDisable)
            table.clear(C.currentCFrames)
            C.rampageMode = false
            C.camoMode = false
            C.verityMode = false
            C.TargetPlayer = nil
        end
    end

    TabProps:AddButton({
        Name = "Verity Body",
        Callback = function ()
            do
                local Player = Players.LocalPlayer
                local Character = Player.Character or Player.CharacterAdded:Wait()
                local Humanoid = Character:WaitForChild("Humanoid")
                ReplicatedStorage.RE["1Too1l"]:InvokeServer("PickingTools", "PropMaker")
                local Tool = Player.Backpack:WaitForChild("PropMaker", 10)
                if Tool then Humanoid:EquipTool(Tool) end
                task.wait(1)
                local HRP = Character:WaitForChild("HumanoidRootPart")
                local RE = ReplicatedStorage.RE["1Clea1rTool1s"]
                local PropMake = workspace[Player.Name].PropMaker.Tool_PropMake
                local Props = {
                    {"RequestingPropName", "HalloweenPumkin2", "Halloween", 1},
                    {"RequestingPropName", "Block1", "Building", 1},
                    {"RequestingPropFeatureName", "FloorCushion", "Furniture", 3},
                    {"RequestingPropName", "PillarSmall", "Building", 4},
                    {"RequestingPropName", "CylinderPillarLarge", "Building", 6}
                }
                local spawned = 0
                for _, data in ipairs(Props) do
                    for i = 1, data[4] do
                        RE:FireServer(data[1], data[2], data[3])
                        task.wait(0.5)
                        local Model = workspace.Model
                        local Children = Model:GetChildren()
                        local Prop = Children[#Children]
                        if Prop then
                            spawned = spawned + 1
                            local Position = HRP.Position + HRP.CFrame.LookVector * 7 + HRP.CFrame.RightVector * (((spawned - 1) % 5) - 2) * 3
                            PropMake:FireServer(Prop, Position)
                        end
                        task.wait(1)
                    end
                end
            end
        end
    })

    TabProps:AddToggle({
        Name = "Verity",
        Description = "Ativa/Desativa o Verity Engine",
        Default = false,
        Callback = function(state)
            ToggleVerityEngine(state)
        end
    })

    RS.Heartbeat:Connect(function(dt)
        if not C.petMode then return end

        local t = tick()

        if t - C.lastValidationTime > 0.8 then
            ValidateAndLockProps()
            C.lastValidationTime = t
        end

        if not C.engineActiveState then
            if t - C.lastNetworkUpdate > 0.014 then
                local canUpdateColor = (t - C.lastColorUpdate > 0.05)
                for i = 1, #C.IdleGroup do
                    local prop = C.wingRemoteCache[i]
                    if prop and prop.Parent then
                        local currentObjectCF = prop.CFrame
                        task.spawn(function()
                            local cfR = prop:FindFirstChild("SetCurrentCFrame")
                            if cfR then pcall(function() cfR:InvokeServer(currentObjectCF) end) end
                            if canUpdateColor and i == C.colorIndex then
                                local crR = prop:FindFirstChild("ChangePropColor")
                                if crR then pcall(function() crR:InvokeServer(getTerrorColor(t, i)) end) end
                            end
                        end)
                    end
                end
                if canUpdateColor then
                    C.colorIndex = (C.colorIndex % #C.IdleGroup) + 1
                    C.lastColorUpdate = t
                end
                C.lastNetworkUpdate = t
            end
            return
        end

        local totalProps = 0
        for i = 1, #C.IdleGroup do
            if C.wingRemoteCache[i] then totalProps = totalProps + 1 end
        end
        if totalProps < 1 then return end

        if C.rampageMode then
            local currentTargetTorso = getTargetTorso(C.TargetPlayer)
            if not C.TargetPlayer or not currentTargetTorso or (t - C.lastTargetSwitchTime >= C.TIMER_TARGET_ALL) then
                C.TargetPlayer = FindNearestPrey()
                C.lastTargetSwitchTime = t
            end
        end

        local currentTarget = C.TargetPlayer
        local isPetState = false

        if not currentTarget or not getTargetTorso(currentTarget) then
            currentTarget = LP
            isPetState = true
        end

        local targetTorso = getTargetTorso(currentTarget)

        C.verityTransitionAlpha = C.verityTransitionAlpha + ((C.verityMode and 1 or 0) - C.verityTransitionAlpha) * math.clamp(dt * 4, 0, 1)

        local desiredHeightTarget = C.HEIGHT_VERITY_LOCK
        if C.verityMode then
            if C.isMovingState then desiredHeightTarget = C.HEIGHT_WALK_LOCK
            else desiredHeightTarget = C.HEIGHT_IDLE_LOCK end
        end
        C.currentRuntimeHeight = C.currentRuntimeHeight + (desiredHeightTarget - C.currentRuntimeHeight) * math.clamp(dt * 6, 0, 1)

        local oldPos = C.witherCurrentPos
        local realGroundVelocity = 0

        if targetTorso then
            local idealPos
            local targetHeight = targetTorso.Position.Y + C.currentRuntimeHeight

            local currentHeightDelta = math.abs(C.witherCurrentPos.Y - targetHeight)
            if currentHeightDelta > C.MAX_HEIGHT_THRESHOLD then
                local targetLookVector = targetTorso.CFrame.LookVector
                local frontFlatVector = Vector3.new(targetLookVector.X, 0, targetLookVector.Z).Unit
                if frontFlatVector.Magnitude ~= frontFlatVector.Magnitude then frontFlatVector = Vector3.new(0, 0, -1) end
                local teleportBase = targetTorso.Position + (frontFlatVector * C.STR_FRONT_OFFSET)
                C.witherCurrentPos = Vector3.new(teleportBase.X, targetHeight, teleportBase.Z)
            end

            local currentDistanceToTarget = (Vector3.new(targetTorso.Position.X, 0, targetTorso.Position.Z) - Vector3.new(C.witherCurrentPos.X, 0, C.witherCurrentPos.Z)).Magnitude
            if currentDistanceToTarget > (C.PET_OFFSET.Z + C.AUTONOMOUS_BUFFER_RADIUS) then
                local headingDir = (C.witherCurrentPos - targetTorso.Position).Unit
                local flatHeading = Vector3.new(headingDir.X, 0, headingDir.Z).Unit
                if flatHeading.Magnitude ~= flatHeading.Magnitude then flatHeading = targetTorso.CFrame.LookVector end
                local worldTargetPoint = targetTorso.Position + (flatHeading * C.PET_OFFSET.Z)
                idealPos = Vector3.new(worldTargetPoint.X, targetHeight, worldTargetPoint.Z)
            else
                idealPos = Vector3.new(C.witherCurrentPos.X, targetHeight, C.witherCurrentPos.Z)
            end

            C.lastLookAtPos = targetTorso.Position

            local distanceToIdeal = (Vector3.new(idealPos.X, 0, idealPos.Z) - Vector3.new(C.witherCurrentPos.X, 0, C.witherCurrentPos.Z)).Magnitude
            if distanceToIdeal > 0.1 then
                local moveDirection = (idealPos - C.witherCurrentPos).Unit
                local step = moveDirection * (C.CHASE_SPEED * dt)
                if step.Magnitude > (idealPos - C.witherCurrentPos).Magnitude then
                    C.witherCurrentPos = idealPos
                else
                    C.witherCurrentPos = C.witherCurrentPos + step
                end
            end

            local currentY = C.witherCurrentPos.Y
            local deltaY = targetHeight - currentY
            local maxVerticalStep = C.MAX_VERTICAL_SPEED * dt
            local finalY = currentY + math.clamp(deltaY, -maxVerticalStep, maxVerticalStep)
            C.witherCurrentPos = Vector3.new(C.witherCurrentPos.X, finalY, C.witherCurrentPos.Z)

            local groundDelta = Vector3.new(C.witherCurrentPos.X - oldPos.X, 0, C.witherCurrentPos.Z - oldPos.Z).Magnitude
            realGroundVelocity = groundDelta / dt

            if realGroundVelocity > 0.5 then
                C.isMovingState = true
                C.dynamicAnimTime = C.dynamicAnimTime + (dt * realGroundVelocity * C.BASE_ANIM_SPEED)
                C.actualRollingSpeed = C.actualRollingSpeed + ((-realGroundVelocity * dt * 3.5) - C.actualRollingSpeed) * math.clamp(dt * 12, 0, 1)
            else
                C.isMovingState = false
                C.dynamicAnimTime = C.dynamicAnimTime + (0 - (C.dynamicAnimTime % (math.pi * 2))) * math.clamp(dt * 4, 0, 1)
                C.actualRollingSpeed = C.actualRollingSpeed * math.clamp(1 - (dt * 4.5), 0, 1)
            end
            C.rollingRotationAngle = C.rollingRotationAngle + C.actualRollingSpeed
        else
            C.isMovingState = false
        end

        if not isPetState and targetTorso and C.verityMode then
            local distanceToTarget = (C.witherCurrentPos - targetTorso.Position).Magnitude
            if distanceToTarget <= C.TARGET_AREA and (t - C.lastGrabAttackTime >= C.GRAB_COOLDOWN) then
                if not C.handGrabState[3].active and not C.handGrabState[4].active then
                    C.lastGrabAttackTime = t
                    for _, armId in ipairs({3, 4}) do
                        if C.currentCFrames[armId] then
                            C.handGrabState[armId].active = true
                            C.handGrabState[armId].currentPos = C.currentCFrames[armId].Position
                            C.handGrabState[armId].lastTrackedCF = C.currentCFrames[armId]
                            C.handGrabState[armId].voidTimer = 0
                            C.handGrabState[armId].isBanishActive = false
                        end
                    end
                end
            end
        end

        local forwardVector = (C.lastLookAtPos - C.witherCurrentPos).Unit
        local flatForward = Vector3.new(forwardVector.X, 0, forwardVector.Z).Unit
        if flatForward.Magnitude ~= flatForward.Magnitude then flatForward = Vector3.new(0, 0, -1) end
        local finalPos = CFrame.fromMatrix(C.witherCurrentPos, flatForward:Cross(Vector3.new(0, 1, 0)), Vector3.new(0, 1, 0), -flatForward)

        local currentWalkOffset = C.isMovingState and C.WALK_OFFSET or 0
        local rotCF = CFrame.Angles(math.rad(C.MANUAL_ROTATION.X), math.rad(C.MANUAL_ROTATION.Y + currentWalkOffset), math.rad(C.MANUAL_ROTATION.Z))

        if C.isMovingState then
            C.currentWalkWeight = (math.sin(C.dynamicAnimTime) + 1) / 2
            C.movementBlend = math.min(C.movementBlend + (dt * 4.0), 1)
        else
            C.movementBlend = math.max(C.movementBlend - (dt * 2.0), 0)
        end

        local actualAlpha = math.clamp(C.LERP_ALPHA * dt * 60, 0, 1)
        if C.snapNextFrame then actualAlpha = 1 end

        for id = 1, 15 do
            if t >= C.nextGlitchCheckFrame[id] then
                if math.random() <= C.GLITCH_CHANCE then
                    local rotX = math.random(-C.GLITCH_MAX_ROT, C.GLITCH_MAX_ROT)
                    local rotY = math.random(-C.GLITCH_MAX_ROT, C.GLITCH_MAX_ROT)
                    local rotZ = math.random(-C.GLITCH_MAX_ROT, C.GLITCH_MAX_ROT)
                    C.multiGlitchCF[id] = CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))
                    C.nextGlitchCheckFrame[id] = t + math.random(0.04, 0.12)
                else
                    C.multiGlitchCF[id] = CFrame.new()
                    C.nextGlitchCheckFrame[id] = t + math.random(0.1, 0.4)
                end
            end
        end

        for i = 1, #C.IdleGroup do
            local offsetIdle = C.IdleGroup[i]
            local offsetW1 = C.WalkGroup1[i]
            local offsetW2 = C.WalkGroup2[i]

            if offsetIdle and offsetW1 and offsetW2 then
                local blendedWalkOffset = offsetW1:Lerp(offsetW2, C.currentWalkWeight)
                local finalOffset = offsetIdle:Lerp(blendedWalkOffset, C.movementBlend)
                local targetCF = finalPos * rotCF

                if C.verityMode then
                    targetCF = targetCF * finalOffset
                else
                    if i == 1 or i == 2 then
                        local headPos = finalPos.Position
                        local lookDirection = (C.lastLookAtPos - headPos)
                        local flatLookDirection = Vector3.new(lookDirection.X, 0, lookDirection.Z).Unit
                        if flatLookDirection.Magnitude ~= flatLookDirection.Magnitude then flatLookDirection = Vector3.new(0, 0, -1) end
                        local lookTargetCFrame = CFrame.lookAt(headPos, headPos + flatLookDirection)
                        targetCF = lookTargetCFrame * CFrame.Angles(C.rollingRotationAngle, math.rad(180), 0) * finalOffset
                    else
                        targetCF = CFrame.new(C.witherCurrentPos.X, C.DEEP_VOID_Y, C.witherCurrentPos.Z)
                    end
                end

                local breathY = math.sin(t * C.BREATH_SPEED + (i * 0.15)) * C.BREATH_HEIGHT
                targetCF = targetCF * CFrame.new(0, breathY, 0)

                if C.multiGlitchCF[i] then targetCF = targetCF * C.multiGlitchCF[i] end

                if (i == 3 or i == 4) and C.handGrabState[i].active and C.verityMode then
                    if targetTorso and not isPetState then
                        local pTarget = targetTorso.Position
                        local targetChar = targetTorso.Parent
                        local currentSeat = targetChar and targetChar:FindFirstChildOfClass("Humanoid") and targetChar:FindFirstChildOfClass("Humanoid").SeatPart

                        if currentSeat and (currentSeat:IsA("Seat") or currentSeat:IsA("VehicleSeat")) then
                            C.handGrabState[i].isBanishActive = true
                        end

                        if C.handGrabState[i].isBanishActive then
                            C.handGrabState[i].voidTimer = C.handGrabState[i].voidTimer + dt
                            local voidCF = CFrame.new(pTarget.X, C.DEEP_VOID_Y, pTarget.Z)
                            C.handGrabState[i].currentPos = voidCF.Position
                            C.currentCFrames[i] = voidCF
                            if currentSeat then
                                task.spawn(function() pcall(function() currentSeat.CFrame = voidCF end) end)
                            elseif targetTorso then
                                task.spawn(function() pcall(function() targetTorso.CFrame = voidCF end) end)
                            end
                            if C.handGrabState[i].voidTimer >= C.VOID_TIME then
                                C.handGrabState[i].active = false
                                C.handGrabState[i].isBanishActive = false
                            end
                        else
                            local dirToTarget = (pTarget - C.handGrabState[i].currentPos).Unit
                            local moveStep = dirToTarget * (C.HAND_FLY_SPEED * dt)
                            if moveStep.Magnitude > (pTarget - C.handGrabState[i].currentPos).Magnitude then
                                C.handGrabState[i].currentPos = pTarget
                            else
                                C.handGrabState[i].currentPos = C.handGrabState[i].currentPos + moveStep
                            end
                            local handLookCF = CFrame.lookAt(C.handGrabState[i].currentPos, pTarget)
                            if handLookCF.X ~= handLookCF.X then handLookCF = CFrame.new(C.handGrabState[i].currentPos) end
                            C.handGrabState[i].lastTrackedCF = handLookCF
                            C.currentCFrames[i] = handLookCF
                        end
                    else
                        C.handGrabState[i].active = false
                    end
                else
                    if not C.currentCFrames[i] or C.snapNextFrame then
                        C.currentCFrames[i] = targetCF
                    else
                        C.currentCFrames[i] = C.currentCFrames[i]:Lerp(targetCF, actualAlpha)
                    end
                end
            end
        end

        if C.snapNextFrame then C.snapNextFrame = false end

        if t - C.lastGrabAttackTime >= 4.0 and not (C.handGrabState[3].isBanishActive or C.handGrabState[4].isBanishActive) then
            C.handGrabState[3].active = false
            C.handGrabState[4].active = false
        end

        if t - C.lastNetworkUpdate > 0.014 then
            local canUpdateColor = (t - C.lastColorUpdate > 0.05)
            for i = 1, #C.IdleGroup do
                local prop = C.wingRemoteCache[i]
                local targetCFrame = C.currentCFrames[i]
                if prop and targetCFrame and targetCFrame.X == targetCFrame.X then
                    task.spawn(function()
                        local cfR = prop:FindFirstChild("SetCurrentCFrame")
                        if cfR then pcall(function() cfR:InvokeServer(targetCFrame) end) end
                        if canUpdateColor and i == C.colorIndex then
                            local crR = prop:FindFirstChild("ChangePropColor")
                            if crR then pcall(function() crR:InvokeServer(getTerrorColor(t, i)) end) end
                        end
                    end)
                end
            end
            if canUpdateColor then
                C.colorIndex = (C.colorIndex % #C.IdleGroup) + 1
                C.lastColorUpdate = t
            end
            C.lastNetworkUpdate = t
        end
    end)
end

TabPersonagens = Window:MakeTab({"Personagens", "rbxassetid://11833765861"})

_G.BS = {}
_G.BS.Players = game:GetService("Players")
_G.BS.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.BS.LocalPlayer = _G.BS.Players.LocalPlayer
_G.BS.PlacedBlocks = {}

_G.BS.SetupBody = function()
    local char = _G.BS.LocalPlayer.Character or _G.BS.LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local Remotes = _G.BS.ReplicatedStorage:WaitForChild("Remotes")
    task.wait(0.5)
    local inc = Remotes:WaitForChild("IncrementBodySize")
    for i = 1, 4 do
        pcall(function() inc:FireServer(true) end)
        task.wait(0.1)
    end
end

_G.BS.SetupOutfit = function()
    local args = { [1] = "Load"; [2] = "BH-AE-e1f20b77ae924c289ad32cda1960c718" }
    pcall(function()
        _G.BS.ReplicatedStorage:WaitForChild("Remotes", 9e9)
            :WaitForChild("AvatarEditorOutfitCodes", 9e9)
            :InvokeServer(unpack(args))
    end)
end

_G.BS.CalcularPosicao = function(mouse, blockSize)
    local target = mouse.Target
    local surface = mouse.TargetSurface
    local normalVec = Vector3.FromNormalId(surface)
    local pos

    if target and target:IsA("BasePart") and _G.BS.PlacedBlocks[target] then
        pos = target.Position + normalVec * blockSize
    elseif target and target:IsA("Model") and _G.BS.PlacedBlocks[target] then
        local primary = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
        if primary then
            pos = primary.Position + normalVec * blockSize
        else
            pos = mouse.Hit.Position
        end
    else
        pos = mouse.Hit.Position
        local snapX = (normalVec.X == 0)
        local snapY = (normalVec.Y == 0)
        local snapZ = (normalVec.Z == 0)
        local x, y, z = pos.X, pos.Y, pos.Z
        if snapX then
            x = math.floor(x / blockSize + 0.5) * blockSize
        else
            x = x + normalVec.X * (blockSize / 2)
        end
        if snapY then
            y = math.floor(y / blockSize + 0.5) * blockSize
        else
            y = y + normalVec.Y * (blockSize / 2)
        end
        if snapZ then
            z = math.floor(z / blockSize + 0.5) * blockSize
        else
            z = z + normalVec.Z * (blockSize / 2)
        end
        pos = Vector3.new(x, y, z)
    end
    return pos
end

_G.BS.IsSpawnBlock = function(part)
    if not part then return false end
    if _G.BS.PlacedBlocks[part] then return true end
    if part:IsA("Model") then
        if part.Name == "SlimeBlock" then return true end
        local primary = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart")
        if primary and primary.Size == Vector3.new(3, 3, 3) then return true end
        return false
    end
    if part:IsA("Part") then
        if part.Name == "Bloco com Fisica" then return true end
        if part.Size == Vector3.new(3, 3, 3) then
            for _, d in ipairs(part:GetChildren()) do
                if d:IsA("Decal") or d:IsA("Texture") then return true end
            end
            return true
        end
    end
    return false
end

_G.BS.SpawnarBloco = function(modelo, mouse)
    if not modelo or not mouse.Hit then return end

    local pos = _G.BS.CalcularPosicao(mouse, 3)

    local clone = modelo:Clone()
    clone.Name = modelo.Name

    local parts = {}
    for _, p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then
            table.insert(parts, p)
        end
    end
    if #parts == 0 then clone:Destroy() return end

    local minV = Vector3.new(math.huge, math.huge, math.huge)
    local maxV = Vector3.new(-math.huge, -math.huge, -math.huge)
    for _, p in ipairs(parts) do
        local cf = p.CFrame
        local half = p.Size / 2
        local corners = {
            cf * Vector3.new(half.X, half.Y, half.Z),
            cf * Vector3.new(-half.X, half.Y, half.Z),
            cf * Vector3.new(half.X, -half.Y, half.Z),
            cf * Vector3.new(half.X, half.Y, -half.Z),
            cf * Vector3.new(-half.X, -half.Y, half.Z),
            cf * Vector3.new(half.X, -half.Y, -half.Z),
            cf * Vector3.new(-half.X, half.Y, -half.Z),
            cf * Vector3.new(-half.X, -half.Y, -half.Z),
        }
        for _, c in ipairs(corners) do
            minV = Vector3.new(math.min(minV.X, c.X), math.min(minV.Y, c.Y), math.min(minV.Z, c.Z))
            maxV = Vector3.new(math.max(maxV.X, c.X), math.max(maxV.Y, c.Y), math.max(maxV.Z, c.Z))
        end
    end

    local tamanhoAtual = maxV - minV
    local maiorLado = math.max(tamanhoAtual.X, tamanhoAtual.Y, tamanhoAtual.Z)
    if maiorLado <= 0 then maiorLado = 1 end
    local escala = 3 / maiorLado

    local centroAtual = (minV + maxV) / 2

    for _, p in ipairs(parts) do
        p.Anchored = true
        p.CanCollide = true
        p.Massless = true

        local rotacao = p.CFrame - p.CFrame.Position
        local posRelativa = (p.Position - centroAtual) * escala
        p.Size = p.Size * escala
        p.CFrame = CFrame.new(pos) * CFrame.new(posRelativa) * rotacao
    end

    clone.PrimaryPart = parts[1]
    clone.Parent = workspace

    _G.BS.PlacedBlocks[clone] = true
    for _, p in ipairs(parts) do
        _G.BS.PlacedBlocks[p] = true
    end
end

_G.BS.CreatePicareta = function()
    local LP = _G.BS.LocalPlayer
    local RS = _G.BS.ReplicatedStorage
    local isBlock = _G.BS.IsSpawnBlock

    local tool = Instance.new("Tool")
    tool.Name = "Picareta"
    tool.RequiresHandle = true
    tool.CanBeDropped = true
    tool.TextureId = "rbxassetid://113653000915679"

    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(0.1, 0.1, 0.1)
    h.Massless = true
    h.Anchored = false
    h.CanCollide = false
    h.Transparency = 0.5
    h.Color = Color3.fromRGB(255, 0, 0)
    local m = Instance.new("SpecialMesh", h)
    m.MeshType = Enum.MeshType.Sphere
    m.Scale = Vector3.new(0.05, 0.05, 0.05)
    h.Parent = tool

    tool.Equipped:Connect(function(mouse)
        local char = tool.Parent
        if char and char:FindFirstChild("Humanoid")
            and char.Humanoid.RigType == Enum.HumanoidRigType.R15 then
            local w = {129886532469170}
            pcall(function()
                RS:WaitForChild("Remotes"):WaitForChild("Wear"):InvokeServer(unpack(w))
            end)
            mouse.Button1Down:Connect(function()
                local hum = char:FindFirstChildOfClass("Humanoid")
                local anim = hum and hum:FindFirstChildOfClass("Animator")
                if anim then
                    local a = Instance.new("Animation")
                    a.AnimationId = "rbxassetid://2410679501"
                    anim:LoadAnimation(a):Play()
                end
                local target = mouse.Target
                if target then
                    if target:IsA("Model") and isBlock(target) then
                        _G.BS.PlacedBlocks[target] = nil
                        for _, d in ipairs(target:GetDescendants()) do
                            _G.BS.PlacedBlocks[d] = nil
                        end
                        target:Destroy()
                    elseif target:IsA("BasePart") and isBlock(target) then
                        local parentModel = target:FindFirstAncestorOfClass("Model")
                        if parentModel and _G.BS.PlacedBlocks[parentModel] then
                            _G.BS.PlacedBlocks[parentModel] = nil
                            for _, d in ipairs(parentModel:GetDescendants()) do
                                _G.BS.PlacedBlocks[d] = nil
                            end
                            parentModel:Destroy()
                        else
                            _G.BS.PlacedBlocks[target] = nil
                            target:Destroy()
                        end
                    end
                end
            end)
        end
    end)

    tool.Unequipped:Connect(function()
        local w = {129886532469170}
        pcall(function()
            RS:WaitForChild("Remotes"):WaitForChild("Wear"):InvokeServer(unpack(w))
        end)
    end)

    tool.Parent = LP.Backpack
end

_G.BS.CreateSpawnTool = function(textureId, imageId, hasPhysics)
    local LP = _G.BS.LocalPlayer
    local tool = Instance.new("Tool")
    tool.Name = ""
    tool.TextureId = textureId
    tool.CanBeDropped = false
    tool.Parent = LP.Backpack

    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(1.5, 1.5, 1.5)
    h.Anchored = false
    h.CanCollide = false
    h.Color = Color3.fromRGB(255, 255, 255)
    h.Parent = tool

    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local d = Instance.new("Decal")
        d.Texture = imageId
        d.Face = face
        d.Parent = h
    end

    local mouse = LP:GetMouse()
    tool.Activated:Connect(function()
        if not mouse.Hit then return end
        local pos = _G.BS.CalcularPosicao(mouse, 3)
        local p = Instance.new("Part")
        p.Size = Vector3.new(3, 3, 3)
        p.Anchored = not hasPhysics
        p.Position = pos
        p.Parent = workspace
        if hasPhysics then
            p.CanCollide = true
            p.Name = "Bloco com Fisica"
        end
        for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
            local d = Instance.new("Decal")
            d.Texture = imageId
            d.Face = face
            d.Parent = p
        end
        _G.BS.PlacedBlocks[p] = true
    end)
end

_G.BS.CreateSpawnTool2 = function(textureId, side, top)
    local LP = _G.BS.LocalPlayer
    local tool = Instance.new("Tool")
    tool.Name = ""
    tool.TextureId = textureId
    tool.CanBeDropped = false
    tool.Parent = LP.Backpack

    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(1.5, 1.5, 1.5)
    h.Anchored = false
    h.CanCollide = false
    h.Color = Color3.fromRGB(255, 255, 255)
    h.Parent = tool

    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local d = Instance.new("Decal")
        d.Texture = (face == Enum.NormalId.Top) and top or side
        d.Face = face
        d.Parent = h
    end

    local mouse = LP:GetMouse()
    tool.Activated:Connect(function()
        if not mouse.Hit then return end
        local pos = _G.BS.CalcularPosicao(mouse, 3)
        local p = Instance.new("Part")
        p.Size = Vector3.new(3, 3, 3)
        p.Anchored = true
        p.Position = pos
        p.Parent = workspace
        for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
            local d = Instance.new("Decal")
            d.Texture = (face == Enum.NormalId.Top) and top or side
            d.Face = face
            d.Parent = p
        end
        _G.BS.PlacedBlocks[p] = true
    end)
end

_G.BS.CreateTransparentTool = function()
    local LP = _G.BS.LocalPlayer
    local tool = Instance.new("Tool")
    tool.Name = ""
    tool.TextureId = "rbxassetid://14934219909"
    tool.CanBeDropped = false
    tool.Parent = LP.Backpack

    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(1.5, 1.5, 1.5)
    h.Anchored = false
    h.CanCollide = false
    h.Transparency = 1
    h.Parent = tool

    local img = "rbxassetid://14934219909"
    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local d = Instance.new("Decal")
        d.Texture = img
        d.Face = face
        d.Parent = h
    end

    local mouse = LP:GetMouse()
    tool.Activated:Connect(function()
        if not mouse.Hit then return end
        local pos = _G.BS.CalcularPosicao(mouse, 3)
        local p = Instance.new("Part")
        p.Size = Vector3.new(3, 3, 3)
        p.Position = pos
        p.Anchored = true
        p.CanCollide = true
        p.Transparency = 1
        p.Parent = workspace
        for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
            local d = Instance.new("Decal")
            d.Texture = img
            d.Face = face
            d.Parent = p
        end
        _G.BS.PlacedBlocks[p] = true
    end)
end

_G.BS.CreateTNT = function()
    local LP = _G.BS.LocalPlayer
    local tool = Instance.new("Tool")
    tool.Name = "TNT"
    tool.TextureId = "rbxassetid://5522034026"
    tool.CanBeDropped = false
    tool.Parent = LP.Backpack

    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(1.5, 1.5, 1.5)
    h.Anchored = false
    h.CanCollide = false
    h.Color = Color3.fromRGB(255, 255, 255)
    h.Parent = tool

    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local d = Instance.new("Decal")
        if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
            d.Texture = "rbxassetid://5522034026"
        else
            d.Texture = "rbxassetid://5522032314"
        end
        d.Face = face
        d.Parent = h
    end

    local mouse = LP:GetMouse()
    tool.Activated:Connect(function()
        if not mouse.Hit then return end
        local pos = _G.BS.CalcularPosicao(mouse, 3)
        local p = Instance.new("Part")
        p.Size = Vector3.new(3, 3, 3)
        p.Anchored = true
        p.Position = pos
        p.Parent = workspace
        for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
            local d = Instance.new("Decal")
            if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
                d.Texture = "rbxassetid://5522034026"
            else
                d.Texture = "rbxassetid://5522032314"
            end
            d.Face = face
            d.Parent = p
        end
        _G.BS.PlacedBlocks[p] = true
    end)
end

_G.BS.CreateSlimeBlock = function()
    local LP = _G.BS.LocalPlayer
    local tool = Instance.new("Tool")
    tool.Name = "Slime Block"
    tool.TextureId = "rbxassetid://152446166"
    tool.CanBeDropped = false
    tool.Parent = LP.Backpack

    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(1.5, 1.5, 1.5)
    h.Anchored = false
    h.CanCollide = false
    h.Color = Color3.fromRGB(255, 255, 255)
    h.Parent = tool

    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local d = Instance.new("Decal")
        d.Texture = "rbxassetid://152446166"
        d.Face = face
        d.Parent = h
    end

    local mouse = LP:GetMouse()
    tool.Activated:Connect(function()
        if not mouse.Hit then return end
        local pos = _G.BS.CalcularPosicao(mouse, 3)

        local ok, model = pcall(function()
            return game:GetObjects("rbxassetid://189897040")[1]
        end)

        if not ok or not model then
            local fallback = Instance.new("Part")
            fallback.Size = Vector3.new(3, 3, 3)
            fallback.Position = pos
            fallback.Anchored = true
            fallback.CanCollide = true
            fallback.Color = Color3.fromRGB(120, 220, 120)
            fallback.Material = Enum.Material.SmoothPlastic
            fallback.Parent = workspace
            _G.BS.PlacedBlocks[fallback] = true
            fallback.Touched:Connect(function(hit)
                local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                local hrp = hit.Parent:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if hit ~= hrp then return end
                local vel = hrp.AssemblyLinearVelocity
                if -vel.Y > 3 then
                    local forca = math.clamp(-vel.Y * 1.6, 60, 220)
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X * 0.8, forca, vel.Z * 0.8)
                end
            end)
            return
        end

        if model:IsA("Model") then
            model.Name = "SlimeBlock"
            local parts = {}
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") then
                    table.insert(parts, p)
                end
            end
            if #parts == 0 then model:Destroy() return end

            local center = parts[1]
            local offset = CFrame.new(pos) * center.CFrame:Inverse()

            for _, p in ipairs(parts) do
                p.Anchored = true
                p.CanCollide = true
                p.CFrame = offset * p.CFrame
            end

            model.PrimaryPart = center
            model.Parent = workspace

            _G.BS.PlacedBlocks[model] = true
            for _, p in ipairs(parts) do
                _G.BS.PlacedBlocks[p] = true
            end

            center.Touched:Connect(function(hit)
                local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                local hrp = hit.Parent:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if hit ~= hrp then return end
                local vel = hrp.AssemblyLinearVelocity
                if -vel.Y > 3 then
                    local forca = math.clamp(-vel.Y * 1.6, 60, 220)
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X * 0.8, forca, vel.Z * 0.8)
                end
            end)
        elseif model:IsA("BasePart") then
            model.Size = Vector3.new(3, 3, 3)
            model.Position = pos
            model.Anchored = true
            model.CanCollide = true
            model.Parent = workspace
            _G.BS.PlacedBlocks[model] = true
            model.Touched:Connect(function(hit)
                local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                local hrp = hit.Parent:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if hit ~= hrp then return end
                local vel = hrp.AssemblyLinearVelocity
                if -vel.Y > 3 then
                    local forca = math.clamp(-vel.Y * 1.6, 60, 220)
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X * 0.8, forca, vel.Z * 0.8)
                end
            end)
        else
            model:Destroy()
        end
    end)
end

_G.BS.CreateMinecraftTools = function()
    local LP = _G.BS.LocalPlayer
    local StarterGear = LP:FindFirstChildOfClass("StarterGear")
    local Backpack = LP:FindFirstChildOfClass("Backpack")
    local PlayerGui = LP:WaitForChild("PlayerGui")

    local ids = {
        "82947393289208",
        "133685119901002",
        "582967927",
        "10451323355",
        "10003944211",
        "6816616790"
    }

    local todosModelos = {}

    for _, id in ipairs(ids) do
        local ok, pasta = pcall(function()
            return game:GetObjects("rbxassetid://" .. id)[1]
        end)
        if ok and pasta then
            for _, obj in ipairs(pasta:GetDescendants()) do
                if obj:IsA("Model") then
                    table.insert(todosModelos, obj)
                end
            end
        end
    end

    if #todosModelos == 0 then return end

    local tool = Instance.new("Tool")
    tool.Name = "Minecraft Blocks"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.TextureId = "rbxassetid://6870729295"
    tool.Parent = Backpack

    if StarterGear then
        local cloneGear = tool:Clone()
        cloneGear.Parent = StarterGear
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MinecraftBlocksUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = PlayerGui

    local VERMELHO = Color3.fromRGB(255, 40, 60)
    local VERMELHO_ESCURO = Color3.fromRGB(120, 10, 25)
    local PRETO = Color3.fromRGB(10, 10, 12)
    local PRETO2 = Color3.fromRGB(20, 20, 24)
    local CINZA = Color3.fromRGB(45, 45, 52)
    local BRANCO = Color3.fromRGB(240, 240, 240)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 400)
    frame.Position = UDim2.new(0.5, -210, 0.5, -200)
    frame.BackgroundColor3 = PRETO
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local cornerFrame = Instance.new("UICorner")
    cornerFrame.CornerRadius = UDim.new(0, 8)
    cornerFrame.Parent = frame

    local strokeFrame = Instance.new("UIStroke")
    strokeFrame.Color = VERMELHO
    strokeFrame.Thickness = 2
    strokeFrame.Transparency = 0.2
    strokeFrame.Parent = frame

    local titulo = Instance.new("Frame")
    titulo.Size = UDim2.new(1, 0, 0, 40)
    titulo.BackgroundColor3 = PRETO2
    titulo.BorderSizePixel = 0
    titulo.Parent = frame
    local cornerTitulo = Instance.new("UICorner")
    cornerTitulo.CornerRadius = UDim.new(0, 8)
    cornerTitulo.Parent = titulo

    local linha = Instance.new("Frame")
    linha.Size = UDim2.new(1, 0, 0, 2)
    linha.Position = UDim2.new(0, 0, 1, -2)
    linha.BackgroundColor3 = VERMELHO
    linha.BorderSizePixel = 0
    linha.Parent = titulo

    local tituloTexto = Instance.new("TextLabel")
    tituloTexto.Size = UDim2.new(1, -50, 1, 0)
    tituloTexto.Position = UDim2.new(0, 15, 0, 0)
    tituloTexto.BackgroundTransparency = 1
    tituloTexto.Text = "MINECRAFT BLOCKS // " .. #todosModelos
    tituloTexto.TextColor3 = VERMELHO
    tituloTexto.TextSize = 15
    tituloTexto.Font = Enum.Font.Code
    tituloTexto.TextXAlignment = Enum.TextXAlignment.Left
    tituloTexto.Parent = titulo

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 5)
    closeBtn.BackgroundColor3 = VERMELHO_ESCURO
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = BRANCO
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.Code
    closeBtn.Parent = titulo
    local cornerClose = Instance.new("UICorner")
    cornerClose.CornerRadius = UDim.new(0, 4)
    cornerClose.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1, -20, 0, 32)
    search.Position = UDim2.new(0, 10, 0, 50)
    search.BackgroundColor3 = PRETO2
    search.BorderSizePixel = 0
    search.Text = ""
    search.PlaceholderText = "> pesquisar bloco_"
    search.PlaceholderColor3 = VERMELHO
    search.TextColor3 = BRANCO
    search.TextSize = 14
    search.Font = Enum.Font.Code
    search.TextXAlignment = Enum.TextXAlignment.Left
    search.ClearTextOnFocus = false
    search.Parent = frame
    local cornerSearch = Instance.new("UICorner")
    cornerSearch.CornerRadius = UDim.new(0, 4)
    cornerSearch.Parent = search
    local padSearch = Instance.new("UIPadding")
    padSearch.PaddingLeft = UDim.new(0, 10)
    padSearch.Parent = search

    local strokeSearch = Instance.new("UIStroke")
    strokeSearch.Color = VERMELHO
    strokeSearch.Thickness = 1
    strokeSearch.Transparency = 0.5
    strokeSearch.Parent = search

    local lista = Instance.new("ScrollingFrame")
    lista.Size = UDim2.new(1, -20, 1, -175)
    lista.Position = UDim2.new(0, 10, 0, 90)
    lista.BackgroundColor3 = PRETO2
    lista.BorderSizePixel = 0
    lista.ScrollBarThickness = 6
    lista.ScrollBarImageColor3 = VERMELHO
    lista.CanvasSize = UDim2.new(0, 0, 0, 0)
    lista.AutomaticCanvasSize = Enum.AutomaticSize.Y
    lista.Parent = frame
    local cornerLista = Instance.new("UICorner")
    cornerLista.CornerRadius = UDim.new(0, 4)
    cornerLista.Parent = lista
    local strokeLista = Instance.new("UIStroke")
    strokeLista.Color = VERMELHO_ESCURO
    strokeLista.Thickness = 1
    strokeLista.Transparency = 0.5
    strokeLista.Parent = lista

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = lista

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = lista

    local selecionado = nil
    local botoes = {}

    local botaoSelecionado = Instance.new("TextLabel")
    botaoSelecionado.Size = UDim2.new(1, -20, 0, 24)
    botaoSelecionado.Position = UDim2.new(0, 10, 1, -68)
    botaoSelecionado.BackgroundColor3 = PRETO2
    botaoSelecionado.BorderSizePixel = 0
    botaoSelecionado.Text = "> nenhum bloco selecionado_"
    botaoSelecionado.TextColor3 = VERMELHO
    botaoSelecionado.TextSize = 13
    botaoSelecionado.Font = Enum.Font.Code
    botaoSelecionado.TextXAlignment = Enum.TextXAlignment.Left
    botaoSelecionado.Parent = frame
    local cornerSel = Instance.new("UICorner")
    cornerSel.CornerRadius = UDim.new(0, 4)
    cornerSel.Parent = botaoSelecionado
    local padSel = Instance.new("UIPadding")
    padSel.PaddingLeft = UDim.new(0, 10)
    padSel.Parent = botaoSelecionado

    local fixarBtn = Instance.new("TextButton")
    fixarBtn.Size = UDim2.new(1, -20, 0, 32)
    fixarBtn.Position = UDim2.new(0, 10, 1, -38)
    fixarBtn.BackgroundColor3 = VERMELHO_ESCURO
    fixarBtn.BorderSizePixel = 0
    fixarBtn.Text = "[ FIXAR NA MOCHILA ]"
    fixarBtn.TextColor3 = BRANCO
    fixarBtn.TextSize = 13
    fixarBtn.Font = Enum.Font.Code
    fixarBtn.Parent = frame
    local cornerFix = Instance.new("UICorner")
    cornerFix.CornerRadius = UDim.new(0, 4)
    cornerFix.Parent = fixarBtn
    local strokeFix = Instance.new("UIStroke")
    strokeFix.Color = VERMELHO
    strokeFix.Thickness = 1
    strokeFix.Transparency = 0.3
    strokeFix.Parent = fixarBtn

    fixarBtn.MouseButton1Click:Connect(function()
        if not selecionado then return end

        local novaTool = Instance.new("Tool")
        novaTool.Name = selecionado.Name
        novaTool.RequiresHandle = false
        novaTool.CanBeDropped = false

        local previewPart = nil
        for _, p in ipairs(selecionado:GetDescendants()) do
            if p:IsA("BasePart") then
                previewPart = p
                break
            end
        end

        if previewPart then
            for _, child in ipairs(previewPart:GetChildren()) do
                if child:IsA("Decal") then
                    novaTool.TextureId = child.Texture
                    break
                elseif child:IsA("Texture") then
                    novaTool.TextureId = child.Texture
                    break
                end
            end
        end

        novaTool.Parent = Backpack
        if StarterGear then
            local cloneGear = novaTool:Clone()
            cloneGear.Parent = StarterGear
        end

        local mouse = LP:GetMouse()
        novaTool.Activated:Connect(function()
            _G.BS.SpawnarBloco(selecionado, mouse)
        end)

        botaoSelecionado.Text = "> fixado: " .. selecionado.Name
    end)

    for i, modelo in ipairs(todosModelos) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.BackgroundColor3 = CINZA
        btn.BorderSizePixel = 0
        btn.Text = "> " .. modelo.Name
        btn.TextColor3 = BRANCO
        btn.TextSize = 13
        btn.Font = Enum.Font.Code
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = i
        btn.AutoButtonColor = true
        btn.Parent = lista
        local cornerBtn = Instance.new("UICorner")
        cornerBtn.CornerRadius = UDim.new(0, 3)
        cornerBtn.Parent = btn

        local padBtn = Instance.new("UIPadding")
        padBtn.PaddingLeft = UDim.new(0, 8)
        padBtn.Parent = btn

        btn.MouseButton1Click:Connect(function()
            selecionado = modelo
            botaoSelecionado.Text = "> selecionado: " .. modelo.Name
            for _, b in ipairs(botoes) do
                b.BackgroundColor3 = CINZA
                b.TextColor3 = BRANCO
            end
            btn.BackgroundColor3 = VERMELHO
            btn.TextColor3 = BRANCO        end)

        table.insert(botoes, btn)
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(search.Text)
        for i, btn in ipairs(botoes) do
            local nome = string.lower(todosModelos[i].Name)
            btn.Visible = (q == "") or (string.find(nome, q, 1, true) ~= nil)
        end
    end)

    local mouse = LP:GetMouse()

    tool.Equipped:Connect(function()
        gui.Enabled = true
    end)

    tool.Unequipped:Connect(function()
        gui.Enabled = false
    end)

    tool.Activated:Connect(function()
        if not selecionado then return end
        _G.BS.SpawnarBloco(selecionado, mouse)
    end)
end

_G.BS.CreatePortalGun = function()
    local LP = _G.BS.LocalPlayer
    local PORTAL_ID = 3386585223
    local TOOL_TEXTURE = "rbxassetid://109470930766852"
    local ALTURA_OFFSET = 10

    local portalA, portalB = nil, nil
    local placingA = true
    local teleportCooldown = {}
    local TELEPORT_DELAY = 0.90
    local mouse = LP:GetMouse()
    local portalAConns, portalBConns = {}, {}

    local function getParts(model)
        local t = {}
        if not model then return t end
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(t, p) end
        end
        return t
    end

    local function getPartsComTexture(model)
        local t = {}
        if not model then return t end
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                for _, filho in ipairs(p:GetChildren()) do
                    if filho:IsA("Texture") or filho:IsA("Decal") or filho:IsA("SurfaceAppearance") then
                        table.insert(t, p)
                        break
                    end
                end
            end
        end
        return t
    end

    local function destroyPortal(portal)
        if not portal then return end
        pcall(function() portal:Destroy() end)
    end

    local function limparConns(conns)
        for _, c in ipairs(conns) do
            pcall(function() c:Disconnect() end)
        end
        return {}
    end

    local function loadPortalAtCFrame(cframe, nome)
        local success, portal = pcall(function()
            return game:GetObjects("rbxassetid://" .. PORTAL_ID)[1]
        end)
        if not success or not portal then return nil end
        portal.Name = nome or "Portal"
        portal.Parent = workspace
        local allParts = getParts(portal)
        if #allParts == 0 then portal:Destroy() return nil end
        local centerPart = allParts[1]
        local offset = cframe * centerPart.CFrame:Inverse()
        for _, part in ipairs(allParts) do
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = true
            part.CanQuery = true
            part.CFrame = offset * part.CFrame
        end
        pcall(function()
            for _, obj in ipairs(portal:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    obj:Destroy()
                end
            end
        end)
        for _, obj in ipairs(portal:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                pcall(function() obj:FireServer() end)
            end
        end
        return portal
    end

    local function getPortalCentroPos(portal)
        if not portal then return nil end
        local parts = getPartsComTexture(portal)
        if #parts == 0 then parts = getParts(portal) end
        if #parts == 0 then return nil end
        local soma = Vector3.zero
        for _, p in ipairs(parts) do soma = soma + p.Position end
        return soma / #parts
    end

    local function teleportarPart(root, destinoCFrame)
        if not root or not destinoCFrame then return end
        if not root.Parent then return end
        pcall(function()
            root.CFrame = destinoCFrame + Vector3.new(0, 3, 0)
            if root.AssemblyLinearVelocity then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end

    local function conectarPortal(fromPortal, toPortal, connsList)
        if not fromPortal or not toPortal then return end
        local toPos = getPortalCentroPos(toPortal)
        if not toPos then return end
        local partsTo = getPartsComTexture(toPortal)
        if #partsTo == 0 then partsTo = getParts(toPortal) end
        if #partsTo == 0 then return end
        local rotacaoTo = partsTo[1].CFrame - partsTo[1].CFrame.Position
        local destinoCFrame = CFrame.new(toPos) * rotacaoTo

        local function hookPart(part)
            if not part:IsA("BasePart") then return end
            local c = part.Touched:Connect(function(hit)
                if not hit or not hit.Parent then return end
                if hit:IsDescendantOf(fromPortal) or hit:IsDescendantOf(toPortal) then return end
                local root = hit
                if hit:IsA("BasePart") and hit.AssemblyRootPart then
                    root = hit.AssemblyRootPart
                end
                local agora = tick()
                if teleportCooldown[root] and agora - teleportCooldown[root] < TELEPORT_DELAY then return end
                teleportCooldown[root] = agora
                teleportarPart(root, destinoCFrame)
            end)
            table.insert(connsList, c)
        end

        local partsAlvo = getPartsComTexture(fromPortal)
        if #partsAlvo == 0 then partsAlvo = getParts(fromPortal) end
        for _, part in ipairs(partsAlvo) do hookPart(part) end
    end

    local function conectarTudo()
        portalAConns = limparConns(portalAConns)
        portalBConns = limparConns(portalBConns)
        if not (portalA and portalB) then return end
        conectarPortal(portalA, portalB, portalAConns)
        conectarPortal(portalB, portalA, portalBConns)
    end

    local function spawnarPortal()
        local mouseTarget = mouse.Hit
        if not mouseTarget then return end
        local character = LP.Character or LP.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local posicaoBase = mouseTarget.Position + Vector3.new(0, ALTURA_OFFSET, 0)
        local direcao = hrp.Position - posicaoBase
        local direcaoHorizontal = Vector3.new(direcao.X, 0, direcao.Z)
        if direcaoHorizontal.Magnitude < 0.1 then
            direcaoHorizontal = Vector3.new(0, 0, 1)
        end
        local cf = CFrame.lookAt(posicaoBase, posicaoBase + direcaoHorizontal.Unit)
        if placingA then
            destroyPortal(portalA)
            portalA = loadPortalAtCFrame(cf, "Portal_A")
        else
            destroyPortal(portalB)
            portalB = loadPortalAtCFrame(cf, "Portal_B")
        end
        placingA = not placingA
        if portalA and portalB then
            task.wait(0.2)
            conectarTudo()
        end
    end

    local portal_gun = Instance.new("Tool")
    portal_gun.Name = "Portal Nether"
    portal_gun.RequiresHandle = false
    portal_gun.TextureId = TOOL_TEXTURE
    portal_gun.CanBeDropped = false

    local backpack = LP:FindFirstChild("Backpack") or LP:WaitForChild("Backpack", 5)
    if backpack then
        portal_gun.Parent = backpack
    elseif LP.Character then
        portal_gun.Parent = LP.Character
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "PortalUI"
    gui.ResetOnSpawn = false
    gui.Parent = LP:WaitForChild("PlayerGui")

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(0, 10, 0, 10)
    closeButton.Text = "X"
    closeButton.TextScaled = true
    closeButton.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.ZIndex = 10
    closeButton.Active = true
    closeButton.Draggable = true
    closeButton.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        destroyPortal(portalA)
        destroyPortal(portalB)
        portalA = nil
        portalB = nil
        placingA = true
        portalAConns = limparConns(portalAConns)
        portalBConns = limparConns(portalBConns)
    end)

    portal_gun.Activated:Connect(function()
        spawnarPortal()
    end)
end

_G.BS.CreateElytra = function()
    local LP = _G.BS.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = _G.BS.ReplicatedStorage

    local CurrentTrack = nil
    local FLYING = false
    local FLY_SPEED = 150
    local flyKeyDown, flyKeyUp, animLoop
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isMoving = false
    local JETPACK_MOVE_ID = "83045494892716"
    local JETPACK_IDLE_ID = "130091513634214"
    local WEAR_ID = 123248642948210

    local function getHumanoid()
        local char = LP.Character
        if not char then return nil end
        return char:FindFirstChildOfClass("Humanoid")
    end

    local function equipJetpack()
        local args = {[1] = WEAR_ID}
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("Wear", 9e9):InvokeServer(unpack(args))
        end)
    end

    local function unequipJetpack()
        local args = {[1] = WEAR_ID}
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("Wear", 9e9):InvokeServer(unpack(args))
        end)
    end

    local function LoadTrack(id)
        local humanoid = getHumanoid()
        if not humanoid then return end
        if CurrentTrack then
            CurrentTrack:Stop(0.1)
            CurrentTrack = nil
        end
        local animId
        local ok, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(id))
        end)
        if ok and result and #result > 0 then
            local anim = result[1]
            if anim:IsA("Animation") then
                animId = anim.AnimationId
            else
                animId = "rbxassetid://" .. tostring(id)
            end
        else
            animId = "rbxassetid://" .. tostring(id)
        end
        local newAnim = Instance.new("Animation")
        newAnim.AnimationId = animId
        local newTrack = humanoid:LoadAnimation(newAnim)
        newTrack.Priority = Enum.AnimationPriority.Action4
        newTrack:Play(0.1, 1, 1)
        CurrentTrack = newTrack
    end

    local function stopEmote()
        if CurrentTrack then
            pcall(function()
                CurrentTrack:Stop(0)
            end)
            CurrentTrack = nil
        end
        local hum = getHumanoid()
        if hum then
            for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
            end
        end
    end

    local function startAnimLoop()
        if animLoop then animLoop:Disconnect() end
        LoadTrack(JETPACK_IDLE_ID)
        local lastState = "idle"
        animLoop = RunService.Heartbeat:Connect(function()
            if not FLYING then
                animLoop:Disconnect()
                animLoop = nil
                return
            end
            local state = isMoving and "move" or "idle"
            if state ~= lastState then
                lastState = state
                if state == "move" then
                    LoadTrack(JETPACK_MOVE_ID)
                else
                    LoadTrack(JETPACK_IDLE_ID)
                end
            end
        end)
    end

    local function stopFlying()
        FLYING = false
        if flyKeyDown then flyKeyDown:Disconnect() end
        if flyKeyUp then flyKeyUp:Disconnect() end
        if animLoop then animLoop:Disconnect() end
        animLoop = nil
        stopEmote()
        unequipJetpack()
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        isMoving = false
    end

    local function sFLY()
        if flyKeyDown then flyKeyDown:Disconnect() end
        if flyKeyUp then flyKeyUp:Disconnect() end

        local CONTROL = {F=0, B=0, L=0, R=0, Q=0, E=0}
        FLYING = true

        equipJetpack()
        startAnimLoop()

        task.spawn(function()
            local char = LP.Character
            if not char then return end
            local hrp = char:WaitForChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end

            local BG = Instance.new("BodyGyro")
            BG.P = 9e4
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = hrp.CFrame
            BG.Parent = hrp

            local BV = Instance.new("BodyVelocity")
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Parent = hrp

            repeat
                task.wait()
                local camera = workspace.CurrentCamera
                local moving = (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0
                isMoving = moving

                if moving then
                    BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B))
                        + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * FLY_SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = camera.CFrame
            until not FLYING

            BG:Destroy()
            BV:Destroy()
            isMoving = false
            if hum then hum.PlatformStand = false end
            stopEmote()
        end)

        flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1
            elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1
            elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1
            elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1
            elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 1
            elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = -1
            end
        end)

        flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0
            end
        end)
    end

    local function mobilefly()
        FLYING = true

        equipJetpack()
        startAnimLoop()

        local controlModule
        pcall(function()
            controlModule = require(LP.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        end)
        if not controlModule then return end

        task.spawn(function()
            local char = LP.Character
            if not char then return end
            local hrp = char:WaitForChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end

            local BG = Instance.new("BodyGyro")
            BG.P = 9e4
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = hrp.CFrame
            BG.Parent = hrp

            local BV = Instance.new("BodyVelocity")
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Parent = hrp

            local v3zero = Vector3.new(0, 0, 0)

            repeat
                task.wait()
                local camera = workspace.CurrentCamera
                local moveDirection = controlModule:GetMoveVector()

                if moveDirection then
                    local moveVector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
                    local moving = moveVector.Magnitude > 0.1
                    isMoving = moving

                    if moving then
                        local worldDirection = camera.CFrame:VectorToWorldSpace(moveVector)
                        BV.Velocity = worldDirection * FLY_SPEED
                    else
                        BV.Velocity = v3zero
                    end
                else
                    isMoving = false
                    BV.Velocity = v3zero
                end

                BG.CFrame = camera.CFrame
            until not FLYING

            BG:Destroy()
            BV:Destroy()
            isMoving = false
            if hum then hum.PlatformStand = false end
            stopEmote()
        end)
    end

    local function startFlying()
        if isMobile then
            mobilefly()
        else
            sFLY()
        end
    end

    local tool = Instance.new("Tool")
    tool.Name = "Elytra"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.TextureId = "rbxassetid://18945940130"
    tool.Parent = LP.Backpack

    tool.Equipped:Connect(function()
        startFlying()
    end)

    tool.Unequipped:Connect(function()
        stopFlying()
    end)
end

_G.BS.CreateAllTools = function()
    _G.BS.CreatePicareta()
    _G.BS.CreateSpawnTool("rbxassetid://106513645844271", "rbxassetid://106513645844271", false)
    _G.BS.CreateSpawnTool2("rbxassetid://9267155972", "rbxassetid://9267155972", "rbxassetid://9267183930")
    _G.BS.CreateSpawnTool("rbxassetid://9359131807", "rbxassetid://9359131807", false)
    _G.BS.CreateSpawnTool("rbxassetid://9277770677", "rbxassetid://9277770677", true)
    _G.BS.CreateSpawnTool("rbxassetid://11547302007", "rbxassetid://11547302007", false)
    _G.BS.CreateSpawnTool("rbxassetid://7341687607", "rbxassetid://7341687607", false)
    _G.BS.CreateSpawnTool("rbxassetid://7696392982", "rbxassetid://7696392982", false)
    _G.BS.CreateSpawnTool("rbxassetid://8677289915", "rbxassetid://8677289915", false)
    _G.BS.CreateSpawnTool("rbxassetid://9184126359", "rbxassetid://9184126359", false)
    _G.BS.CreateSpawnTool("rbxassetid://7901287342", "rbxassetid://7901287342", false)
    _G.BS.CreateSpawnTool("rbxassetid://8677286748", "rbxassetid://8677286748", false)
    _G.BS.CreateSpawnTool("rbxassetid://8677288274", "rbxassetid://8677288274", false)
    _G.BS.CreateSpawnTool("rbxassetid://14934313194", "rbxassetid://14934313194", false)
    _G.BS.CreateTransparentTool()
    _G.BS.CreateTNT()
    _G.BS.CreateSlimeBlock()
    _G.BS.CreateMinecraftTools()
    _G.BS.CreatePortalGun()
    _G.BS.CreateElytra()
end

_G.BS.GroxRun = function()
    pcall(_G.BS.SetupBody)
    pcall(_G.BS.SetupOutfit)
    pcall(_G.BS.CreateAllTools)
end

TabPersonagens:AddButton({
    Name = "Grox",
    Callback = function()
        if _G.BS.GroxRun then _G.BS.GroxRun() end
    end
})

_G.Slayer = _G.Slayer or {}

local function initSlayerShaders()
    local game = game
    local plrs = game:GetService("Players")
    local rs = game:GetService("RunService")
    local ws = workspace
    local lg = game:GetService("Lighting")
    local terr = ws:FindFirstChildOfClass("Terrain")
    local fenv = getfenv()
    local shp = fenv.sethiddenproperty or function() end
    local ghp = fenv.gethiddenproperty or function() end

    local function fetch(url)
        return loadstring(game:HttpGet(url))()
    end

    local randomstring = "https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/"
    local technology = ghp(lg, "Technology") or "ShadowMap"

    local S = _G.Slayer
    S.shader = {}
    S.shaderLoaded = {}
    S.wl = {
        dof = true, cor = true, sray = false, bl = true, blr = false,
        rays = false, sflare = false, mblur = false,
        tech = "ShadowMap", global = false
    }
    S.wshade = false
    S.restore = {}
    S.new = {}
    S.cussky = {
        bk = "rbxassetid://9544505500",
        dn = "rbxassetid://9544547905",
        ft = "rbxassetid://9544504852",
        lt = "rbxassetid://9544547694",
        rt = "rbxassetid://9544547542",
        up = "rbxassetid://9544547398"
    }

    local colorcor, atmosphere, bloom, blur, depth, sky, sray, cloud
    local defsky = {}

    local function random(l)
        local s = ""
        for i = 1, (l or 5) do
            local n = math.random(1, 3)
            if n == 1 then s = s .. string.char(math.random(65, 90))
            elseif n == 2 then s = s .. string.char(math.random(97, 122))
            else s = s .. tostring(math.random(0, 9)) end
        end
        return s
    end

    local bestname = random()

    if lg:FindFirstChildOfClass("BloomEffect") then
        lg:FindFirstChildOfClass("BloomEffect").Enabled = false
        local b = lg:FindFirstChildOfClass("BloomEffect"):Clone()
        b.Parent = lg; b.Enabled = false; bloom = b
        table.insert(S.restore, b); table.insert(S.new, b)
    end
    if lg:FindFirstChildOfClass("Sky") then
        local b = lg:FindFirstChildOfClass("Sky"):Clone()
        b.Parent = lg; sky = b
        table.insert(S.restore, b); table.insert(S.new, b)
    end
    if lg:FindFirstChildOfClass("Atmosphere") then
        local b = lg:FindFirstChildOfClass("Atmosphere"):Clone()
        b.Parent = lg; atmosphere = b
        table.insert(S.restore, b); table.insert(S.new, b)
    end
    if lg:FindFirstChildOfClass("BlurEffect") then
        lg:FindFirstChildOfClass("BlurEffect").Size = 0
        local b = lg:FindFirstChildOfClass("BlurEffect"):Clone()
        b.Parent = lg; b.Enabled = false; blur = b
        table.insert(S.restore, b); table.insert(S.new, b)
    end
    if lg:FindFirstChildOfClass("DepthOfFieldEffect") then
        lg:FindFirstChildOfClass("DepthOfFieldEffect").Enabled = false
        local b = lg:FindFirstChildOfClass("DepthOfFieldEffect"):Clone()
        b.Parent = lg; b.Enabled = false; depth = b
        table.insert(S.restore, b); table.insert(S.new, b)
    end
    if lg:FindFirstChildOfClass("ColorCorrectionEffect") then
        lg:FindFirstChildOfClass("ColorCorrectionEffect").Enabled = false
        local b = lg:FindFirstChildOfClass("ColorCorrectionEffect"):Clone()
        b.Parent = lg; b.Enabled = false; colorcor = b
        table.insert(S.restore, b); table.insert(S.new, b)
    end
    if lg:FindFirstChildOfClass("SunRaysEffect") then
        lg:FindFirstChildOfClass("SunRaysEffect").Enabled = false
        local b = lg:FindFirstChildOfClass("SunRaysEffect"):Clone()
        b.Parent = lg; b.Enabled = false; sray = b
        table.insert(S.restore, b); table.insert(S.new, b)
    end
    if not colorcor then colorcor = Instance.new("ColorCorrectionEffect", lg); colorcor.Enabled = false; table.insert(S.new, colorcor) end
    if not atmosphere then atmosphere = Instance.new("Atmosphere", lg); atmosphere.Density = 0; table.insert(S.new, atmosphere) end
    if not bloom then bloom = Instance.new("BloomEffect", lg); bloom.Enabled = false; table.insert(S.new, bloom) end
    if not blur then blur = Instance.new("BlurEffect", lg); blur.Size = 0; blur.Enabled = false; table.insert(S.new, blur) end
    if not depth then depth = Instance.new("DepthOfFieldEffect", lg); depth.Enabled = false; table.insert(S.new, depth) end
    if not sky then sky = Instance.new("Sky", lg); table.insert(S.new, sky) end
    if not sray then sray = Instance.new("SunRaysEffect", lg); sray.Enabled = false; table.insert(S.new, sray) end
    if terr and not cloud then
        cloud = Instance.new("Clouds", terr)
        cloud.Cover = 0; cloud.Density = 0
        table.insert(S.new, cloud)
    end
    defsky = {
        bk = sky.SkyboxBk, dn = sky.SkyboxDn, ft = sky.SkyboxFt,
        lt = sky.SkyboxLf, rt = sky.SkyboxRt, up = sky.SkyboxUp
    }
    for _, v in ipairs(S.restore) do v.Name = bestname end
    for _, v in ipairs(S.new) do v.Name = bestname end

    S.backup = {
        lighting = {
            ClockTime = lg.ClockTime, Ambient = lg.Ambient, Brightness = lg.Brightness,
            ColorShift_Bottom = lg.ColorShift_Bottom, ColorShift_Top = lg.ColorShift_Top,
            EnvironmentDiffuseScale = lg.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = lg.EnvironmentSpecularScale,
            GlobalShadows = lg.GlobalShadows, OutdoorAmbient = lg.OutdoorAmbient,
            technology = technology, GeographicLatitude = lg.GeographicLatitude,
            ExposureCompensation = lg.ExposureCompensation,
            FogEnd = lg.FogEnd, FogColor = lg.FogColor, FogStart = lg.FogStart
        },
        terrain = {
            WaterColor = terr and terr.WaterColor,
            WaterReflectance = terr and terr.WaterReflectance,
            WaterTransparency = terr and terr.WaterTransparency,
            WaterWaveSize = terr and terr.WaterWaveSize,
            WaterWaveSpeed = terr and terr.WaterWaveSpeed
        }
    }

    S.default = {
        yfbghj = lg.Ambient, tgvbyd = lg.ClockTime, ghuybhuyhj = lg.GeographicLatitude,
        khnbfth = lg.Brightness, hgyghkg = lg.ColorShift_Bottom, yfbhjku = lg.ColorShift_Top,
        ygyyfgvhbjytrt = lg.EnvironmentDiffuseScale, sdfcddc = lg.EnvironmentSpecularScale,
        hgnujuu7thgr = lg.GlobalShadows, hyhnngtf = lg.OutdoorAmbient, hdfr7thgr = lg.ExposureCompensation,
        fhnchvhfjsd = colorcor.Brightness, ugtbbjhygt = colorcor.Contrast,
        tfbghuugbnjhg = colorcor.Saturation, fvrtccvghghj = colorcor.TintColor,
        jnfdhbnfcvh = bloom.Intensity, fvtyghj = bloom.Size, ygbhnj = bloom.Threshold,
        njnfg = blur.Size, jdfkd = depth.FarIntensity, fvgsdfg = depth.FocusDistance,
        sdkvkflv = depth.InFocusRadius, hbjhd = depth.NearIntensity,
        gyhgtg = cloud and cloud.Cover or 0, ygbhggv = cloud and cloud.Density or 0,
        jghbjhgyfd = cloud and cloud.Color or Color3.new(1,1,1),
        shdbsnjfc = atmosphere.Density, skdjfkdm = atmosphere.Offset,
        sjdjncdjf = atmosphere.Color, efjdjfk = atmosphere.Decay,
        sejfd = atmosphere.Glare, jddfjsd = atmosphere.Haze
    }
    S.light = S.default

    local function loadShader(name)
        if S.shaderLoaded[name] then return S.shader[name] end
        local file = name
        if name == "evening" then file = "evening%2Cjson" end
        if name:find("lite") then
            file = name:gsub("lite", "") .. "1.json"
        else
            file = name .. ".json"
        end
        local ok, data = pcall(function()
            return fetch(randomstring .. "shr/" .. file)
        end)
        if ok and data then
            S.shader[name] = data
            S.shaderLoaded[name] = true
            return data
        end
        return nil
    end

    S.setShader = function(name)
        local data = loadShader(name)
        if data then S.light = data end
    end

    local function applySky()
        if not sky then return end
        if S.wshade then
            sky.SkyboxBk = S.cussky.bk
            sky.SkyboxDn = S.cussky.dn
            sky.SkyboxFt = S.cussky.ft
            sky.SkyboxLf = S.cussky.lt
            sky.SkyboxRt = S.cussky.rt
            sky.SkyboxUp = S.cussky.up
        else
            sky.SkyboxBk = defsky.bk
            sky.SkyboxDn = defsky.dn
            sky.SkyboxFt = defsky.ft
            sky.SkyboxLf = defsky.lt
            sky.SkyboxRt = defsky.rt
            sky.SkyboxUp = defsky.up
        end
    end

    local function applyEffects()
        local L = S.light or S.default
        colorcor.Brightness = L.fhnchvhfjsd
        colorcor.Contrast = L.ugtbbjhygt
        colorcor.Saturation = L.tfbghuugbnjhg
        colorcor.TintColor = L.fvrtccvghghj
        colorcor.Enabled = S.wshade and S.wl.cor
        blur.Enabled = S.wshade and S.wl.blr
        bloom.Enabled = S.wshade and S.wl.bl
        bloom.Intensity = L.jnfdhbnfcvh
        bloom.Size = L.fvtyghj
        bloom.Threshold = L.ygbhnj
        blur.Size = L.njnfg
    end

    local function applyLighting()
        if S.wshade and S.light then
            local L = S.light
            lg.Ambient = L.yfbghj
            lg.ClockTime = L.tgvbyd
            lg.GeographicLatitude = L.ghuybhuyhj
            lg.Brightness = L.khnbfth
            lg.ColorShift_Bottom = L.hgyghkg
            lg.ColorShift_Top = L.yfbhjku
            lg.EnvironmentDiffuseScale = L.ygyyfgvhbjytrt
            lg.EnvironmentSpecularScale = L.sdfcddc
            lg.GlobalShadows = L.hgnujuu7thgr
            lg.OutdoorAmbient = L.hyhnngtf
            lg.ExposureCompensation = L.hdfr7thgr
            lg.FogEnd = math.huge
            lg.FogColor = Color3.fromRGB(255, 255, 255)
            lg.FogStart = math.huge
        else
            local B = S.backup.lighting
            lg.Ambient = B.Ambient
            lg.ClockTime = B.ClockTime
            lg.Brightness = B.Brightness
            lg.GlobalShadows = B.GlobalShadows
            lg.OutdoorAmbient = B.OutdoorAmbient
            lg.ExposureCompensation = B.ExposureCompensation
            lg.FogEnd = B.FogEnd
            lg.FogColor = B.FogColor
            lg.FogStart = B.FogStart
        end
    end

    local function applyAtmosphere()
        if S.wshade and S.light then
            local L = S.light
            if cloud then
                cloud.Cover = L.gyhgtg
                cloud.Density = L.ygbhggv
                cloud.Color = L.jghbjhgyfd
            end
            atmosphere.Density = L.shdbsnjfc
            atmosphere.Offset = L.skdjfkdm
            atmosphere.Color = L.sjdjncdjf
            atmosphere.Decay = L.efjdjfk
            atmosphere.Glare = L.sejfd
            atmosphere.Haze = L.jddfjsd
        else
            if cloud then
                cloud.Cover = 0
                cloud.Density = 0
            end
            local D = S.default
            atmosphere.Density = D.shdbsnjfc
            atmosphere.Offset = D.skdjfkdm
            atmosphere.Color = D.sjdjncdjf
            atmosphere.Decay = D.efjdjfk
            atmosphere.Glare = D.sejfd
            atmosphere.Haze = D.jddfjsd
        end
    end

    local function applyDepth()
        if S.wshade and S.light then
            local L = S.light
            depth.FarIntensity = L.jdfkd
            depth.FocusDistance = L.fvgsdfg
            depth.InFocusRadius = L.sdkvkflv
            depth.NearIntensity = L.hbjhd
            depth.Enabled = S.wl.dof
            sray.Enabled = S.wl.rays
        else
            depth.Enabled = false
            sray.Enabled = false
        end
    end

    local function applyTerrain()
        if not terr then return end
        if S.wshade then return end
        local B = S.backup.terrain
        if B.WaterColor then terr.WaterColor = B.WaterColor end
        if B.WaterReflectance then terr.WaterReflectance = B.WaterReflectance end
        if B.WaterTransparency then terr.WaterTransparency = B.WaterTransparency end
        if B.WaterWaveSize then terr.WaterWaveSize = B.WaterWaveSize end
        if B.WaterWaveSpeed then terr.WaterWaveSpeed = B.WaterWaveSpeed end
    end

    rs.RenderStepped:Connect(function()
        applySky()
        applyLighting()
        applyEffects()
        applyAtmosphere()
        applyDepth()
        applyTerrain()
    end)

    S.shp = shp
    S.lg = lg
    S.technology = technology
    S.terr = terr
end

initSlayerShaders()

local function buildShaderTab()
    local S = _G.Slayer
    local Tab = Window:MakeTab({"Shaders", "cloud"})

    Tab:AddSection("Controle Geral")
    Tab:AddToggle({
        Name = "Enable Shaders",
        Default = false,
        Callback = function(Value)
            S.wshade = Value
            pcall(function()
                for _, v in ipairs(S.restore) do
                    if not v:IsA("Atmosphere") and not v:IsA("Sky") then
                        v.Enabled = false
                    end
                end
                for _, v in ipairs(S.new) do
                    if not v:IsA("Atmosphere") and not v:IsA("Sky") then
                        v.Enabled = Value
                    end
                end
                S.shp(S.lg, "Technology", Value and S.wl.tech or S.technology)
            end)
        end
    })

    Tab:AddSection("Effects")
    Tab:AddToggle({Name = "Sunflare", Default = false, Callback = function(v) S.wl.sflare = v end})
    Tab:AddToggle({Name = "Motion Blur", Default = false, Callback = function(v) S.wl.mblur = v end})
    Tab:AddToggle({Name = "Blur Effect", Default = false, Callback = function(v) S.wl.blr = v end})
    Tab:AddToggle({Name = "Bloom", Default = true, Callback = function(v) S.wl.bl = v end})
    Tab:AddToggle({Name = "Color Correction", Default = true, Callback = function(v) S.wl.cor = v end})
    Tab:AddToggle({Name = "Depth Of Field", Default = true, Callback = function(v) S.wl.dof = v end})
    Tab:AddToggle({Name = "Sunrays", Default = false, Callback = function(v) S.wl.rays = v end})

    local function toggleColor(name, key)
        Tab:AddToggle({Name = name, Default = false, Callback = function(v)
            if v then S.setShader(key) elseif S.light == S.shader[key] then S.light = S.default end
        end})
    end

    Tab:AddSection("Color")
    toggleColor("Black", "black")
    toggleColor("Green", "green")
    toggleColor("Red", "red")
    toggleColor("Yellow", "yellow")
    toggleColor("Pink", "pink")
    toggleColor("Gray", "gray")
    toggleColor("White", "white")
    toggleColor("Purple", "purple")

    Tab:AddSection("Color Lite")
    toggleColor("Black Lite", "blacklite")
    toggleColor("Green Lite", "greenlite")
    toggleColor("Red Lite", "redlite")
    toggleColor("Yellow Lite", "yellowlite")
    toggleColor("Pink Lite", "pinklite")
    toggleColor("Gray Lite", "graylite")
    toggleColor("White Lite", "whitelite")
    toggleColor("Purple Lite", "purplelite")

    Tab:AddSection("Time")
    toggleColor("Morning", "morning")
    toggleColor("Midday", "midday")
    toggleColor("Afternoon", "afternoon")
    toggleColor("Evening", "evening")
    toggleColor("Night", "night")
    toggleColor("Midnight", "midnight")

    Tab:AddSection("Time Lite")
    toggleColor("Morning Lite", "morninglite")
    toggleColor("Midday Lite", "middaylite")
    toggleColor("Afternoon Lite", "afternoonlite")
    toggleColor("Evening Lite", "eveninglite")
    toggleColor("Night Lite", "nightlite")
    toggleColor("Midnight Lite", "midnightlite")

    Tab:AddSection("Weather")
    toggleColor("Rain", "rain")
    toggleColor("Snow", "snow")
    toggleColor("Fog", "fog")
    toggleColor("Sunny", "sunny")
    toggleColor("Cloudy", "cloudy")
    toggleColor("Storm", "storm")

    Tab:AddSection("Season")
    toggleColor("Autumn", "autumn")
    toggleColor("Spring", "spring")
    toggleColor("Summer", "summer")
    toggleColor("Winter", "winter")
end

buildShaderTab()
