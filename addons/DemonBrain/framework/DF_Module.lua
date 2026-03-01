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

    -- Se crea una instancia interna del módulo
    local module = {
        name = name,
        state = MODULE_STATE.REGISTERED,
        enabled = false,

        -- Callbacks opcionales
        OnLoad = definition.OnLoad,
        OnEnable = definition.OnEnable,
        OnDisable = definition.OnDisable,
    }

    self.Modules[name] = module

    return module
end

-- ----------------------------------------------------------------------------
-- Cargar todos los módulos registrados
-- ----------------------------------------------------------------------------
-- Ejecuta OnLoad una sola vez por módulo.
function DF:LoadModules()

    for _, module in pairs(self.Modules) do

        if module.state == MODULE_STATE.REGISTERED then

            if type(module.OnLoad) == "function" then
                module:OnLoad()
            end

            module.state = MODULE_STATE.LOADED
        end
    end
end

-- ----------------------------------------------------------------------------
-- Habilitar un módulo específico
-- ----------------------------------------------------------------------------
function DF:EnableModule(name)

    local module = self.Modules[name]
    Assert(module, "EnableModule: Module not found: " .. name)

    -- Si ya está habilitado, no hacemos nada
    if module.state == MODULE_STATE.ENABLED then
        return
    end

    -- Si todavía no fue cargado, forzamos carga previa
    if module.state == MODULE_STATE.REGISTERED then
        self:LoadModules()
    end

    -- Ejecutar callback de activación
    if type(module.OnEnable) == "function" then
        module:OnEnable()
    end

    module.state = MODULE_STATE.ENABLED
    module.enabled = true
end

-- ----------------------------------------------------------------------------
-- Deshabilitar un módulo
-- ----------------------------------------------------------------------------
function DF:DisableModule(name)

    local module = self.Modules[name]
    Assert(module, "DisableModule: Module not found: " .. name)

    if module.state ~= MODULE_STATE.ENABLED then
        return
    end

    if type(module.OnDisable) == "function" then
        module:OnDisable()
    end

    module.state = MODULE_STATE.DISABLED
    module.enabled = false
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

    self:LoadModules()

    for name in pairs(self.Modules) do
        self:EnableModule(name)
    end
end