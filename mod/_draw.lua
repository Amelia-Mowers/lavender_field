function _draw()
    cls()
    if state == "start" then
      render_start_menu()
    elseif state == "victory" 
    then
      render_victory()
    else
      set_cam()
      render_map()
      render_objects()
      camera(0, 0)
    end
  --  print(state, 0, 0)
  --  print(debug_print)
  end
  