module main

import vsl.vcl
import os
import net.http

const how_many = 4096

fn main() {
	// Set up VCL
	devices := vcl.get_devices(vcl.DeviceType.cpu)?
	println('Devices: ${devices}')
	mut device := vcl.get_default_device()?
	defer {
		device.release() or { panic(err) }
	}

	// Create buffers for planets on the device
	mut planet_buf := device.vector[Planet](how_many)?
	defer {
		planet_buf.release() or { panic(err) }
	}
	planets := []Planet{cap: how_many}
	for i:= 0;i<how_many;i++{
		planets << random_planet()
	}
	// Load planet data to the device buffers
	err := <-planet_buf.load(planets)
	if err !is none {
		panic(err)
	}

	// load kernel
	kernel := os.read_file(os.join_path( os.dir(@FILE), 'kernel.cl')) or {
		return
	}
	// Add program source to device and create kernel
	device.add_program(kernel)?
	k := device.kernel('updatePlanet')?

	// Set the kernel arguments
	kernel_err := <-k.set_arg(0, planet_buf)?
	if kernel_err !is none {
		panic(kernel_err)
	}

	next_earth := planet_buf.data()?
}

