-- ============================================================
-- DemonBrain Decision Engine (3 Burst Modes)
-- ============================================================

DemonBrainDecision = {}

local SPELL = DemonBrainSpells

-------------------------------------------------
-- BURST TARGET CHECK (solo usado en modo auto)
-------------------------------------------------

local function IsBurstTarget()

    if not UnitExists("target") then return false end
    if not UnitCanAttack("player", "target") then return false end

    local classification = UnitClassification("target")

    if classification == "elite"
    or classification == "rareelite"
    or classification == "worldboss" then
        return true
    end

    if UnitLevel("target") == -1 then
        return true
    end

    return false
end

-------------------------------------------------
-- DECISION ENGINE
-------------------------------------------------

function DemonBrainDecision:GetBestSpell()

    local state = DemonBrainCore.BuildState()
    local threshold = DemonBrainCore.GetTyrantThreshold()
    local config = DemonBrainCore:GetConfig()

    local burstMode = config and config.burstMode or "normal"

    -------------------------------------------------
    -- 🔴 BURST MANUAL (prioridad absoluta siempre)
    -------------------------------------------------

    if burstMode == "manual" then
        if state.tyrantReady
           and state.activeDemons >= threshold then
            return SPELL.TYRANT
        end
    end

    -------------------------------------------------
    -- 🟣 BURST AUTOMÁTICO (solo elite / boss)
    -------------------------------------------------

    if burstMode == "auto" and IsBurstTarget() then
        if state.tyrantReady
           and state.activeDemons >= threshold then
            return SPELL.TYRANT
        end
    end

    -------------------------------------------------
    -- 🟢 ROTACIÓN NORMAL
    -------------------------------------------------

    if DemonBrainCore.IsDemonCoreActive()
       and state.shards <= 3 then
        return SPELL.DEMONBOLT
    end

    if burstMode == "normal" then
        if state.tyrantReady
           and state.activeDemons >= threshold
           and state.shards < 2 then
            return SPELL.TYRANT
        end
    end

    if state.dreadReady then

        local requiredShards = 2

        if state.rank == 1 then
            requiredShards = 1
        elseif state.rank >= 2 then
            requiredShards = 0
        end

        if state.shards >= requiredShards then
            return SPELL.DREAD
        end
    end

    if state.shards >= 3 then
        return SPELL.HAND
    end

    return SPELL.SHADOWBOLT
end