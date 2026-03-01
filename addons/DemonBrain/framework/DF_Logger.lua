-- ============================================================================
-- DemonFramework - Core Logger
-- ----------------------------------------------------------------------------
-- Servicio permanente del framework.
-- Proporciona:
--   • Niveles formales (DEBUG, INFO, WARN, ERROR)
--   • Buffer circular interno
--   • Filtrado por nivel
--   • Contexto por módulo
--
-- No depende de APIs protegidas.
-- Impacto mínimo en rendimiento.
-- ============================================================================

local DF = DemonFramework

DF.Logger = DF.Logger or {}
local Logger = DF.Logger

-- ---------------------------------------------------------------------------
-- Niveles formales (numéricos para comparación eficiente)
-- ---------------------------------------------------------------------------

local LEVELS = {
    DEBUG = 1,
    INFO  = 2,
    WARN  = 3,
    ERROR = 4,
}

Logger._levels = LEVELS
Logger._currentLevel = LEVELS.INFO
Logger._buffer = {}
Logger._maxEntries = 500

-- ---------------------------------------------------------------------------
-- Utilidad interna: timestamp
-- ---------------------------------------------------------------------------

local function GetTimestamp()
    return GetTime()
end

-- ---------------------------------------------------------------------------
-- Buffer circular
-- ---------------------------------------------------------------------------

local function AddToBuffer(entry)

    if #Logger._buffer >= Logger._maxEntries then
        table.remove(Logger._buffer, 1)
    end

    table.insert(Logger._buffer, entry)
end

-- ---------------------------------------------------------------------------
-- Escritura centralizada
-- ---------------------------------------------------------------------------

local function Write(levelName, levelValue, moduleName, message)

    if levelValue < Logger._currentLevel then
        return
    end

    local entry = {
        timestamp  = GetTimestamp(),
        level      = levelName,
        levelValue = levelValue,
        module     = moduleName or "SYSTEM",
        message    = tostring(message),
    }

    AddToBuffer(entry)

    -- Salida controlada en consola
    print(string.format(
        "|cff8888ff[DF]|r [%s] [%s] %s",
        levelName,
        entry.module,
        entry.message
    ))
end

-- ---------------------------------------------------------------------------
-- API Pública
-- ---------------------------------------------------------------------------

function Logger:SetLevel(levelName)
    local level = LEVELS[levelName]
    if level then
        self._currentLevel = level
    end
end

function Logger:SetMaxEntries(max)
    if type(max) == "number" and max > 10 then
        self._maxEntries = max
    end
end

function Logger:GetLogs()
    return self._buffer
end

function Logger:Clear()
    self._buffer = {}
end

function Logger:Debug(message, module)
    Write("DEBUG", LEVELS.DEBUG, module, message)
end

function Logger:Info(message, module)
    Write("INFO", LEVELS.INFO, module, message)
end

function Logger:Warn(message, module)
    Write("WARN", LEVELS.WARN, module, message)
end

function Logger:Error(message, module)
    Write("ERROR", LEVELS.ERROR, module, message)
end