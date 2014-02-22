-- copied config section from technic
worldpath = minetest.get_worldpath()

landrush.config = Settings(worldpath.."/landrush.conf")

local conf_table = landrush.config:to_table()

local defaults = {
	requireClaim = "false",
	onlineProtection = "true",
	offenseDamage = "4",
	autoBan = "false",
	banLevel = "40",
	banWarning = "25",
	offenseReset = "1440",
	adminUser = nil,
	chunkSize = "16",
	enableHud = "true",
	noBanTime = 240,
	noDamageTime = 600
}

for k, v in pairs(defaults) do
	if conf_table[k] == nil then
		landrush.config:set(k, v)
	end
end

-- Create the config file if it doesn't exist
landrush.config:write() 

-- These are items that can be dug in unclaimed areas when landrush.config:get_bool("requireClaim") is true
landrush.global_dig_list = {["default:ladder"]=true,["default:leaves"]=true,["default:tree"]=true,["default:grass"]=true,["default:grass_1"]=true,["default:grass_2"]=true,["default:grass_3"]=true,["default:grass_4"]=true}

if minetest.get_modpath("whoison") then
	landrush.whoison=true
else
	landrush.whoison=false
end
