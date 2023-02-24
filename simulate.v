module main

import time
import vsl.vcl

fn simulate(shared planets Planets_colors, mut buffers_planets Planets_kernel) {
	mut kernel := buffers_planets.kernel
	mut cl_vector1 := buffers_planets.cl_vector1
	mut cl_vector2 := buffers_planets.cl_vector2
	mut t := time.now()
	for {
		mut kernel_err := <-kernel.global(how_many).local(1).run(cl_vector1.buffer(),
			cl_vector2.buffer())
		if kernel_err !is none {
			println(kernel_err.str())
			break
		}
		kernel_err = <-kernel.global(how_many).local(1).run(cl_vector2.buffer(), cl_vector1.buffer())
		if kernel_err !is none {
			println(kernel_err.str())
			break
		}
		lock planets {
			if !planets.run {
				break
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
	lock planets {
		planets.run = false
	}
}
