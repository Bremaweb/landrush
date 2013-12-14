minetest.log('action','Loading Land Rush Land Claim')

-- Freeminer Compatibility
if freeminer then
	minetest = freeminer
end

landrush = {}

local path = minetest.get_modpath("landrush")

dofile(path.."/config.lua")
dofile(path.."/functions.lua")
dofile(path.."/claims.lua")
dofile(path.."/protection.lua")
dofile(path.."/shared_door.lua")
dofile(path.."/chest.lua")
dofile(path.."/sign.lua")

if ( landrush.config:get_bool("enableHud") ) then
	dofile(path.."/hud.lua")
end

minetest.register_privilege("landrush", "Allows player to dig and build anywhere, and use the landrush chat commands.")

landrush.load_claims()

	minetest.register_node("landrush:landclaim", {
		description = "Land Rush Land Claim",
		tiles = {"landrush_landclaim.png"},
		groups = {oddly_breakable_by_hand=2},
		on_place = function(itemstack, placer, pointed_thing)
			owner = landrush.get_owner(pointed_thing.above)
			player = placer:get_player_name()
			
			if ( pointed_thing.above.y < -200 ) then
				minetest.chat_send_player(player,"You cannot claim below -200")
				return itemstack
			end
			
			if owner then
				minetest.chat_send_player(player, "This area is already owned by "..owner)
			else
				minetest.env:remove_node(pointed_thing.above)
				chunk = landrush.get_chunk(pointed_thing.above)
				landrush.claims[chunk] = {owner=placer:get_player_name(),shared={},claimtype="landclaim"}
				landrush.save_claims()
				minetest.chat_send_player(landrush.claims[chunk].owner, "You now own this area.")
				itemstack:take_item()
				return itemstack
			end
		end,
	})

minetest.register_craft({
			output = 'landrush:landclaim',
			recipe = {
				{'default:stone','default:steel_ingot','default:stone'},
				{'default:steel_ingot','default:mese_crystal','default:steel_ingot'},
				{'default:stone','default:steel_ingot','default:stone'}
			}
		})
minetest.register_alias("landclaim", "landrush:landclaim")
minetest.register_alias("landrush:landclaim_b","landrush:landclaim")


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
		textures = {nil, nil, "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
	}
})

if ( minetest.get_modpath("money2") ) then
	minetest.log('action','Loading Landrush Land Sale')
	dofile(path.."/landsale.lua")
end

minetest.after(0, function ()

dofile(path.."/default.lua")
--dofile(path.."/bucket.lua")
dofile(path.."/doors.lua")
dofile(path.."/fire.lua")
dofile(path.."/chatcommands.lua")
--dofile(path.."/screwdriver.lua")
dofile(path.."/snow.lua")

end )
