-- ============================================================
-- DemonBrain Actions (Simulación robusta)
-- ============================================================

DemonBrainActions = {}

-------------------------------------------------
-- DREADSTALKERS
-------------------------------------------------

DemonBrainActions.Dread = {}

function DemonBrainActions.Dread:Apply(state)

    state.activeDemons = state.activeDemons or 0
    state.shards = state.shards or 0
    state.rank = state.rank or 0

    local requiredShards = 2

    if state.rank == 1 then
        requiredShards = 1
    elseif state.rank >= 2 then
        requiredShards = 0
    end

    -- ❌ Si no está listo → invalidar acción
    if not state.dreadReady then
        state.invalid = true
        return
    end

    -- ❌ Si no hay shards suficientes → invalidar
    if state.shards < requiredShards then
        state.invalid = true
        return
    end

    state.shards = state.shards - requiredShards
    state.activeDemons = state.activeDemons + 2
    state.dreadReady = false
end

-------------------------------------------------
-- HAND OF GUL'DAN
-------------------------------------------------

DemonBrainActions.Hand = {}

function DemonBrainActions.Hand:Apply(state)

    state.activeDemons = state.activeDemons or 0
    state.shards = state.shards or 0

    if state.shards < 3 then
        state.invalid = true
        return
    end

    state.shards = state.shards - 3
    state.activeDemons = state.activeDemons + 3
end

-------------------------------------------------
-- TYRANT
-------------------------------------------------

DemonBrainActions.Tyrant = {}

function DemonBrainActions.Tyrant:Apply(state)

    if not state.tyrantReady then
        state.invalid = true
        return
    end

    state.tyrantReady = false
end