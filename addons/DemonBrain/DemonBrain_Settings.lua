-- ============================================================
-- DemonBrain Settings
-- Modern UI + 3 Burst Modes + Stable Minimap Button + Scroll Fix
-- ============================================================
local DF = DemonFramework
local header
local sub
local tyrantSection
local burstSection
local uiSection
local thresholdSlider
local sizeSlider
local alphaSlider
local langDesc
local tyrantDesc
local burstDesc
local uiDesc
local reloadBtn
local langDropdown
local SyncSettings

local function RefreshAllTexts()

        local L = DemonBrain_L or {}

        if header then
            header:SetText(L.TITLE or "")
        end

        if sub then
            sub:SetText(L.SUBTITLE or "")
        end

        if tyrantSection and tyrantSection.title then
            tyrantSection.title:SetText(L.SECTION_TYRANT or "")
        end

        if burstSection and burstSection.title then
            burstSection.title:SetText(L.SECTION_BURST or "")
        end

        if uiSection and uiSection.title then
            uiSection.title:SetText(L.SECTION_UI or "")
        end

        local config
        if DemonBrainCore and DemonBrainCore.GetConfig then
            config = DemonBrainCore:GetConfig()
        end
        if config then

            if thresholdSlider and thresholdSlider.Text then
                thresholdSlider.Text:SetText((L.SLIDER_DEMONS or "") .. " " .. config.tyrantDemonThreshold)
            end

            if sizeSlider and sizeSlider.Text then
                sizeSlider.Text:SetText((L.SLIDER_SIZE or "") .. " " .. config.iconSize)
            end

            if alphaSlider and alphaSlider.Text then
                alphaSlider.Text:SetText((L.SLIDER_ALPHA or "") .. " " .. string.format("%.2f", config.iconAlpha))
            end
            if langDesc then
                langDesc:SetText(L.LANG_DESC)
            end

            if tyrantDesc then
                tyrantDesc:SetText(L.TYRANT_DESC)
            end

            if burstDesc then
                burstDesc:SetText(L.BURST_DESC)
            end

            if uiDesc then
                uiDesc:SetText(L.UI_DESC)
            end

            if reloadBtn then
                reloadBtn:SetText(L.RELOAD_BUTTON)
            end
            if config.burstMode then
                DemonBrain_SetBurstMode(config.burstMode)
            end
        end
end


local function GetLocaleTable()
    if DemonBrain_L then
        return DemonBrain_L
    end

    -- fallback seguro
    return {
        TITLE = "DemonBrain",
        SUBTITLE = "",
        SECTION_LANG = "Language",
        LANGUAGE_EN = "English",
        LANGUAGE_ES = "Spanish",
    }
end
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
    config.language = config.language or GetLocale()
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
-- PANEL BASE CON SCROLL REAL (COMPATIBLE SETTINGS API)
-------------------------------------------------
local panel = CreateFrame("Frame")
panel.name = "DemonBrain"
panel:SetSize(1,1)

local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetPoint("TOPLEFT", 0, 0)
content:SetWidth(600)
content:SetHeight(1400)

scrollFrame:SetScrollChild(content)

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
-- HEADER
-------------------------------------------------

header = content:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
header:SetPoint("TOPLEFT",20,-20)
header:SetText(GetLocaleTable().TITLE)

sub = content:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
sub:SetPoint("TOPLEFT",header,"BOTTOMLEFT",0,-5)
sub:SetText(GetLocaleTable().SUBTITLE)

-------------------------------------------------
-- LANGUAGE SECTION (Styled)
-------------------------------------------------

local langSection = CreateSection(content, GetLocaleTable().SECTION_LANG, 520, 140)
    langSection:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", -10, -20)

    langDesc = langSection:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
    langDesc:SetPoint("TOPLEFT",langSection.title,"BOTTOMLEFT",0,-8)
    langDesc:SetWidth(480)
    langDesc:SetJustifyH("LEFT")
    langDesc:SetText(GetLocaleTable().LANG_DESC)

    langDropdown = CreateFrame("Frame","DemonBrainLangDropdown",langSection,"UIDropDownMenuTemplate")
    langDropdown:SetPoint("TOPLEFT",langDesc,"BOTTOMLEFT",-15,-10)
    UIDropDownMenu_SetWidth(langDropdown,200)

    local function RefreshTexts()
        header:SetText(GetLocaleTable().TITLE)
        sub:SetText(GetLocaleTable().SUBTITLE)
    end

   local function SetLanguage(lang)
        DemonBrain_SetLanguage(lang)
        RefreshAllTexts()
    end

    UIDropDownMenu_Initialize(langDropdown,function(self,level)
        local L = GetLocaleTable()

        local function Add(text,lang)
            local info = UIDropDownMenu_CreateInfo()
            info.text = text
            info.func = function()
                SetLanguage(lang)
                UIDropDownMenu_SetText(langDropdown, text)
            end
            UIDropDownMenu_AddButton(info)
        end

        Add(L.LANGUAGE_EN,"enUS")
        Add(L.LANGUAGE_ES,"esES")
    end)
        reloadBtn = CreateFrame("Button", nil, langSection, "UIPanelButtonTemplate")
        reloadBtn:SetSize(140, 22)
        reloadBtn:SetPoint("TOPLEFT", langDropdown, "BOTTOMLEFT", 20, -10)
        reloadBtn:SetText(GetLocaleTable().RELOAD_BUTTON)

        reloadBtn:SetScript("OnClick", function()
            ReloadUI()
        end)
   



-------------------------------------------------
-- SECCIÓN TIRANO
-------------------------------------------------

tyrantSection = CreateSection(content,GetLocaleTable().SECTION_TYRANT,520,180)
-- CORRECCIÓN: ahora anclado debajo del idioma
tyrantSection:SetPoint("TOPLEFT",langSection,"BOTTOMLEFT",0,-20)

tyrantDesc = tyrantSection:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
tyrantDesc:SetPoint("TOPLEFT",tyrantSection.title,"BOTTOMLEFT",0,-8)
tyrantDesc:SetWidth(480)
tyrantDesc:SetJustifyH("LEFT")
tyrantDesc:SetText(GetLocaleTable().TYRANT_DESC)

thresholdSlider = CreateFrame("Slider",nil,tyrantSection,"OptionsSliderTemplate")
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
    self.Text:SetText(GetLocaleTable().SLIDER_DEMONS.." "..value)
end)

-------------------------------------------------
-- SECCIÓN BURST
-------------------------------------------------

burstSection = CreateSection(content,GetLocaleTable().SECTION_BURST,520,240)
burstSection:SetPoint("TOPLEFT",tyrantSection,"BOTTOMLEFT",0,-20)

burstDesc = burstSection:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
burstDesc:SetPoint("TOPLEFT",burstSection.title,"BOTTOMLEFT",0,-8)
burstDesc:SetWidth(480)
burstDesc:SetJustifyH("LEFT")
burstDesc:SetText(GetLocaleTable().BURST_DESC)


local burstDropdown = CreateFrame("Frame","DemonBrainBurstDropdown",burstSection,"UIDropDownMenuTemplate")
burstDropdown:SetPoint("TOPLEFT",burstDesc,"BOTTOMLEFT",-15,-10)
UIDropDownMenu_SetWidth(burstDropdown,280)

function DemonBrain_SetBurstMode(mode)
    local config = GetConfig()
    if not config then return end
    config.burstMode = mode
    local L = GetLocaleTable()
    local map = {
        normal=L.MODE_NORMAL,
        manual=L.MODE_MANUAL,
        auto=L.MODE_AUTO
    }

    UIDropDownMenu_SetText(burstDropdown,map[mode])
end

UIDropDownMenu_Initialize(burstDropdown,function(self,level)
    local function Add(text,mode)
        local info = UIDropDownMenu_CreateInfo()
        info.text = text
        info.func = function() DemonBrain_SetBurstMode(mode) end
        UIDropDownMenu_AddButton(info)
    end
    local L = GetLocaleTable()

    Add(L.MODE_NORMAL,"normal")
    Add(L.MODE_MANUAL,"manual")
    Add(L.MODE_AUTO,"auto")
end)

-------------------------------------------------
-- SECCIÓN UI
-------------------------------------------------

uiSection = CreateSection(content,GetLocaleTable().SECTION_UI,520,200)
uiSection:SetPoint("TOPLEFT",burstSection,"BOTTOMLEFT",0,-20)

uiDesc = uiSection:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
uiDesc:SetPoint("TOPLEFT",uiSection.title,"BOTTOMLEFT",0,-8)
uiDesc:SetWidth(480)
uiDesc:SetJustifyH("LEFT")
uiDesc:SetText(GetLocaleTable().UI_DESC)

sizeSlider = CreateFrame("Slider",nil,uiSection,"OptionsSliderTemplate")
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
    self.Text:SetText(GetLocaleTable().SLIDER_SIZE.." "..value)
    RefreshUI()
end)

alphaSlider = CreateFrame("Slider",nil,uiSection,"OptionsSliderTemplate")
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
    self.Text:SetText(GetLocaleTable().SLIDER_ALPHA.." "..string.format("%.2f",value))
    RefreshUI()
end)

-------------------------------------------------
-- ALTURA DINÁMICA REAL
-------------------------------------------------
--[[panel:SetScript("OnShow", function()
    local bottom = uiSection:GetBottom()
    local top = content:GetTop()
    if bottom and top then
        content:SetHeight(top - bottom + 40)
    end
    RefreshAllTexts()
end)--]]

panel:SetScript("OnShow", function()

    local config = GetConfig()
    if config then
        EnsureDefaults(config)
    end

    SyncSettings()        -- 👈 ESTA LÍNEA FALTABA
    RefreshAllTexts()

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

function SyncSettings()
    local config = GetConfig()
    if not config then return end
    EnsureDefaults(config)
    local L = GetLocaleTable()
    local currentLang = DemonBrainDB and DemonBrainDB.language or "enUS"

    if currentLang == "esES" then
        UIDropDownMenu_SetText(langDropdown, L.LANGUAGE_ES)
    else
        UIDropDownMenu_SetText(langDropdown, L.LANGUAGE_EN)
    end
       
    thresholdSlider:SetValue(config.tyrantDemonThreshold)
    thresholdSlider.Text:SetText("Demonios requeridos: "..config.tyrantDemonThreshold)

    sizeSlider:SetValue(config.iconSize)
    sizeSlider.Text:SetText("Tamaño del Icono: "..config.iconSize)

    alphaSlider:SetValue(config.iconAlpha)
    alphaSlider.Text:SetText(string.format("Opacidad: %.2f",config.iconAlpha))

   DemonBrain_SetBurstMode(config.burstMode)
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

            local L = GetLocaleTable()

            GameTooltip:SetOwner(self,"ANCHOR_LEFT")
            GameTooltip:AddLine("DemonBrain",1,0.82,0)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L.MINIMAP_LEFT)
            GameTooltip:AddLine(L.MINIMAP_RIGHT)
            GameTooltip:AddLine(L.MINIMAP_SHIFT)
            GameTooltip:AddLine(" ")

            local config = GetConfig()
            local modeText = {
                normal = L.MODE_NORMAL,
                manual = L.MODE_MANUAL,
                auto   = L.MODE_AUTO
            }

            GameTooltip:AddLine(L.MINIMAP_CURRENT.." "..(modeText[config.burstMode] or ""),0,1,0)
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave",function()
            GameTooltip:Hide()
        end)

    end)
end)