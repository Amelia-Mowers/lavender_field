d_field = {}
d_field.__index = d_field

function d_field:new(
  pos,
  block_func
)
	 local obj = {
	   i = 0,
	   field = {},
	   frontier = {},
	   total = {},
	   origins = {},
	   pos = pos,
	   block_func = block_func,
	 }
	 
	 setmetatable( 
	   obj, 
	   d_field
  )
  
  obj.field[pos:key()] = obj.i
  add(obj.frontier, pos:copy())
  add(obj.total, pos:copy())
  add(obj.origins, pos:copy())
	 return obj
end

function d_field.add(
  self,
  pos
)  
  self.field[pos:key()] 
    = self.i
  add(
    self.frontier, 
    pos:copy()
  )
  add(
    self.total, 
    pos:copy()
  )
  add(
    self.origins, 
    pos:copy()
  )
end

function d_field.expand_to(
  self,
  to,
  max_range
)
		index = get_pos_index()
  
  while to == nil
  or self.field[to:key()]
  == nil
  do
    if self.i >= max_range then
      break
    end
    self:inc(index)
  end
end

function d_field.inc(
  self,
  index
)
  self.i += 1
  next_frontier = {}
   
  for f in all(self.frontier)
  do
    for n 
    in all(f:neighbors()) do
      if self.field[n:key()]
      == nil
      and self.block_func(
        n,
        index,
        self.origins
      ) 
      == false
      then
        self.field[n:key()]
          = self.i
        add(self.total, n)
        add(next_frontier, n)
      end
    end
  end
  self.frontier = next_frontier
end

function path_to(
  start,
  to,
  block_func
)
		if start == nil then
		  return 
		end
  
  d = d_field:new(
    start,
    block_func
  )
  
  d:expand_to(to, 16)
  
  if d.field[to:key()] == nil 
  then
    return
  end  
  
  path = {to}
  head = to
  while head != start do
    distance
      = d.field[head:key()]
    for n 
    in all(head:neighbors()) do
      if d.field[n:key()] != nil
      and d.field[n:key()]
      < distance then
        add(path, n)
        head = n
        break
      end
    end
  end
  
  return path
end

function get_pos_index()
  out = {}
  		for e, p in pairs(pos_c) do
  		  key = p:key()
  		  if out[key] == nil then
  		    out[key] = {}
  		  end
  				add(out[key], e)
  		end
  return out
end
