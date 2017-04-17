xp = {}
xp.lvl = 20
xp.player_xp = {}
xp.player_levels = {}
xp.xp_hud = {}
xp.level_hud = {}

xp.xp_file = minetest.get_worldpath() .. "/xp"
xp.lvl_file = minetest.get_worldpath() .. "/levels"

xp.custom_level_system = false

function xp.set_level_hud_text(player, str)
	player:hud_change(xp.level_hud[player:get_player_name()], "text", str)
end

function xp.get_xp(lvl, x)
	return (xp.lvl * lvl) / x
end

function xp.add_xp(player, num)
	if xp.player_xp[player:get_player_name()] then
		xp.player_xp[player:get_player_name()] = xp.player_xp[player:get_player_name()] + num
	else
		xp.player_xp[player:get_player_name()] = num
		if not xp.player_levels[player:get_player_name()] then
			xp.player_levels[player:get_player_name()] = 1
		end
	end

	if num > 0 then
		cmsg.push_message_player(player, "[xp] +"..tostring(num))
	end

	if xp.player_levels[player:get_player_name()] then
		if xp.player_xp[player:get_player_name()] > xp.lvl*xp.player_levels[player:get_player_name()] then
			xp.player_xp[player:get_player_name()] = xp.player_xp[player:get_player_name()] - xp.lvl*xp.player_levels[player:get_player_name()]
			xp.add_lvl(player)
		end
	else
		xp.player_levels[player:get_player_name()] = 1
	end
	print("[info] xp for player ".. player:get_player_name() .. " " .. xp.player_xp[player:get_player_name()].."/"..xp.lvl*xp.player_levels[player:get_player_name()].." = " .. (xp.player_xp[player:get_player_name()])/(xp.lvl*xp.player_levels[player:get_player_name()]))
	player:hud_change(xp.xp_hud[player:get_player_name()], "number", 20*((xp.player_xp[player:get_player_name()])/(xp.lvl*xp.player_levels[player:get_player_name()])))
	xp.save_xp()
	xp.save_levels()
end

function xp.add_lvl(player)
	if xp.player_levels[player:get_player_name()] then
		xp.player_levels[player:get_player_name()] = xp.player_levels[player:get_player_name()] + 1
	else
		xp.player_levels[player:get_player_name()] = 1
	end
	xp.save_levels()
	if not(xp.custom_level_system) then
		player:hud_change(xp.level_hud[player:get_player_name()], "text", xp.player_levels[player:get_player_name()])
	end
	cmsg.push_message_player(player, "Level up! You are now Level " .. tostring(xp.player_levels[player:get_player_name()]))
end

minetest.register_on_joinplayer(function(player)
	if not player then
		return
	end
	if xp.player_xp[player:get_player_name()] and xp.player_levels[player:get_player_name()] then
		xp.xp_hud[player:get_player_name()] = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=0.5,y=1.0},
			size = {x=16, y=16},
		   	offset = {x=-(32*8+16), y=-(48*2+16)},
			text = "xp_xp.png",
			number = 20*((xp.player_xp[player:get_player_name()])/(xp.lvl*xp.player_levels[player:get_player_name()])),
		})
		xp.level_hud[player:get_player_name()] = player:hud_add({
			hud_elem_type = "text",
			position = {x=0.5,y=1},
			text = xp.player_levels[player:get_player_name()],
			number = 0xFFFFFF,
			alignment = {x=0.5,y=1},
			offset = {x=0, y=-(48*2+16)},
		})
	else
		xp.player_xp[player:get_player_name()] = 0
		xp.player_levels[player:get_player_name()] = 1
		xp.xp_hud[player:get_player_name()] = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=0.5,y=1.0},
			size = {x=16, y=16},
		   	offset = {x=-(32*8+16), y=-(48*2+16)},
			text = "xp_xp.png",
			number = 0,
		})
		xp.level_hud[player:get_player_name()] = player:hud_add({
			hud_elem_type = "text",
			position = {x=0.5,y=1},
			text = "1",
			number = 0xFFFFFF,
			alignment = {x=0.5,y=1},
			offset = {x=0, y=-(48*2+16)},
		})
	end
end)

function xp.load_xp()
	local input = io.open(xp.xp_file, "r")
	if input then
		local str = input:read()
		if str then
			for k, v in str.gmatch(str,"(%w+)=(%w+)") do
    			xp.player_xp[k] = tonumber(v)
			end
		end
		io.close(input)
	end
end

function xp.save_xp()
	if xp.player_xp then
		local output = io.open(xp.xp_file, "w")
		local str = ""
		for k, v in pairs(xp.player_xp) do
			str = str .. k .. "=" .. v .. ","
		end
		str = str:sub(1, #str - 1)
		output:write(str)
		io.close(output)
	end
end

function xp.load_levels()
	local input = io.open(xp.lvl_file, "r")
	if input then
		local str = input:read()
		if str then
			for k, v in str.gmatch(str,"(%w+)=(%w+)") do
    				xp.player_levels[k] = tonumber(v)
			end
		end
		io.close(input)
	end
end

function xp.save_levels()
	if xp.player_xp then
		local output = io.open(xp.lvl_file, "w")
		local str = ""
		for k, v in pairs(xp.player_levels) do
			str = str .. k .. "=" .. v .. ","
		end
		str = str:sub(1, #str - 1)
		output:write(str)
		io.close(output)
	end
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

xp.crafter_xp()
xp.explorer_xp()
xp.load_xp()
xp.load_levels()
