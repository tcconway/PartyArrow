# PartyArrow
PartyArrow adds compact directional arrows that point to your party members, making it easy to stay together in the open world. Each arrow shows distance in meters/kilometers and updates in real time as your group moves.

Supports Retail (Midnight, 12.x) and WoW Forever (1.60.x), in English and French.

## Features

* Appears automatically when you join a party; hidden when solo or in a raid
* Directional arrow and distance for each party member
* Shows a member's zone when they're elsewhere, and Dead/Offline status
* Per-class arrow textures
* Draggable arrow box with saved position
* Options panel to show/hide and lock the arrows

## Commands

* `/pa` (or `/partyarrow`): open the options panel
* `/pa show` / `/pa hide`: turn the arrows on or off for when you're in a party
* `/pa lock` / `/pa unlock`: lock or unlock the arrow box (in a party)
* `/pa reset`: reset the arrow box position
* `/pa debug`: print map and group info for bug reports

## Notes

* Party only, not raids
* Arrows are unavailable inside dungeons and other instances, where the game doesn't share player positions; they return when you leave
* A "?" means the game isn't reporting that member's position
* Bugs and ideas: [GitHub issues](https://github.com/tcconway/PartyArrow/issues)
