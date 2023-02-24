module main

import irishgreencitrus.raylibv as r

const (
	screen_width  = 800
	screen_height = 450
)

fn start(shared planets Planets_colors) {
	r.init_window(screen_width, screen_height, 'draw.v [core] example - basic window'.str)
	r.set_target_fps(60)
	mut camera := r.Camera{
		position: r.Vector3{0.0, 0.0, 10.0}
		target: r.Vector3{0.0, 0.0, 0.0}
		up: r.Vector3{0.0, 0.0, 0.0}
		fovy: 45.0
		projection: r.camera_perspective
	}
	r.set_camera_mode(camera, r.camera_free)
	for !r.window_should_close() {
		r.update_camera(camera)
		if r.is_key_down(r.key_z) {
			camera.target = r.Vector3{0.0, 0.0, 0.0}
		} else if r.is_key_down(r.key_left) {
			camera.target.x--
		} else if r.is_key_down(r.key_right) {
			camera.target.x++
		} else if r.is_key_down(r.key_up) {
			camera.target.y--
		} else if r.is_key_down(r.key_down) {
			camera.target.y++
		} else if r.is_key_down(r.key_minus) {
			camera.target.z--
		} else if r.is_key_down(r.key_kp_add) {
			camera.target.z++
		}
		r.begin_drawing()
		r.clear_background(r.raywhite)
		r.begin_mode_3d(r.Camera3D(camera))
		r.draw_grid(100, 1.0)
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
			r.draw_circle_3d(r.Vector3{f32(planet.position[0]), f32(planet.position[1]), f32(planet.position[2])},
				f32(planet.radius), r.Vector3{f32(0), 0, 0}, f32(0), planets.colors[i])
		}
	}
}
