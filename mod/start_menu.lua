start_timer = timer:new(.4)
start_anim = 1
start_color = {13,6}

function render_start_menu()
  start_timer:tick()
  if start_timer.finished then
    start_timer:restart()
    start_anim += 1
		  if start_anim
		  > #start_color
		  then
		    start_anim = 1
		  end
		end
  
  spr(
    128,
    32, 40, 
    8, 4
  )
  
  local text
    = "press ❎/🅾️ to start"
    
  local t_len, _ 
    = print(text, -10, -10) 
    
  local tx 
    = 64 
    - t_len/2 
    - 3
  local ty
    = 80
  
  print(text, tx+1, ty+1, 1)
  print(
    text, tx, ty,
    start_color[start_anim]
  )
end

function start_menu_control()
  if (
    btn(❎) 
    or btn(🅾️)
  )
  and select_cool.finished
  then
    next_state = "pick"
    select_cool:restart()
  end
end