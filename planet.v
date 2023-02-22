module main

import rand

// Define Planet struct
struct Planet {
	position     [3]f64 // position of the planet in all three directions
	velocity     [3]f64 // velocity of the planet in all three directions
	acceleration [3]f64 // acceleration of the planet in all three directions
	radius       f64    // radius of the planet
	density      f64    // density of the planet
	mass         f64    // mass of the planet
}

fn random_planet() Planet {
	return Planet{
		position: [rand.f64()*screen_width/4+screen_width/2,
		rand.f64()*screen_height/4+screen_height/2,
		rand.f64()*screen_height/4+screen_height/2]
		velocity: [rand.f64()*2-1, rand.f64()*2-1, rand.f64()*2-1]
		acceleration: [0.0, 0.0, 0.0]
		radius: 6.3781e6
		density: 5.52e3
		mass: 5.97e24
	}
}