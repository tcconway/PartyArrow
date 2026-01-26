-- Localization.frFR.lua

if GetLocale and GetLocale() == "frFR" then
    PartyArrowLocals = {
        ["OPTIONS_TITLE"] = "PartyArrow",
        ["OPTIONS_SUBTITLE"] = "Copyright (c) 2026 TC Conway. Tous droits réservés.",
        ["OPTIONS_DETAILS"] =   "|cffffd200Auteur:|r TCConway\n\n" ..
                                "|cffffd200Contribuiteurs:|r\n" ..
                                "- Jayama (PlayerArrow AddOn, qui a inspiré)\n" ..
                                "- Lira (Localisation)\n\n" ..
                                "|cffffd200Remerciements:|r\nLa communauté des addons WoW",
        ["OPTIONS_SETTINGS_HEADER"] = "Réglages",
        ["OPTIONS_SHOW_ARROWS"] = "Afficher les fleches",
        ["OPTIONS_VISIBILITY_LABEL"] = "Visibilite du cadre de fleches",
        ["OPTIONS_VISIBILITY_ALWAYS"] = "Toujours afficher",
        ["OPTIONS_VISIBILITY_GROUP"] = "Afficher seulement en groupe",
        ["OPTIONS_VISIBILITY_HIDDEN"] = "Masquer",
        ["OPTIONS_LOCK_FRAME"] = "Verrouiller le cadre des fleches",
        ["OPTIONS_RESET_POSITION"] = "Reinitialiser la position",
        ["HELP_HEADER"] = "commandes:",
        ["HELP_SHOW"] = "/pa show - afficher les fleches",
        ["HELP_HIDE"] = "/pa hide - masquer les fleches",
        ["HELP_INGROUP"] = "/pa ingroup - afficher les fleches seulement en groupe",
        ["HELP_LOCK"] = "/pa lock - verrouiller le deplacement",
        ["HELP_UNLOCK"] = "/pa unlock - deverrouiller le deplacement",
        ["HELP_RESET"] = "/pa reset - reinitialiser la position",
        ["HELP_DEBUG"] = "/pa debug - afficher les infos de debug",
        ["RESET_DONE"] = "reinitialisé.",
        ["ARROWS_SHOWN"] = "fleches affichees.",
        ["ARROWS_HIDDEN"] = "fleches masquees.",
        ["ARROWS_INGROUP"] = "fleches affichees seulement en groupe.",
        ["ARROWS_LOCKED"] = "fleches verrouillees.",
        ["ARROWS_UNLOCKED"] = "fleches deverrouillees.",
        ["STATUS_ON"] = "Marche.",
        ["DEBUG_NO_MAPID"] = "aucun mapID pour le joueur.",
        ["DEBUG_NO_PLAYER_POS"] = "aucune position du joueur sur la carte.",
        ["DEBUG_MAPID_POS"] = "mapID=%s (%s) pos=%.4f,%.4f",
        ["DEBUG_GROUP_RAID"] = "enGroupe=%s enRaid=%s",
        ["DEBUG_WORLD_SIZE"] = "tailleMonde=%.2f x %.2f",
        ["DEBUG_WORLD_SIZE_UNAVAILABLE"] = "tailleMonde indisponible.",
        ["DEBUG_WORLD_SIZE_API_UNAVAILABLE"] = "API tailleMonde indisponible.",
        ["DEBUG_WORLD_WIDTH"] = "largeurMonde=%.2f (depuis pos carte)",
        ["DEBUG_WORLD_POS_UNAVAILABLE"] = "conversion position monde indisponible.",
        ["DEBUG_WORLD_POS_API_UNAVAILABLE"] = "API position monde indisponible.",
        ["EMPTY_GROUP_MESSAGE"] = "Veuillez\nrejoindre\nun\ngroupe\ns'il\nvous\nplait",
    }
end
