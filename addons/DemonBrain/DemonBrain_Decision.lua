-- ============================================================
-- DemonBrain Decision Engine (Jerárquico Estable)
-- ============================================================

DemonBrainDecision = {}

local SPELL = DemonBrainSpells
local ACTIONS = DemonBrainActions

function DemonBrainDecision:GetBestSpell()

    local state = DemonBrainCore.BuildState()
    local threshold = DemonBrainCore.GetTyrantThreshold()
    local config = DemonBrainCore:GetConfig()
    local burstActive = config and config.autoBurst

    -------------------------------------------------
    -- 🔥 BURST MODE (Tyrant prioridad absoluta)
    -------------------------------------------------

    if burstActive then
        if state.tyrantReady
           and state.activeDemons >= threshold then
            return SPELL.TYRANT
        end
    end

    -------------------------------------------------
    -- 1️⃣ Demonbolt
    -------------------------------------------------

    if DemonBrainCore.IsDemonCoreActive()
       and state.shards <= 3 then
        return SPELL.DEMONBOLT
    end

    -------------------------------------------------
    -- 2️⃣ Tyrant (modo normal)
    -------------------------------------------------

    if not burstActive then
        if state.tyrantReady
           and state.activeDemons >= threshold
           and not state.dreadReady then
            return SPELL.TYRANT
        end
    end

    -------------------------------------------------
    -- 3️⃣ Dread
    -------------------------------------------------

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

    -------------------------------------------------
    -- 4️⃣ Hand
    -------------------------------------------------

    if state.shards >= 3 then
        return SPELL.HAND
    end

    -------------------------------------------------
    -- 5️⃣ Filler
    -------------------------------------------------

    return SPELL.SHADOWBOLT
end