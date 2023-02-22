module main

import vsl.vcl
import irishgreencitrus.raylibv as r
import rand

const (
	screen_width  = 800
	screen_height = 450
)

fn start(k &vcl.Kernel, mut v vcl.Vector[Planet]){
	r.init_window(screen_width, screen_height, 'raylib_draw.v [core] example - basic window'.str)
	r.set_target_fps(60)
	mut camera := r.Camera{
		position: r.Vector3{0.0, 0.0, 10.0}
		target: r.Vector3{0.0, 0.0, 0.0}
		up: r.Vector3{0.0, 0.0, 0.0}
		fovy: 45.0
		projection: r.camera_perspective
	}
	mut colors := []r.Color{cap: how_many}
	for i:= 0;i<how_many;i++{
		colors << random_color()
	}

	r.set_camera_mode(camera, r.camera_free)
	// kernel with global and local size
	kk := k.global(how_many).local(1)
	// simulator loop
	for !r.window_should_close() {
		// Run the kernel
		kernel_err := <-kk.run()
		if kernel_err !is none {
			panic(kernel_err)
		}
		// get one steps of simulations
		planets := v.data()!
		// set camera by keys
		care_camera(&camera)
		// begin
		r.begin_drawing()
		r.clear_background(r.raywhite)
		r.begin_mode_3d(r.Camera3D(camera))
		r.draw_grid(100, 1.0)
		//draw all planets
		draw_planets(planets, colors)
		r.end_mode_3d()
		r.end_drawing()
	}
}

fn draw_planets(planets []Planet, colors []r.Color){
	for i:= 0; i<planets.len; i++{
		planet := planets[i]
		r.draw_circle_3d(
			r.Vector3{planet.position[0], planet.position[1], planet.position[2]},
			f32(planet.radius),
			r.Vector3{f32(0), 0, 0},
			f32(0),
			colors[i]
		)
	}
}

fn care_camera(camera &r.Camera){
	r.update_camera(camera)
	if r.is_key_down(r.key_z) {
		(*camera).target = r.Vector3{0.0, 0.0, 0.0}
	}else if r.is_key_down(r.key_left) {
		(*camera).target.x--
	}else if r.is_key_down(r.key_right) {
		(*camera).target.x++
	}else if r.is_key_down(r.key_up) {
		(*camera).target.y--
	}else if r.is_key_down(r.key_down) {
		(*camera).target.y++
	}else if r.is_key_down(r.key_minus) {
		(*camera).target.z--
	}else if r.is_key_down(r.key_kp_add) {
		(*camera).target.z++
	}
}
fn random_color() r.Color{
	return r.Color{
		r: rand.u8(),
		g: rand.u8(),
		b: rand.u8(),
		a: 255
	}
}