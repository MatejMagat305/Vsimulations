module main

import vsl.vcl
import os
import irishgreencitrus.raylibv as r

const how_many = 1024

fn main() {
	// Set up VCL
	devices := vcl.get_devices(vcl.DeviceType.cpu)?
	println('Devices: ${devices}')
	mut device := vcl.get_default_device()?
	defer {
		device.release() or { panic(err) }
	}

	// Create buffers for planets on the device
	mut planet_buf1 := device.vector[Planet](how_many)?
	mut planet_buf2 := device.vector[Planet](how_many)?
	defer {
		planet_buf1.release() or { panic(err) }
	}
	defer {
		planet_buf2.release() or { panic(err) }
	}
	mut planets := []Planet{cap: how_many}
	for i := 0; i < how_many; i++ {
		planets << random_planet()
	}
	// Load planet data to the device buffers
	mut err := <-planet_buf1.load(planets)
	if err !is none {
		panic(err)
	}
	err = <-planet_buf2.load(planets)
	if err !is none {
		panic(err)
	}
	params := [f64(0.5), 9.81, how_many]
	mut params_buf := device.vector[f64](3)?
	err = <-params_buf.load(params)
	if err !is none {
		panic(err)
	}
	// load kernel
	kernel := os.read_file(os.join_path(os.dir(@FILE), 'kernel.cl')) or { return }
	// Add program source to device and create kernel
	device.add_program(kernel)?
	k := device.kernel('updatePlanet')?

	mut c := []r.Color{cap: how_many}
	for i := 0; i < how_many; i++ {
		c << random_color()
	}
	shared planets_struct := Planets_colors{
		planets_data: planets
		colors: c
		run: true
	}
	mut planets_kernel_buff := Planets_kernel{
		kernel: k
		cl_vector1: planet_buf1
		cl_vector2: planet_buf2
	}
	spawn simulate(shared planets_struct, mut &planets_kernel_buff, mut params_buf)
	start(shared planets_struct)
}
