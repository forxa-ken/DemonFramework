-- ============================================================
-- DemonBrain UI
-- Compatible con DemonBrain_Core (Retail Safe)
-- ============================================================

local SPELL_DEMONBOLT = 264178

-------------------------------------------------
-- SEGURIDAD DB
-------------------------------------------------

DemonBrainDB = DemonBrainDB or {}
DemonBrainDB.iconSize  = DemonBrainDB.iconSize or 70
DemonBrainDB.iconAlpha = DemonBrainDB.iconAlpha or 1
DemonBrainDB.hideMainIcon = DemonBrainDB.hideMainIcon or false

-------------------------------------------------
-- FRAME PRINCIPAL (GLOBAL)
-------------------------------------------------

DemonBrainMain = CreateFrame("Frame", "DemonBrainMain", UIParent)

local function ApplyIconStyle()
    DemonBrainMain:SetSize(DemonBrainDB.iconSize, DemonBrainDB.iconSize)
    DemonBrainMain:SetAlpha(DemonBrainDB.iconAlpha)
end

ApplyIconStyle()

DemonBrainMain:SetPoint("CENTER", 0, -150)
DemonBrainMain:SetMovable(true)
DemonBrainMain:EnableMouse(true)
DemonBrainMain:RegisterForDrag("LeftButton")

DemonBrainMain:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

DemonBrainMain:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-------------------------------------------------
-- ICONO
-------------------------------------------------

DemonBrainMain.icon = DemonBrainMain:CreateTexture(nil, "BACKGROUND")
DemonBrainMain.icon:SetAllPoints()

DemonBrainMain.cooldown = CreateFrame("Cooldown", nil, DemonBrainMain, "CooldownFrameTemplate")
DemonBrainMain.cooldown:SetAllPoints()

-------------------------------------------------
-- GLOW (NÚCLEO DEMONÍACO)
-------------------------------------------------

DemonBrainMain.glow = DemonBrainMain:CreateTexture(nil, "OVERLAY")
DemonBrainMain.glow:SetAllPoints()
DemonBrainMain.glow:SetTexture("Interface\\Cooldown\\star4")
DemonBrainMain.glow:SetBlendMode("ADD")
DemonBrainMain.glow:SetVertexColor(0.4, 0.6, 1)
DemonBrainMain.glow:SetAlpha(0)

-------------------------------------------------
-- ANIMACIÓN TIPO WEAKAURAS
-------------------------------------------------

local animGroup = DemonBrainMain:CreateAnimationGroup()

local pulseUp = animGroup:CreateAnimation("Scale")
pulseUp:SetScale(1.15, 1.15)
pulseUp:SetDuration(0.25)
pulseUp:SetOrder(1)

local pulseDown = animGroup:CreateAnimation("Scale")
pulseDown:SetScale(0.87, 0.87)
pulseDown:SetDuration(0.25)
pulseDown:SetOrder(2)

animGroup:SetLooping("REPEAT")

local function StartAnimation()
    if not animGroup:IsPlaying() then
        animGroup:Play()
    end
    DemonBrainMain.glow:SetAlpha(0.8)
end

local function StopAnimation()
    if animGroup:IsPlaying() then
        animGroup:Stop()
    end
    DemonBrainMain:SetScale(1)
    DemonBrainMain.glow:SetAlpha(0)
end

-------------------------------------------------
-- DETECCIÓN NÚCLEO DEMONÍACO (método estable)
-------------------------------------------------

local function DemonCoreActive()
    local info = C_Spell.GetSpellInfo(SPELL_DEMONBOLT)
    if not info then return false end
    return info.castTime == 0
end

-------------------------------------------------
-- UPDATE UI
-------------------------------------------------

local currentSpell = nil

local function UpdateUI()

    if not DemonBrainCore then return end

    local spellID = DemonBrainCore.GetNextSpell()
    if not spellID then return end

    -------------------------------------------------
    -- Cambiar icono si la spell cambia
    -------------------------------------------------

    if spellID ~= currentSpell then
        currentSpell = spellID

        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.iconID then
            DemonBrainMain.icon:SetTexture(info.iconID)
        end
    end

    -------------------------------------------------
    -- Cooldown visual (sin lógica)
    -------------------------------------------------

    local cd = C_Spell.GetSpellCooldown(spellID)
    if cd and cd.startTime and cd.duration then
        DemonBrainMain.cooldown:SetCooldown(cd.startTime, cd.duration)
    end

    -------------------------------------------------
    -- Animación SOLO si:
    -- Spell = Demonbolt
    -- Núcleo Demoníaco activo
    -------------------------------------------------

    if spellID == SPELL_DEMONBOLT and DemonCoreActive() then
        StartAnimation()
    else
        StopAnimation()
    end
end

-------------------------------------------------
-- EVENTOS (sin OnUpdate)
-------------------------------------------------

DemonBrainMain:RegisterEvent("UNIT_POWER_FREQUENT")
DemonBrainMain:RegisterEvent("UNIT_AURA")
DemonBrainMain:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
DemonBrainMain:RegisterEvent("PLAYER_TARGET_CHANGED")
DemonBrainMain:RegisterEvent("PLAYER_ENTERING_WORLD")

DemonBrainMain:SetScript("OnEvent", function(self, event, unit)
    if unit and unit ~= "player" then return end
    UpdateUI()
end)

-------------------------------------------------
-- APLICAR ESTADO GUARDADO
-------------------------------------------------

if DemonBrainDB.hideMainIcon then
    DemonBrainMain:Hide()
end

function DemonBrainUI_Initialize()

    UpdateUI()
    DemonBrainMain:Show()

end

local DF = DemonFramework

DF:RegisterModule("DemonBrainUI", {

    dependencies = { "DemonBrain" },
   
    OnLoad = function(self)
        -- Nada pesado aquí
    end,

    OnEnable = function(self)

        -- Inicializar UI cuando el motor ya esté habilitado
        if DemonBrainUI_Initialize then
            DemonBrainUI_Initialize()
        end

    end,

    OnDisable = function(self)
        if DemonBrainMain then
            DemonBrainMain:Hide()
        end
    end,
})