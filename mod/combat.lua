-- 906

attack_anim_c,
float_c,
damage_notice_c = batch_comp(3)

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

function update_floating_entities()
	for e, float_data in pairs(float_c) do
	  pos_c[e] = pos_c[e] + float_data.speed
	  float_data.speed = float_data.speed + float_data.accel
	end
  end
  
  function update_damage_notices()
	for e, _ in pairs(damage_notice_c) do
	  if removal_timer_c[e] then
		local life_fraction = 1 - removal_timer_c[e]:fract()
		if life_fraction < 0.3 then
		  text_c[e].col = 5
		elseif life_fraction < 0.6 then
		  text_c[e].col = 9
		else
		  text_c[e].col = 8
		end
	  end
	end
  end

function move_block(pos, index)
	if pos:in_bound(bounds) == false then
	  return true
	end
	tile_block = fget(map_get(pos), 0)
	obj_block = false
	for e in all(index[pos:key()]) do
	  if block_move_c[e] != nil then
		obj_block = true
		break
	  end
	end
	return tile_block or obj_block
  end
  
  function no_block(pos, index)
	return false
  end
  


function reset_actions()
	for e, _ in pairs(actions_c) do
	  actions_c[e] = 2
	  palette_c[e] = nil
	  move_points_c[e] = 0
	end
  end

  function death_check()
	for e, h in pairs(health_c) do
	  if h:dead() then
		remains = st.skull
		if remains_c[e] != nil then
		  remains = remains_c[e]
		end
		health_c[e] = nil
		block_move_c[e] = nil
		block_sight_c[e] = nil
		cover_tile_c[e] = nil
		sprite_c[e].tiles = remains
		sprite_c[e].order = 1
		if child_c[e] != nil then
		  for c in all(child_c[e]) do
			sprite_c[c] = nil
		  end
		end
		update_fog_of_war()
	  end
	end
  end



  function trigger_end_turn()
	remaining_units = false
	for e, _ in pairs(player_c) do
	  if actions_c[e] > 0 or move_points_c[e] > 0 and health_c[e] != nil then
		remaining_units = true
		break
	  end
	end
	remaining_living = false
	for e, _ in pairs(player_c) do
	  if health_c[e] != nil then
		remaining_living = true
		break
	  end
	end
	if remaining_units == false and remaining_living == true then
	  next_state = "enemy_turn"
	end
  end
  
  function victory_check()
	remaining_enemies = false
	for e, _ in pairs(mob_c) do
	  if player_c[e] == nil and health_c[e] != nil then
		remaining_enemies = true
		break
	  end
	end
	if remaining_enemies == false then
	  next_state = "victory"
	end
  end



  function update_attack_animations()
	for e, anim in pairs(attack_anim_c) do
	  anim.t:tick()
	  local fract = anim.t:fract()
	  local dir = anim.dir
	  if dir.x != 0 and dir.y != 0 then
		dir = dir * 0.7071
	  end
	  local bounce = 1 - 2 * abs(fract - 0.5)
	  bounce = bounce * bounce
	  local max_extent = 0.4
	  offset_c[e] = dir * bounce * max_extent
	  if anim.t.finished then
		attack_anim_c[e] = nil
		offset_c[e] = vec2:new()
	  end
	end
  end
  