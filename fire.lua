if minetest.get_modpath("fire") then
	landrush.default_flame_should_extinguish = fire.flame_should_extinguish

	function fire.flame_should_extinguish(pos)
		for x = -1, 1 do
			for y = -1, 1 do
				for z = -1, 1 do
					if not landrush.can_interact({x=pos.x+x,y=pos.y+y,z=pos.z+z},"-!-") then
						return true
					end
				end
			end
		end
		return landrush.default_flame_should_extinguish(pos)
	end
end
