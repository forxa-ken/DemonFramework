-- ============================================================
-- DemonBrain Settings + Minimap Control FINAL
-- ============================================================

DemonBrainDB = DemonBrainDB or {}

DemonBrainDB.tyrantDemonThreshold = DemonBrainDB.tyrantDemonThreshold or 6
DemonBrainDB.autoBurst = DemonBrainDB.autoBurst or false
DemonBrainDB.iconSize = DemonBrainDB.iconSize or 70
DemonBrainDB.iconAlpha = DemonBrainDB.iconAlpha or 1
DemonBrainDB.minimapAngle = DemonBrainDB.minimapAngle or 200
DemonBrainDB.hideMainIcon = DemonBrainDB.hideMainIcon or false

-------------------------------------------------
-- REFRESH FUNCTION
-------------------------------------------------

local function RefreshUI()

    if DemonBrainMain then
        DemonBrainMain:SetSize(DemonBrainDB.iconSize, DemonBrainDB.iconSize)
        DemonBrainMain:SetAlpha(DemonBrainDB.iconAlpha)

        if DemonBrainDB.hideMainIcon then
            DemonBrainMain:Hide()
        else
            DemonBrainMain:Show()
        end
    end

    if DemonBrainCore then
        DemonBrainCore.SetTyrantThreshold(DemonBrainDB.tyrantDemonThreshold)
        DemonBrainCore.SetBurstMode(DemonBrainDB.autoBurst)
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
thresholdSlider:SetValue(DemonBrainDB.tyrantDemonThreshold)

thresholdSlider.Text:SetText("Demonios para Tirano: " .. DemonBrainDB.tyrantDemonThreshold)
thresholdSlider.Low:SetText("2")
thresholdSlider.High:SetText("12")

thresholdSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    DemonBrainDB.tyrantDemonThreshold = value
    self.Text:SetText("Demonios para Tirano: " .. value)
    RefreshUI()
end)
-------------------------------------------------
-- EXPLICACIÓN UMBRAL TIRANO
-------------------------------------------------

local tyrantInfo = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
tyrantInfo:SetPoint("TOPLEFT", thresholdSlider, "BOTTOMLEFT", 0, -25)
tyrantInfo:SetWidth(450)
tyrantInfo:SetJustifyH("LEFT")
tyrantInfo:SetText(
    "Número mínimo de demonios activos necesarios antes de\n" ..
    "que el addon sugiera Invocar Tirano demoníaco.\n\n" ..
    "• Valores bajos=Tirano más frecuente.\n" ..
    "• Valores altos=Ventanas de burst más fuertes.\n\n" ..
    "Recomendado:\n" ..
    "• Raid: 6-8 demonios\n" ..
    "• Mythic+: 4-6 demonios"
)
-------------------------------------------------
-- CHECKBOX BURST
-------------------------------------------------

local burstCheckbox = CreateFrame("CheckButton", nil, panel, "ChatConfigCheckButtonTemplate")
burstCheckbox:SetPoint("TOPLEFT", tyrantInfo, "BOTTOMLEFT", 0, -30)
burstCheckbox.Text:SetText("Activar Burst automático en bosses")
burstCheckbox:SetChecked(DemonBrainDB.autoBurst)

burstCheckbox:SetScript("OnClick", function(self)
    DemonBrainDB.autoBurst = self:GetChecked()
    RefreshUI()
end)

-------------------------------------------------
-- DESCRIPCIÓN BURST
-------------------------------------------------

local burstInfo = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
burstInfo:SetPoint("TOPLEFT", burstCheckbox, "BOTTOMLEFT", 0, -20)
burstInfo:SetWidth(420)
burstInfo:SetJustifyH("LEFT")
burstInfo:SetText(
    "Modo Burst automático:\n\n" ..
    "• Activa Tirano automáticamente en bosses.\n" ..
    "• Respeta el número mínimo de demonios configurado.\n" ..
    "• Fuera de bosses mantiene rotación normal.\n\n" ..
    "Atajo rápido: Shift + Click en el botón del minimapa."
)

-------------------------------------------------
-- SLIDER TAMAÑO
-------------------------------------------------

local sizeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", burstInfo, "BOTTOMLEFT", 0, -40)
sizeSlider:SetMinMaxValues(40, 150)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
sizeSlider:SetWidth(250)
sizeSlider:SetValue(DemonBrainDB.iconSize)

sizeSlider.Text:SetText("Tamaño del Icono: " .. DemonBrainDB.iconSize)
sizeSlider.Low:SetText("40")
sizeSlider.High:SetText("150")

sizeSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    DemonBrainDB.iconSize = value
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
alphaSlider:SetValue(DemonBrainDB.iconAlpha)

alphaSlider.Text:SetText(string.format("Opacidad: %.2f", DemonBrainDB.iconAlpha))
alphaSlider.Low:SetText("0.2")
alphaSlider.High:SetText("1.0")

alphaSlider:SetScript("OnValueChanged", function(self, value)
    DemonBrainDB.iconAlpha = value
    self.Text:SetText(string.format("Opacidad: %.2f", value))
    RefreshUI()
end)

-------------------------------------------------
-- FOOTER
-------------------------------------------------

local footer = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
footer:SetPoint("BOTTOMLEFT", 20, 20)
footer:SetText("DemonBrain\nDesarrollado por Forxaken")

-------------------------------------------------
-- REGISTRO
-------------------------------------------------

local category = Settings.RegisterCanvasLayoutCategory(panel, "DemonBrain")
Settings.RegisterAddOnCategory(category)
DemonBrainCategoryID = category:GetID()

-------------------------------------------------
-- MINIMAP BUTTON
-------------------------------------------------

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")

loginFrame:SetScript("OnEvent", function()

    local minimapButton = CreateFrame("Button", "DemonBrainMiniMapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:RegisterForDrag("LeftButton")

    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Spell_Shadow_DemonForm")
    icon:SetAllPoints()

    -------------------------------------------------
    -- POSICIÓN CIRCULAR
    -------------------------------------------------

    local function UpdateMinimapPosition()
        local angle = DemonBrainDB.minimapAngle
        local radius = 80
        local x = math.cos(math.rad(angle)) * radius
        local y = math.sin(math.rad(angle)) * radius
        minimapButton:ClearAllPoints()
        minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    UpdateMinimapPosition()

    minimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = UIParent:GetScale()
            cx = cx / scale
            cy = cy / scale
            local angle = math.deg(math.atan2(cy - my, cx - mx))
            DemonBrainDB.minimapAngle = angle
            UpdateMinimapPosition()
        end)
    end)

    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -------------------------------------------------
    -- CLICK COMPORTAMIENTO
    -------------------------------------------------

    minimapButton:SetScript("OnClick", function(self, button)

        -- SHIFT + CLICK IZQUIERDO → Burst
        if IsShiftKeyDown() and button == "LeftButton" then
            DemonBrainDB.autoBurst = not DemonBrainDB.autoBurst
            RefreshUI()

            if DemonBrainDB.autoBurst then
                print("|cff00ff00DemonBrain: Burst ACTIVADO|r")
            else
                print("|cffff0000DemonBrain: Burst DESACTIVADO|r")
            end
            return
        end

        -- CLICK IZQUIERDO → Configuración
        if button == "LeftButton" then
            Settings.OpenToCategory(DemonBrainCategoryID)
            Settings.OpenToCategory(DemonBrainCategoryID)
            return
        end

        -- CLICK DERECHO → Ocultar/Mostrar icono spell
        if button == "RightButton" then
            DemonBrainDB.hideMainIcon = not DemonBrainDB.hideMainIcon
            RefreshUI()
        end
    end)

    -------------------------------------------------
    -- TOOLTIP
    -------------------------------------------------

    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("DemonBrain", 1, 0.82, 0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click Izquierdo: Abrir Configuración")
        GameTooltip:AddLine("Click Derecho: Mostrar/Ocultar Icono")
        GameTooltip:AddLine("Shift + Click Izquierdo: Alternar Burst")
        GameTooltip:AddLine(" ")

        if DemonBrainDB.autoBurst then
            GameTooltip:AddLine("Burst: ACTIVADO", 0,1,0)
        else
            GameTooltip:AddLine("Burst: DESACTIVADO", 1,0,0)
        end

        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    RefreshUI()
end)