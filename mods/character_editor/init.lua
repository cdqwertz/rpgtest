character_editor = {}
character_editor.characters = {}
character_editor.language = {}
character_editor.mesh = {}

character_editor.shirts = {"character_editor_red_shirt.png", "character_editor_blue_shirt.png", "character_editor_yellow_shirt.png"}

function character_editor.update_character(player)
	local name = player:get_player_name()
	player:set_properties({
		mesh = character_editor.mesh[name],
		textures = {table.concat(character_editor.characters[name], "^")},
		visual = "mesh",
		visual_size = {x=1, y=1},
	})
	print(table.concat(character_editor.characters[name], "^"))
end

function character_editor.set_mesh(player, mesh)
	local name = player:get_player_name()
	character_editor.mesh[name] = mesh
	character_editor.update_character(player)
end

function character_editor.set_texture(player, pos, texture)
	local name = player:get_player_name()
	if not character_editor.characters[name] then
		character_editor.characters[name] = {}
	end

	character_editor.characters[name][pos] = texture
	print(character_editor.characters[name][pos])
	character_editor.update_character(player)
end

character_editor.window = "size[8,7.5;]"
character_editor.window = character_editor.window .. default.gui_colors
character_editor.window = character_editor.window .. default.gui_bg
character_editor.window = character_editor.window .. "label[0,0;Select your language! All dialogs will be translated\nin this language. Items are not translated.\nIf you cant find your language in this list,\n pls send a private message to cd2 on the minetest forums.]"
character_editor.window = character_editor.window .. "button[3,2;2,1;lang_EN;EN]"
character_editor.window = character_editor.window .. "button[3,3;2,1;lang_DE;DE]"
character_editor.window = character_editor.window .. "button[3,4;2,1;lang_FR;FR]"
character_editor.window = character_editor.window .. "button[3,5;2,1;lang_TR;TR]"

function character_editor.show_window(player)
	local name = player:get_player_name()
	minetest.show_formspec(name, "character_editor:language", character_editor.window)
end

minetest.register_chatcommand("shirt", {
	params = "<name>",
	description = "[TEST CMD] Select your shirt",
	privs = {interact = true},
	func = function(plname , name)
		local player = minetest.get_player_by_name(plname)
		if character_editor.shirts[tonumber(name)] then
			character_editor.set_texture(player, 2, character_editor.shirts[tonumber(name)])
			return true, "You selected ".. name
		else
			return true, "There is no shirt named ".. name
		end
	end,
})

minetest.register_on_joinplayer(function(player)
	character_editor.mesh[player:get_player_name()] = "character.x"
	character_editor.characters[player:get_player_name()] = {}
	character_editor.set_texture(player, 1, "character.png")
end)

minetest.register_on_newplayer(function(player)
	character_editor.show_window(player)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "character_editor:language" then
		print("FORM")
		print("Player "..player:get_player_name().." submitted fields "..dump(fields))
		local name = player:get_player_name()
		if fields["lang_EN"] then
			print("EN")
			character_editor.language[name] = ""
		elseif fields["lang_DE"] then
			print("DE")
			character_editor.language[name] = "de/"
		elseif fields["lang_FR"] then
			print("FR")
			character_editor.language[name] = "fr/"
		elseif fields["lang_TR"] then
			print("TR")
			character_editor.language[name] = "tr/"
		end
	end
end)
