-- technoblade never dies

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local API = "https://ipapi.co/json/"

local translations = {
    BR = "Script em manutenção, por favor, aguarde.",
    US = "Script under maintenance, please wait.",
    CA = "Script under maintenance, please wait.",
    GB = "Script under maintenance, please wait.",
    ES = "Script en mantenimiento, por favor, espere.",
    MX = "Script en mantenimiento, por favor, espere.",
    AR = "Script en mantenimiento, por favor, espere.",
    FR = "Script en maintenance, veuillez patienter.",
    DE = "Skript wird gewartet, bitte warten.",
    IT = "Script in manutenzione, attendere.",
    PT = "Script em manutenção, por favor, aguarde.",
    JP = "スクリプトはメンテナンス中です。しばらくお待ちください。",
    KR = "스크립트가 유지보수 중입니다. 잠시 기다려 주세요.",
    RU = "Скрипт находится на обслуживании, пожалуйста, подождите."
}

local DEFAULT_MESSAGE = "Script under maintenance, please wait."

local function getCountry()
    local success, response = pcall(function()
        return HttpService:GetAsync(API)
    end)

    if not success then
        warn("Não foi possível consultar a API:", response)
        return nil
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not ok or type(data) ~= "table" then
        return nil
    end

    return data.country_code
end

local function createMessage(player, message)
    local gui = Instance.new("ScreenGui")
    gui.Name = "MaintenanceGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local background = Instance.new("Frame")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundTransparency = 0.25
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.Parent = gui

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.fromScale(0.5, 0.5)
    label.Size = UDim2.new(0.8, 0, 0, 80)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = background
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(function()
        local country = getCountry()
        local message = translations[country] or DEFAULT_MESSAGE

        createMessage(player, message)

        print(player.Name, "Country:", country or "Unknown")
    end)
end)
