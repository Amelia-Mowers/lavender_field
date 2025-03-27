spawn_focus_c,
name_c,
mob_c,
obj_c,
speed_c,
move_points_c,
health_c,
defense_c,
attack_c,
player_c,
remains_c,
sight_c,
block_move_c,
block_sight_c, 
on_move_onto_c = batch_comp(15)

function new_mob(
  name,
  pos,
  s,
  chain
)
  local comp_list = {
    {name_c, name},
    {pos_c, pos},
    {offset_c, vec2:new()},
    {
      sprite_c, 
      sprite:new(s,2)
    },
    {mob_c},
    {obj_c},
    {block_move_c},
    {actions_c, 2},
    {move_points_c, 0},
    {sight_c, 5},
    {speed_c, 2},
    {attack_c, 3},
    {health_c, health:new(4)},
    {defense_c, {}},
    {action_set_c, {
      actions.move,
      actions.melee,
      actions.end_turn,
    }},
  }
  
  if chain != nil then
    for c in all(chain) do
      add(comp_list,c)
    end
  end
  
  return comp_list
end

player_chars = {}

function spawn_player_char(char_type, pos, sprite_tiles, extra_components)
  if player_chars[char_type] == nil or dead_c[player_chars[char_type]] then
    player_chars[char_type] = insert(new_mob(
      char_type,
      pos,
      sprite_tiles,
      extra_components
    ))
  else
    pos_c[player_chars[char_type]] = pos
  end
  
  return player_chars[char_type]
end

mob = {
  knight = function(pos)
    return spawn_player_char("knight", pos, st.knight, {
      {spawn_focus_c},
      {player_c},
      {
        health_c, 
        health:new(6)
      },
      {defense_c, {
        [dam_type.phys] = 2,
      }},
    })
  end,
  
  wiz = function(pos)
    return spawn_player_char("wiz", pos, st.wiz, {
      {player_c},
    })
  end,
  
  gnome = function(pos)
    return spawn_player_char("gnome", pos, st.gnome, {
      {player_c},
      {attack_c, 7},
    })
  end,
  
  skeleton = function(pos)
    return insert(new_mob(
      "skeleton",
      pos,
      st.skeleton,
      {}
    ))
  end,
}