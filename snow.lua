--[[
Snow mod rewrite to make it secure for use on landrush
This is a quick workaround before we can upload
an working fix which restores original functionality
]]
if minetest.get_modpath( 'snow' ) then
	local entity_prototype = minetest.registered_entities['snow:snowball_entity']
	if not entity_prototype then
		print( 'COuld not detect snowball prototype...')
		return
	end
	entity_prototype.on_step = function(self, dtime)
		self.timer=self.timer+dtime
		local pos = self.object:getpos()
		local node = minetest.get_node(pos)

		if self.lastpos.x~=nil then
			if node.name ~= "air" then
				if landrush.can_interact( pos, ' ' ) then
					snow.place(pos)
				end
				self.object:remove()
			end
		end
		self.lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
	end
end
