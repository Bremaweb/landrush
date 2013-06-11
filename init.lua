-- Lua definitions:

landrush = {}

-- Change this to true if you want to require people to claim an area before building or digging
local requireClaim = false
local onlineProtection = true
local chunkSize = 16

local claims = {}

-- These are items that can be dug in unclaimed areas when requireClaim is true
local global_dig_list = {["default:ladder"]=true,["default:leaves"]=true,["default:tree"]=true}

local filename = minetest.get_worldpath().."/landrush-claims"

minetest.register_privilege("landrush", "Allows player to dig and build anywhere")

function landrush.load_claims()
	local file = io.open(filename, "r")
	if file then
		for line in file:lines() do
			if line ~= "" then
				local area = line:split(" ")
				local shared = {}
				if area[3] and area[3] ~= "*" then
					for k,v in ipairs(area[3]:split(",")) do
						shared[v] = v
					end
				end
				local claimtype
				if area[4] then
					claimtype = area[4]
				else
					claimtype = "landrush:landclaim"
				end
				claims[area[1]] = {owner=area[2], shared=shared, claimtype=claimtype}
			end
		end
		file:close()
	end
end

function landrush.save_claims()
	local file = io.open(filename, "w")
	for key,value in pairs(claims) do
		local sharedata = ""
		for k,v in pairs(value.shared) do
			sharedata = sharedata..v..","
		end
		local sharestring
		if sharedata == "" then
			sharestring = "*"
		else
			sharestring = sharedata:sub(1,-2)
		end
		file:write(key.." "..value.owner.." "..sharestring.." "..value.claimtype.."\n")
	end
	file:close()
end

function landrush.get_chunk(pos)
	local x = math.floor(pos.x/chunkSize)
	-- 3 levels of vertical protection	
	local y = 0
	
	if ( pos.y < -60 ) then
		y = -200
	elseif ( pos.y < 140 ) then
		y = -30
	else
		y = 90
	end
	
	
	local z = math.floor(pos.z/chunkSize)
	return x..","..y..","..z
end

function landrush.get_chunk_center(pos)
	local x = math.floor(pos.x/chunkSize)*chunkSize+7.5
	local y = 0
	
	if ( pos.y < -60 ) then
		y = -200
	elseif ( pos.y < 120 ) then
		y = -30
	else
		y = 120
	end
	
	local z = math.floor(pos.z/chunkSize)*chunkSize+7.5
	return {x=x,y=y,z=z}
end

function landrush.get_owner(pos)
	local chunk = landrush.get_chunk(pos)
	if claims[chunk] then
		return claims[chunk].owner
	end
end

function landrush.can_interact(name, pos)

	if ( minetest.check_player_privs(name, {landrush=true}) ) then
		return true
	end
	
	local chunk = landrush.get_chunk(pos)
	-- return claims[chunk] == nil or claims[chunk].owner == name or claims[chunk].shared[name]
	if ( claims[chunk] == nil ) then
		if ( requireClaim == true ) then
			return false
		else
			return true
		end		
	end
	
	-- if it's the owner or it's shared
	if ( claims[chunk].shared[name] or claims[chunk].owner == name ) then
		return true
	end
	
	-- see if the owner is offline, and area is not shared then it's off limits
	if ( minetest.env:get_player_by_name(claims[chunk].owner) == nil ) then
		if ( claims[chunk].shared[name] ) then
			return true
		else
			return nil
		end
	else
		if ( claims[chunk].owner ~= name and onlineProtection == false ) then
			minetest.chat_send_player( claims[chunk].owner, "You are being griefed by "..name.." at "..minetest.pos_to_string(pos) )
						
			for u,u in pairs(claims[chunk].shared) do
				minetest.chat_send_player( u, name.." is griefing your shared claim at "..minetest.pos_to_string(pos) )
			end
			
			minetest.chat_send_player( name, "You are griefing "..claims[chunk].owner )
			return true
		end
	end
	return claims[chunk].owner == name or claims[chunk].shared[name]
end

landrush.default_place = minetest.item_place
landrush.default_dig = minetest.node_dig

-- Redefined Lua:

function minetest.node_dig(pos, node, digger)
	local player = digger:get_player_name()
	if landrush.can_interact(player, pos) then
		landrush.default_dig(pos, node, digger)
	else
		local owner = landrush.get_owner(pos)
		if ( owner ~= nil ) then
			minetest.chat_send_player(player, "Area owned by "..owner)
		else
			-- allow them to dig the global dig list		
			if ( global_dig[node['name']] ~= true ) then
				minetest.chat_send_player(player,"Area unclaimed, claim this area to build")
			else
				landrush.default_dig(pos, node, digger)
			end
		end
	end
end

function minetest.item_place(itemstack, placer, pointed_thing)
	if itemstack:get_definition().type == "node" and itemstack:get_name() ~= "default:ladder" then
	owner = landrush.get_owner(pointed_thing.above)
	player = placer:get_player_name()
		if landrush.can_interact(player, pointed_thing.above) then
			return landrush.default_place(itemstack, placer, pointed_thing)
		else
			if ( owner ~= nil ) then
				minetest.chat_send_player(player, "Area owned by "..owner)				
			else
				minetest.chat_send_player(player,"Area unclaimed, claim this area to build")
			end
		end
	else
		return landrush.default_place(itemstack, placer, pointed_thing)
	end
end
				
landrush.load_claims()
-- Load now

-- In-game additions:

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
	params = "<name>",
	description = "shares the current map chunk with <name>",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		local owner = landrush.get_owner(pos)
		if owner then
			if ( owner == name and name ~= param ) or minetest.check_player_privs(name, {landrush=true}) then
				if minetest.env:get_player_by_name(param) then
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

function landrush.regester_claimnode(node, image)
	local claimnode = minetest.get_current_modname()..":"..node
	minetest.register_node(claimnode, {
		description = "Land Rush Land Claim",
		tiles = {image},
		groups = {oddly_breakable_by_hand=2,not_in_creative_inventory=1},
		on_place = function(itemstack, placer, pointed_thing)
			owner = landrush.get_owner(pointed_thing.above)
			player = placer:get_player_name()
			if owner then
				minetest.chat_send_player(player, "This area is already owned by "..owner)
			else
				minetest.env:remove_node(pointed_thing.above)
				chunk = landrush.get_chunk(pointed_thing.above)
				claims[chunk] = {owner=placer:get_player_name(),shared={},claimtype=claimnode}
				landrush.save_claims()
				minetest.chat_send_player(claims[chunk].owner, "You now own this area.")
				itemstack:take_item()
				return itemstack
			end
		end,
	})
end

landrush.regester_claimnode("landclaim", "landrush_landclaim.png")
landrush.regester_claimnode("landclaim_b", "landrush_landclaim.png")

minetest.register_entity("landrush:showarea",{
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(16,function()
			self.object:remove()
		end)
	end,
	initial_properties = {
		hp_max = 1,
		physical = true,
		weight = 0,
		collisionbox = {-8,-8,-8,8,8,8},
		visual = "mesh",
		visual_size = {x=16.1, y=120.1},
		mesh = "landrush_showarea.x",
		textures = {"landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
	}
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

minetest.after(0,function()
	
	local path = minetest.get_modpath("landrush")
	dofile(path.."/bucket.lua")
	dofile(path.."/default.lua")
	dofile(path.."/doors.lua")
	dofile(path.."/fire.lua")
	minetest.log('action','Loading Land Rush Land Claim')
end)

