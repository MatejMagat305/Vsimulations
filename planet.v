module main

import vsl.vcl
import irishgreencitrus.raylibv as r

// Define Planet struct
struct Planet {
	position     [3]f64 // position of the planet in all three directions
	velocity     [3]f64 // velocity of the planet in all three directions
	acceleration [3]f64 // acceleration of the planet in all three directions
	radius       f64    // radius of the planet
	density      f64    // density of the planet
	mass         f64    // mass of the planet
}

struct Planets_colors {
	colors []r.Color
mut:
	planets_data []Planet
	run          bool
}

struct Planets_kernel {
	kernel &vcl.Kernel
mut:
	cl_vector1 &vcl.Vector[Planet]
	cl_vector2 &vcl.Vector[Planet]
}
