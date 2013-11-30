landrush.gstepCount = 0
landrush.playerHudItems = {}

minetest.register_globalstep(function(dtime)
	landrush.gstepCount = landrush.gstepCount + dtime
	if ( landrush.gstepCount > 2 ) then
		landrush.gstepCount=0
		local oplayers = minetest.get_connected_players()
		for _,player in ipairs(oplayers) do
			local name = player:get_player_name()
			local sameowner = false
			owner = landrush.get_owner(player:getpos())

			if ( landrush.playerHudItems[name] ~= nil ) then
				if ( landrush.playerHudItems[name].lastowner == owner ) then
					-- same owner as last time don't update the hud
					sameowner = true
				end
			end

			if ( landrush.playerHudItems[name] ~= nil and sameowner == false ) then
					player:hud_remove(landrush.playerHudItems[name].hud)
					landrush.playerHudItems[name] = nil
			end

			if ( owner ~= nil and sameowner == false ) then
				--minetest.log('action','Redraw hud for '..name)
				landrush.playerHudItems[name] = {hud = player:hud_add({
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
	end
end) 
