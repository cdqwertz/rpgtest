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

money.traderMainPage = function(inv)
	local size='size[12,12,false]'
	local items = ''
	local buy = 'list[context;goods;0,0;8,4]'
	local sell = 'list[context;sell;8,8;2,2]'
	local player = 'list[current_player;main;0,8;8,4]'
	local tooltips = ''
	local posx= 0
	local posy = 0
	print(tostring(inv:get_list('goods')))
	for i,v in pairs(inv:get_list('goods')) do
		if v:to_table() and v:to_table().name then
			local name = v:to_table().name
			local count = v:to_table().count
			local price = minetest.registered_items[name].trading.price
			items = items ..'item_image_button['..posx..','..posy..';1,1;'.. name ..';'.. name ..';'..count..']'
			tooltips = tooltips .. 'tooltip['.. name ..';'.. price ..'\n'.. name ..']'
			posx =posx+1
			if posx == 8 then 
				posx = 0
				posy = posy +1
			end
		end
	end
	return size ..items..sell..player..tooltips
end

money.startupTrader = function(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	
	money.createBuyInv(pos)
	local traderMainPage = money.traderMainPage(inv)
	meta:set_string('formspec', traderMainPage)
		
end

minetest.register_node("money:trader", {
	description = "trader",
	tiles = {"money_shop_top.png", "money_shop_bottom.png", "money_shop.png","money_shop.png"},
	groups = {choppy = 3},
	paramtype2 = "facedir",
	
	on_construct = function(pos)
		money.startupTrader(pos)
	end,
	


	on_receive_fields = function(pos, formname, fields, sender)
		money.fields(formname,fields,pos,sender)
	end,
	
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local inv =meta:get_inventory()
		if listname == 'sell' then
			
			local playerInv = player:get_inventory()
			print(tostring(stack:to_table().name))
			local _stack = stack:to_table()
			local _stackCount = _stack.count
			local _stackName = _stack.name
			local _stackDef = minetest.registered_items[_stackName]
			local _stackTrade = _stackDef.trading
			print(tostring(_stackDef.price))
			
			local price = minetest.registered_items[stack:to_table().name].price or 2
			price = price * stack:to_table().count
			if playerInv:room_for_item("main", {name="money:coin", count=price/2}) then
				playerInv:add_item("main", {name="money:coin", count=price/2})
				inv:set_stack('sell',1,{})
			end
			
		end
	end,
})
money.infopage = function(pos,item)
	 	local meta= minetest.get_meta(pos)
		local inv=meta:get_inventory()
		if not inv:contains_item('goods',item) then
			meta:set_string('formspec',money.traderMainPage(inv))
		else
			meta:set_string('formspec',money.infoItem(item))
		end
end

function money.fields(formname,fields,pos,sender)
	print('formname: '.. tostring(formname))
	for name,value in pairs(fields) do
		if name == 'quit' and value then return end
		if name == 'back' then 
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local traderMainPage = money.traderMainPage(inv)
			meta:set_string('formspec',traderMainPage)
			return
		end
		print(tostring(name))
		print(tostring(value))
		if value == 'buyone' then
			money[value](pos,sender,name)
			
		elseif value == 'buyall' then
			money[value](pos,sender,name)
			
			
		end
		if minetest.registered_items[name] then
			money.infopage(pos,name)
			return
		end
	end
end

money.createBuyInv = function(pos)
 	local meta= minetest.get_meta(pos)
 	local inv=meta:get_inventory()
	inv:set_size("goods", 32)
	inv:set_size('sell',1*1)
	local index= 1
	while inv:room_for_item('goods',{name='money:coin',count = 1}) do
		
		for name,def in pairs(minetest.registered_items)do
			if def.trading then
				if math.random(1,def.trading.rarity)==1 then
					inv:add_item('goods',{name=name,count = math.random(1,100)})
					index = index +1
					
				end
			end
		end
	end
	
	
	
end


money.infoItem = function(item)
	local def = minetest.registered_items[item]
	local info = 'size[12,14]'
	info = info .. 'bgcolor[#000000;false]'
	info = info .. 'button[10,0;2,2;back;formback]'
	info = info .. 'button[2,12;2,2;'..item..';buyone]'
	info = info .. 'button[6,12;2,2;'..item..';buy5]'
	info = info .. 'button[8,12;2,2;'..item..';buy10]'
	info = info .. 'button[4,12;2,2;'..item..';buyall]'
	
	info = info .. 'item_image[0,0;2,2;'..item..']'
	info = info .. 'box[0,0;2,2;#00ff00]'
	
	info = info .. 'label[3,0;'..def.description..':]'
	info = info .. 'box[3,0;4,0.5;#FF3333]'
	
	local y = 2
	local x = 0
	info = info .. 'label['..x..','..y..';price:]'
	info = info .. 'label[6,'..y..';'..def.trading.price..']'
	y = y+0.5
	info = info .. 'label['..x..','..y..';rarity:]'
	info = info .. 'label[6,'..y..';'..def.trading.rarity..']'
	y = y+0.5

	if def.drop then
		info = info .. 'label['..x..','..y..';drop:]'
		info = info .. 'label[6,'..y..';'..def.drop..']'
		y = y+0.5
	end
	if def.climbable then
		info = info .. 'label['..x..','..y..';climbable:]'
		info = info .. 'label[6,'..y..';'..def.climbable..']'
		y = y+0.5
	end
	if def.damage_per_second then
		info = info .. 'label['..x..','..y..';damage_per_second:]'
		info = info .. 'label[6,'..y..';'..def.damage_per_second..']'
		y = y+0.5
	end
	
	if def.tool_capabilities then

		for name,value in pairs(def.tool_capabilities) do
			info = info .. 'label['..x..','..y..';'.. name ..':]'
			y=y+0.5
			xx = 0
			
			if type(value) == 'table' then
				x=x+1
				for index,data in pairs(value)do
					info = info .. 'label['..x..','..y..';'.. index ..':]'
					
					y=y+0.5
					if type(data) == 'table' then
						x=x+1
						for pos, entry in pairs(data)do
							info = info .. 'label['..x..','..y..';'.. pos ..':]'
							
							y = y+0.5
							if type(entry) == 'table' then
								x=x+1
								
								for row,caps in pairs(entry) do
									info = info .. 'label['..x..','..y..';'.. row ..':]'
									info = info .. 'label['.. 6 ..','..y..';'.. caps ..']'
									y=y+0.5
									
								end
								x=xx
							else
								info = info .. 'label['.. 6 ..','..y-0.5 ..';'.. entry ..']'
								
							end
						
						end
						x=xx
					else
						info = info .. 'label['.. 6 ..','..y-0.5 ..';'.. data ..']'
					end
				end
				x=xx
			else
				info = info .. 'label['.. 6 ..','..y-0.5 ..';'.. value ..']'
			end
		end
		x=xx
	end
	
	return info
end


money.buyone = function(pos,player,item)
	print(tostring('buy one item'))
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local playerInv = player:get_inventory()
	local stackAdd = {name=item, count=1}
	local stackRm = {name='money:coin', count=minetest.registered_items[item].trading.price}
	local space = playerInv:room_for_item("main", stackAdd)
	local cash = playerInv:contains_item('main', stackRm)
	if space and cash then
		print(tostring('item buyd'))
		playerInv:add_item('main',stackAdd)
		playerInv:remove_item('main', stackRm)
		inv:remove_item('goods',stackAdd)
	end
	if not inv:contains_item('goods', stackAdd) then
		
	end
	
end

money.buyall = function(pos,player,item)
	print(tostring('buy all item'))
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local maxStack = ItemStack(item):get_stack_max()
	local amount =inv:contains_item('goods',{name=item, count=maxStack})
	local playerInv = player:get_inventory()
	local removed = inv:remove_item('goods', {name=item, count=maxStack})
	local rmt = removed:to_table()
	local cash = playerInv:contains_item('main', {name = 'money:coin',count = rmt.count * minetest.registered_items[item].trading.price })
	local space = playerInv:room_for_item("main", removed)
	if space and cash then
		playerInv:add_item('main',removed)
		playerInv:remove_item('main', {name ='money:coin',count = rmt.count * minetest.registered_items[item].trading.price })
	else 
		inv:add_item('goods',removed)
	end
	
end
	



