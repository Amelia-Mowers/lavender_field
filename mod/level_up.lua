level_up_queue = {}
level_up_options_c = new_comp()
current_level_up_entity = nil

level_up_options = {
  {
    name = "max hp +2",
    effect = function(entity)
      health_c[entity].total += 2
    end
  },
  {
    name = "attack +1",
    effect = function(entity)
      attack_c[entity] += 1
    end
  },
  {
    name = "defense +1",
    effect = function(entity)
      if not defense_c[entity][dam_type.phys] then
        defense_c[entity][dam_type.phys] = 0
      end
      defense_c[entity][dam_type.phys] += 1
    end
  },
  {
    name = "speed +1",
    effect = function(entity)
      speed_c[entity] += 1
    end
  },
}

function init_level_up_system()
  level_up_menu = insert({
    {pos_c, vec2:new(2, 2)},
    {rect_c, rectangle:new(vec2:new(4, 2.5), 0, 6, 5)},
    {menu_c, menu:new({}, "level_up")},
    {static_c},
    {states_visible_c, {level_up = true}}
  })
  
  level_up_cursor = insert({
    {pos_c, vec2:new()},
    {
      menu_cursor_c, 
      menu_cursor:new(
        level_up_menu,
        vec2:new(-0.5, 0),
        "level_up"
      )
    },
    {
      sprite_c, 
      sprite:new(
        st.menu_curs,
        7, 1
      )
    },
    {static_c},
    {states_visible_c, {
      level_up = true
    }},
  })
  
  level_up_title = insert({
    {pos_c, vec2:new(2.5, 1.4)},
    {text_c, text:new("LEVEL UP!", 7, 0, 5)},
    {static_c},
    {states_visible_c, {level_up = true}}
  })
  
  level_up_char_name = insert({
    {pos_c, vec2:new(4, 1.75)},
    {text_c, text:new("", 7, 0, 5)},
    {static_c},
    {states_visible_c, {level_up = true}}
  })
end

function queue_level_up(entity)
  add(level_up_queue, entity)
  next_state = "level_up"
end

function process_level_up_queue()
  if #level_up_queue > 0 then
    current_level_up_entity = level_up_queue[1]
    deli(level_up_queue, 1)
    open_level_up_menu()
  else
    current_level_up_entity = nil
    next_state = "pick"
  end
end

function open_level_up_menu()
  menu_cursor_c[level_up_cursor].pos = vec2:new()
  
  local menu = menu_c[level_up_menu]
  for _, e in pairs(menu.elems) do delete(e) end
  menu.elems = {}
  
  text_c[level_up_char_name].text = name_c[current_level_up_entity] .. " REACHED LEVEL " .. level_c[current_level_up_entity]
  
  local base_pos = pos_c[level_up_menu]
  local o_pos = base_pos + vec2:new(0.5, 0.5)
  local pos = o_pos:copy()
  local menu_pos, menu_size = vec2:new(), vec2:new()
  
  local options_indices = {}
  while #options_indices < 3 do
    local idx = flr(rnd(#level_up_options)) + 1
    local found = false
    for i=1, #options_indices do
      if options_indices[i] == idx then
        found = true
        break
      end
    end
    if not found then
      add(options_indices, idx)
    end
  end
  
  for i=1, 3 do
    local option_idx = options_indices[i]
    local option = level_up_options[option_idx]
    
    local label = vec2:new()
    label.x, label.y = print(option.name, 0, -10)
    label = label / 16
    
    menu_size.x = max(menu_size.x, label.x)
    menu_size.y = (pos - o_pos).y + label.y
    
    local elem = insert({
      {pos_c, pos},
      {text_c, text:new(option.name, 7, nil, 6)},
      {menu_select_c, function()
        option.effect(current_level_up_entity)
        sfx(1)
        process_level_up_queue()
        return true
      end},
      {static_c},
      {states_visible_c, {level_up = true}}
    })
    
    menu.elems[menu_pos:key()] = elem
    pos += vec2:new(0, 0.5)
    menu_pos += vec2:new(0, 1)
  end
  
  rect_c[level_up_menu].size = menu_size + vec2:new(0.75, 1)
end