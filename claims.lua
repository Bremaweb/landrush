landrush.claimFile = worldpath.."/landrush-claims"
landrush.claims = {}

function landrush.load_claims()
	local file = io.open(landrush.claimFile, "r")
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
				landrush.claims[area[1]] = {owner=area[2], shared=shared, claimtype=claimtype}
			end
		end
		file:close()
	end
end

function landrush.save_claims()
	local file = io.open(landrush.claimFile, "w")
	for key,value in pairs(landrush.claims) do
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

