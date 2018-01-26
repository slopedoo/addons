--[[

	Mana Use & Stat Evaluation (MUSE)
		Monitors mana use and regeneration.
	
	By:  Pater of Eldre'Thalas

	(See MUSEReadme.txt for detailed information.)

	MUSE
	1.901
	1/??/2006

	Code Structure:
	1. Constants & Variables
	2. Event Handler & Core
	3. Control & I/O
	4. Initialization

	
	Discussion
	- Two types of events are running in parallel:
	(a) When mana changes, MUSE decides whether we're in the FSR or not, and parses the time since the last mana change into time FM, FR, and LR
	(b) Every screen frame update (once per 0.05 seconds maximum frequency), the Status Bar updates how long until the FSR ends.

	- Two other processes flow from (a):
		- If player is "recording" then MUSE accumulates the times FM, FR, and LR.  MUSE calculates a comparison of INT, SPI, and MFS and shows it in the Dashboard.
			- After calculation of the above, the output can be saved to file for later review.
]]--

--[[
	KNOWN ISSUES TO BE FIXED IN VERY NEAR TERM
	- Does not properly account for channeling
	- Does not account for being dead or ghost
	- Has no way of accounting for 3 piece trans bonus.
	- No options to selectively show/hide StatusBar and Dashboard.

	IGNORING FOR NOW
	- Support for non-priests

]]--

--------------------------------------------------
--
-- 1. Constants & Variable Declarations
--
--------------------------------------------------

-- Constants
MUSE_TITLE = "MUSE";
MUSE_VERSION = 1.901;

BINDING_HEADER_MUSE_TITLE = MUSE_TITLE;
BINDING_NAME_MUSE_TOGGLE_MANUAL = "Toggle Manual";
BINDING_NAME_MUSE_TOGGLE_RECORDING = "Start/Stop Recording";

-- The max time (in seconds) between spell stopping and mana going down that will make MUSE assume they are the same event.
MUSE_SPELL_LATENCY = 0.5;

-- Minimum interval for OnUpdate calls - OnUpdate is only used for StatusBarFrame
MUSE_UPDATE_INTERVAL = 0.05;

MUSE_MANA_PER_INT = 15;
MUSE_SECONDS_PER_TICK = 2.0;

-- Default mana regenerated per point of spirit for most classes
MUSE_SPIRIT_PER_MANA_REGEN = {
	["Druid"] = 4,
	["Hunter"] = 2,
	["Mage"] = 5,
	["Paladin"] = 2,
	["Priest"] = 5,
	["Shaman"] = 5,
	["Warlock"] = 5
};

MUSE_SAVED_DATA_HEADER = ",Date/Time,Zone (Area),Duration,Percent FSR,Total Mana Gained,Total Mana Used,SPI Eval.,MFS Eval.,";


-- Variables held between play sessions.
MUSESettings = {setversion, enable, showstatusbar, showdashboard, manual, autorecordminlength};

-- Status, recording status, and talent variables
MUSEStat = {casterclass, initialized, talentsdetected, meditation, mentalstrength, recording};

-- Variables that change frequently.  (Most change each tick.)
MUSETick = {channeling, channelingendtime, currmana, oldmana, currtime, oldtime, lastspellstoptime, inFSR, timestartFSR, timestopFSR, isFM, deltaTLR, deltaTFR, deltaTFM};

-- OnUpdate variables
MUSEOnUpdate = {timesincelastupdate}

-- Stuff that deals with Dashboard and Saved fights
MUSEOut = {totalTFR, totalTLR, totalTFM, totalplusmana, totalminusmana, percentFSR, SPIeval, MFSeval};


--------------------------------------------------
--
-- 2. Event Handler & Core Functions
--
--------------------------------------------------

function MUSE_EventHandler(event,arg1)


	-- Initialize when I first log in, but not when zoning.
	if (event=="PLAYER_LOGIN") then 
		MUSE_Initialize();
	end

	
	-- Only run events if MUSE is enabled and I'm a priest
	if ( (MUSEStat.casterclass) and (MUSESettings.enable) ) then

		-- First, deal with my core function - mana changing.
		if ( (event == "UNIT_MANA") and (arg1 == "player") ) then
			
			MUSE_EventMana();
			
		-- If I'm recording, do a dashboard update.
		if MUSEStat.recording then MUSE_DashboardUpdate() end
		
		
		-- Next deal with all of the other events that might come
		elseif (event == "SPELLCAST_STOP") then
			MUSE_SpellcastStop();
			
		elseif ( (event == "SPELLCAST_CHANNEL_START") or (event == "SPELLCAST_CHANNEL_UPDATE") ) then
			MUSE_ChannelingSpell(event,arg1);
			
		elseif ( (event == "PLAYER_REGEN_DISABLED") and (not MUSESettings.manual) ) then
			MUSE_StartRecording();
			-- Do a preliminary dashboard update as I start recording (grays it out).
			MUSE_DashboardUpdate();
			
		elseif ( (event == "PLAYER_REGEN_ENABLED") and (not MUSESettings.manual) ) then
			MUSE_StopRecording();
			-- Do a (final) dashboard update right after I stop recording.
			MUSE_DashboardUpdate();
			
		elseif (event == "PLAYER_DIED") then
			MUSE_StopRecording();
				
		end
		
		
	elseif not MUSEStat.casterclass then -- I'm not a caster, so unregister events and go to sleep
		-- UNREGITER EVENTS HERE

	end

end -- MUSE_EventHandler



function MUSE_SpellcastStop()
-- Called when a spell "stops" casting--either from completing or being interrupted.  
-- Figure out which one in next event, which is mana update.  If mana went down, spellcast complete and we're in a FSR.
-- The Stop at the end of channeling doesn't trigger an FSR.
	if ( abs(GetTime()-MUSETick.channelingendtime) > MUSE_SPELL_LATENCY ) then
		MUSETick.lastspellstoptime = GetTime();
	else
		-- Spell Stopped but it was just the end of channeling
	end
end


function MUSE_ChannelingSpell(event,duration)
	MUSETick.channeling = true;
	MUSETick.channelingendtime = GetTime() + duration/1000;
end
	

function MUSE_EventMana()
-- The work-horse function.
-- With 1.901, this runs always, regardless of whether it's recording.

	-- Reset delta quantities.
	MUSETick.deltaTFM = 0.0;
	MUSETick.deltaTFR = 0.0;
	MUSETick.deltaTLR = 0.0;

-- (1) What's my status?

	-- Calculate change in mana since last mana update
	MUSETick.oldmana = MUSETick.currmana;
	MUSETick.currmana = UnitMana("player");
	local deltamana = MUSETick.currmana - MUSETick.oldmana;

	-- Calculate change in time since last mana update
	MUSETick.oldtime = MUSETick.currtime;
	MUSETick.currtime = GetTime();
	local deltatime = MUSETick.currtime - MUSETick.oldtime;
	

-- (2) What just happened?  (This is the core code of MUSE.)

	if (MUSETick.isFM) then
		-- If I was FM before this, and mana just changed, all of the past time was FM.
		MUSETick.deltaTFM = deltatime;

	elseif ( not(MUSETick.inFSR) and not MUSETick.channeling ) then
		-- If I wasn't in the FSR before this, and mana just changed, all of the past time was "full regen"
		MUSETick.deltaTFR = deltatime;

	elseif ( (MUSETick.currtime - MUSETick.timestartFSR < 5.0) or MUSETick.channeling ) then
		-- If I was in FSR before, and it's been less than 5 seconds since it started, then all of recent tick was at LR.
		-- If I was channeling, all of the time was LR.
		MUSETick.deltaTLR = deltatime;	
	
	else
		-- Otherwise, the last tick was part TLR and part TFR. 
		MUSETick.deltaTFR = MUSETick.currtime - MUSETick.timestartFSR - 5.0;
		MUSETick.deltaTLR = deltatime - MUSETick.deltaTFR;
	end

-- (3) What comes next?
	-- Work in tandem with MUSE_SpellcastStop() to determine if I lost mana and finished a spell at (about) the same time.
	-- In concept, there could be a bug here if I stop casting (by interrupting, shield bash, etc) at the same time that my mana goes down for other reasons.
	-- ... such as changing gear or a mana sting.  It's probably not a huge deal but I should deal with it somehow.
	if ( (deltamana < 0) and (abs(MUSETick.currtime - MUSETick.lastspellstoptime) < MUSE_SPELL_LATENCY) ) then
		MUSETick.timestartFSR = MUSETick.lastspellstoptime;
		MUSETick.inFSR = true;
	end

	-- Update FSR Status.  (timestartFSR was just updated, above.)
	if (MUSETick.currtime - MUSETick.timestartFSR > 5.0) then
		if MUSETick.inFSR then
			MUSETick.inFSR = false;
			MUSETick.timestopFSR = MUSETick.currtime;
		end
		
	elseif not(MUSETick.inFSR) then
		MUSETick.inFSR = true;
	end
	
	-- Update FM (or dead) Status
	MUSETick.isFM = ( UnitMana("player") == UnitManaMax("player") ) or UnitIsDeadOrGhost("player");
	
	-- Update channeling status.
	if MUSETick.channeling and ( MUSETick.currtime > MUSETick.channelingendtime ) then
		-- ChatFrame1:AddMessage("Turning off channeling in ManaEvent");
		MUSETick.channeling = false;
		MUSETick.timestopFSR = MUSETick.currtime;
	end
	
	
-- (4)) Do something with my deltas:  update global variables and calculate my derived stats.
	if MUSEStat.recording then
		
		MUSEOut.totalTFM = MUSEOut.totalTFM + MUSETick.deltaTFM;
		MUSEOut.totalTFR = MUSEOut.totalTFR + MUSETick.deltaTFR;
		MUSEOut.totalTLR = MUSEOut.totalTLR + MUSETick.deltaTLR;
		
		if deltamana < 0 then 
			MUSEOut.totalminusmana = MUSEOut.totalminusmana + deltamana;
		else
			MUSEOut.totalplusmana = MUSEOut.totalplusmana + deltamana;
		end 
		
		-- The derived numbers (global variables in 1.901)
		MUSEOut.percentFSR = MUSEOut.totalTLR / max(MUSEOut.totalTFR + MUSEOut.totalTLR,1); 
		-- This max(nettime,1) is just there to prevent it from showing %IND when first loading.
		
		-- This is the actual stat evaluation code.
		MUSEOut.SPIeval = 0.125*(MUSEOut.totalTFR + MUSEStat.meditation * MUSEOut.totalTLR) / (15 * MUSEStat.mentalstrength);
		MUSEOut.MFSeval = 0.2*(MUSEOut.totalTFR + MUSEOut.totalTLR) / (15 * MUSEStat.mentalstrength);
		
	end

end -- MUSE_EventMana


--------------------------------------------------
--
-- Control & I/O Functions
--
--------------------------------------------------

function MUSE_StatusBarUpdate(elapsed)
	
	-- if MUSESettings.showstatusbar then....
	
	MUSEOnUpdate.timesincelastupdate = MUSEOnUpdate.timesincelastupdate + elapsed;
	if (MUSEOnUpdate.timesincelastupdate > MUSE_UPDATE_INTERVAL) then
		
		-- If I'm FM
		if MUSETick.isFM then
		
			MUSEStatusBarText:SetText("- Full Mana -");
			MUSEStatusBarText:SetTextColor(0.5,0.5,0.5);
			MUSESBSpark:Hide();
			MUSE_StatusBarSB:SetValue(0);


		elseif MUSETick.channeling then
			
			local channelremain = MUSETick.channelingendtime - GetTime();
			
			MUSEStatusBarText:SetText("Channeling ("..string.format("%.1f",channelremain).."s)");
			MUSEStatusBarText:SetTextColor(1,1,1);
			
			-- Big assumption here:  channeled spells are 60 seconds.  Have to fix this for other classes.
			local sparkPosition = (channelremain/60) * 195;
			
			MUSESBSpark:Show();
			MUSESBSpark:SetPoint("CENTER", "MUSE_StatusBarSB", "LEFT", sparkPosition, 0);
			MUSE_StatusBarSB:SetValue(5*channelremain/60);
			
		elseif MUSETick.inFSR then
			
			local timetilFSRends = max(0,5.0 - (GetTime()-MUSETick.timestartFSR));
			MUSEStatusBarText:SetText(string.format("%.1f",timetilFSRends).." sec");
			MUSEStatusBarText:SetTextColor(1,1,1);
			MUSE_StatusBarSB:SetValue(timetilFSRends);
			
			local sparkPosition = (timetilFSRends/5) * 195;
			MUSESBSpark:Show();
			MUSESBSpark:SetPoint("CENTER", "MUSE_StatusBarSB", "LEFT", sparkPosition, 0);

		else -- I'm regenning full
			
			local fullregenduration = GetTime() - MUSETick.timestopFSR;
		
			MUSEStatusBarText:SetText(">>> "..string.format("%.1f",fullregenduration).." sec");
			MUSEStatusBarText:SetTextColor(1,1,1);
			MUSESBSpark:Hide();
			MUSE_StatusBarSB:SetValue(0);
			
		end
		
		MUSEOnUpdate.timesincelastupdate = 0;
   end
	
end

	

function MUSE_DashboardUpdate()

	-- Calculate Total Combat Time, percent 5-sec-rule, and rounded output numbers.


	local nettime = MUSEOut.totalTFR + MUSEOut.totalTLR;

	if MUSEStat.recording then
		MUSEDashboardRecordingIndicator:SetText("R");
	else
		MUSEDashboardRecordingIndicator:SetText("");
	end
		

	-- Don't update the dashboard if net is less than the dashboard output threshhold.  Instead, turn the dashboard text gray.
	if ( nettime < MUSESettings.autorecordminlength) then
		
		MUSEDashboardText:SetTextColor(0.5,0.5,0.5);
		
	
	else
	
		
		local titleline, firstline, secondline, thirdline;
		
		titleline = "MUSE Dashboard\n";
		
		firstline = string.format("%.1f",nettime).." sec ("..string.format("%d",100*MUSEOut.percentFSR).."% FSR)\n";
		
		secondline = "+"..MUSEOut.totalplusmana.."   "..MUSEOut.totalminusmana.." mana\n";
		
		thirdline = "SPI: "..string.format("%.1f",MUSEOut.SPIeval).."  MFS: "..string.format("%.1f",MUSEOut.MFSeval);
	
		MUSEDashboardText:SetText(titleline..firstline..secondline..thirdline);
		MUSEDashboardText:SetTextColor(1,0.84,0); -- Close to the default yellowish orange?

	end

	
end -- MUSE_DashboardUpdate



function MUSE_SaveData()
-- Sends data to file.

	local datestring = date();
	local zonestring = GetRealZoneText().." ("..GetMinimapZoneText()..")";
	local durationstring = string.format("%.1f",	MUSEOut.totalTFR+MUSEOut.totalTLR);
	local percentFSRstring = string.format("%.1f",MUSEOut.percentFSR*100);
	local SPIevalstring = string.format("%.2f",MUSEOut.SPIeval);
	local MFSevalstring = string.format("%.2f",MUSEOut.MFSeval);
	
	MUSE_SAVED_DATA_HEADER = ",Date/Time,Zone (Area),Duration,Percent FSR,Total Mana Regained,Total Mana Used,SPI Eval.,MFS Eval.,"
	
	
	local newdata = ","..datestring..","..zonestring..","..durationstring..","..percentFSRstring..","..MUSEOut.totalplusmana..","..MUSEOut.totalminusmana..","..SPIevalstring..","..MFSevalstring..",";
	
	table.insert(MUSESavedData,newdata);
	

end -- MUSE_SaveData



function MUSE_Command(msg)

	if (msg == "enable") then
		MUSE_ToggleEnable();

	elseif (msg == "manual") then
		MUSE_ToggleManual();

	elseif (msg == "record") then
		MUSE_ToggleRecording();

	elseif (msg == "init") then
		MUSESettings.setversion = 0.0;
		MUSE_Initialize();

	else
		ChatFrame1:AddMessage("MUSE v"..MUSE_VERSION.." - Mana Use & Stat Evaluation");
		ChatFrame1:AddMessage("/muse enable - Toggle MUSE on/off.  (Saved between sessions.  Auto-disabled for Warriors & Rogues.)");
		ChatFrame1:AddMessage("/muse manual - Toggle between automatically start/stop recording when entering/exiting combat, and manual start/stop of recording.  Keybinding available.");
		ChatFrame1:AddMessage("/muse record - Start or stop recording.  Overrides 'manual' setting.  Keybinding available.");
		ChatFrame1:AddMessage("/muse init - Re-initialize MUSE.");
	
	end

end -- MUSE_Command


function MUSE_ToggleEnable()
-- Toggles enabled or disabled.  (Saved between settings.)

	if (MUSESettings.enable == true) then
		MUSESettings.enable = false;
		ChatFrame1:AddMessage("MUSE: Disabled.");
	else
		MUSESettings.enable = true;
		ChatFrame1:AddMessage("MUSE: Enabled.");
	end
end -- MUSE_ToggleEnable


function MUSE_ToggleManual()
-- Toggles manual and automatic (combat-based) recording.

	if (MUSESettings.manual == true) then
		MUSESettings.manual = false;
		ChatFrame1:AddMessage("MUSE: Automatic Combat Recording Enabled.");
	else
		MUSESettings.manual = true;
		ChatFrame1:AddMessage("MUSE: Automatic Combat Recording Disabled.");
	end

end -- MUSE_ToggleManual


function MUSE_ToggleRecording()
-- Starts and stops recording.  Overrides and disables automatic (combat-based) recording.

	if (MUSESettings.manual == false) then
		MUSE_ToggleManual();
	end

	if (MUSEStat.recording == true) then
		MUSE_StopRecording();
	else
		MUSE_StartRecording();
	end

end


function MUSE_StartRecording()

	-- Initialize variables for the start of combat.

	MUSEStat.recording = true;

	MUSETick.currtime = GetTime();
	MUSETick.currmana = UnitMana("player");

	MUSEOut.totalTFR = 0.0;
	MUSEOut.totalTLR = 0.0;
	MUSEOut.totalTFM = 0.0;
	MUSEOut.totalplusmana = 0;
	MUSEOut.totalminusmana = 0;
	
end



function MUSE_StopRecording()

	-- Need to do a final mana_update for all of the seconds between my last mana regen tick/spellcast and the end of recording.
	if MUSEStat.recording then
		
		MUSE_EventMana();
	
		MUSEStat.recording = false;
	
		-- Only save the fight to file if the length is more than the min length.
		if ( (MUSEOut.totalTFR + MUSEOut.totalTLR) > MUSESettings.autorecordminlength ) then
			  MUSE_SaveData();
		end
	
	end
	
end




--------------------------------------------------
--
-- 4. Initialization Functions
--
--------------------------------------------------

function MUSE_OnLoad()
	
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("PLAYER_DIED");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("SPELLCAST_STOP");
	this:RegisterEvent("SPELLCAST_CHANNEL_START");
	this:RegisterEvent("SPELLCAST_CHANNEL_UPDATE");
	
end



function MUSE_Initialize()
	
	MUSESettings.showstatusbar = false;
	MUSESettings.showdashboard = false;
	local _, localclass = UnitClass("player");
	-- MUSEStat.casterclass = not( (localclass=="ROGUE") or (localclass=="WARRIOR") );
    -- Focus only on priests for now
	MUSEStat.casterclass = (localclass == "PRIEST"); 
	if (MUSEStat.casterclass) then
  		-- If caster [priest for now] class, initialize.
		

		-- UPDATE USER PREFERENCES = MUSESettings --
	
		if MUSESettings.setversion == nil then 
			MUSESettings.setversion = 0.0;
		end

		if (MUSESettings.setversion < MUSE_VERSION) then 

			ChatFrame1:AddMessage("MUSE: Resetting factory defaults.");
		
			MUSESettings.setversion = MUSE_VERSION;

			MUSESettings.manual = false;
			MUSESettings.enable = true;	
			MUSESettings.showstatusbar = false;
			MUSESettings.showdashboard = false;
			
			MUSESettings.autorecordminlength = 60;
		end
			

		if MUSESavedData == nil then
			MUSESavedData = {};

		end
	
		-- Just update the header line every time - no harm in it.
		MUSESavedData[1] = MUSE_SAVED_DATA_HEADER;
		

		-- Register Slash Commands
		SLASH_MUSE1 = "/muse";
		SlashCmdList["MUSE"] = function(msg) MUSE_Command(msg) end


		-- Initialize Status Variables
		MUSEStat.talentsdetected = false;
		MUSEStat.meditation = 0.00
		MUSEStat.mentalstrength = 1.00;
		MUSEStat.recording = false;

		-- Initialize Tick Variables
		MUSETick.channeling = false;
		MUSETick.channelingendtime = GetTime();
		MUSETick.currmana = UnitMana("player");
		MUSETick.oldmana = MUSETick.currmana;
		MUSETick.currtime = GetTime();
		MUSETick.oldtime = MUSETick.currtime;
		MUSETick.lastspellstoptime = GetTime()-6.0;
		MUSETick.inFSR = false;
		MUSETick.timestartFSR = MUSETick.lastspellstoptime;
		MUSETick.timestopFSR = GetTime();
		MUSETick.isFM = true;
		MUSETick.deltaTFR = 0.0;
		MUSETick.deltaTLR = 0.0;
		MUSETick.deltaTFM = 0.0;
		
		MUSEOnUpdate.timesincelastupdate = 0.0;

		-- Initialize Sum, Output, and Eval variables
		MUSEOut.totalTFR = 0.0;
		MUSEOut.totalTLR = 0.0;
		MUSEOut.totalTFM = 0.0;
		MUSEOut.totalplusmana = 0;
		MUSEOut.totalminusmana = 0;
		
		
		-- Initialize the StatusBar
		MUSE_StatusBarSB:SetMinMaxValues(0,5);
		
		-- Initialize the Dashboard:
		MUSEDashboardText:SetTextColor(1,0.84,0);
		MUSEDashboardText:SetText("MUSE Dashboard\n");
		
		MUSEDashboardRecordingIndicator:SetTextColor(1,1,1);
		MUSEDashboardRecordingIndicator:SetText("");
		
		MUSE_DetectTalents();

		local enabletext, manualtext;
		if MUSESettings.enable then enabletext = "enabled" else enabletext = "disabled" end
		if MUSESettings.manual then manualtext = "manual" else manualtext = "automatic" end
		ChatFrame1:AddMessage("MUSE: Initialized, "..enabletext..", "..manualtext.." recording.  /muse for help.");
		

	else
	
		ChatFrame1:AddMessage("MUSE: Disabled for non-priest.");
		
		MUSESettings.enable = false;
		-- this:UnregisterEvent(EVENTS);
	end

end -- MUSE_Initialize



function MUSE_DetectTalents()
-- Detects meditation (mana-regen-during-FSR) and mentalstrength (increased-mana-per-INT) type talents

	local _, localclass = UnitClass("player");

	if ( localclass == "DRUID" ) then

		local _, _, _, _, currrank, _ = GetTalentInfo(3,9);
		MUSEStat.meditation = 0.03 * currrank;
		ChatFrame1:AddMessage("MUSE: Reflection detected as "..currrank.."/5.");

	end


	if ( localclass == "MAGE" ) then

		local _, _, _, _, currrank, _ = GetTalentInfo(1,11);
		MUSEStat.meditation = 0.03 * currrank;
		ChatFrame1:AddMessage("MUSE: Arcane Meditation detected as "..currrank.."/5.");

		local _, _, _, _, currrank, maxrank = GetTalentInfo(1,13);
		MUSEStat.mentalstrength = 1.0 + currrank * 0.02;
		ChatFrame1:AddMessage("MUSE: Arcane Mind detected as "..currrank.."/4.");

	end

	if ( localclass == "PALADIN" ) then
-- NEED TO UPDATE FOR NEW 1.9 PALLY TALENTS
		local _, _, _, _, currrank, _ = GetTalentInfo(1,11);
		MUSEStat.mentalstrength = 1.0 + currrank * 0.02;
		ChatFrame1:AddMessage("MUSE: Divine Wisdom detected as "..currrank.."/5.");

	end

	if ( localclass == "PRIEST" ) then

		local _, _, _, _, currrank, _ = GetTalentInfo(1,12);
		MUSEStat.meditation = 0.03 * currrank;
		ChatFrame1:AddMessage("MUSE: Meditation detected as "..currrank.."/5.");

		local _, _, _, _, currrank, _ = GetTalentInfo(1,10);
		MUSEStat.mentalstrength = 1.0 + currrank * 0.02;
		ChatFrame1:AddMessage("MUSE: Mental Strength detected as "..currrank.."/5.");

	end

	MUSEStat.talentsdetected = true;

end -- MUSE_DetectTalents
