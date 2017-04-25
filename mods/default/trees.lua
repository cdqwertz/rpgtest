-- wood (tutorial)

minetest.register_node("default:wood_tutorial", {
	description = "Wood",
	tiles = {"default_wood.png"},
	groups = {choppy = 3, oddly_breakable_by_hand=1, wood=1},
	sounds = default.sounds.wood(),
})

-- wood

minetest.register_node("default:wood", {
	description = "Wood",
	tiles = {"default_wood.png"},
	groups = {choppy = 3, wood=1},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:wooden_planks", {
	description = "Wooden Planks",
	tiles = {"default_wooden_planks.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:wooden_planks_2", {
	description = "Wooden Planks",
	tiles = {"default_wooden_planks_2.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:jungle_wood", {
	description = "Jungle Wood",
	tiles = {"default_jungle_wood.png"},
	groups = {choppy = 3, wood=1},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:wooden_planks_jungle", {
	description = "Wooden Planks (Jungle Wood)",
	tiles = {"default_wooden_planks_jungle.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:wooden_planks_2_jungle", {
	description = "Wooden Planks (Jungle Wood)",
	tiles = {"default_wooden_planks_2_jungle.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:birch_wood", {
	description = "Birch Wood",
	tiles = {"default_wood_birch.png"},
	groups = {choppy = 3, wood=1},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:wooden_planks_birch", {
	description = "Wooden Planks (Birch Wood)",
	tiles = {"default_wooden_planks_birch.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
})

minetest.register_node("default:wooden_planks_2_birch", {
	description = "Wooden Planks (Birch Wood)",
	tiles = {"default_wooden_planks_2_birch.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
})

-- log

minetest.register_node("default:log", {
	description = "Log",
	tiles = {"default_log_top.png","default_log_top.png","default_log.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_and_place,
})

minetest.register_node("default:log_1", {
	description = "Log (thick)",
	tiles = {"default_log_top.png","default_log_top.png","default_log.png"},
	groups = {choppy = 3},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-6/16, -0.5, -6/16, 6/16, 0.5, 6/16},
			},
	},
	sounds = default.sounds.wood(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_and_place,
})

minetest.register_node("default:log_2", {
	description = "Log",
	tiles = {"default_log_top.png","default_log_top.png","default_log.png"},
	groups = {choppy = 3},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-4/16, -0.5, -4/16, 4/16, 0.5, 4/16},
			},
	},
	sounds = default.sounds.wood(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_and_place,
})

minetest.register_node("default:log_3", {
	description = "Log (thin)",
	tiles = {"default_log_top.png","default_log_top.png","default_log.png"},
	groups = {choppy = 3},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-2/16, -0.5, -2/16, 2/16, 0.5, 2/16},
			},
	},
	sounds = default.sounds.wood(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_and_place,
})

minetest.register_node("default:jungle_tree", {
	description = "Jungle Tree",
	tiles = {"default_jungle_tree_top.png", "default_jungle_tree_top.png", "default_jungle_tree.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_and_place,
})

minetest.register_node("default:log_birch", {
	description = "Birch Log",
	tiles = {"default_log_birch_top.png","default_log_birch_top.png","default_log_birch.png"},
	groups = {choppy = 3},
	sounds = default.sounds.wood(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_and_place,
})

-- saplings

minetest.register_node("default:sapling", {
	description = "Sapling",
	tiles = {"default_sapling.png"},
	drawtype = "plantlike",
	paramtype = "light",
	inventory_image = "default_sapling.png",
	buildable_to = true,
	walkable = false,
	groups = {crumbly = 3, sapling = 1},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
	},
})

minetest.register_abm({
	nodenames = {"default:sapling"},
	neighbors = {"default:grass", "default:dirt"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.set_node(pos, {name = "air"})
		if math.random(2) == 1 then
			local path = minetest.get_modpath("default") .. "/schematics/tree2.mts"
			minetest.place_schematic({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, path, 0, nil, false)
		elseif math.random(2) == 1 then
			local path = minetest.get_modpath("default") .. "/schematics/tree1.mts"
			minetest.place_schematic({x = pos.x - 2, y = pos.y - 1, z = pos.z - 2}, path, 0, nil, false)
		else
			local path = minetest.get_modpath("default") .. "/schematics/tree3.mts"
			minetest.place_schematic({x = pos.x - 2, y = pos.y - 1, z = pos.z - 2}, path, 0, nil, false)
		end
	end,
})

minetest.register_node("default:sapling_2", {
	description = "Sapling",
	tiles = {"default_sapling_2.png"},
	drawtype = "plantlike",
	paramtype = "light",
	inventory_image = "default_sapling_2.png",
	buildable_to = true,
	walkable = false,
	groups = {crumbly = 3, sapling = 1},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
	},
})

minetest.register_abm({
	nodenames = {"default:sapling_2"},
	neighbors = {"default:grass", "default:dirt"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.set_node(pos, {name = "air"})
		local path = minetest.get_modpath("default") .. "/schematics/pinetree1.mts"
		minetest.place_schematic({x = pos.x - 2, y = pos.y - 0, z = pos.z - 2}, path, 0, nil, false)
	end,
})


-- mapgen

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:grass"},
	sidelen = 16,
	fill_ratio = 0.01,
	biomes = {"forest"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/tree1.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:grass"},
	sidelen = 16,
	fill_ratio = 0.004,
	biomes = {"forest"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/tree2.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:grass"},
	sidelen = 16,
	fill_ratio = 0.01,
	biomes = {"forest"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/tree3.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:grass"},
	sidelen = 16,
	fill_ratio = 0.005,
	biomes = {"forest"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/birchtree1.mts",
	flags = "place_center_x, place_center_z",
})


minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_snow"},
	sidelen = 16,
	noise_params = {
		offset = 0.04,
		scale = 0.01,
		spread = {x = 250, y = 250, z = 250},
		seed = 21,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"tundra"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/pinetree1.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dry_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0.04,
		scale = 0.01,
		spread = {x = 250, y = 250, z = 250},
		seed = 21,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"savanna"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("default").."/schematics/drytree2.mts",
	flags = "place_center_x, place_center_z",
})
