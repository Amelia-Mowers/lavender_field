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