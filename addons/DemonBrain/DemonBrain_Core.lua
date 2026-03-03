-- ============================================================
-- DemonBrain Core
-- Midnight Stable Manual Version (Fully Documented)
-- ============================================================
--
-- Este archivo contiene:
-- ✔ Sistema manual de cooldowns
-- ✔ Tracking manual de demonios activos
-- ✔ Acceso al sistema de configuración del Framework
-- ✔ Construcción del estado que usa DemonBrain_Decision.lua
--
-- NO usa API moderna de cooldown por problemas de taint en Midnight.
-- Todos los CD son manuales.
--
-- Depende de:
--   - DemonBrain_Decision.lua
--   - DemonFramework (Config + Database)
--
-- ============================================================

DemonBrain = DemonBrain or {}
DemonBrainCore = DemonBrainCore or {}

-------------------------------------------------
-- SPELL IDS (Retail Midnight)
-------------------------------------------------
-- IDs oficiales de hechizos de Brujo Demonología
--
-- 686      = Shadow Bolt (Descarga de las Sombras)
-- 264178   = Demonbolt (Descarga demoníaca)
-- 104316   = Call Dreadstalkers (Llamar a terracechadores)
-- 105174   = Hand of Gul'dan (Mano de Gul'dan)
-- 265187   = Summon Demonic Tyrant (Invocar Tirano demoníaco)

DemonBrainSpells = {
    SHADOWBOLT = 686,
    DEMONBOLT  = 264178,
    DREAD      = 104316,
    HAND       = 105174,
    TYRANT     = 265187,
}

local SPELL = DemonBrainSpells

-------------------------------------------------
-- TALENT TRACKING
-------------------------------------------------
-- TALENT: Llamada demoníaca (Demonic Calling)
-- SpellID: 1276947
--
-- IMPORTANTE:
-- Este talento NO modifica el cooldown.
-- Solo modifica coste y cast time.
--
-- Se mantiene para lógica futura (coste dinámico).

local TALENT_DEMONIC_CALLING = 1276947

DemonBrainTalent = {
    demonicCallingRank = 0,
}

-- API utilizada:
-- C_SpellBook.IsSpellKnown(spellID)
-- API Retail moderna para verificar talentos conocidos.

local function UpdateTalentState()

    if C_SpellBook and C_SpellBook.IsSpellKnown then
        if C_SpellBook.IsSpellKnown(TALENT_DEMONIC_CALLING) then
            DemonBrainTalent.demonicCallingRank = 1
        else
            DemonBrainTalent.demonicCallingRank = 0
        end
    else
        DemonBrainTalent.demonicCallingRank = 0
    end
end

-------------------------------------------------
-- COOLDOWNS MANUALES (NO API)
-------------------------------------------------
-- Se evita C_Spell.GetSpellCooldown por:
--  - taint
--  - valores "secret number"
--  - comportamiento inconsistente en Midnight
--
-- Sistema manual basado en GetTime().

local lastDreadCast  = 0   -- Último casteo de Call Dreadstalkers
local lastTyrantCast = 0   -- Último casteo de Summon Demonic Tyrant

local DREAD_CD_BASE  = 20  -- CD real: 20 segundos
local TYRANT_CD_BASE = 60  -- CD real: 60 segundos

-- API usada:
-- GetTime() → tiempo en segundos desde inicio de sesión

local function GetDreadCooldown()
    return DREAD_CD_BASE
end

local function DreadReady()
    return (GetTime() - lastDreadCast) >= GetDreadCooldown()
end

local function TyrantReady()
    return (GetTime() - lastTyrantCast) >= TYRANT_CD_BASE
end

-------------------------------------------------
-- UTILIDADES
-------------------------------------------------

-- API utilizada:
-- UnitPower("player", Enum.PowerType.SoulShards)
--
-- Devuelve fragmentos de alma actuales.

local function GetShards()
    return UnitPower("player", Enum.PowerType.SoulShards) or 0
end

-------------------------------------------------
-- TRACKING MANUAL DE DEMONIOS
-------------------------------------------------
-- No se usa API de pets.
-- Se rastrean invocaciones manualmente.
--
-- Cada invocación guarda:
--   - tiempo de spawn
--   - cantidad de demonios
--
-- Duración asumida: 12s (Dreadstalkers / Imps base)

local DEMON_DURATION = 12
local demonEvents = {}

local function CleanupDemons()

    local now = GetTime()
    local active = 0
    local newTable = {}

    for _, data in ipairs(demonEvents) do
        if (now - data.time) <= DEMON_DURATION then
            table.insert(newTable, data)
            active = active + data.count
        end
    end

    demonEvents = newTable
    return active
end

local function AddDemons(count)
    table.insert(demonEvents, {
        time = GetTime(),
        count = count
    })
end

-------------------------------------------------
-- BUILD STATE (USADO POR DECISION ENGINE)
-------------------------------------------------
-- Esta función es llamada por:
-- DemonBrainDecision:GetBestSpell()

function DemonBrainCore.BuildState()

    return {
        shards = GetShards(),
        activeDemons = CleanupDemons(),
        dreadReady = DreadReady(),
        tyrantReady = TyrantReady(),
        rank = DemonBrainTalent.demonicCallingRank,
    }
end

-------------------------------------------------
-- CONFIG ACCESS (USA DEMONFRAMEWORK)
-------------------------------------------------
-- Llama a:
-- DemonFramework.Config:GetModuleNamespace("DemonBrain")
--
-- Archivo externo:
-- framework/DF_Config.lua

function DemonBrainCore:GetConfig()
    if not DemonFramework or not DemonFramework.Config then
        return nil
    end

    return DemonFramework.Config:GetModuleNamespace("DemonBrain")
end

-------------------------------------------------
-- THRESHOLD (SLIDER UI)
-------------------------------------------------
-- El slider define:
-- namespace.tyrantDemonThreshold
--
-- Usado por:
-- DemonBrain_Decision.lua

function DemonBrainCore.GetTyrantThreshold()

    local namespace = DemonBrainCore:GetConfig()

    if not namespace then
        return 6
    end

    return namespace.tyrantDemonThreshold or 6
end

-------------------------------------------------
-- API EXPUESTA AL ADDON
-------------------------------------------------

-- Llama a DemonBrainDecision (archivo externo)

function DemonBrainCore.GetNextSpell()
    return DemonBrainDecision:GetBestSpell()
end

function DemonBrainCore.GetActiveDemons()
    return CleanupDemons()
end

-------------------------------------------------
-- EVENTOS
-------------------------------------------------
-- API utilizada:
-- CreateFrame("Frame")
-- RegisterEvent(...)
-- SetScript("OnEvent", ...)
-- UNIT_SPELLCAST_SUCCEEDED

local coreFrame

function DemonBrain:Initialize()

    if coreFrame then return end

    coreFrame = CreateFrame("Frame")

    UpdateTalentState()

    coreFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    coreFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    coreFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")

    coreFrame:SetScript("OnEvent", function(_, event, ...)

        if event == "PLAYER_ENTERING_WORLD"
        or event == "TRAIT_CONFIG_UPDATED" then
            UpdateTalentState()
        end

        if event == "UNIT_SPELLCAST_SUCCEEDED" then

            local unitTarget, _, spellID = ...

            if unitTarget == "player" and spellID then

                if spellID == SPELL.DREAD then
                    lastDreadCast = GetTime()
                    AddDemons(2)

                elseif spellID == SPELL.HAND then
                    AddDemons(3)

                elseif spellID == SPELL.TYRANT then
                    lastTyrantCast = GetTime()
                end
                if DemonBrainMain and DemonBrainMain:IsShown() then
                    C_Timer.After(0, function()
                        if DemonBrainMain and DemonBrainMain:GetScript("OnEvent") then
                            DemonBrainMain:GetScript("OnEvent")(DemonBrainMain, "UNIT_SPELLCAST_SUCCEEDED", "player")
                        end
                    end)
                end
            end
        end
    end)
end

-------------------------------------------------
-- DEMONIC CORE PROC CHECK
-------------------------------------------------
-- Verifica si Demonbolt es instantáneo.
-- API usada:
-- C_Spell.GetSpellInfo(spellID)

function DemonBrainCore.IsDemonCoreActive()

    if not C_Spell or not C_Spell.GetSpellInfo then
        return false
    end

    local spellInfo = C_Spell.GetSpellInfo(SPELL.DEMONBOLT)

    if not spellInfo then
        return false
    end

    return spellInfo.castTime == 0
end

-------------------------------------------------
-- AUTO INITIALIZATION
-------------------------------------------------
-- Se ejecuta en PLAYER_LOGIN
-- Adjunta DB al Framework
-- Inicializa perfiles
-- Inicializa Core

local initFrame = CreateFrame("Frame")

initFrame:RegisterEvent("PLAYER_LOGIN")

initFrame:SetScript("OnEvent", function()

    if not DemonBrainDB then
        DemonBrainDB = {}
    end
    DemonBrainDB.burstMode = DemonBrainDB.burstMode or "normal"
    if DemonFramework and DemonFramework.AttachDatabase then
        DemonFramework:AttachDatabase(DemonBrainDB)
    end

    if DemonFramework and DemonFramework.Config then
        DemonFramework.Config:Initialize()
    end

    if DemonBrain and DemonBrain.Initialize then
        DemonBrain:Initialize()
    end
end)