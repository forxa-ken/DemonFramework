-- ============================================================
-- DemonBrain Decision Engine (Jerárquico Estable)
-- ============================================================

DemonBrainDecision = {}

local SPELL = DemonBrainSpells
local ACTIONS = DemonBrainActions

function DemonBrainDecision:GetBestSpell()

    local state = DemonBrainCore.BuildState()
    local threshold = DemonBrainCore.GetTyrantThreshold()
    print("---- DEMONBRAIN DEBUG ----")
    print("DreadReady:", state.dreadReady)
    print("TyrantReady:", state.tyrantReady)
    print("ActiveDemons:", state.activeDemons)
    print("Threshold:", threshold)
    print("Shards:", state.shards)
    print("DemonCoreActive:", DemonBrainCore.IsDemonCoreActive())
    -------------------------------------------------
    -- 1️⃣ Demonbolt (Núcleo Demoníaco)
    -------------------------------------------------

    if DemonBrainCore.IsDemonCoreActive()
       and state.shards <= 3 then
        return SPELL.DEMONBOLT
    end

    -------------------------------------------------
    -- 2️⃣ Tyrant (REGLA ABSOLUTA)
    -------------------------------------------------

    if state.tyrantReady
        and state.activeDemons >= threshold
        and not state.dreadReady then
            return SPELL.TYRANT
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