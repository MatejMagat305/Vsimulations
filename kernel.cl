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

//TODO replace cross-platform variation this nvidia function
double atomic_add_double_global(__global double* p, double val){
    double prev;
    asm volatile(
            "atom.global.add.f64 %0, [%1], %2;"
            : "=d"(prev)
            : "l"(p) , "d"(val)
            : "memory"
            );
    return prev;
}

__kernel void updatePlanet(__global Planet* inputPlanets, __global Planet* outputPlanets, __global double* dt_G_planetCount) {
    int gid = get_global_id(0);
    int planetCount = (int)dt_G_planetCount[2];
    if (gid >= planetCount) { return; }
    // local var
    const double M = inputPlanets[gid].mass;
    if (M <= 0) {
        outputPlanets[gid].mass = -1;
        return;
    }
    {
         const double M2 = outputPlanets[gid].mass;
         if(M > M2){
             outputPlanets[gid].mass = M;
         }
     }
    const double dt = dt_G_planetCount[0];
    const double G = dt_G_planetCount[1];
    volatile double netForceX = 0.0;
    volatile double netForceY = 0.0;
    volatile double netForceZ = 0.0;
    const double X = inputPlanets[gid].x;
    const double Y = inputPlanets[gid].y;
    const double Z = inputPlanets[gid].z;
    const double R = inputPlanets[gid].radius;
    const double D = inputPlanets[gid].density;
    const double VX = inputPlanets[gid].vx;
    const double VY = inputPlanets[gid].vy;
    const double VZ = inputPlanets[gid].vz;
    // all planet forces
    for (int i = 0; i < planetCount; i++) {
        if (i == gid) {
            continue;
        }
        double M_i = inputPlanets[i].mass;
        if (M_i <= 0) { continue; }
        double dx = inputPlanets[i].x - X;
        double dy = inputPlanets[i].y - Y;
        double dz = inputPlanets[i].z - Z;
        double R_i = inputPlanets[i].radius;
        double dist = sqrt(dx * dx + dy * dy + dz * dz);
        double RSUM = (R_i + R);
        double overlap = RSUM - dist;
        if (isnan(dist) || isinf(dist)) { continue; } // error
        if (dist <= R || dist <= R_i) {
            if(M_i > M){
                atomic_add_double_global(&outputPlanets[i].mass, M*0.985);
                outputPlanets[gid].mass = -1;
                atomic_add_double_global(&outputPlanets[i].vx, VX);
                atomic_add_double_global(&outputPlanets[i].vy, VY);
                atomic_add_double_global(&outputPlanets[i].vz, VZ);
                return;
            }
            continue;
        }
        if (overlap > 0) {
           double slowdownMag = 0.05 ;
           netForceX += (-VX * slowdownMag);
           netForceY += (-VY * slowdownMag);
           netForceZ += (-VZ * slowdownMag);
           continue;
        }
        double forceMag = G * M / (dist * dist);
        double forceX = (dx / dist) * forceMag;
        double forceY = (dy / dist) * forceMag;
        double forceZ = (dz / dist) * forceMag;
        if (isnan(forceX) || isnan(forceY) || isnan(forceZ)) { continue; }
        netForceX += forceX;
        netForceY += forceY;
        netForceZ += forceZ;
    }
    // move
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
