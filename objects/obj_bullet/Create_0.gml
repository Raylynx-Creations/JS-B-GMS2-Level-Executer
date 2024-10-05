image_speed = 0;
if (instanceof(Init) == "function"){
	try{
		Init(id);
	}catch (e){
		show_message(e.message);
		obj_game.state = level.error;
	}
}
