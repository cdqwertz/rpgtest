skills = {}
skills.all_skills = {}
skills.selected = {}
skills.lvls = {}
skills.skills_file = minetest.get_worldpath() .. "/skills"

minetest.register_on_newplayer(function(player)
	skills.lvls[player:get_player_name()] = {}
	for s,a in pairs(skills.all_skills) do
		if s == "miner" then
			skills.lvls[player:get_player_name()][s] = 2
		else
			skills.lvls[player:get_player_name()][s] = 1
		end
	end
	skills.save_skills()
end)

function skills.get_dmg(lvl)
	return lvl+2
end

function skills.get_text(name)
	local str = ""
	for s,l in pairs(skills.lvls[name]) do
		str = str .. s .. " : " .. l .. "  "
	end
	return str
end

function skills.level_up(name, text)
	if not(skills.lvls[name][text]) then
		return false
	end

	local count = 0
	for s,l in pairs(skills.lvls[name]) do
		count = count + (l-1)
	end
	local playerObj = minetest.get_player_by_name(name)
	if tonumber(playerObj:get_attribute('lvl')) > count then
		skills.lvls[name][text] = skills.lvls[name][text] + 1
		skills.save_skills()
		cmsg.push_message_player(minetest.get_player_by_name(name), "[skills] " .. skills.get_text(name))
		return true
	else
		return false
	end
end

function skills.register_weapon(name, fromLevel, levels, def)
	if not def.damage then
		if def.damage_m and def.damage_d then
			def.damage = math.floor(skills.get_dmg(fromLevel)*def.damage_m-def.damage_d)
		end
	end

	for i = fromLevel, levels, 1 do
		minetest.register_tool("skills:"..name .. "_lvl_" .. tostring(i), {
			description = def.description.."\n Level: ".. tostring(i).. "\n Damage: " .. tostring(def.damage+ i-fromLevel) .." \n Skill: " .. def.skill,
			inventory_image = def.inventory_image,
			wield_scale = def.wield_scale,
			tool_capabilities = {
				max_drop_level=3,
				damage_groups = {fleshy=def.damage+ i-fromLevel},
			},
			skill = def.skill,
    			on_use = function(itemstack, user, pointed_thing)
				if user == nil then return end
				if pointed_thing.type == "object" then
					if skills.lvls[user:get_player_name()] and skills.lvls[user:get_player_name()][def.skill] > i-1 then
						pointed_thing.ref:punch(user, 10,minetest.registered_tools[itemstack:get_name()].tool_capabilities)
						itemstack:add_wear(300)
						print("[info]" .. user:get_player_name() .. " is fighting!")
					else
						cmsg.push_message_player(user, "[info] You have to be " .. def.skill .. " level "..tostring(i).. " to use this weapon!")
					end
					return itemstack
				end
			end
		})

		minetest.register_craft({
			output = "skills:"..name .. "_lvl_" .. tostring(i),
			recipe = {"skills:"..name .. "_lvl_" .. tostring(i), "skills:"..name .. "_lvl_" ..tostring(i)},
			type = "toolrepair",
		})

		if i < levels then
			minetest.register_craft({
				output = "skills:"..name .. "_lvl_" .. tostring(i+1),
				recipe = {
					{"skills:"..name .. "_lvl_" .. tostring(i), "potions:upgrading"},
				}
			})
		end
	end

	if def.recipe then
		minetest.register_craft({
			output = "skills:"..name .. "_lvl_" .. tostring(fromLevel),
			recipe = def.recipe,
		})
	end
end

function skills.register_tool(name, fromLevel, levels, def)
	for i = fromLevel, levels, 1 do
		local damage_string = ""
		if def.get_damage then
			damage_string = "\n Damage: " .. tostring(def.get_damage(i))
		end
		minetest.register_craftitem("skills:" .. name .. "_lvl_" .. tostring(i), {
			description = def.description .. "\n Level: "..tostring(i) .. damage_string .. "\n Skill: " .. def.skill .. "\n Range: " .. tostring(def.range or 4),
			inventory_image = def.inventory_image,
			wield_image = def.wield_image or def.inventory_image,
			skill = def.skill,
			range = def.range or 4,
			wield_scale = def.wield_scale,
			on_use = function(itemstack, user, pointed_thing)
				if user == nil then return end
				if skills.lvls[user:get_player_name()] and skills.lvls[user:get_player_name()][def.skill] > i-1 then
					def.on_use(itemstack, user, pointed_thing, i)
				else
					cmsg.push_message_player(user, "[info] You have to be " .. def.skill .. " level "..tostring(i).. " to use this tool!")
				end
				return nil
			end
		})

		if i < levels then
			minetest.register_craft({
				output = "skills:"..name .. "_lvl_" .. tostring(i+1),
				recipe = {
					{"skills:"..name .. "_lvl_" .. tostring(i), "potions:upgrading"},
				}
			})
		end
	end

	if def.recipe then
		minetest.register_craft({
			output = "skills:"..name .. "_lvl_" .. tostring(fromLevel),
			recipe = def.recipe,
		})
	end
end

-- load save

function skills.load_skills()
	local input = io.open(skills.skills_file, "r")
	if input then
		local str = input:read()
		if minetest.deserialize(str) then
			skills.lvls = minetest.deserialize(str)
		end
		io.close(input)
	end
end

function skills.save_skills()
	if skills.lvls then
		local output = io.open(skills.skills_file, "w")
		local str = minetest.serialize(skills.lvls)
		output:write(str)
		io.close(output)
	end
end

default.player_inventory.register_tab({
	name = "Skills",
	type = "function",
	get_formspec = function(name) 
		local count = 0
		for s,l in pairs(skills.lvls[name]) do
			count = count + (l-1)
		end
	
		local formspec = "size[8,7.5;]" ..
			default.gui_colors .. 
			default.gui_bg ..
			"label[0,0;Skills:]" ..
			"label[7,0;" .. tostring(minetest.get_player_by_name(name):get_attribute('lvl') - count) .. "]"


		local i = 0
		for skill_name, skill_level in pairs(skills.lvls[name]) do
			formspec = formspec .. "button[0,"..tostring(i+0.5)..";2,1;" .. skill_name .. ";" .. skill_name .. " : " .. tostring(skill_level) .. "]"
			
			if skills.all_skills[skill_name] then
				formspec = formspec .. "label[2.5,"..tostring(i+0.75)..";" .. skills.all_skills[skill_name].description .. "]"
			end
			i = i +1
		end
	
		return formspec
	end,
	on_event = function(player, fields)
		local name = player:get_player_name()
		for n,v in pairs(fields) do
			if v then
				skills.level_up(name, n)
			end
		end
	end
})

-- cmd

minetest.register_chatcommand("skill", {
	params = "<skill>",
	description = "Level up <skill>",
	privs = {},
	func = function(name, text)
		if text == "show" then
			cmsg.push_message_player(minetest.get_player_by_name(name), "[skills] " .. skills.get_text(name))
			return true,"Done"
		end
		if not(skills.lvls[name]) then
			return false, "[ERROR] Please contact an admin."
		end
		if skills.lvls[name][text] then
			local count = 0
			for s,l in pairs(skills.lvls[name]) do
				count = count + (l-1)
			end
			print(count)
			local playerObj = minetest.get_player_by_name(name)
			print(playerObj:get_attribute('lvl'))
			if playerObj:get_attribute('lvl') > count then
				skills.lvls[name][text] = skills.lvls[name][text] + 1
				skills.save_skills()
				cmsg.push_message_player(playerObj, "[skills] " .. skills.get_text(name))
				return true, "You leveled up " ..text
			else
				return true, "You cant level up "..text .. " at the moment."
			end
		else
			return true, "You cant level up "..text
		end
	end,
})

minetest.register_chatcommand("reset_skills", {
	params = "<player>",
	description = "Resets <player>'s skills",
	privs = {server=true},
	func = function(name, param)
		if minetest.get_player_by_name(param) then
			skills.lvls[param] = {}
			for s,a in pairs(skills.all_skills) do
				skills.lvls[param][s] = 1
			end
			skills.save_skills()
		else
			return false,"Player " .. param .. "doesnt exist."
		end
	end,
})

skills.register_skill = function(name, def)
	skills.all_skills[name] = def or {description = ""}
end


skills.register_skill("farmer", {
	description = "You will get more xp for farming."
})

skills.register_skill("warrior", {
	description = "You will be able to use better weapons."
})

skills.register_skill("miner", {
	description = "You will get more xp for mining."
})

skills.register_skill("hunter", {
	description = "You will be able to use better weapons."
})

skills.register_skill("builder", {
	description = "-"
})

skills.load_skills()

skills.register_weapon("spear",1, 12, {
	description = "Spear",
	inventory_image = "skills_spear.png",
	wield_scale = {x = 2, y=2, z = 1},
	damage_m = 1.0,
	damage_d = -1,
	skill = "warrior",
	recipe = {
		{"", "default:flint", ""},
		{"", "default:string_strong", ""},
		{"", "default:stick", ""},
	}
})

skills.register_weapon("chemical_spear",5, 17, {
	description = "Chemical Spear",
	inventory_image = "skills_chemical_spear.png",
	wield_scale = {x = 2, y=2, z = 1},
	damage_m = 1.1,
	damage_d = -2,
	skill = "warrior"
})

skills.register_tool("shield", 5, 5, {
	description = "Shield",
	inventory_image = "skills_shield.png",
	wield_scale = {x = 2, y=2, z = 1},
	skill = "warrior",
	on_use = function(itemstack, user, pointed_thing, level)
		user:set_armor_groups({friendly = 30})
		user:set_physics_override({
			speed = 0.3,
		})
		cmsg.push_message_player(user, "[armor] + shield")

		minetest.after(3.0, function(player)
			if not player or not player:is_player() then
				return
			end
			armor.update_armor(player:get_player_name(), player)
			player:set_physics_override({
				speed = 1,
			})
			cmsg.push_message_player(player, "[armor] - shield")
		end, user)
	end
})

skills.register_weapon("sword", 10, 20, {
	description = "Sword",
	inventory_image = "skills_sword.png",
	wield_scale = {x = 1.5, y=1.5, z = 1},
	damage_m = 1.0,
	damage_d = -1,
	skill = "warrior",
	recipe = {
		{"", "default:blade", ""},
		{"", "default:string_strong", ""},
		{"", "furnace:iron_rod", ""},
	}
})

skills.register_weapon("sword_copper", 17, 30, {
	description = "Copper Sword",
	inventory_image = "skills_sword_copper.png",
	wield_scale = {x = 1.5, y=1.5, z = 1},
	damage_m = 1.0,
	damage_d = -1,
	skill = "warrior",
	recipe = {
		{"", "default:blade", ""},
		{"", "default:string_strong", ""},
		{"", "furnace:copper_rod", ""},
	}
})

skills.register_tool("bow", 1, 30, {
	description = "Wooden Bow",
	inventory_image = "skills_bow.png",
	wield_image = "skills_bow_wield.png",
	wield_scale = {x = 2.5, y=2.5, z = 1},
	skill = "hunter",
	range = 20,
	on_use = function(itemstack, user, pointed_thing, level)
		local p = user:getpos()
		p.y = p.y + 1.5
		local dir = user:get_look_dir()
		minetest.add_particle({
			pos = p,
			velocity = vector.multiply(dir, 50),
			acceleration = {x=0, y=0, z=0},
			expirationtime = 7,
			size = 1,
			collisiondetection = false,
			vertical = false,
			texture = "default_wood.png"
		})
		if pointed_thing.type == "object" then
			local pt = pointed_thing.ref
			if not pt or not pt:getpos() or not user then
				return
			end
			pt:punch(user, 1.0, {
				full_punch_interval=1.0,
				damage_groups={fleshy=skills.get_dmg(level)-1},
			})
		end
	end,

	get_damage = function(level)
		return skills.get_dmg(level)-1
	end,

	recipe = {
		{"", "default:string_strong", "default:stick"},
		{"default:string_strong", "", "default:stick"},
		{"", "default:string_strong", "default:stick"},
	}
})


local modpath = minetest.get_modpath("skills")

dofile(modpath.."/abilities.lua")
