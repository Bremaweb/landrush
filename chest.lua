-- add a special chest that is shared among the land-possesors

minetest.register_node("landrush:shared_chest", {
		description = "Land Rush Shared Chest",
		tiles = {"landrush_shared_chest_top.png", "landrush_shared_chest_top.png", "landrush_shared_chest_side.png", "landrush_shared_chest_side.png", "landrush_shared_chest_side.png", "landrush_shared_chest_front.png"},
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,tubedevice=1,tubedevice_receiver=1},
		paramtype2 = "facedir",
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		
		can_dig = function(pos,player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			return inv:is_empty("main")
		end,
		
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec",default.chest_formspec)
			meta:set_string("infotext", "Shared Chest")
			local inv = meta:get_inventory()
			inv:set_size("main", 8*4)
		end,
		
		allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
			local meta = minetest.get_meta(pos)
			if not landrush.can_interact(pos,player:get_player_name()) then
				minetest.log("action", player:get_player_name() .. " tried to access a shared chest at ".. minetest.pos_to_string(pos))
				return 0
			end
			return count
		end,
				
	    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			local meta = minetest.get_meta(pos)
			if not landrush.can_interact(pos,player:get_player_name()) then
				minetest.log("action", player:get_player_name() .. " tried to access a shared chest at ".. minetest.pos_to_string(pos))
				return 0
			end
			return stack:get_count()
		end,
		
	    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
			local meta = minetest.get_meta(pos)
			if not landrush.can_interact(pos,player:get_player_name()) then
				minetest.log("action", player:get_player_name()..
						" tried to access a shared chest at "..
						minetest.pos_to_string(pos))
				return 0
			end
			return stack:get_count()
		end,
		
		on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
			minetest.log("action", player:get_player_name()..
					" moves stuff in shared chest at "..minetest.pos_to_string(pos))
		end,
		
	    on_metadata_inventory_put = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name()..
					" puts stuff into shared chest at "..minetest.pos_to_string(pos))
		end,
		
	    on_metadata_inventory_take = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name()..
					" takes stuff from shared chest at "..minetest.pos_to_string(pos))
		end,
		
		tube = {
				insert_object = function(pos, node, stack, direction)
					local meta = minetest.env:get_meta(pos)
					local inventory = meta:get_inventory()
					return inventory:add_item("main",stack)
				end,
				
				can_insert = function(pos, node, stack, direction)
					local meta=minetest.env:get_meta(pos)
					local inventory = meta:get_inventory()
					return inventory:room_for_item("main",stack)
				end,
				input_inventory="main",
				connect_sides = {left=1, right=1, back=1, top=1, bottom=1},
		}
})

minetest.register_craft({
	output = 'landrush:shared_chest',
	recipe = {
		{'group:wood','group:wood','group:wood'},
		{'group:wood','landrush:landclaim','group:wood'},
		{'group:wood','group:wood','group:wood'}
	}
})

minetest.register_craft({
	output = 'landrush:shared_chest',
	recipe = {
		{'landrush:landclaim'},
		{'default:chest'}
	}
})

minetest.register_craft({
	output = 'landrush:shared_chest',
	recipe = {
		{'landrush:landclaim'},
		{'default:chest_locked'}
	}
})