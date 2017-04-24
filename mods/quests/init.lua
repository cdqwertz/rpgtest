-- story quests

quests = {}
quests.player_quests = {}
quests.file = minetest.get_worldpath() .. "/quests"
quests.callback = nil
quests.hud = {}

function quests.load()
	local input = io.open(quests.file, "r")
	if input then
		local str = input:read("*all")
		if str then
			if minetest.deserialize(str) then
				quests.player_quests = minetest.deserialize(str)
			end
		else
			print("[WARNING] quest file is empty")
		end
		io.close(input)
	else
		print("[ERROR] couldnt find quest file")
	end
end

function quests.save()
	if quests.player_quests then
		local output = io.open(quests.file, "w")
		local str = minetest.serialize(quests.player_quests)
		output:write(str)
		io.close(output)
	end
end

function quests.show_text(text, player)
	local parts = text:split("\n")
	for i,txt in ipairs(parts) do
		minetest.after(2.9*(i-1), function (txt, player)
			if not(minetest.get_player_by_name(player)) then return end
			cmsg.push_message_player(minetest.get_player_by_name(player), txt)
		end, txt, player)
	end
end

function quests.add_quest(player, quest)
	if not quests.player_quests[player] then
		quests.player_quests[player] = {}
	end
	print("[quests] add quest")
	table.insert(quests.player_quests[player], quest)
	quests.save()
	
	quests.update_hud(minetest.get_player_by_name(player),player)

	if #quest.goals > 0 then
		quests.show_text(quest.text .. "\n" .. quest.goals[1].description, player)
	else
		quests.show_text(quest.text, player)
	end

	return #quests.player_quests[player]
end

function quests.has_quest(name, title)
	if not(quests.player_quests[name]) then
		return false
	end

	for i,def in ipairs(quests.player_quests[name]) do
		if def.title .. (def.id or "") == title then
			return true
		end
	end
	
	return false
end

function quests.finish_quest(player, quest)
	if not(quest.done) then
		cmsg.push_message_player(minetest.get_player_by_name(player), "[quest] You completed " .. quest.title)
	end
	xp.add_xp(minetest.get_player_by_name(player), quest.xp)
	quest.done = true
	if quests.callback then
		quests.callback(minetest.get_player_by_name(player))
	end
end

function quests.finish_goal(player, quest, goal)
	if not(goal.done) then
		for i = 1, #quest.goals do
			if quest.goals[i].requires and quest.goals[i].requires.title == goal.title then
				if quest.goals[i].description then
					quests.show_text(quest.goals[i].description, player)
				end
			end
		end

		if goal.reward then
			minetest.get_player_by_name(player):get_inventory():add_item("main", goal.reward)
			cmsg.push_message_player(minetest.get_player_by_name(player), goal.ending or "[quest] You completed a goal and you got a reward!")
		else
			cmsg.push_message_player(minetest.get_player_by_name(player), goal.ending or "[quest] You completed a goal!")
		end

		if goal.xp then
			xp.add_xp(minetest.get_player_by_name(player), goal.xp)
		end
	end

	goal.done = true
	if not quest.done then
		local all_done = true
		for i = 1, #quest.goals do
			if not quest.goals[i].done then
				all_done = false
				break
			end
		end
		if all_done then
			quests.finish_quest(player, quest)
		end
	end
	quests.save()
end

function quests.new(player, title, text)
	local quest = {
		title = title,
		done = false,
		goals = {},
		xp = 0,
		text = text or "",
	}

	return quest
end

function quests.add_dig_goal(quest, title, node, number, description, ending)
	local goal = {
		title = title,
		type = "dig",
		node = node,
		max = number,
		progress = 0,
		done = false,
		xp = 0,

		description = description or "",
		ending = ending or nil
	}
	table.insert(quest.goals, goal)
	return goal
end

function quests.add_place_goal(quest, title, node, number, description, ending)
	local goal = {
		title = title,
		type = "placenode",
		node = node,
		max = number,
		progress = 0,
		done = false,
		xp = 0,

		description = description or "",
		ending = ending or nil
	}
	table.insert(quest.goals, goal)
	return goal
end

function quests.add_craft_goal(quest, title, item, number, description, ending)
	local goal = {
		title = title,
		type = "craft",
		item = item,
		node = item,
		max = number,
		progress = 0,
		done = false,
		xp = 0,

		description = description or "",
		ending = ending or nil
	}
	table.insert(quest.goals, goal)
	return goal
end

function quests.add_talk_goal(quest, title, pos, description, ending)
	local goal = {
		title = title,
		type = "talk",
		pos = pos,
		progress = 0,
		max = 1,
		done = false,
		xp = 0,

		description = description or "",
		ending = ending or nil
	}
	table.insert(quest.goals, goal)
	return goal
end

function quests.add_give_goal(quest, title, pos, item, number, description, ending)
	local goal = {
		title = title,
		type = "give",
		pos = pos,
		item = item,
		node = item,
		max = number,
		progress = 0,
		done = false,
		xp = 0,

		description = description or "",
		ending = ending or nil
	}
	table.insert(quest.goals, goal)
	return goal
end

function quests.process_node_count_goals(player, type, node, count)
	count = count or 1
	local player_quests = quests.player_quests[player]
	if not(player_quests) or #player_quests == 0 then return end
	table.foreach(player_quests, function(_, quest)
		if not(quest.goals) or #quest.goals == 0 then return end
		table.foreach(quest.goals, function(_, goal)
			if (not goal.requires or goal.requires.done) and
					goal.type == type then
				for i=1,#goal.node do
					if goal.node[i] == node then
						goal.progress = goal.progress + count
						if goal.progress >= goal.max then
							goal.progress = goal.max

							quests.finish_goal(player, quest, goal)
							goal.done = true
						end
						quests.update_hud(minetest.get_player_by_name(player),player)
						quests.save()
					end
				end
			end
		end)
	end)
end

function quests.process_npc_goals(player, type, pos, count)
	local found = false
	count = count or 1
	local player_quests = quests.player_quests[player]
	if not(player_quests) or #player_quests == 0 then return end
	table.foreach(player_quests, function(_, quest)
		if not(quest.goals) or #quest.goals == 0 then return end
		table.foreach(quest.goals, function(_, goal)
			if (not goal.requires or goal.requires.done) and
					goal.type == type then
				print("-> talk")
				if vector.equals(pos, (goal.pos or vector.new(0, 0, 0))) then
					if goal.type == "give" then
						for i=1,#goal.node do
							if goal.node[i] == node then
								goal.progress = goal.progress + count
								if goal.progress >= goal.max then
									goal.progress = goal.max

									quests.finish_goal(player, quest, goal)
									goal.done = true
								end
								quests.update_hud(minetest.get_player_by_name(player),player)
								quests.save()
								
								found = true
							end
						end
					elseif goal.type == "talk" then
						goal.progress = goal.progress + count
						if goal.progress >= goal.max then
							goal.progress = goal.max

							quests.finish_goal(player, quest, goal)
							goal.done = true
						end
						quests.update_hud(minetest.get_player_by_name(player),player)
						quests.save()
						
						found = true
					end
				end
			end
		end)
	end)
	
	return found
end

quests.show_quests_form = "size[8,7.5;]" .. default.gui_colors ..
		default.gui_bg .. "textlist[-0.1,-0.1;8,7.75;quests;%s]"

function quests.format_goal(player, quest, goal)
	-- TODO: support formatting for more than just digging and placing
	if goal.done then
		return "#999999     \\[x\\] " .. (goal.title or "\\[NO TITLE\\]") .. " (" .. tostring(goal.progress) ..
		   	"/" .. tostring(goal.max) .. ")"
	else
		return "     \\[ \\] " .. (goal.title or "\\[NO TITLE\\]") .. " (" .. tostring(goal.progress) ..
		   "/" .. tostring(goal.max) .. ")"
	end
end

function quests.update_hud(player,name)
	if quests.hud[name] == nil then return end

	local player_quests = quests.player_quests[name]
	if not player_quests or #player_quests == 0 then
		player:hud_change(quests.hud[name], "text", "")
		return
	end

	local txt = ""
	for _, quest in pairs(player_quests) do
		if not(quest.done) and not(quest.hidden) then
			txt = txt .. " -> " .. (quest.title or "[NO TITLE]") .. "\n"
			for _, goal in pairs(quest.goals) do
				if (not goal.requires or goal.requires.done) and not(goal.done) then
					txt = txt .. "     [ ] " .. (goal.title or "[NO TITLE]") .. " (" .. tostring(goal.progress) ..
		   					"/" .. tostring(goal.max) .. ")\n"
				end
			end
		end
	end

	player:hud_change(quests.hud[name], "text", txt)
end

function quests.get_formspec(name)
	local player_quests = quests.player_quests[name]
	if not player_quests or #player_quests == 0 then
		local s = quests.show_quests_form
		s = string.format(s, "You have not got any quests yet.")
		return s
	end

	local s = quests.show_quests_form
	local txt = ""
	for _, quest in pairs(player_quests) do
		if quest.done then
			txt = txt .. "#999999 -> " .. (quest.title or "\\[NO TITLE\\]") .. " (Completed),"
		else
			txt = txt .. " -> " .. (quest.title or "\\[NO TITLE\\]") .. ","
			for _, goal in pairs(quest.goals) do
				if not goal.requires or goal.requires.done then
					txt = txt .. quests.format_goal(name, quest, goal) .. ","
				end
			end
		end
	end
	s = string.format(s, txt)
	return s
end

default.player_inventory.register_tab({
	name = "Quests",
	type = "function",
	get_formspec = function(name) 
		local formspec = quests.get_formspec(name)
		return formspec
	end
})

minetest.register_chatcommand("quests", {
	params = "",
	description = "Shows your quests",
	privs = {},
	func = function(name, text)
		minetest.show_formspec(name, "quests:show_quests", quests.get_formspec(name))
		return true, ""
	end,
})

minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger or not digger:is_player() or
			not quests.player_quests[digger:get_player_name()] then
		return
	end

	quests.process_node_count_goals(digger:get_player_name(), "dig", oldnode.name)
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if not placer or not placer:is_player() or
			not quests.player_quests[placer:get_player_name()] then
		return
	end

	quests.process_node_count_goals(placer:get_player_name(), "placenode", newnode.name)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if not player or not player:is_player() or
			not quests.player_quests[player:get_player_name()] then
		return
	end

	quests.process_node_count_goals(player:get_player_name(), "craft", itemstack:get_name(),itemstack:get_count())
end)

minetest.register_on_joinplayer(function(player)
	if not player then
		return
	end
	local name = player:get_player_name()

	quests.hud[name] = player:hud_add({
		hud_elem_type = "text",
		name = "quests",
		text = "",
		position = {x = 1, y = 0},
		alignment = {x = -1, y = 1},
		offset = {x=-10,y=10},
		number = "0xFFFFFF",
	})

	minetest.after(1, function(player,name)
		quests.update_hud(player,name)
	end, player, name)
end)

minetest.register_on_newplayer(function(player)
	if not player then
		return
	end
	quests.player_quests[player:get_player_name()] = {}
	local name = player:get_player_name()
	
	--tutorial
	do
		local quest = quests.new(name, "Tutorial", "Hey you!\nI didnt see you before. Are you new here?\nOh, Ok.\nI will help you to find the city \"NAME HERE\".\nYou will be save there.\n But first you need some basic equipment!")
		local q1 = quests.add_dig_goal(quest, "Harvest Dirt/Grass", {"default:dirt", "default:grass", "default:wet_grass"}, 10, "You need to harvest some Dirt to get stones!")
		local q2 = quests.add_dig_goal(quest, "Harvest Grass", {"default:plant_grass", "default:plant_grass_2", "default:plant_grass_3", "default:plant_grass_4", "default:plant_grass_5", "default:liana", "default:grass", "default:wet_grass"}, 12, "Now you need to get some Grass to craft strings.")
		local q3 = quests.add_dig_goal(quest, "Harvest Leaves", {"default:leaves_1", "default:leaves_2", "default:leaves_3" ,"default:leaves_4"}, 6, "Harvest some leaves to craft twigs.")
	
		local q4 = quests.add_place_goal(quest, "Place Workbench", {"default:workbench"}, 1, "You should craft a workbench and place it in front of you!", "If you want to know how to craft things,\n just open the crafting guide I gave you.\nYou can find all craftable items there!")
		local q5 = quests.add_craft_goal(quest, "Craft Stone Axe", {"default:axe_stone"}, 1, "Now you can craft a Stone Axe.")
		local q6 = quests.add_dig_goal(quest, "Harvest Logs", {"default:log","default:log_1","default:log_2","default:log_3", "default:jungle_tree"}, 20, "You can use the Stone Axe to harvest logs.")
		local q7 = quests.add_dig_goal(quest, "Mine Stone", {"default:stone"}, 20, "You can also mine Stone with your Stone Axe.")
		local q8 = quests.add_craft_goal(quest, "Craft a Flint Pick", {"default:flint_pick"}, 1, "Craft a Flint Pick!", "You can use the flint pick to dig harder blocks.")
		local q9 = quests.add_dig_goal(quest, "Mine Iron", {"default:stone_with_iron"}, 2, "Your Flint Pick is strong enough to mine Iron.", "Great! It is time to upgrade your skills now!\nGoto the skills tab in your inventory\nand level up a skill!")
		

		q3.reward = "default:wood_tutorial 3"
		q4.reward = "crafting_guide:book"

		q2.requires = q1
		q3.requires = q2
		q4.requires = q3
		q5.requires = q4
		q6.requires = q5
		q7.requires = q6
		q8.requires = q7
		q9.requires = q8

		q5.xp = 10
		q9.xp = 10
		quest.xp = 10

		quests.add_quest(name, quest)
	end

	do
		local quest = quests.new(name, "Lets mine!", "")
		local q1 = quests.add_dig_goal(quest, "Mine Stone", {"default:stone"}, 10, "")
		local q2 = quests.add_dig_goal(quest, "Mine Coal", {"default:stone_with_coal"}, 10, "")
		local q3 = quests.add_dig_goal(quest, "Mine Iron", {"default:stone_with_iron"}, 10, "")
		local q4 = quests.add_dig_goal(quest, "Mine Copper", {"default:stone_with_copper"}, 10, "")
		local q5 = quests.add_dig_goal(quest, "Mine Diamond", {"default:stone_with_diamond"}, 10, "")
	
		q1.reward = "torch:torch 10"
		q1.xp = 10
		q2.reward = "farming:apple 30"
		q2.xp = 15
		q3.reward = "default:pick"
		q3.xp = 30
		q4.reward = "torch:torch 99"
		q4.xp = 40
		q5.reward = "torch:torch 99"
		q5.xp = xp.get_xp(5, 1)

		quest.xp = 0
		quest.hidden = true
		quests.add_quest(name, quest)
	end
end)

quests.load()



-- exploring
minetest.register_node("quests:map", {
	description = "Map",
	tiles = {"quests_map_top.png", "quests_map_top.png", "quests_map.png", "quests_map.png", "quests_map.png", "quests_map.png"},
	groups = {quest = 1, cracky = 3},
	on_punch = function(pos, node, player, pointed_thing)
		xp.add_xp(player, math.random(3, 30))
		minetest.remove_node(pos)
	end,
})

minetest.register_node("quests:ray", {
	description = "Ray",
	tiles = {"quests_glowing_ray.png"},
	groups = {cracky = 1, ray=1},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	light_source = 7,
	node_box = {
		type = "fixed",
		fixed = {
				{-0.2, -0.5, -0.2, 0.2, 0.5, 0.2},
			},
	},
	drop = "",
})
