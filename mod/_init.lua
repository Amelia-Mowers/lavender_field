function _init()
  debug_print = {}
  init_action_menu()
  init_status_window()
  
  exp = 0
  
  cur_map = maps.trail
  
  state = "start"
  next_state = nil
  
  bounds = vec2:new(15, 15)
  
  anim_timer
    = timer:new(.5)
    
  select_cool
    = timer:new(0.3)
    
  move_cooldown
    = timer:new(0.6)
    
  moved_last = false
  
  e_action_timer 
    = timer:new(0.6)
  e_action_timer.finished 
    = true
  
  pointer = insert({
    {pos_c, vec2:new()},
    {
      sprite_c, 
      sprite:new(st.point,5)
    },
  })
  
  camera_focus = pointer
  camera_pos = vec2:new()
  
  target = insert({
    {pos_c, vec2:new()},
    {
      sprite_c, 
      sprite:new(st.point,4)
    },
    {palette_c, {[7] = 6}},
    {states_visible_c, {
      target = true,
      menu = true,
    }}
  })
  target_selection = nil
  
  grey_scale = {
    [0] = 0,
      5,5,5,5,5,5,5,
    5,5,5,5,5,5,5,5
  }
  
  init_map()
  
  update_fog_of_war()
  update_child_pos()
end