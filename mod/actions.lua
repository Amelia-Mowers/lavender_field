--actions

actions = {}

actions.move = action:new(
  "move", {
    cost = function(actor)
      return 0
    end,
    
    range = function(actor)
      local range = d_field:new(
        pos_c[tar],
        move_block
      )
    
      fill_zone_c[
        action_range_2
      ].d_field = range
    
      visible_c[
        action_range_2
      ] = true
      
      local mp 
        = move_points_c[actor]
      local s = speed_c[actor]
      local a = actions_c[actor]
      
      range:expand_to(
        nil,
        mp + a*s
      )
      
      if mp == 0 then 
        return s 
      else
        return mp
      end
    end,
    
    targets = function(actor)
      return 1
    end,
    
    range_block_func
      = move_block,
    
    on_select = function(actor)
    end,
    
    render_valid_targets
      = false,
    
    valid_target = function(
      actor, 
      target_pos
    )
      local mp = move_points_c[
        target_selection
      ]
      local s = speed_c[
        target_selection
      ]
      local a = actions_c[
        target_selection
      ]
      
      local range = mp + a*s
      
      local move_path 
        = path_to(
          pos_c[actor],  
          target_pos,
          move_block
        ) 
        
      if move_path != nil 
      and #move_path > 0 then
        if #move_path - 1
        > range
        then
          return false
        end
      
        return true
      end
      return false
    end, 
    
    ai_eval = function(
      actor,
      pos,
      actions_left
    )  
      actions_left 
        = actions_left
        or actions_c[actor]
      
      local best_score = nil
      local best_target = nil
      
      local move_field 
        = d_field:new(
          pos,
          move_block
        )
        
      local mp 
        = move_points_c[actor]
      local s = speed_c[actor]
      local a = actions_c[actor]
      
      move_field:expand_to(
        nil, 
        mp + a*s
      )
      
      for _, move_pos
      in pairs(
        move_field.total
      ) do
        local score = 0
        
        local adjacent_players
          = 0
        local adjacent_enemies
          = 0
        
        for _, neighbor_pos 
        in pairs(
          move_pos:neighbors()
        ) 
        do
          for p, _ in pairs(
            player_c
          )
          do
            if pos_c[p] 
            == neighbor_pos
            and health_c[p]
            != nil
            then
              adjacent_players
              += 1
            end
          end
          
          for enemy, _ 
          in pairs(mob_c) do
            if player_c[enemy]
            == nil 
            and health_c[enemy]
            != nil
            and pos_c[enemy]
            == neighbor_pos 
            and enemy 
            != actor then
              adjacent_enemies
              += 1
            end
          end
        end
        
        score 
          -= adjacent_players
          * 5
        
        score 
          -= adjacent_enemies 
          * 2
        
        if actions_left
        > 1 
        and action_set_c[actor] 
        then
          local next_action_score
            = 0
          
          for _, action 
          in pairs(
            action_set_c[actor]
          ) do
            if action.ai_eval
            and action.name
            != "move"
            and action.can_use
            and action.can_use(
              actor
            ) then
              local action_result
                = action.ai_eval(
                  actor,
                  move_pos, 
                  actions_left - 1
                )
              
              if action_result[1] 
              != nil 
              and action_result[1] 
              > next_action_score 
              then
                next_action_score
                  = action_result[1]
              end
            end
          end
          
          score 
            += next_action_score
            * 0.8
        end
        
        if best_score == nil 
        or score 
        > best_score 
        then
          best_score = score
          best_target 
            = move_pos
        end
      end
      
      return {
        best_score,
        best_target
      }
    end,
    
    ai_target = function(actor) 
    end,
    
    execute = function(actor)
      local move_path 
        = path_to(
          pos_c[actor],  
          action_targets[1],
          move_block
        )
      
      local dist = #move_path -1
      local mp 
        = move_points_c[actor]
      local s 
        = speed_c[actor]
      local a 
        = actions_c[actor]
      
      local mp_use 
        = min(mp, dist)
      local remaining_steps 
        = dist - mp_use
      local a_use = ceil(
        remaining_steps / s
      )
      
      local left_over_mp 
        = (a_use * s) 
        - remaining_steps
  
      move_points_c[actor] 
        = left_over_mp
      actions_c[actor] 
        = actions_c[actor] 
        - a_use
      
      pos_c[actor]
        = action_targets[1]
      update_fog_of_war(
        nil,
        true
      )
	     update_child_pos()
    end,
  }
)

actions.melee = action:new(
  "melee", {
    cost = function(actor)
      return 1
    end,
    
    range = function(actor)
      return 1
    end,
    
    targets = function(actor)
      return 1
    end,
    
    on_select = function(actor)
    end,
    
    render_valid_targets
      = true,
    
    valid_target = function(
      actor, 
      target_pos
    )
      if target_pos
      == pos_c[actor]
      then
        return false
      end
      
      for e, _
      in pairs(health_c) do
        if pos_c[e]
        == target_pos
        and health_c[e]:alive()
        and (
          (
            player_c[actor] 
            != nil
            and player_c[e] 
            == nil
          )
          or player_c[actor] 
          == nil
        )
        then
          return true
        end
      end

      return false
    end, 
    
    ai_eval = function(
      actor,
      t_pos,
      actions_left
    ) 
      local best_score = nil
      local best_target = nil
  
      for _, neighbor_pos 
      in pairs(t_pos:neighbors())
      do
        for e, _ 
        in pairs(mob_c) do
          if neighbor_pos 
          == pos_c[e] 
          and health_c[e] 
          != nil then
          
            local score = nil
        
            if player_c[e] 
            != nil then
              score = 10 
              
              score += health_c[
                actor
              ].dam
        
              local t_rem_health
                = health_c[e]
                  .total
                - health_c[e]
                  .dam
        
              if attack_c[actor] 
              >= t_rem_health
              then
                score *= 10
              end
            end
            
            if score
            != nil then
              if best_score
              == nil
              or score
              > best_score
              then 
                best_score
                  = score
      						  	 best_target
      							     = neighbor_pos
      						  end
      						end
          end
        end
      end
  
      return {
        best_score,
        best_target
      }
    end,
    
    ai_target = function(actor) 
    end,
    
    execute = function(actor)
      target_pos 
        = action_targets[1]
      
      dam = attack_c[
        actor
      ]
      
      attack_anim_c[actor] = {
        t = timer:new(0.4),
        dir
          = target_pos
          - pos_c[actor]
      }
	 
      for e, _
      in pairs(health_c) do
        if pos_c[e] 
        == target_pos
        then
          damage(e, dam)
        end
      end
        
      sfx(2)
	 		  actions_c[actor] = 0
	 		  move_points_c[actor] = 0
    end,
  }
)


actions.end_turn = action:new(
  "end turn", {
    cost = function(actor)
      return 0
    end,
    
    range = function(actor)
      return 0
    end,
    
    targets = function(actor)
      return 0
    end,
    
    on_select = function(actor)
    end,
    
    render_valid_targets
      = false,
    
    valid_target = function(
      actor, 
      target_pos
    )
      return true
    end, 
    
    ai_eval = function(
      actor,
      t_pos,
      actions_left
    ) 
      return {
        0,
        t_pos
      }
    end,
    
    ai_target = function(actor) 
    end,
    
    execute = function(actor)
	 		  actions_c[actor] = 0
	 		  move_points_c[actor] = 0
    end,
  }
)