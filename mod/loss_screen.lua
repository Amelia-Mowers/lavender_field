function render_loss()
  local txt = text:new("ya'll ded", 9, 0)
  txt:render(nil, vec2:new(4 - txt:size().x/2,3.75))
  
  local txt2 = text:new("press ❎/🅾️ to restart", 9, 0)
  txt2:render(nil, vec2:new(4 - txt2:size().x/2,4.25))
end

function loss_control()
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

    cur_map = maps.trail
    init_map()
    update_fog_of_war()

    next_state = "start"
    select_cool:restart()
  end
end