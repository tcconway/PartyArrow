-- Localization.frFR.lua
-- Changes: split out group and raid text.
-- Date: 2026-02-16

if GetLocale and GetLocale() == "frFR" then
    PartyArrowLocals = {
        ["OPTIONS_TITLE"] = "PartyArrow",
        ["OPTIONS_SUBTITLE"] = "Copyright (c) 2026 TC Conway. Sous licence GPLv3.",
        ["OPTIONS_CREDITS"] = "|cffffd200Auteur:|r TCConway\n\n|cffffd200Remerciements:|r\nLa communaute des addons WoW et Blizzard\n\n|cffffd200Localisation:|r\nLira",
        ["OPTIONS_SETTINGS_HEADER"] = "Réglages",
        ["OPTIONS_SHOW_ARROWS"] = "Afficher les fleches en groupe",
        ["OPTIONS_LOCK_FRAME"] = "Verrouiller le cadre des fleches",
        ["OPTIONS_RESET_POSITION"] = "Reinitialiser la position",
        ["HELP_HEADER"] = "commandes:",
        ["HELP_SHOW"] = "/pa show - afficher les fleches",
        ["HELP_HIDE"] = "/pa hide - masquer les fleches",
        ["HELP_LOCK"] = "/pa lock - verrouiller le deplacement",
        ["HELP_UNLOCK"] = "/pa unlock - deverrouiller le deplacement",
        ["HELP_RESET"] = "/pa reset - reinitialiser la position",
        ["HELP_DEBUG"] = "/pa debug - afficher les infos de position et de groupe",
        ["RESET_DONE"] = "reinitialisé.",
        ["ARROWS_SHOWN"] = "fleches affichees, en groupe.",
        ["ARROWS_HIDDEN"] = "fleches masquees.",
        ["ARROWS_LOCKED"] = "fleches verrouillees.",
        ["ARROWS_UNLOCKED"] = "fleches deverrouillees.",
        ["LOCK_NEEDS_PARTY"] = "rejoignez un groupe pour verrouiller ou deverrouiller les fleches.",
        ["UNKNOWN_ZONE"] = "Zone inconnue",
        ["STATUS_ON"] = "Marche.",
        ["DEBUG_NO_PLAYER_POS"] = "aucune position du joueur ici (instance ?).",
        ["DEBUG_MAP"] = "carte=%s (%s)",
        ["DEBUG_POSITION"] = "position=%.1f, %.1f (instance %s)",
        ["DEBUG_IN_GROUP"] = "Groupe=%s",
        ["DEBUG_IN_RAID"] = "Raid=%s",
    }
end
