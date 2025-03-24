action_set_c, actions_c, possible_tar_c = batch_comp(3)

action = {}
action.__index = action

function action.menu_func(self)
  return function()
    local tar = target_selection
    if self.can_use(tar) then
      selected_action = self
      needed_act_t = self.targets(tar)
      if self.on_select then self.on_select(tar) end
      exit_action_menu()
      return true
    end
    return false
  end
end

function action.menu_move_onto(self)
  return function()
    local tar = target_selection
    
    visible_c[action_range_2] = false
    
    local range = d_field:new(pos_c[tar], self.range_block_func)
    fill_zone_c[action_range].d_field = range
    range:expand_to(nil, self.range(tar))
    
    for e in pairs(possible_tar_c) do delete(e) end
    
    if self.render_valid_targets then
      for _, pos in pairs(range.total) do
        if self.valid_target(tar, pos) then
          insert({
            {pos_c, pos:copy()},
            {possible_tar_c},
            {sprite_c, sprite:new(st.point, 4)},
            {palette_c, {[7] = 9}},
            {states_visible_c, {
              target = true,
              menu = true,
            }}
          })
        end
      end
    end
  end
end

function init_action_menu()
  selected_action, action_targets, needed_act_t = nil, {}, nil
  
  action_range = insert({
    {pos_c, vec2:new(4, 4)},
    {fill_zone_c, fill_zone:new(d_field:new(vec2:new(), no_block), 12, 3)},
    {states_visible_c, {
      target = true,
      menu = true,
    }}
  })
  
  action_range_2 = insert({
    {pos_c, vec2:new(4, 4)},
    {fill_zone_c, fill_zone:new(d_field:new(vec2:new(), no_block), 9, 3)},
    {visible_c, false},
    {states_visible_c, {
      target = true,
      menu = true,
    }}
  })
  
  action_menu = insert({
    {pos_c, vec2:new(.5, .5)},
    {rect_c, rectangle:new(vec2:new(2, 2), 0, 6, 5)},
    {menu_c, menu:new({})},
    {menu_back_c, action_menu_back},
    {static_c},
    {states_visible_c, {menu = true}}
  })
    
  menu_cursor = insert({
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
    {states_visible_c, {
      menu = true
    }},
  })
end

function action_menu_back()
  target_selection = nil
  next_state = "pick"
end

function open_action_menu()
  menu_cursor_c[menu_cursor].pos = vec2:new()
  
  local menu = menu_c[action_menu]
  for _, e in pairs(menu.elems) do delete(e) end
  menu.elems = {}

  local base_pos = pos_c[action_menu]
  local o_pos = base_pos + vec2:new(0.5, 0.25)
  local pos = o_pos:copy()
  local menu_pos, menu_size = vec2:new(), vec2:new()
  
  for a in all(action_set_c[target_selection]) do
    local label = vec2:new()
    label.x, label.y = print(a.name, 0, -10)
    label = label / 16
    
    menu_size.x = max(menu_size.x, label.x)
    menu_size.y = (pos - o_pos).y + label.y
    
    local elem = insert({
      {pos_c, pos},
      {text_c, text:new(a.name, 6, nil, 6)},
      {menu_select_c, a:menu_func()},
      {menu_move_onto_c, a:menu_move_onto()},
      {static_c},
      {states_visible_c, {menu = true}}
    })
    
    menu.elems[menu_pos:key()] = elem
    pos += vec2:new(0, 0.5)
    menu_pos += vec2:new(0, 1)
  end
  
  rect_c[action_menu].size = menu_size + vec2:new(0.75, 1)

  open_status_window()
  
  local elem = menu.elems[vec2:new():key()]
  menu_move_onto_c[elem]()
  
  next_state = "menu"
end

function exit_action_menu()
  next_state = "target"
end

function do_nothing() end

function set_action_target()
  if btn(❎) and select_cool.finished then
    select_cool:restart()
    
    if selected_action.valid_target(target_selection, pos_c[pointer]) then
      sfx(1)
      add(action_targets, pos_c[pointer]:copy())
    else
      sfx(0)
    end
  end
end

function trigger_action()
  if needed_act_t == #action_targets and target_selection != nil then
    local e = target_selection
    selected_action.execute(e)
    
    actions_c[e] -= selected_action.cost(e, action_targets)
    
    if actions_c[e] <= 0 and move_points_c[e] <= 0 then
      palette_c[e] = grey_scale
    end
    
    -- Reset state
    selected_action, action_targets, needed_act_t, target_selection = nil, {}, nil, nil
    next_state = "pick"
  end
end