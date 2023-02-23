typedef struct Planet {
    double3 position; // position of the planet in all three directions
    double3 velocity; // velocity of the planet in all three directions
    double3 acceleration; // acceleration of the planet in all three directions
    double radius; // radius of the planet
    double density; // density of the planet
    double mass; // mass of the planet
} Planet;

__kernel void updatePlanet(__global const Planet* inputPlanets, __global Planet* outputPlanets, const double3 dt_G_planetCount) {
    int i = get_global_id(0);
    double3 position_i = inputPlanets[i].position;
    double3 velocity_i = inputPlanets[i].velocity;
    double3 acceleration = 0;
    double radius_i = inputPlanets[i].radius;
    double density_i = inputPlanets[i].density;

    for(int j = 0; j < (int)dt_G_planetCount.z; j++) {
        if (i == j) {
            continue;
        }
        double3 position_j = inputPlanets[j].position;
        double3 velocity_j = inputPlanets[j].velocity;
        double radius_j = inputPlanets[j].radius;
        double density_j = inputPlanets[j].density;

        double3 direction = position_j - position_i;
        double distance = length(direction);
        double temp = radius_i + radius_j + 0.07 + 0.001 * (density_i + density_j);
        if (distance < 0.15 * temp) {
            velocity_i *= 0.985;
        } else if (distance < temp) {
            double overlap = distance - temp;
            double3 normal = direction / distance;
            double3 relative_velocity = velocity_j - velocity_i;
            double speed = dot(relative_velocity, normal);
            double3 force = normal * (dt_G_planetCount.y * inputPlanets[i].mass * inputPlanets[j].mass / (distance * distance + 1e-8));
            acceleration += force / inputPlanets[i].mass;
            velocity_i += force * (1.0 / inputPlanets[i].mass) * dt_G_planetCount.x;
        } else {
            double3 force = direction * (dt_G_planetCount.y * inputPlanets[i].mass * inputPlanets[j].mass / (distance * distance + 1e-8));
            acceleration += force / inputPlanets[i].mass;
            outputPlanets[j].acceleration -= force / inputPlanets[j].mass;
        }
    }

    velocity_i += acceleration * dt_G_planetCount.x;
    position_i += velocity_i * dt_G_planetCount.x;
    outputPlanets[i].velocity = velocity_i;
    outputPlanets[i].position = position_i;
    outputPlanets[i].acceleration = acceleration;
}
