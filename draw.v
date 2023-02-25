module main

import irishgreencitrus.raylibv as r
import time

const (
	screen_width  = 800
	screen_height = 450
)

fn start(shared planets Planets_colors) {
	r.init_window(screen_width, screen_height, 'draw.v [core] example - basic window'.str)
	r.set_target_fps(2)
	mut camera := r.Camera{
		position: r.Vector3{500.0, 0.0, 0.0}
		target: r.Vector3{0.0, 0.0, 0.0}
		up: r.Vector3{0.0, 1.0, 0.0}
		fovy: 45.0
		projection: r.camera_perspective
	}
	r.set_camera_mode(camera, r.camera_free)
	for !r.window_should_close() {
		r.update_camera(camera)
		if r.is_key_down(r.key_z) {
			camera.target = r.Vector3{0.0, 0.0, 0.0}
			camera.position = r.Vector3{500.0, 0.0, 0.0}
		} else if r.is_key_down(r.key_left) {
			camera.target.x-=20
		} else if r.is_key_down(r.key_right) {
			camera.target.x+=20
		} else if r.is_key_down(r.key_up) {
			camera.target.y-=20
		} else if r.is_key_down(r.key_down) {
			camera.target.y+=20
		} else if r.is_key_down(r.key_minus) {
			camera.target.z-=20
		} else if r.is_key_down(r.key_kp_add) {
			camera.target.z+=20
		}
		r.begin_drawing()
		r.clear_background(r.raywhite)
		r.begin_mode_3d(r.Camera3D(camera))
		draw_planets(shared planets)
		r.end_mode_3d()
		r.end_drawing()
		mut b := true
		lock planets {
			b = planets.run
		}
		if !b {
			break
		}
	}
	lock planets {
		planets.run = false
	}
}

fn draw_planets(shared planets Planets_colors) {
	lock planets {
		for i := 0; i < planets.planets_data.len; i++ {
			planet := planets.planets_data[i]
			pos := r.Vector3{f32(planet.x) / 10, f32(planet.y) / 10, f32(planet.z) / 10}
			rad := f32(planet.radius)
			c := planets.colors[i]
			r.draw_sphere(pos, rad, c)
		}
	}
}
