if minetest.get_modpath("default") then	
	minetest.override_item("default:sign_wall", {
		on_receive_fields = function(pos, formname, fields, sender)
			local name = sender:get_player_name()
			if landrush.can_interact(pos, name) then
				local meta = minetest.get_meta(pos)
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

