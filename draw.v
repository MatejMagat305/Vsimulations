module main

import irishgreencitrus.raylibv as r
import rand

const (
	screen_width  = 800
	screen_height = 450
)

fn random_color() r.Color {
	return r.Color{
		r: rand.u8()
		g: rand.u8()
		b: rand.u8()
		a: 255
	}
}
fn start_drawing(ch_planet chan []Planet, stop chan bool) {
	r.init_window(screen_width, screen_height, 'draw.v [core] example - basic window'.str)
	r.set_target_fps(6)
	mut planets := <- ch_planet
	mut camera := r.Camera{
		position: r.Vector3{500.0, 0.0, 0.0}
		target: r.Vector3{0.0, 0.0, 0.0}
		up: r.Vector3{0.0, 1.0, 0.0}
		fovy: 45.0
		projection: r.camera_perspective
	}
	mut colors := []r.Color{cap: how_many}
	for i := 0; i < how_many; i++ {
		colors << random_color()
	}
	r.set_camera_mode(camera, r.camera_free)
	mut val := f32(1)
	for !r.window_should_close() {
		r.update_camera(camera)
		if r.is_key_down(r.key_z) {
			camera.target = r.Vector3{0.0, 0.0, 0.0}
			camera.position = r.Vector3{500.0, 0.0, 0.0}
		} else if r.is_key_down(r.key_left) {
			camera.target.z+=val
		} else if r.is_key_down(r.key_right) {
			camera.target.z-=val
		} else if r.is_key_down(r.key_up) {
			camera.target.y+=val
		} else if r.is_key_down(r.key_down) {
			camera.target.y-=val
		} else if r.is_key_down(r.key_kp_2) {
			camera.target.x+=val
		} else if r.is_key_down(r.key_kp_5) {
			camera.target.x-=val
		}
		if r.is_key_down(r.key_v) {
			val = 1
		}else if r.is_key_down(r.key_w) { val++ }else if r.is_key_down(r.key_s) { val-- }
		r.begin_drawing()
		r.clear_background(r.raywhite)
		r.begin_mode_3d(r.Camera3D(camera))
		draw_planets(planets, colors)
		r.end_mode_3d()
		r.end_drawing()
		for{
			select {
				p := <- ch_planet {
					planets = p.clone()
				}
				else{
					break
				}
			}
		}
	}
	stop <- false
}

[inline]
fn draw_planets(planets []Planet, colors []r.Color ) {
	for i := 0; i < planets.len; i++ {
		planet := planets[i]
		if planet.mass < 0 {
			continue
		}
		pos := r.Vector3{f32(planet.x/10), f32(planet.y/10), f32(planet.z/10)}
		rad := f32(planet.radius)
		c := colors[i]
		r.draw_sphere(pos, rad, c)
	}
}
