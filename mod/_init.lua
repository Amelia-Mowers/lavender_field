function _init()
    debug_print = ""
    init_action_menu()
    init_status_window()
    
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
        sprite:new(
          st.menu_curs,
          7,1
        )
      },
      {static_c},
    })
    
    target = insert({
      {pos_c, vec2:new()},
      {
        sprite_c, 
        sprite:new(st.point,2)
      },
      {visible_c, false},
      {palette_c, {[7] = 6}}
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