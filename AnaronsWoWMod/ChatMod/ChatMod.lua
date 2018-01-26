AWM_CustomChatChannels = {CHAT_MSG_GUILD = {}, CHAT_MSG_RAID = {}}

CreateFrame("Frame", "AWM_CHAT_MESSAGES");
AWM_CHAT_MESSAGES:SetScript("OnEvent", function()
	if (string.sub(arg1,1,12) == "AWMClassChat") then
		chatcolor = ChatTypeInfo[arg3]
		
		chat = string.sub(arg1,13)
		
		AWM_ActiveChannel = AWM_ActiveChannel or UnitClass("player")
		
		if get(AWM_JoinedClassChannels, chat, chat == UnitClass("player")) then
			for channel in AWM_CustomChatChannels["CHAT_MSG_"..arg3] do
				getglobal(channel):AddMessage("["..string.sub(arg3,1,1)..string.lower(string.sub(arg3,2)).." - "..AddClassColor({chat,chat}).."] ["..FormatPlayerName(arg4).."]: "..arg2,chatcolor.r,chatcolor.g,chatcolor.b)
			end
		end
	elseif (arg1 == 'AWMAddonChat') then
		chatcolor = ChatTypeInfo[arg3]
		for channel in AWM_CustomChatChannels["CHAT_MSG_"..arg3] do
			getglobal(channel):AddMessage("["..string.sub(arg3,1,1)..string.lower(string.sub(arg3,2)).." - AWM] ["..FormatPlayerName(arg4).."]: "..arg2,chatcolor.r,chatcolor.g,chatcolor.b)
		end
	end
end);
AWM_CHAT_MESSAGES:RegisterEvent("CHAT_MSG_ADDON");

SlashCmdList["CLASSFILTER_COMMAND"] = function(Flag)
	if Flag ~= "" and Flag ~= " " then
		AWM_ActiveChannel = AWM_ActiveChannel or UnitClass("player")
		local chattype = DEFAULT_CHAT_FRAME.editBox.chatType
		if not (chattype == "GUILD" or chattype == "RAID") then
			chattype = "GUILD"
		end
		SendAddonMessage("AWMClassChat"..AWM_ActiveChannel,Flag,chattype)
	end
end
SLASH_CLASSFILTER_COMMAND1 = "/cm"

SlashCmdList["CLASSFILTEROPTION_COMMAND"] = function(Flag)
	if Flag == "" then
		Flag = "help"
	end
	words = {};
	for word in string.gfind(Flag, "[^%s]+") do
		table.insert(words, word);
	end
	if table.getn(words) == 1 then
		Print("/cm [Message]: Speak in default Class chat.")
		Print("/cmo [Class] [Message]: Speak in input Class chat.")
		Print("/cmo join [Class]: Join a new class chat (you can also join 'caster', 'melee', 'healer' and 'tank').")
		Print("/cmo leave [Class]: Leave this class chat.")
		Print("/cmo set [Class]: Set this to your default class chat.")
		return
	end
	arg1 = string.lower(words[1])
	Arg1 = string.upper(string.sub(words[1],1,1))..string.lower(string.sub(words[1],2))
	Arg2 = string.upper(string.sub(words[2],1,1))..string.lower(string.sub(words[2],2))
	
	if get(ClassColors,Arg2,False) then
		if arg1 == "join" then
			Print("You joined "..Arg2..".")
			AWM_JoinedClassChannels[Arg2] = true
		elseif arg1 == "set" then
			AWM_ActiveChannel = Arg2
			AWM_JoinedClassChannels[Arg2] = true
			Print("ClassChat set to "..Arg2..".")
		elseif arg1 == "leave" then
			AWM_ActiveChannel = UnitClass("player")
			AWM_JoinedClassChannels[Arg2] = false
			Print("You left "..Arg2..".")
		end
	end
	
	if get(ClassColors,Arg1,False) then
		local chattype = DEFAULT_CHAT_FRAME.editBox.chatType
		if not (chattype == "GUILD" or chattype == "RAID") then
			chattype = "GUILD"
		end
		SendAddonMessage("AWMClassChat"..Arg1,string.sub(Flag,string.len(arg1)+2,string.len(Flag)),chattype,chattype)
	end
end
SLASH_CLASSFILTEROPTION_COMMAND1 = "/cmo"



function ChatFrame_RegisterForMessages(...)
	local messageGroup;
	local index = 1;
	for i=1, arg.n do
		messageGroup = ChatTypeGroup[arg[i]];
		if ( messageGroup ) then
			this.messageTypeList[index] = arg[i];
			for index, value in messageGroup do
				this:RegisterEvent(value);
				if value == "CHAT_MSG_GUILD" or value == "CHAT_MSG_RAID" then
					AWM_CustomChatChannels[value][this:GetName()] = true
				end
			end
			index = index + 1;
		end
	end
end

f = CreateFrame('Frame')
f:SetScript('OnEvent',function()
	if (arg1 == 'AnaronsWoWMod') then
		if (AWM_JoinedClassChannels == nil) then
			AWM_JoinedClassChannels = {}
		end
	end
end)
f:RegisterEvent('ADDON_LOADED')

AWMChatModSendChatMessage = SendChatMessage

function SendChatMessage(arg1,arg2,arg3,arg4)
	arg1 = string.gsub(arg1,'S'..'u'..'l'..'f'..'u'..'r'..'a'..'s'..','..' '..'H'..'a'..'n'..'d'..' '..'o'..'f'..' '..'R'..'a'..'g'..'n'..'a'..'r'..'o'..'s','S'..'u'..'l'..'f'..'u'..'r'..'a'..'s'..','..' '..'M'..'i'..'g'..'h'..'t'..'y'..' '..'S'..'w'..'a'..'g'..'h'..'a'..'m'..'m'..'e'..'r'..' '..'o'..'f'..' '..'A'..'n'..'a'..'r'..'o'..'n')
	if (AWMUnitHasDebuff('player','Curse of Tongues') and (arg2 == 'RAID' or arg2 == 'GUILD')) then
		SendAddonMessage('AWMAddonChat',arg1,arg2)
	else
		AWMChatModSendChatMessage(arg1,arg2,arg3,arg4)
	end
end

function PaperDollItemSlotButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", this:GetID());
	GameTooltip:Show()
	local tmp = GameTooltipTextLeft1:GetText()
	if tmp then
		GameTooltipTextLeft1:SetText(string.gsub(tmp,'S'..'u'..'l'..'f'..'u'..'r'..'a'..'s'..','..' '..'H'..'a'..'n'..'d'..' '..'o'..'f'..' '..'R'..'a'..'g'..'n'..'a'..'r'..'o'..'s','S'..'u'..'l'..'f'..'u'..'r'..'a'..'s'..','..' '..'M'..'i'..'g'..'h'..'t'..'y'..' '..'S'..'w'..'a'..'g'..'h'..'a'..'m'..'m'..'e'..'r'..' '..'o'..'f'..' '..'A'..'n'..'a'..'r'..'o'..'n'))
		GameTooltip:Show()
	end
    if ( not hasItem ) then
		GameTooltip:SetText(TEXT(getglobal(strupper(strsub(this:GetName(), 10)))));
	end
	if ( hasCooldown ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end
--	if ( MerchantFrame:IsVisible() ) then
--		ShowInventorySellCursor(this:GetID());
--	end
	if ( InRepairMode() and repairCost and (repairCost > 0) ) then
		GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	end
end