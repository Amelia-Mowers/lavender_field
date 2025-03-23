function _init()
    debug_print = ""
    init_action_menu()
    init_status_window()
    
    cur_map = maps.trail
    
    state = "start"
    next_state = nil
    
    name_c = new_comp()
    mob_c = new_comp()
    obj_c = new_comp()
    speed_c = new_comp()
    move_points_c = new_comp()
    health_c = new_comp()
    attack_c = new_comp()
    player_c = new_comp()
    
    sight_c = new_comp()
    block_move_c = new_comp()
    block_sight_c = new_comp()
    removal_timer_c = new_comp()
    attack_anim_c = new_comp()
    float_c = new_comp()
    damage_notice_c = new_comp()
    cover_tile_c = new_comp()
    
    local_pos_c = new_comp()
    child_c = new_comp()
    remains_c = new_comp()
    
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
    
    move_path = {}
    
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
    
    possible_tar = insert({
      {pos_c, vec2:new()},
      {
        multi_sprite_c, 
        multi_sprite:new(
          st.point, 4, nil, {}
        )
      },
      {palette_c, {[7] = 9}}
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