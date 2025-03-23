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
