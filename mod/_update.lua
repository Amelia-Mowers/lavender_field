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

  function update_state()
    if next_state != nil then
      state = next_state
      next_state = nil
    end
  end