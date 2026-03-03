-- ============================================================
-- DemonBrain Settings
-- Modern UI + 3 Burst Modes + Stable Minimap Button + Scroll Fix
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

local function EnsureDefaults(config)
    config.tyrantDemonThreshold = config.tyrantDemonThreshold or 6
    config.iconSize = config.iconSize or 70
    config.iconAlpha = config.iconAlpha or 1
    config.burstMode = config.burstMode or "normal"
    config.minimapAngle = config.minimapAngle or 200
end

local function RefreshUI()
    local config = GetConfig()
    if not config then return end

    if DemonBrainMain then
        DemonBrainMain:SetSize(config.iconSize, config.iconSize)
        DemonBrainMain:SetAlpha(config.iconAlpha)

        if config.hideMainIcon then
            DemonBrainMain:Hide()
        else
            DemonBrainMain:Show()
        end
    end
end

-------------------------------------------------
-- PANEL BASE CON SCROLL CORRECTO
-------------------------------------------------

-------------------------------------------------
-- PANEL BASE CON SCROLL REAL (COMPATIBLE SETTINGS API)
-------------------------------------------------

local panel = CreateFrame("Frame")
panel.name = "DemonBrain"

panel:SetSize(1, 1) -- necesario para Settings API

-- Scroll Container
local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

-- Contenido interno
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetPoint("TOPLEFT", 0, 0)
content:SetWidth(600)
content:SetHeight(1200) -- altura virtual amplia

scrollFrame:SetScrollChild(content)

-------------------------------------------------
-- HEADER
-------------------------------------------------

local header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
header:SetPoint("TOPLEFT", 20, -20)
header:SetText("DemonBrain - Configuración Avanzada")

local sub = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
sub:SetText("Control inteligente para Brujo Demonología")

-------------------------------------------------
-- FUNCIÓN PARA SECCIONES
-------------------------------------------------

local function CreateSection(parent, title, width, height)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(width, height)

    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })

    f:SetBackdropColor(0.08,0.08,0.08,0.95)

    local t = f:CreateFontString(nil,"ARTWORK","GameFontNormal")
    t:SetPoint("TOPLEFT",15,-10)
    t:SetText(title)

    f.title = t
    return f
end

-------------------------------------------------
-- SECCIÓN TIRANO
-------------------------------------------------

local tyrantSection = CreateSection(content,"Invocar Tirano Demoníaco",520,180)
tyrantSection:SetPoint("TOPLEFT",sub,"BOTTOMLEFT",-10,-20)

local tyrantDesc = tyrantSection:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
tyrantDesc:SetPoint("TOPLEFT",tyrantSection.title,"BOTTOMLEFT",0,-8)
tyrantDesc:SetWidth(480)
tyrantDesc:SetJustifyH("LEFT")
tyrantDesc:SetText(
"Define el número mínimo de demonios activos antes de recomendar Tirano.\n\n"..
"• Valores bajos → Uso más frecuente.\n"..
"• Valores altos → Ventanas de daño más fuertes.\n\n"..
"Recomendación: Raid 6-8 | Mythic+ 4-6"
)

local thresholdSlider = CreateFrame("Slider",nil,tyrantSection,"OptionsSliderTemplate")
thresholdSlider:SetPoint("TOPLEFT",tyrantDesc,"BOTTOMLEFT",0,-25)
thresholdSlider:SetMinMaxValues(2,12)
thresholdSlider:SetValueStep(1)
thresholdSlider:SetObeyStepOnDrag(true)
thresholdSlider:SetWidth(300)
thresholdSlider.Low:SetText("2")
thresholdSlider.High:SetText("12")
thresholdSlider.Text = thresholdSlider:CreateFontString(nil,"ARTWORK","GameFontHighlight")
thresholdSlider.Text:SetPoint("TOP", thresholdSlider, "BOTTOM", 0, -2)
thresholdSlider:SetScript("OnValueChanged",function(self,value)
    local config = GetConfig()
    if not config then return end
    value = math.floor(value+0.5)
    config.tyrantDemonThreshold = value
    self.Text:SetText("Demonios requeridos: "..value)
end)

-------------------------------------------------
-- SECCIÓN BURST
-------------------------------------------------

local burstSection = CreateSection(content,"Modos de Burst",520,240)
burstSection:SetPoint("TOPLEFT",tyrantSection,"BOTTOMLEFT",0,-20)

local burstDesc = burstSection:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
burstDesc:SetPoint("TOPLEFT",burstSection.title,"BOTTOMLEFT",0,-8)
burstDesc:SetWidth(480)
burstDesc:SetJustifyH("LEFT")
burstDesc:SetText(
"Modo Normal:\n"..
"• Usa el umbral configurado.\n"..
"• Rotación equilibrada.\n\n"..
"Burst Manual:\n"..
"• Tirano prioridad absoluta.\n"..
"• Ideal para heroísmo o sincronización.\n\n"..
"Burst Automático:\n"..
"• Se activa solo contra elites o bosses.\n"..
"• Comportamiento normal contra enemigos comunes."
)

local burstDropdown = CreateFrame("Frame","DemonBrainBurstDropdown",burstSection,"UIDropDownMenuTemplate")
burstDropdown:SetPoint("TOPLEFT",burstDesc,"BOTTOMLEFT",-15,-10)
UIDropDownMenu_SetWidth(burstDropdown,280)

local function SetBurstMode(mode)
    local config = GetConfig()
    if not config then return end
    config.burstMode = mode

    local map = {
        normal="Modo Normal",
        manual="Burst Manual",
        auto="Burst Automático"
    }

    UIDropDownMenu_SetText(burstDropdown,map[mode])
end

UIDropDownMenu_Initialize(burstDropdown,function(self,level)
    local function Add(text,mode)
        local info = UIDropDownMenu_CreateInfo()
        info.text = text
        info.func = function() SetBurstMode(mode) end
        UIDropDownMenu_AddButton(info)
    end
    Add("Modo Normal","normal")
    Add("Burst Manual","manual")
    Add("Burst Automático (Elite/Boss)","auto")
end)

-------------------------------------------------
-- SECCIÓN UI
-------------------------------------------------

local uiSection = CreateSection(content,"Interfaz y Apariencia",520,200)
uiSection:SetPoint("TOPLEFT",burstSection,"BOTTOMLEFT",0,-20)

local uiDesc = uiSection:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
uiDesc:SetPoint("TOPLEFT",uiSection.title,"BOTTOMLEFT",0,-8)
uiDesc:SetWidth(480)
uiDesc:SetJustifyH("LEFT")
uiDesc:SetText(
"Personaliza el tamaño y la opacidad del icono de sugerencia.\n"..
"Puedes ocultarlo temporalmente desde el botón del minimapa."
)

local sizeSlider = CreateFrame("Slider",nil,uiSection,"OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT",uiDesc,"BOTTOMLEFT",0,-25)
sizeSlider:SetMinMaxValues(40,150)
sizeSlider:SetValueStep(1)
sizeSlider:SetWidth(250)
sizeSlider.Low:SetText("40")
sizeSlider.High:SetText("150")

sizeSlider:SetScript("OnValueChanged",function(self,value)
    local config = GetConfig()
    if not config then return end
    value = math.floor(value+0.5)
    config.iconSize = value
    self.Text:SetText("Tamaño del Icono: "..value)
    RefreshUI()
end)

local alphaSlider = CreateFrame("Slider",nil,uiSection,"OptionsSliderTemplate")
alphaSlider:SetPoint("TOPLEFT",sizeSlider,"BOTTOMLEFT",0,-60)
alphaSlider:SetMinMaxValues(0.2,1)
alphaSlider:SetValueStep(0.05)
alphaSlider:SetWidth(250)
alphaSlider.Low:SetText("0.2")
alphaSlider.High:SetText("1.0")

alphaSlider:SetScript("OnValueChanged",function(self,value)
    local config = GetConfig()
    if not config then return end
    config.iconAlpha = value
    self.Text:SetText(string.format("Opacidad: %.2f",value))
    RefreshUI()
end)

-------------------------------------------------
-- ALTURA DINÁMICA REAL
-------------------------------------------------
panel:SetScript("OnShow", function()
    local bottom = uiSection:GetBottom()
    local top = content:GetTop()
    if bottom and top then
        content:SetHeight(top - bottom + 40)
    end
end)
-------------------------------------------------
-- REGISTRO SETTINGS
-------------------------------------------------

local category = Settings.RegisterCanvasLayoutCategory(panel,"DemonBrain")
Settings.RegisterAddOnCategory(category)

local function SyncSettings()
    local config = GetConfig()
    if not config then return end
    EnsureDefaults(config)

    thresholdSlider:SetValue(config.tyrantDemonThreshold)
    thresholdSlider.Text:SetText("Demonios requeridos: "..config.tyrantDemonThreshold)

    sizeSlider:SetValue(config.iconSize)
    sizeSlider.Text:SetText("Tamaño del Icono: "..config.iconSize)

    alphaSlider:SetValue(config.iconAlpha)
    alphaSlider.Text:SetText(string.format("Opacidad: %.2f",config.iconAlpha))

    SetBurstMode(config.burstMode)
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")

initFrame:SetScript("OnEvent",function()
    C_Timer.After(0.4,function()
        local config = GetConfig()
        if config then
            EnsureDefaults(config)
            SyncSettings()
            RefreshUI()
        end
    end)
end)

DF:RegisterModule("DemonBrainSettings",{
    dependencies={"DemonBrain"},
    OnEnable=function(self)
        SyncSettings()
    end
})

-------------------------------------------------
-- MINIMAP BUTTON (NO TOCADO)
-------------------------------------------------

-------------------------------------------------
-- MINIMAP BUTTON (STABLE)
-------------------------------------------------

local minimapFrame = CreateFrame("Frame")
minimapFrame:RegisterEvent("PLAYER_LOGIN")

minimapFrame:SetScript("OnEvent",function()

    C_Timer.After(0.5,function()

        local config = GetConfig()
        if not config then return end
        EnsureDefaults(config)

       local btn = _G["DemonBrainMiniMapButton"]
        if not btn then
            btn = CreateFrame("Button","DemonBrainMiniMapButton",Minimap)
        end
        btn:SetSize(31,31)
        btn:SetFrameStrata("MEDIUM")
        btn:RegisterForClicks("LeftButtonUp","RightButtonUp")
        btn:RegisterForDrag("LeftButton")

        btn.icon = btn:CreateTexture(nil,"BACKGROUND")
        btn.icon:SetTexture("Interface\\Icons\\Spell_Shadow_DemonForm")
        btn.icon:SetSize(20,20)
        btn.icon:SetPoint("CENTER")

        btn.border = btn:CreateTexture(nil,"OVERLAY")
        btn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        btn.border:SetSize(53,53)
        btn.border:SetPoint("TOPLEFT")

        btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

        local function UpdatePosition()
            local angle = math.rad(config.minimapAngle)
            local radius = Minimap:GetWidth()/2
            local x = math.cos(angle)*radius
            local y = math.sin(angle)*radius
            btn:ClearAllPoints()
            btn:SetPoint("CENTER",Minimap,"CENTER",x,y)
        end

        UpdatePosition()

        btn:SetScript("OnDragStart",function(self)
            self:SetScript("OnUpdate",function()
                local mx,my = Minimap:GetCenter()
                local cx,cy = GetCursorPosition()
                local scale = UIParent:GetEffectiveScale()
                cx,cy = cx/scale, cy/scale
                local angle = math.deg(math.atan2(cy-my,cx-mx))
                config.minimapAngle = angle
                UpdatePosition()
            end)
        end)

        btn:SetScript("OnDragStop",function(self)
            self:SetScript("OnUpdate",nil)
        end)

        btn:SetScript("OnClick",function(self,button)

            if IsShiftKeyDown() and button=="LeftButton" then
                local modes={"normal","manual","auto"}
                local current=config.burstMode
                local idx=1
                for i,v in ipairs(modes) do
                    if v==current then idx=i break end
                end
                idx=idx+1
                if idx>#modes then idx=1 end
                config.burstMode=modes[idx]
                print("|cff00ff00DemonBrain: Modo -> "..config.burstMode.."|r")
                return
            end

            if button=="LeftButton" then
                if InCombatLockdown() then
                    print("|cffff0000DemonBrain: No puedes abrir configuración en combate.|r")
                    return
                end
                Settings.OpenToCategory(category:GetID())
                Settings.OpenToCategory(category:GetID())
            end

            if button=="RightButton" then
                config.hideMainIcon = not config.hideMainIcon
                RefreshUI()
            end
        end)

        btn:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self,"ANCHOR_LEFT")
            GameTooltip:AddLine("DemonBrain",1,0.82,0)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Click Izquierdo: Configuración")
            GameTooltip:AddLine("Click Derecho: Ocultar Icono")
            GameTooltip:AddLine("Shift + Click: Cambiar modo")
            GameTooltip:AddLine(" ")
            local modeText = {
                normal = "Modo Normal",
                manual = "Burst Manual",
                auto   = "Burst Automático"
            }

            GameTooltip:AddLine("Modo actual: "..modeText[config.burstMode],0,1,0)
          --  GameTooltip:AddLine("Modo actual: "..config.burstMode,0,1,0)
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave",function()
            GameTooltip:Hide()
        end)

    end)
end)