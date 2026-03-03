-- ============================================================
-- DemonBrain Locale Loader (Stable & Dynamic)
-- ============================================================

local function ApplyLocale()

    if not DemonBrainDB then
        DemonBrain_L = DemonBrain_L_enUS or {}
        return
    end

    local selected = DemonBrainDB.language

    if not selected then
        -- Idioma por defecto
        selected = "enUS"

        -- Guardarlo para que no vuelva a ser nil
        DemonBrainDB.language = selected
    end

    if selected == "esES" and type(DemonBrain_L_esES) == "table" then
        DemonBrain_L = DemonBrain_L_esES
    elseif selected == "enUS" and type(DemonBrain_L_enUS) == "table" then
        DemonBrain_L = DemonBrain_L_enUS
    else
        DemonBrain_L = DemonBrain_L_enUS or {}
    end
end
-- Aplicar inmediatamente si DB ya existe
if DemonBrainDB then
    ApplyLocale()
end
function DemonBrain_SetLanguage(lang)
    if not DemonBrainDB then return end
    DemonBrainDB.language = lang
    ApplyLocale()
end

-- Aplicar DESPUÉS de login (DB ya inicializada)
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    ApplyLocale()
end)