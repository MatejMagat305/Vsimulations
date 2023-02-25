module main

import rand
import irishgreencitrus.raylibv as r

fn random_planet() Planet {
	return Planet{10 * (rand.f64() * screen_width / 2 - screen_width / 4),
		10 * (rand.f64() * screen_height / 2 - screen_height / 4),
		10 * (rand.f64() * screen_width / 2 - screen_width / 4),
		rand.f64() * 0.2 - 0.1, rand.f64() * .2 - .1, rand.f64() * .2 - .1, 1.5, 2, rand.f64() * 5+10}
}

fn random_color() r.Color {
	return r.Color{
		r: rand.u8()
		g: rand.u8()
		b: rand.u8()
		a: 255
	}
}
