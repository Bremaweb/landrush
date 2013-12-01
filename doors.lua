if minetest.get_modpath("doors") then
	function landrush.protect_against_door(door)
		local definition = minetest.registered_items[door]
		local on_place = definition.on_place
		function definition.on_place(itemstack, placer, pointed_thing)
			local bottom = pointed_thing.above
			local top = {x=pointed_thing.above.x, y=pointed_thing.above.y+1, z=pointed_thing.above.z}
			local name = placer:get_player_name()
			if landrush.can_interact(top,name) and landrush.can_interact(bottom, name) then
				return on_place(itemstack, placer, pointed_thing)
			else
				topowner = landrush.get_owner(top)
				bottomowner = landrush.get_owner(bottom)
				if topowner and bottomowner and topowner ~= bottomowner then
					minetest.chat_send_player(name, "Area owned by "..topowner.." and "..bottomowner)
				elseif topowner then
					minetest.chat_send_player(name, "Area owned by "..topowner)
				else
					minetest.chat_send_player(name, "Area owned by "..bottomowner)
				end
			end
		end
	end

	landrush.protect_against_door("doors:door_wood")
	landrush.protect_against_door("doors:door_steel")
end

