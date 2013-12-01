if minetest.get_modpath("fire") then
	landrush.default_flame_should_extinguish = fire.flame_should_extinguish

	function fire.flame_should_extinguish(pos)
		corner0 = landrush.can_interact({x=pos.x-1,y=pos.y-1,z=pos.z-1},"-!-")
		corner1 = landrush.can_interact({x=pos.x-1,y=pos.y-1,z=pos.z+1},"-!-")
		corner2 = landrush.can_interact({x=pos.x-1,y=pos.y+1,z=pos.z-1},"-!-")
		corner3 = landrush.can_interact({x=pos.x-1,y=pos.y+1,z=pos.z+1},"-!-")
		corner4 = landrush.can_interact({x=pos.x+1,y=pos.y-1,z=pos.z-1},"-!-")
		corner5 = landrush.can_interact({x=pos.x+1,y=pos.y-1,z=pos.z+1},"-!-")
		corner6 = landrush.can_interact({x=pos.x+1,y=pos.y+1,z=pos.z-1},"-!-")
		corner7 = landrush.can_interact({x=pos.x+1,y=pos.y+1,z=pos.z+1},"-!-")
		if corner0 and corner1 then
			return landrush.default_flame_should_extinguish(pos)
		else
			return true
		end
	end
end

