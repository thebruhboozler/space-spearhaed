local ship_base = require('ship_base')


local enemy = {}
enemy.__index = enemy
setmetatable(enemy, {__index = ship_base})

function enemy:new(x, y, target)
	local obj = ship_base.new(x, y, 0.7, 0.1, 0.2)
	setmetatable(obj, self)
	obj.target = target
	return obj
end

local rotation_rate =math.pi/200

local max_thrust=1.5
local thrust_step = 1

local boost_time = 0
local boost_cool_down = 10

local desired_rotation = 0
local desired_thrust = 0
local desired_x = 0
local desired_y = 0
local attacking_point_chosen = false
local direction = 0
local distance = 0
local good_enough_distance = 15
local good_enough_angle =math.pi/20



local far_enough_away = 500
local evasion_zigzag_period = 10
local evasion_zigzag_time = 3


local lead_x = 0
local lead_y = 0
local min_thrust_chase = 1


local function dist(x1,x2,y1,y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

local possible_states = {
	positioning =1 ,
	attacking = 2,
	evading = 3,
}

local state = possible_states.positioning

function enemy:update(dt)
	if state == possible_states.positioning then
		if attacking_point_chosen == false then
			attacking_point_chosen = true
			direction = math.rad(math.random(0,360))
			distance = math.random(10,300)
		end
		desired_thrust = math.max(self.target.thrust,min_thrust_chase)
		desired_x = self.target.position.x + distance*math.cos(direction)
		desired_y = self.target.position.y + distance*math.sin(direction)
		if dist(desired_x , self.position.x , desired_y , self.position.y) < good_enough_distance then
			state=possible_states.attacking
			attacking_point_chosen=false
			lead_x =math.random(-10,10)
			lead_y =math.random(-10,10)
		end
	elseif state == possible_states.attacking then
		desired_thrust=0
		desired_x = self.target.position.x + lead_x
		desired_y = self.target.position.y + lead_y
		if desired_rotation -self.orientation < good_enough_angle then
			if os.time()-boost_time > boost_cool_down then
				boost_time = os.time()
				self:boost()
				state=possible_states.evading

				direction = math.rad(math.random(0,360))
				distance = math.random(150,500)
				desired_x = self.target.position.x + distance*math.cos(direction)
				desired_y = self.target.position.y + distance*math.sin(direction)
			end
		end
	elseif state == possible_states.evading then
		desired_thrust=max_thrust
		if dist(self.target.position.x , self.position.x , self.target.position.y , self.position.y) > far_enough_away then
			state = possible_states.positioning
			attacking_point_chosen = false
		end

		local curr_time = os.time()
		if curr_time % evasion_zigzag_period < evasion_zigzag_time then
			self:move_left(dt)
		elseif curr_time % evasion_zigzag_period > evasion_zigzag_period -evasion_zigzag_time then
			self:move_right(dt)
		end

		if curr_time-boost_time > boost_cool_down then
			boost_time = curr_time
			self:boost()
		end
	end

	if self.thrust < desired_thrust then
		self.thrust = math.min(self.thrust+thrust_step*dt, max_thrust)
	end

	if self.thrust > desired_thrust then
		self.thrust = math.max(self.thrust-thrust_step*dt, 0)
	end
	local dx = desired_x - self.position.x
	local dy = desired_y - self.position.y
	local angle_to_target = (math.atan2 and math.atan2(dy, dx)) or math.atan(dy, dx)
	desired_rotation = angle_to_target

	local diff = angle_to_target - self.orientation
	while diff > math.pi do diff = diff - 2*math.pi end
	while diff < -math.pi do diff = diff + 2*math.pi end

	local max_turn = rotation_rate



	if math.abs(diff) <= max_turn then
			self.orientation = angle_to_target
	else
		if diff > 0 then
			self.orientation = self.orientation + max_turn
		else
			self.orientation = self.orientation - max_turn
		end
	end
	ship_base.update(self,dt)
end

return enemy
