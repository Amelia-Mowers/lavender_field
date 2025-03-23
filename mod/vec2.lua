--vec2
vec2 = {}
vec2.__index = vec2

pos_c = new_comp()

function vec2:new(x, y)
	 obj = {
	   x = x or 0,
	   y = y or 0,
	 }
	 setmetatable( 
	   obj, 
	   vec2
  )
	 return obj
end

function vec2:rect_arr(
  x1,y1,
  x2,y2
)
	 out = {}
	 
	 for ix = x1, x2 do
	   for iy = y1, y2 do
	     add(
	       out,
	       vec2:new(ix,iy)
	     )
	   end
	 end
	 
	 return out
end

function vec2.copy(self)
  return vec2:new(
    self.x,
    self.y
  )
end

function vec2.in_bound(
		self, bounds
)
  return (
    self.x >= 0
    and self.y >=0
    and self.x <= bounds.x
    and self.y <= bounds.y
  )
end

function vec2.__eq(a, b)
  return (
  		a.x == b.x
  		and a.y == b.y
  )
end

function vec2.__add(a, b)
  return vec2:new(
    a.x + b.x,
    a.y + b.y
  )
end

function vec2.__sub(a, b)
  return vec2:new(
    a.x - b.x,
    a.y - b.y
  )
end

function vec2.__mul(a, b)
  return vec2:new(
    a.x * b,
    a.y * b
  )
end

function vec2.__div(a, b)
  return vec2:new(
    a.x / b,
    a.y / b
  )
end

function vec2.key(self)
  return 
    tostring(self.x) 
    .. ","
    .. tostring(self.y)
end

--function vec2.key(self)
--  local x_val = flr(self.x)
--  local y_val = flr(self.y)
--  return (x_val << 8) + y_val
--end

function vec2.neighbors(self)
  return {
    vec2:new(
      self.x - 1, self.y),
    vec2:new(
      self.x + 1, self.y),
    vec2:new(
      self.x, self.y - 1),
    vec2:new(
      self.x, self.y + 1),
    vec2:new(
      self.x - 1, self.y + 1),
    vec2:new(
      self.x - 1, self.y - 1),
    vec2:new(
      self.x + 1, self.y - 1),
    vec2:new(
      self.x + 1, self.y + 1),
  }
end

function vec2.up(self)
  return vec2:new(
    self.x, self.y - 1
  )
end

function vec2.right(self)
  return vec2:new(
    self.x + 1, self.y
  )
end

function vec2.down(self)
  return vec2:new(
    self.x, self.y + 1
  )
end

function vec2.left(self)
  return vec2:new(
    self.x - 1, self.y
  )
end