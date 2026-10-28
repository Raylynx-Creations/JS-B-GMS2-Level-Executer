if (room == rm_level){
	gpu_set_fog(true, levelBG, 16100, 17600);
	layer_background_blend(layer_background_get_id("Background"), levelBG)
	length = array_length(Checkpoints);
	for (var i=0;i<length;i++){
		var event = Checkpoints[i];
		var position = Camera.x + 1600 - 360*(SongTime + event.offset - event.time);
		var color = c_cyan;
		if (!is_string(event.reference)){
			if (event.damage > 0){
				color = c_pink;
			}else if (event.damage < 0){
				color = c_green2;
			}
		}
		draw_sprite_ext(spr_checkpoint, 0, position, 450, 0.5, 0.5, 0, color, 1);
	}
	if (instanceof(Draw) == "function"){
		Draw();
	}
	if (state == level.ranking){
		draw_set_halign(fa_center);
		draw_set_font(fnt_nexaBold90);
		draw_text(800, 300, "Happy halloween!!\nYou won! :D")
	}
}