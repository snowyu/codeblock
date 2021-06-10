codeblock.sandbox = {}

local S = codeblock.S

function codeblock.sandbox.run_safe(name, file)

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
        move = function(x, y, z)
            codeblock.commands.drone_move(name, x, y, z)
            return
        end,
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
        turn = function(quarters)
            codeblock.commands.drone_turn(name, quarters)
            return
        end,
        place = function(block)
            codeblock.commands.drone_place_block(name, block)
            return
        end,
        place_relative = function(x, y, z, block, label)
            codeblock.commands.drone_place_relative(name, x, y, z, block, label)
        end,
        save = function(label)
            codeblock.commands.drone_save_checkpoint(name, label)
        end,
        go = function(label)
            codeblock.commands.drone_goto_checkpoint(name, label)
        end,
        cube = function(w, h, l, block, hollow)
            codeblock.commands.drone_place_cube(name, w, h, l, block, hollow)
        end,
        sphere = function(r, block, hollow)
            codeblock.commands.drone_place_sphere(name, r, block, hollow)
        end,
        cylinder = function(a, l, r, block, hollow)
            codeblock.commands
                .drone_place_cylinder(name, a, l, r, block, hollow)
        end,
        blocks = codeblock.sandbox.cubes_names,
        plants = codeblock.sandbox.plants_names,
        wools = codeblock.sandbox.wools_names,
        iwools = codeblock.sandbox.iwools_names,
        ipairs = ipairs,
        pairs = pairs,
        random = function(a, b)
            if not a and not b then
                return math.random()
            elseif not a or not b then
                return math.random(a or b)
            else
                return math.random(a, b)
            end
        end,
        floor = function(x) return math.floor(x) end,
        ceil = function(x) return math.ceil(x) end,
        deg = function(x) return math.deg(x) end,
        rad = function(x) return math.rad(x) end,
        exp = function(x) return math.exp(x) end,
        log = function(x) return math.log(x) end,
        max = function(x, ...) return math.max(x, ...) end,
        min = function(x, ...) return math.min(x, ...) end,
        pow = function(x, y) return math.pow(x, y) end,
        sqrt = function(x) return math.sqrt(x) end,
        abs = function(x) return math.abs(x) end,
        sin = function(x) return math.sin(x) end,
        cos = function(x) return math.cos(x) end,
        tan = function(x) return math.tan(x) end,
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

    math.randomseed(minetest.get_us_time())
    local status, err = pcall(untrusted_function)

    if not status then
        minetest.chat_send_player(name, S("Error in @1", file))
        minetest.chat_send_player(name, err)
        return
    end

end

--
-- Allowed blocks
--

codeblock.sandbox.blocks = {
    air = 'air',
    stone = 'default:stone',
    cobble = 'default:cobble',
    stonebrick = 'default:stonebrick',
    stone_block = 'default:stone_block',
    mossycobble = 'default:mossycobble',
    desert_stone = 'default:desert_stone',
    desert_cobble = 'default:desert_cobble',
    desert_stonebrick = 'default:desert_stonebrick',
    desert_stone_block = 'default:desert_stone_block',
    sandstone = 'default:sandstone',
    sandstonebrick = 'default:sandstonebrick',
    sandstone_block = 'default:sandstone_block',
    desert_sandstone = 'default:desert_sandstone',
    desert_sandstone_brick = 'default:desert_sandstone_brick',
    desert_sandstone_block = 'default:desert_sandstone_block',
    silver_sandstone = 'default:silver_sandstone',
    silver_sandstone_brick = 'default:silver_sandstone_brick',
    silver_sandstone_block = 'default:silver_sandstone_block',
    obsidian = 'default:obsidian',
    obsidianbrick = 'default:obsidianbrick',
    obsidian_block = 'default:obsidian_block',
    dirt = 'default:dirt',
    dirt_with_grass = 'default:dirt_with_grass',
    dirt_with_grass_footsteps = 'default:dirt_with_grass_footsteps',
    dirt_with_dry_grass = 'default:dirt_with_dry_grass',
    dirt_with_snow = 'default:dirt_with_snow',
    dirt_with_rainforest_litter = 'default:dirt_with_rainforest_litter',
    dirt_with_coniferous_litter = 'default:dirt_with_coniferous_litter',
    dry_dirt = 'default:dry_dirt',
    dry_dirt_with_dry_grass = 'default:dry_dirt_with_dry_grass',
    permafrost = 'default:permafrost',
    permafrost_with_stones = 'default:permafrost_with_stones',
    permafrost_with_moss = 'default:permafrost_with_moss',
    clay = 'default:clay',
    snowblock = 'default:snowblock',
    ice = 'default:ice',
    cave_ice = 'default:cave_ice',
    tree = 'default:tree',
    wood = 'default:wood',
    leaves = 'default:leaves',
    jungletree = 'default:jungletree',
    junglewood = 'default:junglewood',
    jungleleaves = 'default:jungleleaves',
    pine_tree = 'default:pine_tree',
    pine_wood = 'default:pine_wood',
    pine_needles = 'default:pine_needles',
    acacia_tree = 'default:acacia_tree',
    acacia_wood = 'default:acacia_wood',
    acacia_leaves = 'default:acacia_leaves',
    aspen_tree = 'default:aspen_tree',
    aspen_wood = 'default:aspen_wood',
    aspen_leaves = 'default:aspen_leaves',
    stone_with_coal = 'default:stone_with_coal',
    coalblock = 'default:coalblock',
    stone_with_iron = 'default:stone_with_iron',
    steelblock = 'default:steelblock',
    stone_with_copper = 'default:stone_with_copper',
    copperblock = 'default:copperblock',
    stone_with_tin = 'default:stone_with_tin',
    tinblock = 'default:tinblock',
    bronzeblock = 'default:bronzeblock',
    stone_with_gold = 'default:stone_with_gold',
    goldblock = 'default:goldblock',
    stone_with_mese = 'default:stone_with_mese',
    mese = 'default:mese',
    stone_with_diamond = 'default:stone_with_diamond',
    diamondblock = 'default:diamondblock',
    cactus = 'default:cactus',
    bush_leaves = 'default:bush_leaves',
    acacia_bush_leaves = 'default:acacia_bush_leaves',
    pine_bush_needles = 'default:pine_bush_needles',
    bookshelf = 'default:bookshelf',
    glass = 'default:glass',
    obsidian_glass = 'default:obsidian_glass',
    brick = 'default:brick',
    meselamp = 'default:meselamp',
    sapling = 'default:sapling',
    apple = 'default:apple',
    junglesapling = 'default:junglesapling',
    emergent_jungle_sapling = 'default:emergent_jungle_sapling',
    pine_sapling = 'default:pine_sapling',
    acacia_sapling = 'default:acacia_sapling',
    aspen_sapling = 'default:aspen_sapling',
    large_cactus_seedling = 'default:large_cactus_seedling',
    dry_shrub = 'default:dry_shrub',
    junglegrass = 'default:junglegrass',
    grass_1 = 'default:grass_1',
    grass_2 = 'default:grass_2',
    grass_3 = 'default:grass_3',
    grass_4 = 'default:grass_4',
    grass_5 = 'default:grass_5',
    dry_grass_1 = 'default:dry_grass_1',
    dry_grass_2 = 'default:dry_grass_2',
    dry_grass_3 = 'default:dry_grass_3',
    dry_grass_4 = 'default:dry_grass_4',
    dry_grass_5 = 'default:dry_grass_5',
    fern_1 = 'default:fern_1',
    fern_2 = 'default:fern_2',
    fern_3 = 'default:fern_3',
    marram_grass_1 = 'default:marram_grass_1',
    marram_grass_2 = 'default:marram_grass_2',
    marram_grass_3 = 'default:marram_grass_3',
    bush_stem = 'default:bush_stem',
    bush_sapling = 'default:bush_sapling',
    acacia_bush_stem = 'default:acacia_bush_stem',
    acacia_bush_sapling = 'default:acacia_bush_sapling',
    pine_bush_stem = 'default:pine_bush_stem',
    pine_bush_sapling = 'default:pine_bush_sapling',
    wool_white = 'wool:white',
    wool_grey = 'wool:grey',
    wool_dark_grey = 'wool:dark_grey',
    wool_black = 'wool:black',
    wool_violet = 'wool:violet',
    wool_blue = 'wool:blue',
    wool_cyan = 'wool:cyan',
    wool_dark_green = 'wool:dark_green',
    wool_green = 'wool:green',
    wool_yellow = 'wool:yellow',
    wool_brown = 'wool:brown',
    wool_orange = 'wool:orange',
    wool_red = 'wool:red',
    wool_magenta = 'wool:magenta',
    wool_pink = 'wool:pink'
}

codeblock.sandbox.cubes_names = {
    air = 'air',
    stone = 'stone',
    cobble = 'cobble',
    stonebrick = 'stonebrick',
    stone_block = 'stone_block',
    mossycobble = 'mossycobble',
    desert_stone = 'desert_stone',
    desert_cobble = 'desert_cobble',
    desert_stonebrick = 'desert_stonebrick',
    desert_stone_block = 'desert_stone_block',
    sandstone = 'sandstone',
    sandstonebrick = 'sandstonebrick',
    sandstone_block = 'sandstone_block',
    desert_sandstone = 'desert_sandstone',
    desert_sandstone_brick = 'desert_sandstone_brick',
    desert_sandstone_block = 'desert_sandstone_block',
    silver_sandstone = 'silver_sandstone',
    silver_sandstone_brick = 'silver_sandstone_brick',
    silver_sandstone_block = 'silver_sandstone_block',
    obsidian = 'obsidian',
    obsidianbrick = 'obsidianbrick',
    obsidian_block = 'obsidian_block',
    dirt = 'dirt',
    dirt_with_grass = 'dirt_with_grass',
    dirt_with_grass_footsteps = 'dirt_with_grass_footsteps',
    dirt_with_dry_grass = 'dirt_with_dry_grass',
    dirt_with_snow = 'dirt_with_snow',
    dirt_with_rainforest_litter = 'dirt_with_rainforest_litter',
    dirt_with_coniferous_litter = 'dirt_with_coniferous_litter',
    dry_dirt = 'dry_dirt',
    dry_dirt_with_dry_grass = 'dry_dirt_with_dry_grass',
    permafrost = 'permafrost',
    permafrost_with_stones = 'permafrost_with_stones',
    permafrost_with_moss = 'permafrost_with_moss',
    clay = 'clay',
    snowblock = 'snowblock',
    ice = 'ice',
    cave_ice = 'cave_ice',
    tree = 'tree',
    wood = 'wood',
    leaves = 'leaves',
    jungletree = 'jungletree',
    junglewood = 'junglewood',
    jungleleaves = 'jungleleaves',
    pine_tree = 'pine_tree',
    pine_wood = 'pine_wood',
    pine_needles = 'pine_needles',
    acacia_tree = 'acacia_tree',
    acacia_wood = 'acacia_wood',
    acacia_leaves = 'acacia_leaves',
    aspen_tree = 'aspen_tree',
    aspen_wood = 'aspen_wood',
    aspen_leaves = 'aspen_leaves',
    stone_with_coal = 'stone_with_coal',
    coalblock = 'coalblock',
    stone_with_iron = 'stone_with_iron',
    steelblock = 'steelblock',
    stone_with_copper = 'stone_with_copper',
    copperblock = 'copperblock',
    stone_with_tin = 'stone_with_tin',
    tinblock = 'tinblock',
    bronzeblock = 'bronzeblock',
    stone_with_gold = 'stone_with_gold',
    goldblock = 'goldblock',
    stone_with_mese = 'stone_with_mese',
    mese = 'mese',
    stone_with_diamond = 'stone_with_diamond',
    diamondblock = 'diamondblock',
    cactus = 'cactus',
    bush_leaves = 'bush_leaves',
    acacia_bush_leaves = 'acacia_bush_leaves',
    pine_bush_needles = 'pine_bush_needles',
    bookshelf = 'bookshelf',
    glass = 'glass',
    obsidian_glass = 'obsidian_glass',
    brick = 'brick',
    meselamp = 'meselamp'
}

codeblock.sandbox.plants_names = {
    sapling = 'sapling',
    apple = 'apple',
    junglesapling = 'junglesapling',
    emergent_jungle_sapling = 'emergent_jungle_sapling',
    pine_sapling = 'pine_sapling',
    acacia_sapling = 'acacia_sapling',
    aspen_sapling = 'aspen_sapling',
    large_cactus_seedling = 'large_cactus_seedling',
    dry_shrub = 'dry_shrub',
    grass_1 = 'grass_1',
    grass_2 = 'grass_2',
    grass_3 = 'grass_3',
    grass_4 = 'grass_4',
    grass_5 = 'grass_5',
    dry_grass_1 = 'dry_grass_1',
    dry_grass_2 = 'dry_grass_2',
    dry_grass_3 = 'dry_grass_3',
    dry_grass_4 = 'dry_grass_4',
    dry_grass_5 = 'dry_grass_5',
    fern_1 = 'fern_1',
    fern_2 = 'fern_2',
    fern_3 = 'fern_3',
    marram_grass_1 = 'marram_grass_1',
    marram_grass_2 = 'marram_grass_2',
    marram_grass_3 = 'marram_grass_3',
    bush_stem = 'bush_stem',
    bush_sapling = 'bush_sapling',
    acacia_bush_stem = 'acacia_bush_stem',
    acacia_bush_sapling = 'acacia_bush_sapling',
    pine_bush_stem = 'pine_bush_stem',
    pine_bush_needles = 'pine_bush_needles',
    pine_bush_sapling = 'pine_bush_sapling'
}

codeblock.sandbox.wools_names = {
    white = 'wool_white',
    grey = 'wool_grey',
    dark_grey = 'wool_dark_grey',
    black = 'wool_black',
    violet = 'wool_violet',
    blue = 'wool_blue',
    cyan = 'wool_cyan',
    dark_green = 'wool_dark_green',
    green = 'wool_green',
    yellow = 'wool_yellow',
    brown = 'wool_brown',
    orange = 'wool_orange',
    red = 'wool_red',
    magenta = 'wool_magenta',
    pink = 'wool_pink'
}

codeblock.sandbox.iwools_names = {
    'wool_magenta', 'wool_red', 'wool_pink', 'wool_brown', 'wool_orange',
    'wool_yellow', 'wool_green', 'wool_dark_green', 'wool_cyan', 'wool_blue',
    'wool_violet'
}
