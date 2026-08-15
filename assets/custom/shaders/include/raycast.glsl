#version 330

#moj_import <custom:game_globals.glsl>


struct raycast {
    bool hit;
    vec2 position;
    ivec2 mapPosition;
    vec4 color;
};

raycast sendRay(vec2 origin, float rotation, sampler2D DataSampler, float maxSight) {
    float eps = 1e-6;
    
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
    bool hit = false;
    vec2 pos = origin;

    ivec2 mapPos = ivec2(int(pos.x), int(pos.y));
    vec2 rotVec = vec2(cos(rotation), sin(rotation));
    ivec2 stepDir = ivec2(sign(rotVec.x), sign(rotVec.y));

    float traveled = 0.0;
    while (true) { // scary
        vec2 distToNext = vec2(0.0, 0.0);
        float denomX = max(abs(rotVec.x), eps);
        float denomY = max(abs(rotVec.y), eps);

        if(stepDir.x > 0) {
            distToNext.x = mapPos.x + 1 - pos.x;
        } else {
            distToNext.x = pos.x - mapPos.x;
        }
        if(stepDir.y > 0) {
            distToNext.y = mapPos.y + 1 - pos.y;
        } else {
            distToNext.y = pos.y - mapPos.y;
        }

        // Compute actual travel distance along the ray (t) for the next grid crossing.
        float tx = max(distToNext.x / denomX, eps);
        float ty = max(distToNext.y / denomY, eps);
        if(tx < ty) {
            pos += rotVec * tx;
            mapPos.x += stepDir.x;
            traveled += tx;
        } else {
            pos += rotVec * ty;
            mapPos.y += stepDir.y;
            traveled += ty;
        }


        if(mapPos.x < 0 || mapPos.x >= MAP_SIZE || mapPos.y < 0 || mapPos.y >= MAP_SIZE) {
            hit = false;
            color = vec4(0.0, 0.0, 0.0, 0.0);
            break;
        }

        // Exit if traveled distance exceeds max sight
        if(traveled > maxSight) {
            break;
        }

        ivec2 translated = translateMapCoordToDataCoord(mapPos);
        color = getData(DataSampler, translated.y, translated.x);
        ivec4 icolor = getIntegerColor(color);
        if(icolor.a == WALL_DOOR.a) { // hit a wall or door
            hit = true;
            break;
        }
    }

    return raycast(hit, pos, mapPos, color);
}