ConsoleExec('profanityFilter 0')

AWMCookiesCastSpellByName = CastSpellByName

function CastSpellByName(spell)
	target = string.gsub(spell,'%[target%s*=%s*(%a+)%]%s?(.*)','%1')
	if (target ~= spell) then
		spell = string.gsub(spell,'%[target%s*=%s*(%a+)%]%s?(.*)','%2')
		TargetByName(target)
		CastSpellByName(spell)
		TargetLastTarget()
	end
	AWMCookiesCastSpellByName(spell)
end

function CancelPlayerBuffByName(name)
	for i = 1,16 do
		b = GetBuffName('player',i)
		if b then
			if b == name then
				CancelPlayerBuff(i-1)
			end
		end
	end
end

-- Reload UI
SlashCmdList['RELOAD_COMMAND'] = function(Flag)
	ReloadUI()
end
SLASH_RELOAD_COMMAND1 = '/reloadui';
SLASH_RELOAD_COMMAND2 = '/reui';

function UseItemByName(name)
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(bag) do
			a = GetContainerItemLink(bag,slot)
			if a then
				if string.find(a,name) then
					UseContainerItem(bag,slot)
					return
				end
			end
		end
	end
end

function cast(spell)
	CastSpellByName(spell)
end