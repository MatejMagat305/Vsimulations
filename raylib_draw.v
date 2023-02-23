module main

import vsl.vcl
import irishgreencitrus.raylibv as r
import rand

const (
	screen_width  = 800
	screen_height = 450
)

fn start(shared planets Planets) {
	r.init_window(screen_width, screen_height, 'raylib_draw.v [core] example - basic window'.str)
	r.set_target_fps(60)
	mut camera := r.Camera{
		position: r.Vector3{0.0, 0.0, 10.0}
		target: r.Vector3{0.0, 0.0, 0.0}
		up: r.Vector3{0.0, 0.0, 0.0}
		fovy: 45.0
		projection: r.camera_perspective
	}
	r.set_camera_mode(camera, r.camera_free)
	spawn simulate(shared planets)
	draw(shared planets, mut camera)
}

fn draw(shared planets Planets, mut camera r.Camera) {
	for !r.window_should_close() {
		care_camera(mut &camera)
		r.begin_drawing()
		r.clear_background(r.raywhite)
		r.begin_mode_3d(r.Camera3D(camera))
		r.draw_grid(100, 1.0)
		draw_planets(shared planets)
		r.end_mode_3d()
		r.end_drawing()
	}
	lock planets {
		planets.run = false
	}
}

fn care_camera(mut camera r.Camera) {
	r.update_camera(camera)
	if r.is_key_down(r.key_z) {
		(*camera).target = r.Vector3{0.0, 0.0, 0.0}
	} else if r.is_key_down(r.key_left) {
		(*camera).target.x--
	} else if r.is_key_down(r.key_right) {
		(*camera).target.x++
	} else if r.is_key_down(r.key_up) {
		(*camera).target.y--
	} else if r.is_key_down(r.key_down) {
		(*camera).target.y++
	} else if r.is_key_down(r.key_minus) {
		(*camera).target.z--
	} else if r.is_key_down(r.key_kp_add) {
		(*camera).target.z++
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
