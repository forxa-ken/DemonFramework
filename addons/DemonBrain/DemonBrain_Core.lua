-- ============================================================
-- DemonBrain Core (Retail Safe FINAL)
-- Sin cooldown API
-- Sin IsUsableSpell
-- Sin comparaciones protegidas
-- ============================================================

-------------------------------------------------
-- SPELL IDS
-------------------------------------------------

local SPELL_SHADOWBOLT = 686
local SPELL_DEMONBOLT  = 264178
local SPELL_DREAD      = 104316
local SPELL_HAND       = 105174
local SPELL_TYRANT     = 265187

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local CONFIG = {
    tyrantDemonThreshold = 6,
    autoBurst = false,
}

-------------------------------------------------
-- ESTADO
-------------------------------------------------

local lastDreadCast  = 0
local lastTyrantCast = 0

local demonEvents = {}

local DREAD_CD   = 20
local TYRANT_CD  = 90   -- Solo base (no dependemos del juego)
local DEMON_DURATION = 12

-------------------------------------------------
-- UTILIDADES
-------------------------------------------------

local function GetShards()
    return UnitPower("player", Enum.PowerType.SoulShards) or 0
end

local function TimeSince(t)
    return GetTime() - t
end

local function DreadReady()
    return TimeSince(lastDreadCast) >= DREAD_CD
end

local function TyrantReady()
    return TimeSince(lastTyrantCast) >= TYRANT_CD
end

-------------------------------------------------
-- NÚCLEO DEMONÍACO (método estable que ya funcionó)
-------------------------------------------------

local function DemonCoreActive()
    local info = C_Spell.GetSpellInfo(SPELL_DEMONBOLT)
    if not info then return false end
    return info.castTime == 0
end

-------------------------------------------------
-- TRACKING DEMONIOS
-------------------------------------------------

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
-- MOTOR DE PRIORIDAD
-------------------------------------------------

local function GetRecommendedSpell()

    local shards = GetShards()
    local coreActive = DemonCoreActive()
    local activeDemons = CleanupDemons()

    -- 1️⃣ Evitar sobrecap
    if shards >= 4 then
        return SPELL_HAND
    end

    -- 2️⃣ Núcleo Demoníaco
    if coreActive and shards <= 3 then
        return SPELL_DEMONBOLT
    end

    -- 3️⃣ Preparar Tirano
    if TyrantReady() then

        if activeDemons < CONFIG.tyrantDemonThreshold then

            if DreadReady() and shards >= 2 then
                return SPELL_DREAD
            end

            if shards >= 3 then
                return SPELL_HAND
            end

        else
            return SPELL_TYRANT
        end
    end

    -- 4️⃣ Terrace normal
    if DreadReady() and shards >= 2 then
        return SPELL_DREAD
    end

    -- 5️⃣ Filler
    return SPELL_SHADOWBOLT
end

-------------------------------------------------
-- EVENTOS
-------------------------------------------------

local core = CreateFrame("Frame")
core:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

core:SetScript("OnEvent", function(_, _, unit, _, spellID)

    if unit ~= "player" then return end

    if spellID == SPELL_DREAD then
        lastDreadCast = GetTime()
        AddDemons(2)

    elseif spellID == SPELL_HAND then
        AddDemons(3)

    elseif spellID == SPELL_TYRANT then
        lastTyrantCast = GetTime()
    end
end)

-------------------------------------------------
-- API
-------------------------------------------------

DemonBrainCore = {}

function DemonBrainCore.GetNextSpell()
    return GetRecommendedSpell()
end

function DemonBrainCore.GetActiveDemons()
    return CleanupDemons()
end

function DemonBrainCore.SetBurstMode(value)
    CONFIG.autoBurst = value
end

function DemonBrainCore.SetTyrantThreshold(value)
    CONFIG.tyrantDemonThreshold = value
end
