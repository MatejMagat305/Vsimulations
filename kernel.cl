typedef struct __attribute__((packed)) Planet {
    double x;
    double y;
    double z;
    double vx;
    double vy;
    double vz;
    double radius;
    double density;
    double mass;
} Planet;

__kernel void updatePlanet(__global Planet* inputPlanets, __global Planet* outputPlanets, __global double* dt_G_planetCount) {
    int gid = get_global_id(0);
    int planetCount = (int)dt_G_planetCount[2];
    if (gid >= planetCount) {
        return;
    }
    double dt = dt_G_planetCount[0];
    double netForceX = 0.0;
    double netForceY = 0.0;
    double netForceZ = 0.0;
    double X = inputPlanets[gid].x;
    double Y = inputPlanets[gid].y;
    double Z = inputPlanets[gid].z;
    double R = inputPlanets[gid].radius;
    double D = inputPlanets[gid].density;
    double M = inputPlanets[gid].mass;
    double VX = inputPlanets[gid].vx;
    double VY = inputPlanets[gid].vy;
    double VZ = inputPlanets[gid].vz;
    for (int i = 0; i < planetCount; i++) {
        if (i == gid) {
            continue;
        }
        double dx = X - inputPlanets[i].x;
        double dy = Y - inputPlanets[i].y;
        double dz = Z - inputPlanets[i].z;
        double dist = sqrt(dx * dx + dy * dy + dz * dz);
        double RSUM = (inputPlanets[i].radius + R) * 1.05;
        double overlap = RSUM - dist;
        if (overlap > 0) {;
            double overlapRatio = overlap / dist;
            if (overlapRatio <= 0.1) {
                double slowdownMag = 0.015 * D * overlapRatio;
                netForceX += (-VX * slowdownMag);
                netForceY += (-VY * slowdownMag);
                netForceZ += (-VZ * slowdownMag);
                continue;
            }
            double repulseMag = 0.1 * D * overlapRatio;
            netForceX += (-(dx / dist) * repulseMag);
            netForceY += (-(dy / dist) * repulseMag);
            netForceZ += (-(dz / dist) * repulseMag);
            continue;
        }
    }
    double accelX = netForceX / M;
    double accelY = netForceY / M;
    double accelZ = netForceZ / M;
    outputPlanets[gid].vx += accelX * dt;
    outputPlanets[gid].vy += accelY * dt;
    outputPlanets[gid].vz += accelZ * dt;
    outputPlanets[gid].x += outputPlanets[gid].vx * dt;
    outputPlanets[gid].y += outputPlanets[gid].vy * dt;
    outputPlanets[gid].z += outputPlanets[gid].vz * dt;
}
