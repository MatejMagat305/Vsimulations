
typedef struct Planet {
    double3 position; // position of the planet in all three directions
    double3 velocity; // velocity of the planet in all three directions
    double3 acceleration; // acceleration of the planet in all three directions
    double radius; // radius of the planet
    double density; // density of the planet
    double mass; // mass of the planet
} ;

__kernel void updatePlanet(__global Planet* planet, __global const double3 dt_G_planetCount) {
    int i = get_global_id(0);
    double3 position = planet[i].position;
    double3 velocity = planet[i].velocity;
    double3 acceleration = 0;

    for(int j = 0; j < (int)dt_G_planetCount[2]; j++) {
        if (i == j) {
            continue;
        }
        double3 direction = planet[j].position - position;
        double distance = length(direction);
        if (distance < planet.radius + other_planet.radius + 0.07 + 0.001*density) {
            continue;
        }
        double force = dt_G_planetCount[1] * planet[i].mass * planet[j].mass / (distance * distance + 1e-8);
        acceleration += direction * (force / (planet[i].mass + 1e-8));
    }

    velocity += acceleration * dt_G_planetCount[0];
    position += velocity * dt_G_planetCount[0];
    planet[i].velocity = velocity;
    planet[i].position = position;
}
