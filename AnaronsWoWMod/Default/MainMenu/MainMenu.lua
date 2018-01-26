AWMShowUIPanel = ShowUIPanel
function ShowUIPanel(arg1)
	if (arg1 == AWMMainMenu) then
		AWMMainMenu:Hide()
	end
	AWMShowUIPanel(arg1)
end

function AWMToggleMainMenu()
	if (AWMMainMenu:IsVisible()) then
		AWMMainMenu:Hide()
	else
		ShowUIPanel(AWMMainMenu)
	end
end

SlashCmdList["AWMMENU_COMMAND"] = function(Flag)
	AWMToggleMainMenu()
end
SLASH_AWMMENU_COMMAND1 = "/awm"