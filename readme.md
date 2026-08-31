# Game contained entirely within a minecraft shader

A "but what if I...." idea I had that turned into a 50+ hour painful journey to rediscover rendering methods that were already solved more than 30 years ago, except all running in a fragment shader pipeline.

This mainly works via minecraft's ability to support "persistent render targets," which means that I can define a custom render target that a shader can write to/read from which doesn't affect the main game's rendering. Through this, I was able to create a sort of program memory page with a row/column addressing system, as long as I convert all the data types into colors and then back.

# Setup

NOTE: This game is **ONLY** fully tested on Minecraft Java version **26.3 Snapshot 3**.  
it **MAY** work on other versions, but if you encounter issues I will probably not be fixing them.

To set up, first download both the resource pack and the datapack from [the releases page](https://github.com/Pm7-dev/posteffect-game/releases). Apply the resource pack to your client ([tutorial](https://minecraft.wiki/w/Tutorial:Loading_a_resource_pack)), and add the datapack to a world with cheats enabled ([tutorial](https://minecraft.wiki/w/Tutorial:Importing_a_data_pack)).

To start the game, run the command `/function game:setup` while standing on the ground in a spot with at least three blocks of space around you on all sides. You should now see the starting spot and be able to control the game with your movement keys and space bar.

To exit the game, run the command `/function game:exit`

# Modding

Because everything is compiled when you load resource packs, modding this game is incredibly easy. Simply find the resource pack and extract it to a new folder in your resource packs folder, and load that pack instead of the zipped one. You can now modify whatever you want and load your changes by pressing f3 + t. I have left a simple modding guide in `assets > custom > textures > effect > game > CUSTOM_MAP_INFO.md`. Since maps are loaded from images, you don't even need to edit the code to make custom levels!
