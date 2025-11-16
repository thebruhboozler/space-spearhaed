local ship = {}
ship.__index = ship

function ship.new(x , y, r,g,b)
	local self=setmetatable({},ship)
	self.thrust = 0
	self.orientation = 0
	self.velocity = 0
	self.position = {x = x , y= y}
	self.r = r
	self.g = g
	self.b = b
	return self
end

function ship:rotate(angle)
	self.orientation = self.orientation + angle
end


local impulse = 5
local normalization = 3
local power = 150
local resistence = 1.5
local side_speed = 30
local max_velocity = 500

local function lerp(v1,v2,t)
	return v1 + (v2 - v1) * t
end

function ship:update(dt)
    	local t = impulse * self.thrust - normalization

    	local denom = 1 + t
	local desired_velocity
	if denom <= 0 then
		desired_velocity = 0
	else
		desired_velocity = t / math.sqrt(denom)
		desired_velocity = (desired_velocity + 1) / 2 -- erti da ori magiuri ricxvebi ar arian , formulidanaa, parametrebi ar arian
		desired_velocity = desired_velocity * power
	end

	desired_velocity = math.min(desired_velocity,max_velocity)
	self.velocity = lerp(self.velocity, desired_velocity, dt / resistence)

	local x = self.velocity * math.cos(self.orientation) * dt
	local y = self.velocity * math.sin(self.orientation) * dt
	self.position.x = self.position.x + x
	self.position.y = self.position.y + y
end


local structure= {
50, 0,
-50, 25,
0, 0,
-50,-25
}

local function get_structure(ship_)
	local points = {}

	for i = 1, #structure ,2 do
		local x =  structure[i]*math.cos(ship_.orientation) - structure[i+1]*math.sin(ship_.orientation)
		x = x + ship_.position.x
		local y =  structure[i]*math.sin(ship_.orientation) + structure[i+1]*math.cos(ship_.orientation)
		y = y + ship_.position.y
		table.insert(points,{x=x,y=y})
	end
	return points
end

local function intersects(a, b)
	-- a = {x1, y1, x2, y2}
	-- b = {x1, y1, x2, y2}

	local x1, y1, x2, y2 = a.x1, a.y1, a.x2, a.y2
	local x3, y3, x4, y4 = b.x1, b.y1, b.x2, b.y2

	-- helper: orientation of (p,q,r)
	local function orient(px, py, qx, qy, rx, ry)
		return (qy - py) * (rx - qx) - (qx - px) * (ry - qy)
	end

	local o1 = orient(x1, y1, x2, y2, x3, y3)
	local o2 = orient(x1, y1, x2, y2, x4, y4)
	local o3 = orient(x3, y3, x4, y4, x1, y1)
	local o4 = orient(x3, y3, x4, y4, x2, y2)

	-- general case: segments intersect
	if ((o1 > 0 and o2 < 0) or (o1 < 0 and o2 > 0))
		and ((o3 > 0 and o4 < 0) or (o3 < 0 and o4 > 0)) then
		return true
	end

	-- small helper to check collinear point on segment
	local function on_segment(px, py, qx, qy, rx, ry)
		return math.min(px, rx) <= qx and qx <= math.max(px, rx)
			and math.min(py, ry) <= qy and qy <= math.max(py, ry)
	end

	-- special cases: collinear + overlapping
	if o1 == 0 and on_segment(x1, y1, x3, y3, x2, y2) then return true end
	if o2 == 0 and on_segment(x1, y1, x4, y4, x2, y2) then return true end
	if o3 == 0 and on_segment(x3, y3, x1, y1, x4, y4) then return true end
	if o4 == 0 and on_segment(x3, y3, x2, y2, x4, y4) then return true end

	return false
end

function ship:pierces(other)

	local my_points = get_structure(self)
	local other_points = get_structure(other)

	local spear_point_lines = {}

	table.insert(spear_point_lines , {x1=my_points[1].x , y1=my_points[1].y , x2 = my_points[2].x , y2= my_points[2].y})
	table.insert(spear_point_lines , {x1=my_points[1].x , y1=my_points[1].y , x2 = my_points[4].x , y2= my_points[4].y})
	local other_ship_lines = {}

	for i = 1, #other_points-1  do
		table.insert(other_ship_lines , {x1=other_points[i].x , y1=other_points[i].y , x2 = other_points[i+1].x , y2=other_points[i+1].y})
	end


	for _, line in ipairs(other_ship_lines) do
		if intersects(spear_point_lines[1] , line) and intersects(spear_point_lines[2] , line) then
			return true
		end
	end
	return false
end


function ship:draw()
	local points = get_structure(self)

	local formatedPoints = {}

	for _, point in ipairs(points) do
		table.insert(formatedPoints, point.x)
		table.insert(formatedPoints, point.y)
	end
	love.graphics.setColor(self.r,self.g, self.b)
	love.graphics.polygon("fill",formatedPoints )
end

function ship:boost()
	self.velocity = 500
	self.thrust = 0
end

function ship:move_left(dt)
		local x = -math.sin(self.orientation)*dt
		local y = math.cos(self.orientation)*dt
		self.position.x = self.position.x + x*side_speed
		self.position.y = self.position.y + y*side_speed
end
function ship:move_right(dt)
		local x = math.sin(self.orientation)*dt
		local y = -math.cos(self.orientation)*dt
		self.position.x = self.position.x + x*side_speed
		self.position.y = self.position.y + y*side_speed
end


return ship
