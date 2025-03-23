function move_block(pos, index)
  if pos:in_bound(bounds) == false then
    return true
  end
  tile_block = fget(map_get(pos), 0)
  obj_block = false
  for e in all(index[pos:key()]) do
    if block_move_c[e] != nil then
      obj_block = true
      break
    end
  end
  return tile_block or obj_block
end

function no_block(pos, index)
  return false
end

function update_floating_entities()
  for e, float_data in pairs(float_c) do
    pos_c[e] = pos_c[e] + float_data.speed
    float_data.speed = float_data.speed + float_data.accel
  end
end

function update_damage_notices()
  for e, _ in pairs(damage_notice_c) do
    if removal_timer_c[e] then
      local life_fraction = 1 - removal_timer_c[e]:fract()
      if life_fraction < 0.3 then
        text_c[e].col = 5
      elseif life_fraction < 0.6 then
        text_c[e].col = 9
      else
        text_c[e].col = 8
      end
    end
  end
end

function update_state()
  if next_state != nil then
    state = next_state
    next_state = nil
  end
end

function update_child_pos()
  for e, children in pairs(child_c) do
    for c in all(children) do
      pos_c[c] = pos_c[e] + local_pos_c[c]
    end
  end
end

function update_child_vis()
  for e, children in pairs(child_c) do
    for c in all(children) do
      visible_c[c] = visible_c[e]
    end
  end
end

function trigger_end_turn()
  remaining_units = false
  for e, _ in pairs(player_c) do
    if actions_c[e] > 0 or move_points_c[e] > 0 and health_c[e] != nil then
      remaining_units = true
      break
    end
  end
  remaining_living = false
  for e, _ in pairs(player_c) do
    if health_c[e] != nil then
      remaining_living = true
      break
    end
  end
  if remaining_units == false and remaining_living == true then
    next_state = "enemy_turn"
  end
end

function victory_check()
  remaining_enemies = false
  for e, _ in pairs(mob_c) do
    if player_c[e] == nil and health_c[e] != nil then
      remaining_enemies = true
      break
    end
  end
  if remaining_enemies == false then
    next_state = "victory"
  end
end

function reset_actions()
  for e, _ in pairs(actions_c) do
    actions_c[e] = 2
    palette_c[e] = nil
    move_points_c[e] = 0
  end
end

function timed_removal()
  for e, t in pairs(removal_timer_c) do
    t:tick()
    if t.finished then
      delete(e)
    end
  end
end

function death_check()
  for e, h in pairs(health_c) do
    if h:dead() then
      remains = st.skull
      if remains_c[e] != nil then
        remains = remains_c[e]
      end
      health_c[e] = nil
      block_move_c[e] = nil
      block_sight_c[e] = nil
      cover_tile_c[e] = nil
      sprite_c[e].tiles = remains
      sprite_c[e].order = 1
      if child_c[e] != nil then
        for c in all(child_c[e]) do
          sprite_c[c] = nil
        end
      end
      update_fog_of_war()
    end
  end
end

function update_anim()
  anim_timer:tick()
  if anim_timer.just_finished then
    anim_timer:restart()
    for _, sprite in pairs(sprite_c) do
      sprite.a_index += 1
      if sprite.a_index > #sprite.tiles then
        sprite.a_index = 1
      end
    end
    for _, sprite in pairs(tile_sprite_mapping) do
      sprite.a_index += 1
      if sprite.a_index > #sprite.tiles then
        sprite.a_index = 1
      end
    end
    for _, sprite in pairs(multi_sprite_c) do
      sprite.a_index += 1
      if sprite.a_index > #sprite.tiles then
        sprite.a_index = 1
      end
    end
  end
end

function update_attack_animations()
  for e, anim in pairs(attack_anim_c) do
    anim.t:tick()
    local fract = anim.t:fract()
    local dir = anim.dir
    if dir.x != 0 and dir.y != 0 then
      dir = dir * 0.7071
    end
    local bounce = 1 - 2 * abs(fract - 0.5)
    bounce = bounce * bounce
    local max_extent = 0.4
    offset_c[e] = dir * bounce * max_extent
    if anim.t.finished then
      attack_anim_c[e] = nil
      offset_c[e] = vec2:new()
    end
  end
end

function set_cam()
  local c = pos_c[camera_focus]:copy()
  c.x = c.x - 3.5
  c.y = c.y - 3.5
  camera_pos = camera_pos * 0.8 + c * 0.2
  camera(camera_pos.x * 16, camera_pos.y * 16)
end

function init_map()
  tile_sprite_mapping = {
    [16] = sprite:new(st.grass), 
    [32] = sprite:new(st.dirt), 
    [48] = sprite:new(st.water), 
    [51] = sprite:new(st.dirt), 
    [50] = sprite:new(st.grass),
  }
  map_funcs = {
    [51] = spawn_wall, 
    [50] = spawn_tree,
  }
  for x = 0, 15 do
    for y = 0, 15 do
      local pos = vec2:new(x, y)
      local fn = map_funcs[map_get(pos)]
      if fn != nil then
        fn(pos)
      end
    end
  end
  for m in all(cur_map.spawn) do
    e = m[1](m[2])
    if spawn_focus_c[e] != nil then
      pos_c[pointer] = m[2]:copy()
    end
  end
end

function spawn_wall(pos)
  insert({
    {pos_c, pos}, 
    {sprite_c, sprite:new(st.wall, 2)}, 
    {obj_c}, 
    {block_move_c}, 
    {block_sight_c}, 
    {cover_tile_c}, 
    {remains_c, st.rubble}, 
    {health_c, health:new(10)}, 
    {child_c, {insert({
      {pos_c, vec2:new()}, 
      {local_pos_c, vec2:new(0, 0.5)}, 
      {sprite_c, sprite:new(st.wall_bottom, 1)},
    })}},
  })
end

function spawn_tree(pos)
  insert({
    {pos_c, pos}, 
    {sprite_c, sprite:new(st.tree, 2)}, 
    {obj_c}, 
    {block_move_c}, 
    {block_sight_c}, 
    {remains_c, st.rubble}, 
    {health_c, health:new(10)},
  })
end

covered_tiles = {}
unfogged_tiles = {}
visible_tiles = {}
unfogged_objects = {}
visible_objects = {}

function map_get(pos)
  return mget(pos.x + cur_map.pos.x, pos.y + cur_map.pos.y)
end

function render_map()
  local min_x = flr(camera_pos.x)
  local min_y = flr(camera_pos.y)
  local max_x = min_x + 8
  local max_y = min_y + 8
  covered_tiles = {}
  for e, _ in pairs(cover_tile_c) do
    local pos = pos_c[e]
    covered_tiles[pos:key()] = true
  end
  pal(grey_scale, 0)
  for _, t_pos in pairs(unfogged_tiles) do
    if t_pos.x >= min_x and t_pos.x <= max_x and t_pos.y >= min_y and t_pos.y <= max_y then
      if visible_tiles[t_pos:key()] == nil and covered_tiles[t_pos:key()] == nil then
        local sp = tile_sprite_mapping[map_get(t_pos)]
        sp:render(nil, t_pos)
      end
    end
  end
  pal()
  for _, t_pos in pairs(visible_tiles) do
    if t_pos.x >= min_x and t_pos.x <= max_x and t_pos.y >= min_y and t_pos.y <= max_y then
      if covered_tiles[t_pos:key()] == nil then
        local sp = tile_sprite_mapping[map_get(t_pos)]
        sp:render(nil, t_pos)
      end
    end
  end
end

function update_fog_of_war(actor, inc)
  if inc == nil or inc == false then
    visible_tiles = {}
    visible_objects = {}
  end
  local check = nil
  if actor == nil then
    check = player_c
  else
    check = {[actor] = {}}
  end
  local sight = nil
  for e, _ in pairs(player_c) do
    if sight_c[e] != nil and health_c[e] != nil then
      if sight == nil then
        sight = d_field:new(pos_c[e], line_of_sight_block)
      else
        sight:add(pos_c[e])
      end
    end
  end
  if sight == nil then
    return
  end
  sight:expand_to(nil, 5)
  local index = get_pos_index()
  for t in all(sight.total) do
    for n in all(t:neighbors()) do
      if visible_tiles[n:key()] == nil and n:in_bound(bounds) then
        unfogged_tiles[n:key()] = n
        visible_tiles[n:key()] = n
      end
      for e in all(index[n:key()]) do
        if obj_c[e] != nil then
          visible_objects[e] = {}
          unfogged_objects[e] = {}
        end
      end
    end
  end
  for e, _ in pairs(obj_c) do
    if mob_c[e] != nil then
      visible_c[e] = visible_objects[e] != nil
    else
      if visible_objects[e] == nil then
        palette_c[e] = grey_scale
      else
        palette_c[e] = nil
      end
      visible_c[e] = unfogged_objects[e] != nil
    end
  end
end

function line_of_sight_block(pos, index, origins)
  if pos:in_bound(bounds) == false then
    return true
  end
  for o in all(origins) do
    local blocked = false
    for p in all(pos_in_line(o, pos)) do
      tile_block = fget(map_get(p), 1)
      if tile_block then
        blocked = true
        break
      end
      for e in all(index[p:key()]) do
        if block_sight_c[e] != nil then
          blocked = true
          break
        end
      end
    end
    if blocked == false then
      return false
    end
  end
  return true
end

function pos_in_line(a, b)
  local positions = {}
  local x0, y0 = a.x, a.y
  local x1, y1 = b.x, b.y
  local dx = abs(x1 - x0)
  local sx = x0 < x1 and 1 or -1
  local dy = -abs(y1 - y0)
  local sy = y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    add(positions, vec2:new(x0, y0))
    if x0 == x1 and y0 == y1 then
      break
    end
    local e2 = 2 * err
    if e2 >= dy then
      if x0 == x1 then
        break
      end
      err = err + dy
      x0 = x0 + sx
    end
    if e2 <= dx then
      if y0 == y1 then
        break
      end
      err = err + dx
      y0 = y0 + sy
    end
  end
  return positions
end

function render_path()
  for p in all(move_path) do
    if p != pos_c[target] then
      spr(33, p.x * 16 + 4, p.y * 16 + 4)
    end
  end
end

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

function def(input, default)
  if input == nil then
    return default
  else
    return input
  end
end

function flat(input, index)
  local index = index or 1
  if type(input) == "table" then
    return input[index]
  else
    return input
  end
end

function def_index(input, index, default)
  if type(input) == "table" then
    return input[index]
  else
    return default
  end
end

function rot_sprite(input)
  return {
    input, 
    {input, flip_x = true}, 
    {input, flip_y = true}, 
    {input, flip_x = true, flip_y = true,},
  }
end

function quad_sprite(input)
  return {input, input, input, input,}
end

