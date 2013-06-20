minetest.log('action','Loading Land Rush Land Claim')

landrush = {}

local requireClaim = false 		-- Change this to true if you want to require people to claim an area before building or digging
local onlineProtection = true	-- false turns protection off when the claim owner is online

local offenseDamage = 4			-- how much damage is dealt to the player when they dig in protected areas

local autoBan = false		-- users who attempt to dig and build in claimed areas can be auto banned
local banLevel = 40			-- the offense level they must exceed to get banned, 40 is roughly 5 nodes dug in the same area
local banWarning = 25		-- the offense level they start getting ban warnings
local offenseReset = 1440	-- after this number of minutes all offenses will be forgiven
local adminUser = nil		-- this user will be messaged if chat plus is installed when a player is autobanned

local chunkSize = 16		-- don't change this value after you start using landrush
local claims = {}
local offense = {}

gstepCount = 0
playerHudItems = {}

-- These are items that can be dug in unclaimed areas when requireClaim is true
local global_dig_list = {["default:ladder"]=true,["default:leaves"]=true,["default:tree"]=true,["default:grass"]=true,["default:grass_1"]=true,["default:grass_2"]=true,["default:grass_3"]=true,["default:grass_4"]=true}

local filename = minetest.get_worldpath().."/landrush-claims"

minetest.register_privilege("landrush", "Allows player to dig and build anywhere, and use the landrush chat commands.")

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
			minetest.chat_send_player(player, "Area owned by "..owner.." stop trying to dig here!")
			digger:set_hp( digger:get_hp() - offenseDamage )
			--[[ **********************************************
					START THE AUTOBAN SECTION!!					
				***********************************************]]
			if ( autoBan == true ) then
				if ( offense[player] == nil ) then
					offense[player] = {count=0,lastpos=nil,lasttime=os.time(),bancount=0}
				end
				
				local timediff = (os.time() - offense[player].lasttime)/60
				local distance = landrush.get_distance(offense[player].lastpos,pos)
				
				-- reset offenses after a given time period
				if timediff > offenseReset then
					offense[player].count=0
				end
				
				-- offense amount starts at 10 and is decreased based on the length of time between offenses
				-- and the distance from the last offense. This weighted system tries to make it fair for people who aren't
				-- intentionally griefing
				offenseAmount = ( 10 - ( timediff / 10 ) ) - ( ( distance / chunkSize ) * 0.5 )
							
				offense[player].count=offense[player].count + offenseAmount
				minetest.log("action",player.." greifing attempt")
								
				if ( offense[player].count > banLevel ) then
					offense[player].bancount = offense[player].bancount + 1
					
					local banlength = offense[player].bancount * 10
					
					if ( offense[player].bancount < 4 ) then
						minetest.chat_send_player(player, "You have been banned for "..tostring(banlength).." minutes!")
					else
						minetest.chat_send_player(player, "You have been banned!")
					end
					
					minetest.log("action",player.." has been banned for griefing attempts")
					minetest.chat_send_all(player.." has been banned for griefing attempts")
					
					if ( chatplus and adminUser ~= nil) then					
						table.insert(chatplus.players[adminUser].messages,"mail from <LandRush>: "..player.." banned for "..tostring(banlength).." minutes for attempted griefing")					
					end
					minetest.ban_player(player)
					
					offense[player].count = 0
					offense[player].lastpos = nil
					
					if ( offense[player].bancount < 4 ) then
						minetest.after( (banlength * 60), minetest.unban_player_or_ip,player )
					end
					
					return
				end
				
				if ( offense[player].count > banWarning ) then
					minetest.chat_send_player(player, "Stop trying to dig in claimed areas or you will be banned!")
					minetest.chat_send_player(player, "Use /showarea and /landowner to see the protected area and who owns it.")
					minetest.sound_play("landrush_ban_warning", {to_player=player,gain = 10.0})					
				end
				
				offense[player].lasttime = os.time()
				offense[player].lastpos = pos
				
			end
			--[[ **********************************************
					END THE AUTOBAN SECTION!!					
				***********************************************]]
		else
			-- allow them to dig the global dig list		
			if ( global_dig_list[node['name']] ~= true ) then
				minetest.chat_send_player(player,"Area unclaimed, claim this area to build")
			else
				landrush.default_dig(pos, node, digger)
			end
		end
	end
end

function minetest.item_place(itemstack, placer, pointed_thing)	
	owner = landrush.get_owner(pointed_thing.above)
	player = placer:get_player_name()
		if landrush.can_interact(player, pointed_thing.above) then
			return landrush.default_place(itemstack, placer, pointed_thing)
		else
			if ( owner ~= nil ) then
				minetest.chat_send_player(player, "Area owned by "..owner)
				return itemstack				
			else
				minetest.chat_send_player(player,"Area unclaimed, claim this area to build")
				return itemstack
			end
		end	
end
				
landrush.load_claims()
-- Load now

-- In-game additions:
function landrush.register_claimnode(node, image)
	local claimnode = minetest.get_current_modname()..":"..node
	minetest.register_node(claimnode, {
		description = "Land Rush Land Claim",
		tiles = {image},
		groups = {oddly_breakable_by_hand=2},
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

landrush.register_claimnode("landclaim", "landrush_landclaim.png")
landrush.register_claimnode("landclaim_b", "landrush_landclaim.png")

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
		visual_size = {x=16.1, y=16.1},
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

minetest.register_globalstep(function(dtime)
	gstepCount = gstepCount + dtime
	if ( gstepCount > 2 ) then
	local sameowner = false
		for _,player in pairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			
			owner = landrush.get_owner(player:getpos())
			
			if ( playerHudItems[name] ~= nil ) then
				if ( playerHudItems[name].lastowner == owner ) then
					-- same owner as last time don't update the hud
					sameowner = true				
				end
			end
			
			if ( playerHudItems[name] ~= nil and sameowner == false ) then
					player:hud_remove(playerHudItems[name].hud)
					playerHudItems[name] = nil
			end
			
			if ( owner ~= nil and sameowner == false ) then
				minetest.log('action','Redraw hud for'..name)			
				playerHudItems[name] = {hud = player:hud_add({
						hud_elem_type = "text",
						name = "LandOwner",
						number = 0xFFFFFF,
						position = {x=.2, y=.98},
						text="Land Owner: "..owner,
						scale = {x=200,y=25},
						alignment = {x=0, y=0},
				}), lastowner=owner}			
			end			
		end
		gstepCount = 0
	end
end)

function landrush.get_distance(pos1,pos2)

if ( pos1 ~= nil and pos2 ~= nil ) then
	return math.abs(math.floor(math.sqrt( (pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2 + (pos1.z - pos2.z)^2 )))
else
	return 0
end

end

minetest.after( 10, function ()
local path = minetest.get_modpath("landrush")

dofile(path.."/bucket.lua")
dofile(path.."/default.lua")
dofile(path.."/doors.lua")
dofile(path.."/fire.lua")
dofile(path.."/chatcommands.lua")
end )