var step = delta_time/(1000000/60);
for (var i=0;i<array_length(particles);i++){
	var data = particles[i];
	data.x += data.speed*dsin(data.dir)*step;
	data.y += data.speed*dcos(data.dir)*step;
	data.alpha -= 0.04*step;
	if (data.alpha <= 0){
		array_delete(particles, i, 1);
		i--;
	}
}
prevX = x;
prevY = y;
if (instanceof(BeforeUpdate) == "function"){
	try{
		BeforeUpdate(id);
	}catch (e){
		show_message(e.message);
		obj_game.state = level.error;
	}
}
if (enabled){
	if (modo == mode.shape){
		if (murio){
			if (damaged == 0){
				rank--;
				py = y;
				px = x;
				times = 3;
			}
			damaged += step;
			y = py + 16*dsin(4.5*damaged);
			if (x > Camera.x - 30 and !outsideView){
				x -= 2*damaged/100;
			}else{
				x = Camera.x - 100;
				outsideView = true;
			}
			var offset = 10*(3 - times);
			while (times > 0 and damaged >= offset){
				for (var i=0;i<8;i++){
					array_push(circles,{x: px, y: py, ang: 45*i, scale: 1, time: damaged - offset});
				}
				times--;
				offset = 10*(3 - times);
			}
			if (damaged >= 20){
				var length = array_length(PlayerInstances);
				for (var i=0;i<length;i++){
					var otherplayer = PlayerInstances[i];
					if (otherplayer != id and place_meeting(x,y,otherplayer)){
						if (!otherplayer.murio and otherplayer.damaged == -1){
							audio_play_sound(snd_checkpoint, 0, false);
							HP = 1;
							murio = false;
							damaged = 0;
							outsideView = false;
							if (instanceof(Revive) == "function"){
								try{
									Revive(id,otherplayer);
								}catch (e){
									show_message(e.message);
									obj_game.state = level.error;
								}
							}
							break;
						}
					}
				}
			}
		}else{
			if (damaged >= 0){
				if (rank == 7 and !forcedHit){
					rank--;
				}
				forcedHit = false;
				damaged = min(damaged + step*4/5, 88);
				color.varr = make_color_rgb(red + (255 - red)/2 + (red - 255)*dcos(360*damaged/8)/2,green + (32 - green)/2 + (green - 32)*dcos(360*damaged/8)/2,blue + (112 - blue)/2 + (blue - 112)*dcos(360*damaged/8)/2);
				if (damaged < 30 and hurtanim.enable){
					image_angle = 360*4*damaged/30;
					x += 12*dcos(hurtanim.angle)*step;
					y -= 12*dsin(hurtanim.angle)*step;
				}
				if (hurtanim.enable and damaged >= 30){
					image_angle = 0;
					hurtanim.enable = false;
				}
				if (damaged >= 88){
					damaged = -1;
					color.varr = color.cons;
				}
			}
			var movingg = false;
			var horizontal = 0;
			var vertical = 0;
			if (!Inmovil and !hurtanim.enable){
				if (!AI){
					horizontal = CheckControlInput(control_type, zurdo, action.horizontal, false, control_id);
					vertical = CheckControlInput(control_type, zurdo, action.vertical, false, control_id);
				}else{
					if (control_type != controls.keyboard){
						int.timer -= step;
						if (int.timer <= 0){
							int.timer = irandom_range(30,200);
							int.value = min(random_range(0.3, 2), 1);
						}
					}
					if (timer.wait <= 0){
						timer.wait = irandom_range(30, 90);
						goto.x = irandom_range(limits.left + Camera.x, limits.right + Camera.x);
						goto.y = irandom_range(limits.down + Camera.y, limits.up + Camera.y);
						goto.posX = sign(goto.x - x);
						goto.posY = sign(goto.y - y);
					}
					var positionX = sign(goto.x - x);
					var positionY = sign(goto.y - y);
					if (goto.posX != positionX and goto.posY != positionY){
						timer.wait -= step;
						goto.posX = 2;
						goto.posY = 2;
					}
					var ang = point_direction(x, y, goto.x, goto.y);
					if (goto.posX == positionX){
						if (control_type == controls.keyboard){
							horizontal = sign(goto.posX);
						}else{
							horizontal = dcos(ang)*int.value;
						}
					}
					if (goto.posY == positionY){
						if (control_type == controls.keyboard){
							vertical = sign(goto.posY);
						}else{
							vertical = -dsin(ang)*int.value;
						}
					}
				}
			}
			movingg = (horizontal != 0 or vertical != 0);
			if (movingg){
				mov.x = horizontal;
				mov.y = vertical;
			}else{ if (moving != movingg and !movingg){
				mov.x = 0;
				mov.y = 0;
			}}
			timer.dash -= step;
			if (timer.dash > 10){
				vel.current = vel.dash;
			}
			if (!Inmovil and canDash and !hurtanim.enable){
				if (!AI){
					if (CheckControlInput(control_type, zurdo, action.confirm, false, control_id) and timer.dash <= 0){
						vel.current = vel.dash;
						timer.dash = 18;
						boom.x = x;
						boom.y = y;
						if (!movingg){
							mov.x = 1;
						}
					}
				}else{
					dashtimer -= step;
					if (dashtimer <= 0){
						dashtimer = irandom_range(25, 200);
						vel.current = vel.dash;
						timer.dash = 18;
						boom.x = x;
						boom.y = y;
						if (!movingg){
							mov.x = 1;
						}
					}
				}
			}
			var len = point_distance(0, 0, mov.x, mov.y);
			if (len > 1){
				mov.x /= len;
				mov.y /= len;
			}
			if (timer.dash == 18){
				if (!movingg){
					for (var i=0;i<30;i++){
						array_push(particles, {x: x + random_range(-4, 4), y: y + random_range(-2.1, 2.1), size: random_range(1, 2.5), dir: -90 + random_range(-37.5, 37.5), speed: random_range(2*len, 16*len), alpha: image_alpha});
					}
				}else{
					for (var i=0;i<30;i++){
						array_push(particles, {x: x + random_range(-4, 4), y: y + random_range(-2.1, 2.1), size: random_range(1, 2.5), dir: point_direction(0, 0, mov.x, mov.y) - 90 + random_range(-37.5, 37.5), speed: random_range(2*len, 16*len), alpha: image_alpha});
					}
				}
			}
			if (!Inmovil){
				x += vel.current*mov.x*step;
				y += vel.current*mov.y*step;
			}
			x = clamp(x, limits.left + Camera.x, limits.right + Camera.x);
			y = clamp(y, limits.up + Camera.y, limits.down + Camera.y);
			vel.current += (vel.normal - vel.current)*0.1*step;
			image_angle += angle_difference((len > 0) ? point_direction(0, 0, mov.x, mov.y) - 90 : 0, image_angle)*(0.4 - 0.2*(1 - vel.current/vel.normal)/2.21)*step;
			var diff = (1 - vel.current/vel.normal)*0.06;
			if (moving != movingg and !movingg){
				vel.current = vel.normal;
				timer.idle = 30;
			}
			if (!movingg and timer.dash > 10 - step and timer.dash <= 10){
				mov.x = 0;
				vel.current = vel.normal;
				timer.idle = 30;
			}
			if (len > 0){
				timer.particles += step;
				if (timer.particles >= 3){
					timer.particles -= 3;
					array_push(particles, {x: x, y: y, size: random_range(1, 2.5), dir: image_angle + random_range(-30, 30), speed: random_range(1.25*len, 4*len), alpha: image_alpha});
				}
			}else{
				timer.particles = 0;
			}
			moving = movingg;
			scale.x += ((0.32 - len*0.06 + diff - scale.x)*0.35 + sin(timer.idle/2)*0.05*(timer.idle/30))*step;
			scale.y += ((0.32 + len*0.06 - diff - scale.y)*0.35 - sin(timer.idle/2)*0.05*(timer.idle/30))*step;
			if (timer.idle > 0){
				timer.idle = max(timer.idle - step, 0);
			}
		}
		shape.Set(new Vector3(x, y, depth), new Vector3(25*image_xscale, 25*image_yscale, 25*max(image_xscale, image_yscale)))
	}else{ if (modo == mode.helicopter){
		if (murio){
			if (damaged == 0){
				rank--;
				py = y;
				px = x;
				ppy = y + 9 - special_data.shaperange*dcos(handsrot);
				ppx = x - special_data.shaperange*dsin(handsrot);
				times = 3;
				timess = 11;
				var color1 = make_color_rgb(color_get_red(color.varr)*0.8, color_get_green(color.varr)*0.8, color_get_blue(color.varr)*0.8);
				var color2 = make_color_rgb(204 + color_get_red(color.varr)/5, 204 + color_get_green(color.varr)/5, 204 + color_get_blue(color.varr)/5);
				for (var i=0;i<6;i++){
					var scalee = {x: 0.615, y: 0.615};
					switch (i){
						case 2:
							scalee.x = 0.75;
						break;
						case 3:
							scalee.x = 0.315;
							scalee.y = 0.315;
						break;
						case 4: case 5:
							scalee.x = 0.105;
							scalee.y = 0.105;
						break;
					}
					array_push(bodyparts, {x: x, y: y, vel: {x: random_range(-8,8), y: random_range(-2,20), rot: random_range(-6, 6)}, rot: random(360), sub: i, col: (i < 2) ? color2 : color1, scale: scalee})
				}
			}
			damaged += step;
			y = py + 16*dsin(4.5*damaged);
			if (x > Camera.x - 50 and !outsideView){
				x -= 2*damaged/100;
			}else{
				x = Camera.x - 100;
				outsideView = true;
			}
			var offset = 10*(3 - times);
			while (times > 0 and damaged >= offset){
				for (var i=0;i<8;i++){
					array_push(circles,{x: ppx, y: ppy, ang: 45*i, scale: 1, time: damaged - offset});
				}
				times--;
				offset = 10*(3 - times);
			}
			offset = 4*(11 - timess);
			while (timess > 0 and damaged >= offset){
				array_push(explotions,{x: px + irandom_range(-40,40), y: py + irandom_range(-40,40), time: damaged - offset});
				timess--;
				offset = 4*(11 - timess);
			}
			if (damaged >= 20){
				var length = array_length(PlayerInstances);
				for (var i=0;i<length;i++){
					var otherplayer = PlayerInstances[i];
					if (otherplayer != id and place_meeting(x,y,otherplayer)){
						if (!otherplayer.murio and otherplayer.damaged == -1){
							audio_play_sound(snd_checkpoint, 0, false);
							HP = 1;
							murio = false;
							handsrot = 180;
							facing = 1;
							body.x = 0;
							bounce.timer = 31;
							damaged = 0;
							outsideView = false;
							if (instanceof(Revive) == "function"){
								try{
									Revive(otherplayer);
								}catch (e){
									show_message(e.message);
									obj_game.state = level.error;
								}
							}
							break;
						}
					}
				}
			}
		}else{
			if (damaged >= 0){
				if (rank == 7 and !forcedHit){
					rank--;
				}
				forcedHit = false;
				if (damaged == 0 and hurtanim.enable){
					vel.x = 10*dcos(hurtanim.angle);
					vel.y = 10*dsin(hurtanim.angle);
				}
				damaged = min(damaged + 4*step/5, 88);
				color.varr = make_color_rgb(red + (255 - red)/2 + (red - 255)*dcos(360*damaged/8)/2,green + (32 - green)/2 + (green - 32)*dcos(360*damaged/8)/2,blue + (112 - blue)/2 + (blue - 112)*dcos(360*damaged/8)/2);
				if (damaged >= 20 and hurtanim.enable){
					hurtanim.enable = false;
					stopscroll = false;
				}
				if (damaged >= 88){
					damaged = -1;
					color.varr = color.cons;
				}
			}
			var horizontal = 0;
			var vertical = 0;
			if (!Inmovil){
				if (!AI){
					horizontal = CheckControlInput(control_type, zurdo, action.horizontal, false, control_id);
					vertical = CheckControlInput(control_type, zurdo, action.vertical, false, control_id);
				}else{
					if (control_type != controls.keyboard){
						int.timer -= step;
						if (int.timer <= 0){
							int.timer = irandom_range(30,200);
							int.value = min(random_range(0.3, 2), 1);
						}
					}
					if (timer.wait <= 0){
						timer.wait = irandom_range(30, 90);
						goto.x = irandom_range(limits.left - 50 + Camera.x, limits.right + 50 + Camera.x);
						goto.y = irandom_range(limits.down + 50 + Camera.y, limits.up - 50 + Camera.y);
						goto.posX = sign(goto.x - x);
						goto.posY = sign(goto.y - y);
					}
					var positionX = sign(goto.x - x);
					var positionY = sign(goto.y - y);
					if (goto.posX != positionX and goto.posY != positionY and knockout <= 0){
						timer.wait -= step;
						goto.posX = 2;
						goto.posY = 2;
					}else{ if (knockout > 0){
						goto.posX = 2;
						goto.posY = 2;
					}}
					var ang = point_direction(x, y, goto.x, goto.y);
					if (goto.posX == positionX){
						if (control_type == controls.keyboard){
							horizontal = sign(goto.posX);
						}else{
							horizontal = dcos(ang)*int.value;
						}
					}
					if (goto.posY == positionY){
						if (control_type == controls.keyboard){
							vertical = sign(goto.posY);
						}else{
							vertical = -dsin(ang)*int.value;
						}
					}
				}
			}
			var len = point_distance(0, 0, horizontal, vertical);
			if (len > 1){
				horizontal /= len;
				vertical /= len;
			}
			if (horizontal < 0 and !hurtanim.enable){
				eyes.x = max(eyes.x - 1.5*step, clamp(6*horizontal - Scroll.x, -6, 6));
				if (vel.x > 6*horizontal){
					vel.x = max(vel.x - 0.8*step, 6*horizontal);
				}else{ if (vel.x < 6*horizontal){
					vel.x = min(vel.x + (0.3 - 0.3*abs(horizontal))*step, 6*horizontal);
				}}
				if (facing == 1 and abs(Scroll.x) == 0){
					bounce.timer = 0;
					bounce.value = 0;
				}
				facing = -1;
			}else{ if (horizontal > 0 and !hurtanim.enable){
				eyes.x = min(eyes.x + 1.5*step, clamp(6*horizontal - Scroll.x, -6, 6));
				if (vel.x > 6*horizontal){
					vel.x = max(vel.x - (0.3 - 0.3*abs(horizontal))*step, 6*horizontal);
				}else{ if (vel.x < 6*horizontal){
					vel.x = min(vel.x + 0.8*step, 6*horizontal);
				}}
				if (facing == -1 and abs(Scroll.x) == 0){
					bounce.timer = 0;
					bounce.value = 0;
				}
				facing = 1;
			}else{
				if (eyes.x > -Scroll.x){
					eyes.x = max(eyes.x - 1.5*step, clamp(-Scroll.x, -6, 6));
				}else{ if (eyes.x < -Scroll.x){
					eyes.x = min(eyes.x + 1.5*step, clamp(-Scroll.x, -6, 6));
				}}
				if (vel.x > 0){
					vel.x = max(vel.x - 0.3*step, 0);
				}else{ if (vel.x < 0){
					vel.x = min(vel.x + 0.3*step, 0);
				}}
			}}
			if (vertical < 0 and !hurtanim.enable){
				eyes.y = max(eyes.y - 1.5*step, clamp(6*vertical - Scroll.y, -6, 6));
				if (vel.y > 6*vertical){
					vel.y = max(vel.y - 0.8*step, 6*vertical);
				}else{ if (vel.y < 6*vertical){
					vel.y = min(vel.y + (0.3 - 0.3*abs(vertical))*step, 6*vertical);
				}}
			}else{ if (vertical > 0 and !hurtanim.enable){
				eyes.y = min(eyes.y + 1.5*step, clamp(6*vertical - Scroll.y, -6, 6));
				if (vel.y > 6*vertical){
					vel.y = max(vel.y - (0.3 - 0.3*abs(vertical))*step, 6*vertical);
				}else{ if (vel.y < 6*vertical){
					vel.y = min(vel.y + 0.8*step, 6*vertical);
				}}
			}else{
				if (eyes.y > 0){
					eyes.y = max(eyes.y - 1.5*step, clamp(-Scroll.y, -6, 6));
				}else{ if (eyes.y < 0){
					eyes.y = min(eyes.y + 1.5*step, clamp(-Scroll.y, -6, 6));
				}}
				if (vel.y > 0){
					vel.y = max(vel.y - 0.3*step, 0);
				}else{ if (vel.y < 0){
					vel.y = min(vel.y + 0.3*step, 0);
				}}
			}}
			var condition = {x: -vel.x + Scroll.x, y: -vel.y + Scroll.y + 5.49};
			if (condition.x != 0 or condition.y != 0){
				var objective = angle_difference(point_direction(0, 0, condition.x, condition.y) - 90, handsrot);
				var rotate = objective/10;
				handsrot += max(abs(rotate), min(abs(objective), 3))*sign(rotate);
			}
			while (handsrot > 180){
				handsrot -= 360;
			}
			while (handsrot < -180){
				handsrot += 360;
			}
			if (Scroll.x > 0){
				facing = -1;
			}else{ if (Scroll.x < 0){
				facing = 1;
			}}
			if (facing == -1){
				body.x = max(body.x - 0.075*0.75*step, -0.75);
			}else{
				body.x = min(body.x + 0.075*0.75*step, 0.75);
			}
			condition.x = abs(Scroll.x);
			condition.y = abs(Scroll.y);
			if (vertical <= 0 and horizontal == 0){
				if (condition.x < 1){
					body.rot += clamp(angle_difference(0, body.rot), -step, step);
					halo.rot += clamp(angle_difference(0, halo.rot), -step, step);
				}else{ if (condition.x < 3){
					body.rot += clamp(angle_difference(-10, body.rot), -step, step);
					if (sign(Scroll.x) == 1){
						halo.rot += clamp(angle_difference(10, halo.rot), -step, step);
					}else{
						halo.rot += clamp(angle_difference(-10, halo.rot), -step, step);
					}
				}else{
					body.rot += clamp(angle_difference(-20, body.rot), -step, step);
					if (sign(Scroll.x) == 1){
						halo.rot += clamp(angle_difference(10, halo.rot), -step, step);
					}else{
						halo.rot += clamp(angle_difference(-10, halo.rot), -step, step);
					}
				}}
			}else{
				if (vertical <= 0 and condition.x < 3){
					body.rot += clamp(angle_difference(-10, body.rot), -step, step);
				}else{ if (vertical > 0 and (condition.x < 1 or condition.x >= 3)){
					body.rot += clamp(angle_difference(-20, body.rot), -step, step);
				}}
				if (horizontal < 0 and Scroll.x > -1){
					halo.rot += clamp(angle_difference(10, halo.rot), -step, step);
				}else{ if (horizontal > 0 and Scroll.x < 1){
					halo.rot += clamp(angle_difference(-10, halo.rot), -step, step);
				}}
			}
			if (!Inmovil){
				knockout = max(knockout - step, 0);
				if (x > limits.right + Camera.x - 1 or x < limits.left + Camera.x + 1){
					if (x > limits.right + Camera.x - 1){
						vel.x = -6;
					}else{
						vel.x = 6;
					}
					knockout = 10;
					bounce.timer = 0;
					bounce.value = 0;
					if (hurtanim.enable){
						stopscroll = true;
					}
					audio_play_sound(snd_bonk, 0, false);
				}
				if (py > limits.down + Camera.x - 1 or py < limits.up + Camera.x + 1){
					if (py > limits.down + Camera.x - 1){
						vel.y = -6;
					}else{
						vel.y = 6;
					}
					knockout = 10;
					bounce.timer = 0;
					bounce.value = 1;
					if (hurtanim.enable){
						stopscroll = true;
					}
					audio_play_sound(snd_bonk, 0, false);
				}
			}
			if (bounce.timer < 30) {
				bounce.timer = min(bounce.timer + step, 30)
				head.x = 0.75 - 0.1125/30*(30 - bounce.timer)*dsin(720/30*bounce.timer + 180*bounce.value);
				head.y = 0.75 + 0.1125/30*(30 - bounce.timer)*dsin(720/30*bounce.timer + 180*bounce.value);
			}
			if (!hurtanim.enable or stopscroll){
				x += Scroll.x*step;
				py += Scroll.y*step;
			}
			if (!Inmovil){
				x += vel.x*step;
				py += vel.y*step;
			}
			x = clamp(x, limits.left + Camera.x, limits.right + Camera.x);
			py = clamp(py, limits.up + Camera.y, limits.down + Camera.y);
			timer.particles += step;
			while (timer.particles >= 3){
				timer.particles -= 3;
				if ((vel.x != 0 or vel.y != 0) and !hurtanim.enable){
					array_push(particles, {x: x + (-86*dcos(body.rot) - 28*dsin(body.rot))*body.x, y: y - 21*dcos(body.rot) + 64.5*dsin(body.rot), size: random_range(1, 2.5), dir: point_direction(0, 0, vel.x - Scroll.x, vel.y - Scroll.y) + random_range(60, 120), speed: -point_distance(0, 0, vel.x - Scroll.x, vel.y - Scroll.y)*random_range(0.17, 0.5), alpha: image_alpha});
				}else{ if (Scroll.x != 0 or Scroll.y != 0){
					array_push(particles, {x: x + (-86*dcos(body.rot) - 28*dsin(body.rot))*body.x, y: y - 21*dcos(body.rot) + 64.5*dsin(body.rot), size: random_range(1, 2.5), dir: point_direction(0, 0, -Scroll.x, -Scroll.y) + random_range(60, 120), speed: -point_distance(0, 0, -Scroll.x, -Scroll.y)*random_range(0.17, 0.5), alpha: image_alpha});
				}}
			}
			if (hurtanim.enable){
				eyes.index = 1;
			}else{ if (knockout > 0 or feeling == feel.fear){
				eyes.index = 2;
			}else{
				eyes.index = 0;
			}}
		}
		timer.float += step;
		y = py + ((!Inmovil) ? 6*dsin(4*timer.float) : 0);
		if (body.x > 0){
			tailrot -= 6*step;
		}else{
			tailrot += 6*step;
		}
		halo.x = 0.75*dcos(8*timer.float);
	}}
}
if (instanceof(AfterUpdate) == "function"){
	try{
		AfterUpdate(id);
	}catch (e){
		show_message(e.message);
		obj_game.state = level.error;
	}
}
var curHP = 100/maxHP*HP;
if (frame > curHP){
	frame = max(frame + max(curHP - frame, -step), curHP);
}else{ if (frame < curHP){
	frame = min(frame + min(curHP - frame, step), curHP);
}}
if (!murio){
	x = clamp(x, limits.left + Camera.x, limits.right + Camera.x);
	switch (modo){
		case mode.shape:
			y = clamp(y, limits.up + Camera.y, limits.down + Camera.y);
		break;
		case mode.helicopter:
			py = clamp(py, limits.up + Camera.y, limits.down + Camera.y);
		break;
	}
	obj_game.world_3d.Remove(object);
	obj_game.world_3d.Add(object);
	var _object_colliding = obj_game.world_3d.CheckObject(object)
	if (!is_undefined(_object_colliding) and ((modo == mode.shape and (timer.dash <= 1 or vel.current - vel.normal == 0)) or modo == mode.helicopter) and damaged == -1){
		GetHit(_object_colliding.shape.position, 1);
	}
}
