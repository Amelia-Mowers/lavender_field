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
