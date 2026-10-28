AI = false;
Inmovil = false;
maxHP = MaxHP;
HP = maxHP;
prevX = x;
prevY = y;
reviveFuncjsaifniaslufasnijl = -1; //Delete this maybe
rank = 7;
special_data = {sprite: -1, spr_inside: false, spr_mask: false, playerrot: 0, shaperange: 36};
surf = [-1, -1];
hurtanim = {enable: false, angle: 0};
damaged = -1;
outsideView = false;
murio = false;
frame = 100;
color = {cons: make_color_rgb(red,green,blue), varr: make_color_rgb(red,green,blue), particles: make_color_rgb(red*0.7,green*0.7,blue*0.7)};
particles = [];
layers = [];
circles = [];
AfterUpdate = -1;
BeforeUpdate = -1;
Init = -1;
Revive = -1;
forcedHit = false;
enabled = true;
shape = undefined;
object = undefined;
isMoving = function(){
	return (x != prevX or y != prevY);
}
if (modo == mode.shape){
	#region Shape mode
	shape = new ColAABB(new Vector3(x, y, depth), new Vector3(25*image_xscale, 25*image_yscale, 25*max(image_xscale, image_yscale)))
	object = new ColObject(shape, self);
	obj_game.world_3d.Add(object);
	vel = {current: 7, normal: 7, dash: 22.5};
	limits = {left: 16, right: 1584, up: 16, down: 884};
	moving = false;
	timer = {dash: 0, idle: 0, particles: 0};
	mov = {x: 0, y: 0};
	boom = {x: 0, y: 0};
	scale = {x: 0.32, y: 0.32};
	canDash = true;
	GetHit = function(bullet,amount,forced=false,sound=true,launch=true,invul=true){
		if (murio){
			return;
		}
		HP = clamp(HP - amount, (forced) ? 1 : 0, maxHP);
		forcedHit = forced;
		if (HP == 0){
			audio_play_sound(snd_dead,0,false);
			damaged = 0;
			timer.dash = 0;
			timer.idle = 0;
			vel.current = vel.normal;
			murio = true;
			mov.x = 0;
			mov.y = 0;
			return;
		}else{ if (sound){
			audio_play_sound(snd_hit,0,false);
		}}
		if (invul){
			damaged = 0;
		}
		if (!murio and launch){
			mov.x = 0;
			mov.y = 0;
			if (Players == 1){
				obj_game.death.timer = 0;
				if (amount > 0){
					obj_game.death.color = c_pink;
				}else{
					obj_game.death.color = c_white;
				}
			}
			timer.dash = 0;
			timer.idle = 0;
			vel.current = vel.normal;
			if (HP > 0){
				hurtanim.enable = true;
				hurtanim.angle = point_direction(bullet.x,bullet.y,x,y);
			}
		}
	}
	isDashing = function(){
		return (timer.dash <= 1 or vel.current - vel.normal == 0);
	}
	layers[0] = function(){
		for (var i=0;i<array_length(particles);i++){
			var data = particles[i];
			if (index < 4){
				draw_sprite_ext(spr_playeroutside, index, data.x, data.y, (4 + data.size*data.alpha)/50, (4 + data.size*data.alpha)/50, 0, color.particles, data.alpha);
			}else{
				draw_sprite_ext(special_data.sprite, 0, data.x, data.y, (4 + data.size*data.alpha)/50, (4 + data.size*data.alpha)/50, 0, color.particles, data.alpha);
				if (special_data.spr_mask){
					draw_sprite_ext(special_data.sprite, 2, data.x, data.y, (4 + data.size*data.alpha)/50, (4 + data.size*data.alpha)/50, 0, color.particles, data.alpha);
				}
			}
		}
	}
	layers[1] = function(){
		var size = 128/500*((20 - max(timer.dash, 16))/4);
		if (timer.dash > 10){
			draw_sprite_ext(spr_explotion, max(16 - timer.dash, 0), boom.x, boom.y, size, size, 0, color.cons, image_alpha);
		}
		if (damaged >= 0 and !murio){
			draw_sprite_ext(spr_circle, 0, x, y, 0.06, 0.06, 0, make_color_rgb(25.5,25.5,25.5), image_alpha*0.75);
			if (!surface_exists(surf[0])){
				surf[0] = surface_create(60,60);
			}
			if (!surface_exists(surf[1])){
				surf[1] = surface_create(60,60);
			}
			surface_set_target(surf[0]);
			draw_clear(c_white);
			gpu_set_blendenable(false);
			draw_sprite_ext(spr_radial_wipe, 0, 30, 30, 1, 1, 0, c_white, 0);
			if (damaged > 44){
				draw_sprite_ext(spr_radial_wipe, 0, 30, 30, 1, 1, 180*(88 - damaged)/44, c_white, 1);
			}else{ if (damaged < 44){
				draw_sprite_ext(spr_radial_wipe, 0, 30, 30, 1, 1, 180*(44 - damaged)/44, c_white, 0);
			}}
			gpu_set_blendenable(true);
			surface_reset_target();
			surface_set_target(surf[1]);
			draw_clear_alpha(c_white, 0);
			draw_sprite_ext(spr_circle_wave, 0, 30, 30, 0.06, 0.06, 0, c_white, 1);
			gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
			draw_surface(surf[0], 0, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			surface_reset_target();
			draw_surface_ext(surf[1], x - 30, y - 30, 1, 1, 0, c_white, image_alpha);
		}
		if (timer.dash > 0){
			if (index < 4){
				draw_sprite_ext(spr_playeroutside, index, x, y, scale.x*1.4, scale.y*1.4, image_angle, c_white, min(timer.dash, 10)/10);
			}else{
				draw_sprite_ext(special_data.sprite, 0, x, y, scale.x*1.4, scale.y*1.4, image_angle, c_white, min(timer.dash, 10)/10);
				if (special_data.spr_mask){
					draw_sprite_ext(special_data.sprite, 2, x, y, scale.x*1.4, scale.y*1.4, image_angle, c_white, min(timer.dash, 10)/10);
				}
			}
		}
	}
	layers[2] = function(){
		if (!Dead_Players){
			if (murio){
				var pulsing = abs(dsin(9*damaged));
				var scaling = (42 + 15*pulsing)/250;
				var period = damaged%75;
				var pulsation = abs(dsin(180/8*(clamp(period - 57, 0, 8) + clamp(period - 67, 0, 8))));
				var diffR = 255 - red;
				var diffG = 255 - green;
				var diffB = 255 - blue;
				draw_set_font(fnt_nexaBold90);
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_color(make_color_rgb(red + diffR*pulsation,green + diffG*pulsation,blue + diffB*pulsation));
				draw_text_transformed(x,y-60,"help!",0.15 + 0.15*pulsation,0.15 + 0.15*pulsation,0);
				draw_set_color(c_white);
				draw_set_valign(fa_top);
				draw_sprite_ext(spr_triangle,0,x,y-50+7*pulsing,0.038,0.03,180,c_white,1);
				draw_sprite_ext(spr_death,0,x,y,scaling,scaling,0,c_white,0.75);
				if (index < 4){
					draw_sprite_ext(spr_playerinside, index, x, y, 0.32, 0.32, 0, c_white, image_alpha);
				}else{ if (special_data.spr_inside){
					draw_sprite_ext(special_data.sprite, 1, x, y, 0.32, 0.32, 0, c_white, image_alpha);
				}}
			}else{
				if (index < 4){
					draw_sprite_ext(spr_playerinside, index, x, y, scale.x, scale.y, image_angle, c_white, image_alpha);
				}else{ if (special_data.spr_inside){
					draw_sprite_ext(special_data.sprite, 1, x, y, scale.x, scale.y, image_angle, c_white, image_alpha);
				}}
				if (!surface_exists(surf[0])){
					surf[0] = surface_create(60,60);
				}
				if (!surface_exists(surf[1])){
					surf[1] = surface_create(60,60);
				}
				surface_set_target(surf[0]);
				draw_clear(c_white);
				gpu_set_blendenable(false);
				draw_sprite_ext(spr_radial_wipe, 0, 30, 30, scale.x, scale.y, image_angle, c_white, 0);
				if (frame > 50){
					draw_sprite_ext(spr_radial_wipe, 0, 30, 30, scale.x, scale.y, image_angle + 180*(frame - 50)/50, c_white, 0);
				}else{ if (frame < 50){
					draw_sprite_ext(spr_radial_wipe, 0, 30, 30, scale.x, scale.y, image_angle + 180*frame/50, c_white, 1);
				}}
				gpu_set_blendenable(true);
				surface_reset_target();
				surface_set_target(surf[1]);
				draw_clear_alpha(c_white, 0);
				if (index < 4){
					draw_sprite_ext(spr_playeroutside, index, 30, 30, scale.x, scale.y, image_angle, color.varr, 1);
				}else{
					draw_sprite_ext(special_data.sprite, 0, 30, 30, scale.x, scale.y, image_angle, color.varr, 1);
					if (special_data.spr_mask){
						draw_sprite_ext(special_data.sprite, 2, 30, 30, scale.x, scale.y, image_angle, c_white, 1);
					}
				}
				gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
				draw_surface(surf[0], 0, 0);
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				surface_reset_target();
				draw_surface_ext(surf[1], x - 30, y - 30, 1, 1, 0, c_white, image_alpha);
			}
		}
	}
	layers[3] = function(){ //Check layers in the actual game later
		var length = array_length(circles);
		if (length > 0){
			var step = delta_time/(1000000/60);
			for (var i=0;i<length;i++){
				var effect = circles[i];
				effect.time += step;
				if (effect.time >= 42.5){
					array_delete(circles, i, 1);
					i--;
					length--;
				}else{
					var scaling = 50*effect.scale*dcos(90/30*max(effect.time - 12.5, 0))/250;
					var time = dsin(90/42.5*effect.time);
					draw_sprite_ext(spr_death,1,effect.x + 500*effect.scale*dcos(effect.ang)*time,effect.y + 500*effect.scale*dsin(effect.ang)*time,scaling,scaling,0,c_white,1);
				}
			}
		}
	}
	sprite_index = spr_playeroutside;
	image_xscale = 0.32;
	image_yscale = 0.32;
	image_speed = 0;
	if (AI){
		timer.wait = irandom_range(162, 222);
		dashtimer = irandom_range(157, 332);
		goto = {x: x, y: y, posX: 2, posY: 2};
		int = {timer: 0, value: 0};
	}
	#endregion
}else{ if (modo == mode.helicopter){
	#region Helicopter mode
	py = y;
	facing = 1;
	bounce = {timer: 31, value: 0};
	handsrot = 180;
	limits = {left: 28, right: 1572, up: 28, down: 872};
	eyes = {x: 0, y: 0, index: 0};
	vel = {x: 0, y: 0};
	knockout = 0;
	timer = {particles: 0, float: 0};
	head = {x: 0.75, y: 0.75};
	body = {x: 0.75, rot: 0};
	halo = {x: 0.75, rot: 0};
	tailrot = 0;
	explotions = [];
	bodyparts = [];
	withplayer = true;
	stopscroll = false;
	feeling = feel.normal;
	GetHit = function(bullet,amount,forced=false,sound=true,launch=true,invul=true){
		if (murio){
			return;
		}
		HP = clamp(HP - amount, (forced) ? 1 : 0, MaxHP);
		forcedHit = forced;
		if (HP == 0){
			audio_play_sound(snd_dead,0,false);
			damaged = 0;
			timer.float = 0;
			vel.x = 0;
			vel.y = 0;
			murio = true;
			return;
		}else{ if (sound){
			audio_play_sound(snd_hit,0,false);
		}}
		if (invul){
			damaged = 0;
		}
		if (!murio and launch){
			if (Players == 1){
				obj_game.death.timer = 0;
				if (amount > 0){
					obj_game.death.color = c_pink;
				}else{
					obj_game.death.color = c_white;
				}
			}
			vel.x = 0;
			vel.y = 0;
			if (HP > 0){
				hurtanim.enable = true;
				hurtanim.angle = point_direction(bullet.x,bullet.y,x,y);
			}
		}
	}
	layers[0] = function(){
		for (var i=0;i<array_length(particles);i++){
			var data = particles[i];
			if (withplayer){
				if (index < 4){
					draw_sprite_ext(spr_playeroutside, index, data.x, data.y, (4 + data.size*data.alpha)/50, (4 + data.size*data.alpha)/50, 0, color.particles, data.alpha);
				}else{
					draw_sprite_ext(special_data.sprite, 0, data.x, data.y, (4 + data.size*data.alpha)/50, (4 + data.size*data.alpha)/50, 0, color.particles, data.alpha);
					if (special_data.spr_mask){
						draw_sprite_ext(special_data.sprite, 2, data.x, data.y, (4 + data.size*data.alpha)/50, (4 + data.size*data.alpha)/50, 0, c_white, data.alpha);
					}
				}
			}else{
				draw_sprite_ext(spr_circle, 0, data.x, data.y, (4 + data.size*data.alpha)/500, (4 + data.size*data.alpha)/500, 0, color.particles, data.alpha);
			}
		}
	}
	layers[1] = function(){
		var length = array_length(bodyparts);
		for (var i=0;i<length;i++){
			var corpse = bodyparts[i];
			corpse.vel.y -= 0.5;
			corpse.rot += corpse.vel.rot;
			corpse.x += corpse.vel.x;
			corpse.y -= corpse.vel.y;
			if (corpse.y >= Camera.y + 1100){
				array_delete(bodyparts, i, 1);
				i--;
				length--;
			}else{
				draw_sprite_ext(spr_damaged_parts, corpse.sub, corpse.x, corpse.y, corpse.scale.x, corpse.scale.y, corpse.rot, corpse.col, 1);
			}
		}
		if (damaged >= 0 and !murio){
			draw_sprite_ext(spr_circle, 0, x, y, 0.1, 0.1, 0, make_color_rgb(25.5,25.5,25.5), image_alpha*0.75);
			if (!surface_exists(surf[0])){
				surf[0] = surface_create(100,100);
			}
			if (!surface_exists(surf[1])){
				surf[1] = surface_create(100,100);
			}
			surface_set_target(surf[0]);
			draw_clear(c_white);
			gpu_set_blendenable(false);
			draw_sprite_ext(spr_radial_wipe, 0, 50, 50, 1, 1, 0, c_white, 0);
			if (damaged > 44){
				draw_sprite_ext(spr_radial_wipe, 0, 50, 50, 1, 1, 180*(88 - damaged)/44, c_white, 1);
			}else{ if (damaged < 44){
				draw_sprite_ext(spr_radial_wipe, 0, 50, 50, 1, 1, 180*(44 - damaged)/44, c_white, 0);
			}}
			gpu_set_blendenable(true);
			surface_reset_target();
			surface_set_target(surf[1]);
			draw_clear_alpha(c_white, 0);
			draw_sprite_ext(spr_circle_wave, 0, 50, 50, 0.1, 0.1, 0, c_white, 1);
			gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
			draw_surface(surf[0], 0, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			surface_reset_target();
			draw_surface_ext(surf[1], x - 50, y - 50, 1, 1, 0, c_white, image_alpha);
		}
	}
	layers[2] = function(){
		if (!Dead_Players){
			if (murio){
				var pulsing = abs(dsin(9*damaged));
				var scaling = (76 + 15*pulsing)/250;
				var period = damaged%75;
				var pulsation = abs(dsin(180/8*(clamp(period - 57, 0, 8) + clamp(period - 67, 0, 8))));
				var diffR = 255 - red;
				var diffG = 255 - green;
				var diffB = 255 - blue;
				draw_set_font(fnt_nexaBold90);
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_color(make_color_rgb(red + diffR*pulsation,green + diffG*pulsation,blue + diffB*pulsation));
				draw_text_transformed(x,y-77,"help!",0.15 + 0.15*pulsation,0.15 + 0.15*pulsation,0);
				draw_set_color(c_white);
				draw_set_valign(fa_top);
				draw_sprite_ext(spr_triangle,0,x,y-67+7*pulsing,0.038,0.03,180,c_white,1);
				draw_sprite_ext(spr_death,0,x,y,scaling,scaling,0,c_white,0.75);
				if (index < 4){
					draw_sprite_ext(spr_playerinside, index, x, y, 0.32, 0.32, 0, c_white, image_alpha);
				}else{ if (special_data.spr_inside){
					draw_sprite_ext(special_data.sprite, 1, x, y, 0.32, 0.32, 0, c_white, image_alpha);
				}}
			}else{
				var color1 = make_color_rgb(color_get_red(color.varr)*0.8, color_get_green(color.varr)*0.8, color_get_blue(color.varr)*0.8);
				var color2 = make_color_rgb(204 + color_get_red(color.varr)/5, 204 + color_get_green(color.varr)/5, 204 + color_get_blue(color.varr)/5);
				if (withplayer){
					if (index < 4){
						draw_sprite_ext(spr_playeroutside, index, x - special_data.shaperange*dsin(handsrot), y + 9 - special_data.shaperange*dcos(handsrot), 0.24, 0.24, handsrot + special_data.playerrot + 180, color.varr, image_alpha);
					}else{
						draw_sprite_ext(special_data.sprite, 0, x - special_data.shaperange*dsin(handsrot), y + 9 - special_data.shaperange*dcos(handsrot), 0.24, 0.24, handsrot + special_data.playerrot + 180, color.varr, image_alpha);
						if (special_data.spr_mask){
							draw_sprite_ext(special_data.sprite, 2, x - special_data.shaperange*dsin(handsrot), y + 9 - special_data.shaperange*dcos(handsrot), 0.24, 0.24, handsrot + special_data.playerrot + 180, c_white, image_alpha);
						}
					}
					draw_sprite_ext(spr_circle, 0, x + 9*dcos(handsrot) - 30*dsin(handsrot), y + 9 - 30*dcos(handsrot) - 9*dsin(handsrot), 0.014, 0.014, 0, color1, image_alpha);
					draw_sprite_ext(spr_circle, 0, x - 9*dcos(handsrot) - 30*dsin(handsrot), y + 9 - 30*dcos(handsrot) + 9*dsin(handsrot), 0.014, 0.014, 0, color1, image_alpha);
				}else{
					draw_sprite_ext(spr_circle, 0, x + 11 - 20*dsin(handsrot), y + 20 - 20*dcos(handsrot), 0.0105, 0.0105, 0, color1, image_alpha);
					draw_sprite_ext(spr_circle, 0, x - 11 - 20*dsin(handsrot), y + 20 - 20*dcos(handsrot), 0.0105, 0.0105, 0, color1, image_alpha);
				}
				draw_sprite_ext(spr_helitail, 0, x + (-86*dcos(body.rot) - 28*dsin(body.rot))*body.x, y - 21*dcos(body.rot) + 64.5*dsin(body.rot), 0.46*body.x, 0.46*body.x, tailrot, color1, image_alpha);
				draw_sprite_ext(spr_helibody, 0, x, y, 0.82*body.x, 0.82*head.y, body.rot*sign(body.x), color2, image_alpha);
				draw_sprite_ext(spr_helihead, 0, x, y, 0.82*head.x, 0.82*head.y, 0, color2, image_alpha);
				if (!surface_exists(surf[0])){
					surf[0] = surface_create(100,100);
				}
				if (!surface_exists(surf[1])){
					surf[1] = surface_create(100,100);
				}
				surface_set_target(surf[0]);
				draw_clear(c_white);
				gpu_set_blendenable(false);
				draw_sprite_ext(spr_radial_wipe, 0, 40, 40, head.x, head.y, image_angle, c_white, 0);
				if (frame > 50){
					draw_sprite_ext(spr_radial_wipe, 0, 40, 40, head.x, head.y, image_angle + 180*(frame - 50)/50, c_white, 0);
				}else{ if (frame < 50){
					draw_sprite_ext(spr_radial_wipe, 0, 40, 40, head.x, head.y, image_angle + 180*frame/50, c_white, 1);
				}}
				gpu_set_blendenable(true);
				surface_reset_target();
				surface_set_target(surf[1]);
				draw_clear_alpha(c_white, 0);
				draw_sprite_ext(spr_helihead, 1, 40, 40, 0.82*head.x, 0.82*head.y, 0, color2, 1);
				gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
				draw_surface(surf[0], 0, 0);
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
				surface_reset_target();
				draw_surface_ext(surf[1], x - 40, y - 40, 1, 1, 0, c_white, image_alpha);
				draw_sprite_ext(spr_helieye, eyes.index, x - 13 + max(eyes.x, -3), y + eyes.y, 0.2, 0.2, 0, c_white, image_alpha);
				draw_sprite_ext(spr_helieye, eyes.index, x + 13 + min(eyes.x, 3), y + eyes.y, -0.2, 0.2, 0, c_white, image_alpha);
				draw_sprite_ext(spr_helihalo, 0, x - 45*dsin(halo.rot), y - 45*dcos(halo.rot), halo.x, 1, halo.rot, color1, image_alpha);
			}
		}
	}
	layers[3] = function(){ //Check layers in the actual game later
		var length = array_length(explotions);
		var step = delta_time/(1000000/60);
		if (length > 0){
			var size = 128/500;
			for (var i=0;i<length;i++){
				var effect = explotions[i];
				if (effect.time >= 9){
					array_delete(explotions, i, 1);
					i--;
					length--;
				}else{
					draw_sprite_ext(spr_explotion,floor(effect.time/1.5),effect.x,effect.y,size,size,0,c_white,1);
				}
				effect.time += step;
			}
		}
		length = array_length(circles);
		if (length > 0){
			for (var i=0;i<length;i++){
				var effect = circles[i];
				effect.time += step;
				if (effect.time >= 42.5){
					array_delete(circles, i, 1);
					i--;
					length--;
				}else{
					var scaling = 50*dcos(90/30*max(effect.time - 12.5, 0))/250;
					var time = dsin(90/42.5*effect.time);
					draw_sprite_ext(spr_death,1,effect.x + 500*dcos(effect.ang)*time,effect.y + 500*dsin(effect.ang)*time,scaling,scaling,0,c_white,1);
				}
			}
		}
	}
	sprite_index = spr_helihead;
	image_xscale = 0.615;
	image_yscale = 0.615;
	image_speed = 0;
	if (AI){
		 timer.wait = irandom_range(162, 222);
		 goto = {x: x, y: y, posX: 2, posY: 2};
		 int = {timer: 0, value: 0};
	}
	#endregion
}}
