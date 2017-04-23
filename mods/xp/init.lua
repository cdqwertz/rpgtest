xp = {}
xp.lvl = 20
xp.xp_hud = {}
xp.level_hud = {}
xp.custom_level_system = false

function xp.set_level_hud_text(player, str)
	player:hud_change(xp.level_hud[player:get_player_name()], "text", str)
end

local function getXp(player)
	return tonumber(player:get_attribute('xp'))
end

local function getLvl(player)
	return tonumber(player:get_attribute('lvl'))
end

function xp.get_xp(lvl, x)
	return (xp.lvl * lvl) / x
end

function xp.add_xp(player, num)
	player:set_attribute('xp',getXp(player) + num)
	cmsg.push_message_player(player, "[xp] +"..tostring(num))
	if getXp(player) > xp.lvl * getLvl(player) then
		player:set_attribute('xp', getXp(player) - (xp.lvl * getLvl(player)))
		xp.add_lvl(player)
	end
	print("[info] xp for player ".. player:get_player_name() .. " " .. getXp(player).."/".. xp.lvl * getLvl(player).." = " .. getXp(player) / ( xp.lvl * getLvl(player)))
	player:hud_change(xp.xp_hud[player:get_player_name()], "number", 20 * ((getXp(player)) / (xp.lvl * getLvl(player))))
end

function xp.add_lvl(player)
	player:set_attribute('lvl',getLvl(player) + 1)
	if not(xp.custom_level_system) then
		player:hud_change(xp.level_hud[player:get_player_name()], "text", getLvl(player))
	end
	cmsg.push_message_player(player, "Level up! You are now Level " .. tostring(getLvl(player)))
end

function xp.JoinPlayer()
	minetest.register_on_joinplayer(function(player)
		if not player then
			return
		end
		if getXp(player) and getLvl(player) then
			xp.xp_hud[player:get_player_name()] = player:hud_add({
				hud_elem_type = "statbar",
				position = {x=0.5,y=1.0},
				size = {x=16, y=16},
				offset = {x=-(32*8+16), y=-(48*2+16)},
				text = "xp_xp.png",
				number = 20*((getXp(player))/(xp.lvl * getLvl(player))),
			})
			xp.level_hud[player:get_player_name()] = player:hud_add({
				hud_elem_type = "text",
				position = {x=0.5,y=1},
				text = getLvl(player),
				number = 0xFFFFFF,
				alignment = {x=0.5,y=1},
				offset = {x=0, y=-(48*2+16)},
			})
		else
			print(tostring('something, somewhere is going wrong')
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
		local nearest=nil
		for i,v in pairs(minetest.get_connected_players()) do
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
				xp.add_xp(digger,xp.get_xp(xp.player_levels[player], 14))
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
