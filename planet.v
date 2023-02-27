module main

import rand
import math

// Define Planet struct
[packed]
struct Planet {
	x       f64
	y       f64
	z       f64
	vx      f64
	vy      f64
	vz      f64
	radius  f64
	density f64
	mass    f64
}
fn random_planet() Planet {
	radius := rand.f64()*2+1
	mass := rand.f64()*2+2
	density := mass / (4.0/3.0 * 3.141592653589793 * math.powf(f32(radius), 3))
	return Planet{
		10 * (rand.f64() * screen_width / 2 - screen_width / 4),
		10 * (rand.f64() * screen_height / 2 - screen_height / 4),
		10 * (rand.f64() * screen_width / 2 - screen_width / 4),
		//rand.f64()*0.2-0.1,rand.f64()*0.2-0.1,rand.f64()*0.2-0.1,
		0,0,0,
		radius, density, mass
	}
}