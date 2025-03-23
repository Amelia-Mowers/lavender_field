sprite_c, text_c, rect_c, fill_zone_c, visible_c, palette_c, static_c, offset_c = batch_comp(8)

function def(input, default)
  if input == nil then
    return default
  else
    return input
  end
end

-- sprite implementation
sprite = {}
sprite.__index = sprite

function sprite:new(
  tiles,
  order,
  size,
  flip_x,
  flip_y
)
  local obj = {
    tiles = tiles,
    a_index = 1,
    order = order or 1,
    size = size or 2,
    flip_x = def(flip_x, false),
    flip_y = def(flip_y, false),
  }
  setmetatable(obj, sprite)
  return obj
end

q = {
  {0,0}, 
  {8,0}, 
  {0,8}, 
  {8,8}
}

function sprite.render(
  self, e, pos
)
  if self.a_index 
  > #self.tiles then
    self.a_index = 1
  end
  
  local tile 
    = self.tiles[self.a_index]
  local px, py 
    = pos.x*16, pos.y*16
  
  if type(tile) 
  == "number" then
    if tile == 0 then
      return
    end
    spr(tile, px, py, self.size, self.size, self.flip_x, self.flip_y)
  elseif type(tile) == "table" then
    for i=1, #tile do
      local t = tile[i]
      if t != 0 then
        local t_id = type(t) == "table" and t[1] or t
        local flip_x = type(t) == "table" and t.flip_x or false
        local flip_y = type(t) == "table" and t.flip_y or false
        spr(t_id, px+q[i][1], py+q[i][2], 1, 1, flip_x, flip_y)
      end
    end
  end
end

-- text implementation
text = {}
text.__index = text

function text:new(
  txt, 
  col,
  outline, 
  order
)
  local obj = {
    text = txt,
    col = col or 6,
    outline = outline,
    order = order or 1,
  }
  setmetatable(obj, text)
  return obj
end

t_out = {
  {-1, 0},
  {1, 0},
  {0, -1},
  {0, 1},
  {-1, -1},
  {-1, 1},
  {1, -1},
  {1, 1},
}

function text.render(
  self, e, pos
)
  t = self.text
  x = pos.x*16
  y = pos.y*16
  for d in all(t_out) do
   print(t, x + d[1], y + d[2], self.outline)
  end
  print(t, x, y, self.col)
end

-- rectangle implementation
rectangle = {}
rectangle.__index = rectangle

function rectangle:new(
  size, 
  fill, 
  border, 
  order
)
  local obj = {
    size = size,
    fill = fill or 0,
    border = border or fill or 0,
    order = order or 1,
  }
  setmetatable(obj, rectangle)
  return obj
end

function rectangle.render(
  self, e, pos
)
  local corn = pos + self.size
  rectfill(
    pos.x*16,
    pos.y*16,
    corn.x*16,
    corn.y*16,
    self.fill
  )
  rect(
    pos.x*16,
    pos.y*16,
    corn.x*16,
    corn.y*16,
    self.border
  )
end

-- fill zone implementation
fill_zone = {}
fill_zone.__index = fill_zone

function fill_zone:new(
  d_field, 
  border, 
  order
)
  local obj = {
    d_field = d_field,
    border = border or 0,
    order = order or 1,
  }
  setmetatable(obj, fill_zone)
  return obj
end

function fill_zone.render(
  self, e, pos
)
  fillp()
  
  local field = self.d_field

  local edges = {
    {
      dir = "up",
      dx1=0,
      dy1=0,
      dx2=15,
      dy2=0
    },
    {
      dir = "right",
      dx1=15,
      dy1=0,
      dx2=15,
      dy2=15
    },
    {
      dir = "down",
      dx1=0,
      dy1=15,
      dx2=15,
      dy2=15
    },
    {
      dir = "left",
      dx1=0,
      dy1=0,
      dx2=0,
      dy2=15
    }
  }

  local corners = {
    {
      dir1 = vec2.up, 
      dir2 = vec2.left,
      dx=0,
      dy=0
    },
    {
      dir1 = vec2.up,
      dir2 = vec2.right,
      dx=15,
      dy=0
    },
    {
      dir1 = vec2.down,
      dir2 = vec2.left,
      dx=0,
      dy=15
    },
    {
      dir1 = vec2.down,
      dir2 = vec2.right,
      dx=15,
      dy=15
    }
  }

  for p in all(field.total) do
    local px = p.x * 16
    local py = p.y * 16

    for _, edge in pairs(edges) do
      local neighbor = p[edge.dir](p)
      if field.field[neighbor:key()] == nil then
        line(
          px + edge.dx1,
          py + edge.dy1,
          px + edge.dx2,
          py + edge.dy2,
          self.border
        )
      end
    end

    for _, corner in pairs(corners) do
      local neighbor = corner.dir1(p)
      local neighbor = corner.dir2(neighbor)
      if field.field[neighbor:key()] == nil then
        pset(
          px + corner.dx,
          py + corner.dy,
          self.border
        )
      end
    end
  end
  fillp()
end

function render_objects()
  local min_x 
    = flr(camera_pos.x) - 1
  local min_y 
    = flr(camera_pos.y) - 1
  local max_x 
    = min_x + 9 
  local max_y 
    = min_y + 9
    
  palt(0, false)
  palt(2, true)

  local render_layers = {}
  
  for i = -10, 10 do
    render_layers[i] = {}
  end

  local render_components = {
    sprite_c,
    text_c,
    rect_c,
    fill_zone_c,
  }
  
  for _, comp_table 
  in pairs(render_components) 
  do
    for e, comp 
    in pairs(comp_table) 
    do
      local pos = pos_c[e]
      if static_c[e] != nil
      or (
        pos.x >= min_x 
        and pos.x <= max_x 
        and pos.y >= min_y 
        and pos.y <= max_y 
      ) then
        if visible_c[e] == nil
        or visible_c[e] == true
        then
          add(
            render_layers[
              comp.order
            ], 
            {
              entity=e, 
              component=comp
            }
          )
        end
      end
    end
  end

  for l, list 
  in pairs(render_layers) do
    for _, obj 
    in pairs(list) do
      local e = obj.entity
      local comp 
        = obj.component
      local pos = nil
      
      if offset_c[e] == nil
      then
        pos = pos_c[e]
      else
        pos
          = pos_c[e] 
          + offset_c[e]
      end
      
      if palette_c[e] 
      != nil then
        pal(palette_c[e], 0)
      end
      
      if static_c[e] 
      != nil then
        camera(0, 0)
      end
      
      comp:render(e, pos)
      
      camera(
        camera_pos.x*16,
        camera_pos.y*16
      )
      
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
    for comp in all{sprite_c, tile_sprite_mapping} do
      for _, sprite in pairs(comp) do
        sprite.a_index += 1
        if sprite.a_index > #sprite.tiles then
          sprite.a_index = 1
        end
      end
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