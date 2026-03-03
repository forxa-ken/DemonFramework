-- ============================================================
-- DemonBrain Settings (Framework Profile Based)
-- ============================================================

local DF = DemonFramework

-------------------------------------------------
-- UTIL
-------------------------------------------------

local function GetConfig()
    if not DemonBrainCore or not DemonBrainCore.GetConfig then
        return nil
    end
    return DemonBrainCore:GetConfig()
end

local function RefreshUI()
    local config = GetConfig()
    if not config then return end

    if DemonBrainMain then
        DemonBrainMain:SetSize(config.iconSize or 70, config.iconSize or 70)
        DemonBrainMain:SetAlpha(config.iconAlpha or 1)

        if config.hideMainIcon then
            DemonBrainMain:Hide()
        else
            DemonBrainMain:Show()
        end
    end
end

-------------------------------------------------
-- PANEL
-------------------------------------------------

local panel = CreateFrame("Frame")

local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
header:SetPoint("TOPLEFT", 20, -20)
header:SetText("DemonBrain Settings")

-------------------------------------------------
-- SLIDER TIRANO
-------------------------------------------------

local thresholdSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
thresholdSlider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -40)
thresholdSlider:SetMinMaxValues(2, 12)
thresholdSlider:SetValueStep(1)
thresholdSlider:SetObeyStepOnDrag(true)
thresholdSlider:SetWidth(300)

thresholdSlider.Low:SetText("2")
thresholdSlider.High:SetText("12")

thresholdSlider:SetScript("OnValueChanged", function(self, value)
    local config = GetConfig()
    if not config then return end

    value = math.floor(value + 0.5)
    config.tyrantDemonThreshold = value
    self.Text:SetText("Demonios para Tirano: " .. value)
end)

-------------------------------------------------
-- CHECKBOX BURST
-------------------------------------------------

local burstCheckbox = CreateFrame("CheckButton", nil, panel, "ChatConfigCheckButtonTemplate")
burstCheckbox:SetPoint("TOPLEFT", thresholdSlider, "BOTTOMLEFT", 0, -40)
burstCheckbox.Text:SetText("Activar Burst automático en bosses")

burstCheckbox:SetScript("OnClick", function(self)
    local config = GetConfig()
    if not config then return end
    config.autoBurst = self:GetChecked()
end)

-------------------------------------------------
-- SLIDER TAMAÑO
-------------------------------------------------

local sizeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", burstCheckbox, "BOTTOMLEFT", 0, -60)
sizeSlider:SetMinMaxValues(40, 150)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
sizeSlider:SetWidth(250)

sizeSlider.Low:SetText("40")
sizeSlider.High:SetText("150")

sizeSlider:SetScript("OnValueChanged", function(self, value)
    local config = GetConfig()
    if not config then return end

    value = math.floor(value + 0.5)
    config.iconSize = value
    self.Text:SetText("Tamaño del Icono: " .. value)
    RefreshUI()
end)

-------------------------------------------------
-- SLIDER OPACIDAD
-------------------------------------------------

local alphaSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
alphaSlider:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -60)
alphaSlider:SetMinMaxValues(0.2, 1)
alphaSlider:SetValueStep(0.05)
alphaSlider:SetObeyStepOnDrag(true)
alphaSlider:SetWidth(250)

alphaSlider.Low:SetText("0.2")
alphaSlider.High:SetText("1.0")

alphaSlider:SetScript("OnValueChanged", function(self, value)
    local config = GetConfig()
    if not config then return end

    config.iconAlpha = value
    self.Text:SetText(string.format("Opacidad: %.2f", value))
    RefreshUI()
end)

-------------------------------------------------
-- REGISTRO EN SETTINGS
-------------------------------------------------

local category = Settings.RegisterCanvasLayoutCategory(panel, "DemonBrain")
Settings.RegisterAddOnCategory(category)

-------------------------------------------------
-- SINCRONIZACIÓN INICIAL
-------------------------------------------------

local function SyncSettings()

    local config = GetConfig()
    if not config then return end

    thresholdSlider:SetValue(config.tyrantDemonThreshold or 6)
    thresholdSlider.Text:SetText("Demonios para Tirano: " .. (config.tyrantDemonThreshold or 6))

    burstCheckbox:SetChecked(config.autoBurst or false)

    sizeSlider:SetValue(config.iconSize or 70)
    sizeSlider.Text:SetText("Tamaño del Icono: " .. (config.iconSize or 70))

    alphaSlider:SetValue(config.iconAlpha or 1)
    alphaSlider.Text:SetText(string.format("Opacidad: %.2f", config.iconAlpha or 1))
end

-------------------------------------------------
-- FRAME INIT
-------------------------------------------------

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")

initFrame:SetScript("OnEvent", function()
    C_Timer.After(0.5, function()
        SyncSettings()
        RefreshUI()
    end)
end)

-------------------------------------------------
-- REGISTRO COMO MÓDULO
-------------------------------------------------

DF:RegisterModule("DemonBrainSettings", {
    dependencies = { "DemonBrain" },

    OnEnable = function(self)
        SyncSettings()
    end,
})

-------------------------------------------------
-- MINIMAP BUTTON
-------------------------------------------------

local minimapFrame = CreateFrame("Frame")
minimapFrame:RegisterEvent("PLAYER_LOGIN")

minimapFrame:SetScript("OnEvent", function()

    local config = GetConfig()
    if not config then return end

    -- Crear botón
    local btn = CreateFrame("Button", "DemonBrainMiniMapButton", Minimap)
    btn:SetSize(32, 32)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Spell_Shadow_DemonForm")
    icon:SetAllPoints()

    -- Posición circular fija (simple)
    btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

    -------------------------------------------------
    -- CLICK
    -------------------------------------------------

    btn:SetScript("OnClick", function(self, button)

        local config = GetConfig()
        if not config then return end

        -- SHIFT + CLICK IZQUIERDO → Toggle Burst
        if IsShiftKeyDown() and button == "LeftButton" then
            config.autoBurst = not config.autoBurst

            if config.autoBurst then
                print("|cff00ff00DemonBrain: Burst ACTIVADO|r")
            else
                print("|cffff0000DemonBrain: Burst DESACTIVADO|r")
            end

            return
        end

        -- CLICK IZQUIERDO → Abrir configuración
        if button == "LeftButton" then
            Settings.OpenToCategory(category:GetID())
            Settings.OpenToCategory(category:GetID())
            return
        end

        -- CLICK DERECHO → Ocultar icono principal
        if button == "RightButton" then
            config.hideMainIcon = not config.hideMainIcon
            RefreshUI()
        end
    end)

    -------------------------------------------------
    -- TOOLTIP
    -------------------------------------------------

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("DemonBrain", 1, 0.82, 0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click Izquierdo: Configuración")
        GameTooltip:AddLine("Click Derecho: Ocultar Icono")
        GameTooltip:AddLine("Shift + Click Izquierdo: Toggle Burst")
        GameTooltip:AddLine(" ")

        if config.autoBurst then
            GameTooltip:AddLine("Burst: ACTIVADO", 0,1,0)
        else
            GameTooltip:AddLine("Burst: DESACTIVADO", 1,0,0)
        end

        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end)