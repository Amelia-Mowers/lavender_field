--maps

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