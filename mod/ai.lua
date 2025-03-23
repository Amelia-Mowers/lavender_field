--ai

last_enemy = nil

function enemy_turn()
  e_action_timer:tick()
  
  if e_action_timer.finished
  == false then
    return
  end
  
  local enemies = {}
  for e, _ in pairs(mob_c) do
    if player_c[e] == nil then
      add(enemies, e)
    end
  end
  
  for _, enemy 
  in pairs(enemies) do
    if actions_c[enemy] > 0 
    and health_c[enemy] != nil
    and health_c[enemy]:alive()
    then
      action_targets = {}
      
      local available_actions 
        = action_set_c[enemy]
        
      if available_actions
      == nil then
        actions_c[enemy] = 0 
        break 
      end
      
      camera_focus = enemy
  
      e_action_timer:restart()
        
      if enemy
      != last_enemy then
        last_enemy = enemy
        break 
      end
      
      local best_action = nil
      local best_score_tar
        = {nil, nil}
      
      for _, action 
      in pairs(
        available_actions
      ) do
        if action.ai_eval 
        and action.can_use(
          enemy
        ) 
        then
          local score_tar
            = action.ai_eval(
              enemy,
              pos_c[enemy]
            )
          if score_tar[1] 
          != nil then
            if best_score_tar[1]
            == nil
            or score_tar[1] 
            > best_score_tar[1]
            then
              best_score_tar
                = score_tar
              best_action 
                = action
            end
          end
        end
      end
      
      if best_action == nil 
      or best_score_tar[1] 
      == nil then
        break
      end
      
      action_targets[1]
        = best_score_tar[2] 
      
      best_action.execute(
        enemy
      )
      actions_c[enemy]
        -= best_action.cost(
          enemy
        )
      
      if actions_c[enemy] <= 0 
      then
        palette_c[enemy]
          = grey_scale
      end
      break
    end
  end
  
  rem_enemy_actions = false
  
  for _, enemy 
  in pairs(enemies) do
    if actions_c[enemy] > 0
    and health_c[enemy] != nil
    then
      rem_enemy_actions = true
      break
    end
  end
  
  if rem_enemy_actions == false
  then  
    action_targets = {}
    next_state = "new_round"
  end
end

