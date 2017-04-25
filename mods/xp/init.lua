xp = {}
xp.lvl = 20
xp.xp_hud = {}
xp.level_hud = {}
xp.custom_level_system = false

function xp.set_level_hud_text(player, str)
	player:hud_change(xp.level_hud[player:get_player_name()], "text", str)
end

function xp.getXp(player)
	return tonumber(player:get_attribute('xp'))
end

function xp.getLvl(player)
	return tonumber(player:get_attribute('lvl'))
end

function xp.get_xp(lvl, x)
	return (xp.lvl * lvl) / x
end

function xp.add_xp(player, num)
	player:set_attribute('xp',xp.getXp(player) + num)
	cmsg.push_message_player(player, "[xp] +"..tostring(num))
	if xp.getXp(player) > xp.lvl * xp.getLvl(player) then
		player:set_attribute('xp', xp.getXp(player) - (xp.lvl * xp.getLvl(player)))
		xp.add_lvl(player)
	end
	print("[info] xp for player ".. player:get_player_name() .. " " .. xp.getXp(player).."/".. xp.lvl * xp.getLvl(player).." = " .. xp.getXp(player) / ( xp.lvl * xp.getLvl(player)))
	player:hud_change(xp.xp_hud[player:get_player_name()], "number", 20 * ((xp.getXp(player)) / (xp.lvl * xp.getLvl(player))))
end

function xp.add_lvl(player)
	player:set_attribute('lvl',xp.getLvl(player) + 1)
	if not(xp.custom_level_system) then
		player:hud_change(xp.level_hud[player:get_player_name()], "text", xp.getLvl(player))
	end
	cmsg.push_message_player(player, "Level up! You are now Level " .. tostring(xp.getLvl(player)))
end

function xp.JoinPlayer()
	minetest.register_on_joinplayer(function(player)
		if not player then
			return
		end
		if xp.getXp(player) and xp.getLvl(player) then
			xp.xp_hud[player:get_player_name()] = player:hud_add({
				hud_elem_type = "statbar",
				position = {x=0.5,y=1.0},
				size = {x=16, y=16},
				offset = {x=-(32*8+16), y=-(48*2+16)},
				text = "xp_xp.png",
				number = 20*((xp.getXp(player))/(xp.lvl * xp.getLvl(player))),
			})
			xp.level_hud[player:get_player_name()] = player:hud_add({
				hud_elem_type = "text",
				position = {x=0.5,y=1},
				text = xp.getLvl(player),
				number = 0xFFFFFF,
				alignment = {x=0.5,y=1},
				offset = {x=0, y=-(48*2+16)},
			})
		else
			print(tostring('something, somewhere is going wrong'))
		end
	end)
end

function xp.NewPlayer()
	minetest.register_on_newplayer(function(ObjectRef)
		ObjectRef:set_attribute('xp', 0)
		ObjectRef:set_attribute('lvl', 1)
	end)
end

function xp.explorer_xp()
	minetest.register_on_generated(function(minp, maxp, blockseed)
		local center={x=minp.x+math.abs(minp.x-maxp.x),y=minp.y+math.abs(minp.y-maxp.y),z=minp.z+math.abs(minp.z-maxp.z)}
		local player=nil
		local top = nil
		for i,v in pairs(minetest.get_connected_players()) do
			local pos =v:getpos()
			local dist=vector.distance(center, pos)
			if player==nil then
				player = v
				top = dist
				
			elseif dist  < top then  
				top = dist
				player = v			
			end
		end
		xp.add_xp(player, 0.1)	
	end) 
end

function xp.crafter_xp()
	minetest.register_on_craft(function(itemstack, player)
		local craft_xp = itemstack:get_definition().craft_xp
		if craft_xp then
			xp.add_xp(player, craft_xp)
		end
	end)
end

function xp.miner_xp()
	minetest.register_on_dignode(function(pos, oldnode, digger)
		local miner_xp = minetest.registered_nodes[oldnode.name].miner_xp
		local player = digger:get_player_name()
		local player_lvls = skills.lvls[player]
		if not miner_xp then
		elseif miner_xp.rm then
			if player_lvls then
				xp.add_xp(digger, (player_lvls["miner"]-1))
			end
		elseif miner_xp.lvls then
			if player_lvls and player_lvls["miner"] > 5 then
				xp.add_xp(digger,xp.getLvl(digger), 14)
			end
		elseif miner_xp.rnd then
			if math.random(miner_xp.rnd) == miner_xp.rnd then
				xp.add_xp(digger, miner_xp.xp)	
			end
		elseif miner_xp.xp then 
			xp.add_xp(digger, miner_xp.xp)
		end
	end)
end

function xp.builder_xp()
	minetest.register_on_placenode(function(pos, newnode, placer)
		local builder_xp = minetest.registered_nodes[newnode.name].builder_xp
		if builder_xp then
			xp.add_xp(placer, builder_xp)
		end
	end)
end

xp.NewPlayer()
xp.JoinPlayer()

xp.miner_xp()
xp.crafter_xp()
xp.explorer_xp()
xp.builder_xp()
