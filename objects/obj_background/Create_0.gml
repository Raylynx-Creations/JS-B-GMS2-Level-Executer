if (instanceof(Init) == "function"){
	try{
		Init();
	}catch (e){
		show_message(e.message);
		obj_game.state = level.error;
	}
}
