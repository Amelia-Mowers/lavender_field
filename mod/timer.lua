removal_timer_c = new_comp()

timer = {}
timer.__index = timer

function timer:new(limit)
	 obj = {
	   limit = limit,
	   elapsed = 0,
	   finished = false,
	   just_finished = false,
	 }
	 setmetatable( 
	   obj, 
	   timer
  )
	 return obj
end

function timer.tick(self)
  last = self.elapsed
  self.elapsed = min(
    self.elapsed + 1/30,
    self.limit
  )
  self.finished = 
    self.elapsed >= self.limit
  if last != self.elapsed 
  and self.finished then
    self.just_finished = true
  else
    self.just_finished = false
  end
end

function timer.restart(t)
  t.elapsed = 0
  t.finished = false
  t.just_finished = false
end

function timer.fract(self)
  return 
    self.elapsed
    / self.limit
end

function timed_removal()
  for e, t in pairs(removal_timer_c) do
    t:tick()
    if t.finished then
      delete(e)
    end
  end
end