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


local DF = DemonFramework

DF.Config = DF.Config or {}
local Config = DF.Config
-- Base de datos inyectada por el addon consumidor
DF._database = DF._database or nil

function DF:AttachDatabase(db)

    assert(type(db) == "table", "Database must be table")

    self._database = db
end

local function EnsureDatabase()

    local db = DF._database
    if not db then
        error("No database attached to DemonFramework")
    end

    db.global = db.global or {}
    db.profiles = db.profiles or {}
    db.profileKeys = db.profileKeys or {}

    if not db.profiles["Default"] then
        db.profiles["Default"] = {}
    end
end
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

    if not DF._database.profileKeys[charKey] then
        DF._database.profileKeys[charKey] = "Default"
    end

    local profileName = DF._database.profileKeys[charKey]

    if not DF._database.profiles[profileName] then
        DF._database.profiles[profileName] = {}
    end

    self._activeProfileName = profileName
end

-- ---------------------------------------------------------------------------
-- Obtener perfil activo
-- ---------------------------------------------------------------------------

function Config:GetActiveProfile()
    return DF._database.profiles[self._activeProfileName]
end

function Config:GetActiveProfileName()
    return self._activeProfileName
end

-- ---------------------------------------------------------------------------
-- Obtener namespace de módulo dentro del perfil
-- ---------------------------------------------------------------------------

function Config:GetModuleNamespace(moduleName)

    EnsureDatabase()

    local profile = DF._database.profiles[self._activeProfileName]
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
    if DF._database.profiles[name] then return false end

    DF._database.profiles[name] = {}
    return true
end


-- ---------------------------------------------------------------------------
-- Eliminar perfil
-- ---------------------------------------------------------------------------

function Config:DeleteProfile(name)

    EnsureDatabase()

    if not DF._database.profiles[name] then return false end
    if name == self._activeProfileName then return false end

    DF._database.profiles[name] = nil
    return true
end

-- ---------------------------------------------------------------------------
-- Listar perfiles
-- ---------------------------------------------------------------------------

function Config:GetProfiles()
    EnsureDatabase()
    return DF._database.profiles
end

-- ---------------------------------------------------------------------------
-- Cambiar perfil activo
-- ---------------------------------------------------------------------------

function Config:SetActiveProfile(name)

    EnsureDatabase()

    if not DF._database.profiles[name] then
        return false
    end

    local charKey = UnitName("player") .. "-" .. GetRealmName()
    DF._database.profileKeys[charKey] = name
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

    if not DF._database.profiles[fromName] then return false end
    if DF._database.profiles[toName] then return false end

    DF._database.profiles[toName] = DeepCopy(DF._database.profiles[fromName])
    return true
end