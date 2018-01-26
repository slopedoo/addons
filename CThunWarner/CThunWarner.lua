CThunWarnerStatus_InCombat = 0;
CThunWarnerStatus_PlaySound = 1;
CThunWarnerStatus_SoundPhase2 = 0;
CThunWarnerStatus_ShowList = 4;
CThunWarnerStatus_RangeStatus = 0;
CThunWarnerStatus_CurrentTime = 0;
CThunWarnerStatus_LastTimeCheck = 0;
CThunWarnerStatus_LastTimeSound = 0;
CThunWarnerStatus_Scale = 1;
CThunWarnerStatus_Locked = 0;
CThunWarnerStatus_InStomach = 0;
CThunWarnerStatus_TempDisableSound = 0;
CThunWarnerStatus_Players = {};
CThunWarnerStatus_PlayersStomach = {};
CThunWarnerStatus_DigestiveAcidTexture = "Interface\\Icons\\Ability_Creature_Disease_02";

if (GetLocale() == "deDE") then
	CThunWarnerStatus_Emote = "ist geschw\195\164cht!";
	CThunWarnerStatus_Dies = "Auge von C'Thun stirbt.";
else
	CThunWarnerStatus_Emote = "is weakened!";
	CThunWarnerStatus_Dies = "Eye of C'Thun dies.";
end

function CThunWarner_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("CHAT_MSG_MONSTER_EMOTE");
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
	
	SLASH_CThunWarner1 = "/ctw";
	SLASH_CThunWarner2 = "/ctr";
	SlashCmdList["CThunWarner"] = CThunWarner_SlashHandler;
end

function CThunWarner_SlashHandler(arg1)
	local _, _, command, args = string.find(arg1, "(%w+)%s?(.*)");
	if(command) then
		command = strlower(command);
	else
		command = "";
	end
	if(command == "sound") then
		if(args == "on") then
			CThunWarnerStatus_PlaySound = 1;
			DEFAULT_CHAT_FRAME:AddMessage("Enabled sound warning", 1, 1, 0);
		elseif(args == "off") then
			CThunWarnerStatus_PlaySound = 0;
			DEFAULT_CHAT_FRAME:AddMessage("Disabled sound warning", 1, 1, 0);
		end
	elseif(command == "soundphase2") then
		if(args == "on") then
			CThunWarnerStatus_SoundPhase2 = 1;
			DEFAULT_CHAT_FRAME:AddMessage("Enabled sound warning in phase 2", 1, 1, 0);
		elseif(args == "off") then
			CThunWarnerStatus_SoundPhase2 = 0;
			DEFAULT_CHAT_FRAME:AddMessage("Disabled sound warning in phase 2", 1, 1, 0);
		end
	elseif(command == "lock") then
		CThunWarnerStatus_Locked = 1;
		DEFAULT_CHAT_FRAME:AddMessage("Locked", 1, 1, 0);
	elseif(command == "unlock") then
		CThunWarnerStatus_Locked = 0;
		DEFAULT_CHAT_FRAME:AddMessage("Unlocked", 1, 1, 0);
	elseif(command == "reset") then
		CThunWarnerFrame:SetScale(1);
		CThunWarnerStatus_Scale = 1;
		CThunWarnerFrame:ClearAllPoints();
		CThunWarnerFrame:SetPoint("CENTER", "UIParent");
		CThunWarnerFrame:Show();
		DEFAULT_CHAT_FRAME:AddMessage("Position reseted", 1, 1, 0);
	elseif(command == "scale") then
		if(tonumber(args)) then
			local newscale = tonumber(args);
			CThunWarnerFrame:SetScale(newscale);
			CThunWarnerStatus_Scale = newscale;
			CThunWarnerFrame:ClearAllPoints();
			CThunWarnerFrame:SetPoint("CENTER", "UIParent");
			CThunWarnerFrame:Show();
			DEFAULT_CHAT_FRAME:AddMessage("Scale is now "..newscale, 1, 1, 0);
		end
	elseif(command == "list") then
		if(tonumber(args)) then
			local newlines = tonumber(args);
			CThunWarnerStatus_ShowList = newlines;
			DEFAULT_CHAT_FRAME:AddMessage("Now showing "..newlines.." lines in list", 1, 1, 0);
		end
	elseif(command == "ooc") then
		CThunWarnerStatus_InCombat = 0;
		CThunWarnerStatus_TempDisableSound = 0;
		DEFAULT_CHAT_FRAME:AddMessage("You are now ooc", 1, 1, 0);
	else
		if(CThunWarnerFrame:IsVisible()) then
			CThunWarnerFrame:Hide();
			CThunWarnerTooltip:Hide();
			CThunWarnerStomachTooltip:Hide();
			CThunWarnerStatusBar:Hide();
			DEFAULT_CHAT_FRAME:AddMessage("Range check disabled", 1, 1, 0);
		else
			CThunWarnerFrame:Show();
			DEFAULT_CHAT_FRAME:AddMessage("Range check enabled", 1, 1, 0);
		end
	end
end

function CThunWarner_OnEvent(event)
	if(event == "PLAYER_REGEN_DISABLED") then
		CThunWarnerStatus_InCombat = 1;
	elseif(event == "PLAYER_REGEN_ENABLED") then
		CThunWarnerStatus_InCombat = 0;
		CThunWarnerStatus_TempDisableSound = 0;
	elseif(event == "VARIABLES_LOADED") then
		CThunWarnerFrame:SetScale(CThunWarnerStatus_Scale);
		if(CT_RA_SendStatus and not CThunWarner_Old_CT_RA_SendStatus) then
			CThunWarner_Old_CT_RA_SendStatus = CT_RA_SendStatus;
			CT_RA_SendStatus = function()
					CThunWarner_Old_CT_RA_SendStatus();
					CT_RA_AddMessage("CTR 1.04");
				end;
			CT_RA_SendStatus();
		end
	elseif(event == "CHAT_MSG_MONSTER_EMOTE") then
		if(arg1 == CThunWarnerStatus_Emote) then
			CThunWarnerStatusBar_Timer(45);
			PlaySoundFile("Interface\\AddOns\\CThunWarner\\alarm.mp3");
		end
	elseif(event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
		if(arg1 == CThunWarnerStatus_Dies) then
			if(CThunWarnerStatus_SoundPhase2 == 0) then
				CThunWarnerStatus_TempDisableSound = 1;
			end
		end
	end
end

function CThunWarner_OnUpdate(arg1)
	CThunWarnerStatus_CurrentTime = CThunWarnerStatus_CurrentTime + arg1;
	if(CThunWarnerStatus_CurrentTime > (CThunWarnerStatus_LastTimeCheck+0.1)) then
		local unitid, unitidpet;
		CThunWarnerStatus_Players = {};
		CThunWarnerStatus_PlayersStomach = {};
		CThunWarnerStatus_InStomach = 0;
		for i = 1, GetNumRaidMembers(), 1 do
			unitid = "raid"..i;
			if(not UnitIsDeadOrGhost(unitid)) then
				if(not UnitIsUnit(unitid, "player")) then
					if(CheckInteractDistance(unitid, 3)) then
						tinsert(CThunWarnerStatus_Players, (UnitName(unitid)));
					end
				end
				for a=1,16 do
					local t,c = UnitDebuff(unitid,a);
					if(t == nil) then break; end;
					if(t == CThunWarnerStatus_DigestiveAcidTexture)
					then
						if(UnitIsUnit(unitid, "player")) then
							CThunWarnerStatus_InStomach = 1;
						end
						tinsert(CThunWarnerStatus_PlayersStomach, unitid);
						break;
					end
				end
			end
		end

		if(getn(CThunWarnerStatus_Players) > 0) then
			CThunWarnerStatus_RangeStatus = 1;
			--CThunWarnerStatusTexture:SetVertexColor(1,1,0); -- yellow
			CThunWarnerStatusTexture:SetVertexColor(1,0,0); -- red
			if(CThunWarnerStatus_InCombat == 1 and CThunWarnerStatus_PlaySound == 1 and CThunWarnerStatus_TempDisableSound == 0 and CThunWarnerStatus_InStomach == 0) then
				if(CThunWarnerStatus_CurrentTime > (CThunWarnerStatus_LastTimeSound+1)) then
					PlaySoundFile("Interface\\AddOns\\CThunWarner\\beep.mp3");
					CThunWarnerStatus_LastTimeSound = CThunWarnerStatus_CurrentTime;
				end
			end
		else
			CThunWarnerStatus_RangeStatus = 0;
			CThunWarnerStatusTexture:SetVertexColor(0,1,0); -- green
		end
		CThunWarner_UpdateList();
		CThunWarner_UpdateStomachList();
		CThunWarnerStatus_LastTimeCheck = CThunWarnerStatus_CurrentTime;
	end
end

function CThunWarnerStatusBar_Timer(time)
	CThunWarnerStatusBar.startTime = GetTime();
	CThunWarnerStatusBar.endTime = CThunWarnerStatusBar.startTime + time;
	CThunWarnerStatusBar:SetMinMaxValues(CThunWarnerStatusBar.startTime, CThunWarnerStatusBar.endTime);
	CThunWarnerStatusBar:SetValue(CThunWarnerStatusBar.startTime);
	CThunWarnerStatusBar:Show();
end

function CThunWarnerStatusBar_OnUpdate()
	local time = GetTime();
	if(time > this.endTime) then
		time = this.endTime
	end
	if (time == this.endTime) then
		this:Hide();
		return;
	end
	this:SetValue(this.startTime + (this.endTime - time));
	getglobal(this:GetName().."Text"):SetText(format("%.2f", this.endTime - time));
end

function CThunWarner_UpdateList()
	CThunWarnerTooltip:SetOwner(CThunWarnerFrame, "ANCHOR_BOTTOMRIGHT");
	CThunWarnerTooltip:SetFrameStrata("HIGH");
	if(CThunWarnerStatus_RangeStatus == 0 or CThunWarnerStatus_ShowList == 0) then
		CThunWarnerTooltip:Hide();
	else
		CThunWarnerTooltip:ClearLines();
		CThunWarnerTooltip:AddLine("To near:");
		local index = 1;
		for key, player in CThunWarnerStatus_Players do
			CThunWarnerTooltip:AddLine("- "..player);
			if(index >= CThunWarnerStatus_ShowList) then
				break;
			end
			index = index + 1;
		end
		CThunWarnerTooltip:Show();
	end
end

function CThunWarner_UpdateStomachList()
	CThunWarnerStomachTooltip:SetOwner(CThunWarnerFrame, "ANCHOR_RIGHT");
	CThunWarnerStomachTooltip:SetFrameStrata("HIGH");
	if(getn(CThunWarnerStatus_PlayersStomach) == 0 or CThunWarnerStatus_InStomach == 1) then
		CThunWarnerStomachTooltip:Hide();
	else
		CThunWarnerStomachTooltip:ClearLines();
		CThunWarnerStomachTooltip:AddLine("Stomach:");
		for key, unit in CThunWarnerStatus_PlayersStomach do
			if(UnitExists(unit)) then
				if(UnitInParty(unit)) then
					CThunWarnerStomachTooltip:AddLine((UnitName(unit)),1,0,0,0);
				else
					CThunWarnerStomachTooltip:AddLine((UnitName(unit)));
				end
			end
		end
		CThunWarnerStomachTooltip:Show();
	end
end

