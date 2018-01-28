ActionBarSaverDB = {}
-- {type, name, rank/data}
local spellNames = {}
--{macroName, macroData}
local macroNames = {}
--{macroName, macroData}
local superMacroNames = {}
--{itemName}
local itemNames = {}

function ABS_SaveBars(save)
	spellNames = {}
	macroNames = {}
	superMacroNames = {}
	itemNames = {}
	local tooltip=getglobal("ABS_Tooltip");
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	for id=1,120 do
		local name = ""
		local rank = ""
		if GetActionTexture(id) then
			tooltip:SetAction(id)
			if GetActionText(id) then
				name = GetActionText(id)
				for i=1, 36 do
					local macroName, icon, macro = GetMacroInfo(i)
					if macroName == name then
						macroNames[id] = {macroName, macro}
						--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..macroName);
					end
				end
				if GetOrderedSuperMacroInfo then
					for i=1, 30 do
						local macroName, icon, macro = GetOrderedSuperMacroInfo( i )
						if macroName == name then
							superMacroNames[id] = {macroName, macro}
							--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..macroName);
						end
					end
				end
			else
				if (getglobal("ABS_TooltipTextRight1"):IsVisible()) then
					name = getglobal("ABS_TooltipTextLeft1"):GetText()
					rank = getglobal("ABS_TooltipTextRight1"):GetText()
					
					if not string.find(rank,"Rank") then
						spellNames[id] = {name, 0}  
						--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..name.." 0");
					else
						spellNames[id] = {name, rank}
						--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..name.." "..rank);
					end
				elseif (getglobal("ABS_TooltipTextLeft1"):GetText()) then
					name = getglobal("ABS_TooltipTextLeft1"):GetText()
					if ABS_isSpell(name) then
						spellNames[id] = {name, 0}
						--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..name.." 0");
					else
						itemNames[id] = {name}
						--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..name);
					end
				end
				
			end
		else
			spellNames[id] = nil
		end
	end
	if not ActionBarSaverDB then ActionBarSaverDB = {} end
	ActionBarSaverDB[save] = {}
	ActionBarSaverDB[save]["spellNames"] = spellNames
	ActionBarSaverDB[save]["macroNames"] = macroNames
	ActionBarSaverDB[save]["superMacroNames"] = superMacroNames
	ActionBarSaverDB[save]["itemNames"] = itemNames
end

function ABS_isSpell(name)
	i = 1
	while GetSpellName(i, BOOKTYPE_SPELL) do
		spellNamei, spellRank = GetSpellName(i, BOOKTYPE_SPELL);
		if name == spellNamei then return true end
		i = i + 1
	end
	return false
end

function ABS_LoadBars(save)
	if ActionBarSaverDB[save] then
		for i=1,120 do
			PickupAction(i)
			ClearCursor()
		end
		spellNames = ActionBarSaverDB[save]["spellNames"]
		macroNames = ActionBarSaverDB[save]["macroNames"]
		superMacroNames = ActionBarSaverDB[save]["superMacroNames"]
		itemNames = ActionBarSaverDB[save]["itemNames"]
		for i=1,120 do
			if spellNames[i] then
				ABS_RestoreSpell(i)
			elseif macroNames[i] then
				ABS_RestoreMacro(i)
			elseif superMacroNames[i] and GetOrderedSuperMacroInfo then
				ABS_RestoreSuperMacro(i)
			elseif itemNames[i] then
				ABS_RestoreItem(i)
			end
		end
	end
end

function ABS_RestoreSpell(id)
	i = 1
	while GetSpellName(i, BOOKTYPE_SPELL) do
		spellNamei, spellRank = GetSpellName(i, BOOKTYPE_SPELL);
		if spellNames[id] then
			if spellNamei == spellNames[id][1] and (spellRank == spellNames[id][2] or spellNames[id][2] == 0) then
				--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..spellNames[id][1].." "..spellNames[id][2] );
				PickupSpell(i, BOOKTYPE_SPELL)
				PlaceAction(id)
				return
			end
		end
		i = i + 1
	end
	DEFAULT_CHAT_FRAME:AddMessage( "Failed to restore spell: "..spellNames[id][1].." to ActionButton "..id );
end

function ABS_RestoreMacro(id)
	for i=1, 36 do
		local macroName, icon, macro = GetMacroInfo(i)
		if macroNames[id] then
			if macroName == macroNames[id][1] and macro == macroNames[id][2]then
				--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..macroNames[id][1] );
				PickupMacro(i)
				PlaceAction(id)
				return
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage( "Failed to restore macro: "..macroNames[id][1].." to ActionButton "..id );
end

function ABS_RestoreSuperMacro(id)
	for i=1, 30 do
		local macroName, icon, macro = GetOrderedSuperMacroInfo(i)
		if superMacroNames[id] then
			if macroName == superMacroNames[id][1] and macro == superMacroNames[id][2]then
				--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..superMacroNames[id][1] );
				PickupMacro(i, superMacroNames[id][1])
				PlaceAction(id)
				return
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage( "Failed to restore supermacro: "..superMacroNames[id][1].." to ActionButton "..id );
end

function ABS_RestoreItem(id)
	local itemName, link
	for i = 0,NUM_BAG_FRAMES do
		for j = 1,MAX_CONTAINER_ITEMS do
			link = GetContainerItemLink(i,j);
			if ( link ) then
				itemName = gsub(link,"^.*%[(.*)%].*$","%1");
				if itemNames[id] then
					if itemName == itemNames[id][1] then
						--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..itemNames[id][1].." bag: "..i.." slot: "..j);
						PickupContainerItem(i,j);
						PlaceAction(id)
						return
					end
				end
			end
		end
	end
	for i = 1,23 do
		link = GetInventoryItemLink("player",i);
		if ( link ) then
			itemName = gsub(link,"^.*%[(.*)%].*$","%1");
			if itemNames[id] then
				if itemName == itemNames[id][1] then
					--DEFAULT_CHAT_FRAME:AddMessage( id.." = "..itemNames[id][1].." bag: "..i.." slot: "..j);
					PickupInventoryItem(i);
					PlaceAction(id)
					return
				end
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage( "Failed to restore item: "..itemNames[id][1].." to ActionButton "..id );
end

SLASH_ABS1 = "/abs"
SlashCmdList["ABS"] = function(msg)
	msg = msg or ""
	if msg == "" then
		DEFAULT_CHAT_FRAME:AddMessage("/abs save <profile> - Saves your current action bar setup under the given profile.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs load <profile> - Changes your action bars to the passed profile.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs list - Lists all saved profiles.")
	elseif msg == "list" then
		DEFAULT_CHAT_FRAME:AddMessage( "Saved ActionBars:" );
		for k, v in pairs(ActionBarSaverDB) do
			DEFAULT_CHAT_FRAME:AddMessage( k );
		end
	else
		local _,_,cmd, arg = string.find(msg,"(%a+)%s(.*)")
		cmd = string.lower(cmd or "")
		arg = string.lower(arg or "")
		cmd = string.gsub(cmd, "%s+", "")
		arg = string.gsub(arg, "%s+", "")
		
		if( cmd == "save" and arg ~= "" ) then
			DEFAULT_CHAT_FRAME:AddMessage( "Saving current actionbars as "..arg );
			ABS_SaveBars(arg)
		elseif( cmd == "load" and arg ~= "" ) then
			if ActionBarSaverDB[arg] then
				DEFAULT_CHAT_FRAME:AddMessage( "Loading "..arg );
				ABS_LoadBars(arg)
			else
				DEFAULT_CHAT_FRAME:AddMessage( "No save named "..arg.." found." );
			end
		end
	end
end