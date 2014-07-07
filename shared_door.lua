function landrush.on_rightclick(pos, dir, check_name, replace, replace_dir, params)
		pos.y = pos.y+dir
		if not minetest.get_node(pos).name == check_name then
			return
		end
		local p2 = minetest.get_node(pos).param2
		p2 = params[p2+1]

		local meta = minetest.get_meta(pos):to_table()
		minetest.set_node(pos, {name=replace_dir, param2=p2})
		minetest.get_meta(pos):from_table(meta)

		pos.y = pos.y-dir
		meta = minetest.get_meta(pos):to_table()
		minetest.set_node(pos, {name=replace, param2=p2})
		minetest.get_meta(pos):from_table(meta)
	end
	
doors.register_door("landrush:shared_door", {
	description = "Shared Door",
	inventory_image = "shared_door_inv.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles_bottom = {"shared_door_b.png", "door_blue.png"},
	tiles_top = {"shared_door_a.png", "door_blue.png"},
})

minetest.register_craft({
	output = 'landrush:shared_door',
	recipe = {
		{'default:steel_ingot','default:steel_ingot',''},
		{'default:steel_ingot','landrush:landclaim',''},
		{'default:steel_ingot','default:steel_ingot',''}
	}
})



minetest.registered_nodes['landrush:shared_door_b_1'].on_rightclick = function(pos, node, clicker)
if ( landrush.can_interact(pos,clicker:get_player_name()) ) then
	landrush.on_rightclick(pos, 1, "landrush:shared_door_t_1", "landrush:shared_door_b_2", "landrush:shared_door_t_2", {1,2,3,0})
end
end

minetest.registered_nodes['landrush:shared_door_t_1'].on_rightclick = function(pos, node, clicker)
if ( landrush.can_interact(pos,clicker:get_player_name()) ) then
	landrush.on_rightclick(pos, -1, "landrush:shared_door_b_1", "landrush:shared_door_t_2", "landrush:shared_door_b_2", {1,2,3,0})
end
end

-- Fix for duplicating Bug!
-- Bug was caused, because the reverse order of the on_rightclick was not taken into account

minetest.registered_nodes['landrush:shared_door_b_2'].on_rightclick = function(pos, node, clicker)
if ( landrush.can_interact(pos,clicker:get_player_name()) ) then
	landrush.on_rightclick(pos, 1, "landrush:shared_door_t_2", "landrush:shared_door_b_1", "landrush:shared_door_t_1", {3,0,1,2})
end
end

minetest.registered_nodes['landrush:shared_door_t_2'].on_rightclick = function(pos, node, clicker)
if ( landrush.can_interact(pos,clicker:get_player_name()) ) then
	landrush.on_rightclick(pos, -1, "landrush:shared_door_b_2", "landrush:shared_door_t_1", "landrush:shared_door_b_1", {3,0,1,2})
end
end 
