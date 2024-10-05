if (other.canHurt and ((modo == mode.shape and (other.ignoreDash or timer.dash <= 1 or vel.current - vel.normal == 0)) or modo == mode.helicopter) and damaged == -1 and !murio){
	try{
		other.canHit(id,other.id);
	}catch (e){
		show_message(e.message);
		obj_game.state = level.error;
	}
}