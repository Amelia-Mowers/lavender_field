function new_map(
    pos,
    size,
    spawn,
    exits,
    next_map
  )
    return {
      pos = pos,
      size = size
        or vec2:new(16,16),
      spawn = spawn,
      exits = exits,
      next_map = next_map,
    }
  end
  
  maps = {
    trail = new_map(
      vec2:new(0,0),
      nil,
      {
        {
          mob.knight,
          vec2:new(2,8)
        },
        {
          mob.wiz,
          vec2:new(1,7)
        },
        {
          mob.gnome,
          vec2:new(0,8)
        },
        {
          mob.skeleton,
          vec2:new(6,8)
        },
      },
      vec2:rect_arr(
        14,6,
        15,9
      ),
      "grave"
    ),
    grave = new_map(
      vec2:new(16,0),
      nil,
      {
        {
          mob.knight,
          vec2:new(3,7)
        },
        {
          mob.skeleton,
          vec2:new(14,8)
        },
      },
      vec2:rect_arr(
        14,6,
        15,9
      ),
      "foo"
    )
  }



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