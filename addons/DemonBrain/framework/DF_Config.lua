-- DemonFramework Config (stub)

local DF = DemonFramework

DF.Config = DF.Config or {}

function DF.Config:Get(key)
    DemonBrainDB = DemonBrainDB or {}
    return DemonBrainDB[key]
end

function DF.Config:Set(key, value)
    DemonBrainDB = DemonBrainDB or {}
    DemonBrainDB[key] = value
end