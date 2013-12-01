if minetest.get_modpath("default") then	
	minetest.register_node(":default:sign_wall", {
		description = "Sign",
		drawtype = "signlike",
		tiles = {"default_sign_wall.png"},
		inventory_image = "default_sign_wall.png",
		wield_image = "default_sign_wall.png",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "wallmounted",
		--wall_top = <default>
		--wall_bottom = <default>
		--wall_side = <default>
		},
		groups = {choppy=2,dig_immediate=2},
		legacy_wallmounted = true,
		sounds = default.node_sound_defaults(),
		on_construct = function(pos)
		--local n = minetest.env:get_node(pos)
		
			local meta = minetest.env:get_meta(pos)
			meta:set_string("formspec", "hack:sign_text_input")
			meta:set_string("infotext", "\"\"")
		end,
		on_receive_fields = function(pos, formname, fields, sender)
		--print("Sign at "..minetest.pos_to_string(pos).." got "..dump(fields))
			local name = sender:get_player_name()
			if landrush.can_interact(pos, name) then
				local meta = minetest.env:get_meta(pos)
				fields.text = fields.text or ""
				print((name or "").." wrote \""..fields.text..
					"\" to sign at "..minetest.pos_to_string(pos))
				meta:set_string("text", fields.text)
				meta:set_string("infotext", '"'..fields.text..'"')
			else
				local owner = landrush.get_owner(pos)
				minetest.chat_send_player(name, "Area owned by "..owner)
			end
		end,
	})
end

