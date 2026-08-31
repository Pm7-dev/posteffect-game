# Here's how to create a custom level for this silly game!!  

Open up the map.png in the image editor of your choosing, preferably use an image editor that lets you edit the alpha channel of colors you place on a scale of 0-255. I personally used Pinta for this, but Paint.net, Krita, Gimp, etc. should all be fine for this purpose.

Colors with an alpha of 255 are considered walls. There are only four defined walls by default: Brick, Wood, Stone, and Dirt. These each have a specific RGB value they are attached to, and the textures can be found/edited in the wall_atlas.png. The RGB values used are as follows:

- (127, 42, 33, 255)  [7F2A21FF]  Brick

- (85, 35, 17, 255)    [552311FF]  Wood
- (134, 136, 136, 255)  [868888FF]  Stone
- (107, 76, 62, 255)  [6B4C3EFF]  Brick
-
There is also the color (255, 255, 0, 255) [FFFF00FF] used to denote the winning wall. When the player touches a wall of this color the game will end and they will be shown the win screen. Additionally, there is a secret ending wall denoted by the color (250, 255, 0, 255) [FAFF00FF] which functions exactly the same but shows the secret ending screen instead. 

Any other color with opacity 255 will be considered a Door. Doors use the last texture in the bottom right of the wall_atlas.png, and are hue shifted to match the color that you placed down. This means that you should try to use visually distinct, high-saturation colors for doors.

Any pixel with 150 opacity will be loaded as a key pickup. The key texture can be found/edited in key_atlas.png, and is also hue shifted to match the pixel you placed. Doors can be unlocked when a player interacts with it while holding a key of matching rgb color. Try not to place too many of these, as it may cause lag.

The player spawn point is determined by a singular black pixel with opacity 200 [000000C8]. Do not place multiple of these pixels. I believe it will just load the first.

Enemies are represented by red pixels at opacity 100 [FF000064].

To change global game data, look in `assets > custom > shaders > include > game_globals.glsl`. There, you'll find values you can change to make the map work however you'd like.

overlay.png was going to contain more things like a label for the health bar but I decided against it. Now it just has the crosshair. It's overlayed on top of the game in the render_gui pass.

win_screen.png and lose_screen.png are pretty self explanatory, change them if you want.

enemy.png is Mumuy, change it if you ~~hate cats~~ have a reason
## Modifying more things

If you'd like to modify things outside of what I've already described, your life is going to suck.

I'd like to point you towards `assets > custom > shaders > include > data_storage.glsl` lines 38-ish if you're looking to add more wall types, but you'll also have to modify  the `getTextureOffset` method in `render_map.fsh` in order to make the texture offset read your new texture when it encounters the new rgb value.

As for anything else, I'd suggest just looking through `assets > custom > post_effect > game.json` to see the data and render pipeline so you can understand the inner workings of the game. An understanding of opengl graphics and the minecraft shader code would be helpful, but honestly just screw around with stuff and see what you can do. That's how I got into this mess, anyway.

oki byeee :3