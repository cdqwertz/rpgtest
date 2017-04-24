function mobs.register_component(name, def)
	if not(def.action) or not(name) then
		return false
	end
	mobs.components[name] = def
	return true
end

function mobs.get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end

function mobs.update_components(components, self, def)
	for i,v in ipairs(components) do
		if v.name and mobs.components[v.name] then
			local output = mobs.components[v.name].action(self, v, def)
			-- print("[mobs] call : " .. v.name .. " -> " .. output)
			if output == 0 and v.failure then
				-- print("[mobs] FAILURE")
				mobs.update_components(v.failure, self, def)
			elseif output == 1 and v.success then
				mobs.update_components(v.success, self, def)
			elseif output == 2 and v.done then
				mobs.update_components(v.done, self, def)
			end
		end
	end
end

function mobs.register_mob(name, def)
	mobs.mobs[#mobs.mobs+1] = {name, def.lvl}

	if not def.hp then
		if def.lvl and def.hits then
			def.hp = skills.get_dmg(def.lvl)*def.hits
		end
	end

	def.behaviour = def.behaviour or {
		{
			name = "walk",
			speed = 4,
			distance = 3
		}, {
			name = "attack"
		}, {
			name = "find_player",
			range = 15,
			failure = {
				{
					name = "randomize_destination"
				}
			}
		}
	}

	minetest.register_entity(name, {
		hp_max = def.hp,
		physical = true,
		collisionbox = def.collisionbox,
	 	visual = def.visual or "upright_sprite",
	 	visual_size = def.visual_size or {x=1, y=1},
		textures = def.textures,
		mesh = def.mesh or nil,
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = true,
		stepheight = def.stepheight or 1.1,
		speed = 0,
		anim = "",
		time = 0.0,
		destination = nil,

		on_punch = function(self, player)
			if self.object:get_hp() <= 0 then
				if player and player:is_player() then
					xp.add_xp(player, def.xp or xp.get_xp(def.lvl, 10))
					if math.random(0,10) == 5 then
						minetest.spawn_item(self.object:getpos(),"potions:upgrading")
					else
						if def.drops then
							minetest.spawn_item(self.object:getpos(), def.drops[math.random(1, #def.drops)])
						else
							minetest.spawn_item(self.object:getpos(), "money:silver_coin")
						end
					end
					mobs.count = mobs.count - 1
					self.object:remove()
				end
			end
		end,

		on_step = function(self, dtime)
			self.time = self.time + dtime
			if self.time > 1 then
				-- print("[mobs] -----------------")
				mobs.update_components(def.behaviour, self, def)
				self.time = 0
			end
		end,
	})

	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = "mobs_spawn.png",

		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return
			end
			local p = {x=pointed_thing.above.x, y=pointed_thing.above.y+2, z=pointed_thing.above.z}
			minetest.add_entity(p, name)
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
	})
end

function mobs.get_mob(lvl)
	local a = {}
	local found_mob = false
	for i,n in ipairs(mobs.mobs) do
		if n[2] < lvl +5 and n[2] > lvl-5 then
			found_mob = true
			a[#a+1] = n[1]
		end
	end

	if found_mob then
		return a[math.random(1, #a)]
	end

	a = {}
	found_mob = false
	for i,n in ipairs(mobs.mobs) do
		if n[2] < lvl +5 then
			found_mob = true
			a[#a+1] = n[1]
		end
	end

	if found_mob then
		return a[math.random(1, #a)]
	end

	return mobs.mobs[math.random(1, #mobs.mobs)][1]
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 10 then
		print("[mobs] mob count = " .. tostring(mobs.count))
		if mobs.count > (#minetest.get_connected_players())*2 then
			-- print("[mobs] canceled spawning")
			timer = 0
			return
		end

		for _, player in pairs(minetest.get_connected_players()) do
			local p = player:getpos()
			local a = {-1, 1}
			local x = math.random(20, 40)*a[math.random(1,2)] + p.x
			local z = math.random(20, 40)*a[math.random(1,2)] + p.z

			local nodes_under_air = minetest.find_nodes_in_area_under_air({x=x-10, y=p.y-20, z = p.z-10}, {x=x+10, y=p.y+20, z = p.z+10}, {"group:cracky", "group:crumbly", "group:choppy"})
			if #nodes_under_air > 0 then
				local spawn_pos = nodes_under_air[math.random(#nodes_under_air)]

				local spawn_mob = mobs.get_mob(xp.getLvl(player))
				minetest.add_entity(spawn_pos, spawn_mob)
				mobs.count = mobs.count +1
			end
		end
		timer = 0
	end
end)
