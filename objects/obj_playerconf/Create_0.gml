control_type = controls.keyboard;
control_id = 0;
zurdo = false;
confirming = true;
var colspec = make_color_hsv(hue, saturation, value);
player = instance_create_depth(176, (Mode == mode.helicopter) ? 52 : 55, 0, obj_player, {modo: (Mode != mode.none) ? Mode : mode.shape, red: color_get_red(colspec), green: color_get_green(colspec), blue: color_get_blue(colspec), index: index});
with (player){
	if (modo == mode.shape){
		limits.right = 336;
		limits.down = 240;
	}else{ if (modo == mode.helicopter){
		limits.right = 324;
		limits.down = 228;
	}}
	if (modo == mode.helicopter){
		x += 20;
	}
	if (index >= 4){
		var specil_data = Player_icons[index - 4];
		special_data.sprite = specil_data.sprite;
		special_data.spr_inside = specil_data.spr_inside;
		special_data.spr_mask = specil_data.spr_mask;
		special_data.playerrot = specil_data.playerrot;
		special_data.shaperange = specil_data.shaperange;
	}else{
		if (index%2 == 0){
			special_data.playerrot = 45;
			special_data.shaperange = 42;
		}else{ if (index == 3){
			special_data.shaperange = 39;
		}}
	}
	image_alpha = 0;
	control_type = other.control_type;
	control_id = other.control_id;
	zurdo = other.zurdo;
	AI = false;
	Inmovil = true;
}
state = config.waiting;
selecting = 0;
mul = 1;
timer = [0, 0, 0];
surface = -1;
pos = [0, 0];
BeforeDraw = function(){
	if (state == config.coloring){
		if (selecting == 0){
			draw_sprite_ext(spr_pixel, 0, 176, 62 - 10*mul, 176, 62 - 10*mul, 0, make_color_rgb(0,76,76), 1);
		}else{
			draw_sprite_ext(spr_pixel, 0, 176, 84 + 40*selecting, 176, 20, 0, make_color_rgb(0,76,76), 1);
		}
	}
}
Draw = function(){
	switch (state){
		case config.waiting:
			draw_set_valign(fa_center);
			draw_text_transformed(176,128,"Press Space\nto join",0.4,0.4,0);
			draw_set_valign(fa_top);
		break;
		case config.coloring:
			if (selecting == 0){
				draw_set_color(make_color_rgb(0, 255, 255));
			}
			draw_sprite_ext(spr_triangle, 0, 76, 62 - 10*mul, 0.04, 0.04, 90, draw_get_color(), 1);
			draw_sprite_ext(spr_triangle, 0, 276, 62 - 10*mul, 0.04, 0.04, -90, draw_get_color(), 1);
			draw_sprite_ext(spr_triangle, 0, 40, 14, 0.02, 0.014, 0, draw_get_color(), 1);
			draw_sprite_ext(spr_triangle, 0, 100, 14, 0.02, 0.014, 0, draw_get_color(), 1);
			draw_sprite_ext(spr_triangle, 0, 252, 14, 0.02, 0.014, 0, draw_get_color(), 1);
			draw_sprite_ext(spr_triangle, 0, 312, 14, 0.02, 0.014, 0, draw_get_color(), 1);
			draw_set_color(c_white);
			draw_set_halign(fa_left);
			draw_text_transformed(20,126 - 20*mul,"Hue:",0.3,0.3,0);
			draw_text_transformed(20,156 - 10*mul,"Sat:",0.3,0.3,0);
			draw_text_transformed(20,186,"Val:",0.3,0.3,0);
			draw_text_transformed(290,134 - 20*mul,string(hue),0.15,0.15,0);
			draw_text_transformed(290,164 - 10*mul,string(saturation),0.15,0.15,0);
			draw_text_transformed(290,194,string(value),0.15,0.15,0);
			var color11 = make_color_hsv(hue, 0, value);
			var color12 = make_color_hsv(hue, 255, value);
			var color21 = make_color_hsv(hue, saturation, 0);
			var color22 = make_color_hsv(hue, saturation, 255);
			draw_sprite_ext(spr_hsv, 0, 120, 132 - 20*mul, 161/290, 1, 0, c_white, 1);
			draw_rectangle_color(120,162 - 10*mul,280,186 - 10*mul,color11,color12,color12,color11,false);
			draw_rectangle_color(120,192,280,216,color21,color22,color22,color21,false);
			draw_sprite_ext(spr_triangle, 0, 120 + 160*hue/255, 132 - 20*mul, 0.015, 0.015, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 120 + 160*saturation/255, 162 - 10*mul, 0.015, 0.015, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 120 + 160*value/255, 192, 0.015, 0.015, 180, c_white, 1);
			draw_set_halign(fa_center);
		break;
		case config.players: case config.playersOut:
			draw_sprite_ext(spr_pixel, 0, 176, -22.5 - 128*dcos(180*min(timer[0], 30)/30), 176, 105.5, 0, make_color_hsv(hue, saturation, 127), 1);
			if (!surface_exists(surface)){
				surface = surface_create(348, 207);
			}
			surface_reset_target();
			surface_set_target(surface);
			draw_clear_alpha(c_white, 0);
			for (var i=0;i<5;i++){
				draw_sprite_ext(spr_row, 0, 5, 5 + 51*i - (51*pos[1])%51, 1, 1, 0, make_color_hsv(0, 0, 0), 1);
				for (var j=7*(floor(pos[1])+i);j<min(7*(floor(pos[1])+i+1),4+array_length(Player_icons));j++){
					if (j == selecting and timer[0] > 30){
						draw_sprite_ext(spr_pixel, 0, 27 + 49*(j%7), 27 + 51*floor(j/7) - 51*pos[1], 22, 22, 0, make_color_hsv(hue, saturation, 48 + 32*dcos(9*timer[0])), 1);
					}
					draw_sprite_ext((j <= 3) ? spr_playeroutside : Player_icons[j-4].sprite, (j <= 3) ? j : 0, 27 + 49*(j%7), 27 + 51*i - (51*pos[1])%51, 0.32, 0.32, 0, make_color_hsv(hue, saturation, value), 1);
					if (j >= 4 and Player_icons[j-4].spr_mask){
						draw_sprite_ext(Player_icons[j-4].sprite, 2, 27 + 49*(j%7), 27 + 51*i - (51*pos[1])%51, 0.32, 0.32, 0, c_white, 1);
					}
					if (j == index){
						draw_sprite_ext(spr_selected, 0, 5 + 49*(j%7), 5 + 51*floor(j/7) - 51*pos[1], 1, 1, 0, make_color_hsv(hue, saturation, 255), 1);
					}
				}
			}
			surface_reset_target();
			surface_set_target(other.surface[3]);
			draw_surface(surface, 2, -126 - 128*dcos(180*min(timer[0], 30)/30));
			draw_sprite_ext(spr_triangle, 0, 40, 114 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 100, 114 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 252, 114 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 312, 114 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 76, 190 - 10*mul - 128*dcos(180*min(timer[0], 30)/30), 0.04, 0.04, 90, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 276, 190 - 10*mul - 128*dcos(180*min(timer[0], 30)/30), 0.04, 0.04, -90, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 40, 142 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 0, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 100, 142 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 0, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 252, 142 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 0, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 312, 142 - 128*dcos(180*min(timer[0], 30)/30), 0.02, 0.014, 0, c_white, 1);
			draw_set_color(c_white);
			draw_set_halign(fa_left);
			draw_text_transformed(20,254 - 20*mul - 128*dcos(180*min(timer[0], 30)/30),"Hue:",0.3,0.3,0);
			draw_text_transformed(20,284 - 10*mul - 128*dcos(180*min(timer[0], 30)/30),"Sat:",0.3,0.3,0);
			draw_text_transformed(20,314 - 128*dcos(180*min(timer[0], 30)/30),"Val:",0.3,0.3,0);
			draw_text_transformed(290,262 - 20*mul - 128*dcos(180*min(timer[0], 30)/30),string(hue),0.15,0.15,0);
			draw_text_transformed(290,292 - 10*mul - 128*dcos(180*min(timer[0], 30)/30),string(saturation),0.15,0.15,0);
			draw_text_transformed(290,322 - 128*dcos(180*min(timer[0], 30)/30),string(value),0.15,0.15,0);
			var color11 = make_color_hsv(hue, 0, value);
			var color12 = make_color_hsv(hue, 255, value);
			var color21 = make_color_hsv(hue, saturation, 0);
			var color22 = make_color_hsv(hue, saturation, 255);
			draw_sprite_ext(spr_hsv, 0, 120, 260 - 20*mul - 128*dcos(180*min(timer[0], 30)/30), 161/290, 1, 0, c_white, 1);
			draw_rectangle_color(120,290 - 10*mul - 128*dcos(180*min(timer[0], 30)/30),280,314 - 10*mul - 128*dcos(180*min(timer[0], 30)/30),color11,color12,color12,color11,false);
			draw_rectangle_color(120,320 - 128*dcos(180*min(timer[0], 30)/30),280,344 - 128*dcos(180*min(timer[0], 30)/30),color21,color22,color22,color21,false);
			draw_sprite_ext(spr_triangle, 0, 120 + 160*hue/255, 260 - 20*mul - 128*dcos(180*min(timer[0], 30)/30), 0.015, 0.015, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 120 + 160*saturation/255, 290 - 10*mul - 128*dcos(180*min(timer[0], 30)/30), 0.015, 0.015, 180, c_white, 1);
			draw_sprite_ext(spr_triangle, 0, 120 + 160*value/255, 320 - 128*dcos(180*min(timer[0], 30)/30), 0.015, 0.015, 180, c_white, 1);
			draw_set_halign(fa_center);
		break;
	}
	if (state == config.done){
		draw_set_color(make_color_hsv(hue, saturation, value));
		draw_text_transformed(176,150,"Ready!",0.4,0.4,0);
		draw_set_color(make_color_hsv(0,0,64));
		draw_text_transformed(176,220,"Press ESC to Go Back",0.2,0.2,0);
		draw_set_color(c_white);
	}else{ if (state != config.waiting){
		var indications = ["Use Arrows to Move", "Press Space to Finish", "Press ESC to Leave"];
		draw_text_transformed(176,358 - ((state == config.coloring) ? 128 : 128*dcos(180*min(timer[0], 30)/30)),indications[floor(indication/2)],0.175,0.175,0);
		if (state != config.coloring){
			indications[1] = "Press Space to Select";
			indications[2] = "Press ESC to Go Back";
			draw_text_transformed(176,84 - 128*dcos(180*min(timer[0], 30)/30),indications[floor(indication/2)],0.175,0.175,0);
		}
	}}
}