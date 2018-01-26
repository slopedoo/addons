AWMGearCheckOutput = {}

local GCChannel = 'RAID'

function AWMGearCheckMenuOnLoad()
	local classes = AWMClasses

	for id = 1,40 do
		f = CreateFrame('Button','AWMGearCheckMenu'..id..'Frame',this);
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
			for item in this.gear do
				if (item ~= 'Average Durability') then
					GameTooltip:AddDoubleLine(item, this.gear[item][1])
				end
			end
			GameTooltip:AddDoubleLine('Average Durability', this.gear['Average Durability'][1]..'%')
			GameTooltip:Show()
		end)
		
		f:SetScript('OnLeave',function()
			GameTooltip:Hide()
		end)
		f:Hide()
	end
end

function AWMGearCheckOnUpdate()
	local i = 1
	for name in AWMGearCheckOutput do
		f = getglobal(this:GetName()..i..'Frame')
		f.name = name
		f.gear = AWMGearCheckOutput[name]
		
		--if (string.len(f.name) > 6) then
		--end
		
		if (f.gear['Average Durability'][1] < 1) then
			color = '\124cffFF3300'
		elseif (f.gear['Average Durability'][1] < 10) then
			color = '\124cff999900'
		else
			color = '\124cff99FF99'
		end
		
		f.s:SetText(color..string.sub(f.name,1,5)..'\n'..f.gear['Average Durability'][1]..'%')
		f:Show()
		i = i+1
		
	end
	for i = i,40 do
		frame = getglobal(this:GetName()..i..'Frame')
		frame:Hide()
	end 
end

function DoGearCheck()
	ShowUIPanel(AWMMainMenu)
	ShowUIPanel(AWMGearCheckMenu)
	SendAddonMessage('AWMGearCheck','REQUEST','RAID')
	SendAddonMessage('AWMGearCheck','REQUEST','BATTLEGROUND')
	AWMGearCheckOutput = {}
end


function AWMGCGetMessage(Key, Message, Channel, Sender)
	if (Key == 'AWMGearCheck') then
		parts = codeSplit(Message)
		if (parts[1] == 'REQUEST') then
    		msg = 'REPLY'
    		for slot = 1,18 do
    			local cur,max = GetItemDurability(slot)
    			link = GetInventoryItemLink('player', slot)
    			if link then
    				msg = msg..'$$'..link..'$$'..cur..'$$'..max
    			end
    		end
    		SendAddonMessage('AWMGearCheck',msg,Channel);
		elseif (parts[1] == 'REPLY') then
			tmp = {}
			
			totval = 0
			totnum = 0
			
			for i = 2,table.getn(parts),3 do
				tmp[parts[i]] = {parts[i+1],parts[i+2]}
				
				if (parts[i+2] ~= 'NaN') then
					totval = totval + parts[i+2]
					totnum = totnum + 1
				end
			end
			tmp['Average Durability'] = {(math.floor(totval/totnum*1000)/10),''}
			AWMGearCheckOutput[Sender] = tmp
		end
	end
end

CreateFrame('Frame', 'AWM_GEAR_CHECK_FRAME');
AWM_GEAR_CHECK_FRAME:SetScript('OnEvent', function()
	AWMGCGetMessage(arg1,arg2,arg3,arg4)
end);
AWM_GEAR_CHECK_FRAME:RegisterEvent('CHAT_MSG_ADDON');

function GetItemDurability(index)
	AWMTooltip:SetOwner(Minimap, 'ANCHOR_RIGHT');
	AWMTooltip:SetText('AWMTooltip');
	AWMTooltip:AddLine('Must be show to',1,1,1);
	AWMTooltip:AddLine('this featur working.',1,1,1);
	AWMTooltip:Show()
	
	AWMTooltip:SetInventoryItem('player',index)
	i = 1
	str = true
	while str do
		str = getglobal('AWMTooltipTextLeft'..i):GetText()
		if (str) then
			if (string.find(str,'Durability %d+ / %d+.*')) then
				AWMTooltip:Hide()
				str = string.sub(str,12)
				RunScript('percent = '..str)
				return str,percent
			end
		end
		i = i+1
	end
	AWMTooltip:Hide()
	return ' ','NaN'
end