-- ============================================================================
-- DemonFramework - Module System v1
-- ----------------------------------------------------------------------------
-- Responsable de:
--   • Registro de módulos
--   • Control de ciclo de vida
--   • Estados formales de módulo
--   • Inicialización ordenada básica
--
-- No incluye todavía:
--   • Dependencias entre módulos
--   • Prioridades
--   • Lazy loading
--
-- Diseño:
--   Sistema simple pero formal, preparado para escalar.
-- ============================================================================

local DF = DemonFramework

-- Tabla global de módulos registrados
DF.Modules = DF.Modules or {}

-- Estados formales del ciclo de vida de un módulo
-- Se usan valores numéricos para eficiencia y comparación rápida.
local MODULE_STATE = {
    REGISTERED = 1,  -- Registrado pero no cargado
    LOADED     = 2,  -- OnLoad ejecutado
    ENABLED    = 3,  -- OnEnable ejecutado
    DISABLED   = 4,  -- Desactivado manualmente
}

local function Transition(module, expectedState, newState)

    if module.state ~= expectedState then
        return false
    end

    module.state = newState
    return true
end

-- ----------------------------------------------------------------------------
-- Función interna de validación
-- ----------------------------------------------------------------------------
-- Evita estados inconsistentes y errores silenciosos.
local function Assert(condition, message)
    if not condition then
        error("[DemonFramework] " .. message)
    end
end

-- ----------------------------------------------------------------------------
-- Registro de módulo
-- ----------------------------------------------------------------------------
-- name        : string único
-- definition  : tabla con posibles callbacks:
--                OnLoad(self)
--                OnEnable(self)
--                OnDisable(self)
--
-- Devuelve la instancia interna del módulo.
function DF:RegisterModule(name, definition)

    Assert(type(name) == "string", "Module name must be string")
    Assert(type(definition) == "table", "Module definition must be table")
    Assert(not self.Modules[name], "Module already registered: " .. name)

    local module = {
    name = name,
    state = MODULE_STATE.REGISTERED,
    enabled = false,
    dependencies = definition.dependencies or {},

    OnLoad = definition.OnLoad,
    OnEnable = definition.OnEnable,
    OnDisable = definition.OnDisable,
  }

    -- Copiar todos los campos definidos por el módulo
    for key, value in pairs(definition) do
        module[key] = value
    end

    -- Método de log contextual por módulo
    module.Log = function(self, message, level)

        level = level or "INFO"
        local methodName = level:sub(1,1):upper() .. level:sub(2):lower()

        if DF.Logger and DF.Logger[methodName] then
            DF.Logger[methodName](DF.Logger, message, self.name)
        end
    end

    self.Modules[name] = module

    return module
end

-- ----------------------------------------------------------------------------
-- Cargar todos los módulos registrados
-- ----------------------------------------------------------------------------
-- Ejecuta OnLoad una sola vez por módulo.
function DF:LoadModule(name)

    local module = self.Modules[name]
    if not module then return end

    if not Transition(module, MODULE_STATE.REGISTERED, MODULE_STATE.LOADED) then
        return
    end

    if type(module.OnLoad) == "function" then
        module:OnLoad()
    end
end

-- ----------------------------------------------------------------------------
-- Habilitar un módulo específico
-- ----------------------------------------------------------------------------
function DF:EnableModule(name)

    local module = self.Modules[name]
    if not module then return end

    -- Permitir desde LOADED o DISABLED
    if module.state ~= MODULE_STATE.LOADED
    and module.state ~= MODULE_STATE.DISABLED then
        return
    end

    module.enabled = true
    module.state = MODULE_STATE.ENABLED

    if type(module.OnEnable) == "function" then
        module:OnEnable()
    end
end
-- ----------------------------------------------------------------------------
-- Deshabilitar un módulo
-- ----------------------------------------------------------------------------
function DF:DisableModule(name)

    local module = self.Modules[name]
    if not module then return end

    if not Transition(module, MODULE_STATE.ENABLED, MODULE_STATE.DISABLED) then
        return
    end

    module.enabled = false

    if type(module.OnDisable) == "function" then
        module:OnDisable()
    end

    if self.Events then
        self.Events:UnsubscribeOwner(module)
    end
end

-- ----------------------------------------------------------------------------
-- Inicialización general del sistema de módulos
-- ----------------------------------------------------------------------------
-- Flujo:
--   1. Cargar todos (OnLoad)
--   2. Habilitar todos (OnEnable)
--
-- Se llama desde DF_Core cuando el addon termina de cargar.
function DF:InitializeModules()

    local orderedModules = self:ResolveModuleOrder()

    for _, module in ipairs(orderedModules) do
        self:LoadModule(module.name)
    end

    for _, module in ipairs(orderedModules) do
        self:EnableModule(module.name)
    end
end


function DF:ResolveModuleOrder()

    local ordered = {}
    local visited = {}
    local visiting = {}

    local function Visit(module)

        if visiting[module.name] then
            error("Circular dependency detected at module: " .. module.name)
        end

        if not visited[module.name] then

            visiting[module.name] = true

            for _, depName in ipairs(module.dependencies) do

                local dep = self.Modules[depName]

                if not dep then
                    error("Missing dependency: " .. depName .. " for module: " .. module.name)
                end

                Visit(dep)
            end

            visiting[module.name] = nil
            visited[module.name] = true
            table.insert(ordered, module)
        end
    end

    for _, module in pairs(self.Modules) do
        Visit(module)
    end

    return ordered
end