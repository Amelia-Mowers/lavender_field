-- Update the batch_comp line to include states_visible_c
sprite_c, text_c, rect_c, fill_zone_c, visible_c, palette_c, static_c, offset_c, states_visible_c = batch_comp(9)

function def(i, d)
  return i or d
end

sprite = {}
sprite.__index = sprite

function sprite:new(tiles, order, size, flip_x, flip_y)
  local o = {tiles = tiles, a_index = 1, order = order or 1, size = size or 2, flip_x = def(flip_x, false), flip_y = def(flip_y, false)}
  setmetatable(o, sprite)
  return o
end

q = {{0, 0}, {8, 0}, {0, 8}, {8, 8}}

function sprite.render(s, e, pos)
  if s.a_index > #s.tiles then
    s.a_index = 1
  end
  local t, px, py = s.tiles[s.a_index], pos.x * 16, pos.y * 16
  if type(t) == "number" then
    if t ~= 0 then
      spr(t, px, py, s.size, s.size, s.flip_x, s.flip_y)
    end
  elseif type(t) == "table" then
    for i = 1, #t do
      local ti = t[i]
      if ti ~= 0 then
        local tid, fx, fy = type(ti) == "table" and ti[1] or ti, type(ti) == "table" and ti.flip_x or false, type(ti) == "table" and ti.flip_y or false
        spr(tid, px + q[i][1], py + q[i][2], 1, 1, fx, fy)
      end
    end
  end
end

text = {}
text.__index = text

function text:new(txt, col, outline, order)
  local o = {text = txt, col = col or 6, outline = outline, order = order or 1}
  setmetatable(o, text)
  return o
end

t_out = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

function text.render(s, e, pos)
  local t, x, y = s.text, pos.x * 16, pos.y * 16
  for d in all(t_out) do
    ?t, x + d[1], y + d[2], s.outline
  end
  ?t, x, y, s.col
end

function text.size(self)
  local x, y = print(self.text, 0, -10)
  return vec2:new(x/16,(y+10)/16)
end

rectangle = {}
rectangle.__index = rectangle

function rectangle:new(size, fill, border, order)
  local o = {size = size, fill = fill or 0, border = border or fill or 0, order = order or 1}
  setmetatable(o, rectangle)
  return o
end

function rectangle.render(s, e, pos)
  local c = pos + s.size
  rectfill(pos.x * 16, pos.y * 16, c.x * 16, c.y * 16, s.fill)
  rect(pos.x * 16, pos.y * 16, c.x * 16, c.y * 16, s.border)
end

fill_zone = {}
fill_zone.__index = fill_zone

function fill_zone:new(d_field, border, order)
  local o = {d_field = d_field, border = border or 0, order = order or 1}
  setmetatable(o, fill_zone)
  return o
end

function fill_zone.render(s, e, pos)
  fillp()
  local f, b = s.d_field, s.border
  local dirs = {
    {"up", 0, 0, 16, 0},
    {"right", 16, 0, 16, 16},
    {"down", 0, 16, 16, 16},
    {"left", 0, 0, 0, 16} 
  }
  
  for p in all(f.total) do
    local px, py = p.x * 16, p.y * 16
    for i = 1, 4 do
      local d = dirs[i]
      if not f.field[p[d[1]](p):key()] then
        line(px + d[2], py + d[3], px + d[4], py + d[5], b)
      end
    end
  end
  fillp()
end

function render_objects()
  local min_x, min_y = flr(camera_pos.x) - 1, flr(camera_pos.y) - 1
  local max_x, max_y = min_x + 9, min_y + 9
  palt(0, false)
  palt(2, true)
  local layers = {}
  for i = -10, 10 do
    layers[i] = {}
  end
  local r_comps = {sprite_c, text_c, rect_c, fill_zone_c}
  for _, ct in pairs(r_comps) do
    for e, comp in pairs(ct) do
      local p = pos_c[e]
      if static_c[e] or p.x >= min_x and p.x <= max_x and p.y >= min_y and p.y <= max_y then
        -- Check if entity should be visible based on the current state
        local state_visible = true
        if states_visible_c[e] then
          state_visible = states_visible_c[e][state] == true
        end
        
        if (visible_c[e] == nil or visible_c[e] == true) and state_visible then
          add(layers[comp.order], {e = e, c = comp})
        end
      end
    end
  end
  for _, list in pairs(layers) do
    for _, obj in pairs(list) do
      local e, comp = obj.e, obj.c
      local pos = offset_c[e] and pos_c[e] + offset_c[e] or pos_c[e]
      if palette_c[e] then
        pal(palette_c[e], 0)
      end
      if static_c[e] then
        camera(0, 0)
      end
      comp:render(e, pos)
      camera(camera_pos.x * 16, camera_pos.y * 16)
      pal()
      palt(0, false)
      palt(2, true)
    end
  end
  palt()
end

function update_anim()
  anim_timer:tick()
  if anim_timer.just_finished then
    anim_timer:restart()
    for comp in all {sprite_c, tile_sprite_mapping} do
      for _, spr in pairs(comp) do
        spr.a_index += 1
        if spr.a_index > #spr.tiles then
          spr.a_index = 1
        end
      end
    end
  end
end

function set_cam()
  local c = pos_c[camera_focus]:copy()
  c.x -= 3.5
  c.y -= 3.5
  camera_pos = camera_pos * .8 + c * .2
  camera(camera_pos.x * 16, camera_pos.y * 16)
end