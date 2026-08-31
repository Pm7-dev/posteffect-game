#version 330

// Don't change these unless you have a realllllly good reason
#define MAP_SIZE 256
#define MEMORY_PAGE_SIZE 512

// Changing this one might break something, idk I never tried it. It *should* only affect the number of raycasts sent per frame.
#define SCREEN_WIDTH 1920.0

#define FOV 70. // degrees

#define MOVE_SPEED 5.0 // meters/second
#define ROT_SPEED 180.0 // degrees/second

#define MAX_SIGHT 12 // meters
#define REACH 2. // meters, for opening doors

// Idk why you'd change this
#define PI 3.14159265

#define HITBOX_RADIUS 0.2 // meters, for wall collision
#define PICKUP_RADIUS 0.4 // meters, for picking up keys
#define DAMAGE_RADIUS 0.4 // meters for enemy damage

#define INVENTORY_SPACE 10 // don't go past like.... 100?

#define ENEMY_SIGHT 8.
#define ENEMY_SPEED 1.9
#define ENEMY_DAMAGE 24. // damager per damage tick
#define DAMAGE_DEBOUNCE 0.4 // seconds of invincibility after attack