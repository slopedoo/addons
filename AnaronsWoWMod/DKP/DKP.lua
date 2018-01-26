AWMDKPBonusPerMinute = 0
AWM_AUCTION_DURATION = 30
AWM_ROLL_DURATION = 10
AWMDKPBonusPerMinuteTimer = GetTime()
AWMTrustedDKPSources = {}


AWM_AUCTION_TIMER = 0
AWM_ANOUNCED_TIME = 0
AWM_ANOUNCE_TYPE = 0
AWM_AUCTION_ITEM = ''

function AWMDKPUpdate()
	AWMDKPMenuYourDKP:SetText('You have '..get(AWMDKP,UnitName('player'),0)..' DKP.')
end

function AWMAddDKPToPlayer(player,absolute,percentage)
	AWMSetDKPToPlayer(player,tostring(math.floor(tonumber(get(AWMDKP,player,0))*(1+percentage/100) + absolute)))
end

function AWMSetDKPToPlayer(player,value)
	if (value ~= nil) then
		AWMDKP[player] = value
	end
end

function AWMDKPSync()
	msg = ''
	for name, val in AWMDKP do
		msg = name..'$$'..val..'$$'..msg
	end
	SendAddonMessage('AWMDKPUpdate',msg,'RAID')
	SendAddonMessage('AWMDKPUpdate',msg,'GUILD')
end

SlashCmdList["AWMDKP_COMMAND"] = function(Flag)
	flag = string.lower(Flag)
	words = {};
	for word in string.gfind(flag, "[^%s]+") do
		table.insert(words, word);
	end
	if (words[1] == 'add') then
		if (table.getn(words) == 3) then
			local name = string.upper(string.sub(words[2],1,1))..string.lower(string.sub(words[2],2,string.len(words[2])))
			
			local dkp = words[3]
			local absolute = 0
			local percentage = 0
			if (string.sub(dkp,string.len(dkp)) == '%') then
				percentage = tonumber(string.sub(dkp,1,string.len(dkp)-1))
			else
				absolute = tonumber(dkp)
			end
			if (name == 'All') then
				for player in AWMDKP do
					AWMAddDKPToPlayer(player,absolute,percentage)
				end
				print('Added '..dkp..' DKP to the everyone.')
			elseif (name == 'Raid') then
				for i = 1,40 do
					local target = 'raid'..i
					if (UnitName(target)) then
						AWMAddDKPToPlayer(UnitName(target),absolute,percentage)
					end
				end
				print('Added '..dkp..' DKP to the entire raid.')
			elseif (name == 'Notraid') then
				for player in AWMDKP do
					AWMAddDKPToPlayer(player,absolute,percentage)
				end
				for i = 1,40 do
					local target = 'raid'..i
					if (UnitName(target)) then
						AWMAddDKPToPlayer(UnitName(target),absolute,percentage)
					end
				end
				print('Added '..dkp..' DKP to everyone not in raid.')
			elseif (name == 'Guild') then
				print('The "guild" command is not finished yet.')
			else
				AWMAddDKPToPlayer(name,absolute,percentage)
				print (name..' has '..get(AWMDKP,name,0)..' DKP.')
			end
			AWMDKPSync()
		else
			print ('The "add" command takes 2 arguments: 1) player name 2) amount to add.')
		end
--	elseif (words[1] == 'set') then
--		if (table.getn(words) == 3) then
--			local name = string.upper(string.sub(words[2],1,1))..string.lower(string.sub(words[2],2,string.len(words[2])))
--			if (name ~= 'Raid' and name ~= 'Guild') then
--				AWMSetDKPToPlayer(name,tonumber(words[3]))
--				print (name..' has '..get(AWMDKP,name)..' DKP.')
--			end
--		else
--			print ('The "set" command takes 2 arguments: 1) player name 2) amount set add.')
--		end
	elseif (words[1] == 'raidstart') then
		AWMDKPBonusPerMinute = 1
		print('All raid members will now gain 1 DKP per minute.')
	elseif (words[1] == 'raidstop') then
		AWMDKPBonusPerMinute = 0
		print('Raid members will not gain any DKPs per minute.')
	elseif (words[1] == 'get') then
		local name = string.upper(string.sub(words[2],1,1))..string.lower(string.sub(words[2],2,string.len(words[2])))
		print (name..' has '..get(AWMDKP,name,0)..' DKP.')
	elseif (words[1] == 'isolate') then
		AWMTrustedDKPSources = {}
	elseif (words[1] == 'sync') then
		AWMDKPSync()
	elseif (words[1] == 'clean') then
		for name, val in AWMDKP do
			if val == '0' then
				AWMDKP[name] = nil
			end
		end
	else
		print('Unknown command, try "add", "get", "sync" or "isolate".')
	end
end
SLASH_AWMDKP_COMMAND1 = "/dkp"


SlashCmdList["AWM_AUCTION_COMMAND"] = function(Flag)
	AWM_AUCTION_TIMER = GetTime()+AWM_AUCTION_DURATION
	AWM_ANOUNCED_TIME = 0
	AWM_AUCTION_ITEM = Flag
	AWM_ANOUNCE_TYPE = 1
end
SLASH_AWM_AUCTION_COMMAND1 = "/auction"

SlashCmdList["AWM_ROLL_COMMAND"] = function(Flag)
	AWM_AUCTION_TIMER = GetTime()+AWM_ROLL_DURATION
	AWM_ANOUNCED_TIME = 0
	AWM_AUCTION_ITEM = Flag
	AWM_ANOUNCE_TYPE = 2
end
SLASH_AWM_ROLL_COMMAND1 = "/rollfor"


f = CreateFrame('Frame')
f:SetScript('OnUpdate',function()
	local time = AWM_AUCTION_TIMER - GetTime()
	if AWM_AUCTION_TIMER == 0 then time = 100 end
	
	if (AWM_ANOUNCE_TYPE == 1) then
	if (time < 100 and AWM_ANOUNCED_TIME == 0) then
		AWM_ANOUNCED_TIME = 1
		SendChatMessage('An auction for '..AWM_AUCTION_ITEM..' has started, it lasts for '..AWM_AUCTION_DURATION..' seconds!','RAID_WARNING')
	elseif (time < 20 and AWM_ANOUNCED_TIME == 1) then
		AWM_ANOUNCED_TIME = 2
		SendChatMessage('The auction for '..AWM_AUCTION_ITEM..' ends in 20 seconds.','RAID_WARNING')
	elseif (time < 10 and AWM_ANOUNCED_TIME == 2) then
		AWM_ANOUNCED_TIME = 3
		SendChatMessage('The auction for '..AWM_AUCTION_ITEM..' ends in 10 seconds!','RAID_WARNING')
	elseif (time < 5 and AWM_ANOUNCED_TIME == 3) then
		AWM_ANOUNCED_TIME = 4
		SendChatMessage('The auction for '..AWM_AUCTION_ITEM..' ends in 5 seconds!','RAID_WARNING')
	elseif (time < 3 and AWM_ANOUNCED_TIME == 4) then
		AWM_ANOUNCED_TIME = 5
		SendChatMessage('The auction for '..AWM_AUCTION_ITEM..' ends in 3 seconds!','RAID_WARNING')
	elseif (time < 2 and AWM_ANOUNCED_TIME == 5) then
		AWM_ANOUNCED_TIME = 6
		SendChatMessage('The auction for '..AWM_AUCTION_ITEM..' ends in 2 seconds!','RAID_WARNING')
	elseif (time < 1 and AWM_ANOUNCED_TIME == 6) then
		AWM_ANOUNCED_TIME = 7
		SendChatMessage('The auction for '..AWM_AUCTION_ITEM..' ends in 1 seconds!','RAID_WARNING')
	elseif (time < 0 and AWM_ANOUNCED_TIME == 7) then
		AWM_ANOUNCED_TIME = 8
		SendChatMessage('The auction for '..AWM_AUCTION_ITEM..' has ended!','RAID_WARNING')
	end
	else
	if AWM_AUCTION_TIMER == 0 then time = 100 end
	if (time < 100 and AWM_ANOUNCED_TIME == 0) then
		AWM_ANOUNCED_TIME = 1
		SendChatMessage('You have '..AWM_ROLL_DURATION..' seconds to roll for '..AWM_AUCTION_ITEM..'.','RAID_WARNING')
	elseif (time < 5 and AWM_ANOUNCED_TIME == 1) then
		AWM_ANOUNCED_TIME = 2
		SendChatMessage('You have 5 seconds to roll for '..AWM_AUCTION_ITEM..'.','RAID_WARNING')
	elseif (time < 3 and AWM_ANOUNCED_TIME == 2) then
		AWM_ANOUNCED_TIME = 3
		SendChatMessage('You have 3 seconds to roll for '..AWM_AUCTION_ITEM..'.','RAID_WARNING')
	elseif (time < 2 and AWM_ANOUNCED_TIME == 3) then
		AWM_ANOUNCED_TIME = 4
		SendChatMessage('You have 2 seconds to roll for '..AWM_AUCTION_ITEM..'.','RAID_WARNING')
	elseif (time < 1 and AWM_ANOUNCED_TIME == 4) then
		AWM_ANOUNCED_TIME = 5
		SendChatMessage('You have 1 seconds to roll for '..AWM_AUCTION_ITEM..'.','RAID_WARNING')
	elseif (time < 0 and AWM_ANOUNCED_TIME == 5) then
		AWM_ANOUNCED_TIME = 6
		SendChatMessage('Rolls for '..AWM_AUCTION_ITEM..' has been closed.','RAID_WARNING')
	end
	end
end)


f = CreateFrame('Frame')
f:SetScript('OnEvent',function()
	if (arg1 == 'AWMDKPUpdate') then
		if (AWMTrustedDKPSources[arg4]) then
			--AWMDKP = {}--???
			local args = codeSplit(arg2)
			for i = 1, table.getn(args),2 do
				AWMSetDKPToPlayer(args[i],args[i+1])
			end
		elseif (AWMTrustedDKPSources[arg4] == nil) then
			AWMDKPPendingSource = arg4
			StaticPopupDialogs["AWMDKPTrustSender"]["text"] = arg4.." wants to sync his DKP table with you, do you want him to override your data?"
			StaticPopup_Show("AWMDKPTrustSender")
		end
	end
end);
f:RegisterEvent('CHAT_MSG_ADDON')

f = CreateFrame('Frame')
f:SetScript('OnUpdate',function()
	if (GetTime()-AWMDKPBonusPerMinuteTimer > 60) then
		if (AWMDKPBonusPerMinute ~= 0) then
			AWMDKPBonusPerMinuteTimer = GetTime()
			for i = 1,40 do
				local target = 'raid'..i
				if (UnitName(target)) then
					AWMAddDKPToPlayer(UnitName(target),AWMDKPBonusPerMinute,0)
				end
			end
			AWMDKPSync()
		end
	end
end)

StaticPopupDialogs["AWMDKPTrustSender"] = {
	text = "Do you trust him?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		AWMTrustedDKPSources[AWMDKPPendingSource] = true
	end,
	OnCancel = function()
		AWMTrustedDKPSources[AWMDKPPendingSource] = false
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
}