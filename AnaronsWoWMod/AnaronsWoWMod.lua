BINDING_HEADER_ANARONSWOWMOD = "Anaron's WoW Mod"

--/script local type, id, book = GetCursorInfo(); print((type=="item") and GetItemIcon(id) or (type=="spell") and GetSpellTexture(id,book) or (type=="macro") and select(2,GetMacroInfo(id)))
--/script print( GetMouseFocus():GetTexture() )

AWMMinigameUP	= false;
AWMMinigameDOWN	= false;
AWMMinigameLEFT	= false;
AWMMinigameRIGHT= false;
	

AWMClasses = {'Warrior','Mage','Rogue','Druid','Hunter','Shaman','Priest','Warlock','Paladin'}

function MergeFunctions(func1,func2)
	return function(...)
		func1(unpack(arg))
		func2(unpack(arg))
	end
end

function codeSplit(arg1)
	words = {};
	for word in string.gfind(arg1, "[^%$]+") do
		table.insert(words, word);
	end
	return words
end

function commaSplit(arg1)
	return toTable(string.gsub(arg1,'%s*,%s*',','),'[^,]+')
end

function toTable(arg1,regex)
	words = {};
	for word in string.gfind(arg1, regex) do
		words[word] = word
	end
	return words
end

function toLists(arg1,regex)
	words = {};
	for word in string.gfind(arg1, regex) do
		table.insert(words, word);
	end
	return words
end

AWMIsRaidLeader = IsRaidLeader
function IsRaidLeader()
	return AWMIsRaidLeader() or IsRaidOfficer()
end

function ColorPrint(msg,r,g,b)
	DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b)
end
function Print(msg)
	ColorPrint(msg, 1, 1, 0)
end
function GreenPrint(msg)
	ColorPrint(msg, 0, 0.8, 0)
end
function RedPrint(msg)
	ColorPrint(msg, 0.8, 0, 0)
end
function PurplePrint(msg)
	ColorPrint(msg, 0.8, 0, 0.8)
end
function RedPrint2(msg)
	ColorPrint(msg, 1, 0.2, 0.2)
end


AWMClassCoords = {
	["WARRIOR"]	= {0, 0.25, 0, 0.25},
	["MAGE"]	= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]	= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]	= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]	= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]	= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]	= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]	= {0, 0.25, 0.5, 0.75}
};

ClassColors = {Warrior = "\124cffC79C6E", Warlock = "\124cff9482C9", Mage = "\124cff69CCF0", Priest = "\124cffFFFFFF", Hunter = "\124cffABD473", Druid = "\124cffFF7D0A", Paladin = "\124cffF58CBA", Shaman = "\124cff0070DE", Rogue = "\124cffFFF569", White = "\124cffFFFFFF", Creator = "\124cffFF3333", Tank = "\124cff666666", Melee = "\124cff3333FF", Caster = "\124cffFF3333", Healer = "\124cff99FF33"}

function AddClassColor(unittab)
	if (unittab) then
		return get(ClassColors,unittab[2],"\124cffFFFFFF")..'|Hplayer:'..unittab[1]..'|h'..unittab[1]..'|h|r'
	else
		return ' '
	end
end

function FormatUnitName(unit)
	if (unit) then
		local name = UnitName(unit)
		local class = UnitClass(unit)
		if (name and class) then
			if (ClassColors[class]) then
				return ClassColors[class]..'|Hplayer:'..name..'|h'..name..'|h|r'
			end
		end
		return name
	end
	return ' '
end

function FormatPlayerName(name)
	return '|Hplayer:'..name..'|h'..name..'|h|r'
end

function get(dict,index,default)
	if (dict) then
		if (dict[index]) then
			return dict[index]
		else
			return default
		end
	else
		return default
	end
end

function SortUnitsToGroups(units)
	local groups = {{},{},{},{},{},{},{},{}}
	for unit in units do
		table.insert(groups[UnitGroup(unit)],{UnitName(unit),UnitClass(unit)})
	end
	return groups
end

function AddGroupUnitsToTooltip(groups)
	for i = 1,8,2 do
		GameTooltip:AddDoubleLine('Group'..i..':','Group'..(i+1)..':', 1,1,1, 1,1,1)
		for j = 1,5 do
			name1, name2 = AddClassColor(groups[i][j]), AddClassColor(groups[i+1][j])
			if not (name1 == ' ' and name2 == ' ') then
				GameTooltip:AddDoubleLine('  '..name1,name2..'  ')
			end
		end
	end
end

function UnitGroup(unit)
	_,_, group = GetRaidRosterInfo(tonumber(string.sub(unit,5)))
	return group
end


function ToUnderScore(input)
	return string.gsub(input,' ','_')
end

function ToUnderSpace(input)
	return string.gsub(input,'_',' ')
end


function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg,1,1,0)
end

function channelprint(msg,channel)
	c = ChatTypeInfo[arg3]
	ColorPrint('['..string.upper(string.sub(channel,1,1))..string.lower(string.sub(channel,2))..'] '..msg,c.r,c.g,c.b)
end

function pyt(dx,dy)
	return math.sqrt(dx*dx+dy*dy);
end

CreateFrame("Frame","AWMLoadFrame");
AWMLoadFrame:SetScript("OnEvent",function()
	if (arg1 == "AnaronsWoWMod") then
		if (AWMIconX == nil) then
			AWMIconX = -75
		end
		if (AWMIconY == nil) then
			AWMIconY = -20
		end
		if (AWMHiddenIcon == nil) then
			AWMHiddenIcon = false
		end
		if (AWMHiddenIcon) then
			AWMIcon:Hide()
		end
		if (AWMScrubs == nil) then
			AWMScrubs = {}
		end
		if (AWMDKP == nil) then
			AWMDKP = {}
		end
	end
end);
AWMLoadFrame:RegisterEvent("ADDON_LOADED")

function AWMLoadIcon(frame,slot)
	if (AWMFeatures == nil) then
		AWMFeatures = {raid=0, guild=0, misc=0}
	end
	y = ({raid=-205, guild=-90, misc=-320})[slot]
	x = AWMFeatures[slot] + 1
	AWMFeatures[slot] = x
	
	while (x > 7) do
		x = x-6
		y = y - 35
	end
	x = 35*x	
	
	frame:SetPoint(
		"TOPLEFT",
		"AWMMainMenu",
		"TOPLEFT",
		x,
		y
	);

	if (slot == 'raid') then
		frame:SetScript('OnUpdate',function()
			if (UnitInRaid("player")) then
				frame:SetAlpha(1)
			else
				frame:SetAlpha(0.3)
			end
		end);
	end
end


CreateFrame("Frame", "AWMMessageFrame");
AWMMessageFrame:SetScript("OnEvent", function()
	if (arg1 == "AWMMessage") then
		arg2 = AWMParseAddonMessage(arg2)--???
		channelprint('['..FormatPlayerName(arg4)..']: '..arg2,arg3)
	end
end);
AWMMessageFrame:RegisterEvent("CHAT_MSG_ADDON");


AWMChatFrame_OnEvent = ChatFrame_OnEvent
function ChatFrame_OnEvent(event)
	if (arg1) then
		if string.find(arg1,'::AWM::') then
			return
		elseif string.find(arg1,'::DKP::') and event == 'CHAT_MSG_WHISPER' then
			local name = string.upper(string.sub(arg1,8,8))..string.lower(string.sub(arg1,9))
			name = string.gsub(name,'(%a+)','%1')
			if name == '' then name = arg2 end
			SendChatMessage((name..' has '..get(AWMDKP,name,0)..' DKP.'),'WHISPER',nil,arg2)
			return
		end
	end
	AWMChatFrame_OnEvent(event)
end

function GetActionName(arg1)
	AWMTooltip:SetOwner(Minimap, "ANCHOR_RIGHT");
	AWMTooltip:SetText("AWMTooltip");
	AWMTooltip:AddLine("Must be show to",1,1,1);
	AWMTooltip:AddLine("this featur working.",1,1,1);
	AWMTooltip:Show()
	
	AWMTooltip:SetAction(arg1)
	actionname = AWMTooltipTextLeft1:GetText()
	AWMTooltip:Hide()
	return actionname
end

function GetFullSpellInfo(spell)
	local name = true
	local slot = 0
	while name do
		slot = slot +1
		name = GetSpellName(slot,"player")
		if name == spell then
			AWMTooltip:SetOwner(Minimap, "ANCHOR_RIGHT");
			AWMTooltip:SetText("AWMTooltip");
			AWMTooltip:AddLine("Must be show to",1,1,1);
			AWMTooltip:AddLine("this featur working.",1,1,1);
			AWMTooltip:Show()
			
			AWMTooltip:SetSpell(slot,'player')
			
			local tmp = {}
			i = 1
			while getglobal('AWMTooltipTextLeft'..i) do
				local tmp3 = getglobal('AWMTooltipTextLeft'..i):GetText()
				if tmp3 then
					table.insert(tmp,tmp3)
				end
				i = i + 1
			end

			AWMTooltip:Hide()
			return tmp[1],tmp[table.getn(tmp)],tmp
		end
	end
end

function buffed(buff)
	return AWMUnitHasBuff('player',buff)
end

function AWMUnitHasBuff(unit,buff)
	local i = 0;
	local Buff = true
	while Buff do
  	i = i + 1;
  	Buff = GetBuffName(unit,i)
  	if Buff then
  		if (string.find(string.lower(Buff),string.lower(buff))) then
  			return true
  		end
  	end
  end
  return false
end

function AWMUnitHasDebuff(unit,buff)
	local i = 0;
	local Buff = true
	while Buff do
  	i = i + 1;
  	Buff = GetDebuffName(unit,i)
  	if Buff then
  		if (string.find(string.lower(Buff),string.lower(buff))) then
  			return true
  		end
  	end
  end
  return false
end

function GetBuffName(target,index)
	if (UnitBuff(target, index)) then
		AWMTooltip:SetOwner(Minimap, "ANCHOR_RIGHT");
		AWMTooltip:SetText("AWMTooltip");
		AWMTooltip:AddLine("Must be show to",1,1,1);
		AWMTooltip:AddLine("this featur working.",1,1,1);
		AWMTooltip:Show()
		
		AWMTooltip:SetUnitDebuff(target, index)
		buffname = AWMTooltipTextLeft1:GetText()
		AWMTooltip:Hide()
		return buffname
	else
		return false
	end
end

function GetBuffName(target,index)
	if (UnitBuff(target, index)) then
		AWMTooltip:SetOwner(Minimap, "ANCHOR_RIGHT");
		AWMTooltip:SetText("AWMTooltip");
		AWMTooltip:AddLine("Must be show to",1,1,1);
		AWMTooltip:AddLine("this featur working.",1,1,1);
		AWMTooltip:Show()
		
		AWMTooltip:SetUnitBuff(target, index)
		buffname = AWMTooltipTextLeft1:GetText()
		AWMTooltip:Hide()
		return buffname
	else
		return false
	end
end

function TryCastSpellByName(spell,caster)
	if (caster == nil) then
		caster = 'player'
	end
	
	for i = 1,100 do
		local name = GetSpellName(i,caster)
		if (name == nil) then
			return false
		end
		if (name == spell) then
			if (GetSpellCooldown(i,caster) > 0) then
				return false
			elseif (UnitMana('player') >= GetSpellCost(i,caster)) then
				CastSpellByName(spell)
				return true
			else
				return false
			end
		end
	end
end

function GetSpellCost(i,caster)
	AWMTooltip:SetOwner(Minimap, "ANCHOR_RIGHT");
	AWMTooltip:SetText("AWMTooltip");
	AWMTooltip:AddLine("Must be show to",1,1,1);
	AWMTooltip:AddLine("this featur working.",1,1,1);
	AWMTooltip:Show()

	AWMTooltip:SetSpell(i,caster)
	local t = AWMTooltipTextLeft2:GetText()
	
	AWMTooltip:Hide()
	if (string.find(t,'(%d+) Rage')) then
		t = string.gsub(t,'(%d+) Rage','%1')
		return tonumber(t)
	else
		return 0
	end
end

AWMSendAddonMessage = SendAddonMessage
function SendAddonMessage(arg1,arg2,arg3)--???
	--arg2 = string.gsub(arg2,'|c........|Hplayer:([^|]*)|h([^|]*)|h|r','%2')
	--arg2 = string.gsub(arg2,'\r',' ')
	AWMSendAddonMessage(arg1,arg2,arg3)
end

function AWMParseAddonMessage(arg1)
	return arg1
end