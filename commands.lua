codeblock.commands = {}

local S = default.get_translator

function codeblock.commands.add_drone(pos, dir, name, file)
    local drone = codeblock.Drone:new(pos, dir, name, file) -- TODO: Change this later
    codeblock.drones[name] = drone

    local drone_entity = minetest.add_entity(pos, "codeblock:drone", nil)
    drone_entity:set_rotation({x = 0, y = dir, z = 0})
    drone_entity:get_luaentity():set_drone_owner(name)

    codeblock.drone_entities[name] = drone_entity

    return drone
end

function codeblock.commands.remove_drone(name)

    local drone_entity = codeblock.drone_entities[name];
    drone_entity:remove()
    codeblock.drones[name] = nil;
    codeblock.drone_entities[name] = nil;

end

function codeblock.commands.test_sequence(name)

    for l = 1, 10 do
        for k = 1, 5 do
            for j = 1, 4 do
                for i = 1, 10 do
                    codeblock.commands.drone_forward(name, 1)
                    codeblock.commands.drone_place_block(name, "default:stone")
                end
                codeblock.commands.drone_turn_right(name)
            end
            codeblock.commands.drone_up(name, 1)
        end
        codeblock.commands.drone_right(name, 1)
        codeblock.commands.drone_back(name, 1)
    end
end

function codeblock.commands.drone_forward(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.z = drone.z + n
    elseif angle == 1 then
        drone.x = drone.x - n
    elseif angle == 2 then
        drone.z = drone.z - n
    elseif angle == 3 then
        drone.x = drone.x + n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_right(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.x = drone.x + n
    elseif angle == 1 then
        drone.z = drone.z + n
    elseif angle == 2 then
        drone.x = drone.x - n
    elseif angle == 3 then
        drone.z = drone.z - n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_left(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.x = drone.x - n
    elseif angle == 1 then
        drone.z = drone.z - n
    elseif angle == 2 then
        drone.x = drone.x + n
    elseif angle == 3 then
        drone.z = drone.z + n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_back(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local angle = drone.dir / math.pi * 2

    if angle == 0 then
        drone.z = drone.z - n
    elseif angle == 1 then
        drone.x = drone.x + n
    elseif angle == 2 then
        drone.z = drone.z + n
    elseif angle == 3 then
        drone.x = drone.x - n
    end

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_up(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.y = drone.y + n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_down(name, n)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.y = drone.y - n

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_left(name)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.dir = (drone.dir + math.pi / 2) % (2 * math.pi)

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_turn_right(name)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    drone.dir = (drone.dir - math.pi / 2) % (2 * math.pi)

    codeblock.events.handle_update_drone_entity(drone)

end

function codeblock.commands.drone_place_block(name, block_identifier)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    local real_block_name = codeblock.Drone.blocks[block_identifier]

    if not real_block_name then
        minetest.chat_send_player(name, S('block not allowed'))
        return
    end

    codeblock.events.handle_place_block({x = drone.x, y = drone.y, z = drone.z},
                                        real_block_name)

end

function codeblock.commands.drone_save_checkpoint(name, label)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    if not label then
        minetest.chat_send_player(name, S("no checkpoint name"))
    end

    drone.checkpoints[label] = {x = drone.x, y = drone.y, z = drone.z}

end

function codeblock.commands.drone_goto_checkpoint(name, label)

    local drone = codeblock.drones[name]
    if not drone then
        minetest.chat_send_player(name, S("drone does not exist"))
    end

    if not label or not drone.checkpoints[label] then
        minetest.chat_send_player(name, S("no checkpoint @1", label or ""))
    end

    local cp = drone.checkpoints[label]
    drone.x = cp.x
    drone.y = cp.y
    drone.z = cp.z

    codeblock.events.handle_update_drone_entity(drone)

end

--
-- 

function codeblock.commands.run_safe(name, file)

    if not file then
        minetest.chat_send_player(name, S("Empty drone file"))
        return
    end

    local path = codeblock.datapath .. name .. '/' .. file
    local untrusted_code = codeblock.filesystem.read(path)

    if not untrusted_code then
        minetest.chat_send_player(name, S('@1 not found', file))
        return
    end

    local command_env = {
        forward = function(n)
            codeblock.commands.drone_forward(name, n)
            return
        end,
        back = function(n)
            codeblock.commands.drone_back(name, n)
            return
        end,
        left = function(n)
            codeblock.commands.drone_left(name, n)
            return
        end,
        right = function(n)
            codeblock.commands.drone_right(name, n)
            return
        end,
        up = function(n)
            codeblock.commands.drone_up(name, n)
            return
        end,
        down = function(n)
            codeblock.commands.drone_down(name, n)
            return
        end,
        turn_left = function()
            codeblock.commands.drone_turn_left(name)
            return
        end,
        turn_right = function()
            codeblock.commands.drone_turn_right(name)
            return
        end,
        place = function(block)
            codeblock.commands.drone_place_block(name, block)
            return
        end,
        save = function(label)
            codeblock.commands.drone_save_checkpoint(name, label)
        end,
        go = function(label)
            codeblock.commands.drone_goto_checkpoint(name, label)
        end,
        blocks = codeblock.Drone.cubes_names,
        plants = codeblock.Drone.plants_names,
        wools = codeblock.Drone.wools_names,
        ipairs = ipairs,
        pairs = pairs,
        floor = function(x) return math.floor(x) end,
        sin = function(x) return math.sin(x) end,
        cos = function(x) return math.cos(x) end,
        pi = math.pi,
        print = function(msg)
            minetest.chat_send_player(name, '> ' .. tostring(msg))
            return
        end
    }

    if untrusted_code:byte(1) == 27 then
        minetest.chat_send_player(name, S("Error in @1", file) ..
                                      S("binary bytecode prohibited"))
    end

    local untrusted_function, message = loadstring(untrusted_code)
    if not untrusted_function then
        minetest.chat_send_player(name, S("Error in @1", file))
        minetest.chat_send_player(name, message)
        return
    end

    setfenv(untrusted_function, command_env)

    local status, err = pcall(untrusted_function)

    if not status then
        minetest.chat_send_player(name, S("Error in @1", file))
        minetest.chat_send_player(name, err)
        return
    end

end
