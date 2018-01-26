AWMSummonOutput = {}

local SRChannel = 'RAID'

function AWMSummonMenuOnLoad()
	local classes = AWMClasses

	for id = 1,40 do
		f = CreateFrame('Button','AWMSummonMenu'..id..'Frame',this);
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
		c = AWMClassCoords[string.upper('Warrior')]
		t:SetTexCoord(c[1],c[2],c[3],c[4])
		f.t = t
		
		i = id
		j = 0
		while i > 5 do
			i = i - 5
			j = j + 1
		end
		
		f:SetPoint('TOPLEFT',i*45-6,-90-j*33,'TOPLEFT')
		
		f:SetScript('OnEnter',function()
			GameTooltip:SetOwner(this, 'ANCHOR_LEFT');
			GameTooltip:SetText(this.name);
			if (AWMSummonOutput[this.name] == '\124cffFF0000') then
				GameTooltip:AddLine('Click to target '..this.name,1,1,0)
			else
				GameTooltip:AddLine(this.name..' is being summoned.',1,1,0)
				GameTooltip:AddLine('by someone.',1,1,0)
			end
			GameTooltip:AddLine('Shift click to remove',1,0.5,0)
			GameTooltip:AddLine(this.name..' from list.',1,0.5,0)
			
			GameTooltip:Show()
		end)
		
		f:SetScript('OnLeave',function()
			GameTooltip:Hide()
		end)
		
		f:SetScript('OnMouseDown',function ()
			if (IsShiftKeyDown()) then
				SendAddonMessage('AWMSummon','SUMMONED'..this.name,'RAID')
			else
				TargetByName(this.name)
				GameTooltip:SetOwner(this, 'ANCHOR_LEFT');
				GameTooltip:SetText(this.name);
				GameTooltip:AddLine('Ritual of Summoning has',1,1,0)
				GameTooltip:AddLine('to be casted manually.',1,1,0)
				GameTooltip:AddLine('Shift click to remove',1,0.5,0)
				GameTooltip:AddLine(this.name..' from list.',1,0.5,0)

				GameTooltip:Show()
			end
		end)
		f:Hide()
	end
end

function AWMSummonOnUpdate()
	local i = 1
	for name in AWMSummonOutput do
		f = getglobal(this:GetName()..i..'Frame')
		f.name = name
		
		f.s:SetText(AWMSummonOutput[name]..string.sub(f.name,1,5))
		f:Show()
		i = i+1
		
	end
	for i = i,40 do
		frame = getglobal(this:GetName()..i..'Frame')
		frame:Hide()
	end 
end

function AWMRequestSummon()
	SendAddonMessage('AWMSummon','REQUEST','RAID')
end


function AWMSummonGetMessage(Key, Message, Channel, Sender)
	if (Key == 'AWMSummon') then
		if (Message == 'REQUEST') then
			AWMSummonOutput[Sender] = '\124cffFF0000'
		elseif (string.sub(Message,1,8) == 'PROGRESS') then
			Sender = string.sub(Message,9)
			if (AWMSummonOutput[Sender]) then
				AWMSummonOutput[Sender] = '\124cff00FF00'
			end
		elseif (string.sub(Message,1,8) == 'SUMMONED') then
			Sender = string.sub(Message,9)
			AWMSummonOutput[Sender] = nil
		end
	end
end

CreateFrame('Frame', 'AWM_SUMMON_FRAME');
AWM_SUMMON_FRAME:SetScript('OnEvent', function()
	AWMSummonGetMessage(arg1,arg2,arg3,arg4)
end);
AWM_SUMMON_FRAME:RegisterEvent('CHAT_MSG_ADDON');


AWMSummonCastSpellByName = CastSpellByName
function CastSpellByName(arg1,arg2)
	if (arg1 == 'Ritual of Summoning') then
		if (UnitName('target')) then
			SendAddonMessage('AWMSummon','PROGRESS'..UnitName('target'),'RAID')
		end
	end
	AWMSummonCastSpellByName(arg1,arg2)
end

AWMSummonCastSpell = CastSpell
function CastSpell(arg1,arg2)
	if (GetSpellName(arg1,arg2) == 'Ritual of Summoning') then
		if (UnitName('target')) then
			SendAddonMessage('AWMSummon','PROGRESS'..UnitName('target'),'RAID')
		end
	end
	AWMSummonCastSpell(arg1,arg2)
end

AWMSummonUseAction = UseAction
function UseAction(arg1,arg2,arg3)
	if (GetActionName(arg1) == 'Ritual of Summoning') then
		if (UnitName('target')) then
			SendAddonMessage('AWMSummon','PROGRESS'..UnitName('target'),'RAID')
		end
	end
	AWMSummonUseAction(arg1,arg2,arg3)
end