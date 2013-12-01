--[[
Screwdriver replacement to fit the needs of the landrush mod.
Otherwise it will be possible to open doors without permission.
]]

if minetest.get_modpath("screwdriver") then
	-- Start overwriting the standard function
	tmp_tool = minetest.registered_tools["screwdriver:screwdriver"]
	if tmp_tool == nil then
		print("Something went wrong when correcting the screwdriver...")
	end
	if tmp_tool.on_use == nil then
		print( "tmp_tool.on_use is a nil value... ")
	end
	tmp_tool.on_use = function(itemstack, user, pointed_thing)
		safe_screwdriver_handler(itemstack, user, pointed_thing)
		return itemstack
	end
	minetest.registered_tools["screwdriver:screwdriver"] = tmp_tool
	for i = 1,4,1 do
		tmp_tool = minetest.registered_tools["screwdriver:screwdriver"..i]
		tmp_tool.on_use = function(itemstack, user, pointed_thing)
			safe_screwdriver_handler(itemstack, user, pointed_thing)
			return itemstack
		end
		minetest.registered_tools["screwdriver:screwdriver"..i] = tmp_tool
	end
	print( "Rewritten screwdriver routines..." )
end


function safe_screwdriver_handler (itemstack,user,pointed_thing)
	local keys=user:get_player_control()
	local player_name=user:get_player_name()
	local item=itemstack:to_table()
	if item["metadata"]=="" or keys["sneak"]==true then return screwdriver_setmode(user,itemstack) end
	local mode=tonumber((item["metadata"]))
	if pointed_thing.type~="node" then return end
	local pos=minetest.get_pointed_thing_position(pointed_thing,above)
	-- Landrush fix
	if not landrush.can_interact( pos, player_name ) then
		return nil
	end
	-- end fix
	local node=minetest.get_node(pos)
	local node_name=node.name
	if minetest.registered_nodes[node_name].paramtype2 == "facedir" then
		if minetest.registered_nodes[node_name].drawtype == "nodebox" then
			if minetest.registered_nodes[node_name].node_box["type"]~="fixed" then return end
			end
		if node.param2==nil  then return end
		-- Get ready to set the param2
			local n = node.param2
			local axisdir=math.floor(n/4)
			local rotation=n-axisdir*4
			if mode==1 then
				rotation=rotation+1
				if rotation>3 then rotation=0 end
				n=axisdir*4+rotation
			end

			if mode==2 then
				local ppos=user:getpos()
				local pvect=user:get_look_dir()
				local face=get_node_face(pos,ppos,pvect)
				if face == nil then return end
				local index=convertFaceToIndex(face)
				local face1=faces_table[n*6+index+1]
				local found = 0
				while found == 0 do
					n=n+1
					if n>23 then n=0 end
					if faces_table[n*6+index+1]==face1 then found=1 end
				end
			end

			if mode==3 then
				axisdir=axisdir+1
				if axisdir>5 then axisdir=0 end
				n=axisdir*4
			end

			if mode==4 then
				local ppos=user:getpos()
				local pvect=user:get_look_dir()
				local face=get_node_face(pos,ppos,pvect)
				if face == nil then return end
				if axisdir == face then
					rotation=rotation+1
				if rotation>3 then rotation=0 end
					n=axisdir*4+rotation
				else
					n=face*4
				end
			end
			--print (dump(axisdir..", "..rotation))
			local meta = minetest.get_meta(pos)
			local meta0 = meta:to_table()
			node.param2 = n
			minetest.set_node(pos,node)
			meta = minetest.get_meta(pos)
			meta:from_table(meta0)
			local item=itemstack:to_table()
			local item_wear=tonumber((item["wear"]))
			item_wear=item_wear+327
			if item_wear>65535 then itemstack:clear() return itemstack end
			item["wear"]=tostring(item_wear)
			itemstack:replace(item)
			return itemstack
	end
end
