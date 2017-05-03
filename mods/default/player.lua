default.gui_color_theme = 2
default.player_inventory = {}
default.player_inventory.tabs = {}
default.player_inventory.contexts = {}

function default.player_inventory.register_tab(def)
	def.type = def.type or "normal"
	table.insert(default.player_inventory.tabs, def)
end

function default.player_inventory.get_tab(name)
	for i,v in ipairs(default.player_inventory.tabs) do
		if v.name == name then
			return v
		end
	end
end

function default.player_inventory.get_formspec(tab, name)
	if not(default.player_inventory.tabs[tab]) then
		return ""
	end

	local formspec = ""
	if default.player_inventory.tabs[tab].type == "function" then
		formspec = default.player_inventory.tabs[tab].get_formspec(name)
	else
		formspec = default.player_inventory.tabs[tab].formspec
	end

	local tabs = {}

	for i,v in ipairs(default.player_inventory.tabs) do
		table.insert(tabs, v.name) 
	end

	formspec = formspec .. "tabheader[0,0;tabs;"..table.concat(tabs, ",")..";" .. tostring(tab) .. ";true;false]"
	return formspec
end

function default.player_inventory.set_tab(name, i)
	if not(default.player_inventory.contexts[name]) then
		default.player_inventory.contexts[name] = {
			tab = 1
		}
	end

	default.player_inventory.contexts[name].tab = i
end

function default.player_inventory.update(player)
	if not(player) then
		return
	end

	local name = player:get_player_name()

	if not(default.player_inventory.contexts[name]) then
		default.player_inventory.contexts[name] = {
			tab = 1
		}
	end

	local tab = default.player_inventory.contexts[name].tab or 1
	local formspec = default.player_inventory.get_formspec(tab, name)
	player:set_inventory_formspec(string.gsub(string.format(formspec, player:get_player_name()), "<player_name>", player:get_player_name()))
end

function default.player_inventory.get_default_inventory_formspec()
	local formspec = "size[8,7.5;]" .. 
		   default.gui_colors .. 
		   default.gui_bg ..
		   "list[current_player;main;0,3.5;8,4;]" .. 
		   default.itemslot_bg(0,3.5,8,4)
	return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)

	if not(formname == "") then
		return
	end

	local name = player:get_player_name()
	if fields.tabs then
		default.player_inventory.set_tab(name, tonumber(fields.tabs))
		default.player_inventory.update(player)
	else
		if not(default.player_inventory.contexts[name]) then return end
		if not(default.player_inventory.tabs[default.player_inventory.contexts[name].tab]) then return end
		if not(default.player_inventory.tabs[default.player_inventory.contexts[name].tab]).on_event then return end
		default.player_inventory.tabs[default.player_inventory.contexts[name].tab].on_event(player, fields)
		default.player_inventory.update(player)
	end
end)

function default.itemslot_bg(x,y,w,h)
	if default.gui_color_theme == 1 then
		local imgs = ""
		for i = 0, w-1,1 do
			for j=0, h-1,1 do
				imgs = imgs .."image["..x+i..","..y+j..";1,1;gui_itemslot_bg.png]"
			end
		end
		return imgs
	else
		return ""
	end
end

default.gui_color_themes = {}

function default.register_gui_color_theme(def)
	table.insert(default.gui_color_themes, def)
end

function default.set_gui_color_theme(x)
	default.gui_bg = default.gui_color_themes[x].background
	default.gui_colors = default.gui_color_themes[x].colors
end

default.register_gui_color_theme({
	background = "bgcolor[#a88e69FF;false]",
	colors = "listcolors[#00000000;#10101030;#00000000;#68B259;#FFF]"
})

default.register_gui_color_theme({
	background = "bgcolor[#333333FF;false]",
	colors = "listcolors[#222222FF;#333333FF;#000000FF;#444444FF;#FFF]"
})

default.register_gui_color_theme({
	background = "bgcolor[#CCCCCCFF;false]",
	colors = "listcolors[#AAAAAAFF;#777777FF;#666666FF;#444444FF;#FFF]"
})

default.register_gui_color_theme({
	background = "bgcolor[#99999933;false]",
	colors = "listcolors[#00000022;#44444477;#000000FF;#444444FF;#FFF]"
})

default.set_gui_color_theme(default.gui_color_theme)

default.inv_form = default.player_inventory.get_default_inventory_formspec()
default.inv_form = default.inv_form.."list[current_player;craft;1.5,1;3,1;]"
default.inv_form = default.inv_form..default.itemslot_bg(1.5,1,3,1)
default.inv_form = default.inv_form.."list[current_player;craftpreview;5.5,1;1,1;]"
default.inv_form = default.inv_form..default.itemslot_bg(5.5,1,1,1)
default.inv_form = default.inv_form.."listring[current_player;craft]"
default.inv_form = default.inv_form.."listring[current_player;main]"
default.inv_form = default.inv_form.."button[0,2.5;1,1;crafting_guide;?]"

default.player_inventory.register_tab({
	name = "Crafting",
	formspec = default.inv_form
})

default.craft_form = "size[8,7.5;]"
default.craft_form = default.craft_form..default.gui_colors
default.craft_form = default.craft_form..default.gui_bg
default.craft_form = default.craft_form.."list[current_player;main;0,3.5;8,4;]"
default.craft_form = default.craft_form..default.itemslot_bg(0,3.5,8,4)
default.craft_form = default.craft_form.."list[current_player;craft;1.5,0;3,3;]"
default.craft_form = default.craft_form..default.itemslot_bg(1.5,0,3,3)
default.craft_form = default.craft_form.."list[current_player;craftpreview;5,1;1,1;]"
default.craft_form = default.craft_form..default.itemslot_bg(5,1,1,1)
default.craft_form = default.craft_form.."listring[current_player;craft]"
default.craft_form = default.craft_form.."listring[current_player;main]"

default.player_anim = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	player:hud_set_hotbar_image("gui_hotbar.png")
	player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")

	default.player_inventory.set_tab(name, 1)
	default.player_inventory.update(player)
	
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

