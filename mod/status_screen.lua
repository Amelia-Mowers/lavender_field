function pad(input, padding)
  while #input < padding do
    input = " " .. input
  end
  return input
end

function init_status_window()
  status_window = insert {
    {pos_c, vec2:new(5.25, .5)}, 
    {rect_c, rectangle:new(vec2:new(2.25, 2.2), 0, 6, 5)}, 
    {menu_c, menu:new({})}, 
    {menu_back_c, action_menu_back}, 
    {static_c},
    {states_visible_c, {
      target = true,
      menu = true,
    }},
  }
  local tar = target_selection
  base_pos = pos_c[status_window] + vec2:new(.25, .25)
  status = insert {
    {pos_c, base_pos}, 
    {static_c}, 
    {states_visible_c, {
      target = true,
      menu = true,
    }},
    {text_c, text:new("", 6, nil, 7)},
  }
end

function open_status_window()
  local tar = target_selection
  local h, a, mp, s = health_c[tar], actions_c[tar], move_points_c[tar], speed_c[tar]
  local e, l = exp_c[tar] or 0, level_c[tar] or 1
  
  if state == "target" and selected_action then
    local potential_a, potential_mp = a, mp
    if selected_action.valid_target and selected_action.valid_target(tar, pos_c[pointer]) and selected_action.cost then
      if selected_action.name == "move" then
        local move_path = path_to(pos_c[tar], pos_c[pointer], move_block)
        if move_path and #move_path > 0 then
          local dist = #move_path - 1
          local mp_use = min(mp, dist)
          local remaining_steps = dist - mp_use
          local a_use = ceil(remaining_steps / s)
          local left_over_mp = a_use * s - remaining_steps
          potential_mp, potential_a = left_over_mp, a - a_use
        end
      else
        potential_a = a - selected_action.cost(tar)
      end
      potential_a, potential_mp = max(0, potential_a), max(0, potential_mp)
      a, mp = potential_a, potential_mp
    end
  end
  
  local th = h.total
  local ch = th - h.dam
  local hs, ms = pad(tostr(ch), 2) .. "/" .. tostr(th), tostr(mp) .. "/" .. tostr(s)
  local status_txt = name_c[tar] .. "," .. tostr(l) .. "\n" .. "hp:" .. hs .. "\n" .. "act:" .. tostr(a) .. "/2 \n" .. "mve:" .. ms .. "\n" .. "exp:" .. tostr(e)
  text_c[status].text = status_txt
end