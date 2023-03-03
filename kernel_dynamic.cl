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

__kernel void _updatePlanet(__global Planet* inputPlanets, __global Planet* outputPlanets, __global const double* dt_G_planetCount) {
    const int gid = get_global_id(0);
    const int planetCount = (int)dt_G_planetCount[2];
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
        double dist = sqrt(dx * dx + dy * dy + dz * dz);
        if (isnan(dist) || isinf(dist)) { continue; } // error
        const double forceMag = G * M / (dist * dist);
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

__kernel void _crashPlanet(__global Planet* Planets, __global const double* dt_G_planetCount) {

    const int gid = get_global_id(0);
    const int planetCount = (int)dt_G_planetCount[2];
    if (gid >= planetCount) { return; }
    // local var
    const double M = Planets[gid].mass;
    if (M <= 0) {
        return;
    }
    const double X = Planets[gid].x;
    const double Y = Planets[gid].y;
    const double Z = Planets[gid].z;
    const double R = Planets[gid].radius;
    const double D = Planets[gid].density;
    // all planet forces
    for (int i = 0; i < planetCount; i++) {
        if (i == gid) {
            continue;
        }
        double M_i = inputPlanets[i].mass;
        if (M_i <= 0) { continue; }
        double dx = Planets[i].x - X;
        double dy = Planets[i].y - Y;
        double dz = Planets[i].z - Z;
        double R_i = Planets[i].radius;
        double dist = sqrt(dx * dx + dy * dy + dz * dz);
        double RSUM = (R_i + R);
        double overlap = RSUM - dist;
        if (isnan(dist) || isinf(dist)) { continue; } // error
        if (dist <= R || dist <= R_i) {
        if(M_i > M){
            const double sumMM = M + M_i;
            Planets[i].mass = sumMM; //TODO add atomic
            Planets[gid].mass = -1;
            Planets[i].vx = 0; //TODO add atomic
            Planets[i].vy = 0; //TODO add atomic
            Planets[i].vz = 0; //TODO add atomic
            return;
        }
        continue;
        }
        if (overlap > 0) {
            double slowdownMag = 0.05 * D;
            Planets[i].vx *= slowdownMag;
            Planets[i].vy *= slowdownMag;
            Planets[i].vz *= slowdownMag;
        }
    }
}

__kernel void updatePlanet(__global Planet* inputPlanets, __global Planet* outputPlanets, __global const double* dt_G_planetCount) {
    const int i = get_global_id(0);
    if(i==0){
        const int planetCount = (int)dt_G_planetCount[2];
        const int loopCount = (int)dt_G_planetCount[3];
        for(int j = 0;j<loopCount;j++){
            clk_event_t evt;
            clk_event_t evt2;
            queue_t q = get_default_queue();
            ndrange_t nd = ndrange_1D(planetCount);
            if(j%2==1){
                void (^fn)(void) = ^{_updatePlanet(outputPlanets, inputPlanets, dt_G_planetCount);};
                enqueue_kernel(q, CLK_ENQUEUE_FLAGS_WAIT_WORK_GROUP, nd, 0, NULL, &evt, fn);

                void (^fn2)(void) = ^{_crashPlanet(inputPlanets, dt_G_planetCount);};
                enqueue_kernel(q, CLK_ENQUEUE_FLAGS_WAIT_WORK_GROUP, nd, 0, NULL, &evt, fn2);
            }else{
                void (^fn)(void) = ^{_updatePlanet(inputPlanets, outputPlanets, dt_G_planetCount);};
                enqueue_kernel(q, CLK_ENQUEUE_FLAGS_WAIT_WORK_GROUP, nd, 0, NULL, &evt, fn);
                void (^fn2)(void) = ^{_crashPlanet(outputPlanets, dt_G_planetCount);};
                enqueue_kernel(q, CLK_ENQUEUE_FLAGS_WAIT_WORK_GROUP, nd, 0, NULL, &evt, fn2);
            }
            release_event(evt);
            release_event(evt2);
            //if(j%500==1 && j>1) printf("%d\n", j);
        }
    }else{
        return;
    }
}