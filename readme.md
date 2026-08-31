# Game contained entirely within a minecraft shader

A "but what if I...." idea I had that turned into a 50+ hour painful journey to rediscover rendering methods that were already solved more than 30 years ago, except all running in a fragment shader pipeline.

This mainly works via minecraft's ability to support "persistent render targets," which means that I can define a custom render target that a shader can write to/read from which doesn't affect the main game's rendering. Through this, I was able to create a sort of program memory page with a row/column addressing system, as long as I convert all the data types into colors and then back.

# Setup

To set up, first download the .... wait I should make the release first....