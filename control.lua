--equipment_hotkey

--control.lua

-- if script.active_mods["gvv"] then
-- require("__gvv__.gvv")()
-- end

--[[ 


	--   /c global.equipment_hotkey = nil
	--   /c game.print(global['equipment_hotkey'])

global.equipment_hotkey = {

			"1" : {
				armor: qqqqqq, 
				equipments: {table, "xxx"}, {table, "yyy"}, {table, "zzz"}
				buffer: {name=n, name=n, name=n}
				}
		}
	

]]

--@
local function print(s)
    local DEBUG = false

    if DEBUG then
        -- game.print(math.random(10000, 99999) .. " " .. s)
        game.print(s)
    end
end

--@
local function print_table(t, name)
    local function rnd()
        return math.random(10000, 99999)
    end
    local count = 0

    if name then
        game.print(rnd() .. "   " .. " ╒ " .. name:upper() .. ":")
    else
        game.print(rnd() .. "   " .. "╒ TABLE:")
    end
    for key, value in pairs(t) do
        game.print(
            rnd() ..
                "   " ..
                    "├ " ..
                        tostring(key) .. " [" .. type(key) .. "] : " .. tostring(value) .. " [" .. type(value) .. "]"
        )
        count = count + 1
    end
    game.print(rnd() .. "   ╘ count: " .. count)
end

--@
local function hotkey(s)
    return string.sub(s, -1)
end

local function save_equipment(event)
    -- SAVE_EQUIPMENT

    local player = game.get_player(event.player_index)

    print("save_equipment function:")

    -- key
    local key = hotkey(event.input_name)

    print("key:" .. key)

    -- armor
    local armor_slot = player.character.get_inventory(defines.inventory.character_armor)
    if armor_slot.is_empty() then
        player.print("armor_slot is_empty")
        return
    end
    active_armor = armor_slot[1]

    print("active_armor: " .. active_armor.name)

    if not (active_armor.grid and active_armor.grid.valid) then
        player.print("active_armor without grid")
        return
    end

    -- global
    if not global.equipment_hotkey then
        global.equipment_hotkey = {}
    end

    global.equipment_hotkey[key] = {}

    global.equipment_hotkey[key]["armor"] = active_armor.name
    global.equipment_hotkey[key]["contents"] = active_armor.grid.get_contents()

    -- equipments to global
    local _grid = {}
    for _, equip in pairs(active_armor.grid.equipment) do
        table.insert(_grid, {["name"] = equip.name, ["position"] = equip.position})
    end

    global.equipment_hotkey[key]["grid"] = _grid

    player.print("grid saved " .. key)
end

-- LOAD_EQUIPMENT
local function load_equipment(event)
    local player = game.get_player(event.player_index)

    print("load_equipment function:")

    -- key
    local key = hotkey(event.input_name)

    if not (global.equipment_hotkey and global.equipment_hotkey[key]) then
        player.print("no saved grid")
        return
    end

    -- armor
    local armor_slot = player.character.get_inventory(defines.inventory.character_armor)

    if armor_slot.is_empty() then
        player.print("armor_slot is_empty")
        return
    end

    active_armor = armor_slot[1]

    if active_armor.name ~= global.equipment_hotkey[key].armor then
        player.print("wrong armor")
        return
    end

    local player_inventory = player.get_main_inventory()

    -- PRELOAD_CHECK

    --[[  
	
	прелоад НОВЫЙ:
		создать виртуал
		грид плюсануть в виртуал
		сейв минусанть из виртуала
		чек места
		удалить виртуал
	
	-- если пустой сейв
	if next(global.equipment_hotkey[key]["buffer"]) == nil then
		print("save buffer empty")
	end
	
	
	]]
    print("PRELOAD_CHECK:")

    -- virtual_inventory
    virtual_inventory = game.create_inventory(#player_inventory + 50)
    for item, n in pairs(player_inventory.get_contents()) do
        virtual_inventory.insert({name = item, count = n})
    end

    -- grid in virtual
    for item, n in pairs(active_armor.grid.get_contents()) do
        virtual_inventory.insert({name = item, count = n})
    end

    -- save contents remove from virtual
    for item, n in pairs(global.equipment_hotkey[key]["contents"]) do
        virtual_inventory.remove({name = item, count = n})
    end

    --free space check
    virtual_inventory.sort_and_merge()

    print("player_inventory " .. #player_inventory)
    print("virtual пустые " .. virtual_inventory.count_empty_stacks()) -- пустые
    print("virtual занятые " .. #virtual_inventory - virtual_inventory.count_empty_stacks()) -- занятые

    space = #player_inventory - (#virtual_inventory - virtual_inventory.count_empty_stacks())
    print("space " .. space)

    virtual_inventory.destroy()

    if space < 0 then
        player.print("not enough inventory space")
        return
    end

    -- LOAD EQUIPMENT

    --[[ 
		лоад:
		грид аккумы в сейв
		грид в буфер, очистить грид
		сейв в грид (
			1 из буфера, 
			2 из инентаря
				список чего нехватает
			если аккум дать заряд
			)
		буфер остатки в инвентарь
	
	]]
    --@
    local function do_tables_match(a, b)
        return table.concat(a) == table.concat(b)
    end

    -- @
    local function coordinates_match(coord)
        if active_armor.grid.get(coord) and do_tables_match(coord, active_armor.grid.get(coord).position) then
            print("coordinates_match +")
            return true
        end
    end

    -- grid to save
    for n in ipairs(global.equipment_hotkey[key]["grid"]) do
        item_coord_table = global.equipment_hotkey[key]["grid"][n]["position"]
        item_name = global.equipment_hotkey[key]["grid"][n]["name"]

        -- battery-equipment energy
        if game.equipment_prototypes[item_name].type == "battery-equipment" and coordinates_match(item_coord_table) then
            global.equipment_hotkey[key]["grid"][n]["energy"] = active_armor.grid.get(item_coord_table).energy
        -- table.insert(global.equipment_hotkey[key]["grid"][n], active_armor.grid.get(item_coord_table).energy)
        end

        -- energy-shield-equipment shield
        if
            game.equipment_prototypes[item_name].type == "energy-shield-equipment" and
                coordinates_match(item_coord_table)
         then
            global.equipment_hotkey[key]["grid"][n]["shield"] = active_armor.grid.get(item_coord_table).shield
        -- table.insert(global.equipment_hotkey[key]["grid"][n], active_armor.grid.get(item_coord_table).energy)
        end
    end

    -- grid to buffer, clear grid
    buffer = active_armor.grid.take_all()

    -- save to grid
    --[[		сейв в грид (
			1 из буфера, 
			2 из инентаря
				список чего нехватает
			если аккум дать заряд   equipment_prototypes[item_name].type == "battery-equipment"
			)]]
    not_found_list = {}

    for n in ipairs(global.equipment_hotkey[key]["grid"]) do
        local item_coord_table = global.equipment_hotkey[key]["grid"][n]["position"]
        local item_name = global.equipment_hotkey[key]["grid"][n]["name"]

        local found = false

        -- search in buffer
        if not found and buffer and buffer[item_name] and buffer[item_name] > 0 then
            buffer[item_name] = buffer[item_name] - 1
            found = true
        end

        -- search in inv
        if not found and player_inventory.get_item_count(item_name) > 0 then
            player_inventory.remove({name = item_name, count = 1})
            found = true
        end

        -- put in grid
        if found then
            -- not_found
            active_armor.grid.put {name = item_name, position = item_coord_table}

            -- battery-equipment energy
            local item_energy = global.equipment_hotkey[key]["grid"][n]["energy"]

            if game.equipment_prototypes[item_name].type == "battery-equipment" and item_energy then
                active_armor.grid.get(item_coord_table).energy = item_energy
                global.equipment_hotkey[key]["grid"][n]["energy"] = nil
            end

            -- energy-shield-equipment shield
            local item_shield = global.equipment_hotkey[key]["grid"][n]["shield"]

            if game.equipment_prototypes[item_name].type == "energy-shield-equipment" and item_shield then
                active_armor.grid.get(item_coord_table).shield = item_shield
                global.equipment_hotkey[key]["grid"][n]["shield"] = nil
            end
        else
            if not_found_list[item_name] then
                not_found_list[item_name] = not_found_list[item_name] + 1
            else
                not_found_list[item_name] = 1
            end
        end
    end

    -- print not_found_list
    if next(not_found_list) then
        for item, n in pairs(not_found_list) do
            if n == 1 then
                player.print({"", "not found: ", game.equipment_prototypes[item].localised_name})
            else
                player.print({"", "not found: ", game.equipment_prototypes[item].localised_name, " - " .. n})
            end
        end
    end

    -- buffer to inventory
    for item, n in pairs(buffer) do
        if n > 0 then
            player_inventory.insert({name = item, count = n})
        end
    end

    buffer = nil

    player.print("grid loaded " .. key)
end

script.on_event(
    {"equipment_hotkey_save_1", "equipment_hotkey_save_2", "equipment_hotkey_save_3", "equipment_hotkey_save_4"},
    save_equipment
)
script.on_event(
    {"equipment_hotkey_load_1", "equipment_hotkey_load_2", "equipment_hotkey_load_3", "equipment_hotkey_load_4"},
    load_equipment
)
