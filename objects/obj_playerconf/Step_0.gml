if (obj_game.state == menu.players){
	if (state == config.done){
		if (CheckControlInput(control_type, zurdo, action.cancel, false, control_id)){
			state = config.coloring;
			selecting = 0;
			with (player){
				Inmovil = true;
				array_delete(particles, 0, array_length(particles));
				if (modo == mode.helicopter){
					x = 196;
					py = 52;
					facing = 1;
					knockout = 0;
					bounce.timer = 30;
					vel.x = 0;
					vel.y = 0;
					handsrot = 180;
					eyes.x = 0
					eyes.y = 0
					eyes.index = 0;
					head.x = 0.75;
					head.y = 0.75;
					body.x = 0.75;
					body.rot = 0;
					halo.rot = 0;
				}else{
					x = 176;
					y = 55;
					timer.idle = 0;
					image_angle = 0;
					vel.current = vel.normal;
					timer.dash = 0;
				}
			}
		}
	}else{ if (state != config.waiting){
		if (Mode == mode.helicopter){
			mul += (((state == config.coloring) ? min(selecting, 1) : 0) - mul)/4;
		}
		var songtimee = floor(SongTime/0.48);
		if (songtime != songtimee){
			songtime = songtimee;
			indication++;
			indication %= 6;
		}
		if (state == config.coloring){
			if (Mode == mode.helicopter){
				player.py = 52 - 10*mul;
			}
			if (CheckControlInput(control_type, zurdo, action.vertical, false, control_id) > 0){
				timer[0]++;
				if (selecting < 3 and (timer[0] == 1 or (timer[0] > 30 and timer[0]%6 == 0))){
					selecting++;
					audio_play_sound(snd_selecting, 0, false);
				}
			}else{ if (CheckControlInput(control_type, zurdo, action.vertical, false, control_id) < 0){
				timer[0]++;
				if (timer[0] == 1 or (timer[0] > 30 and timer[0]%6 == 0)){
					if (timer[0] == 1 and selecting == 0){
						state = config.players;
						timer[0] = 0;
						selecting = index;
						player.limits.down += 100;
						if (selecting >= 21){
							pos[0] = floor(selecting/7) - 2;
							pos[1] = pos[0];
						}
						audio_play_sound(snd_selecting, 0, false);
					}
					if (selecting > 0 and state == config.coloring){
						selecting--;
						audio_play_sound(snd_selecting, 0, false);
					}
				}
			}else{
				timer[0] = 0;
			}}
			var prevI = index;
			var prevH = hue;
			var prevS = saturation;
			var prevV = value;
			if (CheckControlInput(control_type, zurdo, action.horizontal, false, control_id) > 0){
				if (timer[1]%((timer[1] < 50) ? 30 : 6 - min(3*floor((timer[1] - 50)/15), 5)) == 0){
					switch (selecting){
						case 0:
							index++;
							index %= sprite_get_number(spr_playeroutside) + array_length(Player_icons);
							audio_play_sound(snd_selecting, 0, false);
						break;
						case 1:
							if (hue < 255){
								hue++;
								timer[1] = max(timer[1], 50);
								audio_play_sound(snd_selecting, 0, false);
							}
						break;
						case 2:
							if (saturation < 255){
								saturation++;
								timer[1] = max(timer[1], 50);
								audio_play_sound(snd_selecting, 0, false);
							}
						break;
						case 3:
							if (value < 255){
								value++;
								timer[1] = max(timer[1], 50);
								audio_play_sound(snd_selecting, 0, false);
							}
						break;
					}
				}
				timer[1]++;
			}else{ if (CheckControlInput(control_type, zurdo, action.horizontal, false, control_id) < 0){
				if (timer[1]%((timer[1] < 50) ? 30 : 6 - min(3*floor((timer[1] - 50)/15), 5)) == 0){
					switch (selecting){
						case 0:
							index--;
							if (index < 0){
								index = sprite_get_number(spr_playeroutside) + array_length(Player_icons) - 1;
							}
							audio_play_sound(snd_selecting, 0, false);
						break;
						case 1:
							if (hue > 0){
								hue--;
								timer[1] = max(timer[1], 50);
								audio_play_sound(snd_selecting, 0, false);
							}
						break;
						case 2:
							if (saturation > 0){
								saturation--;
								timer[1] = max(timer[1], 50);
								audio_play_sound(snd_selecting, 0, false);
							}
						break;
						case 3:
							if (value > 0){
								value--;
								timer[1] = max(timer[1], 50);
								audio_play_sound(snd_selecting, 0, false);
							}
						break;
					}
				}
				timer[1]++;
			}else{
				timer[1] = 0;
			}}
			if (CheckControlInput(control_type, zurdo, action.confirm, false, control_id) and !confirming){
				state = config.done;
				timer[0] = 0;
				timer[1] = 0;
				with (player){
					if (modo == mode.helicopter){
						timer.float = 0;
					}
					Inmovil = false;
					timer.dash = 2;
				}
				audio_play_sound(snd_confirm, 0, false);
			}else{ if (CheckControlInput(control_type, zurdo, action.cancel, false, control_id)){
				state = config.waiting;
				player.image_alpha = 0;
				confirming = true;
				control_id = -1;
				Players--;
				obj_game.ocupado[slot] = false;
				if (control_type == controls.keyboard){
					if (zurdo){
						obj_game.keyboard_taken[1] = false;
					}else{
						obj_game.keyboard_taken[0] = false;
					}
				}
				audio_play_sound(snd_cancel, 0, false);
			}}
			if (prevI != index or prevH != hue or prevS != saturation or prevV != value){
				var colspec = make_color_hsv(hue, saturation, value);
				with (player){
					index = other.index;
					if (index <= 3){
						if (index%2 == 0){
							special_data.playerrot = 45;
							special_data.shaperange = 42;
						}else{ if (index == 3){
							special_data.playerrot = 0;
							special_data.shaperange = 39;
						}else{
							special_data.playerrot = 0;
							special_data.shaperange = 36;
						}}
					}else{
						var specil_data = Player_icons[other.index - 4];
						special_data.sprite = specil_data.sprite;
						special_data.spr_inside = specil_data.spr_inside;
						special_data.spr_mask = specil_data.spr_mask;
						special_data.playerrot = specil_data.playerrot;
						special_data.shaperange = specil_data.shaperange;
					}
					red = color_get_red(colspec);
					green = color_get_green(colspec);
					blue = color_get_blue(colspec);
					color = {cons: make_color_rgb(red,green,blue), varr: make_color_rgb(red,green,blue), particles: make_color_rgb(red*0.7,green*0.7,blue*0.7)};
				}
			}
		}else{
			if (state == config.players){
				timer[0]++;
			}else{
				timer[0]--;
			}
			if (Mode == mode.helicopter){
				player.py = 180 - 128*dcos(180*min(timer[0], 30)/30) - 10*mul;
				player.y = player.py;
			}else{
				player.y = 183 - 128*dcos(180*min(timer[0], 30)/30);
			}
			pos[1] += (pos[0] - pos[1])/5;
			if (timer[0] == 0){
				state = config.coloring;
				selecting = 0;
				timer[1] = 0;
				timer[2] = 0;
				player.limits.down -= 100;
				audio_play_sound(snd_selecting, 0, false);
			}else{ if (timer[0] > 30){
				if (CheckControlInput(control_type, zurdo, action.vertical, false, control_id) > 0){
					if (timer[1]%((timer[1] < 20) ? 30 : 6 - min(3*floor((timer[1] - 20)/15), 5)) == 0 and 3 + array_length(Player_icons) >= selecting + 7){
						selecting += 7;
						if (selecting >= 21 + 7*pos[0]){
							pos[0] = floor(selecting/7) - 2;
						}
						audio_play_sound(snd_selecting, 0, false);
					}
					timer[1]++;
				}else{ if (CheckControlInput(control_type, zurdo, action.vertical, false, control_id) < 0){
					if (selecting - 7 >= 0 and timer[1]%((timer[1] < 20) ? 30 : 6 - min(3*floor((timer[1] - 20)/15), 5)) == 0){
						selecting -= 7;
						if (selecting < 7 + 7*pos[0]){
							pos[0] = max(floor(selecting/7) - 1, 0);
						}
						audio_play_sound(snd_selecting, 0, false);
					}
					timer[1]++;
				}else{
					timer[1] = 0;	
				}}
				if (CheckControlInput(control_type, zurdo, action.horizontal, false, control_id) > 0){
					if (timer[2]%((timer[2] < 20) ? 30 : 6 - min(3*floor((timer[2] - 20)/15), 5)) == 0 and selecting%7 < 6 and selecting + 1 <= 3 + array_length(Player_icons)){
						selecting++;
						audio_play_sound(snd_selecting, 0, false);
					}
					timer[2]++;
				}else{ if (CheckControlInput(control_type, zurdo, action.horizontal, false, control_id) < 0){
					if (selecting%7 > 0 and timer[2]%((timer[2] < 20) ? 30 : 6 - min(3*floor((timer[2] - 20)/15), 5)) == 0){
						selecting--;
						audio_play_sound(snd_selecting, 0, false);
					}
					timer[2]++;
				}else{
					timer[2] = 0;
				}}
				if (CheckControlInput(control_type, zurdo, action.confirm, false, control_id)){
					if (index != selecting){
						index = selecting;
						audio_play_sound(snd_confirm, 0, false);
					}
				}else{ if (CheckControlInput(control_type, zurdo, action.cancel, false, control_id)){
					with (player){
						if (other.index <= 3){
							sprite = [spr_playeroutside, spr_playerinside];
							index = other.index;
							if (index%2 == 0){
								special_data.playerrot = 45;
								special_data.shaperange = 42;
							}else{ if (index == 3){
								special_data.playerrot = 0;
								special_data.shaperange = 39;
							}else{
								special_data.playerrot = 0;
								special_data.shaperange = 36;
							}}
						}else{
							var specil_data = Player_icons[other.index - 4];
							special_data.sprite = specil_data.sprite;
							special_data.spr_inside = specil_data.spr_inside;
							special_data.spr_mask = specil_data.spr_mask;
							special_data.playerrot = specil_data.playerrot;
							special_data.shaperange = specil_data.shaperange;
							index = other.index;
						}
					}
					timer[0] = 30;
					state = config.playersOut;
				}}
			}}
		}
		if (state != config.waiting){
			confirming = false;
		}
	}}
}