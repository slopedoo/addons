function AWMCustomRaidSearchMenuOnLoad()
	AWMCustomRaidSearchMenu.activemacro = 1
	if (AWMCustomSearchMacros == nil) then
		AWMCustomSearchMacros = {}
		
		AWMResetDefaultMacros()

	end
	
	AWMCustomRaidSearchMenu.buffframes = {}
	
	for i in AWMListOfTextures do
		f = CreateFrame('Button',nil,AWMCustomRaidSearchMenuSelectIconFrame);
		
		f:SetFrameStrata('HIGH')
		f:SetWidth(26)
		f:SetHeight(26)
		
		t = f:CreateTexture(nil,'BACKGROUND')
		t:SetTexture('Interface\\Icons\\'..AWMListOfTextures[i])
		f.texture = 'Interface\\Icons\\'..AWMListOfTextures[i]
		t:SetAllPoints(f)
		t:SetWidth(24)
		t:SetHeight(24)

		j = i
		h = 0
		while j > 5 do
			j = j - 5
			h = h + 1
		end
		f:SetPoint('TOPLEFT',(j-1)*29,(h)*-29,'TOPLEFT')
		
		f:SetScript('OnMouseDown',function()
			if (arg1 == 'LeftButton') then
				AWMCustomSearchMacros[AWMCustomRaidSearchMenu.activemacro]['texture'] = this.texture
				f = getglobal('AWMCustomRaidSearchMenuBuff'..AWMCustomRaidSearchMenu.activemacro)
				f.t:SetTexture(this.texture)
			end
		end)
	end
	
	for i = 1,32 do
		if (AWMCustomSearchMacros[i] == nil) then
			AWMCustomSearchMacros[i] = {texture='Interface\\Icons\\INV_Fabric_Purple_01', name='', text=''}
		end
		f = CreateFrame('Button','AWMCustomRaidSearchMenuBuff'..i,AWMCustomRaidSearchMenu);
		
		f:SetFrameStrata('HIGH')
		f:SetWidth(26)
		f:SetHeight(26)
		
		t = f:CreateTexture('AWMCustomRaidSearchMenuBuff'..i,'BACKGROUND')
		t:SetTexture(AWMCustomSearchMacros[i]['texture'])
		t:SetAllPoints(f)
		t:SetWidth(26)
		f:SetWidth(26)
		f.t = t
		f.id = i
		
		j = i
		h = 0
		while j > 8 do
			j = j - 8
			h = h + 1
		end
		f:SetPoint('TOPLEFT',5+j*29,-225 - h*29,'TOPLEFT')
		
		f:SetScript('OnEnter',function()
			GameTooltip:SetOwner(this,'ANCHOR_LEFT')
			this.name  = AWMCustomSearchMacros[this.id]['name']
			this.groups = SortUnitsToGroups(CustomRaidSearch(AWMCustomSearchMacros[this.id]['text']))
			this.classes = AWMClasses
			GameTooltip:SetText(this.name)
			GameTooltip:AddDoubleLine('Left Click to edit.','Right Click to post.', 1,0,0, 1,0,0)
			AddGroupUnitsToTooltip(this.groups)
			
			GameTooltip:AddDoubleLine('Left Click to edit.','Right Click to post.', 1,0,0, 1,0,0)
			GameTooltip:Show()
		end);
		f:SetScript('OnLeave',function()
			GameTooltip:Hide()
		end)
		f:SetScript('OnMouseDown',function()
			if (arg1 == 'LeftButton') then
				this:GetParent().activemacro = this.id
				AWMCustomRaidSearchMenuTextBoxName:SetText(AWMCustomSearchMacros[this.id]['name'])
				AWMCustomRaidSearchMenuTextBoxText:SetText(AWMCustomSearchMacros[this.id]['text'])
				AWMCustomRaidSearchMenuTextBoxTexture:SetTexture(AWMCustomSearchMacros[this.id]['texture'])
			elseif (arg1 == 'RightButton') then
				RaidSearchMatchOnMouseDown()
			end
		end)
		--f:Hide()
		AWMCustomRaidSearchMenuTextBoxName:SetText(AWMCustomSearchMacros[AWMCustomRaidSearchMenu.activemacro]['name'])
		AWMCustomRaidSearchMenuTextBoxText:SetText(AWMCustomSearchMacros[AWMCustomRaidSearchMenu.activemacro]['text'])
		AWMCustomRaidSearchMenuTextBoxTexture:SetTexture(AWMCustomSearchMacros[AWMCustomRaidSearchMenu.activemacro]['texture'])
		
		AWMCustomRaidSearchMenu.buffframes[f:GetName()] = f
	end
end

AWMCustomSearchLoadFrame = CreateFrame('Frame')
AWMCustomSearchLoadFrame:SetScript('OnEvent',function()
	if (arg1 == 'AnaronsWoWMod') then
		AWMCustomRaidSearchMenuOnLoad()
	end
end)
AWMCustomSearchLoadFrame:RegisterEvent('ADDON_LOADED')

function AWMResetDefaultMacros()
	AWMCustomSearchMacros[25] = {texture='Interface\\Icons\\Ability_Druid_Cower',					name='Deserters:',									text='{buff=Deserter} or {zone=warsong gulch}'}
	
	AWMCustomSearchMacros[4]  = {texture='Interface\\Icons\\INV_Potion_25',							name='Without [Greater Arcane Elixir]:',			text='!{buff=Greater Arcane Elixir} and {class=Mage,Warlock}'}
	AWMCustomSearchMacros[12] = {texture='Interface\\Icons\\Spell_Shadow_SoulGem',					name='Soulstones:',									text='{buff=Soulstone Resurrection}'}
	AWMCustomSearchMacros[20] = {texture='Interface\\Icons\\Spell_Holy_WordFortitude',				name='Mana users without spirit:',					text='!{buff: spirit} and !{class=warrior,rogue}'}
	AWMCustomSearchMacros[28] = {texture='Interface\\Icons\\Ability_Druid_Cower',					name='Deserters',									text='{buff=Deserter}'}
			
	AWMCustomSearchMacros[5]  = {texture='Interface\\Icons\\Spell_Fire_FireArmor',					name='Players without Fire Prot Potion:',			text='!{buff=fire protection}'}
	AWMCustomSearchMacros[13] = {texture='Interface\\Icons\\INV_Potion_23',							name='Players without Shadow Prot Potion:',			text='!{buff=shadow protection}'}
	AWMCustomSearchMacros[21] = {texture='Interface\\Icons\\INV_Potion_20',							name='Players without Frost Prot Potion:',			text='!{buff=frost protection}'}
	AWMCustomSearchMacros[29] = {texture='Interface\\Icons\\Spell_Nature_SpiritArmor',				name='Players without Nature Prot Potion:',			text='!{buff=nature protection}'}

	
	AWMCustomSearchMacros[6]  = {texture='Interface\\Icons\\Spell_Holy_DispelMagic',				name='Paladins without aura:',						text='!{buff: aura} and {class= paladin}'}
	AWMCustomSearchMacros[14] = {texture='Interface\\Icons\\Spell_Holy_ArcaneIntellect',			name='Mana users without mage intellect:',			text='!{buff: arcane} and {power=mana}'}
	AWMCustomSearchMacros[22] = {texture='Interface\\Icons\\Spell_Nature_Regeneration',				name='Players without Druid buff:',					text='!{buff: of the wild}'}
	AWMCustomSearchMacros[30] = {texture='Interface\\Icons\\Spell_Holy_PrayerOfFortitude',			name='Players without Fortitude:',					text='!{buff: fortitude}'}
		
	AWMCustomSearchMacros[7]  = {texture='Interface\\Icons\\Spell_Holy_GreaterBlessingOfKings',		name='Melees without Might:',						text='{class= warrior, rogue} and !{buff: blessing of might}'}
	AWMCustomSearchMacros[15] = {texture='Interface\\Icons\\Spell_Holy_GreaterBlessingOfSalvation',	name='Casters without Salvation:',					text='{class: warlock, mage} and !{buff: blessing of salvation}'}
	AWMCustomSearchMacros[23] = {texture='Interface\\Icons\\Spell_Holy_GreaterBlessingOfWisdom',	name='Healers and hunters Without Wisdom:',			text='{class= druid, hunter, paladin, priest, shaman} and !{buff: blessing of wisdom}'}
	AWMCustomSearchMacros[31] = {texture='Interface\\Icons\\Spell_Magic_GreaterBlessingOfKings',	name='Players without Kings:',						text='!{buff: blessing of kings}'}
	
	AWMCustomSearchMacros[8]  = {texture='Interface\\Icons\\INV_Potion_62',							name='Melees without Titans flask:',				text='{class= warrior, rogue} and !{buff= flask of the titans}'}
	AWMCustomSearchMacros[16] = {texture='Interface\\Icons\\INV_Potion_41',							name='Casters without Supreme flask:',				text='{class= warlock, mage} and !{buff= supreme power}'}
	AWMCustomSearchMacros[24] = {texture='Interface\\Icons\\INV_Potion_97',							name='Healers and hunters Without Wisdom flask:',	text='{class= druid, hunter, paladin, priest, shaman} and !{buff= distilled wisdom}'}
	AWMCustomSearchMacros[32] = {texture='Interface\\Icons\\INV_Drink_07',							name='Players without correct flask:',				text='{class= warrior, rogue} and !{buff=flask of the titans} or ({class= warlock, mage} and !{buff= supreme power}) or ({class= druid, hunter, paladin, priest, shaman} and !{buff=distilled wisdom})'}
end

-- Reload UI
SlashCmdList['RESET_SEARCH_MACROS_COMMAND'] = function(Flag)
	AWMResetDefaultMacros()
	ReloadUI()
end
SLASH_RESET_SEARCH_MACROS_COMMAND1 = '/resetsearchmacros';
