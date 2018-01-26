function AWMMissingBuffSearchMenuOnLoad()
	AWMMissingBuffSearchMenu.buffframes = {}
	AWMMissingBuffSearchMenu.ClassEnabled = {}
	
	local classes = ({'Warrior','Mage','Rogue','Druid','Hunter','Shaman','Priest','Warlock','Paladin'})
	
	for i in classes do
		AWMMissingBuffSearchMenu.ClassEnabled[classes[i]] = true
	end
	
	for i = 1,9 do
		id = classes[i]
		f = CreateFrame('Button','AWMMissingBuffSearchMenu'..id..'Frame',this);
		f.id = id
		
		f:SetFrameStrata('HIGH')
		f:SetWidth(24)
		f:SetHeight(24)
		
		t = f:CreateTexture('AWMMissingBuffSearchMenu'..id..'Texture','BACKGROUND')
		t:SetTexture('Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes')
		
		t:SetAllPoints(f)
		t:SetWidth(24)
		t:SetHeight(24)
		c = AWMClassCoords[string.upper(classes[i])]
		t:SetTexCoord(c[1],c[2],c[3],c[4])
		f.t = t
		
		f:SetPoint('TOPLEFT',i*26+8,-124,'TOPLEFT')
		
		f:SetScript('OnMouseDown',function()
			AWMMissingBuffSearchMenu.ClassEnabled[this.id] = not AWMMissingBuffSearchMenu.ClassEnabled[this.id]
			this:SetAlpha(1.3-this:GetAlpha())
			AWMMissingBuffSearchBuffClick()
		end)
		f:SetScript('OnEnter',AWMMissingBuffSearchBuffClick)
		
		f:SetScript('OnLeave',function()
			GameTooltip:Hide()
		end)
	end
	
	for i = 1,50 do
		f = CreateFrame('Button','AWMMissingBuffSearchMenuBuff'..i,this);
		
		f:SetFrameStrata('HIGH')
		f:SetWidth(26)
		f:SetHeight(26)
		
		t = f:CreateTexture('AWMMissingBuffSearchMenuBuff'..i,'BACKGROUND')
		t:SetAllPoints(f)
		t:SetWidth(26)
		f:SetWidth(26)
		f.t = t
		
		j = i
		h = 0
		while j > 8 do
			j = j - 8
			h = h + 1
		end
		f:SetPoint('TOPLEFT',5+j*29,-198 - h*29,'TOPLEFT')
		f:Hide()

		AWMMissingBuffSearchMenu.buffframes[f:GetName()] = f
	end
end

function AWMMissingBuffSearchBuffClick()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	GameTooltip:SetText(this.id);
	if (AWMMissingBuffSearchMenu.ClassEnabled[this.id]) then
		tmp = 'Included'
	else
		tmp = 'Excluded'
	end
	GameTooltip:AddLine(tmp, 1,1,1)
	GameTooltip:Show()
end