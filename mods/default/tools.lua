minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
		},
		damage_groups = {fleshy=2},
	}
})

-- wood

minetest.register_tool("default:simple_hammer", {
	description = "Simple Hammer",
	inventory_image = "default_basic_hammer.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			cracky={times={[2]=2.00, [3]=1.00}, uses=10, maxlevel=1},
			choppy={times={[2]=1.50, [3]=1.00}, uses=20, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	},
	trading={price = 250,rarity = 1}
})

-- flint

minetest.register_tool("default:flint_pick", {
	description = "Flint Pick",
	inventory_image = "default_flint_pick.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			cracky={times={[2]=1.50, [3]=0.80}, uses=50, maxlevel=1},
			choppy={times={[2]=1.50, [3]=1.00}, uses=20, maxlevel=1}
		},
		damage_groups = {fleshy=2},
	}
})

-- stone

minetest.register_tool("default:axe_stone", {
	description = "Stone Axe",
	inventory_image = "default_axe_stone.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			cracky={times={[3]=1.50}, uses=5, maxlevel=1},
			choppy={times={[2]=3.50, [3]=1.10}, uses=10, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	}
})

-- iron

minetest.register_tool("default:axe", {
	description = "Iron Axe",
	inventory_image = "default_axe.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			choppy={times={[1]=1.00, [2]=0.40, [3]=0.30}, uses=90, maxlevel=1}
		},
		damage_groups = {fleshy=2},
	}
})

minetest.register_tool("default:saw", {
	description = "Iron Saw",
	inventory_image = "default_saw.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			choppy={times={[1]=0.30, [2]=0.20, [3]=0.10}, uses=70, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	}
})

minetest.register_tool("default:pick", {
	description = "Iron Pick",
	inventory_image = "default_pick.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			cracky={times={[1]=1.90, [2]=0.50, [3]=0.30}, uses=50, maxlevel=1},
			choppy={times={[2]=3.50, [3]=1.10}, uses=50, maxlevel=1}
		},
		damage_groups = {fleshy=2},
	}
})

minetest.register_tool("default:shovel", {
	description = "Iron Shovel",
	inventory_image = "default_shovel.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			crumbly={times={[1]=0.90, [2]=0.40, [3]=0.20}, uses=100, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	}
})

-- copper

minetest.register_tool("default:pick_copper", {
	description = "Copper Pick",
	inventory_image = "default_pick_copper.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			cracky={times={[1]=1.00, [2]=0.30, [3]=0.20}, uses=150, maxlevel=1},
			hard={times={[2]=2.5, [3]=1.50}, uses=50, maxlevel=1},
			choppy={times={[2]=3.50, [3]=1.10}, uses=50, maxlevel=1}
		},
		damage_groups = {fleshy=3},
	}
})

minetest.register_tool("default:axe_copper", {
	description = "Copper Axe",
	inventory_image = "default_axe_copper.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			choppy={times={[1]=0.90, [2]=0.20, [3]=0.10}, uses=150, maxlevel=1}
		},
		damage_groups = {fleshy=2},
	}
})

minetest.register_tool("default:shovel_copper", {
	description = "Copper Shovel",
	inventory_image = "default_shovel_copper.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			crumbly={times={[1]=0.70, [2]=0.30, [3]=0.10}, uses=100, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	}
})

minetest.register_tool("default:saw_copper", {
	description = "Copper Saw",
	inventory_image = "default_saw_copper.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			choppy={times={[1]=0.20, [2]=0.20, [3]=0.10}, uses=120, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	}
})

-- diamond

minetest.register_tool("default:pick_diamond", {
	description = "Diamond Pick",
	inventory_image = "default_pick_diamond.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			cracky={times={[1]=0.40, [2]=0.30, [3]=0.20}, uses=150, maxlevel=1},
			hard={times={[1]=1.90, [2]=1.00, [3]=0.7}, uses=150, maxlevel=1},
			choppy={times={[2]=3.50, [3]=1.10}, uses=100, maxlevel=1}
		},
		damage_groups = {fleshy=3},
	}
})

minetest.register_tool("default:axe_diamond", {
	description = "Diamond Axe",
	inventory_image = "default_axe_diamond.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			choppy={times={[1]=0.30, [2]=0.20, [3]=0.10}, uses=150, maxlevel=1}
		},
		damage_groups = {fleshy=2},
	}
})

minetest.register_tool("default:shovel_diamond", {
	description = "Diamond Shovel",
	inventory_image = "default_shovel_diamond.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			crumbly={times={[1]=0.30, [2]=0.20, [3]=0.10}, uses=100, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	}
})

minetest.register_tool("default:saw_diamond", {
	description = "Diamond Saw",
	inventory_image = "default_saw_diamond.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			choppy={times={[1]=0.10, [2]=0.10, [3]=0.10}, uses=120, maxlevel=1}
		},
		damage_groups = {fleshy=1},
	}
})

-- other

minetest.register_tool("default:knife", {
	description = "Knife",
	inventory_image = "default_knife.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			leaves={times={[1]=0.10}, uses=1000, maxlevel=1},
			choppy={times={[3]=2.00}, uses=50, maxlevel=1}
		},
		damage_groups = {fleshy=7},
	}
})

minetest.register_tool("default:knife_big", {
	description = "Knife (big)",
	inventory_image = "default_knife.png",
	wield_scale = {x = 1.5, y=1.5, z = 1},
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			leaves={times={[1]=0.05}, uses=1000, maxlevel=1},
			choppy={times={[3]=2.00}, uses=50, maxlevel=1}
		},
		damage_groups = {fleshy=8},
	}
})

minetest.register_tool("default:shears", {
	description = "Shears",
	inventory_image = "default_shears.png",
	tool_capabilities = {
		max_drop_level=3,
		groupcaps= {
			leaves={times={[1]=0.10}, uses=1000, maxlevel=1},
			choppy={times={[3]=2.00}, uses=50, maxlevel=1}
		}
	}
})
