doors.register("landrush:shared_door", {
	description = "Shared Door",
	inventory_image = "shared_door_inv.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles = {{name="landrush_shared_door.png", backface_culling = false}},
	recipe = {
		{'default:steel_ingot','default:steel_ingot',''},
		{'default:steel_ingot','landrush:landclaim',''},
		{'default:steel_ingot','default:steel_ingot',''}
	}
})

-- table used to aid door opening/closing
local transform = {
	{
		{v = "_a", param2 = 3},
		{v = "_a", param2 = 0},
		{v = "_a", param2 = 1},
		{v = "_a", param2 = 2},
	},
	{
		{v = "_b", param2 = 1},
		{v = "_b", param2 = 2},
		{v = "_b", param2 = 3},
		{v = "_b", param2 = 0},
	},
	{
		{v = "_b", param2 = 1},
		{v = "_b", param2 = 2},
		{v = "_b", param2 = 3},
		{v = "_b", param2 = 0},
	},
	{
		{v = "_a", param2 = 3},
		{v = "_a", param2 = 0},
		{v = "_a", param2 = 1},
		{v = "_a", param2 = 2},
	},
}

local sdoor_toggle = function(pos, node, clicker)
	local meta = minetest.get_meta(pos)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local name = def.door.name

	local state = meta:get_string("state")
	if state == "" then
		-- fix up lvm-placed right-hinged doors, default closed
		if node.name:sub(-2) == "_b" then
			state = 2
		else
			state = 0
		end
	else
		state = tonumber(state)
	end

	if clicker and not minetest.check_player_privs(clicker, "protection_bypass") then
		local owner = meta:get_string("doors_owner")
		if owner ~= "" then
			if clicker:get_player_name() ~= owner then
				return false
			end
		end
	end

	-- until Lua-5.2 we have no bitwise operators :(
	if state % 2 == 1 then
		state = state - 1
	else
		state = state + 1
	end

	local dir = node.param2
	if state % 2 == 0 then
		minetest.sound_play(def.door.sounds[1],
			{pos = pos, gain = 0.3, max_hear_distance = 10})
	else
		minetest.sound_play(def.door.sounds[2],
			{pos = pos, gain = 0.3, max_hear_distance = 10})
	end

	minetest.swap_node(pos, {
		name = name .. transform[state + 1][dir+1].v,
		param2 = transform[state + 1][dir+1].param2
	})
	meta:set_int("state", state)

	return true
end

-- now override this definition so we can put a custom on_rightclick function
--local ad = minetest.registered_nodes['landrush:shared_door_a']
--local ab = minetest.registered_nodes['landrush:shared_door_b']
local ad = {}
ad.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local name = clicker:get_player_name()
	if landrush.can_interact(pos,name) then
		sdoor_toggle(pos, node, clicker)
	end
	return itemstack
end

minetest.override_item("landrush:shared_door_a", ad)
minetest.override_item("landrush:shared_door_b", ad)