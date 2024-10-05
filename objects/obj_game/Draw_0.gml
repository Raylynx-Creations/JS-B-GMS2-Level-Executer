if (room == rm_menu){
	if ((state != menu.waiting and not (audio_get_name(music) == "mus_intro")) and state != menu.done or (state == menu.done and timer < 83)){
		draw_set_color(make_color_rgb(12,22,24));
		draw_rectangle(0,-4,1600,900,false);
		draw_set_color(c_white);
	}
	switch (state){
		case menu.intro:
			if (audio_get_name(music) == "mus_intro"){
				for (var i=0;i<array_length(data);i++){
					draw_sprite_ext(spr_spikeball,0,data[i].x,data[i].y,data[i].scale.x,data[i].scale.y,data[i].angle,data[i].col,data[i].alpha);
				}
			}
		break;
		case menu.warnings:
			draw_sprite(spr_caveBG,0,0,0);
			draw_sprite_ext(spr_mushroom,0,120,335,0.7*data[0].xscale,0.7*data[0].yscale,-20 + data[0].angle,c_white,1);
			draw_sprite_ext(spr_mushroom,0,355,435,0.55*data[1].xscale,0.55*data[1].yscale,-160 + data[1].angle,c_white,1);
			draw_sprite_ext(spr_mushroom,0,235,792,0.4*data[2].xscale,0.4*data[2].yscale,-5 + data[2].angle,c_white,1);
			draw_sprite_ext(spr_mushroom,0,500,100,0.4*data[3].xscale,0.4*data[3].yscale,-145 + data[3].angle,c_white,1);
			draw_sprite_ext(spr_mushroom,0,1065,75,0.55*data[4].xscale,0.55*data[4].yscale,160 + data[4].angle,c_white,1);
			draw_sprite_ext(spr_mushroom,0,1505,440,0.7*data[5].xscale,0.7*data[5].yscale,data[5].angle,c_white,1);
			draw_sprite_ext(spr_mushroom,0,1250,465,0.4*data[6].xscale,0.4*data[6].yscale,135 + data[6].angle,c_white,1);
			draw_sprite_ext(spr_mushroom,0,1330,815,0.55*data[7].xscale,0.55*data[7].yscale,25 + data[7].angle,c_white,1);
			draw_set_color(c_black);
			draw_set_alpha(0.65);
			draw_rectangle(0,0,1600,900,false);
			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_font(fnt_nexaBold90);
			var col = make_color_rgb(255,32,112);
			draw_text_transformed_color(800,58,text[0],0.8,0.8,0,col,col,col,col,1-image_angle);
			var col = make_color_rgb(0,255,255);
			draw_text_transformed_color(800,244,text[1],0.4,0.4,0,col,col,col,col,1-image_angle);
			var col = c_gray;
			draw_text_transformed_color(800,795,"Press " + indication[0] + " to Continue",0.3,0.3,0,col,col,col,col,1-image_angle);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 4 - 2*floor((timer2%120)/60) : 2 - 2*floor((timer2%120)/60)), 721, 795, 0.45, 0.45, 0, c_white, 1-image_angle);
			}
			draw_set_halign(fa_left);
			draw_set_alpha(image_alpha);
			draw_rectangle(0,0,1600,900,false);
			draw_set_alpha(1);
			draw_set_color(c_white);
		break;
	}
}else{
	draw_clear(levelBG);
	length = array_length(Checkpoints);
	for (var i=array_length(Background.Alive)-1;i>=0;i--){
		with (Background.Alive[i]){
			try{
				Draw(id);
			}catch (e){
				show_message("Background.Alive[" + string(i) + "]: " + e.message);
				obj_game.state = level.error;
			}
		}
	}
	for (var i=0;i<length;i++){
		var event = Checkpoints[i];
		var position = 1600 - 360*(SongTime + event.offset - event.time);
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
	DrawPlayers(PlayerInstances);
	for (var i=array_length(Bullets.Alive)-1;i>=0;i--){
		with (Bullets.Alive[i]){
			try{
				Draw(id);
			}catch (e){
				show_message("Bullets.Alive[" + string(i) + "]: " + e.message);
				obj_game.state = level.error;
			}
		}
	}
	if (instanceof(Draw) == "function"){
		Draw();
	}
}