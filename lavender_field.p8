pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--lavender field crusaders
--by mia mowers

#include mod/_init.lua

function move_block(pos, index)
  if pos:in_bound(bounds)
    == false
  then 
    return true
  end
 
  tile_block = fget(
    map_get(pos), 0
  )
  
  obj_block = false
 
  for e 
  in all(index[pos:key()]) do
    if block_move_c[e]
    != nil then
      obj_block = true
      break
    end
  end  
  
  return 
    tile_block or obj_block
end

function no_block(pos, index)
  return false
end
 
function _update()
  update_state()
  update_child_vis() -- 2
  timed_removal()
  select_cool:tick()
  if state == "start" then
    start_menu_control()
  end
  if state == "pick" then
    victory_check()
    pointer_control_pad()
    target_select()
    trigger_end_turn()
  end
  if state == "menu" then
    menu_cursor_control()
    menu_select()
    menu_back()
  end
  if state == "target" then
    pointer_control_pad()
    target_deselect()
    if target_selection != nil 
    and pos_c[pointer] != nil 
    then
      move_path = {}
    end
    set_action_target()
    trigger_action()
  end
  if state == "enemy_turn" then
    enemy_turn()
  end
  if state == "new_round" then
    camera_focus = pointer
    reset_actions()
    update_fog_of_war()
    next_state = "pick"
  end
  if state == "victory" then
    victory_control()
  end
  death_check()
  update_health_bars()
  update_menu_cursor()
  update_anim()
  update_floating_entities()
  update_damage_notices()
  update_attack_animations()
end

function update_floating_entities()
  for e, float_data 
  in pairs(float_c) do
    pos_c[e] 
      = pos_c[e] 
      + float_data.speed
    
    float_data.speed 
      = float_data.speed 
      + float_data.accel
  end
end

function update_damage_notices()
  for e, _ 
  in pairs(damage_notice_c) do
    if removal_timer_c[e] then
      local life_fraction 
        = 1 
        - removal_timer_c[
          e
        ]:fract()
      
      if life_fraction 
      < 0.3 then
        text_c[e].col = 5
      elseif life_fraction 
      < 0.6 then
        text_c[e].col = 9
      else
        text_c[e].col = 8
      end
    end
  end
end

function update_state()
		if next_state != nil then
		  state = next_state
		  next_state = nil
		end
end

function update_child_pos()
		for e, children
  in pairs(child_c) do
    for c in all(children) do
      pos_c[c]
        = pos_c[e]
        + local_pos_c[c]
    end
  end
end

function update_child_vis()
		for e, children
  in pairs(child_c) do
    for c in all(children) do
      visible_c[c]
        = visible_c[e]
    end
  end
end

function trigger_end_turn()
  remaining_units = false
  for e, _
  in pairs(player_c) do
     if actions_c[e] > 0
     or move_points_c[e] > 0
     and health_c[e] != nil 
     then
       remaining_units = true
       break
     end
  end
  
  remaining_living = false
  for e, _
  in pairs(player_c) do
     if health_c[e] != nil 
     then
       remaining_living = true
       break
     end
  end
  
  if remaining_units == false
  and remaining_living == true
  then
    next_state = "enemy_turn"
  end
end

function victory_check()
  remaining_enemies = false
  
  for e, _
  in pairs(mob_c) do
     if player_c[e] == nil
     and health_c[e] != nil 
     then
       remaining_enemies = true
       break
     end
  end
  
  if remaining_enemies == false
  then
    next_state = "victory"
  end
end

function reset_actions()
		for e, _
		in pairs(actions_c) do
  		 actions_c[e] = 2
  		 palette_c[e] = nil
     move_points_c[e] = 0
		end
end

function timed_removal()
  for e, t
  in pairs(removal_timer_c) do
    t:tick()
    if t.finished then
      delete(e)
    end
  end
end

function death_check()
  for e, h
  in pairs(health_c) do
    if h:dead() then
      remains = st.skull
      
      if remains_c[e] != nil
      then
        remains = remains_c[e]
      end
      
      health_c[e] = nil
      block_move_c[e] = nil
      block_sight_c[e] = nil
      cover_tile_c[e] = nil
      sprite_c[e].tiles
        = remains
      sprite_c[e].order = 1
      
      if child_c[e] != nil then
        for c 
        in all(child_c[e]) do
          sprite_c[c] = nil
        end
      end
      
      update_fog_of_war()
    end
  end
end


function update_anim()
		anim_timer:tick()
		if anim_timer.just_finished
		then
				anim_timer:restart()
		  for _, sprite
		  in pairs(sprite_c) do
		    sprite.a_index += 1
		    if sprite.a_index
		    > #sprite.tiles
		    then
		      sprite.a_index = 1
		    end
		  end
		  for _, sprite
		  in pairs(tile_sprite_mapping) do
		    sprite.a_index += 1
		    if sprite.a_index
		    > #sprite.tiles
		    then
		      sprite.a_index = 1
		    end
		  end
		  for _, sprite
		  in pairs(multi_sprite_c) do
		    sprite.a_index += 1
		    if sprite.a_index
		    > #sprite.tiles
		    then
		      sprite.a_index = 1
		    end
		  end
		end
end

function update_attack_animations()
  for e, anim 
  in pairs(attack_anim_c) do
    anim.t:tick()
    
    local fract
      = anim.t:fract()
    
    local dir = anim.dir
    
    if dir.x != 0 
    and dir.y != 0 then
      dir = dir * 0.7071
    end
    
    local bounce 
      = 1 - 2 * abs(fract - 0.5)
    
    bounce = bounce * bounce
    
    local max_extent = 0.4
    
    offset_c[e]
      = dir 
      * bounce 
      * max_extent
    
    if anim.t.finished then
      attack_anim_c[e] = nil
      offset_c[e] = vec2:new()
    end
  end
end

function set_cam()
  local c = pos_c[
    camera_focus
  ]:copy()
  
  c.x = c.x-3.5
  c.y = c.y-3.5
  
  camera_pos
    = camera_pos * 0.8
    + c * 0.2
  
  camera(
    camera_pos.x*16, 
    camera_pos.y*16
  )
end
 
function _draw()
  cls()
  if state == "start" then
    render_start_menu()
  elseif state == "victory" 
  then
    render_victory()
  else
    set_cam()
    render_map()
    render_objects()
    camera(0, 0)
  end
--  print(state, 0, 0)
--  print(debug_print)
end

function init_map()
  tile_sprite_mapping = {
    [16] = sprite:new(st.grass),
    [32] = sprite:new(st.dirt),
    [48] = sprite:new(st.water),
    [51] = sprite:new(st.dirt),
    [50] = sprite:new(st.grass),
  }
  
  map_funcs = {
    [51] = spawn_wall,
    [50] = spawn_tree,
  } 
  
  for x=0, 15 do
    for y=0, 15 do
      local pos 
        = vec2:new(x, y)
      local fn
        = map_funcs[
          map_get(pos)
        ]
      if fn != nil then
        fn(pos)
      end
    end
  end
  
  for m 
  in all(cur_map.spawn)
  do
    e = m[1](m[2])
    if spawn_focus_c[e] 
    != nil then
      pos_c[pointer]
        = m[2]:copy()
    end
  end
end

function spawn_wall(pos)
  insert({
    {pos_c, pos},
    {
      sprite_c, 
      sprite:new(st.wall,2)
    },
    {obj_c},
    {block_move_c},
    {block_sight_c},
    {cover_tile_c},
    {remains_c, st.rubble},
    {health_c, health:new(10)},
    {child_c, {
      insert({
        {pos_c, vec2:new()},
        {local_pos_c, vec2:new(
          0, 0.5
        )},
        {
          sprite_c, 
          sprite:new(
            st.wall_bottom,
            1
          )
        },
      }),
    }},
  })
end

function spawn_tree(pos)
  insert({
    {pos_c, pos},
    {
      sprite_c, 
      sprite:new(st.tree,2)
    },
    {obj_c},
    {block_move_c},
    {block_sight_c},
    {remains_c, st.rubble},
    {health_c, health:new(10)},
  })
end

covered_tiles = {}
unfogged_tiles = {}
visible_tiles = {}
unfogged_objects = {}
visible_objects = {}

function map_get(pos)
  return mget(
    pos.x + cur_map.pos.x, 
    pos.y + cur_map.pos.y
  )
end

function render_map()
  local min_x 
    = flr(camera_pos.x)
  local min_y 
    = flr(camera_pos.y)
  local max_x 
    = min_x + 8 
  local max_y 
    = min_y + 8
    
  covered_tiles = {}
  
  for e, _
  in pairs(cover_tile_c) do
    local pos = pos_c[e]
    covered_tiles[pos:key()]
      = true
  end
  
  pal(grey_scale, 0)
  for _, t_pos 
  in pairs(unfogged_tiles) do
    if t_pos.x >= min_x 
    and t_pos.x <= max_x 
    and t_pos.y >= min_y 
    and t_pos.y <= max_y then
      if visible_tiles[
        t_pos:key()
      ] == nil 
      and covered_tiles[
        t_pos:key()
      ] == nil
      then
        local sp
          = tile_sprite_mapping[
            map_get(t_pos)
          ]
        sp:render(nil, t_pos)
      end
    end
  end
  pal()
  for _, t_pos 
  in pairs(visible_tiles) do
    if t_pos.x >= min_x 
    and t_pos.x <= max_x 
    and t_pos.y >= min_y 
    and t_pos.y <= max_y then
      if covered_tiles[
        t_pos:key()
      ] == nil then
        local sp
          = tile_sprite_mapping[
            map_get(t_pos)
          ]
        sp:render(nil, t_pos)
      end
    end
  end
end

function update_fog_of_war(
  actor,
  inc
)
  if inc == nil
  or inc == false then
    visible_tiles = {}
    visible_objects = {}
  end
  
  local check = nil
  
  if actor == nil then
    check = player_c
  else
    check = {[actor] = {}}
  end
  
  local sight = nil
  
  for e, _
  in pairs(player_c) do
    if sight_c[e] != nil
    and health_c[e] != nil then
      if sight == nil then
        sight = d_field:new(
          pos_c[e],
          line_of_sight_block
        )
      else
        sight:add(pos_c[e])
      end
    end
  end
  
  if sight == nil then 
    return 
  end
  
  sight:expand_to(
    nil, 
    5
  )
  
  local index = get_pos_index()
  
  for t
  in all(sight.total) do
    for n 
    in all(t:neighbors()) do 
      if visible_tiles[
        n:key()
      ] == nil
      and n:in_bound(bounds)
      then
        unfogged_tiles[
          n:key()
        ] = n
        visible_tiles[
          n:key()
        ] = n
      end
      
      for e 
      in all(
        index[n:key()]
      ) do
        if obj_c[e]
        != nil then
          visible_objects[e]
            = {} 
          unfogged_objects[e]
            = {} 
        end
      end
    end
  end
  
  for e, _
  in pairs(obj_c) do
    if mob_c[e] != nil then
      visible_c[e]
        = visible_objects[e]
        != nil
    else
      if visible_objects[e]
      == nil then
        palette_c[e]
          = grey_scale
      else
        palette_c[e]
          = nil
      end
      visible_c[e]
        = unfogged_objects[e]
        != nil
    end
  end
end

function line_of_sight_block(
  pos,
  index,
  origins
)
  if pos:in_bound(bounds)
    == false
  then 
    return true
  end
  for o in all(origins) do
    local blocked = false
    
    for p 
    in all(pos_in_line(
      o, pos
    )) 
    do
      tile_block = fget(
        map_get(p), 1
      )
      
      if tile_block then
        blocked = true
        break
      end
 
      for e 
      in all(
        index[p:key()]
      ) do
        if block_sight_c[e]
        != nil then
          blocked = true
          break
        end
      end
    end
    if blocked == false then
      return false
    end
  end
  
  return true
end

function pos_in_line(a, b)
  local positions = {}
  
  local x0, y0 = a.x, a.y
  local x1, y1 = b.x, b.y
  
  local dx = abs(x1 - x0)
  local sx 
    = x0 < x1 
    and 1 
    or -1
  local dy = -abs(y1 - y0)
  local sy 
    = y0 < y1 
    and 1 
    or -1
  local err = dx + dy
  
  while true do
    add(
      positions, 
      vec2:new(x0, y0)
    )
    
    if x0 == x1 
    and y0 == y1 then
      break
    end
    
    local e2 = 2 * err
    if e2 >= dy then
      if x0 == x1 then
        break
      end
      err = err + dy
      x0 = x0 + sx
    end
    if e2 <= dx then
      if y0 == y1 then
        break
      end
      err = err + dx
      y0 = y0 + sy
    end
  end
  
  return positions
end

function render_path()
  for p in all(move_path) do
    if p != pos_c[target] then
      spr(
        33, 
        p.x*16+4, 
        p.y*16+4
      )
    end
  end
end

function target_select()
  if btn(❎) 
  and select_cool.finished then
    select_cool:restart()
  	 pointer_pos = pos_c[pointer]
    tar = nil
    tar_pos = nil
    for e, pos 
    in pairs(pos_c) do
      if pointer_pos == pos
      and mob_c[e] != nil
      and health_c[e] != nil
      and player_c[e] != nil
      and (
        actions_c[e] > 0
        or move_points_c[e] > 0
      )
      then
        tar = e
        tar_pos = pos
        break
     end
   end
   
   if tar != nil then
     target_selection = tar
     pos_c[target]
       = tar_pos:copy()
    	visible_c[target]
      	= true
    	visible_c[pointer]
      	= false
     pos_c[action_range]
       = tar_pos:copy()
     pos_c[action_range_2]
       = tar_pos:copy()
     next_state = "menu"
     open_action_menu()
   else 
     sfx(0)
   end
  end
end

function target_deselect()
  if btn(🅾️) then
    target_selection = nil
    visible_c[target] = false
    next_state = "pick"
    visible_c[action_range] = false
    visible_c[action_range_2] = false
    visible_c[possible_tar] = false
    close_status_window() 
  end
end

function pointer_control_pad()
  move_cooldown:tick()
  
  new_move = nil
  if btn(⬆️) then
    new_move = ⬆️
  elseif btn(⬇️) then 
    new_move = ⬇️
  elseif btn(⬅️) then
    new_move = ⬅️
  elseif btn(➡️) then
    new_move = ➡️
  end
  
  if new_move == nil then
  		moved_last = false
    return
  end
  
  if moved_last
  and move_cooldown.finished
  == false then 
    return
  end
  
  move_cooldown:restart()
     
  if moved_last then 
  		move_cooldown.limit
  		*= 0.5
  else
  		move_cooldown.limit 
  		= 0.3
  end
    
  new_pos
  = pos_c[pointer]:copy()
  
  if new_move == ⬆️ then 
    new_pos.y -= 1
  elseif new_move == ⬇️ then 
    new_pos.y += 1
  elseif new_move == ⬅️ then
    new_pos.x -= 1
  elseif new_move == ➡️ then
    new_pos.x += 1
  end
	 
	 if new_pos:in_bound(bounds)
	 then
	 		sfx(1)
    moved_last = true
	   pos_c[pointer] = new_pos
	   
    if state == "target" 
    and target_selection then
      open_status_window()
    end
	 end
end

-->8
--utils

function def(input, default)
  if input == nil then
    return default
  else
    return input
  end
end

function flat(
  input,
  index
)
  local index = index or 1
  if type(input) 
  == "table" then
    return input[index]
  else
    return input
  end
end

function def_index(
  input,
  index,
  default
)
  if type(input) 
  == "table" then
    return input[index]
  else
    return default
  end
end

function rot_sprite(
  input
)
  return {
    input,
    {input, flip_x = true},
    {input, flip_y = true},
    {
      input,
      flip_x = true,
      flip_y = true,
    },
  }
end

function quad_sprite(
  input
)
  return {
    input,
    input,
    input,
    input,
  }
end

--ecs

entity_counter = 0
comp_list = {}

function new_comp()
		new = {}
		add(comp_list, new)
		return new
end

function n_entity()
  out = entity_counter
  entity_counter += 1
  return out
end

function insert(comps)
  e = n_entity()
  for c in all(comps) do
  		if c[2] == nil then
  		  c[1][e] = {}
  		else
      c[1][e] = c[2]
    end
  end
  return e
end

function delete(entity)
  for c in all(comp_list) do
    c[entity] = nil
  end
end

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

--render
sprite_c = new_comp()
text_c = new_comp()
rect_c = new_comp()
fill_zone_c = new_comp()
multi_sprite_c = new_comp()

visible_c = new_comp()
palette_c = new_comp()
static_c = new_comp()
offset_c = new_comp()

renderable = {}
renderable.__index = renderable

function renderable:new()
  local obj = {}
  setmetatable(obj, self)
  return obj
end

function renderable.render(
  self, e, pos
)
  -- base render does nothing, should be overridden
end

-- sprite implementation
sprite = {}
sprite.__index = sprite
setmetatable(sprite, {__index = renderable})

function sprite:new(
  tiles,
  order,
  size,
  flip_x,
  flip_y
)
  local obj = renderable:new()
  obj.tiles = tiles
  obj.a_index = 1
  obj.order = order or 1
  obj.size = size or 2
  obj.flip_x = def(flip_x, false)
  obj.flip_y = def(flip_y, false)
  setmetatable(obj, sprite)
  return obj
end

q = {
  {0,0}, 
  {8,0}, 
  {0,8}, 
  {8,8}
}

function sprite.render(
  self, e, pos
)
  if self.a_index 
  > #self.tiles then
    self.a_index = 1
  end
  
  local tile 
    = self.tiles[self.a_index]
  local px, py 
    = pos.x*16, pos.y*16
  
  if type(tile) 
  == "number" then
    if tile == 0 then
      return
    end
    spr(tile, px, py, self.size, self.size, self.flip_x, self.flip_y)
  elseif type(tile) == "table" then
    for i=1, #tile do
      local t = tile[i]
      if t != 0 then
        local t_id = type(t) == "table" and t[1] or t
        local flip_x = type(t) == "table" and t.flip_x or false
        local flip_y = type(t) == "table" and t.flip_y or false
        spr(t_id, px+q[i][1], py+q[i][2], 1, 1, flip_x, flip_y)
      end
    end
  end
end

-- text implementation
text = {}
text.__index = text
setmetatable(text, {__index = renderable})

function text:new(
  txt, 
  col,
  outline, 
  order
)
  local obj = renderable:new()
  obj.text = txt
  obj.col = col or 6
  obj.outline = outline
  obj.order = order or 1
  setmetatable(obj, text)
  return obj
end

function text.render(
  self, e, pos
)
  t = self.text
  c = self.col
  o = self.outline
  x = pos.x*16
  y = pos.y*16
  
  print(t, x-1, y, o)
  print(t, x+1, y, o)
  print(t, x, y-1, o)
  print(t, x, y+1, o)
  print(t, x-1, y-1, o)
  print(t, x-1, y+1, o)
  print(t, x+1, y-1, o)
  print(t, x+1, y+1, o)
  print(t, x, y, c)
end

-- rectangle implementation
rectangle = {}
rectangle.__index = rectangle
setmetatable(rectangle, {__index = renderable})

function rectangle:new(
  size, 
  fill, 
  border, 
  order
)
  local obj = renderable:new()
  obj.size = size
  obj.fill = fill or 0
  obj.border = border or fill or 0
  obj.order = order or 1
  setmetatable(obj, rectangle)
  return obj
end

function rectangle.render(
  self, e, pos
)
  local corn = pos + self.size
  rectfill(
    pos.x*16,
    pos.y*16,
    corn.x*16,
    corn.y*16,
    self.fill
  )
  rect(
    pos.x*16,
    pos.y*16,
    corn.x*16,
    corn.y*16,
    self.border
  )
end

-- fill zone implementation
fill_zone = {}
fill_zone.__index = fill_zone
setmetatable(fill_zone, {__index = renderable})

function fill_zone:new(
  d_field, 
  border, 
  order
)
  local obj = renderable:new()
  obj.d_field = d_field
  obj.border = border or 0
  obj.order = order or 1
  setmetatable(obj, fill_zone)
  return obj
end

function fill_zone.render(
  self, e, pos
)
  fillp()
  
  local field = self.d_field

  local edges = {
    {
      dir = "up",
      dx1=0,
      dy1=0,
      dx2=15,
      dy2=0
    },
    {
      dir = "right",
      dx1=15,
      dy1=0,
      dx2=15,
      dy2=15
    },
    {
      dir = "down",
      dx1=0,
      dy1=15,
      dx2=15,
      dy2=15
    },
    {
      dir = "left",
      dx1=0,
      dy1=0,
      dx2=0,
      dy2=15
    }
  }

  local corners = {
    {
      dir1 = vec2.up, 
      dir2 = vec2.left,
      dx=0,
      dy=0
    },
    {
      dir1 = vec2.up,
      dir2 = vec2.right,
      dx=15,
      dy=0
    },
    {
      dir1 = vec2.down,
      dir2 = vec2.left,
      dx=0,
      dy=15
    },
    {
      dir1 = vec2.down,
      dir2 = vec2.right,
      dx=15,
      dy=15
    }
  }

  for p in all(field.total) do
    local px = p.x * 16
    local py = p.y * 16

    for _, edge in pairs(edges) do
      local neighbor = p[edge.dir](p)
      if field.field[neighbor:key()] == nil then
        line(
          px + edge.dx1,
          py + edge.dy1,
          px + edge.dx2,
          py + edge.dy2,
          self.border
        )
      end
    end

    for _, corner in pairs(corners) do
      local neighbor = corner.dir1(p)
      local neighbor = corner.dir2(neighbor)
      if field.field[neighbor:key()] == nil then
        pset(
          px + corner.dx,
          py + corner.dy,
          self.border
        )
      end
    end
  end
  fillp()
end

-- multi-sprite implementation
multi_sprite = {}
multi_sprite.__index 
  = multi_sprite
setmetatable(
  multi_sprite, 
  {__index = renderable}
)

function multi_sprite:new(
  tiles,
  order,
  size,
  positions
)
  local obj = renderable:new()
  obj.tiles = tiles
  obj.a_index = 1
  obj.order = order or 1
  obj.size = size or 2
  obj.positions = positions
  setmetatable(
    obj, 
    multi_sprite
  )
  return obj
end

function multi_sprite.render(
  self, e, pos
)
  local s = sprite:new(
    self.tiles,
    self.order,
    self.size
  )
  
  s.a_index = self.a_index
  
  for i 
  in all(self.positions) do
    sprite.render(s, e, i)
  end
end

function render_objects()
  local min_x 
    = flr(camera_pos.x) - 1
  local min_y 
    = flr(camera_pos.y) - 1
  local max_x 
    = min_x + 9 
  local max_y 
    = min_y + 9
    
  palt(0, false)
  palt(2, true)

  local render_layers = {}
  
  for i = -10, 10 do
    render_layers[i] = {}
  end

  local render_components = {
    sprite_c,
    text_c,
    rect_c,
    fill_zone_c,
    multi_sprite_c
  }
  
  for _, comp_table 
  in pairs(render_components) 
  do
    for e, comp 
    in pairs(comp_table) 
    do
      local pos = pos_c[e]
      if static_c[e] != nil
      or (
        pos.x >= min_x 
        and pos.x <= max_x 
        and pos.y >= min_y 
        and pos.y <= max_y 
      ) then
        if visible_c[e] == nil
        or visible_c[e] == true
        then
          add(
            render_layers[
              comp.order
            ], 
            {
              entity=e, 
              component=comp
            }
          )
        end
      end
    end
  end

  for l, list 
  in pairs(render_layers) do
    for _, obj 
    in pairs(list) do
      local e = obj.entity
      local comp 
        = obj.component
      local pos = nil
      
      if offset_c[e] == nil
      then
        pos = pos_c[e]
      else
        pos
          = pos_c[e] 
          + offset_c[e]
      end
      
      if palette_c[e] 
      != nil then
        pal(palette_c[e], 0)
      end
      
      if static_c[e] 
      != nil then
        camera(0, 0)
      end
      
      comp:render(e, pos)
      
      camera(
        camera_pos.x*16,
        camera_pos.y*16
      )
      
      pal()
      palt(0, false)
      palt(2, true)
    end
  end
  
  palt()
end

--timer
timer = {}
timer.__index = timer

function timer:new(limit)
	 obj = {
	   limit = limit,
	   elapsed = 0,
	   finished = false,
	   just_finished = false,
	 }
	 setmetatable( 
	   obj, 
	   timer
  )
	 return obj
end

function timer.tick(self)
  last = self.elapsed
  self.elapsed = min(
    self.elapsed + 1/30,
    self.limit
  )
  self.finished = 
    self.elapsed >= self.limit
  if last != self.elapsed 
  and self.finished then
    self.just_finished = true
  else
    self.just_finished = false
  end
end

function timer.restart(t)
  t.elapsed = 0
  t.finished = false
  t.just_finished = false
end

function timer.fract(self)
  return 
    self.elapsed
    / self.limit
end

--pathing
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


--menu
menu_cursor = {}
menu = {}

menu_cursor_c = new_comp()
menu_c = new_comp()
menu_back_c = new_comp()
menu_select_c = new_comp()
menu_move_onto_c = new_comp()

menu_move_cooldown
  = timer:new(0.3)
menu_moved_last = false

function menu_cursor:new(
  menu_e,
  offset
)
	 obj = {
	   pos = vec2:new(),
	   offset = offset,
	   focus = menu_e,
	 }
	 return obj
end

function menu:new(elements)
	 local obj = {
	   elems = {},
	 }
	 if elements != nil then
	   for n in all(elements) do
	     key = vec2:new(
	       n[1][1],
	       n[1][2]
	     ):key()
	     
	     obj.elems[key] = n[2]
	   end
	 end
	 return obj
end

function update_menu_cursor()
		for e, c 
		in pairs(menu_cursor_c) do
		  menu = menu_c[c.focus]
		  elem_e = menu.elems[
		    c.pos:key()]
		  
		  if elem_e != nil then
		    elem_pos = pos_c[elem_e]
		  
		    pos_c[e] = (
		      elem_pos + c.offset
		    )
		  end
		end
end

function menu_cursor_control()
  menu_move_cooldown:tick()
  
  new_move = nil
  if btn(⬆️) then
    new_move = ⬆️
  elseif btn(⬇️) then 
    new_move = ⬇️
  elseif btn(⬅️) then
    new_move = ⬅️
  elseif btn(➡️) then
    new_move = ➡️
  end
  
  if new_move == nil then
  		menu_moved_last = false
    return
  end
  
  if menu_moved_last
  and menu_move_cooldown.finished
  == false then 
    return
  end
  
  menu_move_cooldown:restart()
     
  if menu_moved_last then 
  		menu_move_cooldown.limit
  		*= 0.8
  else
  		menu_move_cooldown.limit 
  		= 0.3
  end
    
		for e, c 
		in pairs(menu_cursor_c) do
    new_pos = c.pos:copy()
    if new_move == ⬆️ then 
      new_pos.y -= 1
    elseif new_move == ⬇️ then 
      new_pos.y += 1
    elseif new_move == ⬅️ then
      new_pos.x -= 1
    elseif new_move == ➡️ then
      new_pos.x += 1
    end
    
    elem = menu_c[
      c.focus
    ].elems[
	     new_pos:key()
	   ]
	 
	   if elem != nil
	   then
	 		  sfx(1)
	 		  menu_move_onto_c[elem]()
      menu_moved_last = true
	     c.pos = new_pos
	   end
	 end
end

function menu_select()
  if btn(❎)
  and select_cool.finished then
    select_cool:restart()
    for e, c 
    in pairs(menu_cursor_c) do
      menu = menu_c[c.focus]
      elem = menu.elems[
        c.pos:key()
      ] 
       
      if menu_select_c[elem]
      != nil then
	 		    if menu_select_c[elem]()
	 		    then 
	 		      sfx(1)
	 		    else
	 		      sfx(0)
	 		    end
	     end
    end
  end
end

function menu_back()
  if btn(🅾️) then
   for e, _ 
   in pairs(menu_c) do
     if menu_back_c[e]
     != nil then
	 		  sfx(1)
	 		  menu_back_c[e]()
	    end
   end
  end
end

--combat

health = {}
health.__index = health

function health:new(total)
	 local obj = {
	   total = total,
	   dam = 0
	 }
	 setmetatable( 
	   obj, 
	   health
  )
	 return obj
end

function health.dead(self)
	 return self.dam >= self.total
end

function health.alive(self)
	 return self:dead() == false
end

function damage(e, dam)
	 cur = health_c[e].dam
	 health_c[e].dam = cur + dam
	 if dam > 0 then
    spawn_damage_number(e, dam)
  end
end

health_bar_c = new_comp()

function new_health_bar()
	 return {
	   insert({
      {pos_c, vec2:new()},
      {
        rect_c, 
        rectangle:new(
          vec2:new(11/16,1/16), 
          3, 
          3, 
          4
        )
      },
    }),
	   insert({
      {pos_c, vec2:new()},
      {
        rect_c, 
        rectangle:new(
          vec2:new(11/16,1/16), 
          1, 
          1, 
          3
        )
      },
    }),
  }
end

function update_health_bars()
  for e, h
	 in pairs(health_c) do
	   if h.dam > 0
	   and health_bar_c[e]
	   == nil
	   then
	     health_bar_c[e]
	       = new_health_bar()
	   end
	 end 

	 for e, h_e
	 in pairs(health_bar_c) do
	   base_pos = pos_c[e]
	   local health = health_c[e]
	     or {
	       total = 1,
	       dam = 1,
	     }
	   
	   if health.dam == 0 then
	     visible_c[h_e[1]] = false
	     visible_c[h_e[2]] = false
	   else
	     visible_c[h_e[1]] = true
	     visible_c[h_e[2]] = true
	   end
	   
	   len 
	     = (health.total 
	       - health.dam)
	     / health.total
	     * 11/16
	      
	   cur_len
	     = rect_c[h_e[1]].size.x
	     
	   if cur_len 
	   <= 0.01 then
	     visible_c[h_e[1]] = false
	     visible_c[h_e[2]] = false
	   end
	     
	   new_len
	     = len*.1 + cur_len*.9
	   
	   rect_c[h_e[1]].size.x
	    = new_len
	    
	   if new_len > .5 then
	     rect_c[h_e[1]].fill = 3
	     rect_c[h_e[1]].border = 3
	   elseif new_len > .3 then
	     rect_c[h_e[1]].fill = 9
	     rect_c[h_e[1]].border = 9
	   else 
	     rect_c[h_e[1]].fill = 8
	     rect_c[h_e[1]].border = 8
	   end
	   
	   new_pos 
	     = base_pos
	     + vec2:new(1/8,-2/16)
	     
	   pos_c[h_e[1]] = new_pos
	   pos_c[h_e[2]] = new_pos
	 end
end

function spawn_damage_number(
  entity, damage
)
  local pos
    = pos_c[entity]:copy()
  
  pos.y += 0.1
  
  pos.x 
    += 0.5 
    + rnd(0.05) - 0.025
  
  local dmg_text = insert({
    {pos_c, pos},
    {
      text_c, 
      text:new(
        tostring(damage),
        8,
        0, 
        5
      )
    },
    {
      float_c, 
      {
        speed = vec2:new(
          0, -0.04
        ),
        accel = vec2:new(
          0, 
          0.001
        )   
      }
    },
    {damage_notice_c},
    {
      removal_timer_c,
      timer:new(1.5) 
    }
  })
end

--ai

last_enemy = nil

function enemy_turn()
  e_action_timer:tick()
  
  if e_action_timer.finished
  == false then
    return
  end
  
  local enemies = {}
  for e, _ in pairs(mob_c) do
    if player_c[e] == nil then
      add(enemies, e)
    end
  end
  
  for _, enemy 
  in pairs(enemies) do
    if actions_c[enemy] > 0 
    and health_c[enemy] != nil
    and health_c[enemy]:alive()
    then
      action_targets = {}
      
      local available_actions 
        = action_set_c[enemy]
        
      if available_actions
      == nil then
        actions_c[enemy] = 0 
        break 
      end
      
      camera_focus = enemy
  
      e_action_timer:restart()
        
      if enemy
      != last_enemy then
        last_enemy = enemy
        break 
      end
      
      local best_action = nil
      local best_score_tar
        = {nil, nil}
      
      for _, action 
      in pairs(
        available_actions
      ) do
        if action.ai_eval 
        and action.can_use(
          enemy
        ) 
        then
          local score_tar
            = action.ai_eval(
              enemy,
              pos_c[enemy]
            )
          if score_tar[1] 
          != nil then
            if best_score_tar[1]
            == nil
            or score_tar[1] 
            > best_score_tar[1]
            then
              best_score_tar
                = score_tar
              best_action 
                = action
            end
          end
        end
      end
      
      if best_action == nil 
      or best_score_tar[1] 
      == nil then
        break
      end
      
      action_targets[1]
        = best_score_tar[2] 
      
      best_action.execute(
        enemy
      )
      actions_c[enemy]
        -= best_action.cost(
          enemy
        )
      
      if actions_c[enemy] <= 0 
      then
        palette_c[enemy]
          = grey_scale
      end
      break
    end
  end
  
  rem_enemy_actions = false
  
  for _, enemy 
  in pairs(enemies) do
    if actions_c[enemy] > 0
    and health_c[enemy] != nil
    then
      rem_enemy_actions = true
      break
    end
  end
  
  if rem_enemy_actions == false
  then  
    action_targets = {}
    next_state = "new_round"
  end
end





-->8
--action menu

action_set_c = new_comp()
actions_c = new_comp()

action = {}
action.__index = action

function action:new(
  name, config
)
  local obj = {
    name = name,
    cost = config.cost,
    range = config.range,
    targets = config.targets,
    range_block_func 
      = config.range_block_func
      or no_block,
    on_select
      = config.on_select,
    render_valid_targets
      = config.render_valid_targets,
    valid_target 
      = config.valid_target, 
    ai_eval = config.ai_eval,
    ai_target = config.ai_target,
    execute = config.execute,
    can_use = config.can_use 
    or function(actor)
      a_rem = actions_c[actor]
      a_use = config.cost()
      return a_rem - a_use
      >= 0
    end
  }
  
	 setmetatable( 
	   obj, 
	   action
  )
  return obj
end

function action.menu_func(self)
  return function()
    local tar 
      = target_selection
      
    if self.can_use(tar)
    == true
    then
      selected_action 
        = self
    
      needed_act_t 
        = self.targets(tar)
    
      if self.on_select then
        self.on_select(tar)
      end
    
      exit_action_menu()
      
      return true
    end
    return false
  end
end

function action.menu_move_onto(
  self
)
  return function()
    local tar = target_selection
    
    visible_c[action_range]
      = true
      
    visible_c[
      action_range_2
    ] = false
      
    local range = d_field:new(
      pos_c[tar],
      self.range_block_func
    )
    
    fill_zone_c[
      action_range
    ].d_field = range
    
    range:expand_to(
      nil,
      self.range(tar)
    )
    
    visible_c[possible_tar]
      = true
      
    pos_c[possible_tar] 
      = pos_c[tar]
      
    multi_sprite_c[
      possible_tar
    ].positions = {}
    
    if self.render_valid_targets
    then
      for _, pos
      in pairs(range.total) do
        if self.valid_target(
          tar,
          pos
        ) then
          add(
            multi_sprite_c[
              possible_tar
            ].positions, 
          pos)
        end 
      end
    end
  end
end

function init_action_menu()
  selected_action = nil
  action_targets = {}
  needed_act_t = nil
  
  action_range = insert({
    {pos_c, vec2:new(4,4)},
    {
      fill_zone_c, 
      fill_zone:new(
        d_field:new(
          vec2:new(),
          no_block
        ), 
        12,
        3
      )
    },
    {visible_c, false},
  })
  
  action_range_2 = insert({
    {pos_c, vec2:new(4,4)},
    {
      fill_zone_c, 
      fill_zone:new(
        d_field:new(
          vec2:new(),
          no_block
        ), 
        9,
        3
      )
    },
    {visible_c, false},
  })
  
  action_menu = insert({
  		{pos_c, vec2:new(.5,.5)},
  		{visible_c, false},
  		{rect_c, rectangle:new(
  				vec2:new(2,2),0,6,5
  		)},
    {menu_c, menu:new({})},
    {
      menu_back_c,
      action_menu_back
    },
    {static_c},
  })
end

function action_menu_back()
  target_selection = nil
  visible_c[target]
    = false
  visible_c[pointer]
    = true
  visible_c[action_range]
    = false
  visible_c[action_range_2]
    = false
  visible_c[possible_tar]
    = false
  next_state = "pick"
  
  hide_action_menu()
  close_status_window()
end

function open_action_menu()
  cur = 
    menu_cursor_c[menu_cursor]
  
  cur.pos = vec2:new()    

  menu = menu_c[action_menu]
		for _, e 
  in pairs(menu.elems) do
    delete(e)
  end
  
  menu.elems = {}

  base_pos = pos_c[action_menu]
  
  o_pos = base_pos 
    + vec2:new(0.5,0.25)
  pos = o_pos:copy()
  menu_pos = vec2:new()
  menu_size = vec2:new()
  for a
  in all(action_set_c[
    target_selection
  ]) do
    label = vec2:new()
    label.x, label.y =
      print(a.name,0,-10)
    label = label / 16
    
    menu_size.x = max(
      menu_size.x,
      label.x
    )
    
    base = pos - o_pos
    
    menu_size.y = 
      base.y + label.y
    
    elem = insert({
      {pos_c, pos},
      {text_c, text:new(
        a.name,6,nil,6
      )},
      {
        menu_select_c, 
        a:menu_func()
      },
      {
        menu_move_onto_c, 
        a:menu_move_onto()
      },
      {static_c},
    })
    menu.elems[
      menu_pos:key()
    ] = elem
    pos += vec2:new(0,0.5)
    menu_pos += vec2:new(0,1)
  end
  
  rect_c[action_menu].size =
    menu_size 
    + vec2:new(0.75,1)

  visible_c[action_menu] = true
  for _, e 
  in pairs(menu.elems) do
    visible_c[e] = true
  end
  visible_c[menu_cursor] = true
  
  elem = menu.elems[
	   vec2:new():key()
	 ]
	 open_status_window()
  menu_move_onto_c[elem]()
end

function exit_action_menu()
  visible_c[target]
    = true
  next_state = "target"
  visible_c[pointer]
    = true
  hide_action_menu()
end

function hide_action_menu()
  visible_c[action_menu]
    = false
  visible_c[menu_cursor]
    = false
  menu = menu_c[action_menu]
  for _, e 
  in pairs(menu.elems) do
    visible_c[e] = false
  end
end

function do_nothing()
end

function set_action_target()
  if btn(❎)
  and select_cool.finished
  then
    select_cool:restart()
		  
    if selected_action
    .valid_target(
      target_selection, 
      pos_c[pointer]
    )
    then
	 		  sfx(1)
      add(
        action_targets,
        pos_c[pointer]:copy()
      )
    else
	 		  sfx(0)
    end
  end
end

function trigger_action()
  if needed_act_t
  == #action_targets
  and target_selection != nil
  then 
	   local e = target_selection
    selected_action.execute(e) 
	 		    
    actions_c[e] 
      -= selected_action.cost(
        e, action_targets
      )
      
    if actions_c[e] <= 0
    and move_points_c[e] <= 0
    then
      palette_c[e]
        = grey_scale
    end
      
    selected_action = nil
    action_targets = {}
    needed_act_t = nil
    target_selection = nil
    visible_c[target]
      = false
    visible_c[action_range]
      = false
    visible_c[action_range_2]
      = false
    visible_c[possible_tar]
      = false
    next_state = "pick"
    close_status_window()
  end
end
-->8
--actions

actions = {}

actions.move = action:new(
  "move", {
    cost = function(actor)
      return 0
    end,
    
    range = function(actor)
      local range = d_field:new(
        pos_c[tar],
        move_block
      )
    
      fill_zone_c[
        action_range_2
      ].d_field = range
    
      visible_c[
        action_range_2
      ] = true
      
      local mp 
        = move_points_c[actor]
      local s = speed_c[actor]
      local a = actions_c[actor]
      
      range:expand_to(
        nil,
        mp + a*s
      )
      
      if mp == 0 then 
        return s 
      else
        return mp
      end
    end,
    
    targets = function(actor)
      return 1
    end,
    
    range_block_func
      = move_block,
    
    on_select = function(actor)
    end,
    
    render_valid_targets
      = false,
    
    valid_target = function(
      actor, 
      target_pos
    )
      local mp = move_points_c[
        target_selection
      ]
      local s = speed_c[
        target_selection
      ]
      local a = actions_c[
        target_selection
      ]
      
      local range = mp + a*s
      
      local move_path 
        = path_to(
          pos_c[actor],  
          target_pos,
          move_block
        ) 
        
      if move_path != nil 
      and #move_path > 0 then
        if #move_path - 1
        > range
        then
          return false
        end
      
        return true
      end
      return false
    end, 
    
    ai_eval = function(
      actor,
      pos,
      actions_left
    )  
      actions_left 
        = actions_left
        or actions_c[actor]
      
      local best_score = nil
      local best_target = nil
      
      local move_field 
        = d_field:new(
          pos,
          move_block
        )
        
      local mp 
        = move_points_c[actor]
      local s = speed_c[actor]
      local a = actions_c[actor]
      
      move_field:expand_to(
        nil, 
        mp + a*s
      )
      
      for _, move_pos
      in pairs(
        move_field.total
      ) do
        local score = 0
        
        local adjacent_players
          = 0
        local adjacent_enemies
          = 0
        
        for _, neighbor_pos 
        in pairs(
          move_pos:neighbors()
        ) 
        do
          for p, _ in pairs(
            player_c
          )
          do
            if pos_c[p] 
            == neighbor_pos
            and health_c[p]
            != nil
            then
              adjacent_players
              += 1
            end
          end
          
          for enemy, _ 
          in pairs(mob_c) do
            if player_c[enemy]
            == nil 
            and health_c[enemy]
            != nil
            and pos_c[enemy]
            == neighbor_pos 
            and enemy 
            != actor then
              adjacent_enemies
              += 1
            end
          end
        end
        
        score 
          -= adjacent_players
          * 5
        
        score 
          -= adjacent_enemies 
          * 2
        
        if actions_left
        > 1 
        and action_set_c[actor] 
        then
          local next_action_score
            = 0
          
          for _, action 
          in pairs(
            action_set_c[actor]
          ) do
            if action.ai_eval
            and action.name
            != "move"
            and action.can_use
            and action.can_use(
              actor
            ) then
              local action_result
                = action.ai_eval(
                  actor,
                  move_pos, 
                  actions_left - 1
                )
              
              if action_result[1] 
              != nil 
              and action_result[1] 
              > next_action_score 
              then
                next_action_score
                  = action_result[1]
              end
            end
          end
          
          score 
            += next_action_score
            * 0.8
        end
        
        if best_score == nil 
        or score 
        > best_score 
        then
          best_score = score
          best_target 
            = move_pos
        end
      end
      
      return {
        best_score,
        best_target
      }
    end,
    
    ai_target = function(actor) 
    end,
    
    execute = function(actor)
      local move_path 
        = path_to(
          pos_c[actor],  
          action_targets[1],
          move_block
        )
      
      local dist = #move_path -1
      local mp 
        = move_points_c[actor]
      local s 
        = speed_c[actor]
      local a 
        = actions_c[actor]
      
      local mp_use 
        = min(mp, dist)
      local remaining_steps 
        = dist - mp_use
      local a_use = ceil(
        remaining_steps / s
      )
      
      local left_over_mp 
        = (a_use * s) 
        - remaining_steps
  
      move_points_c[actor] 
        = left_over_mp
      actions_c[actor] 
        = actions_c[actor] 
        - a_use
      
      pos_c[actor]
        = action_targets[1]
      update_fog_of_war(
        nil,
        true
      )
	     update_child_pos()
    end,
  }
)

actions.melee = action:new(
  "melee", {
    cost = function(actor)
      return 1
    end,
    
    range = function(actor)
      return 1
    end,
    
    targets = function(actor)
      return 1
    end,
    
    on_select = function(actor)
    end,
    
    render_valid_targets
      = true,
    
    valid_target = function(
      actor, 
      target_pos
    )
      if target_pos
      == pos_c[actor]
      then
        return false
      end
      
      for e, _
      in pairs(health_c) do
        if pos_c[e]
        == target_pos
        and health_c[e]:alive()
        and (
          (
            player_c[actor] 
            != nil
            and player_c[e] 
            == nil
          )
          or player_c[actor] 
          == nil
        )
        then
          return true
        end
      end

      return false
    end, 
    
    ai_eval = function(
      actor,
      t_pos,
      actions_left
    ) 
      local best_score = nil
      local best_target = nil
  
      for _, neighbor_pos 
      in pairs(t_pos:neighbors())
      do
        for e, _ 
        in pairs(mob_c) do
          if neighbor_pos 
          == pos_c[e] 
          and health_c[e] 
          != nil then
          
            local score = nil
        
            if player_c[e] 
            != nil then
              score = 10 
              
              score += health_c[
                actor
              ].dam
        
              local t_rem_health
                = health_c[e]
                  .total
                - health_c[e]
                  .dam
        
              if attack_c[actor] 
              >= t_rem_health
              then
                score *= 10
              end
            end
            
            if score
            != nil then
              if best_score
              == nil
              or score
              > best_score
              then 
                best_score
                  = score
      						  	 best_target
      							     = neighbor_pos
      						  end
      						end
          end
        end
      end
  
      return {
        best_score,
        best_target
      }
    end,
    
    ai_target = function(actor) 
    end,
    
    execute = function(actor)
      target_pos 
        = action_targets[1]
      
      dam = attack_c[
        actor
      ]
      
      attack_anim_c[actor] = {
        t = timer:new(0.4),
        dir
          = target_pos
          - pos_c[actor]
      }
	 
      for e, _
      in pairs(health_c) do
        if pos_c[e] 
        == target_pos
        then
          damage(e, dam)
        end
      end
        
      sfx(2)
	 		  actions_c[actor] = 0
	 		  move_points_c[actor] = 0
    end,
  }
)


actions.end_turn = action:new(
  "end turn", {
    cost = function(actor)
      return 0
    end,
    
    range = function(actor)
      return 0
    end,
    
    targets = function(actor)
      return 0
    end,
    
    on_select = function(actor)
    end,
    
    render_valid_targets
      = false,
    
    valid_target = function(
      actor, 
      target_pos
    )
      return true
    end, 
    
    ai_eval = function(
      actor,
      t_pos,
      actions_left
    ) 
      return {
        0,
        t_pos
      }
    end,
    
    ai_target = function(actor) 
    end,
    
    execute = function(actor)
	 		  actions_c[actor] = 0
	 		  move_points_c[actor] = 0
    end,
  }
)

-->8
--sprites 

st = {
  point = {
    rot_sprite(1),
    rot_sprite(17),
  },
  menu_curs = {{33,0,0,0}},
  
  knight = {4,36},
  wiz = {6,38},
  gnome = {8,40},
  
  grass = {quad_sprite(16)},
  dirt = {quad_sprite(32)},
  water = {
    {48,49,49,48},
    {49,48,48,49},
  },
  wall = {10},
  tree = {44},
  wall_bottom = {{0,0,42,43}},
  rubble = {{0,0,58,59}},
  skull = {12},
  
  gobbo = {64,96},
  warg = {66,98},
  skeleton = {68,100},
  slime = {70,102},
}


-->8
--mobs

spawn_focus_c = new_comp()

function new_mob(
  name,
  pos,
  s,
  chain
)
  local comp_list = {
    {name_c, name},
    {pos_c, pos},
    {offset_c, vec2:new()},
    {
      sprite_c, 
      sprite:new(s,2)
    },
    {mob_c},
    {obj_c},
    {block_move_c},
    {actions_c, 2},
    {move_points_c, 0},
    {sight_c, 5},
    {speed_c, 2},
    {attack_c, 3},
    {health_c, health:new(5)},
    {action_set_c, {
      actions.move,
      actions.melee,
      actions.end_turn,
    }},
  }
  
  if chain != nil then
    for c in all(chain) do
      add(comp_list,c)
    end
  end
  
  return comp_list
end

mob = {
  knight = function(pos)
    return insert(new_mob(
      "knight",
      pos,
      st.knight,
      {
        {spawn_focus_c},
        {player_c},
        {
          health_c, 
          health:new(11)
        },
      }
    ))
  end,
  wiz = function(pos)
    return insert(new_mob(
      "wiz",
      pos,
      st.wiz,
      {
        {player_c},
      }
    ))
  end,
  gnome = function(pos)
    return insert(new_mob(
      "gnome",
      pos,
      st.gnome,
      {
        {player_c},
        {attack_c, 7},
      }
    ))
  end,
  skeleton = function(pos)
    return insert(new_mob(
      "skeleton",
      pos,
      st.skeleton,
      {}
    ))
  end,
}


-->8
--maps

function new_map(
  pos,
  size,
  spawn,
  exits,
  next_map
)
  return {
    pos = pos,
    size = size
      or vec2:new(16,16),
    spawn = spawn,
    exits = exits,
    next_map = next_map,
  }
end

maps = {
  trail = new_map(
    vec2:new(0,0),
    nil,
    {
      {
        mob.knight,
        vec2:new(2,8)
      },
      {
        mob.wiz,
        vec2:new(1,7)
      },
      {
        mob.gnome,
        vec2:new(0,8)
      },
      {
        mob.skeleton,
        vec2:new(6,8)
      },
    },
    vec2:rect_arr(
      14,6,
      15,9
    ),
    "grave"
  ),
  grave = new_map(
    vec2:new(16,0),
    nil,
    {
      {
        mob.knight,
        vec2:new(3,7)
      },
      {
        mob.skeleton,
        vec2:new(14,8)
      },
    },
    vec2:rect_arr(
      14,6,
      15,9
    ),
    "foo"
  )
}
-->8
--start menu

start_timer = timer:new(.4)
start_anim = 1
start_color = {13,6}

function render_start_menu()
  start_timer:tick()
  if start_timer.finished then
    start_timer:restart()
    start_anim += 1
		  if start_anim
		  > #start_color
		  then
		    start_anim = 1
		  end
		end
  
  spr(
    128,
    32, 40, 
    8, 4
  )
  
  local text
    = "press ❎/🅾️ to start"
    
  local t_len, _ 
    = print(text, -10, -10) 
    
  local tx 
    = 64 
    - t_len/2 
    - 3
  local ty
    = 80
  
  print(text, tx+1, ty+1, 1)
  print(
    text, tx, ty,
    start_color[start_anim]
  )
end

function start_menu_control()
  if btn(❎) 
  or btn(🅾️)
  then
    next_state = "pick"
    select_cool:restart()
  end
end


-->8
--status screen

function pad(input, padding)
  while #input < padding do
    input = " " .. input
  end
  return input
end


function init_status_window()
  
  local w = 2.25
  status_window = insert({
  		{pos_c, vec2:new(7.5-w,.5)},
  		{visible_c, false},
  		{rect_c, rectangle:new(
  				vec2:new(w,1.9),0,6,5
  		)},
    {menu_c, menu:new({})},
    {
      menu_back_c,
      action_menu_back
    },
    {static_c},
  })
  
  local tar = target_selection
  
  base_pos
    = pos_c[status_window] 
    + vec2:new(0.25,0.25)
    
  status = insert({
      {pos_c, base_pos},
    		{visible_c, false},
      {static_c},
      {text_c, text:new(
        "",6,nil,7
      )},
    })
end

function open_status_window()
  visible_c[status] = true
  visible_c[status_window] = true
    
  local tar = target_selection
  
  local h = health_c[tar]
  local a = actions_c[tar]
  local mp = move_points_c[tar]
  local s = speed_c[tar]
  
  -- if in targeting state with a valid action selected, calculate potential costs
  if state == "target" and selected_action then
    -- create a temporary copy of current values
    local potential_a = a
    local potential_mp = mp
    
    -- only calculate potential costs if cursor position is a valid target
    if selected_action.valid_target and 
       selected_action.valid_target(tar, pos_c[pointer]) and
       selected_action.cost then
       
      -- for move action, calculate path distance and update potential values
      if selected_action.name == "move" then
        local move_path = path_to(
          pos_c[tar],  
          pos_c[pointer],
          move_block
        )
        
        if move_path and #move_path > 0 then
          local dist = #move_path - 1
          local mp_use = min(mp, dist)
          local remaining_steps = dist - mp_use
          local a_use = ceil(remaining_steps / s)
          local left_over_mp = (a_use * s) - remaining_steps
          
          potential_mp = left_over_mp
          potential_a = a - a_use
        end
      else
        potential_a 
          = a 
          - selected_action.cost(tar)
      end
      
      potential_a 
        = max(0, potential_a)
      potential_mp 
        = max(0, potential_mp)
      
      a = potential_a
      mp = potential_mp
    end
  end
  
  local th = h.total
  local ch = th - h.dam
  
  local hs 
    = pad(tostr(ch), 2) 
    .. "/"
    .. tostr(th)
    
  local ms 
    = tostr(mp) 
    .. "/"
    .. tostr(s)

  local status_txt =
    name_c[tar] .. "\n"  ..
    "hp:".. hs .."\n" ..
    "act:".. tostr(a) .."/2 \n" ..
    "mve:".. ms .."\n"
    
  text_c[status].text 
    = status_txt
end

function close_status_window()
  visible_c[status] = false
  visible_c[status_window]
    = false
end
-->8
function render_victory()
  local text
    = "victory!"
    
  local t_len, _ 
    = print(text, -10, -10) 
    
  local tx 
    = 64 
    - t_len/2 
    - 3
  local ty
    = 64
  
--  print(text, tx+1, ty+1, 1)
  print(
    text, tx, ty,
    6
  )
end

function victory_control()
  if (
    btn(❎) 
    or btn(🅾️)
  )
  and select_cool.finished
  then
    for e, _ 
    in pairs(obj_c) do
      delete(e)
    end
    
    cur_map = maps[
      cur_map.next_map
    ]
    init_map()
    next_state = "pick"
    select_cool:restart()
  end
end
__gfx__
00000000000002220000000000000000222222222222222222222222222222222222222222222222000000000000000022222222222222220000000000000000
00000000077702220000000000666600222220000002222222000000000222222222222222222222006666606666660022222222222222220000000000000000
0070070007000222006666000006060022220dddddd02222220ddddddd0002222222220002222222066066606006066022222222222222220000000000000000
000770000702222200060600006666002220ddddddd000222200ddddd0aaa0222222200d00222222066666606006666022222222222222220000000000000000
000770000002222200666600000660002220d00000d060222220ddddd0aaa022222200ddd0022222066600606666606022222222222222220000000000000000
007007002222222200066000000660002220d00000d06022220dddddd0aaa02222220ddddd002222066600606666666022222200002222220000000000000000
000000002222222200600600006006002220ddd0ddd06022220000000000022222220dddddd02222006666600666660022222066660222220000000000000000
000000002222222200000000000000002220ddd0ddd0602222220111110d022222200d0000d00222000000000000000022220606066022220000000000000000
00000000222222220000000000000000200000d0dd00000222222011100000222206001111006022066666666000666022220606006022220000000000000000
00002020200002220000000000dddd0020666000000ddd022200000000ddd0222206011111106022060066666606606022220666666022220000000000000000
000002002077022200dddd0000000d00206660dddd0ddd02220dd0ddd0ddd0222000001111000002060066660606666022222060660222220000000000000000
000000002070022200000d0000d0dd00206660dddd000002220dd0ddd000002220ddd000000ddd02066666666606006022200066600002220000000000000000
000000002000222200d0dd00066dd000200000ddddd06022220000dddd0d022220ddd0dddd0ddd02066666666606006022206600006602220000000000000000
0202000022222222066dd000066dd00022220dd00dd0002222220dd00d000222200000d00d000002066660666606666022206606606602220000000000000000
002000002222222206600d0000d00d0022220dd00dd0222222220dd00dd0222222220dd00dd02222006666666606660022200000000002220000000000000000
00000000222222220000000000000000222222222222222222222222222222222222222222222222000000000000000022222222222222220000000000000000
0000000022662222000000000dddd000222222222222222222222222222222222222222222222222000000000000000022222200002222222222222002222222
02200020226662220dddd00000dddd00222222222222222222222222222222222222222222222222055505555505555022220077770022222222220770222222
022000002266662200dddd000dddddd0222220000002222222000000000222222222222222222222055055555505550022207777777702222222220770222222
00002000226662220dddddd00000000022220dddddd00022220ddddddd0002222222220002222222000000000000000022077777777770222222207777022222
00000000226622220000000000dddd002220ddddddd060222200ddddd0aaa0222222200d00222222055555505550555020777777777777022222207777022222
0000022022222222000dd000000dd0002220d00000d060222220ddddd0aaa022222200ddd0022222055555505555055020777777777777022222077777702222
020002202222222200d00d0000d00d002220d00000d06022220dddddd0aaa02222220ddddd002222055555005555505020677777777776022222077777702222
000000002222222200000000000000002220ddd0ddd06022220000000000022222200dddddd00222000000000000000020667777777766022220777777770222
00000000000000000000000000000000200000d0dd00000222220111110d022222060d0000d06022222200000002222220666677776666022220777777770222
00000000000000000077770000606660206660d0dd0ddd0222000011100000222206001111006022222005505500222220666666666666022206677777766022
0000000000000000077777700660666020666000000ddd02220dd00000ddd0222000001111000002220055500550022222066666666660222206666776666022
00033000000000000677776000000660206660dddd000002220dd0ddd0ddd02220ddd011110ddd02220555000005002222206666666602222206666666666022
03300330000330000666666006600000200000ddddd06022220000ddd000002220ddd000000ddd02220500055500502222220000000022222220666666660222
0000000000000000006666000660666022220dddddd0002222220ddddd0d0222200000dddd000002220005555550502222222205502222222222000000002222
0000000000000000000550000660660022220dd00dd0222222220dd00d00022222220dd00dd02222220000000000002222222005500222222222200550022222
00000000000000000000000000000000222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220022220022222222222222222222222222000022222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220302203022222222222222222222222220666602222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220330033022222222222222222222222206060660222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220333333022222222222222222222222206060060222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220000000022222000000222222222222206666660222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220090990022222044440222222222222220606602222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220000000022222040440000222222222220666602222222222200002222220000000000000000000000000000000000000000000000000000000000000000
222203333330222220444404440222222200000060000022222220cccc0222220000000000000000000000000000000000000000000000000000000000000000
22000033330000222044440444402222220660666606602222220cccccc022220000000000000000000000000000000000000000000000000000000000000000
22033033330330222000000444402222220660006006602222220c0cc0c022220000000000000000000000000000000000000000000000000000000000000000
22033033330330222222044444402222220000666600002222220c0cc0c022220000000000000000000000000000000000000000000000000000000000000000
22000030030000222222044004402222222206600660222222220cccccc022220000000000000000000000000000000000000000000000000000000000000000
22220330033022222222044004402222222206600660222222220cccccc022220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220022220022222222222222222222222222000022222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220302203022222222222222222222222220666602222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220330033022222222222222222222222206060660222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220333333022222222222222222222222206060060222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220000000022222000000222222222222206666660222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220090990022222044440222222222222220606602222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220000000022222040440000222222220000666600002222222200002222220000000000000000000000000000000000000000000000000000000000000000
220000333300002220444404440222222206600060066022222220cccc0222220000000000000000000000000000000000000000000000000000000000000000
22033033330330222044440444402222220660666606602222220cccccc022220000000000000000000000000000000000000000000000000000000000000000
2203303333033022200000044440222222000000600000222220cc0cc0cc02220000000000000000000000000000000000000000000000000000000000000000
2200003333000022222204444440222222220666666022222220cc0cc0cc02220000000000000000000000000000000000000000000000000000000000000000
22220330033022222222044004402222222206600660222222220cccccc022220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000d0000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ddd10000000000000000000000000000000000ddd1000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dd100000000000000000000000000000000000dd1000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dd100000000000000000000000000000000000dd1000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dd1000000dddd000d00d000ddd00d0dd0000dddd1000ddd00d0dd000000000000000000000000000000000000000000000000000000000000000000000
000000dd100000dd1dd10dd1dd10d1dd1ddd1dd00dd1dd100d1dd1ddddd100000000000000000000000000000000000000000000000000000000000000000000
000000dd10000dd11dd10dd1dd1dd1d11dd11dd1dd11dd10dd1d11dd111100000000000000000000000000000000000000000000000000000000000000000000
000000dd100d0dd11dd10dd1dd1ddd111dd11dd1dd11dd10ddd110dd100000000000000000000000000000000000000000000000000000000000000000000000
000000ddd0dd1dd11dd10dd1d11dd11d1dd11dd1dd11dd10dd11d0dd100000000000000000000000000000000000000000000000000000000000000000000000
000000d1ddd110ddd1dd00dd1100ddd11d111d1101dd1dd00ddd11d1100000000000000000000000000000000000000000000000000000000000000000000000
000000010111000111011001100001110010d1100001101100111001000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000dd0000000000000d0000001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000dddddd00d0000000ddd10000ddd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ddd1d1dd10000000dd100000dd100000000000000dddd0000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dd1101d110000000dd100000dd10000000dddd0000dddd000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dddd000d0000ddd0dd1000dddd10000000000d000dddddd00000000000000000000000000000000000000000000000000000000000000000000
000000000000dddd110dd100d1dd1dd100dd1dd10000000d0dd00000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dd1100dd10dd1d11dd10dd11dd100000066dd00000dddd000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dd1000dd10ddd110dd10dd11dd100000066dd000000dd0000000000000000000000000000000000000000000000000000000000000000000000
0000ddd000000dd1000dd10dd11d0dd10dd11dd100d0000d00d0000d00d000000000000000000000000000000000000000000000000000000000000000000000
000d11d100000dd10000dd00ddd110dd001dd1dd0dd1000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd1001000000110000011001110001100011011dd1000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd11000000000000000000000000000000000000dd1000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd1000000d0dd00d000d000ddd0000dddd0000dddd1000ddd00d0dd00ddd0000000000000000000000000000000000000000000000000000000000000000000
0dd100000ddddd1dd10dd10dd1d100dd1dd100dd1dd100d1dd1ddddd1dd1d1000000000000000000000000000000000000000000000000000000000000000000
0dd1000d0dd1111dd10dd100dd110dd11dd10dd11dd10dd1d11dd11110dd11000000000000000000000000000000000000000000000000000000000000000000
0dd100dd1dd1000dd10dd1000ddd0dd11dd10dd11dd10ddd110dd100000ddd000000000000000000000000000000000000000000000000000000000000000000
00dd00d11dd1000dd10dd10d11dd1dd11dd10dd11dd10dd11d0dd1000d11dd100000000000000000000000000000000000000000000000000000000000000000
000ddd110d110000ddd1dd00ddd110ddd1dd001dd1dd00ddd11d110000ddd1100000000000000000000000000000000000000000000000000000000000000000
00001110001000000111011001110001110110001101100111001000000111000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000d0000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000ddd10000000000000000000000000000000000ddd10000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000dd100000000000000000000000000000000000dd10000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000dd100000000000000000000000000000000000dd10000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000dd1000000dddd000d00d000ddd00d0dd0000dddd1000ddd00d0dd0000000000000000000000000000000000000
00000000000000000000000000000000000000dd100000dd1dd10dd1dd10d1dd1ddd1dd00dd1dd100d1dd1ddddd1000000000000000000000000000000000000
00000000000000000000000000000000000000dd10000dd11dd10dd1dd1dd1d11dd11dd1dd11dd10dd1d11dd1111000000000000000000000000000000000000
00000000000000000000000000000000000000dd100d0dd11dd10dd1dd1ddd111dd11dd1dd11dd10ddd110dd1000000000000000000000000000000000000000
00000000000000000000000000000000000000ddd0dd1dd11dd10dd1d11dd11d1dd11dd1dd11dd10dd11d0dd1000000000000000000000000000000000000000
00000000000000000000000000000000000000d1ddd110ddd1dd00dd1100ddd11d111d1101dd1dd00ddd11d11000000000000000000000000000000000000000
00000000000000000000000000000000000000010111000111011001100001110010d11000011011001110010000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000dd0000000000000d0000001d000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000dddddd00d0000000ddd10000ddd100000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000ddd1d1dd10000000dd100000dd100000000000000dddd00000000000000000000000000000000000000
000000000000000000000000000000000000000000000dd1101d110000000dd100000dd10000000dddd0000dddd0000000000000000000000000000000000000
000000000000000000000000000000000000000000000dddd000d0000ddd0dd1000dddd10000000000d000dddddd000000000000000000000000000000000000
00000000000000000000000000000000000000000000dddd110dd100d1dd1dd100dd1dd10000000d1dd000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000dd1100dd10dd1d11dd10dd11dd100000066dd00000dddd0000000000000000000000000000000000000
000000000000000000000000000000000000000000000dd1000dd10ddd110dd10dd11dd100000066dd000000dd00000000000000000000000000000000000000
000000000000000000000000000000000000ddd000000dd1000dd10dd11d0dd10dd11dd100d0000d00d0000d00d0000000000000000000000000000000000000
00000000000000000000000000000000000d11d100000dd10000dd00ddd110dd001dd1dd0dd10000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000dd1001000000110000011001110001100011011dd10000000000000000000000000000000000000000000000000000
000000000000000000000000000000000dd11000000000000000000000000000000000000dd10000000000000000000000000000000000000000000000000000
000000000000000000000000000000000dd1000000d0dd00d000d000ddd0000dddd0000dddd1000ddd00d0dd00ddd00000000000000000000000000000000000
000000000000000000000000000000000dd100000ddddd1dd10dd10dd1d100dd1dd100dd1dd100d1dd1ddddd1dd1d10000000000000000000000000000000000
000000000000000000000000000000000dd1000d0dd1111dd10dd100dd110dd11dd10dd11dd10dd1d11dd11110dd110000000000000000000000000000000000
000000000000000000000000000000000dd100dd1dd1000dd10dd1000ddd0dd11dd10dd11dd10ddd110dd100000ddd0000000000000000000000000000000000
0000000000000000000000000000000000dd00d11dd1000dd10dd10d11dd1dd11dd10dd11dd10dd11d0dd1000d11dd1000000000000000000000000000000000
00000000000000000000000000000000000ddd110d110000ddd1dd00ddd110ddd1dd001dd1dd00ddd11d110000ddd11000000000000000000000000000000000
00000000000000000000000000000000000011100010000001110110011100011101100011011001110010000001110000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ddd0ddd0ddd00dd00dd000000ddddd0000d00ddddd000000ddd00dd000000dd0ddd0ddd0ddd0ddd0000000000000000000000000
000000000000000000000000d1d1d1d1d111d011d0110000dd1d1dd00d01dd111dd000000d11d0d10000d0110d11d1d1d1d10d11000000000000000000000000
000000000000000000000000ddd1dd01dd00ddd0ddd00000ddd0ddd10d10dd1d0dd100000d10d1d10000ddd00d10ddd1dd010d10000000000000000000000000
000000000000000000000000d111d1d0d11001d101d10000dd1d0dd10d10dd101dd100000d10d1d1000001d10d10d1d1d1d00d10000000000000000000000000
000000000000000000000000d100d1d1ddd0dd01dd0100000ddddd11d0100ddddd1100000d10dd010000dd010d10d1d1d1d10d10000000000000000000000000
00000000000000000000000001000101011101100110000000111110010000111110000000100110000001100010010101010010000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3232323232323032323232323232323232323232323232323232323232323232320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323030323232323232323232101010101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323230303232323232323232101010101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323232301010323232323232101010101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232101010303010103232323232101032101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323210101010303010101010323232323210323210101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010301010202020101010101010101010323210101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020201020202020302020202020202010101010103232323210101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020201020202020201020202010101010101010321010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010202020101010301010101010101010103232323210101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101030301010103232323232321010321010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323210101030301032323232323232101010101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232103030323232323232323232101010101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323032323232323232323232101010101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323030323232323232323232101010101010101010101010101010320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323230323232323232323232323232323232323232323232323232320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00040000151301f100111001210011100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00030000115300d5001a5001750017500175001c5001c50019500135001a5001850016500185002d000175001f500165001450014500105001250014500165001950014500165001550011500175003e50015500
000800001364006620076000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010e00000c5000e0000e5000c5001050010500100000c5001050010500000000c500105000e50013500105000c5001050010500115000c500000000c500105000000000000000000000000000000000000000000
__music__
00 01424344

