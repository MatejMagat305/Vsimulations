module main

import time
import vsl.vcl
import os
fn start_simulate(ch chan []Planet, stop chan bool) {
	mut planets := []Planet{cap: how_many}
	for i := 0; i < how_many; i++ {
		planets << random_planet()
	}
	ch <- planets
	defer {	stop <- false }
	mut device := vcl.get_default_device() or { return }
	defer {
		device.release() or { panic(err) }
	}

	// Create buffers for planets on the device
	mut planet_buf1 := device.vector[Planet](how_many) or { return }
	mut planet_buf2 := device.vector[Planet](how_many) or { return }
	defer {
		planet_buf1.release() or { panic(err) }
	}
	defer {
		planet_buf2.release() or { panic(err) }
	}
	// Load planet data to the device buffers
	mut err := <-planet_buf1.load(planets)
	if err !is none { panic(err) }
	err = <-planet_buf2.load(planets)
	if err !is none { panic(err)	}
	params := [f64(0.1), 9.81, how_many]
	mut params_buf := device.vector[f64](3) or { return }
	err = <-params_buf.load(params)
	if err !is none { panic(err) }
	// load kernel
	mut kernel_string := os.read_file(os.join_path(os.dir(@FILE), 'kernel.cl')) or { return }
	// Add program source to device and create kernel
	device.add_program(kernel_string) or { return }
	mut kernel := device.kernel('updatePlanet') or { return }

	// start loop
	mut t := time.now()
	for {
		if time.since(t).milliseconds() > time.second.milliseconds() / 4 {
			ch <- planet_buf1.data() or {
				println(err)
				planets
			}
			t = time.now()
		}
		mut kernel_err := <- kernel.global(how_many).local(1).run(planet_buf1.buffer(),	planet_buf2.buffer(), params_buf)
		if kernel_err !is none {
			println(kernel_err.str())
			break
		}
		kernel_err = <- kernel.global(how_many).local(1).run(planet_buf2.buffer(), planet_buf1.buffer(), params_buf)
		if kernel_err !is none {
			println(kernel_err.str())
			break
		}
	}
}
