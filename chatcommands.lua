
minetest.register_chatcommand("landowner", {
	params = "",
	description = "tells the owner of the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		local owner = landrush.get_owner(pos)
		if owner then
			minetest.chat_send_player(name, "This area is owned by "..owner)
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("unclaim", {
	params = "",
	description = "unclaims the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		local owner = landrush.get_owner(pos)
		local inv = player:get_inventory()
		if owner then						
			if owner == name or minetest.check_player_privs(name, {landrush=true}) then
				chunk = landrush.get_chunk(pos)
				--if inv:room_for_item("main", claims[chunk].claimtype) then
					-- player:get_inventory():add_item("main", {name=claims[chunk].claimtype}) -- they don't get their claim item back
					claims[chunk] = nil
					landrush.save_claims()
					minetest.chat_send_player(name, "You renounced your claim on this area.")
				--else
--					minetest.chat_send_player(name, "Your inventory is full.")
	--			end
			else
				minetest.chat_send_player(name, "This area is owned by "..owner)
			end
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("sharearea", {
	params = "<name> or *all to retain ownership but allow anyone to build",
	description = "shares the current map chunk with <name>",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		local owner = landrush.get_owner(pos)
		if owner then
			if ( owner == name and name ~= param ) or minetest.check_player_privs(name, {landrush=true}) then
				if minetest.env:get_player_by_name(param) or param=="*all" then
					claims[landrush.get_chunk(pos)].shared[param] = param
					landrush.save_claims()
					minetest.chat_send_player(name, param.." may now edit this area.")
					minetest.chat_send_player(param, name.." has just shared an area with you.")
				else
					minetest.chat_send_player(name, param.." is not a valid player.")
				end
			else
				minetest.chat_send_player(name, "This area is owned by "..owner)
			end
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("unsharearea", {
	params = "<name>",
	description = "unshares the current map chunk with <name>",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		local owner = landrush.get_owner(pos)
		if owner then
			if owner == name or minetest.check_player_privs(name, {landrush=true}) then
				if name ~= param then
					claims[landrush.get_chunk(pos)].shared[param] = nil
					landrush.save_claims()
					minetest.chat_send_player(name, param.." may no longer edit this area.")
					minetest.chat_send_player(param, name.." has just revoked your editing privileges in an area.")
				else
					minetest.chat_send_player(name, 'Use "/unclaim" to unclaim the aria.')
				end
			else
				minetest.chat_send_player(name, "This area is owned by "..owner)
			end
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("mayedit", {
	params = "",
	description = "lists the people who may edit the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		local mayedit = landrush.get_owner(pos)
		if mayedit then
			local chunk = landrush.get_chunk(pos)
			for user, user in pairs(claims[chunk].shared) do
				mayedit = mayedit..", "..user
			end
			minetest.chat_send_player(name, mayedit)
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("showarea", {
	params = "",
	description = "highlights the boundaries of the current protected area",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		--local owner = landrush.get_owner(pos)
--		if owner then
			--if landrush.can_interact(name, pos) then
				local entpos = landrush.get_chunk_center(pos)
				entpos.y = (pos.y-1)
				minetest.env:add_entity(entpos, "landrush:showarea")
			--else
			--	minetest.chat_send_player(name, "This area is owned by "..owner)
			--end
--[[		else
			minetest.chat_send_player(name, "This area is unowned.")
		end]]
-- (Removed at Rarkenin's request)
	end,
})
