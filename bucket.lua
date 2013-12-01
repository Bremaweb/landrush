if minetest.get_modpath("bucket") then
	minetest.register_craftitem(":bucket:bucket_empty", {
		description = "Emtpy bucket",
		inventory_image = "bucket.png",
		stack_max = 1,
		liquids_pointable = true,
		on_use = function(itemstack, user, pointed_thing)
		-- Must be pointing to node
			if pointed_thing.type ~= "node" then
				return
			end
		-- Check if pointing to a liquid source
			n = minetest.env:get_node(pointed_thing.under)
			liquiddef = bucket.liquids[n.name]
			if liquiddef ~= nil and liquiddef.source == n.name and liquiddef.itemname ~= nil then
				local player = user:get_player_name()
				if landrush.can_interact(pointed_thing.under, player) then
					minetest.env:add_node(pointed_thing.under, {name="air"})
					return {name=liquiddef.itemname}
				else
					owner = landrush.get_owner(pointed_thing.under)
					minetest.chat_send_player(user:get_player_name(), "Area owned by "..owner)
				end
			end
		end,
	})

	for key, value in pairs(bucket.liquids) do
		if minetest.registered_items[value.itemname].on_use then
			local item = minetest.registered_items[value.itemname]
			local on_use = item.on_use
			function item.on_use(itemstack, user, pointed_thing)
				if pointed_thing.type ~= "node" then
					return
				end
				n = minetest.env:get_node(pointed_thing.under)
				local player = user:get_player_name()
				if minetest.registered_nodes[n.name].buildable_to then
					if landrush.can_interact(pointed_thing.under, player) then
						return on_use(itemstack, user, pointed_thing)
					else
						minetest.chat_send_player(player, "Area owned by "..landrush.get_owner(pointed_thing.above))
					end
				else
					if landrush.can_interact(pointed_thing.above, player) then
						return on_use(itemstack, user, pointed_thing)
					else
						minetest.chat_send_player(player, "Area owned by "..landrush.get_owner(pointed_thing.above))
					end
				end
			end
		end
	end
end

