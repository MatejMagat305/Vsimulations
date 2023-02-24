module main

import rand
import irishgreencitrus.raylibv as r

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

fn random_color() r.Color {
	return r.Color{
		r: rand.u8()
		g: rand.u8()
		b: rand.u8()
		a: 255
	}
}
