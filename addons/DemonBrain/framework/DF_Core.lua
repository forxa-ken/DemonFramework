-- ============================================================================
-- DemonFramework - Core Bootstrap
-- ============================================================================

_G.DemonFramework = _G.DemonFramework or {}
local DF = _G.DemonFramework

-- Contenedores base únicos
DF.Modules = DF.Modules or {}
DF.Events  = DF.Events  or {}
DF.State   = DF.State   or {}

-- ----------------------------------------------------------------------------
-- Inicialización controlada
-- ----------------------------------------------------------------------------
function DF:Initialize()

    if DF.State.initialized then
        return
    end

    DF.State.initialized = true

    -- Inicializar sistema de configuración
    if DF.Config and DF.Config.Initialize then
        DF.Config:Initialize()
    end

    if self.InitializeModules then
        self:InitializeModules()
    end
end