ScrubListChatFrame_OnEvent = ChatFrame_OnEvent
function ChatFrame_OnEvent(event)
	if (arg1) then
		if string.find(arg1,'.+ pokes you') then
			name = string.gsub(arg1,'(.+) (pokes you.*)','%1')
			if (AWMScrubs[name]) then
				return
			end
		end
	end
	ScrubListChatFrame_OnEvent(event)
end


function AWMScrubListScrub(name)
	if (name == '' or name == ' ') then
		name = UnitName('target')
	end
	if (name == nil) then
		return
	end
	
	AWMScrubs[name] = date('%x')
	print (name..' was added to scrub list.') 
	AWMScrubListShow()
end
function AWMUnscrubListScrub(name)
	if (name == '' or name == ' ') then
		name = UnitName('target')
	end
	if (name == nil) then
		return
	end
	
	AWMScrubs[name] = nil
	print (name..' was removed from scrub list.') 
	AWMScrubListShow()
end

function AWMScrubListUnScrub(frame)
	AWMScrubs[frame.scrub] = nil
end

function AWMScrubListRaidCheck()
	for i = 1,40 do
		if (UnitName('raid'..i) == nil) then
			return
		end
		if (AWMScrubs[UnitName('raid'..i)]) then
			print('\124cffFF0000SCRUB ALERT: \124cffFFFF00'..UnitName('raid'..i)..' is in your raid!')
		end
	end
end

function AWMScrubListShow()
	num = 1;
	for scrub in AWMScrubs do
		getglobal('AWMScrubListMenuScrollFrameChild'..num..'Text'):SetText(scrub..' - '..AWMScrubs[scrub]);
		getglobal('AWMScrubListMenuScrollFrameChild'..num).scrub = scrub;
		getglobal('AWMScrubListMenuScrollFrameChild'..num):Show()
		num = num + 1;
		if (num == 72) then
			return
		end
	end
	for num = num, 72 do
		getglobal('AWMScrubListMenuScrollFrameChild'..num):Hide()
	end
end

SlashCmdList["SCRUBLIST_COMMAND"] = function(Flag)
	AWMScrubListScrub(string.upper(string.sub(Flag,1,1))..string.lower(string.sub(Flag,2)))
end
SLASH_SCRUBLIST_COMMAND1 = "/scrub"

SlashCmdList["UNSCRUBLIST_COMMAND"] = function(Flag)
	AWMUnscrubListScrub(string.upper(string.sub(Flag,1,1))..string.lower(string.sub(Flag,2)))
end
SLASH_UNSCRUBLIST_COMMAND1 = "/unscrub"


ChatFrame_OnEvent = MergeFunctions(ChatFrame_OnEvent,function(event)
	if (arg1) then
		if (string.find(arg1,'%a+ has joined the raid group')) then
			name = string.gsub(arg1,'(%a+) has joined the raid group','%1')
			if (AWMScrubs[name]) then
				print('\124cffFF0000SCRUB ALERT: \124cffFFFF00'..name..' is in your raid!')
			end
		end
		if (string.find(arg1,'You have joined a raid group')) then
			AWMScrubListRaidCheck()
		end
	end
end)