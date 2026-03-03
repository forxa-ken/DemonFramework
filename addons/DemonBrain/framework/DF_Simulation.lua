_G.DemonFramework = _G.DemonFramework or {}
local DF = _G.DemonFramework

-- ⚠️ NO sobrescribimos si ya existe
DF.Simulation = DF.Simulation or {}

local Simulation = DF.Simulation

-------------------------------------------------
-- Deep Copy
-------------------------------------------------

local function DeepCopy(original)
    local copy = {}

    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end

    return copy
end

-------------------------------------------------
-- Snapshot
-------------------------------------------------

function Simulation:CreateSnapshot(state)
    return DeepCopy(state)
end

-------------------------------------------------
-- Simulate Action
-------------------------------------------------

function DF.Simulation:SimulateAction(state, action)

    local sim = self:CreateSnapshot(state)
    if action and action.Apply then
        action:Apply(sim)
    end

    return sim
end