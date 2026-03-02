-- ============================================================================
-- DemonFramework - Config System (Profiles v1)
-- ----------------------------------------------------------------------------
-- Sistema de perfiles tipo ElvUI con namespace por módulo
-- ============================================================================
-- ---------------------------------------------------------------------------
-- Aplicar defaults recursivamente
-- ---------------------------------------------------------------------------

local function ApplyDefaults(target, defaults)

    for key, value in pairs(defaults) do

        if type(value) == "table" then

            target[key] = target[key] or {}
            ApplyDefaults(target[key], value)

        elseif target[key] == nil then
            target[key] = value
        end

    end
end




local function EnsureDatabase()

    DemonBrainDB = DemonBrainDB or {}

    DemonBrainDB.global = DemonBrainDB.global or {}
    DemonBrainDB.profiles = DemonBrainDB.profiles or {}
    DemonBrainDB.profileKeys = DemonBrainDB.profileKeys or {}

    -- Garantizar que Default exista SIEMPRE
    if not DemonBrainDB.profiles["Default"] then
        DemonBrainDB.profiles["Default"] = {}
    end

end
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

    EnsureDatabase()

    local charKey = UnitName("player") .. "-" .. GetRealmName()

    if not DemonBrainDB.profileKeys[charKey] then
        DemonBrainDB.profileKeys[charKey] = "Default"
    end

    local profileName = DemonBrainDB.profileKeys[charKey]

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

    EnsureDatabase()

    local profile = DemonBrainDB.profiles[self._activeProfileName]
    profile[moduleName] = profile[moduleName] or {}

    local namespace = profile[moduleName]

    -- Aplicar defaults si el módulo los declaró
    local module = DF.Modules[moduleName]
    if module and module.defaults then
        ApplyDefaults(namespace, module.defaults)
    end

    return namespace
end

-- ---------------------------------------------------------------------------
-- Crear perfil
-- ---------------------------------------------------------------------------

function Config:CreateProfile(name)

    EnsureDatabase()

    if not name or name == "" then return false end
    if DemonBrainDB.profiles[name] then return false end

    DemonBrainDB.profiles[name] = {}
    return true
end


-- ---------------------------------------------------------------------------
-- Eliminar perfil
-- ---------------------------------------------------------------------------

function Config:DeleteProfile(name)

    EnsureDatabase()

    if not DemonBrainDB.profiles[name] then return false end
    if name == self._activeProfileName then return false end

    DemonBrainDB.profiles[name] = nil
    return true
end

-- ---------------------------------------------------------------------------
-- Listar perfiles
-- ---------------------------------------------------------------------------

function Config:GetProfiles()
    EnsureDatabase()
    return DemonBrainDB.profiles
end

-- ---------------------------------------------------------------------------
-- Cambiar perfil activo
-- ---------------------------------------------------------------------------

function Config:SetActiveProfile(name)

    EnsureDatabase()

    if not DemonBrainDB.profiles[name] then
        return false
    end

    local charKey = UnitName("player") .. "-" .. GetRealmName()
    DemonBrainDB.profileKeys[charKey] = name
    self._activeProfileName = name

    if DemonFramework and DemonFramework.NotifyProfileChanged then
    DemonFramework:NotifyProfileChanged()
    end

    return true
end

-- ---------------------------------------------------------------------------
-- Copiar perfil
-- ---------------------------------------------------------------------------

local function DeepCopy(source)

    if type(source) ~= "table" then
        return source
    end

    local copy = {}

    for k, v in pairs(source) do
        copy[k] = DeepCopy(v)
    end

    return copy
end

function Config:CopyProfile(fromName, toName)

    EnsureDatabase()

    if not DemonBrainDB.profiles[fromName] then return false end
    if DemonBrainDB.profiles[toName] then return false end

    DemonBrainDB.profiles[toName] = DeepCopy(DemonBrainDB.profiles[fromName])
    return true
end