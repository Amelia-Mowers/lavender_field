function _draw()
  cls()
  set_cam()
  render_map()
  render_objects()
  camera(0, 0)
  if state == "loss" 
  then
    render_loss()
  end
  if state == "start" then
    cls()
    render_start_menu()
  elseif state == "victory" 
  then
    cls()
    render_victory()
  end
   print(state, 0, 0)
   print(debug_print)
  end
  