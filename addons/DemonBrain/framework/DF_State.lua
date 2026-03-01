-- DemonFramework State Container

local DF = DemonFramework

DF.State = DF.State or {}

-- Internal runtime state tracking
DF.State.modulesLoaded = false
DF.State.initialized = false