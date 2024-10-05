if (room == rm_menu){
	draw_set_font(fnt_nexaBold90);
	draw_set_halign(fa_center);
	switch (state){
		case menu.quitOut: case menu.nolevelsOut:
			draw_set_alpha(max(timer - 30, 0)/20);
			draw_text_transformed(260, 857, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 213, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_text_transformed(1340, 857, "Press " + indication[1] + " to Quit", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1317, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
		break;
		case menu.quit: case menu.nolevels:
			draw_set_alpha(max(20 - timer, 0)/20);
			draw_text_transformed(260, 857, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 213, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_text_transformed(1340, 857, "Press " + indication[1] + " to Quit", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1317, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
		break;
	}
	if (state != menu.waiting and state != menu.warnings and not (audio_get_name(music) == "mus_intro")){
		for (var i=0;i<array_length(data);i++){
			var thing = data[i];
			if (not variable_struct_exists(thing, "ontop") and not variable_struct_exists(thing, "notdraw")){
				draw_sprite_ext(thing.sprite,thing.index,thing.x,thing.y,thing.scale.x,thing.scale.y,thing.angle,thing.col,thing.alpha);
			}
		}
	}
	draw_set_alpha(1);
	draw_set_font(fnt_nexaBold90);
	switch (state){
		case menu.returning:
			draw_set_alpha(1/15*max(timer - 131, 0));
			draw_text_transformed(840, 847, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 793, 846, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_set_color(c_white);
			draw_text_transformed(1310, 847, "Press " + indication[1] + " to Cancel", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1272, 846, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_set_color(c_white);
			draw_text_transformed(278, 12, "SELECT YOUR\nLEVEL", 0.5, 0.5, 0);
			draw_set_alpha(1);
			if (array_length(data) > 0){
				draw_set_color(make_color_rgb(0,76,76));
				var header = {x: data[0].x, y: data[0].y};
				if (timer < 55 and state == menu.levels){
					header = {x: data[1].x, y: data[1].y}
				}
				draw_set_color(c_gray);
				draw_set_halign(fa_left);
				draw_text_transformed(header.x - 480, header.y - 15, "song name & artist", 0.2, 0.2, 0);
				draw_text_transformed(header.x - 50, header.y - 15, "level creator", 0.2, 0.2, 0);
				draw_text_transformed(header.x + 250, header.y - 15, "level type", 0.2, 0.2, 0);
				draw_text_transformed(header.x + 416, header.y - 15, "rank", 0.2, 0.2, 0);
				if (!surface_exists(surface[0])){
					surface[0] = surface_create(2*data[1].scale.x, 2*data[1].scale.y);
				}else{ if (surface_get_width(surface[0]) != 2*data[1].scale.x or surface_get_height(surface[0]) != 2*data[1].scale.y){
					surface_resize(surface[0], 2*data[1].scale.x, 2*data[1].scale.y);
				}}
				surface_set_target(surface[0]);
				draw_clear_alpha(c_black, 0);
				if (timer >= 138){
					draw_sprite_ext(data[3].sprite,data[3].index,data[3].x,data[3].y,data[3].scale.x,data[3].scale.y,data[3].angle,data[3].col,data[3].alpha);
				}
				DrawSongs();
				surface_reset_target();
				draw_surface(surface[0], data[1].x - data[1].scale.x, data[1].y - data[1].scale.y);
			}
			if (timer < 15){
				draw_set_color(c_black);
				draw_rectangle(0,-4,1600,900,false);
				draw_set_color(c_white);
			}else{ if (timer > 68 and timer <= 88){
				draw_sprite_ext(spr_hole, 0, 800, 250, 10*(timer - 68)/1000, 10*(timer - 68)/1000, 0, make_color_rgb(0,255,255), (88 - timer)/20);
			}}
			if (array_length(Squares) > 0){
				for (var i=0;i<array_length(Squares);i++){
					draw_sprite_ext(spr_pixel,0,Squares[i].x,Squares[i].y,40,40,Squares[i].rot,Squares[i].col,Squares[i].alpha/15*min(timer, 15));
				}
			}
		break;
		case menu.done:
			if (timer < 83){
				draw_set_alpha(1/15*max(15 - timer, 0));
				draw_text_transformed(278, 12, "SELECT YOUR\nLEVEL", 0.5, 0.5, 0);
				var rota = random_range(-6/10*max(10 - timer, 0), 6/10*max(10 - timer, 0));
				var scala = 0.2 + 0.015*(dsin(180/10*min(timer, 10)) + dcos(90/5*clamp(timer - 5, 0, 5)));
				draw_text_transformed(840, 847, "Hold " + indication[0] + " to Confirm", scala, scala, rota);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 840 - (53*scala/0.2)*dcos(rota) - (4*scala/0.2)*dsin(rota), 850 - (4*scala/0.2)*dcos(rota) + (53*scala/0.2)*dsin(rota), 0.3*scala/0.2, 0.3*scala/0.2, rota, draw_get_color(), draw_get_alpha());
				}
				draw_text_transformed(1310, 847, "Hold " + indication[1] + " to Cancel", 0.2, 0.2, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1267, 846, 0.3, 0.3, 0, c_white, draw_get_alpha());
				}
				draw_set_alpha(1);
				draw_set_color(c_gray);
				draw_set_halign(fa_left);
				draw_text_transformed(data[0].x - 480, data[0].y - 15, "song name & artist", 0.2, 0.2, 0);
				draw_text_transformed(data[0].x - 50, data[0].y - 15, "level creator", 0.2, 0.2, 0);
				draw_text_transformed(data[0].x + 250, data[0].y - 15, "level type", 0.2, 0.2, 0);
				draw_text_transformed(data[0].x + 416, data[0].y - 15, "rank", 0.2, 0.2, 0);
				if (!surface_exists(surface[0])){
					surface[0] = surface_create(2*data[1].scale.x, 2*data[1].scale.y);
				}else{ if (surface_get_width(surface[0]) != 2*data[1].scale.x or surface_get_height(surface[0]) != 2*data[1].scale.y){
					surface_resize(surface[0], 2*data[1].scale.x, 2*data[1].scale.y);
				}}
				surface_set_target(surface[0]);
				draw_clear_alpha(c_black, 0);
				draw_sprite_ext(data[3].sprite,data[3].index,data[3].x,data[3].y,data[3].scale.x,data[3].scale.y,data[3].angle,data[3].col,data[3].alpha);
				DrawSongs();
				draw_set_color(c_white);
				for (var i=0;i<4;i++){
					draw_set_halign(fa_center);
					draw_text_transformed(274 + 464*(i%2), 90 + 326*floor(i/2), "Player  " + string(i + 1), 0.4, 0.4, 0);
					draw_sprite_ext(spr_pixel, 0, 274 + 464*(i%2), 284 + 326*floor(i/2), 176, 128, 0, make_color_rgb(0,20,20), 1);
					surface_reset_target();
					if (!surface_exists(surface[3])){
						surface[3] = surface_create(352, 256);
					}
					surface_set_target(surface[3]);
					draw_clear_alpha(c_black, 0);
					var aux = Levels[selected].play_as;
					with (configurations[i]){
						BeforeDraw();
						var length = array_length(player.layers);
						for (var j=0;j<length;j++){
							player.layers[j]();
						}
						Draw();
					}
					surface_reset_target();
					surface_set_target(surface[0]);
					draw_surface(surface[3], 98 + 464*(i%2), 156 + 326*floor(i/2));
				}
				surface_reset_target();
				draw_set_halign(fa_left);
				draw_surface(surface[0], data[1].x - data[1].scale.x, data[1].y - data[1].scale.y);
				draw_set_alpha(1/5*max(timer - 78, 0));
				draw_rectangle(-1,-10,1601,901,false);
				draw_set_alpha(1);
			}else{
				for (var i=0;i<array_length(Squares);i++){
					draw_sprite_ext(spr_pixel,0,Squares[i].x,Squares[i].y,40,40,Squares[i].rot,Squares[i].col,Squares[i].alpha);
				}
			}
		break;
		case menu.players: case menu.playersOut:
			draw_text_transformed(278, 12, "SELECT YOUR\nLEVEL", 0.5, 0.5, 0);
			if (mouse_x >= 694 + 25*(maincontrols != controls.keyboard) and mouse_x <= 985 - 25*(maincontrols != controls.keyboard) and mouse_y >= 840 and mouse_y <= 870 and cursor_sprite != -1 and state == menu.players and canproceed and timer > 75){
				draw_set_color(c_yellow);
			}else{ if (!canproceed or state == menu.playersOut){
				if (timer > 45){
					draw_set_color(c_gray);
				}
			}}
			draw_set_alpha(abs(dcos(90*clamp(timer - 15, 0, 60)/30)));
			if (timer <= 45){
				draw_text_transformed(840, 847, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 793, 846, 0.3, 0.3, 0, c_white, draw_get_alpha());
				}
			}else{ if (state == menu.players){
				var rota = random_range(-6/60*timer2[1], 6/60*timer2[1]);
				var scala = 0.2 + 0.015/60*timer2[1];
				draw_text_transformed(840, 847, "Hold " + indication[0] + " to Confirm", scala, scala, rota);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 840 - (53*scala/0.2)*dcos(rota) - (4*scala/0.2)*dsin(rota), 850 - (4*scala/0.2)*dcos(rota) + (53*scala/0.2)*dsin(rota), 0.3*scala/0.2, 0.3*scala/0.2, rota, draw_get_color(), draw_get_alpha());
				}
			}}
			draw_set_color(c_white);
			if (mouse_x >= 1186 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1434 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 840 and mouse_y <= 870 and cursor_sprite != -1 and state == menu.players and timer > 75){
				draw_set_color(c_yellow);
			}
			if (timer <= 45){
				draw_text_transformed(1310, 847, "Press " + indication[1] + " to Cancel", 0.2, 0.2, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1272, 846, 0.3, 0.3, 0, c_white, draw_get_alpha());
				}
			}else{ if (state == menu.players){
				var rota = random_range(-6/60*timer2[0], 6/60*timer2[0]);
				var scala = 0.2 + 0.015/60*timer2[0];
				draw_text_transformed(1310, 847, "Hold " + indication[1] + " to Cancel", scala, scala, rota);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1310 - (43*scala/0.2)*dcos(rota) - (4*scala/0.2)*dsin(rota), 850 - (4*scala/0.2)*dcos(rota) + (43*scala/0.2)*dsin(rota), 0.3*scala/0.2, 0.3*scala/0.2, rota, c_white, draw_get_alpha());
				}
			}else{
				var rota = random_range(-6/10*max(timer - 65, 0), 6/10*max(timer - 65, 0));
				var scala = 0.2 + 0.015*(dsin(180/10*min(75 - timer, 10)) + dcos(90/5*clamp(70 - timer, 0, 5)));
				draw_text_transformed(1310, 847, "Hold " + indication[1] + " to Cancel", scala, scala, rota);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1), 1310 - (43*scala/0.2)*dcos(rota) - (4*scala/0.2)*dsin(rota), 850 - (4*scala/0.2)*dcos(rota) + (43*scala/0.2)*dsin(rota), 0.3*scala/0.2, 0.3*scala/0.2, rota, c_white, draw_get_alpha());
				}
			}}
			draw_set_alpha(1);
			draw_set_color(c_gray);
			draw_set_halign(fa_left);
			draw_text_transformed(data[0].x - 480, data[0].y - 15, "song name & artist", 0.2, 0.2, 0);
			draw_text_transformed(data[0].x - 50, data[0].y - 15, "level creator", 0.2, 0.2, 0);
			draw_text_transformed(data[0].x + 250, data[0].y - 15, "level type", 0.2, 0.2, 0);
			draw_text_transformed(data[0].x + 416, data[0].y - 15, "rank", 0.2, 0.2, 0);
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(2*data[1].scale.x, 2*data[1].scale.y);
			}else{ if (surface_get_width(surface[0]) != 2*data[1].scale.x or surface_get_height(surface[0]) != 2*data[1].scale.y){
				surface_resize(surface[0], 2*data[1].scale.x, 2*data[1].scale.y);
			}}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(data[3].sprite,data[3].index,data[3].x,data[3].y,data[3].scale.x,data[3].scale.y,data[3].angle,data[3].col,data[3].alpha);
			DrawSongs();
			var coloring = make_color_rgb(0,20,20);
			if (timer >= 45 + ((state == menu.playersOut) ? 1 : 0)){
				draw_set_color(c_white);
				for (var i=0;i<4;i++){
					draw_set_halign(fa_center);
					draw_text_transformed(1274 + 464*(i%2) - 1000*dsin(90/30*clamp(timer - 45, 0, 30)), 90 + 326*floor(i/2), "Player  " + string(i + 1), 0.4, 0.4, 0);
					draw_sprite_ext(spr_pixel, 0, 1274 + 464*(i%2) - 1000*dsin(90/30*clamp(timer - 45, 0, 30)), 284 + 326*floor(i/2), 176, 128, 0, coloring, 1);
					surface_reset_target();
					if (!surface_exists(surface[3])){
						surface[3] = surface_create(352, 256);
					}
					surface_set_target(surface[3]);
					draw_clear_alpha(c_black, 0);
					var aux = Levels[selected].play_as;
					with (configurations[i]){
						BeforeDraw();
						var length = array_length(player.layers);
						for (var j=0;j<length;j++){
							player.layers[j]();
						}
						Draw();
					}
					surface_reset_target();
					surface_set_target(surface[0]);
					draw_surface(surface[3], 1098 + 464*(i%2) - 1000*dsin(90/30*clamp(timer - 45, 0, 30)), 156 + 326*floor(i/2));
				}
				surface_reset_target();
				draw_set_halign(fa_left);
			}else{
				draw_set_color(c_white);
				draw_text_transformed(-980 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 114, "Difficulty:", 0.4, 0.4, 0);
				surface_reset_target();
				if (!surface_exists(surface[3])){
					surface[3] = surface_create(490,90);
				}
				surface_set_target(surface[3]);
				draw_clear_alpha(c_gray, 0);
				gpu_set_colorwriteenable(false, false, false, true);
				var diff = Levels[selected].difficulty;
				for (var i=diff;i<5;i++){
					draw_sprite_ext(spr_difficulty, i, 45 + 100*i, 45, 90/500, 90/500, 0, c_white, 1);
				}
				gpu_set_colorwriteenable(true, true, true, true);
				for (var i=0;i<diff;i++){
					draw_sprite_ext(spr_difficulty, i, 45 + 100*i, 45, 90/500, 90/500, (i == diff - 1) ? (15 - 15*min(timer2[0] - 146 - 5*i, 50)/50)*dsin(9*(timer2[0] - 116 - 5*i)) : 0, c_white, 1);
				}
				surface_reset_target();
				surface_set_target(surface[0]);
				draw_surface(surface[3], -720 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 100);
				var aux = ["None","Easy","Normal","Hard","Corrupted","Hardcore"];
				draw_set_color(make_color_rgb(255/4*max(diff - 1, 0) + ((diff == 0) ? 127 : 0),255 - 223/4*max(diff - 1, 0) - ((diff == 0) ? 128 : 0),255 - 143/4*max(diff - 1, 0) - ((diff == 0) ? 128 : 0)));
				draw_set_halign(fa_center);
				draw_text_transformed(-120 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 121, aux[diff], 0.3, 0.3, 0);
				draw_set_halign(fa_left);
				draw_set_color(c_white);
				draw_text_transformed(-980 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 194, "You play as:", 0.4, 0.4, 0);
				var aux = Levels[selected].play_as;
				draw_set_halign(fa_center);
				draw_text_transformed(-510 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 194, aux, 0.4, 0.4, 0);
				draw_set_color(make_color_rgb(0,169,169));
				var str = "This play mode doesn't exist.\nVerify you wrote it correctly.\nYou can only play in fragile\nmode until you fix this.";
				if (aux == "Shape"){
					str = "Shapes have the ability to dash\nthrough any pink obstacle to\navoid getting hit.\nHowever they have a slow\nmovement when they are not\ndashing.";
				}else{ if (aux == "Helicopter"){
					str = "Helicopter cannot dash, but it\nmoves faster than the Shapes.\nThey are not affected by any\nmovement on the level.\nJust be careful to not bonk its\nhead into the edges of the screen.";
				}else{ if (aux == "Boat"){
					str = "Coming soon...";
				}else{ if (aux == "Big Cube"){
					str = "Coming soon...";
				}else{ if (aux == "Multiple"){
					str = "Coming soon...";
				}else{ if (aux == "Missing"){
					str = "Details file missing.\nVerify that the details file is\nlocated in the folder of the level\nwith the correct name.\nYou can still play the level but only\nfragile mode until you fix this.";
				}}}}}}
				draw_text_transformed(-665 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 255, str, 0.3, 0.3, 0);
				draw_set_halign(fa_left);
				draw_set_color(c_white);
				draw_sprite_ext(spr_pixel, 0, -175 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 365, 155, 155, 0, coloring, 1);
				surface_reset_target();
				if (!surface_exists(surface[4])){
					surface[4] = surface_create(310,310);
				}
				surface_set_target(surface[4]);
				draw_clear_alpha(c_black,0);
				if (aux == "Shape" or aux == "Helicopter" or aux == "Boat" or aux == "Big Cube" or aux == "Multiple"){
					var player_array = [];
					with (obj_player){
						array_push(player_array, id);
					}
					if (array_length(player_array) > 0){
						DrawPlayers(player_array);
					}
				}else{
					draw_sprite_ext(spr_question, 0, 155, 155, 0.62, 0.62, 15*dsin(1.25*timer2[0]), make_color_rgb(0,127,127), 1);
				}
				surface_reset_target();
				surface_set_target(surface[0]);
				draw_surface(surface[4],-330 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)),210);
				draw_text_transformed(-980 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 544, "Play mode:", 0.4, 0.4, 0);
				if (selecting[0] >= 0){
					if (selecting[0] == 0){
						aux = "Normal";
					}else{ if (selecting[0] == 1){
						aux = "Casual";
					}else{ if (selecting[0] == 2){
						aux = "Unbreakable";
					}else{
						aux = "Fragile";
					}}}
				}else{
					aux = "Fragile";
				}
				draw_set_halign(fa_center);
				draw_text_transformed(-370 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 544, aux + " mode", 0.4, 0.4, irandom_range(-6/10*shake, 6/10*shake));
				if (selecting[0] >= 0){
					draw_sprite_ext(spr_triangle, 0, -650 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 572, 0.04, 0.04, 90, draw_get_color(), 1);
					draw_sprite_ext(spr_triangle, 0, -90 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 572, 0.04, 0.04, -90, draw_get_color(), 1);
				}
				if (aux == "Unbreakable"){
					draw_set_valign(fa_center);
					draw_set_color(make_color_rgb(0,255,255));
					draw_text_transformed(-550 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 669, "Infinite HP!", 0.4, 0.4, 10*dsin(timer2[0]));
					draw_set_color(make_color_rgb(255,32,112));
					draw_text_transformed(-190 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 669, "No ranking!", 0.4, 0.4, -10*dsin(timer2[0] - 45));
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_set_color(c_white);
					draw_text_transformed(-980 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 644, "HP:", 0.4, 0.4, 0);
					draw_sprite_ext(spr_hp, 0, -880 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 645, 60/108, 60/108, 0, c_white, 1);
				}else{ if (aux == "Fragile"){
					draw_set_valign(fa_center);
					draw_set_color(make_color_rgb(255,32,112));
					draw_text_transformed(-370 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 669, "No HP!", 0.4, 0.4, 10*dsin(timer2[0]));
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_set_color(c_white);
					draw_text_transformed(-980 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 644, "HP:", 0.4, 0.4, 0);
					draw_sprite_ext(spr_hp, 1, -880 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 645, 60/108, 60/108, 0, c_white, 1);
				}else{
					if (aux == "Casual"){
						draw_set_valign(fa_center);
						draw_set_color(make_color_rgb(0,255,255));
						draw_text_transformed(-550 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 669, "2x HP", 0.4, 0.4, 10*dsin(timer2[0]));
						draw_set_color(make_color_rgb(255,32,112));
						draw_text_transformed(-190 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 669, "No ranking!", 0.4, 0.4, -10*dsin(timer2[0] - 45));
						draw_set_valign(fa_top);
					}
					draw_set_halign(fa_left);
					draw_set_color(c_white);
					draw_text_transformed(-980 + 1000*dcos(90/30*clamp(timer - 15, 0, 30)), 644, "HP: " + string(max(Levels[selected].hp*(selecting[0] + 1), 3*(selecting[0] + 1))), 0.4, 0.4, 0);
				}}
				surface_reset_target();
			}
			draw_surface(surface[0], data[1].x - data[1].scale.x, data[1].y - data[1].scale.y);
		break;
		case menu.settings: case menu.settingsOut:
			draw_text_transformed(278, 12, "SELECT YOUR\nLEVEL", 0.5, 0.5, 0);
			if (mouse_x >= 694 + 25*(maincontrols != controls.keyboard) and mouse_x <= 985 - 25*(maincontrols != controls.keyboard) and mouse_y >= 840 and mouse_y <= 870 and cursor_sprite != -1 and state == menu.settings and timer >= 146){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(840, 847, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 793, 846, 0.3, 0.3, 0, c_white, 1);
			}
			draw_set_color(c_white);
			if (mouse_x >= 1186 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1434 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 840 and mouse_y <= 870 and cursor_sprite != -1 and state == menu.settings and timer >= 146){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(1310, 847, "Press " + indication[1] + " to Cancel", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1272, 846, 0.3, 0.3, 0, c_white, 1);
			}
			draw_set_color(c_gray);
			draw_set_halign(fa_left);
			draw_text_transformed(data[0].x - 480, data[0].y - 15, "song name & artist", 0.2, 0.2, 0);
			draw_text_transformed(data[0].x - 50, data[0].y - 15, "level creator", 0.2, 0.2, 0);
			draw_text_transformed(data[0].x + 250, data[0].y - 15, "level type", 0.2, 0.2, 0);
			draw_text_transformed(data[0].x + 416, data[0].y - 15, "rank", 0.2, 0.2, 0);
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(2*data[1].scale.x, 2*data[1].scale.y);
			}else{ if (surface_get_width(surface[0]) != 2*data[1].scale.x or surface_get_height(surface[0]) != 2*data[1].scale.y){
				surface_resize(surface[0], 2*data[1].scale.x, 2*data[1].scale.y);
			}}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(data[3].sprite,data[3].index,data[3].x,data[3].y,data[3].scale.x,data[3].scale.y,data[3].angle,data[3].col,data[3].alpha);
			DrawSongs();
			draw_set_color(c_white);
			if (selecting[0] >= 0){
				draw_sprite_ext(spr_pixel, 0, 500, 573, 1000, 32, 0, make_color_rgb(0,76,76), (timer >= 146));
			}
			draw_text_transformed(1020 - 1000*dsin(90/30*clamp(timer - 76, 0, 30)), 114, "Difficulty:", 0.4, 0.4, 0);
			surface_reset_target();
			if (!surface_exists(surface[3])){
				surface[3] = surface_create(490,90);
			}
			surface_set_target(surface[3]);
			draw_clear_alpha(c_gray, 0);
			gpu_set_colorwriteenable(false, false, false, true);
			var diff = Levels[selected].difficulty;
			var icon = (state == menu.settings) ? clamp(floor((timer - 111)/5), 0, diff) : diff;
			for (var i=icon;i<5;i++){
				draw_sprite_ext(spr_difficulty, i, 45 + 100*i, 45, 90/500, 90/500, 0, c_white, 1);
			}
			gpu_set_colorwriteenable(true, true, true, true);
			for (var i=0;i<icon;i++){
				draw_sprite_ext(spr_difficulty, i, 45 + 100*i, 45, 90/500, 90/500, (i == diff - 1) ? (15 - 15*min(timer2[0] - 146 - 5*i, 50)/50)*dsin(9*(timer2[0] - 116 - 5*i)) : 0, c_white, 1);
			}
			surface_reset_target();
			surface_set_target(surface[0]);
			draw_surface(surface[3], 1280 - 1000*dsin(90/30*clamp(timer - 76, 0, 30)), 100);
			var aux = ["None","Easy","Normal","Hard","Corrupted","Hardcore"];
			draw_set_color(make_color_rgb(255/4*max(diff - 1, 0) + ((diff == 0) ? 127 : 0),255 - 223/4*max(diff - 1, 0) - ((diff == 0) ? 128 : 0),255 - 143/4*max(diff - 1, 0) - ((diff == 0) ? 128 : 0)));
			draw_set_halign(fa_center);
			draw_text_transformed(1880 - 1000*dsin(90/30*clamp(timer - 76, 0, 30)), 121, aux[diff], 0.3, 0.3, 0);
			draw_set_halign(fa_left);
			draw_set_color(c_white);
			draw_text_transformed(1020 - 1000*dsin(90/30*clamp(timer - 72, 0, 30)), 194, "You play as:", 0.4, 0.4, 0);
			var aux = Levels[selected].play_as;
			draw_set_halign(fa_center);
			draw_text_transformed(1490 - 1000*dsin(90/30*clamp(timer - 72, 0, 30)), 194, aux, 0.4, 0.4, 0);
			draw_set_color(make_color_rgb(0,169,169));
			var str = "This play mode doesn't exist.\nVerify you wrote it correctly.\nYou can only play in fragile\nmode until you fix this.";
			if (aux == "Shape"){
				str = "Shapes have the ability to dash\nthrough any pink obstacle to\navoid getting hit.\nHowever they have a slow\nmovement when they are not\ndashing.";
			}else{ if (aux == "Helicopter"){
				str = "Helicopter cannot dash, but it\nmoves faster than the Shapes.\nThey are not affected by any\nmovement on the level.\nJust be careful to not bonk its\nhead into the edges of the screen.";
			}else{ if (aux == "Boat"){
				str = "Coming soon...";
			}else{ if (aux == "Big Cube"){
				str = "Coming soon...";
			}else{ if (aux == "Multiple"){
				str = "Coming soon...";
			}else{ if (aux == "Missing"){
				str = "Details file missing.\nVerify that the details file is\nlocated in the folder of the level\nwith the correct name.\nYou can still play the level but only\nfragile mode until you fix this.";
			}}}}}}
			draw_text_transformed(1335 - 1000*dsin(90/30*clamp(timer - 68, 0, 30)), 255, str, 0.3, 0.3, 0);
			draw_set_halign(fa_left);
			draw_set_color(c_white);
			draw_sprite_ext(spr_pixel, 0, 1825 - 1000*dsin(90/30*clamp(timer - 72, 0, 30)), 365, 155, 155, 0, make_color_rgb(0,20,20), 1);
			surface_reset_target();
			if (!surface_exists(surface[4])){
				surface[4] = surface_create(310,310);
			}
			surface_set_target(surface[4]);
			draw_clear_alpha(c_black,0);
			if (aux == "Shape" or aux == "Helicopter" or aux == "Boat" or aux == "Big Cube" or aux == "Multiple"){
				var player_array = [];
				with (obj_player){
					array_push(player_array, id);
				}
				if (array_length(player_array) > 0){
					DrawPlayers(player_array);
				}
			}else{
				draw_sprite_ext(spr_question, 0, 155, 155, 0.62, 0.62, 15*dsin(1.25*timer2[0]), make_color_rgb(0,127,127), 1);
			}
			surface_reset_target();
			surface_set_target(surface[0]);
			draw_surface(surface[4],1670 - 1000*dsin(90/30*clamp(timer - 72, 0, 30)),210);
			draw_text_transformed(1020 - 1000*dsin(90/30*clamp(timer - 64, 0, 30)), 544, "Play mode:", 0.4, 0.4, 0);
			if (selecting[0] >= 0){
				if (selecting[0] == 0){
					aux = "Normal";
				}else{ if (selecting[0] == 1){
					aux = "Casual";
				}else{ if (selecting[0] == 2){
					aux = "Unbreakable";
				}else{
					aux = "Fragile";
				}}}
			}else{
				aux = "Fragile";
			}
			draw_set_halign(fa_center);
			draw_text_transformed(1630 - 1000*dsin(90/30*clamp(timer - 64, 0, 30)), 544, aux + " mode", 0.4, 0.4, irandom_range(-6/10*shake, 6/10*shake));
			if (selecting[0] >= 0){
				if (timer >= 146){
					draw_set_color(make_color_rgb(0,255,255));
				}
				draw_sprite_ext(spr_triangle, 0, 1350 - 1000*dsin(90/30*clamp(timer - 64, 0, 30)), 572, 40/1000, 40/1000, 90, draw_get_color(), 1);
				draw_sprite_ext(spr_triangle, 0, 1910 - 1000*dsin(90/30*clamp(timer - 64, 0, 30)), 572, 40/1000, 40/1000, -90, draw_get_color(), 1);
			}
			if (aux == "Unbreakable"){
				draw_set_valign(fa_center);
				draw_set_color(make_color_rgb(0,255,255));
				draw_text_transformed(1450 - 1000*dsin(90/30*clamp(timer - 60, 0, 30)), 669, "Infinite HP!", 0.4, 0.4, 10*dsin(timer2[0]));
				draw_set_color(make_color_rgb(255,32,112));
				draw_text_transformed(1810 - 1000*dsin(90/30*clamp(timer - 60, 0, 30)), 669, "No ranking!", 0.4, 0.4, -10*dsin(timer2[0] - 45));
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_set_color(c_white);
				draw_text_transformed(1020 - 1000*dsin(90/30*clamp(timer - 56, 0, 30)), 644, "HP:", 0.4, 0.4, 0);
				draw_sprite_ext(spr_hp, 0, 1120 - 1000*dsin(90/30*clamp(timer - 56, 0, 30)), 645, 60/108, 60/108, 0, c_white, 1);
			}else{ if (aux == "Fragile"){
				draw_set_valign(fa_center);
				draw_set_color(make_color_rgb(255,32,112));
				draw_text_transformed(1630 - 1000*dsin(90/30*clamp(timer - 60, 0, 30)), 669, "No HP!", 0.4, 0.4, 10*dsin(timer2[0]));
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_set_color(c_white);
				draw_text_transformed(1020 - 1000*dsin(90/30*clamp(timer - 56, 0, 30)), 644, "HP:", 0.4, 0.4, 0);
				draw_sprite_ext(spr_hp, 1, 1120 - 1000*dsin(90/30*clamp(timer - 56, 0, 30)), 645, 60/108, 60/108, 0, c_white, 1);
			}else{
				if (aux == "Casual"){
					draw_set_valign(fa_center);
					draw_set_color(make_color_rgb(0,255,255));
					draw_text_transformed(1450 - 1000*dsin(90/30*clamp(timer - 60, 0, 30)), 669, "2x HP", 0.4, 0.4, 10*dsin(timer2[0]));
					draw_set_color(make_color_rgb(255,32,112));
					draw_text_transformed(1810 - 1000*dsin(90/30*clamp(timer - 60, 0, 30)), 669, "No ranking!", 0.4, 0.4, -10*dsin(timer2[0] - 45));
					draw_set_valign(fa_top);
				}
				draw_set_halign(fa_left);
				draw_set_color(c_white);
				draw_text_transformed(1020 - 1000*dsin(90/30*clamp(timer - 56, 0, 30)), 644, "HP: " + string(max(Levels[selected].hp*(selecting[0] + 1), 3*(selecting[0] + 1))), 0.4, 0.4, 0);
			}}
			surface_reset_target();
			draw_surface(surface[0], data[1].x - data[1].scale.x, data[1].y - data[1].scale.y);
		break;
		case menu.levels: case menu.levelsOut:
			if (state == menu.levels){
				draw_set_alpha(clamp(25 - timer, 0, 10)/10);
			}else{ if (state == menu.levelsOut and timer >= 30){
				draw_set_alpha(data[1].alpha);
			}else{
				draw_set_alpha(0);
			}}
			draw_text_transformed(260, 857, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 213, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_text_transformed(1340, 857, "Press " + indication[1] + " to Quit", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1317, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			if ((timer >= 55 and state == menu.levels) or (timer < 30 and state == menu.levelsOut)){
				draw_set_alpha(data[2].alpha);
				if (mouse_x >= 694 + 25*(maincontrols != controls.keyboard) and mouse_x <= 985 - 25*(maincontrols != controls.keyboard) and mouse_y >= 840 and mouse_y <= 870 and cursor_sprite != -1 and state == menu.levels and timer >= 123){
					draw_set_color(c_yellow);
				}
				draw_text_transformed(840, 847, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 793, 846, 0.3, 0.3, 0, c_white, draw_get_alpha());
				}
				draw_set_color(c_white);
				if (mouse_x >= 1186 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1434 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 840 and mouse_y <= 870 and cursor_sprite != -1 and state == menu.levels and timer >= 123){
					draw_set_color(c_yellow);
				}
				draw_text_transformed(1310, 847, "Press " + indication[1] + " to Cancel", 0.2, 0.2, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1272, 846, 0.3, 0.3, 0, c_white, draw_get_alpha());
				}
				draw_set_color(c_white);
			}
			if ((timer >= 25 and state == menu.levels) or (timer < 30 and state == menu.levelsOut)){
				draw_set_alpha(1);
				if (state == menu.levels){
					draw_text_transformed(278, 12 - 200*dcos(90/30*min(timer - 25, 30)), "SELECT YOUR\nLEVEL", 0.5, 0.5, 0);
				}else{
					draw_text_transformed(278, 12 - 200*dsin(90/30*timer), "SELECT YOUR\nLEVEL", 0.5, 0.5, 0);
				}
				draw_set_color(make_color_rgb(0,76,76));
				var header = {x: data[0].x, y: data[0].y};
				if (timer < 55 and state == menu.levels){
					header = {x: data[1].x, y: data[1].y}
				}
				draw_set_color(c_gray);
				draw_set_halign(fa_left);
				draw_text_transformed(header.x - 480, header.y - 15, "song name & artist", 0.2, 0.2, 0);
				draw_text_transformed(header.x - 50, header.y - 15, "level creator", 0.2, 0.2, 0);
				draw_text_transformed(header.x + 250, header.y - 15, "level type", 0.2, 0.2, 0);
				draw_text_transformed(header.x + 416, header.y - 15, "rank", 0.2, 0.2, 0);
				if ((timer > 65 and data[1].scale.y >= 1) or state == menu.levelsOut){
					if (!surface_exists(surface[0])){
						surface[0] = surface_create(2*data[1].scale.x, 2*data[1].scale.y);
					}else{ if (surface_get_width(surface[0]) != 2*data[1].scale.x or surface_get_height(surface[0]) != 2*data[1].scale.y){
						surface_resize(surface[0], 2*data[1].scale.x, 2*data[1].scale.y);
					}}
					surface_set_target(surface[0]);
					draw_clear_alpha(c_black, 0);
					if (timer >= 122){
						draw_sprite_ext(data[3].sprite,data[3].index,data[3].x,data[3].y,data[3].scale.x,data[3].scale.y,data[3].angle,data[3].col,data[3].alpha);
					}
					DrawSongs();
					surface_reset_target();
					draw_surface(surface[0], data[1].x - data[1].scale.x, data[1].y - data[1].scale.y);
				}
			}
		break;
		case menu.nolevelsOut:
			draw_set_alpha(max(30 - timer, 0)/30);
			var col = make_color_rgb(255,32,112);
			draw_text_transformed_color(800, 162, "There are no levels!", 0.8, 0.8, 0, col, col, col, col, draw_get_alpha());
			col = make_color_rgb(0,255,255);
			draw_text_transformed_color(800, 322, "It seems you have no levels to play with on this game,\nplease verify that there are levels in the Levels folder\nnext to this game's executable and that they have the\ncorrect structure and names to be able to identify\nand load them into the game.", 0.4, 0.4, 0, col, col, col, col, draw_get_alpha());
			draw_text_transformed(800, 691, "Press " + indication[0] + " to Go Back", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 753, 690, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
		break;
		case menu.nolevels:
			draw_set_alpha(clamp(timer - 20, 0, 30)/30);
			var col = make_color_rgb(255,32,112);
			draw_text_transformed_color(800, 162, "There are no levels!", 0.8, 0.8, 0, col, col, col, col, draw_get_alpha());
			col = make_color_rgb(0,255,255);
			draw_text_transformed_color(800, 322, "It seems you have no levels to play with on this game,\nplease verify that there are levels in the Levels folder\nnext to this game's executable and that they have the\ncorrect structure and names to be able to identify\nand load them into the game.", 0.4, 0.4, 0, col, col, col, col, draw_get_alpha());
			if (mouse_x >= 650 + 25*(maincontrols != controls.keyboard) and mouse_x <= 950 - 25*(maincontrols != controls.keyboard) and mouse_y >= 694 and mouse_y <= 724){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(800, 691, "Press " + indication[0] + " to Go Back", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 753, 690, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_set_color(c_white);
		break;
		case menu.credits: case menu.creditsOut:
			draw_set_alpha(clamp(45 - timer, 0, 20)/20);
			draw_text_transformed(260, 857, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 213, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_text_transformed(1340, 857, "Press " + indication[1] + " to Quit", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1317, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_set_alpha(clamp(timer - 45, 0, 30)/30);
			draw_set_color(make_color_rgb(255,32,112));
			draw_text_transformed(800, 3, "Credits", 0.8, 0.8, 0);
			draw_set_color(make_color_rgb(0,255,255));
			draw_text_transformed(800, 114, "Just Shapes & Beats is property of Berzerk Studio.", 0.4, 0.4, 0);
			draw_text_transformed(800, 194, "Game made by Cezar Andrade.", 0.4, 0.4, 0);
			draw_text_transformed(800, 274, "Menu music by Danimmal Cannon. (from the original JS&B)", 0.4, 0.4, 0);
			draw_set_color(c_white);
			if (mouse_x >= 582 + 25*(maincontrols != controls.keyboard) and mouse_x <= 1020 - 25*(maincontrols != controls.keyboard) and mouse_y >= 428 and mouse_y <= 460){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(800, 419, "Press " + indication[0] + " to Go Back", 0.3, 0.3, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 730, 418, 0.45, 0.45, 0, c_white, draw_get_alpha());
			}
			draw_set_color(c_white);
		break;
		case menu.options: case menu.optionsOut:
			draw_set_alpha(clamp(75 - timer, 0, 60)/60);
			draw_text_transformed(260, 857, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 213, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_text_transformed(1340, 857, "Press " + indication[1] + " to Quit", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1317, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			if (data[4].scale.x > 0 and data[4].scale.y > 0){
				if (!surface_exists(surface[0])){
					surface[0] = surface_create(2*data[4].scale.x, 2*data[4].scale.y);
				}else{ if (surface_get_width(surface[0]) != 2*data[4].scale.x or surface_get_height(surface[0]) != 2*data[4].scale.y){
					surface_resize(surface[0], 2*data[4].scale.x, 2*data[4].scale.y);
				}}
				if (!surface_exists(surface[1])){
					surface[1] = surface_create(2*data[4].scale.x, 2*data[4].scale.y);
				}else{ if (surface_get_width(surface[1]) != 2*data[4].scale.x or surface_get_height(surface[1]) != 2*data[4].scale.y){
					surface_resize(surface[1], 2*data[4].scale.x, 2*data[4].scale.y);
				}}
				surface_set_target(surface[0]);
				draw_clear_alpha(c_black, 0);
				draw_set_alpha(clamp(timer - 45, 0, 30)/30);
				if (timer > 90){
					draw_set_color(make_color_rgb(0, 99, 99));
					draw_rectangle(-250 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -97 + 100*dsin(90/30*clamp(timer - 45, 0, 30)) + 34*selecting[3], 250 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -62 + 100*dsin(90/30*clamp(timer - 45, 0, 30)) + 34*selecting[3], false);
					draw_set_color(c_white);
				}
				draw_set_halign(fa_left);
				draw_text_transformed(-240 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -95 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), "Music:", 0.2, 0.2, 0);
				draw_text_transformed(-240 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -61 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), "Sound:", 0.2, 0.2, 0);
				surface_reset_target();
				surface_set_target(surface[1]);
				draw_clear_alpha(c_black, 0);
				for (var i=0;i<10;i++){
					draw_sprite_ext(spr_bar, ((i + 1)/10 > Volume.music), -140 + 26*i + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -80 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 30/36, 30/36, 0, c_white, 1);
					draw_sprite_ext(spr_bar, ((i + 1)/10 > Volume.sounds), -130 + 26*i + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -46 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 30/36, 30/36, 0, c_white, 1);
				}
				if (selecting[0] == 2){
					draw_set_color(make_color_rgb(0,255,255));
				}
				draw_sprite_ext(spr_triangle, 0, 16 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -12 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 20/1000, 20/1000, 90, draw_get_color(), 1);
				draw_sprite_ext(spr_triangle, 0, 173 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -12 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 20/1000, 20/1000, -90, draw_get_color(), 1);
				draw_set_color(c_white);
				if (selecting[0] == 3){
					draw_set_color(make_color_rgb(0,255,255));
				}
				draw_sprite_ext(spr_triangle, 0, -90 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 22 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 20/1000, 20/1000, 90, draw_get_color(), 1);
				draw_sprite_ext(spr_triangle, 0, -15 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 22 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 20/1000, 20/1000, -90, draw_get_color(), 1);
				draw_set_color(c_white);
				if (selecting[0] == 4){
					draw_set_color(make_color_rgb(0,255,255));
				}
				draw_sprite_ext(spr_triangle, 0, 50 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 56 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 20/1000, 20/1000, 90, draw_get_color(), 1);
				draw_sprite_ext(spr_triangle, 0, 124 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 56 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 20/1000, 20/1000, -90, draw_get_color(), 1);
				draw_set_color(c_white);
				surface_reset_target();
				surface_set_target(surface[0]);
				draw_text_transformed(-240 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -27 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), "Screen Resolution:", 0.2, 0.2, 0);
				draw_set_halign(fa_center);
				draw_set_valign(fa_center);
				draw_text_transformed(95 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), -11 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), string(Resolutions[res].x) + "x" + string(Resolutions[res].y), 0.2, 0.2, irandom_range(-6/10*selecting[4], 6/10*selecting[4]));
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_text_transformed(-240 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 7 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), "Fullscreen:", 0.2, 0.2, 0);
				draw_set_halign(fa_center);
				draw_set_valign(fa_center);
				draw_text_transformed(-52 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 23 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), (window_get_fullscreen()) ? "On" : "Off", 0.2, 0.2, irandom_range(-6/10*selecting[5], 6/10*selecting[5]));
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_text_transformed(-240 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 41 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), "Photosensitive Mode:", 0.2, 0.2, 0);
				draw_set_halign(fa_center);
				draw_set_valign(fa_center);
				draw_text_transformed(86 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 57 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), (Photosensitive) ? "On" : "Off", 0.2, 0.2, irandom_range(-6/10*selecting[6], 6/10*selecting[6]));
				draw_set_color(make_color_rgb(127, 127, 127));
				draw_set_halign(fa_center);
				draw_set_valign(fa_top);
				if (cursor_sprite != -1 and mouse_x >= 644 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 956 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 871 and mouse_y <= 884){
					draw_set_color(c_white);
				}
				draw_text_transformed(250*dsin(90/30*clamp(timer - 45, 0, 30)), 77 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), "Press " + indication[1] + " to Save Changes and Go Back", 0.125, 0.125, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), -103 + 250*dsin(90/30*clamp(timer - 45, 0, 30)), 78 + 100*dsin(90/30*clamp(timer - 45, 0, 30)), 0.1875, 0.1875, 0, c_white, draw_get_alpha());
				}
				draw_set_color(c_white);
				surface_reset_target();
				draw_surface(surface[0], 800 - 250*dsin(90/30*clamp(timer - 45, 0, 30)), 790 - 100*dsin(90/30*clamp(timer - 45, 0, 30)));
				draw_surface(surface[1], 800 - 250*dsin(90/30*clamp(timer - 45, 0, 30)), 790 - 100*dsin(90/30*clamp(timer - 45, 0, 30)));
			}
		break;
		case menu.quitOut:
			draw_set_alpha(max(30 - timer, 0)/30);
			var col = make_color_rgb(255,32,112);
			draw_text_transformed_color(800, 370, "Quit the Game?", 0.8, 0.8, 0, col, col, col, col, draw_get_alpha());
			draw_text_transformed(500, 497, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 453, 496, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_text_transformed(1100, 497, "Press " + indication[1] + " to Cancel", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1061, 496, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
		break;
		case menu.quit:
			draw_set_alpha(clamp(timer - 20, 0, 30)/30);
			var col = make_color_rgb(255,32,112);
			draw_text_transformed_color(800, 370, "Quit the Game?", 0.8, 0.8, 0, col, col, col, col, draw_get_alpha());
			if (cursor_sprite != -1 and mouse_x >= 340 + 25*(maincontrols != controls.keyboard) and mouse_x <= 660 - 25*(maincontrols != controls.keyboard) and mouse_y >= 500 and mouse_y <= 530){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(500, 497, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 453, 496, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_set_color(c_white);
			if (cursor_sprite != -1 and mouse_x >= 980 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1220 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 500 and mouse_y <= 530){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(1100, 497, "Press " + indication[1] + " to Cancel", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1061, 496, 0.3, 0.3, 0, c_white, draw_get_alpha());
			}
			draw_set_color(c_white);
		break;
		case menu.title:
			if (cursor_sprite != -1 and mouse_x >= 156 + 25*(maincontrols != controls.keyboard) and mouse_x <= 405 - 25*(maincontrols != controls.keyboard) and mouse_y >= 850 and mouse_y <= 880){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(260, 857, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 213, 856, 0.3, 0.3, 0, c_white, 1);
			}
			draw_set_color(c_white);
			if (cursor_sprite != -1 and mouse_x >= 1236 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1444 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 850 and mouse_y <= 880){
				draw_set_color(c_yellow);
			}
			draw_text_transformed(1340, 857, "Press " + indication[1] + " to Quit", 0.2, 0.2, 0);
			if (maincontrols != controls.keyboard){
				draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1317, 856, 0.3, 0.3, 0, c_white, 1);
			}
			draw_set_color(c_white);
		break;
		case menu.intro:
			draw_set_alpha(0);
			if (audio_get_name(music) == "mus_intro" and SongTime > 9.875){
				draw_set_alpha(min(SongTime - 9.875, 0.075)/0.075);
			}else{ if (not (audio_get_name(music) == "mus_intro") and timer <= 60){
				draw_set_alpha(max(30 - timer, 0)/30);
			}}
			draw_rectangle(0,0,1600,900,false);
			if (not (audio_get_name(music) == "mus_intro")){
				draw_set_alpha(clamp(timer - 270, 0, 30)/30);
				draw_text_transformed(260, 857, "Press " + indication[0] + " to Confirm", 0.2, 0.2, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 6 : ((maincontrols == controls.generic) ? 2 + 2*floor(buttoff/2) : 2*floor(buttoff/2)), 213, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
				}
				draw_text_transformed(1340, 857, "Press " + indication[1] + " to Quit", 0.2, 0.2, 0);
				if (maincontrols != controls.keyboard){
					draw_sprite_ext(spr_cont_butt, (zurdo) ? 7 : ((maincontrols == controls.generic) ? 3 + 2*floor(buttoff/2) : 1 + 2*floor(buttoff/2)), 1317, 856, 0.3, 0.3, 0, c_white, draw_get_alpha());
				}
			}
		break;
	}
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	for (var i=0;i<array_length(data);i++){
		var thing = data[i];
		if (variable_struct_exists(thing, "ontop")){
			if (variable_struct_exists(thing, "particles")){
				for (var j=0;j<array_length(thing.particles);j++){
					var thing2 = thing.particles[j];
					thing2.x -= thing2.speed*dcos(thing2.dir);
					thing2.y += thing2.speed*dsin(thing2.dir);
					thing2.alpha -= 0.04;
					if (thing2.alpha <= 0){
						array_delete(thing.particles, j, 1);
						j--;
					}else{
						draw_sprite_ext(spr_pixel, 0, thing2.x, thing2.y, 4 + thing2.size*thing2.alpha, 4 + thing2.size*thing2.alpha, 0, make_color_rgb(0, 179, 179), thing2.alpha);
					}
				}
			}else{ if (variable_struct_exists(thing, "icons")){
				var diff = Levels[selected].difficulty - 1;
				for (var j=0;j<array_length(thing.icons);j++){
					var thing2 = thing.icons[j];
					thing2.timer++;
					if (thing2.timer > 0){
						thing2.scale.x = (90 + 90*dcos(9*min(thing2.timer, 10)) + 4.5*max(thing2.timer - 10, 0))/500;
						thing2.scale.y = thing2.scale.x;
						thing2.alpha = 1 - dcos(9*min(thing2.timer, 10)) - 0.02*max(thing2.timer - 10, 0);
						if (thing2.timer == 10){
							audio_play_sound(snd_difficulty, 0, false);
							if (thing2.index != diff){
								array_delete(thing.icons, j, 1);
								j--;
							}
						}else{ if (thing2.alpha <= 0){
							array_delete(thing.icons, j, 1);
							j--;
						}}
					}
					draw_sprite_ext(thing2.sprite,thing2.index,thing2.x,thing2.y,thing2.scale.x,thing2.scale.y,thing2.angle,thing2.col,thing2.alpha);
				}
			}else{ if (not variable_struct_exists(thing, "notdraw")){
				draw_sprite_ext(thing.sprite,thing.index,thing.x,thing.y,thing.scale.x,thing.scale.y,thing.angle,thing.col,thing.alpha);
			}}}
		}
	}
}