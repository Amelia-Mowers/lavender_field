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


st = {
    point = {
      rot_sprite(1),
      rot_sprite(17),
    },
    menu_curs = {{33,0,0,0}},
    
    knight = {4,36},
    wiz = {6,38},
    gnome = {8,40},
    
    grass = {quad_sprite(16)},
    dirt = {quad_sprite(32)},
    water = {
      {48,49,49,48},
      {49,48,48,49},
    },
    wall = {10},
    tree = {44},
    wall_bottom = {{0,0,42,43}},
    rubble = {{0,0,58,59}},
    skull = {12},
    
    gobbo = {64,96},
    warg = {66,98},
    skeleton = {68,100},
    slime = {70,102},
  }
  