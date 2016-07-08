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

character_editor.window = "size[8,3.4]" .. default.gui_colors ..
		default.gui_bg ..
		"label[0.1,0;" ..
		minetest.formspec_escape([[Select your language!
Dialogs are translated, but items are not.
If you can't find your language in this list,
pls send a private message to cd2 on the minetest forums. ]]) ..
		[[
			]dropdown[0.25,2;8;language;EN,DE,FR,ID,TR;1]
			button_exit[2.5,2.8;3,1;set;Save and Exit] ]]

function character_editor.show_window(player)
	minetest.show_formspec(player:get_player_name(), "character_editor:language", character_editor.window)
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

minetest.register_on_newplayer(function(player)
	character_editor.mesh[player:get_player_name()] = "character.x"
	character_editor.characters[player:get_player_name()] = {}
	character_editor.set_texture(player, 1, "character.png")
	character_editor.show_window(player)
end)

function character_editor.on_receive_fields(player, formname, fields)
	if formname == "character_editor:language" then
		local name = player:get_player_name()
		if fields.language and not fields.quit then
			local val = fields.language
			if val == "EN" then
				print("EN")
				character_editor.language[name] = ""
			elseif val == "DE" then
				print("DE")
				character_editor.language[name] = "de/"
			elseif val == "FR" then
				print("FR")
				character_editor.language[name] = "fr/"
			elseif val == "ID" then
				print("ID")
				character_editor.language[name] = "id/"
			elseif val == "TR" then
				print("TR")
				character_editor.language[name] = "tr/"
			else
				print("Invalid option " .. val)
			end
		end
	end
end
minetest.register_on_player_receive_fields(character_editor.on_receive_fields)

sfinv.register_page("character_editor", {
	title = "Character",
	get = function(self, player, context, vars)
		return vars.layout ..
			"label[2.25,0;" ..
			minetest.formspec_escape([[Select your language!
Dialogs are translated, but items are not.]]) ..
			[[
				]dropdown[2.25,1;6;language;EN,DE,FR,ID,TR;1]
			]] ..
			default.crafting_add:format(player:get_player_name())
	end,
	on_player_receive_fields = function(self, player, context, fields)
		return character_editor.on_receive_fields(player, "character_editor:language", fields)
	end
})
