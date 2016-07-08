dofile(minetest.get_modpath("sfinv") .. "/api.lua")

sfinv.register_page("sfinv:crafting", {
	title = "Crafting",
	get = function(self, player, context, vars)
		return vars.layout ..
			[[
				list[current_player;craft;2.75,0.5;3,3;]
				list[current_player;craftpreview;6.75,1.5;1,1;]
				image[5.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]
				listring[current_player;main]
				listring[current_player;craft]
			]] ..
			default.itemslot_bg(2.75,0.5,3,3) ..
			default.itemslot_bg(6.75,1.5,1,1) ..
			default.crafting_add:format(player:get_player_name())
	end
})
