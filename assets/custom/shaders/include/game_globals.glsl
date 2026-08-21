#version 330

#define MAP_SIZE 256
#define MEMORY_PAGE_SIZE 512

#define SCREEN_WIDTH 1920.0

#define FOV 60.0 // degrees

#define MOVE_SPEED 5.0 // meters/second
#define ROT_SPEED 180.0 // degrees/second

#define MAX_SIGHT 12 // meters
#define REACH 2.25 // meters, for opening doors

#define PI 3.14159265

#define HITBOX_RADIUS 0.2 // meters, for wall collision
#define PICKUP_RADIUS 0.4 // meters, for picking up keys

#define INVENTORY_SPACE 10 // don't go past like.... 100?

