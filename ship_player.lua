local ship_base = require('ship_base')


local player = {}
player.__index = player
setmetatable(player, {__index = ship_base})

function player:new(x, y)
	local obj = ship_base.new(x, y, 0.1, 0.7, 0.2)  -- base ship object
	setmetatable(obj, self)  -- make obj inherit player methods
	return obj
end

local rotation_rate =math.pi/200

local max_thrust=1.5
local thrust_step = 1

local boost_time = 0
local boost_cool_down = 10
function player:update(dt)

	if love.keyboard.isDown('d') then
		self.orientation = self.orientation + rotation_rate
	end

	if love.keyboard.isDown('a') then
		self.orientation = self.orientation - rotation_rate
	end

	if love.keyboard.isDown('w') then
		self.thrust = math.min(self.thrust+thrust_step*dt, max_thrust)
	end

	if love.keyboard.isDown('s') then
		self.thrust = math.min(math.abs(self.thrust-thrust_step*dt), 0)
	end

	if love.keyboard.isDown('space') then
		if os.time()-boost_time > boost_cool_down then
			boost_time = os.time()
			self.velocity = 500
			self.thrust = 0
		end
	end

	ship_base.update(self,dt)

	if love.keyboard.isDown('e') then
		self:move_left(dt)
	end
	if love.keyboard.isDown('q') then
		self:move_right(dt)
	end
end

return player
