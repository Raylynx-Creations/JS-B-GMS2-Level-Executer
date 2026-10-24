try{
	if (is_method(Draw)){
		Draw(id);
	}else{
		draw_self();
	}
}catch (e){
	show_message("Background.Alive[" + string(id) + "]: " + e.message);
	obj_game.state = level.error;
}