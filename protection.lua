landrush.offense = {}

function landrush.can_interact(pos, name)

	if ( pos.y < -200 ) then
		return true
	end

	if ( minetest.check_player_privs(name, {landrush=true}) ) then
		return true
	end

	local chunk = landrush.get_chunk(pos)

	if ( landrush.claims[chunk] ~= nil ) then
		if ( landrush.claims[chunk].shared['*all'] ) then
			return true
		end
	end
	
	
	-- return landrush.claims[chunk] == nil or landrush.claims[chunk].owner == name or landrush.claims[chunk].shared[name]
	if ( landrush.claims[chunk] == nil ) then
		if ( landrush.config:get_bool("requireClaim") == true ) then
			return false
		else
			return true
		end
	end

	-- see if the owner is offline, and area is not shared then it's off limits	
	if ( landrush.claims[chunk].owner ~= name and landrush.config:get_bool("onlineProtection") == false ) then
		if ( minetest.get_player_by_name(owner) ~= nil ) then
			minetest.chat_send_player( landrush.claims[chunk].owner, "You are being griefed by "..name.." at "..minetest.pos_to_string(pos) )

			for u,u in pairs(landrush.claims[chunk].shared) do
				minetest.chat_send_player( u, name.." is griefing your shared claim at "..minetest.pos_to_string(pos) )
			end

			minetest.chat_send_player( name, "You are griefing "..landrush.claims[chunk].owner )
			return true
		end
	end
	return landrush.claims[chunk].owner == name or landrush.claims[chunk].shared[name]
end

function landrush.do_autoban(pos,name) 
	-- moved this to it's own function so landrush.protection_violation is a little cleaner, and this could be overwritten as well
	
	if ( landrush.offense[name] == nil ) then
			landrush.offense[name] = {count=0,lastpos=nil,lasttime=os.time(),bancount=0}
		end

		local timediff = (os.time() - landrush.offense[name].lasttime)/60
		local distance = landrush.get_distance(landrush.offense[name].lastpos,pos)

		-- reset offenses after a given time period
		if timediff > tonumber(landrush.config:get("offenseReset")) then
			landrush.offense[name].count=0
		end

		-- offense amount starts at 10 and is decreased based on the length of time between offenses
		-- and the distance from the last offense. This weighted system tries to make it fair for people who aren't
		-- intentionally griefing
		offenseAmount = ( 10 - ( timediff / 10 ) ) - ( ( distance / landrush.config:get("chunkSize") ) * 0.5 )

		landrush.offense[name].count=landrush.offense[name].count + offenseAmount
		minetest.log("action",name.." greifing attempt")

		if ( landrush.offense[name].count > tonumber(landrush.config:get("banLevel")) ) then
			landrush.offense[name].bancount = landrush.offense[name].bancount + 1

			local banlength = landrush.offense[name].bancount * 10

			if ( landrush.offense[name].bancount < 4 ) then
				minetest.chat_send_player(name, "You have been banned for "..tostring(banlength).." minutes!")
			else
				minetest.chat_send_player(name, "You have been banned!")
			end

			minetest.log("action",name.." has been banned for griefing attempts")
			minetest.chat_send_all(name.." has been banned for griefing attempts")

			if ( chatplus and landrush.config:get("adminUser") ~= nil) then
				table.insert(chatplus.names[landrush.config:get("adminUser")].messages,"mail from <LandRush>: "..name.." banned for "..tostring(banlength).." minutes for attempted griefing")
			end
			minetest.ban_player(name)

			landrush.offense[name].count = 0
			landrush.offense[name].lastpos = nil

			if ( landrush.offense[name].bancount < 4 ) then
				minetest.after( (banlength * 60), minetest.unban_name_or_ip,name )
			end

			return
		end

		if ( landrush.offense[name].count > tonumber(landrush.config:get("banWarning")) ) then
			minetest.chat_send_player(name, "Stop trying to dig in claimed areas or you will be banned!")
			minetest.chat_send_player(name, "Use /showarea and /landowner to see the protected area and who owns it.")
			minetest.sound_play("landrush_ban_warning", {to_player=name,gain = 10.0})
		end

		landrush.offense[name].lasttime = os.time()
		landrush.offense[name].lastpos = pos
end

function landrush.protection_violation(pos,name)
	-- this function can be overwritten to apply whatever discipline the server admin wants
	-- this is the default discipline
	
	local player = minetest.get_player_by_name(name)
	
	if ( player == nil ) then
	  return
	end
	
	local owner = landrush.get_owner(pos)
	
	if ( landrush.config:get_bool("requireClaim") == true ) then
		if ( owner == nil ) then
			minetest.chat_send_player(name,"This area is unowned, but you must claim it to build or mine")
			return true
		end	
	end
	
	minetest.chat_send_player(name, "Area owned by "..tostring(owner).." stop trying to dig here!")
	player:set_hp( player:get_hp() - landrush.config:get("offenseDamage") )
	
	if ( landrush.config:get_bool("autoBan") == true ) then
		landrush.do_autoban(pos,name)
	end

end

landrush.default_is_protected = minetest.is_protected

function minetest.is_protected (pos, name)
	if ( landrush.can_interact(pos, name) ) then
		return landrush.default_is_protected(pos,name)
	else
		return true
	end
end

minetest.register_on_protection_violation( landrush.protection_violation )


-- I'm keeping this just for the TNT workaround
landrush.default_place = minetest.item_place

function minetest.item_place(itemstack, placer, pointed_thing)
	owner = landrush.get_owner(pointed_thing.above)
	name = placer:get_player_name()
		if landrush.can_interact(pointed_thing.above,name) or itemstack:get_name() == "" then
			-- add a workaround for TNT, since overwriting the registered node seems not to work
			if itemstack:get_name() == "tnt:tnt" or itemstack:get_name() == "tnt:tnt_burning" then
				local pos = pointed_thing.above
				local temp_pos = pos
				temp_pos.x = pos.x + 2
				if name ~= landrush.get_owner( temp_pos ) then
					minetest.chat_send_player( name, "Do not place TNT near claimed areas..." )
					return itemstack
				end
				temp_pos.x = pos.x - 2
				if name ~= landrush.get_owner( temp_pos ) then
					minetest.chat_send_player( name, "Do not place TNT near claimed areas..." )
					return itemstack
				end
				temp_pos.z = pos.z + 2
				if name ~= landrush.get_owner( temp_pos ) then
					minetest.chat_send_player( name, "Do not place TNT near claimed areas..." )
					return itemstack
				end
				temp_pos.z = pos.z - 2
				if name ~= landrush.get_owner( temp_pos ) then
					minetest.chat_send_player( name, "Do not place TNT near claimed areas..." )
					return itemstack
				end
			end
			-- end of the workaround
			return landrush.default_place(itemstack, placer, pointed_thing)
		else
			if ( owner ~= nil ) then
				minetest.chat_send_player(name, "Area owned by "..owner)
				return itemstack
			else
				minetest.chat_send_player(name,"Area unclaimed, claim this area to build")
				return itemstack
			end
		end
end

