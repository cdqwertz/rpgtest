minetest.register_craftitem("money:coin", {
	description = "Coin",
	inventory_image = "money_coin.png",
})

minetest.register_craftitem("money:silver_coin", {
	description = "Silver Coin",
	inventory_image = "money_silver_coin.png",
})

money = {}
money.shop = {}
money.shop.form = "size[8,8;]"..default.gui_colors..default.gui_bg.."list[current_player;main;0,4;8,4;]button[0,3;1,1;btn_back;<]button[7,3;1,1;btn_next;>]button[3,1;2,1;btn_trade;Trade]item_image_button[2,1;1,1;input_item;input_item;]item_image_button[5,1;1,1;output_item;output_item;]"
money.shop.page = {}
money.shop.offers = {
	{input="money:silver_coin", output="default:coal_lump"},
	{input="money:silver_coin 2", output="default:box"},
	{input="money:coin 1", output="default:pick"},
	{input="money:silver_coin 4", output="dungeons:custom_treasure_chest"},
	{input="default:stone_item 999", output="money:silver_coin 5"}
}

function money.shop.get_formspec(page)
	if not(money.shop.offers[page]) then
		return money.shop.form
	end

	local s = string.gsub(money.shop.form, "input_item", money.shop.offers[page].input)
	s = string.gsub(s, "output_item", money.shop.offers[page].output)

	return s
end

function money.shop.trade(player)
	if not(money.shop.page[player:get_player_name()]) then
		return
	end

	local offer = money.shop.offers[money.shop.page[player:get_player_name()]]

	if not(offer) then
		return
	end

	if player:get_inventory():contains_item("main", offer.input) then
		player:get_inventory():remove_item("main", offer.input)
		player:get_inventory():add_item("main", offer.output)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "money:shop" then
		if fields.btn_next then
			money.shop.page[player:get_player_name()] = money.shop.page[player:get_player_name()] + 1
			
			if money.shop.page[player:get_player_name()] > #money.shop.offers then
				money.shop.page[player:get_player_name()] = #money.shop.offers
			end

			minetest.show_formspec(player:get_player_name(), "money:shop", money.shop.get_formspec(money.shop.page[player:get_player_name()]))
		end
		if fields.btn_back then
			money.shop.page[player:get_player_name()] = money.shop.page[player:get_player_name()] - 1

			if money.shop.page[player:get_player_name()] < 1 then
				money.shop.page[player:get_player_name()] = 1
			end

			minetest.show_formspec(player:get_player_name(), "money:shop", money.shop.get_formspec(money.shop.page[player:get_player_name()]))
		end
		if fields.btn_trade then
			money.shop.trade(player)
		end
		if fields.quit then
			money.shop.page[player:get_player_name()] = nil
		end
	end
end)

minetest.register_node("money:shop", {
	description = "Shop",
	tiles = {"money_shop_top.png", "money_shop_bottom.png", "money_shop.png","money_shop.png"},
	groups = {choppy = 3},
	paramtype2 = "facedir",
	
	on_rightclick = function(pos, node, player, pointed_thing)
		money.shop.page[player:get_player_name()] = 1
		minetest.show_formspec(player:get_player_name(), "money:shop", money.shop.get_formspec(1))
	end
})

minetest.register_node("money:trader", {
	description = "trader",
	tiles = {"money_shop_top.png", "money_shop_bottom.png", "money_shop.png","money_shop.png"},
	groups = {choppy = 3},
	paramtype2 = "facedir",
	
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		inv:set_size("side", 8*4)
		inv:set_size('sell',1*1)
		local invs = meta:from_table({
			inventory = {
			main = {
				[1] = "default:dirt", [2] = "", [3] = "", [4] = "",
				[5] = "", [6] = "", [7] = "", [8] = "", [9] = "",
				[10] = "", [11] = "", [12] = "", [13] = "",
				[14] = "default:cobble", [15] = "", [16] = "", [17] = "",
				[18] = "", [19] = "", [20] = "default:cobble", [21] = "",
				[22] = "", [23] = "", [24] = "", [25] = "", [26] = "",
				[27] = "", [28] = "", [29] = "", [30] = "", [31] = "",
				[32] = ""},
			
			side = {
				[1] = "default:stone", [2] = "", [3] = "", [4] = "",
				[5] = "", [6] = "", [7] = "", [8] = "", [9] = "",
				[10] = "", [11] = "", [12] = "", [13] = "",
				[14] = "torch:torch", [15] = "", [16] = "", [17] = "",
				[18] = "", [19] = "", [20] = "default:dirt", [21] = "",
				[22] = "", [23] = "", [24] = "", [25] = "", [26] = "",
				[27] = "", [28] = "", [29] = "", [30] = "", [31] = "",
				[32] = ""},
			sell = {
				[1] = ""}
			},
			
		})
		local background = 'background[0;0;0,0;money_shop_top.png;true]'--useless
		local size='size[12,12,false]'
		local container0='container[5,5]'
		local listring = 'listring[context;main]'
		local listring2 = 'listring[context;side]'
		local list = 'list[context;main;0,0;8,4;]'
		local textlist = 'textlist[0,1;1,1;<name>;albero,foglia,tronco,radice,seme,frutto,pangom]'
		local box = 'box[0,0;1,1;#FFFFFF]'
		local bgcolor = 'bgcolor[#ffffff;true]'
		local tabheader = 'tabheader[0,0;header;sasso,carta,forbice;forbice;false;true]'
		local dropdown = 'dropdown[0,0;1;casa;tetto,muri,porte;2]'
		local checkbox ='checkbox[0,0;vero;vero;true]'
		local scrollbar = 'scrollbar[0,0;1,1;horizontal;scroll;200]'
		--local itembutton = 'item_image_button[0,0;1,1;' .. table.insert(items,v:to_table().name) .. ';torch;torch]'
		print(tostring(inv))
		available = {}
		for name, def in pairs(minetest.registered_items) do
			if def.trading then
				available[name]=def.trading
			end
		end
		
		local items = ''
		local prices = ''
		local buys = ''
		local sell = 'list[context;sell;8,8;2,2]'
		local player = 'list[current_player;main;0,8;8,4]'
		local index = 1
		for i,v in pairs(meta:to_table().inventory.side) do
			print(tostring(i))
			print(tostring(v:to_table()))
			
			if v:to_table() and v:to_table().name then
				local name = v:to_table().name
				local fieldItem = name
				local nameItem = name
				local labelItem = 'info'
				local fnameinfo = name..'info'
				local fnamebuy = name .. 'buy'
				local fnamesell = name..'sell'
				local _index = tostring(index)
				local labelpos = tostring(index + 1)
				local price = v:to_table().price or math.random(1,1000)
				
				items = items ..'item_image_button[1,'.._index..';1,1;'.. fieldItem ..';'.. nameItem ..';'.. labelItem ..']'
				prices = prices ..'label[3,'.. labelpos ..';$'.. price ..']'
				buys = buys .. 'button[5,'.. _index ..';1,1;'.. fnamebuy ..';buy one]'
				buys = buys .. 'button[5,'.. labelpos ..';1,1;'.. fnamesell ..';sell one]'
				

				index = index+1
			end
			
		end

			
			
		
		meta:set_string('formspec', size ..items..prices ..buys..sell..player)
		meta:set_string('formback', size ..items..prices ..buys..sell..player)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		money.fields(formname,fields,pos)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local inv =meta:get_inventory()
		if listname == 'sell' then
			inv:set_stack('sell',1,{})
			local playerInv = player:get_inventory()
			if playerInv:room_for_item("main", {name="money:coin", count=5}) then
				playerInv:add_item("main", {name="money:coin", count=5})
			else
				inv:add_item('sell',{name="money:coin", count=5})
			end
			
		end
		end,
})

function money.fields(formname,fields,pos)
	print(tostring(formname))
	for name,value in pairs(fields) do
		if name == 'quit' and value then return end
		
		print(tostring(name))
		print(tostring(value))
		
		local aaa=money.received[value](name,value,pos)
		
	end
end
money.received = {}
money.received.formback= function(name,value,pos)
	local meta=minetest.get_meta(pos)
	meta:set_string('formspec',meta:get_string('formback'))
end
money.received.info = function(name,value,pos)
	local info = {}
		info['groups'] = 'table'
	local infos = ''
	local index=4
	for i,v in pairs(info) do
		if v == 'table' then
			for ii,vv in pairs(minetest.registered_items[name][i]) do
				infos = infos..'label[3,]'
				
			end
		end
	end
	print(tostring('informations'))
	
	local meta=minetest.get_meta(pos)
	meta:set_string('formspec',
	'size[12,12]'..
	'button[10,0;2,2;back;formback]'..
	'label[3,3;'..minetest.registered_items[name].name..']'..
	'button[02,10;2,2;buy one;buy one]'..
	'button[06,10;2,2;buy 5;buy 5]'..
	'button[08,10;2,2;buy 10;buy 10]'..
	'button[04,10;2,2;buy all;buy all]'
	)
	
	
end

money.received.buy = function(name,value,pos)
	print(tostring('direct buy'))
end

