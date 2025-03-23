function pad(input, padding)
    while #input < padding do
      input = " " .. input
    end
    return input
  end
  
  
  function init_status_window()
    
    local w = 2.25
    status_window = insert({
            {pos_c, vec2:new(7.5-w,.5)},
            {visible_c, false},
            {rect_c, rectangle:new(
                    vec2:new(w,1.9),0,6,5
            )},
      {menu_c, menu:new({})},
      {
        menu_back_c,
        action_menu_back
      },
      {static_c},
    })
    
    local tar = target_selection
    
    base_pos
      = pos_c[status_window] 
      + vec2:new(0.25,0.25)
      
    status = insert({
        {pos_c, base_pos},
              {visible_c, false},
        {static_c},
        {text_c, text:new(
          "",6,nil,7
        )},
      })
  end
  
  function open_status_window()
    visible_c[status] = true
    visible_c[status_window] = true
      
    local tar = target_selection
    
    local h = health_c[tar]
    local a = actions_c[tar]
    local mp = move_points_c[tar]
    local s = speed_c[tar]
    
    -- if in targeting state with a valid action selected, calculate potential costs
    if state == "target" and selected_action then
      -- create a temporary copy of current values
      local potential_a = a
      local potential_mp = mp
      
      -- only calculate potential costs if cursor position is a valid target
      if selected_action.valid_target and 
         selected_action.valid_target(tar, pos_c[pointer]) and
         selected_action.cost then
         
        -- for move action, calculate path distance and update potential values
        if selected_action.name == "move" then
          local move_path = path_to(
            pos_c[tar],  
            pos_c[pointer],
            move_block
          )
          
          if move_path and #move_path > 0 then
            local dist = #move_path - 1
            local mp_use = min(mp, dist)
            local remaining_steps = dist - mp_use
            local a_use = ceil(remaining_steps / s)
            local left_over_mp = (a_use * s) - remaining_steps
            
            potential_mp = left_over_mp
            potential_a = a - a_use
          end
        else
          potential_a 
            = a 
            - selected_action.cost(tar)
        end
        
        potential_a 
          = max(0, potential_a)
        potential_mp 
          = max(0, potential_mp)
        
        a = potential_a
        mp = potential_mp
      end
    end
    
    local th = h.total
    local ch = th - h.dam
    
    local hs 
      = pad(tostr(ch), 2) 
      .. "/"
      .. tostr(th)
      
    local ms 
      = tostr(mp) 
      .. "/"
      .. tostr(s)
  
    local status_txt =
      name_c[tar] .. "\n"  ..
      "hp:".. hs .."\n" ..
      "act:".. tostr(a) .."/2 \n" ..
      "mve:".. ms .."\n"
      
    text_c[status].text 
      = status_txt
  end
  
  function close_status_window()
    visible_c[status] = false
    visible_c[status_window]
      = false
  end