codeblock = {}

codeblock.modpath = minetest.get_modpath("codeblock")
codeblock.datapath = minetest.get_worldpath() .. "/lua_files/"

if not minetest.mkdir(codeblock.datapath) then
    error("[editor] failed to create directory!")
end

---------------------------------- 1:limited 2:standard 3:privileged 4:trusted
codeblock.auth_levels =           {1,       2,       3,       4} 
codeblock.max_calls =             {1e6,     1e7,     1e8,     1e9}
codeblock.max_volume =            {1e5,     1e6,     1e7,     1e8}
codeblock.max_commands =          {1e4,     1e5,     1e6,     1e7}
codeblock.max_distance =          {150 ^ 2, 300 ^ 2, 700 ^ 2, 1500 ^ 2}
codeblock.max_dimension =         {15,      30,      70,      150}
codeblock.commands_before_yield = {1,       10,      20,      40}
codeblock.default_auth_level = 1

codeblock.S = minetest.get_translator("codeblock")

dofile(codeblock.modpath .. "/utils.lua")
dofile(codeblock.modpath .. "/commands.lua")
dofile(codeblock.modpath .. "/sandbox.lua")
--
dofile(codeblock.modpath .. "/drone.lua")
dofile(codeblock.modpath .. "/drone_entity.lua")
dofile(codeblock.modpath .. "/register.lua")
dofile(codeblock.modpath .. "/formspecs.lua")
dofile(codeblock.modpath .. "/examples.lua")
--
dofile(codeblock.modpath .. "/filesystem.lua")
dofile(codeblock.modpath .. "/editor.lua")
