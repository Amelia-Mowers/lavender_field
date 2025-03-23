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
block_sight_c = batch_comp(14)

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

mob = {
  knight = function(pos)
    return insert(new_mob(
      "knight",
      pos,
      st.knight,
      {
        {spawn_focus_c},
        {player_c},
        {
          health_c, 
          health:new(6)
        },
        {defense_c, {
          [dam_type.phys] = 2,
        }},
      }
    ))
  end,
  wiz = function(pos)
    return insert(new_mob(
      "wiz",
      pos,
      st.wiz,
      {
        {player_c},
      }
    ))
  end,
  gnome = function(pos)
    return insert(new_mob(
      "gnome",
      pos,
      st.gnome,
      {
        {player_c},
        {attack_c, 7},
      }
    ))
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