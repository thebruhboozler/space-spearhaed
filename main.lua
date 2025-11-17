local player=require('ship_player')
local enemy = require('ship_enemy')


local ship
local enemy_ship
local explosion
local explosion_frames = {}
local frameWidth = 32
local frameHeight = 32

local current_frame = 1
local timer = 0
local animationSpeed = 0.2

local explosion_happening = false
local explosion_x = 0
local explosion_y =0
local num_of_frames = 8

local windowWidth, windowHeight

local spawn_x_offset , spwan_y_offset = 100 , 100
function love.load()

	windowWidth , windowHeight  =   love.graphics.getDimensions()

	ship = player:new(spawn_x_offset, windowHeight - spwan_y_offset)
	enemy_ship =  enemy:new(windowWidth - spawn_x_offset ,spwan_y_offset,ship)
    	explosion = love.graphics.newImage("sprites/explosion.png")

	for i = 0, num_of_frames-1 do
		table.insert(explosion_frames, love.graphics.newQuad(i * frameWidth, 0, frameWidth, frameHeight, explosion:getDimensions()))
	end

end


function love.update(dt)
	if ship ~=nil then
		ship:update(dt)
		if enemy_ship ~= nil then
			if ship:pierces(enemy_ship) then
				explosion_happening = true
				explosion_x = enemy_ship.position.x
				explosion_y = enemy_ship.position.y
				enemy_ship = nil
			end
		end
	end
	if enemy_ship ~=nil then
		enemy_ship:update(dt)
		if ship ~= nil then
			if enemy_ship:pierces(ship) then 
				explosion_happening = true
				explosion_x = ship.position.x
				explosion_y = ship.position.y
				ship = nil
			end
		end
	end

	if explosion_happening then
		timer = timer + dt
		if timer >= animationSpeed then
			timer = timer - animationSpeed
			current_frame = current_frame + 1
			if current_frame > #explosion_frames-1 then
				explosion_happening = false
			end
		end
	end

end
function love.keypressed(key) 
	if key =='r' then
		if ship == nil or enemy_ship == nil then
			ship = player:new(spawn_x_offset, windowHeight - spwan_y_offset)
			enemy_ship =  enemy:new(windowWidth - spawn_x_offset ,spwan_y_offset,ship)
			current_frame = 1
		end
	end
end

function love.draw()
	if ship ~= nil then ship:draw() end
	if enemy_ship ~= nil then enemy_ship:draw() end
	if explosion_happening then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(explosion, explosion_frames[current_frame], explosion_x, explosion_y)
	end
end
