function static_val(val)
  return function() return val end
end
  
function action:new(name, config)
  config.cost = config.cost or static_val(1)
  config.range = config.range or static_val(1)
  config.targets = config.targets or static_val(1)
  config.on_select = config.on_select or function() end
  config.range_block_func = config.range_block_func or no_block
  config.render_valid_targets = config.render_valid_targets or false
  config.ai_target = config.ai_target or function() end
  
  local obj = {
    name = name,
    cost = config.cost,
    range = config.range,
    targets = config.targets,
    range_block_func = config.range_block_func,
    on_select = config.on_select,
    render_valid_targets = config.render_valid_targets,
    valid_target = config.valid_target, 
    ai_eval = config.ai_eval,
    ai_target = config.ai_target,
    execute = config.execute,
    can_use = config.can_use or function(actor)
      local a_rem = actions_c[actor]
      local a_use = config.cost()
      return a_rem - a_use >= 0
    end
  }
  
  setmetatable(obj, action)
  return obj
end

actions = {}

actions.move = action:new("move", {
  cost = static_val(0),
  
  range = function(actor)
    local range = d_field:new(pos_c[tar], move_block)
    fill_zone_c[action_range_2].d_field = range
    visible_c[action_range_2] = true
    
    local mp = move_points_c[actor]
    local s = speed_c[actor]
    local a = actions_c[actor]
    
    range:expand_to(nil, mp + a*s)
    
    return (mp == 0) and s or mp
  end,
  
  range_block_func = move_block,
  
  valid_target = function(actor, target_pos)
    local mp = move_points_c[target_selection]
    local s = speed_c[target_selection]
    local a = actions_c[target_selection]
    local range = mp + a*s
    
    local move_path = path_to(pos_c[actor], target_pos, move_block) 
      
    if move_path != nil and #move_path > 0 then
      return #move_path - 1 <= range
    end
    return false
  end, 
  
  ai_eval = function(actor, pos, actions_left)  
    actions_left = actions_left or actions_c[actor]
    
    local best_score = nil
    local best_target = nil
    
    local move_field = d_field:new(pos, move_block)
    local mp = move_points_c[actor]
    local s = speed_c[actor]
    local a = actions_c[actor]
    
    move_field:expand_to(nil, mp + a*s)
    
    for _, move_pos in pairs(move_field.total) do
      local score = 0
      local adjacent_players = 0
      local adjacent_enemies = 0
      
      for _, neighbor_pos in pairs(move_pos:neighbors()) do
        for p, _ in pairs(player_c) do
          if pos_c[p] == neighbor_pos and health_c[p] != nil then
            adjacent_players += 1
          end
        end
        
        for enemy, _ in pairs(mob_c) do
          if player_c[enemy] == nil 
              and health_c[enemy] != nil
              and pos_c[enemy] == neighbor_pos 
              and enemy != actor then
            adjacent_enemies += 1
          end
        end
      end
      
      score -= adjacent_players * 5
      score -= adjacent_enemies * 2
      
      if actions_left > 1 and action_set_c[actor] then
        local next_action_score = 0
        
        for _, action in pairs(action_set_c[actor]) do
          if action.ai_eval
              and action.name != "move"
              and action.can_use
              and action.can_use(actor) then
            
            local action_result = action.ai_eval(actor, move_pos, actions_left - 1)
            
            if action_result[1] != nil and action_result[1] > next_action_score then
              next_action_score = action_result[1]
            end
          end
        end
        
        score += next_action_score * 0.8
      end
      
      if best_score == nil or score > best_score then
        best_score = score
        best_target = move_pos
      end
    end
    
    return {best_score, best_target}
  end,
  
  ai_target = function() end,
  
  execute = function(actor)
    move_interrupt = false
    
    local move_path = path_to(pos_c[actor], action_targets[1], move_block)
    
    if move_path == nil or #move_path == 0 then
      return
    end
    
    local reversed_path = {}
    for i = #move_path, 1, -1 do
      add(reversed_path, move_path[i])
    end
    move_path = reversed_path
    
    local pos_index = get_pos_index()
    
    local mp = move_points_c[actor]
    local s = speed_c[actor]
    local a = actions_c[actor]
    local current_pos = pos_c[actor]
    
    for i = 2, #move_path do
      if move_interrupt then
        break
      end
      
      local next_pos = move_path[i]
      
      if mp > 0 then
        mp -= 1
      else
        if a > 0 and s > 0 then
          a -= 1
          local steps_with_action = s
          steps_with_action -= 1
          mp = steps_with_action
        else
          break
        end
      end
      
      current_pos = next_pos
      pos_c[actor] = next_pos
      
      local entities_at_pos = pos_index[next_pos:key()]
      if entities_at_pos then
        for _, entity in pairs(entities_at_pos) do
          if on_move_onto_c[entity] != nil then
            on_move_onto_c[entity](entity, actor)
          end
        end
      end
      if move_interrupt then
        break
      end
    end
    
    move_points_c[actor] = mp
    actions_c[actor] = a
    
    update_fog_of_war(nil, true)
    update_child_pos()
  end,
})

actions.melee = action:new("melee", {
  render_valid_targets = true,
  
  valid_target = function(actor, target_pos)
    if target_pos == pos_c[actor] then
      return false
    end
    
    for e, _ in pairs(health_c) do
      if pos_c[e] == target_pos
          and health_c[e]:alive()
          and ((player_c[actor] != nil and player_c[e] == nil)
              or player_c[actor] == nil) then
        return true
      end
    end

    return false
  end, 
  
  ai_eval = function(actor, t_pos, actions_left) 
    local best_score = nil
    local best_target = nil

    for _, neighbor_pos in pairs(t_pos:neighbors()) do
      for e, _ in pairs(mob_c) do
        if neighbor_pos == pos_c[e] and health_c[e] != nil then
          local score = nil
      
          if player_c[e] != nil then
            score = 10 
            score += health_c[actor].dam
      
            local t_rem_health = health_c[e].total - health_c[e].dam
      
            if attack_c[actor] >= t_rem_health then
              score *= 10
            end
          end
          
          if score != nil then
            if best_score == nil or score > best_score then 
              best_score = score
              best_target = neighbor_pos
            end
          end
        end
      end
    end

    return {best_score, best_target}
  end,
  
  ai_target = function() end,
  
  execute = function(actor)
    target_pos = action_targets[1]
    dam = attack_c[actor]
    
    attack_anim_c[actor] = {
      t = timer:new(0.4),
      dir = target_pos - pos_c[actor]
    }

    for e, _ in pairs(health_c) do
      if pos_c[e] == target_pos then
        damage(e, dam)
      end
    end
      
    sfx(2)
    actions_c[actor] = 0
    move_points_c[actor] = 0
  end,
})

actions.end_turn = action:new("end turn", {
  cost = static_val(0),
  range = static_val(0),
  targets = static_val(0),
  valid_target = function() return true end,
  ai_eval = function(actor, t_pos) return {0, t_pos} end,
  execute = function(actor)
    actions_c[actor] = 0
    move_points_c[actor] = 0
  end,
})