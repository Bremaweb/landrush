-- create a new type of sign that is not protected by landrush mod

local signdef = table.copy(minetest.registered_nodes["default:sign_wall"])

signdef.description = "Unprotected Sign"
signdef.on_receive_fields = function(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	fields.text = fields.text or ""
	print((sender:get_player_name() or "").." wrote \""..fields.text..
			"\" to sign at "..minetest.pos_to_string(pos))
	meta:set_string("text", fields.text)
	meta:set_string("infotext", '"'..fields.text..'"')
end

minetest.register_node("landrush:unlocked_sign", signdef)


minetest.register_craft({
	output = 'landrush:unlocked_sign 6',
	recipe = {
		{'default:wood','default:wood','default:wood'},
		{'default:wood','default:wood','landrush:landclaim'},
		{'','default:stick',''}
	}
}) 
