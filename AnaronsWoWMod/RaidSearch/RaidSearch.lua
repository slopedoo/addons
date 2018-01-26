AWMMissingBuffActive = false

AWMBuffRegister = {}
AWMBuffRegisterTime = 0

function macro(x,y,z,mode)
	return string.gsub(z,'(.*)%{%s*'..x..'%s*'..mode..'%s*([^%}]*)%s*%}(.*)',y)
end

function CustomRaidSearch(input)
	oldinput = input..'1'
	while oldinput ~= input do
		oldinput = input

--		!, || and && is not valid syntax???
		input = string.gsub(input, '%!',   ' not ')
		input = string.gsub(input, '%|%|%|%|', ' or ' )
		input = string.gsub(input, '%&%&', ' and ')
		
--		is, isnot should be legit
		input = string.gsub(input, ' isnot ', '!=')
		input = string.gsub(input, ' is ',    '==')
		
		for str,par in {Buff='target',Name='target',Class='target',Group='target',Health='target',Power='target',Zone='zone',Guild='target'} do
			input = macro(string.lower(str), '%1 AWMCustom'..str..'Macro('..par..',"%2",true) %3',input,'=')
			input = macro(string.lower(str), '%1 AWMCustom'..str..'Macro('..par..',"%2",false) %3',input,':')
		end
		
--		You only need one white space
		input = string.gsub(input, '[\n%s]+',   ' ')		
	end
	if input == ' ' or input == '' then
		input = 'false'
	end
	passedunits = {}
	for i = 1,40 do
		target = 'raid'..i
		if (UnitName(target)) then
			hp = UnitHealth(target)
			mp = UnitMana(target)
			power  = mp
			mana   = mp * ((UnitPowerType(target)==0) and 1 or 0 )
			rage   = mp * ((UnitPowerType(target)==1) and 1 or 0 )
			energy = mp * ((UnitPowerType(target)==3) and 1 or 0 )
			guild  = GetGuildInfo(target)
			
			name,_,group,level,class,CLASS,zone,online,dead = GetRaidRosterInfo(i)
			
			alive = not dead
			online = not (not online)
			if (name) then
				RunScript('passed = '..input)
					if passed then
					passedunits[target] = true
				end
			end
		end
	end
	return passedunits
end

function RaidUnitHasBuff(target,buff)
	local buffs = GetRaidBuffs()
	local buff = ToUnderScore(string.lower(buff))
	if (buffs[buff]) then
		if (buffs[buff]['units'][target]) then
			return buffs[buff]['units'][target]
		end
	end
	return false
end

function RaidUnitHasBuffContaining(target,buff)
	local buffs = GetRaidBuffs()
	local buff = ToUnderScore(string.lower(buff))
	for s in buffs do
		if string.find(s,buff) then
			if (buffs[s]['units'][target]) then
				return buffs[s]['units'][target]
			end
		end
	end
	return false
end

function BuffSearch(frame,Text,mode)
	local buffs = {}
	BUFFS = GetRaidBuffs()
	local classes = ''
	for class in frame.ClassEnabled do
    	if (frame.ClassEnabled[class]) then
    		if (classes ~= '') then
    			classes = classes..', '
    		end
    		classes = classes..class
		end
	end
	
	text = ToUnderScore(string.lower(Text))
	
	if (BUFFS[text] == nil) then
		kws = {text}
	else
		kws = {}
	end
	
	for i in BUFFS do
		if (string.find(i,text)) then
			table.insert(kws,i)
			if mode then str = ''
			else str ='!' end
			
			buffs[i] = {name = BUFFS[i]['name'], texture = BUFFS[i]['texture'], units = CustomRaidSearch(str..'{buff='..BUFFS[i]['name']..'}&&{class='..classes..'}&&online')}
		end
	end
	
	if (buffs[text] == nil) then
		buffs[text] = {name = 'Buff containing "'..Text..'"', texture = 'Interface\\Icons\\Spell_Shadow_SpectralSight'}
		if mode then str = ''
		else str ='!' end
		buffs[text]['units'] = CustomRaidSearch(str..'{buff:'..text..'}&&{class='..classes..'}&&online')
	end
	
	num2 = 1	
	for num in kws do
		num2 = num+1
		i = kws[num]
   		f = frame.buffframes[frame:GetName()..'Buff'..num]
   		t = f.t
   		
   		t:SetTexture(buffs[i]['texture'])
   		f.texture = t
   		f.groups = SortUnitsToGroups(buffs[i]['units'])
		
		local bool = true
    	for c in frame.ClassEnabled do
    		bool = bool and frame.ClassEnabled[c]
    	end
    	if bool then
    		msg = 'Players'
    	else
    		msg = classes
    	end
    	
		if (mode) then
   			f.name = msg..' with '..buffs[i]['name']
		else
   			f.name = msg..' without '..buffs[i]['name']			
		end
   		f.mode = mode
   		f.classes = frame.ClassEnabled
   		f:SetScript('OnEnter',RaidSearchMatchOnEnter)
   		f:SetScript('OnLeave',RaidSearchMatchOnLeave)
   		f:SetScript('OnMouseDown',RaidSearchMatchOnMouseDown)
   		f:Show()
	end
	for num = num2,50 do
		f = frame.buffframes[frame:GetName()..'Buff'..num]
		f:SetScript('OnEnter',nil)
		f:SetScript('OnLeave',nil)
		f:Hide()
	end
end

function RaidSearchMatchOnMouseDown()
	local msg = this.name
	str = ''
	for i in this.groups do
		for player in this.groups[i] do
    		if (str ~= '') then
    			str = str..', '
    		end
    		str = str..AddClassColor(this.groups[i][player])
		end
	end
	if (str == '') then
		str = 'None'
	end
	if IsRaidLeader() then
		SendAddonMessage('AWMMessage',msg..'\r'..str..'.','RAID')
	end
	str = ''
	for i in this.groups do
		for player in this.groups[i] do
    		if (str ~= '') then
    			str = str..', '
    		end
    		str = str..this.groups[i][player][1]
		end
	end
	if (str == '') then
		str = 'None'
	end
	if IsRaidLeader() then
		SendChatMessage('::AWM:: '..msg..' '..str..'.','RAID',nil,nil)--???
	end
end


function RaidSearchMatchOnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	GameTooltip:SetText(this.name);
	AddGroupUnitsToTooltip(this.groups)
	GameTooltip:Show()
end

function RaidSearchMatchOnLeave()
	GameTooltip:Hide()
end

function GetRaidBuffs()
	if (GetTime() - AWMBuffRegisterTime > 1) then
		local buffs = {}
		for i = 1,40 do
			tar = 'raid'..i
			if UnitName(tar) then
				j = 1
				buff = true
				while buff do
					buff = GetBuffName(tar,j)
					if (buff) then
						while (string.sub(buff,string.len(buff)) == ' ') do
							buff = string.sub(buff,1,string.len(buff)-1)
						end
						
						buffid = ToUnderScore(string.lower(buff))
						if (buffs[buffid] == nil) then
							buffs[buffid] = {name = buff, texture = UnitBuff(tar,j), units = {}}
						end
						buffs[buffid]['units'][tar] = true
					end
					j = j+1
				end
				
				j = 1
				buff = true
				while buff do
					buff = GetDebuffName(tar,j)
					if (buff) then
						while (string.sub(buff,string.len(buff)) == ' ') do
							buff = string.sub(buff,1,string.len(buff)-1)
						end
						
						buffid = ToUnderScore(string.lower(buff))
						if (buffs[buffid] == nil) then
							buffs[buffid] = {name = buff, texture = UnitDebuff(tar,j), units = {}}
						end
						buffs[buffid]['units'][tar] = true
					end
					j = j+1
				end
			end
		end
		
		AWMBuffRegister = buffs
		AWMBuffRegisterTime = GetTime()
	end
	return AWMBuffRegister
end

function GetDebuffName(target,index)
	if (UnitDebuff(target, index)) then
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
--???
function AWMCustomBuffMacro (tar,str,exact)
	for s in commaSplit(string.lower(str)) do
		if (exact) then
			if RaidUnitHasBuff(tar,s) then
				return true
			end
		else
			if RaidUnitHasBuffContaining(tar,s) then
				return true
			end
		end
	end
	return false
end

function AWMCustomNameMacro (tar,str,exact)
	for s in commaSplit(string.lower(str)) do
		t = string.lower(UnitName(tar))
		if (t == s or (not exact and string.find(t,s))) then
			return true
		end
	end
	return false
end

function AWMCustomGroupMacro (tar,str,exact)
	for s in commaSplit(string.lower(str)) do
		t = string.lower(UnitGroup(tar))
		if (t == s or (not exact and string.find(t,s))) then
			return true
		end
	end
	return false
end

function AWMCustomClassMacro (tar,str,exact)
	for s in commaSplit(string.lower(str)) do
		t = string.lower(UnitClass(tar))
		if (t == s or (not exact and string.find(t,s))) then
			return true
		end
	end
	return false
end
function AWMCustomHealthMacro (tar,str,exact)
	local l = commaSplit(string.lower(str))
	if (table.getn(l) == 1) then
		if (UnitHealth(tar) > l[1]) then
			return true
		end
	elseif (table.getn(l) == 2) then
		if (UnitHealth(tar) > l[1] and UnitHealth(tar) < l[2]) then
			return true
		end
	end
	return false
end

function AWMCustomPowerMacro (tar,str,exact)
	for s in commaSplit(string.lower(str)) do
		t = ({'mana','rage','','energy'})[UnitPowerType(tar)+1]
		if (t == s or (not exact and string.find(t,s))) then
			return true
		end
	end
	return false
end

function AWMCustomZoneMacro (zone,str,exact)
	if (zone == nil) then
		return false
	end
	for s in commaSplit(string.lower(str)) do
		t = string.lower(zone)
		if (t == s or (not exact and string.find(t,s))) then
			return true
		end
	end
	return false
end

function AWMCustomGuildMacro (tar,str,exact)
	for s in commaSplit(string.lower(str)) do
		t = GetGuildInfo(tar) or ''
		if (t == s or (not exact and string.find(t,s))) then
			return true
		end
	end
	return false
end