-------------------------------------------------
-- DemonFramework Core
-------------------------------------------------

-- Garantizar existencia global
_G.DemonFramework = _G.DemonFramework or {}

local DF = _G.DemonFramework

-- Inicialización segura
DF.Modules = DF.Modules or {}
DF.State   = DF.State   or {}
DF.Events  = DF.Events  or {}
DF.Config  = DF.Config  or {}
DF.Logger  = DF.Logger  or {}


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

-- ---------------------------------------------------------------------------
-- Notificación de cambio de perfil
-- ---------------------------------------------------------------------------
function DF:NotifyProfileChanged()

    -- Notificar módulos clásicos
    for _, module in pairs(self.Modules) do
        if type(module.OnProfileChanged) == "function" then
            module:OnProfileChanged()
        end
    end

    -- Publicar evento global
    if self.Events then
        self.Events:Publish("PROFILE_CHANGED", {
            profile = self.Config._activeProfileName
        })
    end
end
