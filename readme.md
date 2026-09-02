# Game contained entirely within a Minecraft shader

A "but what if...." idea I had that turned into a 50+ hour journey to rediscover rendering techniques solved more than 30 years ago, all running in a Minecraft post-effect shader.

This is not a mod! This is made entirely in vanilla Minecraft using a resource pack and a datapack.

# Demonstration Video
[![Video that demonstrates the shader game](https://img.youtube.com/vi/IXZsasVcYCE/0.jpg)](https://www.youtube.com/watch?v=IXZsasVcYCE)
# Setup

NOTE: This uses niche resource pack features that are not officially "supported" by mojang. This game is **ONLY** fully tested on Minecraft Java version **26.3 Snapshot 3**. it **MAY** work on future versions, but if you encounter issues I will probably not be fixing them.

NOTE 2: This may not work on all GPUs. In development I came across a situation in which the code ran fine on my laptop's dedicated GPU but crashed on the integrated graphics. Everything works fine on all the GPUs I can test now, but please report an issue if your hardware does not work with this.

Setup instructions:  
- Go to [the latest release](https://github.com/Pm7-dev/posteffect-game/releases/latest) 
- Download both the `controller-datapack.zip` AND `posteffect-game.zip`
- Create an instance of 26.3 Snapshot 3 in the launcher of your choice.
- Add the `posteffect-game.zip` into your resource packs folder and enable it. ([tutorial](https://minecraft.wiki/w/Tutorial:Loading_a_resource_pack))
- Add the `controller-datapack.zip` datapack to a world with cheats enabled ([tutorial](https://minecraft.wiki/w/Tutorial:Importing_a_data_pack)).

To start the game, run the command `/function game:setup` while standing on the ground in a spot with at least three blocks of space around you on all sides. You should now see the starting spot and be able to control the game with your movement keys and space bar.

**IMPORTANT:** Running the setup command will put you in spectator and mount you to an armor stand. If you press your crouch button you will dismount the armor stand and the game will break. If you accidentally do this, run `/function game:exit` to get your view back.

To exit the game, run the command `/function game:exit

# Issues you may encounter:

If you're encountering setup issues, This guide may be able to help!

**The command output of `/function game:setup` is an error:** Make sure you have the datapack installed on the world. You can check this by running `/datapack list` and seeing if the `controller-datapack.zip` shows up in green brackets.

**I ran the command, and now there's just some red squares on my screen:** Make sure you not only put the resource pack in your resource packs folder, but also have it enabled. You can check this by pressing escape, selecting "Options," and then "Resource Packs." `posteffect-game.zip` should be on the **Selected** side of the screen and above any other resource packs. Use the arrows on the pack to make sure this is true. You may need to run `/function game:exit` and `/function game:setup`again if you had to make changes here

**Every time I apply the resource pack, I get a toast that says Resource Reload Failed:** This is actually a bug. Please report this to me either through the issues page here or however other way of contact you have with me. Be sure to send your launcher's log if you can! That contains vital information about what exactly broke.

**At some point I stopped being able to use a specific input:** Ok this is gonna sound really stupid but it probably started raining in-game. Set the weather to clear using `/weather clear` and disable weather with `/gamerule advance_weather false`. The game input works by reading the colors on the screen, and rain interferes with this.

# How this works... mostly
This mainly works via Minecraft's ability to support "persistent render targets," which means that I can define a custom "image" beyond the main game's output that each rendering pass can write to/read from without the data being cleared between frames. Through this, I am able to store/modify data across multiple frames as long as I convert the data into colors, with the main caveat being that I can only update each pixel once per render pass. It's sorta like trying to build program memory in Conway's Game of Life, except each unit can store 32 bits of information, rather than just one.

The data types I created for this are floats and mapcoords. Floats are 32 bit floating point numbers, while mapcoords are 2d ivec2 types with 16 bits to store each axis. I also used mapcoords to create a very cursed version of a pointer, but the two are functionally the same.

Similar to old 3d games like Wolfenstein 3D, this game sends one raycast per vertical column of pixels and stores the result of it in memory. The render passes then look at this raycast data and decide what to render (what part of the wall texture to render, how tall to make the wall based on how far away it is, the fog, etc.)

# Modding

Because everything is compiled when you load resource packs, modding this game is incredibly easy. Simply find the resource pack and extract it to a new folder in your resource packs folder, and load that pack instead of the zipped one. You can now modify whatever you want and load your changes by pressing f3 + t. I have left a simple modding guide in `assets > custom > textures > effect > game > CUSTOM_MAP_INFO.md`. Since maps are loaded from images, you don't even need to edit the code to make custom levels!
