function landrush.get_chunk(pos)
	local x = math.floor(pos.x/landrush.config:get("chunkSize"))
	-- 3 levels of vertical protection
	local y = 0

	if ( pos.y < -200 ) then
		y = - 32000
	elseif ( pos.y < -60 ) then
		y = -200
	elseif ( pos.y < 140 ) then
		y = -30
	else
		y = 90
	end


	local z = math.floor(pos.z/landrush.config:get("chunkSize"))
	return x..","..y..","..z
end

function landrush.get_chunk_center(pos)
	local x = math.floor(pos.x/landrush.config:get("chunkSize"))*landrush.config:get("chunkSize")+7.5
	local y = 0

	if ( pos.y < -200 ) then
		y = - 32000
	elseif ( pos.y < -60 ) then
		y = -200
	elseif ( pos.y < 120 ) then
		y = -30
	else
		y = 120
	end

	local z = math.floor(pos.z/landrush.config:get("chunkSize"))*landrush.config:get("chunkSize")+7.5
	return {x=x,y=y,z=z}
end

function landrush.get_owner(pos)
	local chunk = landrush.get_chunk(pos)
	if landrush.claims[chunk] then
		return landrush.claims[chunk].owner
	end
end
 
function landrush.get_distance(pos1,pos2)
	if ( pos1 ~= nil and pos2 ~= nil ) then
		return math.abs(math.floor(math.sqrt( (pos1.x - pos2.x)^2 + (pos1.z - pos2.z)^2 )))
	else
		return 0
	end
end

function landrush.get_timeonline(name)
	-- a wrapper for whoison.getTimeOnline since whoison is an optional dependancy
	if ( landrush.whoison == true ) then
		return (whoison.getTimeOnline(name) / 60)
	else
		return -1
	end
end
