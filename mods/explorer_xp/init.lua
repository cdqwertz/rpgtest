explorer_xp = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local center={x=minp.x+math.abs(minp.x-maxp.x),y=minp.y+math.abs(minp.y-maxp.y),z=minp.z+math.abs(minp.z-maxp.z)}
	local nearest=nil
	for i,v in pairs(minetest.get_connected_players()) do
		local player=v:get_player_name()	
		local pos =v:getpos()
		local dist=vector.distance(center, pos)
		if nearest==nil then			
			nearest={name=v,dist=dist}
		elseif dist  < nearest.dist then  
			nearest.dist = dist
			nearest.name=v			
		end
	end
	xp.add_xp(nearest.name, 0.1)	
	return
end) 
