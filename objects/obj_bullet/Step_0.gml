if (instanceof(Update) == "function"){
	try{
		Update(id);
	}catch (e){
		show_message(e.message);
		obj_game.state = level.error;
	}
}

if (is_struct(spriteiomdsfilasmdanls)){
	if (variable_struct_exists(spriteiomdsfilasmdanls, "animation_times") and !variable_struct_exists(spriteiomdsfilasmdanls,"pause")){
		spriteiomdsfilasmdanls.timer += delta_time*spriteiomdsfilasmdanls.animation_speed/10000;
		if (is_array(spriteiomdsfilasmdanls.animation_times)){
			while ((image_index + 1 < spriteiomdsfilasmdanls.images or spriteiomdsfilasmdanls.loops) and spriteiomdsfilasmdanls.timer >= spriteiomdsfilasmdanls.animation_times[image_index % spriteiomdsfilasmdanls.images]){
				spriteiomdsfilasmdanls.timer -= spriteiomdsfilasmdanls.animation_times[image_index % spriteiomdsfilasmdanls.images];
				if (spriteiomdsfilasmdanls.loops){
					image_index = (image_index + 1) % spriteiomdsfilasmdanls.images;
				}
			}
		}else{
			while ((image_index + 1 < spriteiomdsfilasmdanls.images or spriteiomdsfilasmdanls.loops) and spriteiomdsfilasmdanls.timer >= spriteiomdsfilasmdanls.animation_times){
				spriteiomdsfilasmdanls.timer -= spriteiomdsfilasmdanls.animation_times;
				if (spriteiomdsfilasmdanls.loops){
					image_index = (image_index + 1) % spriteiomdsfilasmdanls.images;
				}
			}
		}
	}
}

if (SongTime >= DeathTime or SongTime < SpawnTime){
	instance_destroy();
}
