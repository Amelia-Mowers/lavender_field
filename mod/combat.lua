attack_anim_c,float_c,damage_notice_c,health_bar_c=batch_comp(4)

health={}
health.__index=health

function health:new(t)
  local o={total=t,dam=0}
  setmetatable(o,health)
  return o
end

function health.dead(s) return s.dam>=s.total end
function health.alive(s) return not s:dead() end

dam_type = {
  phys = "physical",
}

function damage(e,d,t)
  local t = t or dam_type.phys
  local def = defense_c[e][t] or 0
  local dam = min(d-def,0)
  health_c[e].dam+=dam
  spawn_damage_number(e,dam)
end

function new_health_bar()
  return {
    insert({
      {pos_c,vec2:new()},
      {rect_c,rectangle:new(vec2:new(11/16,1/16),3,3,4)}
    }),
    insert({
      {pos_c,vec2:new()},
      {rect_c,rectangle:new(vec2:new(11/16,1/16),1,1,3)}
    })
  }
end

function update_health_bars()
  for e,h in pairs(health_c) do
    if h.dam>0 and not health_bar_c[e] then
      health_bar_c[e]=new_health_bar()
    end
  end 

  for e,h_e in pairs(health_bar_c) do
    local base_pos=pos_c[e]
    local h=health_c[e] or {total=1,dam=1}
    
    local vis=h.dam>0
    visible_c[h_e[1]]=vis
    visible_c[h_e[2]]=vis
    
    local len=(h.total-h.dam)/h.total*11/16
    local cur_len=rect_c[h_e[1]].size.x
    
    if cur_len<=0.01 then
      visible_c[h_e[1]]=false
      visible_c[h_e[2]]=false
    end
    
    local new_len=len*.1+cur_len*.9
    rect_c[h_e[1]].size.x=new_len
    
    local fill,border=8,8
    if new_len>0.5 then
      fill,border=3,3
    elseif new_len>0.3 then
      fill,border=9,9
    end
    rect_c[h_e[1]].fill=fill
    rect_c[h_e[1]].border=border
    
    local new_pos=base_pos+vec2:new(1/8,-2/16)
    pos_c[h_e[1]]=new_pos
    pos_c[h_e[2]]=new_pos
  end
end

function spawn_damage_number(e,d)
  local p=pos_c[e]:copy()
  p.y+=0.1
  p.x+=0.5+rnd(0.05)-0.025
  
  insert({
    {pos_c,p},
    {text_c,text:new(tostring(d),8,0,5)},
    {float_c,{
      speed=vec2:new(0,-0.04),
      accel=vec2:new(0,0.001)
    }},
    {damage_notice_c},
    {removal_timer_c,timer:new(1.5)}
  })
end

function update_floating_entities()
  for e,f in pairs(float_c) do
    pos_c[e]+=f.speed
    f.speed+=f.accel
  end
end

function update_damage_notices()
  for e,_ in pairs(damage_notice_c) do
    local t=removal_timer_c[e]
    if t then
      local lf=1-t:fract()
      text_c[e].col=lf<0.3 and 5 or (lf<0.6 and 9 or 8)
    end
  end
end

function move_block(pos,index)
  if not pos:in_bound(bounds) then return true end
  
  if fget(map_get(pos),0) then return true end
  
  for e in all(index[pos:key()]) do
    if block_move_c[e] then return true end
  end
  
  return false
end

function no_block() return false end

function reset_actions()
  for e in pairs(actions_c) do
    actions_c[e]=2
    palette_c[e]=nil
    move_points_c[e]=0
  end
end

function death_check()
  for e,h in pairs(health_c) do
    if h:dead() then
      local r=remains_c[e] or st.skull
      health_c[e]=nil
      block_move_c[e]=nil
      block_sight_c[e]=nil
      cover_tile_c[e]=nil
      sprite_c[e].tiles=r
      sprite_c[e].order=1
      
      if child_c[e] then
        for c in all(child_c[e]) do
          sprite_c[c]=nil
        end
      end
      
      update_fog_of_war()
    end
  end
end

function trigger_end_turn()
  local units_remain,living_remain=false,false
  
  for e in pairs(player_c) do
    if health_c[e] then
      living_remain=true
      if actions_c[e]>0 or move_points_c[e]>0 then
        units_remain=true
        break
      end
    end
  end
  
  if not units_remain and living_remain then
    next_state="enemy_turn"
  end
end

function victory_check()
  for e in pairs(mob_c) do
    if not player_c[e] and health_c[e] then
      return
    end
  end
  next_state="victory"
end

function update_attack_animations()
  for e,a in pairs(attack_anim_c) do
    a.t:tick()
    local f=a.t:fract()
    local d=a.dir
    
    if d.x!=0 and d.y!=0 then d*=0.7071 end
    
    local b=(1-2*abs(f-0.5))^2
    offset_c[e]=d*b*0.4
    
    if a.t.finished then
      attack_anim_c[e]=nil
      offset_c[e]=vec2:new()
    end
  end
end