if (room == rm_level){
	if (currentSong.state){
		draw_set_font(fnt_nexaLight20);
		draw_set_halign(fa_right);
		var multiplier = dsin(clamp(3*currentSong.timer, 0, 90) + clamp(3*(currentSong.timer - 150), 0, 90));
		draw_set_alpha(multiplier);
		var position = 1780 - 200*multiplier;
		var madeby = currentSong.type + " by";
		var offsetY = 0;
		draw_set_color(#1B6A5C);
		if (is_undefined(currentSong.from) or (currentSong.from[0] == "" and currentSong.from[1] == "")){
			var artistSize = string_width(currentSong.artist[0]);
			draw_text(position,797,madeby);
			draw_set_color(#279884);
			draw_set_font(fnt_nexaLight27);
			draw_text(position,837,currentSong.artist[0]);
			var sprite = currentSong.artist[1];
			if (is_struct(sprite)){
				var scale = 40/max(sprite_get_width(sprite.sprite), sprite_get_height(sprite.sprite));
				if (variable_struct_exists(sprite,"animation_times")){
					draw_sprite_ext(sprite.sprite,sprite.index,position - artistSize - 27,859,scale,scale,0,c_white,draw_get_alpha());
					sprite.timer += delta_time*sprite.animation_speed/10000;
					if (is_array(sprite.animation_times)){
						while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times[sprite.index]){
							sprite.timer -= sprite.animation_times[sprite.index];
							if (sprite.loops){
								sprite.index = (sprite.index + 1) % sprite.images;
							}
						}
					}else{
						while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times){
							sprite.timer -= sprite.animation_times;
							if (sprite.loops){
								sprite.index = (sprite.index + 1) % sprite.images;
							}
						}
					}
				}else{
					draw_sprite_ext(sprite.sprite,0,position - artistSize - 27,859,scale,scale,0,c_white,draw_get_alpha());
				}
			}
		}else{
			var sprite = currentSong.from[1];
			if (currentSong.from[0] != ""){
				if (is_struct(sprite)){
					var spriteA = currentSong.artist[1];
					if (is_struct(spriteA)){
						var artistSize = string_width(currentSong.artist[0]);
						draw_text(position,797,madeby + "       " + currentSong.artist[0]);
						var scale = 40/max(sprite_get_width(spriteA.sprite), sprite_get_height(spriteA.sprite));
						if (variable_struct_exists(spriteA,"animation_times")){
							draw_sprite_ext(spriteA.sprite,spriteA.index,position - artistSize - 27,813,scale,scale,0,c_white,draw_get_alpha());
							spriteA.timer += delta_time*spriteA.animation_speed/10000;
							if (is_array(spriteA.animation_times)){
								while ((spriteA.index + 1 < spriteA.images or spriteA.loops) and spriteA.timer >= spriteA.animation_times[spriteA.index]){
									spriteA.timer -= spriteA.animation_times[spriteA.index];
									if (spriteA.loops){
										spriteA.index = (spriteA.index + 1) % spriteA.images;
									}
								}
							}else{
								while ((spriteA.index + 1 < spriteA.images or spriteA.loops) and spriteA.timer >= spriteA.animation_times){
									spriteA.timer -= spriteA.animation_times;
									if (spriteA.loops){
										spriteA.index = (spriteA.index + 1) % spriteA.images;
									}
								}
							}
						}else{
							draw_sprite_ext(spriteA.sprite,0,position - artistSize - 27,813,scale,scale,0,c_white,draw_get_alpha());
						}
					}else{
						draw_text(position,797,madeby + " " + currentSong.artist[0]);
					}
					draw_set_color(#279884);
					draw_set_font(fnt_nexaLight27);
					var fromSize = string_width(currentSong.from[0]);
					draw_text(position,837,"from     " + currentSong.from[0]);
					var scale = 40/max(sprite_get_width(sprite.sprite), sprite_get_height(sprite.sprite));
					if (variable_struct_exists(sprite,"animation_times")){
						draw_sprite_ext(sprite.sprite,sprite.index,position - fromSize - 27,859,scale,scale,0,c_white,draw_get_alpha());
						sprite.timer += delta_time*sprite.animation_speed/10000;
						if (is_array(sprite.animation_times)){
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times[sprite.index]){
								sprite.timer -= sprite.animation_times[sprite.index];
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}else{
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times){
								sprite.timer -= sprite.animation_times;
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}
					}else{
						draw_sprite_ext(sprite.sprite,0,position - fromSize - 27,859,scale,scale,0,c_white,draw_get_alpha());
					}
				}else{
					var spriteA = currentSong.artist[1];
					if (is_struct(spriteA)){
						var artistSize = string_width(currentSong.artist[0]);
						draw_set_color(#279884);
						draw_text(position,797,madeby + "       " + currentSong.artist[0]);
						var scale = 40/max(sprite_get_width(spriteA.sprite), sprite_get_height(spriteA.sprite));
						if (variable_struct_exists(spriteA,"animation_times")){
							draw_sprite_ext(spriteA.sprite,spriteA.index,position - artistSize - 27,813,scale,scale,0,c_white,draw_get_alpha());
							spriteA.timer += delta_time*spriteA.animation_speed/10000;
							if (is_array(spriteA.animation_times)){
								while ((spriteA.index + 1 < spriteA.images or spriteA.loops) and spriteA.timer >= spriteA.animation_times[spriteA.index]){
									spriteA.timer -= spriteA.animation_times[spriteA.index];
									if (spriteA.loops){
										spriteA.index = (spriteA.index + 1) % spriteA.images;
									}
								}
							}else{
								while ((spriteA.index + 1 < spriteA.images or spriteA.loops) and spriteA.timer >= spriteA.animation_times){
									spriteA.timer -= spriteA.animation_times;
									if (spriteA.loops){
										spriteA.index = (spriteA.index + 1) % spriteA.images;
									}
								}
							}
						}else{
							draw_sprite_ext(spriteA.sprite,0,position - artistSize - 27,813,scale,scale,0,c_white,draw_get_alpha());
						}
					}else{
						draw_text(position,797,madeby + " " + currentSong.artist[0]);
					}
					draw_set_color(#279884);
					draw_set_font(fnt_nexaLight27);
					draw_text(position,837,"from " + currentSong.from[0]);
				}
			}else{ if (is_struct(sprite)){
				var height = sprite_get_height(sprite.sprite);
				offsetY = max(min(height, 100) - 40, 0);
				var spriteA = currentSong.artist[1];
				if (is_struct(spriteA)){
					var artistSize = string_width(currentSong.artist[0]);
					draw_text(position,797 - offsetY,madeby + "       " + currentSong.artist[0]);
					var scale = 40/max(sprite_get_width(spriteA.sprite), sprite_get_height(spriteA.sprite));
					if (variable_struct_exists(spriteA,"animation_times")){
						draw_sprite_ext(spriteA.sprite,spriteA.index,position - artistSize - 27,813 - offsetY,scale,scale,0,c_white,draw_get_alpha());
						spriteA.timer += delta_time*spriteA.animation_speed/10000;
						if (is_array(spriteA.animation_times)){
							while ((spriteA.index + 1 < spriteA.images or spriteA.loops) and spriteA.timer >= spriteA.animation_times[spriteA.index]){
								spriteA.timer -= spriteA.animation_times[spriteA.index];
								if (spriteA.loops){
									spriteA.index = (spriteA.index + 1) % spriteA.images;
								}
							}
						}else{
							while ((spriteA.index + 1 < spriteA.images or spriteA.loops) and spriteA.timer >= spriteA.animation_times){
								spriteA.timer -= spriteA.animation_times;
								if (spriteA.loops){
									spriteA.index = (spriteA.index + 1) % spriteA.images;
								}
							}
						}
					}else{
						draw_sprite_ext(spriteA.sprite,0,position - artistSize - 27,813 - offsetY,scale,scale,0,c_white,draw_get_alpha());
					}
				}else{
					draw_text(position,797 - offsetY,madeby + " " + currentSong.artist[0]);
				}
				var scale = min(height, 100)/height;
				var width = sprite_get_width(sprite.sprite)*scale;
				var fromSize = 16 + width;
				draw_set_color(#279884);
				draw_set_font(fnt_nexaLight27);
				draw_text(position - fromSize,837 - offsetY/2,"from");
				if (variable_struct_exists(sprite,"animation_times")){
					draw_sprite_ext(sprite.sprite,sprite.index,position - width/2,859 - offsetY/2,scale,scale,0,c_white,draw_get_alpha());
					sprite.timer += delta_time*sprite.animation_speed/10000;
					if (is_array(sprite.animation_times)){
						while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times[sprite.index]){
							sprite.timer -= sprite.animation_times[sprite.index];
							if (sprite.loops){
								sprite.index = (sprite.index + 1) % sprite.images;
							}
						}
					}else{
						while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times){
							sprite.timer -= sprite.animation_times;
							if (sprite.loops){
								sprite.index = (sprite.index + 1) % sprite.images;
							}
						}
					}
				}else{
					draw_sprite_ext(sprite.sprite,0,position - width/2,859 - offsetY/2,scale,scale,0,c_white,draw_get_alpha());
				}
			}}
		}
		draw_set_color(c_white);
		draw_set_font(fnt_nexaBold57);
		draw_text(position,709 - offsetY,currentSong.title);
		draw_set_font(fnt_nexaLight18);
		if (currentSong.levelby[0] != ""){
			draw_set_color(#A9E1E3);
			if (!is_undefined(currentSong.recreatedby) and currentSong.recreatedby[0] != ""){
				var sprite = currentSong.levelby[1];
				if (is_struct(sprite)){
					var levelSize = string_width(currentSong.levelby[0]);
					draw_text(position,610 - offsetY,"Level by        " + currentSong.levelby[0]);
					var scale = 40/max(sprite_get_width(sprite.sprite), sprite_get_height(sprite.sprite));
					if (variable_struct_exists(sprite,"animation_times")){
						draw_sprite_ext(sprite.sprite,sprite.index,position - levelSize - 28,624 - offsetY,scale,scale,0,c_white,draw_get_alpha());
						sprite.timer += delta_time*sprite.animation_speed/10000;
						if (is_array(sprite.animation_times)){
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times[sprite.index]){
								sprite.timer -= sprite.animation_times[sprite.index];
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}else{
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times){
								sprite.timer -= sprite.animation_times;
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}
					}else{
						draw_sprite_ext(sprite.sprite,0,position - levelSize - 28,624 - offsetY,scale,scale,0,c_white,draw_get_alpha());
					}
				}else{
					draw_text(position,610 - offsetY,"Level by " + currentSong.levelby[0]);
				}
				sprite = currentSong.recreatedby[1];
				if (is_struct(sprite)){
					var recreatedSize = string_width(currentSong.recreatedby[0]);
					draw_text(position,662 - offsetY,"Recreated by        " + currentSong.recreatedby[0]);
					var scale = 40/max(sprite_get_width(sprite.sprite), sprite_get_height(sprite.sprite));
					if (variable_struct_exists(sprite,"animation_times")){
						draw_sprite_ext(sprite.sprite,sprite.index,position - recreatedSize - 28,674 - offsetY,scale,scale,0,c_white,draw_get_alpha());
						sprite.timer += delta_time*sprite.animation_speed/10000;
						if (is_array(sprite.animation_times)){
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times[sprite.index]){
								sprite.timer -= sprite.animation_times[sprite.index];
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}else{
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times){
								sprite.timer -= sprite.animation_times;
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}
					}else{
						draw_sprite_ext(sprite.sprite,0,position - recreatedSize - 28,674 - offsetY,scale,scale,0,c_white,draw_get_alpha());
					}
				}else{
					draw_text(position,662 - offsetY,"Recreated by " + currentSong.recreatedby[0]);
				}
			}else{
				var sprite = currentSong.levelby[1];
				if (is_struct(sprite)){
					var levelSize = string_width(currentSong.levelby[0]);
					draw_text(position,662 - offsetY,"Level by        " + currentSong.levelby[0]);
					var scale = 40/max(sprite_get_width(sprite.sprite), sprite_get_height(sprite.sprite));
					if (variable_struct_exists(sprite,"animation_times")){
						draw_sprite_ext(sprite.sprite,sprite.index,position - levelSize - 28,674 - offsetY,scale,scale,0,c_white,draw_get_alpha());
						sprite.timer += delta_time*sprite.animation_speed/10000;
						if (is_array(sprite.animation_times)){
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times[sprite.index]){
								sprite.timer -= sprite.animation_times[sprite.index];
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}else{
							while ((sprite.index + 1 < sprite.images or sprite.loops) and sprite.timer >= sprite.animation_times){
								sprite.timer -= sprite.animation_times;
								if (sprite.loops){
									sprite.index = (sprite.index + 1) % sprite.images;
								}
							}
						}
					}else{
						draw_sprite_ext(sprite.sprite,0,position - levelSize - 28,674 - offsetY,scale,scale,0,c_white,draw_get_alpha());
					}
				}else{
					draw_text(position,662 - offsetY,"Level by " + currentSong.levelby[0]);
				}
			}
		}
		draw_set_halign(fa_left);
		if (currentSong.version != ""){
			draw_set_font(fnt_nexaBold22);
			draw_text(-180 + 200*multiplier, 851, "v" + currentSong.version);
		}
		draw_set_alpha(1);
	}
	if (glitch.timer > 0){
		for (var i=0;i<array_length(glitches);i++){
			draw_sprite_ext(spr_pixel, 0, 800, glitches[i].y + (glitches[i].y - 450)/10*(10 - glitch.timer)*(1 + 5/10*(10 - glitch.timer)), 1100, glitches[i].size*(1 + 2/10*(10 - glitch.timer)), 5/2*(10 - max(glitch.timer, 8)), c_white, 0.075);
		}
		draw_sprite_ext(spr_pixel, 0, 800, 450, 800, 450, 0, c_white, 0.1*min(glitch.alpha, 1));
	}
	var step = delta_time/(1000000/60);
	var barHeight = 0;
	var secondBarHeight = 43;
	var loopHeight = 0;
	var extraHeight = 0;
	switch (barLevel.state){
		case levelBar.none:
			barHeight = 40;
			secondBarHeight = 0;
		break;
		case levelBar.start:
			barHeight = 40*(1 - dsin(clamp(18*barLevel.timer, 0, 90)));
		case levelBar.track: case levelBar.replacing: case levelBar.extending: case levelBar.sectionOut: case levelBar.sectionWaiting:
			secondBarHeight = 0;
		break;
		case levelBar.finish:
			barHeight = 40*dsin(clamp(4.5*(barLevel.timer - 123), 0, 90));
			secondBarHeight = 0;
		break;
		case levelBar.sectionStart:
			secondBarHeight = 43*dsin(3*clamp(barLevel.timer - 15, 0, 30));
		break;
		case levelBar.sectionOnlyStart:
			barHeight = 40;
			secondBarHeight = 40*dsin(3*min(barLevel.timer, 30));
		break;
		case levelBar.sectionOnly: case levelBar.sectionOnlyReplacing: case levelBar.sectionOnlyExtending:
			barHeight = 40;
			secondBarHeight = 40;
		break;
		case levelBar.sectionOnlySuspend:
			barHeight = 40;
			secondBarHeight = 40 - 40*dsin(clamp(4.5*(barLevel.timer - 130), 0, 90));
		break;
		case levelBar.sectionSuspend:
			secondBarHeight = 43 - 43*dsin(clamp(4.5*(barLevel.timer - 130), 0, 90));
		break;
		case levelBar.sectionEnd:
			secondBarHeight = 43 - 43*dsin(clamp(9*(barLevel.timer - ((segmentBar.damage > 0 and segmentBar.damageTimer == 0) ? 150 : 130)), 0, 90));
		break;
		case levelBar.sectionOnlyEnd:
			barHeight = 40;
			secondBarHeight = 40 - 40*dsin(clamp(9*(barLevel.timer - ((segmentBar.damage > 0 and segmentBar.damageTimer == 0) ? 150 : 130)), 0, 90));
		break;
		case levelBar.sectionResume:
			secondBarHeight = 43*dsin(3*min(barLevel.timer, 30));
		break;
	}
	if (barLevel.loop.timer >= 0){
		if (barLevel.loop.timer < 10){
			barLevel.loop.timer = min(barLevel.loop.timer + step, 10);
		}else if (!barLevel.loop.enabled){
			barLevel.loop.timer += step;
		}
		loopHeight = 30*dsin(9*(min(barLevel.loop.timer, 10) + clamp(barLevel.loop.timer - 10, 0, 10)));
		if (barLevel.loop.timer >= 20){
			barLevel.loop.timer = -1;
		}
	}
	if (barLevel.extraMessage.timer >= 0){
		barLevel.extraMessage.timer += step;
		extraHeight = 30*dsin(9*(min(barLevel.extraMessage.timer, 10) + clamp(barLevel.extraMessage.timer - (barLevel.extraMessage.finish - 10), 0, 10)));
		if (barLevel.extraMessage.timer >= barLevel.extraMessage.finish){
			barLevel.extraMessage.timer = -1;
		}
	}
	if (barLevel.message.timer >= 0){
		barLevel.message.timer += step;
		draw_set_font(fnt_nexaBold13);
		draw_set_halign(fa_center);
		draw_text_color(800 + barLevel.shake.x, 24 + barLevel.shake.y + secondBarHeight - barHeight + (26 + loopHeight + extraHeight)*dsin(9*(min(barLevel.message.timer, 10) + clamp(barLevel.message.timer - 110, 0, 10))), barLevel.message.text, barLevel.message.color, barLevel.message.color, barLevel.message.color, barLevel.message.color, dsin(18*(min(barLevel.message.timer, 5) + clamp(barLevel.message.timer - 115, 0, 5))));
		draw_set_halign(fa_left);
		if (barLevel.message.timer >= 120){
			barLevel.message.timer = -1;
		}
	}
	if (barLevel.extraMessage.timer >= 0){
		barLevel.extraMessage.timer += step;
		draw_set_font(fnt_nexaBold13);
		draw_set_halign(fa_center);
		draw_text_color(800 + barLevel.shake.x, 24 + barLevel.shake.y + secondBarHeight - barHeight + (26 + loopHeight)*dsin(9*(min(barLevel.extraMessage.timer, 10) + clamp(barLevel.extraMessage.timer - (barLevel.extraMessage.finish - 10), 0, 10))), barLevel.extraMessage.text, barLevel.extraMessage.color, barLevel.extraMessage.color, barLevel.extraMessage.color, barLevel.extraMessage.color, dsin(18*(min(barLevel.extraMessage.timer, 5) + clamp(barLevel.extraMessage.timer - (barLevel.extraMessage.finish - 5), 0, 5))));
		draw_set_halign(fa_left);
		if (barLevel.extraMessage.timer >= barLevel.extraMessage.finish){
			barLevel.extraMessage.timer = -1;
		}
	}
	if (barLevel.loop.enabled or barLevel.loop.timer >= 0){
		draw_set_font(fnt_nexaBold13);
		draw_set_halign(fa_center);
		draw_text_color(800 + barLevel.shake.x, 24 + barLevel.shake.y + secondBarHeight - barHeight + 26*dsin(9*(min(barLevel.loop.timer, 10) + clamp(barLevel.loop.timer - 10, 0, 10))), barLevel.loop.message, barLevel.loop.color, barLevel.loop.color, barLevel.loop.color, barLevel.loop.color, dsin(18*(min(barLevel.loop.timer, 5) + clamp(barLevel.loop.timer - 15, 0, 5))));
		draw_set_halign(fa_left);
	}
	DrawBars();
	if (state == level.waiting and timer < 60){
		draw_sprite_ext(spr_pixel,0,800,450,801,451,0,c_black,(60 - timer)/60);
	}
	if (flash >= 0){
		flash++;
		if (flash >= 6){
			flash = -1;
		}else{
			draw_sprite_ext(spr_pixel,0,800,450,801,451,0,c_white,(6 - flash)/10);
		}
	}
	if (death.timer >= 0 and state != level.rewind){
		death.timer += (Dead_Players) ? 1 : 4;
		if (death.timer >= 101){
			death.timer = -1;
		}else{
			draw_sprite_ext(spr_pixel,0,800,450,801,451,0,death.color,(101 - death.timer)/100);
		}
	}
}