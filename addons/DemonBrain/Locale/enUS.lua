-- ============================================================
-- English Localization
-- ============================================================

DemonBrain_L_enUS = {

    TITLE = "DemonBrain - Advanced Settings",
    SUBTITLE = "Smart control for Demonology Warlock",

    SECTION_LANG = "Language",
    SECTION_TYRANT = "Summon Demonic Tyrant",
    SECTION_BURST = "Burst Modes",
    SECTION_UI = "Interface & Appearance",

    LANG_DESC = "Select the language used by DemonBrain.",

    TYRANT_DESC =
        "Defines the minimum number of active demons before recommending Tyrant.\n\n" ..
        "• Lower values → More frequent usage.\n" ..
        "• Higher values → Stronger damage windows.\n\n" ..
        "Recommendation: Raid 6-8 | Mythic+ 4-6",

    BURST_DESC =
        "Normal Mode:\n" ..
        "• Uses configured threshold.\n" ..
        "• Balanced rotation.\n\n" ..
        "Manual Burst:\n" ..
        "• Absolute Tyrant priority.\n" ..
        "• Ideal for Heroism or planned damage.\n\n" ..
        "Automatic Burst:\n" ..
        "• Activates automatically against elites or bosses.\n" ..
        "• Normal behavior against common enemies.",

    UI_DESC =
        "Customize the size and opacity of the suggestion icon.\n" ..
        "You can temporarily hide it using the minimap button.",

    SLIDER_DEMONS = "Required Demons:",
    SLIDER_SIZE = "Icon Size:",
    SLIDER_ALPHA = "Opacity:",

    MODE_NORMAL = "Normal Mode",
    MODE_MANUAL = "Manual Burst",
    MODE_AUTO = "Automatic Burst",

    LANGUAGE_EN = "English",
    LANGUAGE_ES = "Spanish",

    RELOAD_BUTTON = "Reload UI",

    MINIMAP_LEFT = "Left Click: Settings",
    MINIMAP_RIGHT = "Right Click: Toggle Icon",
    MINIMAP_SHIFT = "Shift + Click: Change Mode",
    MINIMAP_CURRENT = "Current Mode:",
}