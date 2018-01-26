local Moving = false

function AWMIconOnEnter(frame)
	GameTooltip:SetOwner(AWMIcon, "ANCHOR_LEFT");
	GameTooltip:SetText("Anarons WoW Mod");
	GameTooltip:AddLine("Left Click to open the A.W.M. GUI.",1,1,1);
	GameTooltip:AddLine("Right Click and drag to move icon.",1,1,1);
	GameTooltip:AddLine("You have "..get(AWMDKP,UnitName('player'),0)..' DKP.',0.7,0.7,1);
	GameTooltip:Show()
end

function AWMIconOnLeave()
	GameTooltip:Hide()
end

function AWMIconOnUpdate()
	if Moving then
		MouseX, MouseY = GetCursorPosition()
		MouseX, MouseY = MouseX - Minimap:GetLeft() - (Minimap:GetWidth())/2, MouseY - Minimap:GetBottom() - (Minimap:GetHeight())/2
		
		dist = pyt(MouseX,MouseY)
		AWMIconX = MouseX*78/dist;
		AWMIconY = MouseY*78/dist;
	end
	AWMIcon:SetPoint(
		"CENTER",
		"Minimap",
		"CENTER",
		AWMIconX,
		AWMIconY
	);
end


function AWMIconOnMouseDown(arg1)
	Moving = false;
	if (arg1 == "LeftButton") then
		AWMToggleMainMenu();
	else
		Moving = true;
	end
end


function AWMIconOnMouseUp(arg1)
	Moving = false;
end

SlashCmdList["AWMICON_COMMAND"] = function(Flag)
	flag = string.lower(Flag)
	if (flag == 'hide') then
		AWMHiddenIcon = true
		AWMIcon:Hide()
	elseif (flag == 'show') then
		AWMHiddenIcon = false
		AWMIcon:Show()
	else
		Print('AWM: Invalid command.')
	end
end
SLASH_AWMICON_COMMAND1 = "/awmicon"