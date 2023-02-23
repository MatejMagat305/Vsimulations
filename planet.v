module main

import rand
import vsl.vcl
import irishgreencitrus.raylibv as r
import time

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
	xyz := [
		rand.f64() * screen_width / 4 + screen_width / 2,
		rand.f64() * screen_height / 4 + screen_height / 2,
		rand.f64() * screen_height / 4 + screen_height / 2,
	]
	v_xyz := [rand.f64() * 2 - 1, rand.f64() * 2 - 1, rand.f64() * 2 - 1]
	return Planet{
		position: [3]f64{init: xyz[it]}
		velocity: [3]f64{init: v_xyz[it]}
		acceleration: [3]f64{init: 0.0}
		radius: rand.f64() * 6
		density: rand.f64() * 8
		mass: rand.f64() * 5
	}
}

struct Planets {
	colors []r.Color
	kernel &vcl.Kernel
mut:
	cl_vector1   &vcl.Vector[Planet]
	cl_vector2   &vcl.Vector[Planet]
	run          bool
	planets_data []Planet
}

fn draw_planets(shared planets Planets) {
	lock planets {
		for i := 0; i < planets.planets_data.len; i++ {
			planet := planets.planets_data[i]
			r.draw_circle_3d(r.Vector3{f32(planet.position[0]), f32(planet.position[1]), f32(planet.position[2])},
				f32(planet.radius), r.Vector3{f32(0), 0, 0}, f32(0), planets.colors[i])
		}
	}
}

fn simulate(shared planets Planets) {
	mut kernel := vcl.Kernel{}
	mut cl_vector1 := vcl.Vector[Planet]{}
	mut cl_vector2 := vcl.Vector[Planet]{}
	lock planets {
		unsafe {
			kernel = planets.kernel
			cl_vector1 = planets.cl_vector1
			cl_vector2 = planets.cl_vector2
		}
	}
	mut t := time.now()
	for planets.run {
		mut kernel_err := <-kernel.global(how_many).local(1).run(cl_vector1.buffer(),
			cl_vector2.buffer())
		if kernel_err !is none {
			println(kernel_err.str())
		}
		kernel_err = <-kernel.global(how_many).local(1).run(cl_vector2.buffer(), cl_vector1.buffer())
		if kernel_err !is none {
			println(kernel_err.str())
		}
		lock planets {
			if !planets.run {
				return
			}
			if time.since(t).milliseconds() > time.second.milliseconds() / 10 {
				planets.planets_data = cl_vector1.data() or {
					println(err)
					planets.planets_data
				}
				t = time.now()
			}
		}
	}
}
