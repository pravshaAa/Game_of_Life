
local world = {}
local cellSize = 12
local gameState = "pause"
local xSizeWorld = 106
local ySizeWorld = 60
local cameraX = 0
local cameraY = 0
local cameraSpeed = 350

function love.load()
    NET(0, 0, xSizeWorld, ySizeWorld, cellSize)
end

function love.update(dt)
	if love.keyboard.isDown("w") then
		cameraY = cameraY + cameraSpeed*dt
	elseif love.keyboard.isDown("s") then
		cameraY = cameraY - cameraSpeed*dt
	end
    
	if love.keyboard.isDown("d") then
		cameraX = cameraX - cameraSpeed*dt
	elseif love.keyboard.isDown("a") then
		cameraX = cameraX + cameraSpeed*dt
	end
			
	if gameState == "pause" then
		for i, v in ipairs(world) do
			if love.mouse.isDown(1) and CheckCursor(world[i].x, world[i].y, cellSize, cellSize) and world[i].state == false then
				world[i].state = true
			elseif love.mouse.isDown(2) and CheckCursor(world[i].x, world[i].y, cellSize, cellSize) and world[i].state then
				world[i].state = false
			end
		end
	elseif gameState == "start" then
		local nextState = {}
		for i, v in ipairs(world) do
			local neighbors = findNeighboringCell(i)
			local aliveNeighbors = 0
			
			for _, neighborIndex in ipairs(neighbors) do
				if world[neighborIndex].state then
					aliveNeighbors = aliveNeighbors + 1
				end
			end
			
			if v.state then
				if aliveNeighbors == 2 or aliveNeighbors == 3 then
					nextState[i] = true
				end
			else
				if aliveNeighbors == 3 then
					nextState[i] = true
				else
					nextState[i] = false
				end
			end
		end
		
		for i, v in ipairs(world) do
			world[i].state = nextState[i]
		end
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.translate(cameraX, cameraY)
	
	for i, v in ipairs(world) do
		if world[i].state == false then
			love.graphics.rectangle("line", world[i].x, world[i].y, cellSize, cellSize)
		elseif world[i].state then
			love.graphics.rectangle("fill", world[i].x, world[i].y, cellSize, cellSize)
		end
	end
	
	love.graphics.pop()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "return" then
		gameState = "start"
	elseif key == "escape" then
		gameState = "pause"
    end
end

function NET(xStart, yStart, xSize, ySize, sizeCell)
    xStart = xStart - sizeCell
    for i = 1, xSize*ySize do
        if i == 1 then
            localX = xStart + sizeCell
            localY = yStart
        else
            localX = localX + sizeCell
        end
		
		table.insert(world, i, {x = localX, y = localY, state = false, col =  math.floor((i-1) % xSize) + 1, row = math.floor((i-1) / xSize) + 1})
		
        if localX == sizeCell*xSize + xStart then
            localY = localY + sizeCell
            localX = xStart 
        end
    end
end

function findNeighboringCell(cellIndex) 
	local cell = world[cellIndex]
	local neighbors = {}
	local xSize = xSizeWorld
	local ySize = ySizeWorld
	
	for i = -1, 1 do
		for j = -1, 1 do
			if not (i == 0 and j == 0) then
				local neighborRow = cell.row + i
				local neighborCol = cell.col + j  
				
				if neighborRow >= 1 and neighborRow <= ySize and neighborCol >= 1 and neighborCol <= xSize then
                    local neighborIndex = (neighborRow - 1) * xSize + neighborCol
                    table.insert(neighbors, neighborIndex)
                end
			end
		end
	end
	
	return neighbors
end

function CheckCursor(x, y, width, height)
	xMouse, yMouse = love.mouse.getPosition()
	local worldX = xMouse - cameraX
	local worldY = yMouse - cameraY
	return 	y <= worldY and
		 y + height >= worldY and
		 x <= worldX and
		 x + width >= worldX
end