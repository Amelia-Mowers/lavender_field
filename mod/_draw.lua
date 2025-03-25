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
  add(debug_print, state)
  add(debug_print, exp)
  print("",0,0,6)
  for a in all(debug_print) do
    print(a)
  end
end
  