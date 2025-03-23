entity_counter = 0
comp_list = {}

function new_comp()
		new = {}
		add(comp_list, new)
		return new
end

function n_entity()
  out = entity_counter
  entity_counter += 1
  return out
end

function insert(comps)
  e = n_entity()
  for c in all(comps) do
  		if c[2] == nil then
  		  c[1][e] = {}
  		else
      c[1][e] = c[2]
    end
  end
  return e
end

function delete(entity)
  for c in all(comp_list) do
    c[entity] = nil
  end
end