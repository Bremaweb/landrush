
minetest.register_node("landrush:sale_block",{
	description="Landrush Sale Block",
	tiles={"landrush_sale_block.png"},
	groups = {crumbly=2,snappy=2,oddly_breakable_by_hand=2},
	drop = "landrush:sale_block",
			
	after_place_node = function (pos, placer)
		local name = placer:get_player_name()
		local owner = landrush.get_owner(pos)
		local meta = minetest.get_meta(pos)
		if ( name == owner ) then			
			meta:set_int("price",0)
			meta:set_string("infotext", "For sale by "..owner)
			meta:set_string("note","")
			meta:set_string("formspec", landrush.sell_formspec(pos, placer))
		else
			meta:set_string("infotext","Not for sale")
			minetest.chat_send_player(name,"You can't sell a claim you don't own")						
		end
	end,
		
	on_punch = function (pos, node, puncher)
		-- do the sale -- maybe a are you sure formspec?
		local name = puncher:get_player_name()
		local owner = landrush.get_owner(pos)
		if ( name ~= owner and owner ~= nil ) then			
			local meta = minetest.get_meta(pos)
			local price = meta:get_int("price")
			
			if ( price == 0 ) then
				minetest.chat_send_player(name,'Land Sale setup not complete')
				return
			end
			
			if ( money.get(name) >= price ) then
				local transfer = money.transfer(name,owner,price)
				if ( transfer == nil ) then
					chunk = landrush.get_chunk(pos)
					landrush.claims[chunk] = {owner=name,shared={},claimtype='landclaim'}
					landrush.save_claims()
					minetest.chat_send_player(landrush.claims[chunk].owner, "You now own this claim.")
					minetest.remove_node(pos)
					
					if ( chatplus ) then					
						table.insert(chatplus.players[owner].messages,"mail from <LandRush>: "..name.." has bought your claim at "..minetest.pos_to_string(pos).." for "..tostring(price))					
					end
					
				else
					minetest.chat_send_player(name,"Money transfer failed: "..transfer)
				end
			else
				minetest.chat_send_player(name,"You do not have enough to purchase this claim")
			end			
		end
	end,

	on_receive_fields = function ( pos, formname, fields, sender )
		--process formspec
		local name = sender:get_player_name()
		local owner = landrush.get_owner(pos)
		if ( name == owner ) then
			local meta = minetest.get_meta(pos)
			meta:set_int("price",fields.price)
			meta:set_string("note",fields.note)
			meta:set_string("infotext","For sale by "..owner.." for " .. tostring(fields.price) .." "..fields.note)
			meta:set_string("formspec",landrush.sell_formspec(pos,sender))
		else
			minetest.chat_send_player(name,"You can't configure this sale!")
		end
	end,

})

minetest.register_craft({
	output = "landrush:sale_block",
	recipe = {
		{"","group:wood","group:wood"},
		{"","group:wood",""},
		{"group:wood","group:wood",""}
	}
})

function landrush.sell_formspec(pos,player)
	local meta = minetest.env:get_meta(pos)	
	local price = meta:get_int("price")
	local note = meta:get_string("note")
	
	local formspec = "size[4,6;]"
				.."label[0,0;Setup Sale]"				
				.."field[.25,2;2,1;price;Sale Price;"..price.."]"
				.."field[.25,4;4,1;note;Notes;"..note.."]"
				.."button_exit[.75,5;2,1;save;Save]"	
	
	return formspec
end
