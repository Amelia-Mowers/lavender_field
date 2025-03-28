function _update()
  debug_print = {}
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
  if state == "target" then
    pointer_control_pad()
    target_deselect()
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
  if state == "loss" then
    loss_control()
  end
  menu_cursor_control()
  menu_select()
  menu_back()
  loss_check()
  death_check()
  update_health_bars()
  update_menu_cursor()
  update_anim()
  update_floating_entities()
  update_notice_texts()
  update_attack_animations()
end

function update_state()
  if next_state != nil then
    state = next_state
    next_state = nil
  end
end