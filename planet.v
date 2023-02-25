module main

import vsl.vcl
import irishgreencitrus.raylibv as r

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
