

SlashCmdList["GUILDNOTE_COMMAND"] = function(flag)
	for i = 1,string.len(flag) do
		if (string.sub(flag,i,i) == ' ') then
			for j = 1, GetNumGuildMembers() do
				if (GetGuildRosterInfo(j)) then
					if (string.lower(GetGuildRosterInfo(j)) == string.lower(string.sub(flag,1,i-1))) then
						GuildRosterSetPublicNote(j,DoTextChange(string.sub(flag,i+1)))
						return
					end
				end
			end
		end
	end
end
SLASH_GUILDNOTE_COMMAND1 = "/guildnote"

SlashCmdList["GUILDOFFICERNOTE_COMMAND"] = function(flag)
	for i = 1,string.len(flag) do
		if (string.sub(flag,i,i) == ' ') then
			for j = 1, GetNumGuildMembers() do
				if (GetGuildRosterInfo(j)) then
					if (string.lower(GetGuildRosterInfo(j)) == string.lower(string.sub(flag,1,i-1))) then
						GuildRosterSetOfficerNote(j,DoTextChange(string.sub(flag,i+1)))
						return
					end
				end
			end
		end
	end
end
SLASH_GUILDOFFICERNOTE_COMMAND1 = "/officernote"

SlashCmdList["MOTD_COMMAND"] = function(flag)
	GuildSetMOTD(DoTextChange(flag))
end
SLASH_MOTD_COMMAND1 = "/motd"

function DoTextChange(arg1)
	arg1 = string.gsub(arg1,'%[color%]','\124cff')
	arg1 = string.gsub(arg1,'%[red%]','\124cffFF0000')
	arg1 = string.gsub(arg1,'%[blue%]','\124cff0000FF')
	arg1 = string.gsub(arg1,'%[green%]','\124cff00FF00')
	arg1 = string.gsub(arg1,'%[none%]','\124cffr')
	arg1 = string.gsub(arg1,'Sulfuras, Hand of Ragnaros','Sulfuras, Mighty Swaghammer of Anaron')
	return arg1
end

function AWMGuildModHelp()
	print('\124cffFF9900Guild Functions')
	print('/guildnote [name] [message] - Sets the guild note of the given player.')
	print('/officernote [name] [message] - Sets the officer note of the given player.')
	print('/motd [message] - Sets the guild message of the day.')
	print('[red], [blue], [green], lets you color the messages.')
	print('[color], lets you provide a custom color.')
	print('For instance: "[red]Pro [color]CCFF00Tank" will result in:')
	print('\124cffFF0000Pro \124cffCCFF00Tank')
end

