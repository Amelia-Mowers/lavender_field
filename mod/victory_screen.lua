function render_victory()
  local txt = text:new("invicta!", 9, 0)
  txt:render(nil, vec2:new(4 - txt:size().x/2,3.75))
  
  local txt2 = text:new("press ❎/🅾️ to restart", 9, 0)
  txt2:render(nil, vec2:new(4 - txt2:size().x/2,4.25))
end
  
  function victory_control()
    if (
      btn(❎) 
      or btn(🅾️)
    )
    and select_cool.finished
    then
      for e, _ 
      in pairs(obj_c) do
        if player_c[e] == nil then
          delete(e)
        end
      end
      
      cur_map = maps[
        cur_map.next_map
      ]
      init_map()
      next_state = "new_round"
      select_cool:restart()
    end
  end