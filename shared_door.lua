doors.register("landrush:shared_door", {
	description = "Shared Door",
	inventory_image = "shared_door_inv.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles = {{name="landrush_shared_door.png", backface_culling = false}},
	protected = true,
	recipe = {
		{'default:steel_ingot','default:steel_ingot',''},
		{'default:steel_ingot','landrush:landclaim',''},
		{'default:steel_ingot','default:steel_ingot',''}
	}

})




