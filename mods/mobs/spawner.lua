minetest.register_node("mobs:spawner", {
	description = "Spawner",
	tiles = {"mobs_spawner.png", "mobs_spawner.png", "mobs_spawner_side.png"},
	groups = {cracky = 3},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-8/16, -8/16, -8/16, 8/16, -6/16, 8/16},
			},
	},
})

minetest.register_abm({
	nodenames = {"mobs:spawner"},
	neighbors = {},
	interval = 5,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for i, player in ipairs(minetest.get_connected_players()) do
			local p = player:getpos()
			local d = vector.distance(pos, p)
			
			if d < 6 then
				local n = mobs.get_mob(xp.getLvl(player))
				minetest.add_entity(vector.new(pos.x, pos.y + 1, pos.z), n)
			end
		end
	end,
})
