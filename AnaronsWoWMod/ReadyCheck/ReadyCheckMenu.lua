FeedBack = {}
local CheckStarter
local Waiting = 0
local AllReady = true
local XMLNewLine = "\r"
local IsAFK = false
local StartTime

local RCChannel = "RAID"

function AWMReadyCheckMenuOnLoad()

	for id = 1,40 do
		f = CreateFrame('Button','AWMReadyCheckMenu'..id..'Frame',this);
		f.id = id
		
		f:SetFrameStrata('HIGH')
		f:SetWidth(40)
		f:SetHeight(29)
		
		s = f:CreateFontString('AWMBuffSearchMenu'..id..'Text')
		s:SetFontObject('GameFontNormalSmall')
		s:SetAllPoints(f)
		s:SetWidth(40)
		s:SetHeight(29)
		f.s = s
		
		t = f:CreateTexture('AWMBuffSearchMenu'..id..'Texture','BACKGROUND')
		t:SetTexture('Interface\\Tooltips\\UI-Tooltip-Background')
		
		t:SetAllPoints(f)
		t:SetWidth(40)
		t:SetAlpha(0.3)
		t:SetHeight(29)
		f.t = t
		
		i = id
		j = 0
		while i > 5 do
			i = i - 5
			j = j + 1
		end
		
		f:SetPoint('TOPLEFT',i*45-6,-90-j*33,'TOPLEFT')
		f:Hide()
	end
end

function AWMReadyCheckOnUpdate()
	local i = 0
	for i = 1, 40 do
		name = UnitName("raid"..i)
		f = getglobal(this:GetName()..i..'Frame')
		if (name) then
			local reply = FeedBack[name]
			f:Show()
			
			local color=''
			local note =''
			if reply then
				if (reply == 'READY') then
					color = '00FF00'
					note = 'Ready'
				elseif (reply == 'NOT_READY') then
					color = 'FF0000'
					note = 'Wait!'
				elseif (reply == 'AFK') then
					color = 'FFFF00'
					note = 'AFK'
				elseif (reply == 'PENDING') then
					color = 'FFFFFF'
					note = '...'
				elseif (UnitLevel('raid'..i) == 0) then
					color = '0000FF'
					note = 'Offline'
				else
					color = '000000'
					note = 'Bugged!'
				end
			else
				color = 'BBBBBB'
				note = ''
			end
			if string.len(name) > 5 then
				name = string.sub(name,1,5)
			end
			f.s:SetText('\124cff'..color..name..'\n'..note)
		else
			f:Hide()
			reply = 'pending'
		end
	end
end

function CountReplies()
	Waiting = Waiting - 1
	if (Waiting == 0) then
		print('Ready Check: Everyone has replied.')
	end	
end

function DoReadyCheck()
	--Print(this:GetName())
	if (IsRaidLeader() and UnitInRaid("player")) then
		Print("A ready check was started.")
		SendAddonMessage("ReadyCheckStart",UnitName("player"),"RAID")
	end
end


function RCGetMessage(Key, Message, Channel, Sender)
	RCChannel = Channel
	if string.find(Key,'ReadyCheck') then print(key) end
--	Key, Message, Channel, Sender
	if (Key == "ReadyCheckStart") then
		ShowUIPanel(AWMMainMenu)
		ShowUIPanel(AWMReadyCheckMenu)
		Ready = 0
		AllReady = true
		FeedBack = {}
		
		CheckStarter = Sender
		StaticPopupDialogs["RC_TWO_OPTIONS"]["text"] = CheckStarter..": Are you ready?"
		if (IsAFK) then
			StaticPopup_timeout = 5
		end
		StaticPopup_Show("RC_TWO_OPTIONS")
		StartTime = GetTime()
		SendAddonMessage("ReadyCheckCount",CheckStarter,Channel);
	elseif (Key == "ReadyCheckReplyYes") then
		FeedBack[Sender] = "READY"
	elseif (Key == "ReadyCheckReplyNo") then
		AllReady = false
		FeedBack[Sender] = "NOT_READY"
	elseif (Key == "ReadyCheckReplyAFK") then
		AllReady = false
		FeedBack[Sender] = "AFK"
	elseif (Key == "ReadyCheckCount") then
		FeedBack[Sender] = 'PENDING'
		Waiting = Waiting + 1;
	end
end

-- System message
CreateFrame("Frame", "RC_SYSTEM");
RC_SYSTEM:SetScript("OnEvent", function()
	if (arg1 == "You are now AFK: Away from Keyboard") then
		IsAFK = true
	elseif (arg1 == "You are no longer AFK.") then
		IsAFK = false
	end
end);
RC_SYSTEM:RegisterEvent("CHAT_MSG_SYSTEM");

CreateFrame("Frame","RC_UPDATE");

-- Menues
StaticPopupDialogs["RC_TWO_OPTIONS"] = {
	text = "Are you ready?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		SendAddonMessage("ReadyCheckReplyYes",CheckStarter, RCChannel)
	end,
	OnCancel = function()
		if (IsAFK) or (GetTime() - StartTime > 9) then
			SendAddonMessage("ReadyCheckReplyAFK",CheckStarter,RCChannel)
		else
			SendAddonMessage("ReadyCheckReplyNo",CheckStarter,RCChannel)
		end
	end,
	timeout = 10,
	whileDead = true,
	hideOnEscape = false,
}

CreateFrame("Frame", "AWM_READY_CHECK_FRAME");
AWM_READY_CHECK_FRAME:SetScript("OnEvent", function()
	RCGetMessage(arg1,arg2,arg3,arg4)
end);
AWM_READY_CHECK_FRAME:RegisterEvent("CHAT_MSG_ADDON");