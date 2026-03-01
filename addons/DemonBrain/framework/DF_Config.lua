-- ============================================================================
-- DemonFramework - Config System (Profiles v1)
-- ----------------------------------------------------------------------------
-- Sistema de perfiles tipo ElvUI con namespace por módulo
-- ============================================================================

local DF = DemonFramework

DF.Config = DF.Config or {}
local Config = DF.Config

-- ---------------------------------------------------------------------------
-- Utilidad: obtener identificador único del personaje
-- ---------------------------------------------------------------------------

local function GetCharacterKey()
    local name = UnitName("player") or "Unknown"
    local realm = GetRealmName() or "Realm"
    return name .. "-" .. realm
end

-- ---------------------------------------------------------------------------
-- Inicialización de estructura base
-- ---------------------------------------------------------------------------

function Config:Initialize()

    DemonBrainDB = DemonBrainDB or {}

    DemonBrainDB.global = DemonBrainDB.global or {}
    DemonBrainDB.profiles = DemonBrainDB.profiles or {}
    DemonBrainDB.profileKeys = DemonBrainDB.profileKeys or {}

    local charKey = GetCharacterKey()

    -- Si el personaje no tiene perfil asignado, usar Default
    if not DemonBrainDB.profileKeys[charKey] then
        DemonBrainDB.profileKeys[charKey] = "Default"
    end

    local profileName = DemonBrainDB.profileKeys[charKey]

    -- Crear perfil si no existe
    if not DemonBrainDB.profiles[profileName] then
        DemonBrainDB.profiles[profileName] = {}
    end

    self._activeProfileName = profileName
end

-- ---------------------------------------------------------------------------
-- Obtener perfil activo
-- ---------------------------------------------------------------------------

function Config:GetActiveProfile()
    return DemonBrainDB.profiles[self._activeProfileName]
end

function Config:GetActiveProfileName()
    return self._activeProfileName
end

-- ---------------------------------------------------------------------------
-- Obtener namespace de módulo dentro del perfil
-- ---------------------------------------------------------------------------

function Config:GetModuleNamespace(moduleName)

    local profile = self:GetActiveProfile()

    profile[moduleName] = profile[moduleName] or {}

    return profile[moduleName]
end