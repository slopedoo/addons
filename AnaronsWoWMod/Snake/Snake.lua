local width = 24;
local height = 27;

function AWMSnakeMenuOnLoad()
	AWMSnakeFrames = {};
	for i = 1,24 do
		AWMSnakeFrames[i] = {};
		for j = 1,27 do
			f = CreateFrame('Frame',nil,AWMSnakeMenu);
			
			t = f:CreateTexture(nil,'BACKGROUND')
			t:SetTexture('Interface\\Icons\\'..AWMListOfTextures[1])
			t:SetAllPoints(f)
			t:SetWidth(10)
			t:SetHeight(10)
			
			f.texture = t;
			f:SetFrameStrata('HIGH')
			f:SetWidth(10)
			f:SetHeight(10)
			
			f:SetPoint('TOPLEFT',(i+2)*10,(0-7.5-j)*10,'TOPLEFT')
			
			f:SetAlpha(0);
			
			AWMSnakeFrames[i][j] = f;
		end
	end
	
	AWMSnakeNewGame();
end

function AWMSnakeNewGame()
	
	for i = 1,24 do
		for j = 1,27 do
			AWMSnakeSetPxlValue(i,j,0);
		end
	end
	
	AWMSnakePoints = {};
	
	for i = 1,29 do
		AWMSnakePoints[i] = {};
		for j = 1,26 do
			AWMSnakePoints[i][j] = (i == 1 or i == 29) and 1 or 0;
		end
		AWMSnakePoints[i][1] = 1
		AWMSnakePoints[i][26] = 1
	end
	
	AWMSnakeTimer = 0;
	AWMSnakeLength = 4;
	AWMSnakeHead = 4;
	
	AWMSnakeUP		= false;
	AWMSnakeDOWN	= false;
	AWMSnakeLEFT	= false;
	AWMSnakeRIGHT	= false;
	
	AWMMinigameLEFTSticky = false
	AWMMinigameDOWNSticky = false
	AWMMinigameRIGHTSticky = false
	AWMMinigameUPSticky = false
							
	AWMSnakeMoveX	= 0;
	AWMSnakeMoveY	= 0;
	
	AWMSnakeWorm = {{["x"] = 1, ["y"] = 1}, {["x"] = 2, ["y"] = 1}, {["x"] = 3, ["y"] = 1}, {["x"] = 4, ["y"] = 1}};
	
	for i in AWMSnakeWorm do
		AWMSnakeSetPxlValue(AWMSnakeWorm[i]['x'],AWMSnakeWorm[i]['y'],1);
		AWMSnakePoints[AWMSnakeWorm[i]['y']+1][AWMSnakeWorm[i]['x']+1] = 1;
	end
	
	AWMSpawnSnakeFood()
end

function AWMSnakeSetPxlValue(x,y,val)
	f = AWMSnakeFrames[x][y];
	t = f.texture;
	if (val == 0) then
		f:SetAlpha(0);
	else
		f:SetAlpha(1);
		if (val == 1) then
			t:SetTexture('Interface\\Icons\\INV_Misc_EngGizmos_02')
		else
			t:SetTexture('Interface\\Icons\\INV_Misc_Gem_Pearl_05')
		end
	end
end

function AWMSpawnSnakeFood()
	local x = 0;
	local y = 0;
	while (AWMSnakePoints[y+1][x+1] ~= 0) do
		x = floor(random()*24)+1
		y = floor(random()*27)+1
	end
	AWMSnakePoints[y+1][x+1] = 2;
	AWMSnakeSetPxlValue(x,y,2)
end

function AWMSnakeOnUpdate()
	if (GetTime() - AWMSnakeTimer > 0.1) then
		AWMSnakeTimer = GetTime();
		
		if (AWMSnakeMoveX == 0) then
			if (AWMMinigameLEFTSticky) then
				AWMSnakeMoveX	= -1;
				AWMSnakeMoveY	= 0;
			elseif (AWMMinigameRIGHTSticky) then
				AWMSnakeMoveX	= 1;
				AWMSnakeMoveY	= 0;
			end
		else --if (AWMSnakeLEFT) then
			if (AWMMinigameUPSticky) then
				AWMSnakeMoveX	= 0;
				AWMSnakeMoveY	= -1;
			elseif (AWMMinigameDOWNSticky) then
				AWMSnakeMoveX	= 0;
				AWMSnakeMoveY	= 1;
			end
		end
		
		if (AWMSnakeMoveX ~= 0 or AWMSnakeMoveY ~= 0) then
			oldpos = AWMSnakeWorm[AWMSnakeHead];
			
			AWMSnakeHead = AWMSnakeHead + 1;
			if (AWMSnakeHead > 300) then
				AWMSnakeHead = AWMSnakeHead - 300;
			end
			
			local i = AWMSnakeHead - AWMSnakeLength;
			if (i < 1) then
				i = i + 300;
			end
			
			AWMSnakeWorm[AWMSnakeHead] = {['x'] = oldpos['x'] + AWMSnakeMoveX, ['y'] = oldpos['y'] + AWMSnakeMoveY}
			
			if (AWMSnakePoints[AWMSnakeWorm[AWMSnakeHead]['y']+1][AWMSnakeWorm[AWMSnakeHead]['x']+1] == 1) then
				AWMSnakeNewGame();
				return
			elseif (AWMSnakePoints[AWMSnakeWorm[AWMSnakeHead]['y']+1][AWMSnakeWorm[AWMSnakeHead]['x']+1] == 2) then
				AWMSnakeLength = AWMSnakeLength + 1;
				AWMSpawnSnakeFood()
			end
			
			AWMSnakeSetPxlValue(AWMSnakeWorm[i]['x'],AWMSnakeWorm[i]['y'],0);
			AWMSnakeSetPxlValue(AWMSnakeWorm[AWMSnakeHead]['x'],AWMSnakeWorm[AWMSnakeHead]['y'],1);
			
			AWMSnakePoints[AWMSnakeWorm[i]['y']+1][AWMSnakeWorm[i]['x']+1] = 0;
			AWMSnakePoints[AWMSnakeWorm[AWMSnakeHead]['y']+1][AWMSnakeWorm[AWMSnakeHead]['x']+1] = 1;
		end
	end
end