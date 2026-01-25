# PartyArrow
PartyArrow is a WoW addon for Midnight (12.x) that shows directional arrows to party members with distance and status indicators, class-based arrow textures, and a simple options panel.

## Features

Directional arrows for each party member
Distance display in meters/kilometers
DEAD/OFFLINE status indicators
Per-class arrow textures with a default fallback
Draggable arrow box with saved position
In-game options panel

## Commands

/pa  or (/partyarrow) opens the options panel
/pa show - shows the arrows
/pa hide - hides the arrows
/pa lock - locks the arrow box
/pa unlock - unlocks the arrow box
/pa reset - resets the arrow box position
/pa debug - prints map/debug info

## Notes
* Party only (not shown in raids)
* Uses the WoW C_Map API with automatic map scaling fallback