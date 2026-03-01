-- ============================================================================
-- DemonFramework - Core Bootstrap
-- ----------------------------------------------------------------------------
-- Responsable de:
--   • Crear namespace global DemonFramework
--   • Controlar inicialización única
--   • Lanzar el sistema de módulos
-- ============================================================================

_G.DemonFramework = _G.DemonFramework or {}
local DF = _G.DemonFramework

-- Contenedores base (no se recrean si ya existen)
DF.Modules = DF.Modules or {}
DF.Events  = DF.Events  or {}
DF.State   = DF.State   or {}

-- ----------------------------------------------------------------------------
-- Inicialización controlada del framework
-- ----------------------------------------------------------------------------
function DF:Initialize()

    -- Evita doble inicialización
    if DF.State.initialized then
        return
    end

    DF.State.initialized = true

    -- Inicializa sistema de módulos
    self:InitializeModules()
end

-- ----------------------------------------------------------------------------
-- Hook al evento ADDON_LOADED
-- ----------------------------------------------------------------------------
-- Solo se inicializa cuando DemonBrain termina de cargar.
local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "DemonBrain" then
        DF:Initialize()
    end
end)