farming = {}

function farming.register_plant(name, steps, def)
	for i = 1, steps, 1 do
		minetest.register_node(":farming:"..name.."_"..tostring(i), {
			description = def.description .. " " .. tostring(i),
			tiles = {def.texture.."_"..tostring(i)..".png"},
			drawtype = "plantlike",
			paramtype = "light",
			inventory_image = def.texture.."_"..tostring(i)..".png",
			drop = def.drop .. " " .. tostring(i),
			groups = {crumbly=3},
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
			},

			on_dig = function(pos, node, player)
				if skills.lvls[player:get_player_name()] and skills.lvls[player:get_player_name()]["farmer"] and skills.lvls[player:get_player_name()]["farmer"] > 4 then
					xp.add_xp(player,xp.get_xp(player:get_attribute('lvl'), 100)*(i-1))
				end
				minetest.node_dig(pos, node, player)
			end,
		})
		minetest.register_abm({
			nodenames = {"farming:"..name.."_"..tostring(i)},
			neighbors = {"default:dirt", "default:grass"},
			interval = 40.0,
			chance = 10,
			action = function(pos, node, active_object_count, active_object_count_wider)
				if i < steps then
					minetest.set_node(pos, {name = "farming:"..name.."_"..tostring(i+1)})
				end
			end,
		})
	end
	
	minetest.register_craftitem(def.drop, {
		description = def.drop_description,
		inventory_image = def.drop_texture,
		on_place = function(itemstack, placer, pointed_thing) 
			if pointed_thing.above then
				if minetest.get_node(pointed_thing.above).name == "air" then
					minetest.set_node(pointed_thing.above, {name="farming:"..name.."_1"})
					itemstack:take_item()
				end
			end
			return itemstack
		end,
	})
end

farming.register_plant("wheat", 5, {
	description = "Wheat",
	texture = "farming_wheat",
	
	drop = "farming:wheat_seeds",
	drop_description = "Wheat Seeds",
	drop_texture = "farming_wheat_seeds.png",
})

farming.register_plant("carrot", 3, {
	description = "Carrot",
	texture = "farming_carrot",
	
	drop = "farming:carrot",
	drop_description = "Carrot",
	drop_texture = "farming_carrot.png",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:grass"},
	sidelen = 16,
	fill_ratio = 0.005,
	biomes = {
		"grassland", "forest"
	},
	y_min = 0,
	y_max = 31000,
	decoration = "farming:carrot_3",
})

minetest.override_item("default:plant_grass", {drop = {
	max_items = 1,
	items = {
		{items = {'farming:sugarcane'},rarity = 20},
		{items = {'default:plant_grass'}},
	}
}})

minetest.override_item("default:plant_grass_2", {drop = {
	max_items = 1,
	items = {
		{items = {'farming:wheat_seeds'},rarity = 5},
		{items = {'default:plant_grass'}},
	}
}})

minetest.override_item("default:plant_grass_3", {drop = {
	max_items = 1,
	items = {
		{items = {'farming:wheat_seeds'},rarity = 5},
		{items = {'default:plant_grass'}},
	}
}})

minetest.override_item("default:plant_grass_4", {drop = {
	max_items = 1,
	items = {
		{items = {'farming:wheat_seeds'},rarity = 5},
		{items = {'default:plant_grass'}},
	}
}})

minetest.override_item("default:plant_grass_5", {drop = {
	max_items = 1,
	items = {
		{items = {'farming:wheat_seeds'},rarity = 5},
		{items = {'default:plant_grass'}},
	}
}})

-- other plants

minetest.register_node("farming:apple", {
	description = "Apple",
	tiles = {"farming_apple.png"},
	drawtype = "plantlike",
	paramtype = "light",
	inventory_image = "farming_apple.png",
	groups = {crumbly=3},
	walkable = false,
	on_use = minetest.item_eat(2),
})


minetest.register_node("farming:sugarcane", {
	description = "Sugarcane",
	tiles = {"farming_sugarcane.png"},
	drawtype = "plantlike",
	paramtype = "light",
	inventory_image = "farming_sugarcane.png",
	groups = {crumbly=3, falling_node=1},
	walkable = false,
})

minetest.register_abm({
	nodenames = {"farming:sugarcane"},
	neighbors = {"default:dirt", "default:grass", "default:sand"},
	interval = 10.0,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "air" then
			minetest.set_node(pos, {name = "farming:sugarcane"})
		end
	end,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:sand"},
	sidelen = 16,
	fill_ratio = 0.04,
	biomes = {
		"beach"
	},
	spawn_by = "default:water_source",
	num_spawn_by = 1,
	y_min = 0,
	y_max = 31000,
	decoration = "farming:sugarcane",
})

minetest.register_node("farming:cactus", {
	description = "Cactus",
	tiles = {"farming_cactus_top.png", "farming_cactus_top.png", "farming_cactus.png"},
	groups = {crumbly=3, falling_node=1},
})

minetest.register_abm({
	nodenames = {"farming:cactus"},
	neighbors = {"default:sand"},
	interval = 60.0,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "air" then
			minetest.set_node(pos, {name = "farming:cactus"})
		end
	end,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:sand"},
	sidelen = 16,
	fill_ratio = 0.004,
	biomes = {
		"desert"
	},
	y_min = 0,
	y_max = 31000,
	decoration = "farming:cactus",
})

-- items

minetest.register_craftitem("farming:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
})

minetest.register_craftitem("farming:sugar", {
	description = "Sugar",
	inventory_image = "farming_sugar.png",
})

minetest.register_craftitem("farming:bowl", {
	description = "Bowl",
	inventory_image = "farming_bowl.png",
	stack_max = 1,
	liquids_pointable = true,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.above then
			if minetest.get_node(pointed_thing.under).name == "default:water_source" then
				itemstack:replace("farming:bowl_with_water")
			end
		end
		return itemstack
	end,
})

minetest.register_craftitem("farming:bowl_with_water", {
	description = "Bowl with Water",
	inventory_image = "farming_bowl_with_water.png",
	stack_max = 1,
})

minetest.register_craftitem("farming:slice_of_bread", {
	description = "Slice of Bread",
	inventory_image = "farming_slice_of_bread.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craftitem("farming:cookie", {
	description = "Cookie",
	inventory_image = "farming_cookie.png",
	on_use = minetest.item_eat(5),
})

minetest.register_craftitem("farming:mushroom_soup", {
	description = "Mushroom Soup",
	inventory_image = "farming_mushroom_soup.png",
	on_use = minetest.item_eat(7),
})

minetest.register_craftitem("farming:cactus_soup", {
	description = "Cactus Soup",
	inventory_image = "farming_cactus_soup.png",
	on_use = minetest.item_eat(7),
})


minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {"farming:wheat_seeds", "farming:wheat_seeds", "farming:wheat_seeds"}
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:cookie 5",
	recipe = {"farming:sugar", "farming:flour", "farming:bowl_with_water"},
	replacements = {
		{"farming:bowl_with_water", "farming:bowl"}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:sugar 3",
	recipe = {"farming:sugarcane"}
})


minetest.register_craft({
	output = "farming:bowl",
	recipe = {
		{"default:wood", "", "default:wood"},
		{"", "default:wood", ""},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:slice_of_bread 10",
	recipe = {"farming:flour", "farming:flour", "farming:bowl_with_water"},
	replacements = {
		{"farming:bowl_with_water", "farming:bowl"}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:mushroom_soup",
	recipe = {"default:mushroom", "default:mushroom", "farming:bowl"},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:cactus_soup",
	recipe = {"farming:cactus", "farming:cactus", "farming:bowl"},
})
