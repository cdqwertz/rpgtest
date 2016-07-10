sfinv = {
	pages = {},
	pages_unordered = {},
	homepage_name = "sfinv:crafting",
	contexts = {}
}

function sfinv.register_page(name, def)
	if not name or not def or not def.get then
		error("Invalid sfinv page. Requires a name & def, and a get function in def")
	end
	sfinv.pages[name] = def
	def.name = name
	table.insert(sfinv.pages_unordered, def)
end

local theme_start = [[
		size[8,8.6]
	]] .. default.gui_bg .. default.gui_bg_img .. default.gui_slots ..
		default.gui_colors

local theme_end =
	[[
		list[current_player;main;0,4.7;8,1;]
		list[current_player;main;0,5.85;8,3;8]
	]] .. default.itemslot_bg(0,4.7,8,1) .. default.itemslot_bg(0,5.85,8,3)

function sfinv.get_nav_fs(player, context, vars, nav, current_idx)
	-- Only show tabs if there is more than one page
	if #nav > 1 then
		return "tabheader[0,0;tabs;" .. table.concat(nav, ",") .. ";" .. current_idx .. ";true;false]"
	else
		return ""
	end
end

function sfinv.get_layout_fs(player, context, vars)
	return theme_start .. vars.nav .. theme_end
end

function sfinv.get_formspec(player, context)
	-- Generate navigation tabs
	local nav = {}
	local nav_ids = {}
	local current_idx = 1
	for i, pdef in pairs(sfinv.pages_unordered) do
		if not pdef.is_in_nav or pdef:is_in_nav(player, context) then
			nav[#nav + 1] = pdef.title
			nav_ids[#nav_ids + 1] = pdef.name
			if pdef.name == context.page then
				current_idx = i
			end
		end
	end
	context.nav = nav_ids

	-- Collect variables
	local vars = {
		name = player:get_player_name()
	}
	vars.nav = sfinv.get_nav_fs(player, context, vars, nav, current_idx)
	vars.layout = sfinv.get_layout_fs(player, context, vars)

	-- Generate formspec
	local page = sfinv.pages[context.page] or sfinv.pages["404"]
	if page then
		return page:get(player, context, vars)
	else
		local old_page = context.page
		context.page = sfinv.homepage_name
		if sfinv.pages[context.page] then
			minetest.log("warning", "[sfinv] Couldn't find " .. dump(old_page) .. " so using switching to homepage")
			return sfinv.get_formspec(player, context)
		else
			error("[sfinv] Invalid homepage")
		end
	end
end

function sfinv.set(player, context)
	if not context then
		local name = player:get_player_name()
		context = sfinv.contexts[name]
		if not context then
			context = {
				page = sfinv.homepage_name
			}
			sfinv.contexts[name] = context
		end
	end

	local fs = sfinv.get_formspec(player, context)
	player:set_inventory_formspec(fs)
end

minetest.register_on_joinplayer(function(player)
	minetest.after(0.5, function()
		sfinv.set(player)
	end)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return false
	end

	-- Get Context
	local name = player:get_player_name()
	local context = sfinv.contexts[name]
	if not context then
		sfinv.set(player)
		return false
	end

	-- Handle Events
	if fields.tabs and context.nav then
		local tid = tonumber(fields.tabs)
		if tid and tid > 0 then
			local id = context.nav[tid]
			local page = sfinv.pages[id]
			if id and page then
				print(name .. " views sfinv/" .. id)

				-- TODO: on_leave
				local oldpage = sfinv.pages[context.page]
				if oldpage and oldpage.on_leave then
					oldpage:on_leave(player, context)
				end
				context.page = id
				if page.on_enter then
					page:on_enter(player, context)
				end
				sfinv.set(player, context)
			end
		end
		return
	end

	-- Pass to page
	local page = sfinv.pages[context.page]
	if page and page.on_player_receive_fields then
		return page:on_player_receive_fields(player, context, fields)
	end
end)
