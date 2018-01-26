C'Thun Warner

Author:
-------
Alason aka Freddy
http://black-fraternity.de (PM to Alason)
CThunWarner@freddy.eu.org

Purpose:
--------
Shows some information about the C'Thun fight

Installation:
-------------
Copy it to your Interface\AddOns dir

Notes:
-------------
It will shows a dot which changes color:
red: somebody is very near to you (< 5 yards)
yellow: somebody is near to you (>5 yards but <10 yards
green: everybody is far enough away from you (> 10 yards)

If somebody is to near you'll hear a beeping sound (only when you're in combat)

Players who are to near to you can be shown in a list

In Phase 2 it will show you who's in the stomach of C'Thun and how many debuffs they have
Players who are in your in the stomach + in your party will be colored red

It will play a alarm sound when CThun is weakened and show a process bar of the weakened phase

Commands:
-----------------
/ctw - Show/Hide the dot
/ctw sound on/off - Enables/Disables the beeping sound
/ctw soundphase2 on/off - Enables/Disables the beeping sound in phase 2
/ctw list 0...40 - Sets how many player names will be shown in the list of players who are to near (0 means disabled)
/ctw ooc - Sometimes wow dosn't recognises the end of the combat correctly this will make the addon stop beeping ;)
/ctw scale 1...20 - Sets the scale of the dot (1 is default)
/ctw reset - Resets position and scale of the dot
/ctw lock - Locks the dot
/ctw unlock - Unlocks the dot

ToDo:
-----------------
- Tell me your ideas
- Class colors/stomach list

can you please change the dot so that when it's locked it doesn't accept mouse clicks? if you hold right click on the dot to move your camera around, it doesn't work. you also cannot click on or mouseover things behind it.

I believe you use Frame:EnableMouse(0) to allow mouse clicks to pass through, and (1) to start accepting mouse clicks again

also, commands to disable the weaken sounds and progress bar would be nice :)

History:
-----------------
Version 1.05
- Removed 5 yards check
- Wont check distance for pet's any longer
- Wont check if a player is in the stomach if he's death
- Changed toc to 11200
- Wont show debuff count, due to it was often incorrect

Version 1.04
- Renamed addon to CThunWarner
- Removed the mouse over tooltip
- Added timer and alarm sound for weakened phase
- Added list with players who are currently in the stomach of C'Thun (red colored name means the player is in your party)
- "/ctw soundphase2 on/off" added, allowes you to disable sound in phase 2
- "/ctw ooc" added, sometimes it doesn't stop beeping, this helps

Version 1.03
- Range 5-10y => Button will become yellow and it will beep normal (once a second)
- Range 0-5y => Button will become red and it will beep very fast (twice a second)
- "/ctr list 0-40" added, shows an always visible list of players which are to near to, you can set a max count of palyers to show
- "/ctr lock" added
- "/ctr unlock" added

Version 1.03
- Range 5-10y => Button will become yellow and it will beep normal (once a second)
- Range 0-5y => Button will become red and it will beep very fast (twice a second)
- "/ctr list 0-40" added, shows an always visible list of players which are to near to, you can set a max count of palyers to show
- "/ctr lock" added
- "/ctr unlock" added

Version 1.02
- Wont check own pets anymore
- "/ctr scale" added

Version 1.01
- Pets will be checked now
- Only living players will be checked
- Changed range to 10y
- Fixed beep sound
- Added "/ctr reset" to reset the position


