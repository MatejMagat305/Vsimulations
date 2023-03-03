module main


const (
how_many = 64

name_kernel_file = 'kernel.cl'
)
fn main() {
	ch := chan []Planet{cap:100}
	stop := chan bool{cap:1}
	spawn start_simulate(ch, stop)
	spawn start_drawing( ch, stop)
	 _ := <- stop
}
