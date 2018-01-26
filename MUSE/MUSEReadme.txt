Mana Use & Stat Evaluation (MUSE)
	Monitors mana use and regeneration.

By:  Pater of Eldre'Thalas

===TESTING VERSION===
This release is for testing and bug quashing.

===INTRO===
Designed to help priests (only, for now) compare the benefit of INT and mana regeneration on gear.
During short fights, INT is always more important.  In long fights, regen is more important.
This mod is designed to help evaluate whether INT, SPI, or other mana-regen generated more mana for the priest.
It is likely that only L60 priests who raid 20 and 40-man content will find this tool useful, because most other priests do not have combats that last 120 seconds or more.
On the other hand, any priest could record longer blocks of time (such as yard trash clearing in instances or level grinding) to try to optimize mana use and regen.

===TERMINOLOGY===
Stats: INT, SPI, and MFS (+mana/5 sec)
FSR = Five-second-rule (SPI-based regen disabled or reduced to a fraction, for five seconds after a completed spellcast)
Time types are:
- TFR = Time spent at normal mana regen (non-FSR).
- TLR = Time spent at low mana regen (within FSR).
- TFM = Time spent at full mana (While you are at full mana, *none* of the stats in consideration help you - this time is subtracted from totals.)
"meditation" refers to talents that allow SPI regen to continue (at reduced rate) during FSR.
"mentalstrength" refers to talents that increase mana gains from INT.

===THE NUMBERS===
1 INT = 15 mana (increased up to 15% by talents)
1 SPI = 0.25 mana/tick = 0.125 mana/sec (at full regeneration).  (In FSR, zero or a percentage of full, with certain talents.)
+1 Mana per 5 seconds = 0.20 mana/sec (at all times)

The basic formula for INT versus SPI is 15/0.125 = 120 seconds.  
(That means that it would take 120 seconds of non-FSR time for one point of SPI to regenerate the same amount of mana that 1 point of INT gave you.)
An illustration:

===THE OUTPUT & SAMPLE USAGE===
The final output stat comparison gives a number for SPI and a number for MFS.  These numbers are designed to be compared to a baseline of INT=1.0.
For example, after a very long boss fight, you might see the following output.

Example:  SPI = 1.5  MFS = 2.6.
This means that for every point of mana that INT gave your mana pool, you regained 1.6 points of mana per point of SPI and 2.6 points of mana per MFS.

If you wanted to optimize your gear or your buffs, you might use the numbers in the following way:

-Gear Comparison-
Compare two cloaks and see which would help you most during that fight:
Frostweaver Cape, 12 INT, 12 SPI
Faded Hakkari Cloak, 8 INT, 6 MFS

Frostweaver:  12INT*1.0 + 12SPI*1.5 = 30
Faded Hakkari:  8INT*1.0 + 6MFS*2.6 = 23.6

The Frostweaver cloak would be superior in terms of mana use (ignoring STA, resists, etc.).

-Buff Comparison-
If you had to choose between Blessing of Wisdom and Blessing of Kings, which would you prefer?
Blessing of Wisdom:  33MFS*2.6 = 85.8
Blessing of Kings (assume you have 300 INT and 300 SPI):  30INT*1.0 + 30SPI*1.5 = 75

Wisdom would get you more mana than Kings in this situation (again, ignoring  STA benefits).


===EXTRACTING SAVED DATA==
Data is output in a comma-separated-variable (CSV) format.  They are saved per-character.
File: \WTF\Account\[YOUR ACCOUNT NAME]\[SERVER NAME]\[CHARACTER NAME]\SavedVariables\MUSE.lua
To open the file in Excel:
1.  File-Open-(Files of type: all files) & navigate to the file named above.  This will trigger the Text Import Wizard.
2.  Start import at row: 10 (or whatever line you see the word MUSESavedData).  Select "delimited" if it is not already.  Click Next.
3.  Select "Tab" and "Comma" and "Other" and put the equals sign (=) in the box.  Click Finish.
4.  "Save As" another file so you don't overwrite MUSE.lua.