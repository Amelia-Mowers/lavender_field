function render_victory()
    local text
      = "victory!"
      
    local t_len, _ 
      = print(text, -10, -10) 
      
    local tx 
      = 64 
      - t_len/2 
      - 3
    local ty
      = 64
    
    print(
      text, tx, ty,
      6
    )

    text
      = "press ❎/🅾️ to next level"
      
    t_len, _ 
      = print(text, -10, -10) 
      
    tx 
      = 64 
      - t_len/2 
      - 3
    ty
      = 74
    
    print(
      text, tx, ty,
      6
    )
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
        delete(e)
      end
      
      cur_map = maps[
        cur_map.next_map
      ]
      init_map()
      next_state = "pick"
      select_cool:restart()
    end
  end