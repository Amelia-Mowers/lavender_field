pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--lavender field crusaders
--by mia mowers

function _init()
  init_action_menu()

  state = "pick"
  next_state = nil
  
  mob_c = new_comp()
  speed_c = new_comp()
  removal_timer_c = new_comp()
  
  bounds = vec2:new(7, 7)
  
  anim_timer
   = timer:new(.5)
   
  select_cool
   = timer:new(0.3)
   
  move_cooldown
   = timer:new(0.6)
   
  moved_last = false
  
  move_path = {}
  
  pointer = insert({
    {pos_c, vec2:new()},
    {
      sprite_c, 
      sprite:new({1,9},3)
    },
  })
  
  menu_cursor = insert({
  		{visible_c, false},
    {pos_c, vec2:new()},
    {
      menu_cursor_c, 
      menu_cursor:new(
      		action_menu,
      		vec2:new(-0.5,0)
      )
    },
    {
      sprite_c, 
      sprite:new({13,45},3)
    },
  })
  
  target = insert({
    {pos_c, vec2:new()},
    {
      sprite_c, 
      sprite:new({41},2)
    },
    {visible_c, false},
  })
  target_selection = nil
  
  knight = insert({
    {pos_c, vec2:new(1,3)},
    {
      sprite_c, 
      sprite:new({3,35})
    },
    {mob_c},
    {actions_c, {
      {"move", move_option},
      {"foo", do_nothing},
      {"bar", do_nothing},
    }},
  })
  
  wiz = insert({
    {pos_c, vec2:new(3,3)},
    {
      sprite_c, 
      sprite:new({5,37})
    },
    {mob_c},
    {actions_c, {
      {"move", move_option},
      {"bar", do_nothing},
      {"baz", do_nothing},
      {"buzz", do_nothing},
    }},
  })
  
  gnome = insert({
    {pos_c, vec2:new(5,3)},
    {
      sprite_c, 
      sprite:new({7,39})
    },
    {mob_c},
  })
  
  insert({
    {pos_c, vec2:new(1,5)},
    {
      sprite_c, 
      sprite:new({64,96})
    },
    {mob_c},
  })
  
  insert({
    {pos_c, vec2:new(3,5)},
    {
      sprite_c, 
      sprite:new({66,98})
    },
    {mob_c},
  })
  
  insert({
    {pos_c, vec2:new(5,5)},
    {
      sprite_c, 
      sprite:new({68,100})
    },
    {mob_c},
  })
  
  insert({
    {pos_c, vec2:new(7,5)},
    {
      sprite_c, 
      sprite:new({70,102})
    },
    {mob_c},
  })
end



function move_block(pos, index) 
  tile_block = fget(
    mget(pos.x*2, pos.y*2), 0
  )
  
  obj_block = false
 
  for e 
  in all(index[pos:key()]) do
    if mob_c[e] != nil then
      obj_block = true
      break
    end
  end  
  
  return 
    tile_block or obj_block
end
 
function _update()
  update_state()
		timed_removal()
		select_cool:tick()
  if state == "pick" then
  		pointer_control_pad()
    target_select()
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
      move_path = path_to(
        pos_c[target_selection],  -- start from the selected entity
        pos_c[pointer],           -- path to where the pointer is
        move_block
      )
    end
    set_action_target()
    trigger_action()
  end
  update_menu_cursor()
  update_anim()
end

function update_state()
		if next_state != nil then
		  state = next_state
		  next_state = nil
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

function update_anim()
		anim_timer:tick()
		if anim_timer.just_finished
		then
				anim_timer:restart()
		  for _, sprite
		  in pairs(sprite_c) do
		    sprite.a_index += 1
		    if sprite.a_index
		    > count(sprite.tiles)
		    then
		      sprite.a_index = 1
		    end
		  end
		end
end
 
function _draw()
  cls()
  map()
  render_objects()
  if state == "target" then
    render_path()
  end
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
   for e, pos 
   in pairs(pos_c) do
     if pointer_pos == pos
     and mob_c[e] != nil then
       target_selection = e
       pos_c[target] = 
         pos:copy()
    			visible_c[target]
      			= true
    			visible_c[pointer]
      			= false
      	pos_c[action_range] = 
         pos:copy()
       next_state = "menu"
       open_action_menu()
     end
   end
  end
end

function target_deselect()
  if btn(🅾️) then
    target_selection = nil
    visible_c[target]
      = false
    next_state = "pick"
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
	 end
end

-->8
--utils

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
visible_c = new_comp()

sprite = {}
text = {}
rectangle = {}
fill_zone = {}

function sprite:new(
  tiles,
  order,
  size
)
  return {
    tiles   = tiles,
    a_index = 1,
    order   = order or 1,
    size   = size or 2
  }
end

function text:new(
  txt, 
  col, 
  order
)
  return {
    text = txt,
    col = col or 6,
    order = order or 1
  }
end

function rectangle:new(
  size, 
  fill, 
  border, 
  order
)
  return {
    size = size,
    fill = fill   or 0,
    border = border 
      or fill or 0,
    order = order  or 1
  }
end

function fill_zone:new(
  block_func, 
  range, 
  border, 
  order
)
  return {
    block_func = block_func,
    range = range,
    border = border or 0,
    order = order  or 1
  }
end

function render_objects()
  palt(0, false)
  palt(2, true)

  local render_layers = {}

  for e, s 
  in pairs(sprite_c) do
    local visible 
      = visible_c[e]
    if visible == nil 
    or visible == true then
      if render_layers[s.order]
      == nil then
        render_layers[s.order] 
          = {}
      end
      add(
        render_layers[s.order], 
        {
          class="sprite", 
          e=e,
          data=s
        }
      )
    end
  end

  for e, t in pairs(text_c) do
    local visible
      = visible_c[e]
    if visible == nil 
    or visible == true then
      if render_layers[t.order]
      == nil then
        render_layers[t.order] 
          = {}
      end
      add(
        render_layers[t.order], 
        {
          class="text", 
          e=e, 
          data=t
        }
      )
    end
  end

  for e, r in pairs(rect_c) do
    local visible 
      = visible_c[e]
    if visible == nil 
    or visible == true then
      if render_layers[r.order]
      == nil then
        render_layers[r.order] 
          = {}
      end
      add(
        render_layers[r.order], 
        {
          class="rect", 
          e=e, 
          data=r
        }
      )
    end
  end

  for e, r 
  in pairs(fill_zone_c) do
    local visible 
      = visible_c[e]
    if visible == nil 
    or visible == true then
      if render_layers[r.order]
      == nil then
        render_layers[r.order] 
          = {}
      end
      add(
        render_layers[r.order], 
        {
          class="fill_zone", 
          e=e, 
          data=r
        }
      )
    end
  end

  for l, list
  in pairs(render_layers) do
    for obj 
    in all(list) do
      local e   = obj.e
      local d   = obj.data
      local pos = pos_c[e]

      if obj.class
      == "sprite"
      then
        local tile
          = d.tiles[d.a_index]
        spr(
          tile,
          pos.x*16,
          pos.y*16,
          d.size,
          d.size
        )

      elseif obj.class
      == "text" then
        print(
          d.text,
          pos.x*16,
          pos.y*16, 
          d.col
        )

      elseif obj.class 
      == "rect" then
        local corn
          = pos + d.size
        rectfill(
          pos.x*16,
          pos.y*16,
          corn.x*16,
          corn.y*16,
          d.fill
        )
        rect(
          pos.x*16,
          pos.y*16,
          corn.x*16,
          corn.y*16,
          d.border
        )

      elseif obj.class 
      == "fill_zone" then
        field = d_field:new(
          pos, d.block_func
        )
        field:expand_to(
          nil, 
          d.range
        )
  
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
  
        for p 
        in all(field.total) do
          local px = p.x * 16
          local py = p.y * 16
    
          for _, edge 
          in pairs(edges) do
            local neighbor
              = p[edge.dir](p)
            if field.field[
              neighbor:key()
            ] == nil then
              line(
                px + edge.dx1,
                py + edge.dy1,
                px + edge.dx2,
                py + edge.dy2,
                d.border
              )
            end
          end
      
          for _, corner 
          in pairs(corners) do
            local neighbor
              = corner.dir1(p)
            local neighbor
              = corner.dir2(
                neighbor
              )
            if field.field[
              neighbor:key()
            ] == nil then
              pset(
                px + corner.dx,
                py + corner.dy,
                d.border
              )
            end
          end
        end
      end
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
	 return obj
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
        n, index
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
		  
		  if elem_e != nil do
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
	 
	   if menu_c[c.focus].elems[
	     new_pos:key()] != nil
	   then
	 		  sfx(1)
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
        c.pos:key()] 
       
      if menu_select_c[elem]
      != nil then
	 		    sfx(1)
	 		    menu_select_c[elem]()
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



-->8
--action menu

actions_c = new_comp()

function init_action_menu()
  selected_action = nil
  action_targets = {}
  needed_act_t = nil
  
  action_range = insert({
    {pos_c, vec2:new(4,4)},
    {
      fill_zone_c, 
      fill_zone:new(
        move_block, 
        3,
        13
      )
    },
    {visible_c, false},
  })
  
  action_menu = insert({
  		{pos_c, vec2:new(2,2)},
  		{visible_c, false},
  		{rect_c, rectangle:new(
  				vec2:new(2,2),1,6,2
  		)},
    {menu_c, menu:new({})},
    {
      menu_back_c,
      action_menu_back
    }
  })
end

function action_menu_back()
  target_selection = nil
  visible_c[target]
    = false
  visible_c[pointer]
    = true
  next_state = "pick"
  
  hide_action_menu()
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
  
  o_pos = vec2:new(2.5,2.25)
  pos = o_pos:copy()
  menu_pos = vec2:new()
  menu_size = vec2:new()
  for a
  in all(actions_c[
    target_selection
  ]) do
    label = vec2:new()
    label.x, label.y =
      print(a[1],0,-10)
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
        a[1],6,3
      )},
      {menu_select_c, a[2]} 
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
end

function move_option()
  selected_action = move_action
  needed_act_t = 1
  
  visible_c[action_range]
    = true
  fill_zone_c[
    action_range].range = 4
  
  exit_action_menu()
end

function move_action()
  target_pos 
    = pos_c[target_selection]
   
  if action_targets[1] != nil 
  and move_path != nil 
  and #move_path > 0 then
    pos_c[target_selection] 
      = move_path[1]
  end
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
    
		  point_pos
		    = pos_c[pointer]
		   
    add(
      action_targets,
      point_pos:copy()
    )
  end
end


function trigger_action()
  if needed_act_t
  == #action_targets
  then
    selected_action()
    selected_action = nil
    action_targets = {}
    needed_act_t = nil
    target_selection = nil
    visible_c[target]
      = false
    visible_c[action_range]
      = false
    next_state = "pick"
  end
end
__gfx__
00000000777722222222777722222222222222222222222222222222222222222222222222222222222222222222222222222222222662222222222200000000
0000000072222222222222272222200000022222222000000002222222222222222222222777222222227772222ee222222ee222222666222222222200000000
00700700722222222222222722220dddddd02222220ddddddd000222222222202222222227222222222222722ee22ee22ee22ee2222666622222222200000000
0007700072222222222222272220ddddddd000222220ddddd0aaa0222222220d0222222227222222222222722222222222222222222666222222222200000000
0007700022222222222222222220d00000d060222220ddddd0aaa022222220ddd022222222222222222222222222222222222222222662222222222200000000
0070070022222222222222222220d00000d06022220dddddd0aaa02222220ddddd022222222222222222222222ee222222ee2222222222222222222200000000
0000000022222222222222222220ddd0ddd06022220000000000022222220dddddd022222222222222222222ee22ee22ee22ee22222222222222222200000000
0000000022222222222222222220ddd0ddd0602222220111110d022222200d0000d0022222222222222222222222222222222222222222222222222200000000
222222222222222222222222200000d0dd0000022222201110000022220600111100602222222222222222222222222222222222222222222222222200000000
2222e2e2222222222222222220666000000ddd022200000000ddd02222060111111060222222222222222222222ee222222ee222222222222222222200000000
22222e222222222222222222206660dddd0ddd02220dd0ddd0ddd022200000111100000222222222222222222ee22ee22ee22ee2222222222222222200000000
222222222222222222222222206660dddd000002220dd0ddd000002220ddd000000ddd0222222222222222222222222222222222222222222222222200000000
222222227222222222222227200000ddddd06022220000dddd0d022220ddd0dddd0ddd0227222222222222722222222222222222222222222222222200000000
2e2e2222722222222222222722220dd00dd0002222220dd00d000222200000d00d000002272222222222227222ee222222ee2222222222222222222200000000
22e22222722222222222222722220dd00dd0222222220dd00dd0222222220dd00dd022222777222222227772ee22ee22ee22ee22222222222222222200000000
22222222777722222222777722222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
22222222000000000000000022222222222222222222222222222222222222222222222266662222222266662222222222222222226622222222222200000000
2ee222e2000000000000000022222222222222222222222222222222222222222222222262222222222222262222ee222222ee22226662222222222200000000
2ee222220006600000000000222220000002222222200000000222222222222222222222622222222222222622ee22ee22ee22ee226666222222222200000000
2222e222006666000000000022220dddddd00022220ddddddd000222222222202222222262222222222222262222222222222222226662222222222200000000
2222222200666600000000002220ddddddd060222220ddddd0aaa0222222220d0222222222222222222222222222222222222222226622222222222200000000
22222ee200066000000000002220d00000d060222220ddddd0aaa022222220ddd02222222222222222222222222ee222222ee222222222222222222200000000
2e222ee200000000000000002220d00000d06022220dddddd0aaa02222220ddddd02222222222222222222222ee22ee22ee22ee2222222222222222200000000
2222222200000000000000002220ddd0ddd06022220000000000022222200dddddd0022222222222222222222222222222222222222222222222222200000000
222222220000000000000000200000d0dd00000222220111110d022222060d0000d0602222222222222222222222222222222222222222222222222200000000
2222ee220000000000000000206660d0dd0ddd022200001110000022220600111100602222222222222222222222ee222222ee22222222222222222200000000
22ee22ee000000000000000020666000000ddd02220dd00000ddd0222000001111000002222222222222222222ee22ee22ee22ee222222222222222200000000
222222220000000000000000206660dddd000002220dd0ddd0ddd02220ddd011110ddd0222222222222222222222222222222222222222222222222200000000
222222220000000000000000200000ddddd06022220000ddd000002220ddd000000ddd0262222222222222262222222222222222222222222222222200000000
22ee2222000000000000000022220dddddd0002222220ddddd0d0222200000dddd0000026222222222222226222ee222222ee222222222222222222200000000
ee22ee22000000000000000022220dd00dd0222222220dd00d00022222220dd00dd0222262222222222222262ee22ee22ee22ee2222222222222222200000000
22222222000000000000000022222222222222222222222222222222222222222222222266662222222266662222222222222222222222222222222200000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222220000002222200000000000000000000000000000000
22220022220022222222222222222222222222000022222222222222222222222222222222222222222002222220022200000000000000000000000000000000
22220302203022222222222222222222222220666602222222222222222222222222222222222222220222222222202200000000000000000000000000000000
2222033003302222222222222222222222220606066022222222222222222222222222222222222220222222ee22220200000000000000000000000000000000
222203333330222222222222222222222222060600602222222222222222222222222000002222222022ee22ee22220200000000000000000000000000000000
222200000000222220000002222222222222066666602222222222222222222222222099990222222022ee222222220200000000000000000000000000000000
22220090990022222055550222222222222220606602222222222222222222222222099999902222202222222222220200000000000000000000000000000000
22220000000022222050550000222222222220666602222222222200002222222222099999902222202222222ee2220200000000000000000000000000000000
2222033333302222205555055502222222000000600000222222203333022222222209999990222220222ee22ee2220200000000000000000000000000000000
2200003333000022205555055550222222066066660660222222033333302222222209999990222220222ee22222220200000000000000000000000000000000
22033033330330222000000555502222220660006006602222220303303022222222209999022222220222222222202200000000000000000000000000000000
22033033330330222222055555502222220000666600002222220303303022222222220000222222222002222220022200000000000000000000000000000000
22000030030000222222055005502222222206600660222222220333333022222222222222222222222220222202222200000000000000000000000000000000
22220330033022222222055005502222222206600660222222220333333022222222222222222222222220222202222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220022220022222222222222222222222222000022222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220302203022222222222222222222222220666602222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220330033022222222222222222222222206060660222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220333333022222222222222222222222206060060222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220000000022222000000222222222222206666660222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220090990022222055550222222222222220606602222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22220000000022222050550000222222220000666600002222222200002222220000000000000000000000000000000000000000000000000000000000000000
22000033330000222055550555022222220660006006602222222033330222220000000000000000000000000000000000000000000000000000000000000000
22033033330330222055550555502222220660666606602222220333333022220000000000000000000000000000000000000000000000000000000000000000
22033033330330222000000555502222220000006000002222220303303022220000000000000000000000000000000000000000000000000000000000000000
22000033330000222222055555502222222206666660222222220303303022220000000000000000000000000000000000000000000000000000000000000000
22220330033022222222055005502222222206600660222222220333333022220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
__label__
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e2
22222e2222222e2222222e2222222e2222222e222ee2222222222e2222222e2222222e2222222e2222222e2222222e2222222e222ee2222222222e2222222e22
22222222222222222222222222222222222222222222e222222222222222222222222222222222222222222222222222222222222222e2222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e22222e2e22222e2e222222222ee22e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e222222222ee22e2e22222e2e2222
22e2222222e2222222e2222222e2222222e222222e222ee222e2222222e2222222e2222222e2222222e2222222e2222222e222222e222ee222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22ee222e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e2
22222e2222222e2222222e2222222e2222222e222ee222222ee222222ee2222222222e2222222e2222222e2222222e2222222e2222222e222ee2222222222e22
22222222222222222222222222222222222222222222e2222222e2222222e2222222222222222222222222222222222222222222222222222222e22222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222202222222222222222222222222222222222222222
2e2e22222e2e22222e2e22222e2e22222e2e222222222ee222222ee222222ee22e2e22222e2e22222e2e220d0e2e22222e2e22222e2e222222222ee22e2e2222
22e2222222e2222222e2222222e2222222e222222e222ee22e222ee22e222ee222e2222222e2222222e220ddd0e2222222e2222222e222222e222ee222e22222
2222222222222222222222222222222222222222222222222222222222222222222222222222222222220ddddd02222222222222222222222222222222222222
2222222222222222222222222222222222222222222222222222222222222222222222222222222222200dddddd0022222222222222222222222222222222222
2222e2e22222e2e22ee222e22222e2e22ee222e22ee222e22222e2e22222e2e22ee222e22ee222e222060d1111d060e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e222ee2222222222e222ee222222ee2222222222e2222222e222ee222222ee22222220601111110602222222e2222222e2222222e2222222e22
22222222222222222222e222222222222222e2222222e22222222222222222222222e2222222e222200000111100000222222222222222222222222222222222
2222222222222222222222222222222222222222222222222222222222222222222222222222222220ddd011110ddd0222222222222222222222222222222222
2e2e22222e2e222222222ee22e2e222222222ee222222ee22e2e22222e2e222222222ee222222ee220ddd0dddd0ddd022e2e22222e2e22222e2e22222e2e2222
22e2222222e222222e222ee222e222222e222ee22e222ee222e2222222e222222e222ee22e222ee2200000d00d00000222e2222222e2222222e2222222e22222
2222222222222222222222222222222222222222222222222222222222222222222222222222222222220dd00dd0222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22ee222e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e2222222e222ee222222ee2200000022e2222222e2222222e2222222e2222222e2222222e222ee2222222222e2222222e2222222e2222222e22
2222222222222222222222222222e22222220dddddd0222222222222222222222222222222222222222222222222e22222222222222222222222222222222222
222222222222222222222222222222222220ddddddd0002222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e222222222ee22220d11111d060222e2e22222e2e22222e2e22222e2e22222e2e222222222ee22e2e22222e2e22222e2e22222e2e2222
22e2222222e2222222e222222e222ee22e20d11111d0602222e2222222e2222222e2222222e2222222e222222e222ee222e2222222e2222222e2222222e22222
222222222222222222222222222222222220ddd1ddd0602222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222200000d1ddd0602222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22ee222e22222e2e2206660d1dd0000022222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e2
22222e2222222e222ee2222222222e2220666011110ddd0222222e2222222e2222222e2222222e2222222e2222222e2222222e222ee2222222222e2222222e22
22222222222222222222e22222222222206660dddd0ddd02222222222222222222222222222222222222222222222222222222222222e2222222222222222222
22222222222222222222222222222222206660dddd00000222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e222222222ee22e2e2222200000ddddd060222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e222222222ee22e2e22222e2e2222
22e2222222e222222e222ee222e2222222e20dd00dd0002222e2222222e2222222e2222222e2222222e2222222e2222222e222222e222ee222e2222222e22222
2222222222222222222222222222222222220dd00dd0222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e222ee2222222222e2222222e2222222e222ee2222222222e222200000000222e2222222e2222222e2222222e2222222e2222222e2222222e22
22222222222222222222e2222222222222222222222222222222e2222222222220dddddddd022222222222222222222222222222222222222222222222222222
2222222222222222222222222222222222222222222222222222222222222222220ddddddd000222222222222222222222222222222222222222222222222222
2e2e22222e2e222222222ee22e2e22222e2e22222e2e222222222ee22e2e22222e20ddddd0aaa0222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e2222222e222222e222ee222e2222222e2222222e222222e222ee222e2222222e0ddddd0aaa02222e2222222e2222222e2222222e2222222e2222222e22222
2222222222222222222222222222222222222222222222222222222222222222220dddddd0aaa022222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222200000000000222222222222222222222222222222222222222222222222222
2222e2e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e222220111110d02e22ee222e22ee222e22222e2e22222e2e22222e2e22222e2e2
22222e222ee2222222222e2222222e2222222e2222222e2222222e2222222e2222200001100000222ee222222ee2222222222e2222222e2222222e2222222e22
222222222222e2222222222222222222222222222222222222222222222222222220dd0dd0ddd0222222e2222222e22222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222220dd0dd0ddd022222222222222222222222222222222222222222222222222
2e2e222222222ee22e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e20000dd000002222222ee222222ee22e2e22222e2e22222e2e22222e2e2222
22e222222e222ee222e2222222e2222222e2222222e2222222e2222222e2222222e20dd00d0d02222e222ee22e222ee222e2222222e2222222e2222222e22222
222222222222222222222222222222222222222222222222222222222222222222220dd00d000222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22ee222e22222e2e22222e2e2277722e2222277722ee222e22222e2e22ee222e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e222ee2222222222e2222222e2227e2222222222e722ee2222222222e222ee222222ee2222222222e2222222e2222222e2222222e2222222e2222222e22
222222222222e22222222222222222222722e222222222722222e222222222222222e2222222e222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e222222222ee22e2e22222e2e222222222ee22e2e222222222ee22e2e222222222ee222222ee22e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e222222e222ee222e2222222e222222e222ee222e222222e222ee222e222222e222ee22e222ee222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e2
22222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e222ee2222222222e22
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222e22222222222
22222222222222222222222222222222272222222222227222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e22222e2e2222272e22222e2e22722e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e222222222ee22e2e2222
22e2222222e2222222e2222222e222222777222222e2777222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e222222e222ee222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22ee222e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e222ee222222ee2222222222e2222222e2222222e2222222e2222222e222ee2222222222e2222222e2222222e2222222e2222222e2222222e22
22222222222222222222e2222222e22222222222222222222222222222222222222222222222e222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e222222222ee222222ee22e2e22222e2e22222e2e22222e2e22222e2e222222222ee22e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e2222222e222222e222ee22e222ee222e2222222e2222222e2222222e2222222e222222e222ee222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
2ee2222222222e2222222e2222222e2222222e2222222e2222222e222ee2222222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22
2222e2222222222222222222222222222222222222222222222222222222e2222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222ee22e2e22222e2e22222e2e22222e2e22222e2e22222e2e222222222ee22e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
2e222ee222e2222222e2222222e2222222e2222222e2222222e222222e222ee222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222e2e22222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22ee222e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2
22222e2222222e2222222e222ee2222222222e2222222e2222222e222ee2222222222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22
2222222222222222222222222222e2222222222222222222222222222222e2222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2e2e22222e2e22222e2e222222222ee22e2e22222e2e22222e2e222222222ee22e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e22222e2e2222
22e2222222e2222222e222222e222ee222e2222222e2222222e222222e222ee222e2222222e2222222e2222222e2222222e2222222e2222222e2222222e22222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010201010101010101020101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010202020101010101010201010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010201020201010202010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010102020101010101010201010101020101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010201010101010101010101020101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010201010102010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1020101010101010101020201010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1020101020102010202010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010201010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010202010101010102010101010101010201010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2010101010101020101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010102010101020101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100000105301f500115001250011500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000115200d5001a5001750017500175001c5001c50019500135001a5001850016500185002d000175001f500165001450014500105001250014500165001950014500165001550011500175003e50015500
001000000000019500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001a5001a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

