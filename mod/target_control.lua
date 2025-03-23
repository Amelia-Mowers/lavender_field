function target_select()
    if btn(❎) and select_cool.finished then
      select_cool:restart()
      pointer_pos = pos_c[pointer]
      tar = nil
      tar_pos = nil
      for e, pos in pairs(pos_c) do
        if pointer_pos == pos 
        and mob_c[e] != nil 
        and health_c[e] != nil 
        and player_c[e] != nil 
        and (actions_c[e] > 0 or move_points_c[e] > 0) 
        then
          tar = e
          tar_pos = pos
          break
        end
      end
      if tar != nil then
        target_selection = tar
        pos_c[target] = tar_pos:copy()
        visible_c[target] = true
        visible_c[pointer] = false
        pos_c[action_range] = tar_pos:copy()
        pos_c[action_range_2] = tar_pos:copy()
        next_state = "menu"
        open_action_menu()
      else
        sfx(0)
      end
    end
  end
  
  function target_deselect()
    if btn(🅾️) then
      target_selection = nil
      visible_c[target] = false
      next_state = "pick"
      visible_c[action_range] = false
      visible_c[action_range_2] = false
      visible_c[possible_tar] = false
      close_status_window()
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
    if moved_last and move_cooldown.finished == false then
      return
    end
    move_cooldown:restart()
    if moved_last then
      move_cooldown.limit *= 0.5
    else
      move_cooldown.limit = 0.3
    end
    new_pos = pos_c[pointer]:copy()
    if new_move == ⬆️ then
      new_pos.y -= 1
    elseif new_move == ⬇️ then
      new_pos.y += 1
    elseif new_move == ⬅️ then
      new_pos.x -= 1
    elseif new_move == ➡️ then
      new_pos.x += 1
    end
    if new_pos:in_bound(bounds) then
      sfx(1)
      moved_last = true
      pos_c[pointer] = new_pos
      if state == "target" and target_selection then
        open_status_window()
      end
    end
  end