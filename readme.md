# Game contained entirely within a Minecraft shader

A "but what if...." idea I had that turned into a 50+ hour journey to rediscover rendering techniques solved more than 30 years ago, all running in a Minecraft post-effect shader.

This is not a mod! This is made entirely in vanilla Minecraft using a resource pack and a datapack.

# Demonstration Video
[![Video that demonstrates the shader game](https://img.youtube.com/vi/IXZsasVcYCE/0.jpg)](https://www.youtube.com/watch?v=IXZsasVcYCE)
# Setup

NOTE: This uses niche resource pack features that are not officially "supported" by mojang. This game is **ONLY** fully tested on Minecraft Java version **26.3 Snapshot 3**. it **MAY** work on future versions, but if you encounter issues I will probably not be fixing them.

NOTE 2: This may not work on all GPUs. In development I came across a situation in which the code ran fine on my laptop's dedicated GPU but crashed on the integrated graphics. Everything works fine on all the GPUs I can test now, but please report an issue if your hardware does not work with this.

To set up, first download both the resource pack and the datapack from [the latest release](https://github.com/Pm7-dev/posteffect-game/releases/latest). Apply the resource pack to your client ([tutorial](https://minecraft.wiki/w/Tutorial:Loading_a_resource_pack)), and add the datapack to a world with cheats enabled ([tutorial](https://minecraft.wiki/w/Tutorial:Importing_a_data_pack)).

To start the game, run the command `/function game:setup` while standing on the ground in a spot with at least three blocks of space around you on all sides. You should now see the starting spot and be able to control the game with your movement keys and space bar.

**IMPORTANT:** Running the setup command will put you in spectator and mount you to an armor stand. If you press your crouch button you will dismount the armor stand and the game will break. If you accidentally do this, run `/function game:exit` to get your view back.

To exit the game, run the command `/function game:exit`

# How this works... mostly
This mainly works via Minecraft's ability to support "persistent render targets," which means that I can define a custom "image" beyond the main game's output that each rendering pass can write to/read from without the data being cleared between frames. Through this, I am able to store/modify data across multiple frames as long as I convert the data into colors, with the main caveat being that I can only update each pixel once per render pass. It's sorta like trying to build program memory in Conway's Game of Life, except each unit can store 32 bits of information, rather than just one.

# Modding

Because everything is compiled when you load resource packs, modding this game is incredibly easy. Simply find the resource pack and extract it to a new folder in your resource packs folder, and load that pack instead of the zipped one. You can now modify whatever you want and load your changes by pressing f3 + t. I have left a simple modding guide in `assets > custom > textures > effect > game > CUSTOM_MAP_INFO.md`. Since maps are loaded from images, you don't even need to edit the code to make custom levels!
