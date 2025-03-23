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
