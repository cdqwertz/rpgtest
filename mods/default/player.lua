function default.itemslot_bg(x,y,w,h)
	local imgs = ""
	for i = 0, w-1,1 do
		for j=0, h-1,1 do
			imgs = imgs .."image["..x+i..","..y+j..";1,1;gui_itemslot_bg.png]"
		end
	end
	return imgs
end

default.gui_bg = "bgcolor[#a88e69FF;false]"
default.gui_colors = "listcolors[#00000000;#10101030;#00000000;#68B259;#FFF]"
default.gui_bg_img = ""--"background[5,5;1,1;gui_formbg.png;true]"
default.gui_slots = "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

default.player_anim = {}

minetest.register_on_joinplayer(function(player)
	player:hud_set_hotbar_image("gui_hotbar.png")
	player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
	-- player:set_inventory_formspec(default.inv_form:format(player:get_player_name()))

	player:set_properties({
		mesh = "character.x",
		textures = {"character.png"},
		visual = "mesh",
		visual_size = {x=1, y=1},
	})
	--player:set_animation({ x= 25, y= 60,}, 30, 0)
	player:set_local_animation({x= 25, y=90},{x=0, y=20}, {x= 90, y=100}, {x= 90, y=100}, 30)
	-- default.player_anim[player:get_player_name()] = "stand"

	-- Testing of HUD elements
	player:hud_add({
		hud_elem_type = "waypoint",
		name = "spawn",
		text = "",
		number = 255,
		world_pos = {x=0,y=0,z=0}
	})
end)

local function set_pl_anim(a, b, name, player)
	if default.player_anim[player:get_player_name()] ~= name then
		player:set_animation({ x= a, y= b,}, 30, 0)
		default.player_anim[player:get_player_name()] = name
	end
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local controls = player:get_player_control()

		if player:get_hp() == 0 then
			--set_pl_anim(90, 100, "mine", player)
		elseif controls.jump then
			set_pl_anim(105, 120, "jump", player)
		elseif controls.sneak then
			set_pl_anim(125, 140, "sneak", player)
		elseif controls.up or controls.down or controls.left or controls.right then
			set_pl_anim(0, 20, "walk", player)
		elseif controls.LMB then
			set_pl_anim(90, 100, "mine", player)
		else
			set_pl_anim(25, 90, "stand", player)
		end
	end
end)
