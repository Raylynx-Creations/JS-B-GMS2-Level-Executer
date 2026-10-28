LoadLevels();
//LoadPlayerIcons();
selected = 2;
PlayerData = LoadPlayerConfig();
MaxHP = Levels[selected].hp;
Mode = (Levels[selected].play_as == "Shape") ? mode.shape : mode.helicopter;
for (var i=0;i<4;i++){
	PlayerData[i].control_type = controls.keyboard;
	PlayerData[i].control_id = 0;
	PlayerData[i].zurdo = false;
}
room_goto(rm_level); //Remove all the previous shit xd
text = ["Disclaimer","Just Shapes and Beats is property of Berzerk Studio,\nI do not own anything of this game title.\n\nThis fangame was made for pure fun, and it's available\nto play for free, without any charges.\nIf you payed for this game, report it immediatelly.\n\nI also do not own any music used in this fangame."];
for (var i=0;i<8;i++){
	data[i] = {timer: irandom(99), angle: 0, xscale: 1, yscale: 1, direction: 1 - 2*irandom(1)};
}
Songs = [];
Bullets = {Alive: [], Dead: []};
Background = {Alive: [], Dead: []};
canproceed = false;
indice = -1;
compilation = -1;
Init = -1;
Update = -1;
Draw = -1;
Rewind = -1;
surface = [-1, -1, -1, -1, -1];
maincontrols = controls.keyboard;
zurdo = false;
camera = {x: 0, y: 0};
mouse = {x: mouse_x, y: mouse_y};
Created = true; //true
Squares = [];
world_3d = new ColWorldGameMaker();
objects_3d = [];
highestrank = 0;
camera_view = view_camera[0];
state = menu.waiting;
timer = 0;
timer2 = 0;
inLoop = false;
segInLoop = false;
selecting = 0;
bounce = false;
shake = 0;
buttoff = 0;
songtime = floor(SongTime/0.48);
audio_group_load(music_group);
audio_group_load(sound_group);
texture_prefetch("tex_grp_onetime"); //Remove comment when done
music = -1;
indication = ["Space", "ESC"];
lvl_prev = undefined;
res = LoadSettings();
currentSong = {state: false};
currentCheckpoint = [-1, -1, -1];
songtimeAboveZero = -1;
skip = -1;
segment = -1;
pitch = 1;
Checkpoints = [];
flash = -1;
death = {timer: -1, color: c_white};
glitch = {timer: 0, alpha: 0, state: 0};
glitches = [];
configuringSegments = false;
for (var i=0; i<10; i++){
	array_push(glitches, {y: 0, vel: 0, size: 0, duration: 0});
}
barLevel = {state: levelBar.none, tempStuck : -1, staticStuck: -1, iconAnim: 0, shake: {x: 0, y: 0, timer: 0}, stuck: -1, lock: {alpha: 0, pulse: 0, rot: 0, size: 0.75, color: c_cyan, enabled: false}, endCreated: false, message: {text: "", color: c_cyan, timer: -1}, extraMessage: {text: "", color: c_cyan, timer: -1, finish: 0}, loop: {message: "", timer: 0, color: c_cyan, enabled: false}, stunned: {start: 0, backoff: 0, timer: -1, damaged: false}, timer: 0, color: c_cyan, color2: {r: -1, g: -1, b: -1}, color3: {r: -1, g: -1, b: -1}, color4: false, anim: 0, index: {music: 0, visual: 0}, order: []};
segmentBar = {player: 0, condition: undefined, damage: 0, damaged: false, iconAnim: 0, damageTimer: 0, deathParticles: [], deathTimes: 3, shake: {x: 0, y: 0, timer: 0}, type: "", playerColor: 0, lock: {alpha: 0, pulse: 0, rot: 0, size: 0.75, color: c_cyan, enabled: false}, anim: 0, stunned: {start: 0, backoff: 0, timer: -1, damaged: false}, surface: -1, color: c_cyan, color2: {r: -1, g: -1, b: -1}, color3: {r: -1, g: -1, b: -1}, color4: false, anim: 0, index: {music: 0, visual: 0}, order: []};
barBoss = {state: bossBar.none, timer: 0};
sound_init();
sound_generate_channels(1);
positionTrack = 0;
ShowSongTitle = function(title, artist, from, type){
	currentSong.timer = 0;
	currentSong.levelby = ["",undefined];
	currentSong.recreatedby = ["",undefined];
	currentSong.title = title;
	currentSong.state = true;
	currentSong.type = type;
	currentSong.version = "";
	array_copy(currentSong.artist,0,artist,0,array_length(artist));
	if (artist[1] != ""){
		var itemm = currentSong.artist;
		itemm[1] = getSprite(itemm[1]);
	}
	currentSong.from = variable_clone(from);
	if (!is_undefined(from) and from[1] != ""){
		var itemm = currentSong.from;
		itemm[1] = getSprite(itemm[1]);
	}
}
UpdateBars = function(tempSeg){
	if (barLevel.state != levelBar.none){
		var step = delta_time/(1000000/60);
		barLevel.timer += step;
		barLevel.anim += step;
		segmentBar.anim += step;
		barLevel.iconAnim += step;
		segmentBar.iconAnim += step;
		barLevel.shake.timer = max(barLevel.shake.timer - step, 0);
		if (barLevel.shake.timer > 0){
			var range = min(barLevel.timer/2, 8);
			barLevel.shake.x = irandom_range(-range, range);
			barLevel.shake.y = irandom_range(-range, range);
		}else{
			barLevel.shake.x = 0;
			barLevel.shake.y = 0;
		}
		segmentBar.shake.timer = max(segmentBar.shake.timer - step, 0);
		if (segmentBar.shake.timer > 0){
			var range = min(segmentBar.timer/2, 8);
			segmentBar.shake.x = irandom_range(-range, range);
			segmentBar.shake.y = irandom_range(-range, range);
		}else{
			segmentBar.shake.x = 0;
			segmentBar.shake.y = 0;
		}
		var item = barLevel.order[barLevel.index.visual];
		switch (barLevel.state){
			case levelBar.start:
				if (!barLevel.color4 and item.type.keepIconOnThisBar and (item.type.name == "boss" or item.type.name == "boss battle")){
					if (barLevel.timer < 100){
						barLevel.color = c_cyan;
					}else{
						if (barLevel.shake.timer < max(112 - barLevel.timer, 0)){
							barLevel.shake.timer = 112 - barLevel.timer;
						}
						barLevel.color = c_pink;
					}
				}
			break;
			case levelBar.replacing: case levelBar.extending:
				var prevItem = barLevel.order[barLevel.index.visual - 1];
				if (!barLevel.color4){
					if (barLevel.timer < 100){
						if (prevItem.type.name == "boss" or prevItem.type.name == "boss battle"){
							if (prevItem.type.name != item.type.name){
								barLevel.color = make_color_rgb(127.5 + 127.5*dcos(6*min(barLevel.timer, 30)), 143.5 - 111.5*dcos(6*min(barLevel.timer, 30)), 183.5 - 71.5*dcos(6*min(barLevel.timer, 30)));
							}else{
								barLevel.color = c_pink;
							}
						}
					}else if (item.type.name == "boss" or item.type.name == "boss battle"){
						if (item.type.keepIconOnThisBar or item.type.showIconOnPrevBar){
							if (prevItem.type.name != item.type.name){
								if (barLevel.shake.timer < max(112 - barLevel.timer, 0)){
									barLevel.shake.timer = 112 - barLevel.timer;
								}
							}
							barLevel.color = c_pink;
						}else if (prevItem.type.name != item.type.name){
							if (barLevel.timer < 130){
								barLevel.color = make_color_rgb(127.5 - 127.5*dcos(6*min(barLevel.timer - 100, 30)), 143.5 + 111.5*dcos(6*min(barLevel.timer - 100, 30)), 183.5 + 71.5*dcos(6*min(barLevel.timer - 100, 30)));
							}else{
								barLevel.color = c_pink;
							}
						}else{
							barLevel.color = c_pink;
						}
					}else{
						barLevel.color = c_cyan;
					}
				}
			break;
			case levelBar.sectionReplacing: case levelBar.sectionExtending:
				if (segmentBar.color2.r != -1 and segmentBar.color3.r != -1 and !segmentBar.color4){
					if (barLevel.timer <= 135){
						var counter = max(barLevel.timer - 60, 0)/75;
						segmentBar.color = make_color_rgb(segmentBar.color2.r + (segmentBar.color3.r - segmentBar.color2.r)*counter, segmentBar.color2.g + (segmentBar.color3.g - segmentBar.color2.g)*counter, segmentBar.color2.b + (segmentBar.color3.b - segmentBar.color2.b)*counter)
					}else{
						segmentBar.color = make_color_rgb(segmentBar.color3.r, segmentBar.color3.g, segmentBar.color3.b);
					}
				}
			break;
		}
	}
	var item = barLevel.order[barLevel.index.music];
	var length = array_length(item.events);
	var timeSong = ((barLevel.stuck == -1) ? SongTime : barLevel.stuck);
	var amount = (barLevel.stuck == -1) ? 1 : 2;
	for (var j=0;j<amount;j++){
		for (var i=0;i<length;i++){
			var event = item.events[i];
			switch (event.name){
				case "checkpoint":
					if (timeSong >= event.time and !inLoop and !segInLoop and !event.special and !event.created){
						array_push(Checkpoints, {time: event.time, offset: (is_undefined(tempSeg)) ? 0 : tempSeg, damage: event.damage, index: event.index, barIndex: barLevel.index.music, segmentIndex: ((j == 1) ? segmentBar.index.music : -1), reference: event});
						event.created = true;
					}
				break;
				case "collectible": case "custom":
					if (event.dispAnim == -1){
						var result = false;
						try{
							result = event.collected();
						}catch (e){
							show_message(e.message);
							state = level.error;
						}
						if (result){
							event.dispAnim = 0;
						}
					}
				default:
					event.updated = false;
					if (event.checkpoint and timeSong >= event.time and !inLoop and !segInLoop and !event.created){
						array_push(Checkpoints, {time: event.time, offset: (is_undefined(tempSeg)) ? 0 : tempSeg, damage: event.damage, index: event.index, barIndex: barLevel.index.music, segmentIndex: ((j == 1) ? segmentBar.index.music : -1), reference: event});
						event.created = true;
					}
				break;
			}
		}
		if (amount == 2){
			item = segmentBar.order[segmentBar.index.music];
			length = array_length(item.events);
			timeSong = SongTime;
			tempSeg = undefined;
		}
	}
}
DrawBars = function(){
	switch (barLevel.state){
		case levelBar.none: {
			if (array_length(barLevel.order) > 0){
				var item = barLevel.order[barLevel.index.visual];
				var length = array_length(item.musicLoop);
				for (var i=0;i<length;i++){
					var event = item.musicLoop[i];
					if (event.eject >= 0){
						event.eject += delta_time/(1000000/60);
						if (event.eject >= 30){
							event.eject = -1;
						}
					}
				}
			}
			if (barLevel.stuck != -1 and array_length(segmentBar.order) > 0){
				var item = segmentBar.order[segmentBar.index.visual];
				var length = array_length(item.musicLoop);
				for (var i=0;i<length;i++){
					var event = item.musicLoop[i];
					if (event.eject >= 0){
						event.eject += delta_time/(1000000/60);
						if (event.eject >= 30){
							event.eject = -1;
						}
					}
				}
			}
		break; }
		case levelBar.start: {
			var item = barLevel.order[barLevel.index.visual];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			if (barLevel.timer <= 40){
				var length = array_length(item.musicLoop);
				var tempArray = [];
				barLevel.lock.enabled = false;
				for (var i=0;i<length;i++){
					var event = item.musicLoop[i];
					var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					if (ending == 692 and event.timer < 2.5){
						barLevel.lock.enabled = true;
						tempArray[0] = undefined;
						tempArray[1] = ending;
						tempArray[2] = 0;
						tempArray[3] = 0;
						DrawProgressBarEvents(event, 1, 0, 0, item, barLevel, tempArray, tempArray);
					}else if (event.eject >= 0){
						event.eject += delta_time/(1000000/60);
						if (event.eject >= 30){
							event.eject = -1;
						}
					}
				}
				if (barLevel.lock.enabled and barLevel.timer >= 15){
					var diff = barLevel.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					draw_sprite_ext(spr_goal, 0, 446 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, 0, c_white, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(barLevel.lock.pulse, dcos(90/15*max(barLevel.timer - 30, 0)))]);
					draw_sprite_ext(spr_goal, 1, 446 + barLevel.shake.x, 24 + barLevel.shake.y, diff, diff, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha*(barLevel.lock.size + 2 - diff)/2);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}else{
					draw_sprite_ext(spr_goal, 0, 446 + barLevel.shake.x, -16 + barLevel.shake.y + (40 + 8*dcos(clamp(36*(barLevel.timer - 5), 0, 90)))*dsin(clamp(18*barLevel.timer, 0, 90)), 0.5, 0.5, 0, c_white, 1);
				}
			}else if (barLevel.timer <= 103){
				var length = array_length(item.musicLoop);
				var tempArray = [];
				barLevel.lock.enabled = false;
				for (var i=0;i<length;i++){
					var event = item.musicLoop[i];
					var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					if (ending == 692 and event.timer < 2.5){
						barLevel.lock.enabled = true;
						tempArray[0] = undefined;
						tempArray[1] = ending;
						tempArray[2] = 0;
						tempArray[3] = 0;
						DrawProgressBarEvents(event, 1, 0, 0, item, barLevel, tempArray, tempArray);
					}else if (event.eject >= 0){
						event.eject += delta_time/(1000000/60);
						if (event.eject >= 30){
							event.eject = -1;
						}
					}
				}
				var seno = dsin(clamp(2*(barLevel.timer - 49), 0, 90));
				var movi = 370*seno;
				var color = make_color_rgb(color_get_red(barLevel.color)*102/255, color_get_green(barLevel.color)*102/255, color_get_blue(barLevel.color)*102/255);
				if (barLevel.timer >= 100 and item.type.keepIconOnThisBar and (item.type.name == "boss" or item.type.name == "boss battle")){
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(4.5*max(barLevel.timer - 100, 0))]);
				}	
				draw_sprite_ext(spr_pixel, 0, 430 + barLevel.shake.x + movi, 24 + barLevel.shake.y, movi, 16, 0, color, 0.5);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				if (barLevel.lock.enabled){
					if (barLevel.timer < 45){
						draw_sprite_ext(spr_goal, 0, 446 + barLevel.shake.x - 8*dsin(clamp(10*(barLevel.timer - 40), 0, 90)), 24 + barLevel.shake.y, 0.5, 0.5, 0, c_white, 1);
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(barLevel.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
						draw_sprite_ext(spr_goal, 1, 446 + barLevel.shake.x - 8*dsin(clamp(10*(barLevel.timer - 40), 0, 90)), 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
					}else{
						if (barLevel.lock.alpha < 1){
							draw_sprite_ext(spr_goal, 0, 446 + barLevel.shake.x - 8*dsin(clamp(10*(barLevel.timer - 40), 0, 90)) + (716 + 8*dcos(clamp(10*(barLevel.timer - 94), 0, 90)))*seno, 24 + barLevel.shake.y, 0.5, 0.5, 0, c_white, 1);
						}
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
						draw_sprite_ext(spr_goal, 1, 446 + barLevel.shake.x - 8*dsin(clamp(10*(barLevel.timer - 40), 0, 90)) + (716 + 8*dcos(clamp(10*(barLevel.timer - 94), 0, 90)))*seno, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}else{
					draw_sprite_ext(spr_goal, 0, 446 + barLevel.shake.x - 8*dsin(clamp(10*(barLevel.timer - 40), 0, 90)) + (716 + 8*dcos(clamp(10*(barLevel.timer - 94), 0, 90)))*seno, 24 + barLevel.shake.y, 0.5, 0.5, 0, c_white, 1);
				}
			}else{
				var counter = barLevel.timer - 103;
				var fullAlpha = counter/30;
				var color = make_color_rgb(color_get_red(barLevel.color)*102/255, color_get_green(barLevel.color)*102/255, color_get_blue(barLevel.color)*102/255);
				if (item.type.keepIconOnThisBar and (item.type.name == "boss" or item.type.name == "boss battle")){
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(4.5*min(barLevel.timer - 100, 20))]);
				}
				draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, counter/120);
				draw_sprite_ext(spr_pixel, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 370, 16, 0, color, (133 - barLevel.timer)/60);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				var length = array_length(item.events);
				var abovePlayer = [];
				for (var i=0;i<length;i++){
					var event = item.events[i];
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					/*if (position < 0){
						position = -16;
					}*/
					DrawProgressBarEvents(event, fullAlpha, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer);
				}
				var length = array_length(item.musicLoop);
				var tempArray = [];
				for (var i=0;i<length;i++){
					var event = item.musicLoop[i];
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					if (ending == 692 and event.timer < 2.5){
						barLevel.lock.enabled = true;
					}else{
						barLevel.lock.enabled = false;
					}
					tempArray[0] = undefined;
					tempArray[1] = ending;
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, fullAlpha, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
				}
				if (barLevel.stunned.timer == -1){
					draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(692*(SongTime - item.offset)/item.length, 0, 692), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, fullAlpha);
				}else{
					var step = delta_time/1000000;
					barLevel.stunned.timer += step;
					var limitmax = 120*barLevel.stunned.timer;
					if (limitmax > 3){
						var color = c_cyan;
						if (barLevel.stunned.damage){
							color = make_color_rgb(127.5 - 127.5*dcos(360/0.15*barLevel.stunned.timer), 143.5 + 111.5*dcos(360/0.15*barLevel.stunned.timer),183.5 + 71.5*dcos(360/0.15*barLevel.stunned.timer));
						}
						var original = 692*(SongTime - item.offset);
						var sostenido = 692*(barLevel.stunned.start - item.offset - barLevel.stunned.backoff*(limitmax - 3)/141);
						draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(max(original, sostenido)/item.length, 0, 692), 24 + barLevel.shake.y, 8, 8, 90/0.15*barLevel.stunned.timer, color, 1);
						if ((limitmax >= 144 or (barLevel.stunned.timer%0.15 >= 0 and barLevel.stunned.timer%0.15 < step)) and original >= sostenido){
							barLevel.stunned.timer = -1;
						}
					}else{
						draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(692*(barLevel.stunned.start - item.offset)/item.length, 0, 692), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, fullAlpha);
					}
				}
				if (barLevel.lock.enabled){
					if (barLevel.lock.alpha < 1){
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, 0, c_white, 1);
						if (nextItem != undefined and (item.type.name == "boss" or item.type.name == "boss battle") and nextItem.type.name != item.type.name and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*barLevel.lock.alpha - min(barLevel.timer - 103, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 118, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, diff, diff, 0, c_white, (2.7 - 0.2*barLevel.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, diff, diff, 0, c_white, (2.7 - 0.2*barLevel.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, 0, c_white, 1);
					if (nextItem != undefined and (item.type.name == "boss" or item.type.name == "boss battle") and nextItem.type.name != item.type.name and nextItem.type.showIconOnPrevBar){
						var diff = 2.7 - min(barLevel.timer - 103, 15)/7.5;
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 118, 0))]);
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, diff, diff, 0, c_white, (2.7 - diff)/2);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, diff, diff, 0, c_white, (2.7 - diff)/2);
						}
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
					}
				}
				length = array_length(abovePlayer);
				for (var i=0;i<length;i++){
					var event = abovePlayer[i];
					if (event.name == 45){
						var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
						tempArray[0] = undefined;
						tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
						tempArray[2] = barLevel.shake.x;
						tempArray[3] = 0;
						DrawProgressBarEvents(event, fullAlpha, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
					}else{
						var position = clamp(692*(event.time - item.offset)/item.length, -16 /*-1*/, 692);
						/*if (position < 0){
							position = -16;
						}*/
						DrawProgressBarEvents(event, fullAlpha, position + barLevel.shake.x, barLevel.shake.y, item, barLevel);
					}
				}
				if (barLevel.timer >= 133){
					barLevel.state = levelBar.track;
					barLevel.anim = 0;
				}
			}
			if (item.type.keepIconOnThisBar){
				switch (item.type.name){
					case "boss":
						draw_sprite_ext(spr_goal, 2, 70 + 350*dsin(min(1.5*barLevel.timer, 90)) + 830*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, -26 - 50*dcos(min(2*barLevel.timer, 180)) + 31*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, 1);
					break;
					case "boss battle":
						draw_sprite_ext(spr_goal, 3, 70 + 350*dsin(min(1.5*barLevel.timer, 90)) + 830*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, -26 - 50*dcos(min(2*barLevel.timer, 180)) + 31*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, 1);
					break;
				}
			}
		break; }
		case levelBar.track: {
			draw_sprite_ext(spr_meter, 0, 800, 24, 1, 1, 0, barLevel.color, 0.25);
			var item = barLevel.order[barLevel.index.visual];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer);
			}
			length = array_length(item.musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
			}
			if (barLevel.stunned.timer == -1){
				draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(692*(SongTime - item.offset)/item.length, 0, 692), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			}else{
				var step = delta_time/1000000;
				barLevel.stunned.timer += step;
				var limitmax = 120*barLevel.stunned.timer;
				if (limitmax > 3){
					var color = c_cyan;
					if (barLevel.stunned.damage){
						color = make_color_rgb(127.5 - 127.5*dcos(360/0.15*barLevel.stunned.timer), 143.5 + 111.5*dcos(360/0.15*barLevel.stunned.timer),183.5 + 71.5*dcos(360/0.15*barLevel.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(barLevel.stunned.start - item.offset - barLevel.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(max(original, sostenido)/item.length, 0, 692), 24 + barLevel.shake.y, 8, 8, 90/0.15*barLevel.stunned.timer, color, 1);
					if ((limitmax >= 144 or (barLevel.stunned.timer%0.15 >= 0 and barLevel.stunned.timer%0.15 < step)) and original >= sostenido){
						barLevel.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(692*(barLevel.stunned.start - item.offset)/item.length, 0, 692), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
				}
			}
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and (item.type.name == "boss" or item.type.name == "boss battle") and nextItem.type.name != item.type.name and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and (item.type.name == "boss" or item.type.name == "boss battle") and nextItem.type.name != item.type.name and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel);
				}
			}
			if (item.type.keepIconOnThisBar){
				switch (item.type.name){
					case "boss":
						draw_sprite_ext(spr_goal, 2, 420 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, 1);
					break;
					case "boss battle":
						draw_sprite_ext(spr_goal, 3, 420 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, 1);
					break;
				}
			}
		break; }
		case levelBar.replacing: {
			var item = [barLevel.order[barLevel.index.visual - 1], barLevel.order[barLevel.index.visual]];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var offset = 370 - 370*dcos(clamp(3*(barLevel.timer - 67.5), 0, 180));
			var offsetNew = 370 - 370*dcos(clamp(3*(barLevel.timer - 60), 0, 180));
			var offsetOld = 370 - 370*dcos(clamp(3*(barLevel.timer - 75), 0, 180));
			if (barLevel.timer > 100 and (item[1].type.keepIconOnThisBar or item[1].type.showIconOnPrevBar) and (item[1].type.name == "boss" or item[1].type.name == "boss battle") and item[0].type.name != item[1].type.name){
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(4.5*max(barLevel.timer - 100, 0))]);
			}
			draw_sprite_part_ext(spr_meter, 0, 0, 0, 370, 32, 430 + barLevel.shake.x + offsetOld - offset, 8 + barLevel.shake.y, 1, 1, barLevel.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 1, 32, 800 + barLevel.shake.x + offsetOld - offset, 8 + barLevel.shake.y, offsetNew - offsetOld, 1, barLevel.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 370, 32, 800 + barLevel.shake.x + offsetNew - offset, 8 + barLevel.shake.y, 1, 1, barLevel.color, 0.25);
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			var length = [array_length(item[0].events), array_length(item[1].events)];
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(max(740 - offsetOld, 1), 50);
			}else{ if (surface_get_width(surface[0]) != max(740 - offsetOld, 1)){
				surface_resize(surface[0], max(740 - offsetOld, 1), 50);
			}}
			if (!surface_exists(surface[1])){
				surface[1] = surface_create(max(offsetNew, 1), 50);
			}else{ if (surface_get_width(surface[1]) != max(offsetNew, 1)){
				surface_resize(surface[1], max(offsetNew, 1), 50);
			}}
			var pos = 0;
			var abovePlayer = [[], []];
			for (var i=0;i<2;i++){
				surface_set_target(surface[i]);
				draw_clear_alpha(c_black, 0);
				for (var j=0;j<length[i] - (i == 1 and item[1].extra);j++){
					var event = item[i].events[j];
					var position = clamp(692*(event.time - item[i].offset)/item[i].length, -32, 692);
					position += offset*(i - 1);
					if (variable_struct_exists(event, "ioasfnudiqwoaiucabxiw")){
						pos = position;
					}else{
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], barLevel, abovePlayer[i]);
					}
				}
				surface_reset_target();
			}
			var length2 = array_length(item[1].musicLoop);
			surface_set_target(surface[1]);
			var tempArray = [];
			for (var i=0;i<length2;i++){
				var event = item[1].musicLoop[i];
				var position = clamp(692*(event.start - item[1].offset)/item[1].length, -16, 692);
				var ending = clamp(692*(event.finish - item[1].offset)/item[1].length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position - 430, 0, item, barLevel, abovePlayer[1], tempArray);
			}
			surface_reset_target();
			if (740 - offsetOld > 0){
				draw_surface(surface[0], 430 + barLevel.shake.x - offset + offsetOld, barLevel.shake.y);
			}
			if (offsetNew > 0){
				draw_surface(surface[1], 1170 + barLevel.shake.x - offset, barLevel.shake.y);
			}
			if (barLevel.stunned.timer == -1){
				draw_sprite_ext(spr_pixel, 0, 1163 + barLevel.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(692*(SongTime - item[1].offset)/item[1].length, 0, 692*offsetNew/740), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			}else{
				var step = delta_time/1000000;
				barLevel.stunned.timer += step;
				var limitmax = 120*barLevel.stunned.timer;
				if (limitmax > 3){
					var color = c_cyan;
					if (barLevel.stunned.damage){
						color = make_color_rgb(127.5 - 127.5*dcos(360/0.15*barLevel.stunned.timer), 143.5 + 111.5*dcos(360/0.15*barLevel.stunned.timer),183.5 + 71.5*dcos(360/0.15*barLevel.stunned.timer));
					}
					var original = 692*(SongTime - item[1].offset);
					var sostenido = 692*(barLevel.stunned.start - item[1].offset - barLevel.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_pixel, 0, 1163 + barLevel.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(max(original, sostenido)/item[1].length, 0, 692*offsetNew/740), 24 + barLevel.shake.y, 8, 8, 90/0.15*barLevel.stunned.timer, color, 1);
					if ((limitmax >= 144 or (barLevel.stunned.timer%0.15 >= 0 and barLevel.stunned.timer%0.15 < step)) and original >= sostenido){
						barLevel.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_pixel, 0, 1163 + barLevel.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(692*(barLevel.stunned.start - item[1].offset)/item[1].length, 0, 692*offsetNew/740), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
				}
			}
			for (var i=0;i<2;i++){
				surface_set_target(surface[i]);
				draw_clear_alpha(c_black, 0);
				var length2 = array_length(abovePlayer[i]);
				for (var j=0;j<length2;j++){
					var event = abovePlayer[i][j];
					if (event.name == 45){
						var position = clamp(692*(event.start - item[i].offset)/item[i].length, -32, 692);
						tempArray[0] = undefined;
						tempArray[1] = clamp(692*(event.finish - item[i].offset)/item[i].length, -32, 692);
						tempArray[2] = -430;
						tempArray[3] = 0;
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], barLevel, undefined, tempArray, offsetOld, offsetNew);
					}else{
						var position = clamp(692*(event.time - item[i].offset)/item[i].length, -32, 692);
						position += offset*(i - 1);
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], barLevel, undefined, item[0], offsetOld, offsetNew);
					}
				}
				surface_reset_target();
			}
			if (item[1].extra){
				DrawProgressBarEvents(item[1].events[length[1] - 1], 1, max(pos, offsetOld - offset - 17), 0, item[1], barLevel, undefined, item[0], offsetOld, offsetNew);
			}
			if (barLevel.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = barLevel.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180)), 0.5, 0.5, 15*dsin(barLevel.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)), c_white, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(barLevel.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180)), diff, diff, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha*(barLevel.lock.size + 2 - diff)/2);
				}else{
					if (barLevel.lock.alpha < 1){
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), c_white, 1);
						if (nextItem != undefined and (item.type.name == "boss" or item.type.name == "boss battle") and nextItem.type.name != item.type.name and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*barLevel.lock.alpha - min(barLevel.timer - 105, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*barLevel.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*barLevel.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 15*dsin(barLevel.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)) + 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), c_white, 1);
				if (nextItem != undefined and (item.type.name == "boss" or item.type.name == "boss battle") and nextItem.type.name != item.type.name and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 105, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			if (740 - offsetOld > 0){
				draw_surface(surface[0], 430 + barLevel.shake.x - offset + offsetOld, barLevel.shake.y);
			}
			if (offsetNew > 0){
				draw_surface(surface[1], 1170 + barLevel.shake.x - offset, barLevel.shake.y);
			}
			var iconAnim = 0;
			if (item[0].type.name != item[1].type.name or !item[1].type.keepIconOnThisBar){
				if (item[0].type.keepIconOnThisBar){
					iconAnim = min(barLevel.timer, 30);
				}
			}else{
				iconAnim = max(30 - barLevel.timer, 0);
			}
			if (iconAnim > 0){
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(min(6*iconAnim, 90))]);
			}
			switch (item[0].type.name){
				case "boss":
					draw_sprite_ext(spr_goal, 2, 420 - offset + offsetOld + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, dcos(max(6*(iconAnim - 15), 0)));
				break;
				case "boss battle":
					draw_sprite_ext(spr_goal, 3, 420 - offset + offsetOld + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, dcos(max(6*(iconAnim - 15), 0)));
				break;
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (item[1].type.keepIconOnThisBar){
				if (item[0].type.name != item[1].type.name){
					var diff = 0.7 + 0.3*min(barLevel.timer, 15)/15;
					if (!item[1].type.showIconOnPrevBar){
						diff = 1 + 2*max(barLevel.timer, 15)/15;
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(6*clamp(barLevel.timer - 15, 0, 15))]);
					}
					switch (item[1].type.name){
						case "boss":
							draw_sprite_ext(spr_goal, 2, 324 - offset + offsetOld + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, 1 - max(diff - 1, 0)/2);
						break;
						case "boss battle":
							draw_sprite_ext(spr_goal, 3, 324 - offset + offsetOld + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, 1 - max(diff - 1, 0)/2);
						break;
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}else if (item[1].type.showIconOnPrevBar and item[0].type.name != item[1].type.name){
				var diff = 0.7 + 0.3*min(barLevel.timer, 15)/15;
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(6*clamp(barLevel.timer - 100, 0, 15))]);
				switch (item[1].type.name){
					case "boss":
						draw_sprite_ext(spr_goal, 2, 324 - offset + offsetOld + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, dcos(6*clamp(barLevel.timer - 115, 0, 15)));
					break;
					case "boss battle":
						draw_sprite_ext(spr_goal, 3, 324 - offset + offsetOld + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, dcos(6*clamp(barLevel.timer - 115, 0, 15)));
					break;
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}
			if (barLevel.timer >= 135){
				barLevel.state = levelBar.track;
				barLevel.anim = 0;
				surface_free(surface[0]);
				surface_free(surface[1]);
			}
		break; }
		case levelBar.extending: {
			var item = [barLevel.order[barLevel.index.visual - 1], barLevel.order[barLevel.index.visual]];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var offset = 370 - 370*dcos(clamp(3*(barLevel.timer - 67.5), 0, 180));
			var offsetNew = 370 - 370*dcos(clamp(3*(barLevel.timer - 60), 0, 180));
			if (barLevel.timer > 100 and (item[1].type.keepIconOnThisBar or item[1].type.showIconOnPrevBar) and (item[1].type.name == "boss" or item[1].type.name == "boss battle") and item[0].type.name != item[1].type.name){
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(4.5*max(barLevel.timer - 100, 0))]);
			}
			draw_sprite_part_ext(spr_meter, 0, 0, 0, 370, 32, 430 + barLevel.shake.x, 8 + barLevel.shake.y, 1, 1, barLevel.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 1, 32, 800 + barLevel.shake.x, 8 + barLevel.shake.y, offsetNew - offset, 1, barLevel.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 370, 32, 800 + barLevel.shake.x + offsetNew - offset, 8 + barLevel.shake.y, 1, 1, barLevel.color, 0.25);
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			var timediff = item[1].length - item[0].length;
			var length = array_length(item[1].events);
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(740 + offsetNew - offset, 50);
			}else{ if (surface_get_width(surface[0]) != 740 + offsetNew - offset){
				surface_resize(surface[0], 740 + offsetNew - offset, 50);
			}}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item[1].events[i];
				var time = event.time - item[1].offset;
				var position = clamp(692*time/(item[0].length + timediff*offset/740), -32 /*-1*/, 692*item[1].length/(item[0].length + timediff*offset/740));
				/*if (position < 0){
					position = -32;
				}*/
				if (time > item[0].length){
					position += 48*(740 - offset)/740;
				}
				DrawProgressBarEvents(event, 1, position - 430, 0, item[1], barLevel, abovePlayer);
			}
			length = array_length(item[1].musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item[1].musicLoop[i];
				var time = event.start - item[1].offset;
				var extra = 692*item[1].length/(item[0].length + timediff*offset/740);
				var position = clamp(692*time/(item[0].length + timediff*offset/740), -32, extra);
				if (time > item[0].length){
					position += 48*(740 - offset)/740;
				}
				var ending = clamp(692*(event.finish - item[1].offset)/(item[0].length + timediff*offset/740), -32, extra);
				var diff = extra - 692;
				if (ending - diff == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430 + 48*(740 - offset)/740;
				tempArray[3] = diff;
				DrawProgressBarEvents(event, 1, position - 430, 0, item[1], barLevel, abovePlayer, tempArray);
			}
			surface_reset_target();
			shader_reset();
			draw_surface(surface[0], 430 + barLevel.shake.x, barLevel.shake.y);
			shader_set(shd_preMulAlp);
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (barLevel.stunned.timer == -1){
				draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(692*(SongTime - item[1].offset)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			}else{
				var step = delta_time/1000000;
				barLevel.stunned.timer += step;
				var limitmax = 120*barLevel.stunned.timer;
				if (limitmax > 3){
					var color = c_cyan;
					if (barLevel.stunned.damage){
						color = make_color_rgb(127.5 - 127.5*dcos(360/0.15*barLevel.stunned.timer), 143.5 + 111.5*dcos(360/0.15*barLevel.stunned.timer),183.5 + 71.5*dcos(360/0.15*barLevel.stunned.timer));
					}
					var original = 692*(SongTime - item[1].offset);
					var sostenido = 692*(barLevel.stunned.start - item[1].offset - barLevel.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(max(original, sostenido)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 24 + barLevel.shake.y, 8, 8, 90/0.15*barLevel.stunned.timer, color, 1);
					if ((limitmax >= 144 or (barLevel.stunned.timer%0.15 >= 0 and barLevel.stunned.timer%0.15 < step)) and original >= sostenido){
						barLevel.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(692*(barLevel.stunned.start - item[1].offset)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
				}
			}
			if (barLevel.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = barLevel.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180)), 0.5, 0.5, 15*dsin(barLevel.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)), c_white, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(barLevel.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180)), diff, diff, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha*(barLevel.lock.size + 2 - diff)/2);
				}else{
					if (barLevel.lock.alpha < 1){
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), c_white, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*barLevel.lock.alpha - min(barLevel.timer - 105, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*barLevel.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*barLevel.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 15*dsin(barLevel.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)) + 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), c_white, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 105, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x - offset + offsetNew, 20 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var time = event.start - item[1].offset;
					var extra = 692*item[1].length/(item[0].length + timediff*offset/740);
					var position = clamp(692*time/(item[0].length + timediff*offset/740), -16, extra);
					if (time > item[0].length){
						position += 48*(740 - offset)/740;
					}
					tempArray[0] = item[0];
					tempArray[1] = clamp(692*(event.finish - item[1].offset)/(item[0].length + timediff*offset/740), -16, extra);
					tempArray[2] = 48*(740 - offset)/740 - 430;
					tempArray[3] = extra - 692;
					DrawProgressBarEvents(event, 1, position - 430, 0, item[1], barLevel, undefined, tempArray, timediff, offset, offsetNew);
				}else{
					var time = event.time - item[1].offset;
					var position = clamp(692*time/(item[0].length + timediff*offset/740), -16, 692*item[1].length/(item[0].length + timediff*offset/740));
					if (time > item[0].length){
						position += 48*(740 - offset)/740;
					}
					DrawProgressBarEvents(event, 1, position - 430, 0, item[1], barLevel, undefined, item[0], timediff, offset, offsetNew);
				}
			}
			surface_reset_target();
			shader_reset();
			draw_surface(surface[0], 430 + barLevel.shake.x, barLevel.shake.y);
			shader_set(shd_preMulAlp);
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			var iconAnim = 0;
			if (item[0].type.name != item[1].type.name or !item[1].type.keepIconOnThisBar){
				if (item[0].type.keepIconOnThisBar){
					iconAnim = min(barLevel.timer, 30);
				}
			}else{
				iconAnim = max(30 - barLevel.timer, 0);
			}
			if (iconAnim > 0){
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(min(6*iconAnim, 90))]);
			}
			switch (item[0].type.name){
				case "boss":
					draw_sprite_ext(spr_goal, 2, 420 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, dcos(max(6*(iconAnim - 15), 0)));
				break;
				case "boss battle":
					draw_sprite_ext(spr_goal, 3, 420 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, dcos(max(6*(iconAnim - 15), 0)));
				break;
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (item[1].type.keepIconOnThisBar){
				if (item[0].type.name != item[1].type.name){
					var diff = 0.7 + 0.3*min(barLevel.timer, 15)/15;
					if (!item[1].type.showIconOnPrevBar){
						diff = 1 + 2*max(barLevel.timer, 15)/15;
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(6*clamp(barLevel.timer - 15, 0, 15))]);
					}
					switch (item[1].type.name){
						case "boss":
							draw_sprite_ext(spr_goal, 2, 324 + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, 1 - max(diff - 1, 0)/2);
						break;
						case "boss battle":
							draw_sprite_ext(spr_goal, 3, 324 + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, 1 - max(diff - 1, 0)/2);
						break;
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}else if (item[1].type.showIconOnPrevBar and item[0].type.name != item[1].type.name){
				var diff = 0.7 + 0.3*min(barLevel.timer, 15)/15;
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(6*clamp(barLevel.timer - 100, 0, 15))]);
				switch (item[1].type.name){
					case "boss":
						draw_sprite_ext(spr_goal, 2, 324 + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, dcos(6*clamp(barLevel.timer - 115, 0, 15)));
					break;
					case "boss battle":
						draw_sprite_ext(spr_goal, 3, 324 + 96*dsin(min(1.5*barLevel.timer, 90)) + (830 - offset + offsetNew)*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, 9 - 15*dcos(min(2*barLevel.timer, 180)) + 30*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, diff, diff, 15*dcos(barLevel.iconAnim), c_white, dcos(6*clamp(barLevel.timer - 115, 0, 15)));
					break;
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}
			if (barLevel.timer >= 135){
				barLevel.state = levelBar.track;
				barLevel.anim = 0;
				surface_free(surface[0]);
			}
		break; }
		case levelBar.sectionStart: { //Continue the keep icon on this bar from here and also making the showOnPrevBar show the boss icon when boss fight
			var pos = 45*dsin(3*clamp(barLevel.timer - 15, 0, 30));
			var item = segmentBar.order[segmentBar.index.visual];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			if (!surface_exists(segmentBar.surface)){
				segmentBar.surface = surface_create(740, 54);
			}
			surface_set_target(segmentBar.surface);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(spr_meter, 0, 370, -18 + pos, 1, 1, 0, segmentBar.color, 0.25);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer);
			}
			length = array_length(item.musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer, tempArray);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(SongTime - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(segmentBar.stunned.start - item.offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(max(original, sostenido)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(segmentBar.stunned.start - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			if (segmentBar.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = segmentBar.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					draw_sprite_ext(spr_goal, 0, 724, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(segmentBar.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 724, -18 + pos, diff, diff, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha*(segmentBar.lock.size + 2 - diff)/2);
				}else{
					if (segmentBar.lock.alpha < 1){
						var color = c_white;
						if (segmentBar.damage > 0){
							color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
						}
						draw_sprite_ext(spr_goal, 0, 724, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*segmentBar.lock.alpha - min(barLevel.timer - 15, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 30, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 724, -18 + pos, segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				draw_sprite_ext(spr_goal, 0, 724, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 15, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 30, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = -430;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar);
				}
			}
			surface_reset_target();
			shader_reset();
			draw_surface(segmentBar.surface, 430 + segmentBar.shake.x, 40 + segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (item.type.keepIconOnThisBar){ //a
				switch (item.type.name){
					case "boss":
						draw_sprite_ext(spr_goal, 2, 70 + 350*dsin(min(1.5*barLevel.timer, 90)) + 830*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, -26 - 50*dcos(min(2*barLevel.timer, 180)) + 31*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, 1);
					break;
					case "boss battle":
						draw_sprite_ext(spr_goal, 3, 70 + 350*dsin(min(1.5*barLevel.timer, 90)) + 830*dcos(clamp(2.25*(barLevel.timer - 60), 0, 90)) + barLevel.shake.x, -26 - 50*dcos(min(2*barLevel.timer, 180)) + 31*dcos(clamp(9*(barLevel.timer - 90), 0, 90)) + barLevel.shake.y, 1, 1, 15*dcos(barLevel.iconAnim), c_white, 1);
					break;
				}
			}
			//---------------------------
			var range = max(12 - barLevel.timer/2, 0)*clamp(barLevel.timer - 6, 0, 1);
			var shakeX = irandom_range(-range, range);
			var shakeY = irandom_range(-range, range);
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, shakeY + barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x + shakeX;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, abovePlayer, tempArray);
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692) + shakeX;
			var appear = min(barLevel.timer, 6)/6;
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x + shakeX;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 2.6 - 2*appear, 2.6 - 2*appear, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, appear);
			if (barLevel.timer >= 45){
				barLevel.state = levelBar.section;
				surface_free(segmentBar.surface);
			}
		break; }
		case levelBar.sectionStartHidden: {
			var item = segmentBar.order[segmentBar.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
			//---------------------------
			var range = max(12 - barLevel.timer/2, 0)*clamp(barLevel.timer - 6, 0, 1);
			var shakeX = irandom_range(-range, range);
			var shakeY = irandom_range(-range, range);
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, shakeY + barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x + shakeX;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, abovePlayer, tempArray);
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692) + shakeX;
			var appear = min(barLevel.timer, 6)/6;
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x + shakeX;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 2.6 - 2*appear, 2.6 - 2*appear, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, appear);
			if (barLevel.timer >= 24){
				barLevel.state = levelBar.sectionWaiting;
				surface_free(segmentBar.surface);
			}
		break; }
		case levelBar.sectionOnlyStart: {
			var pos = 42*dsin(3*min(barLevel.timer, 30));
			var item = segmentBar.order[segmentBar.index.visual];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			draw_sprite_ext(spr_meter, 0, 800, -18 + pos, 1, 1, 0, segmentBar.color, 0.25);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position, -42 + pos, item, segmentBar, abovePlayer);
			}
			length = array_length(item.musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = 0;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position, -42 + pos, item, segmentBar, abovePlayer, tempArray);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + clamp(692*(SongTime - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(segmentBar.stunned.start - item.offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + clamp(max(original, sostenido)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + clamp(692*(segmentBar.stunned.start - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			if (segmentBar.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = segmentBar.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					draw_sprite_ext(spr_goal, 0, 1154, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(segmentBar.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 1154, -18 + pos, diff, diff, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha*(segmentBar.lock.size + 2 - diff)/2);
				}else{
					if (segmentBar.lock.alpha < 1){
						var color = c_white;
						if (segmentBar.damage > 0){
							color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
						}
						draw_sprite_ext(spr_goal, 0, 1154, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*segmentBar.lock.alpha - min(barLevel.timer - 15, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 30, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154, -18 + pos, segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				draw_sprite_ext(spr_goal, 0, 1154, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 15, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 30, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = 0;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position, -42 + pos, item, segmentBar, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position, -42 + pos, item, segmentBar);
				}
			}
			if (barLevel.timer >= 45){
				barLevel.state = levelBar.sectionOnly;
				surface_free(segmentBar.surface);
			}
			//---------------------------------------------------
			var item = barLevel.order[barLevel.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
		break; }
		case levelBar.section: {
			var item = segmentBar.order[segmentBar.index.visual];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			draw_sprite_ext(spr_meter, 0, 800 + segmentBar.shake.x, 67 + segmentBar.shake.y, 1, 1, 0, segmentBar.color, 0.25);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, 43 + segmentBar.shake.y, item, segmentBar, abovePlayer);
			}
			length = array_length(item.musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = segmentBar.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, 43 + segmentBar.shake.y, item, segmentBar, abovePlayer, tempArray);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + segmentBar.shake.x + clamp(692*(SongTime - item.offset)/item.length, 0, 692), 67 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(segmentBar.stunned.start - item.offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + segmentBar.shake.x + clamp(max(original, sostenido)/item.length, 0, 692), 67 + segmentBar.shake.y, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + segmentBar.shake.x + clamp(692*(segmentBar.stunned.start - item.offset)/item.length, 0, 692), 67 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			var rot = 15*dsin(segmentBar.anim);
			if (segmentBar.lock.enabled){
				if (segmentBar.lock.alpha < 1){
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x, 67 + segmentBar.shake.y, 0.7 - 0.2*segmentBar.lock.alpha, 0.7 - 0.2*segmentBar.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x, 67 + segmentBar.shake.y, 0.7 - 0.2*segmentBar.lock.alpha, 0.7 - 0.2*segmentBar.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x, 67 + segmentBar.shake.y, 0.5, 0.5, rot, color, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x, 67 + segmentBar.shake.y, segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x, 67 + segmentBar.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x, 67 + segmentBar.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x, 67 + segmentBar.shake.y, 0.5, 0.5, rot, color, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = segmentBar.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, 43 + segmentBar.shake.y, item, segmentBar, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, 43 + segmentBar.shake.y, item, segmentBar);
				}
			}
			//--------------------------------------
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692);
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, 1);
		break; }
		case levelBar.sectionOnly: {
			var item = segmentBar.order[segmentBar.index.visual];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			draw_sprite_ext(spr_meter, 0, 800 + segmentBar.shake.x, 24 + segmentBar.shake.y, 1, 1, 0, segmentBar.color, 0.25);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, segmentBar.shake.y, item, segmentBar, abovePlayer);
			}
			length = array_length(item.musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = segmentBar.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, segmentBar.shake.y, item, segmentBar, abovePlayer, tempArray);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + segmentBar.shake.x + clamp(692*(SongTime - item.offset)/item.length, 0, 692), 24 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(segmentBar.stunned.start - item.offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + segmentBar.shake.x + clamp(max(original, sostenido)/item.length, 0, 692), 24 + segmentBar.shake.y, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 446 + segmentBar.shake.x + clamp(692*(segmentBar.stunned.start - item.offset)/item.length, 0, 692), 24 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			var rot = 15*dsin(segmentBar.anim);
			if (segmentBar.lock.enabled){
				if (segmentBar.lock.alpha < 1){
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x, 24 + segmentBar.shake.y, 0.7 - 0.2*segmentBar.lock.alpha, 0.7 - 0.2*segmentBar.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x, 24 + segmentBar.shake.y, 0.7 - 0.2*segmentBar.lock.alpha, 0.7 - 0.2*segmentBar.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x, 24 + segmentBar.shake.y, 0.5, 0.5, rot, color, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x, 24 + segmentBar.shake.y, segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x, 24 + segmentBar.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x, 24 + segmentBar.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x, 24 + segmentBar.shake.y, 0.5, 0.5, rot, color, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = segmentBar.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, segmentBar.shake.y, item, segmentBar, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + segmentBar.shake.x, segmentBar.shake.y, item, segmentBar);
				}
			}
			//---------------------------------------------------
			var item = barLevel.order[barLevel.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
		break; }
		case levelBar.sectionSuspend: {
			var pos = 45 - 45*dsin(4.5*clamp(barLevel.timer - 130, 0, 20));
			var item = segmentBar.order[segmentBar.index.visual];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
			if (!surface_exists(segmentBar.surface)){
				segmentBar.surface = surface_create(740, 54);
			}
			surface_set_target(segmentBar.surface);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(spr_meter, 0, 370, -18 + pos, 1, 1, 0, segmentBar.color, 0.25);
			length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer, undefined, undefined, undefined, undefined, item.finish);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(SongTime - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(segmentBar.stunned.start - item.offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(max(original, sostenido)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(segmentBar.stunned.start - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, undefined, undefined, undefined, undefined, undefined, item.finish);
			}
			surface_reset_target();
			shader_reset();
			draw_surface(segmentBar.surface, 430 + segmentBar.shake.x, 40 + segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			//--------------------------------------
			var range = max(64 - barLevel.timer/2, 0)*clamp(barLevel.timer - 130, 0, 1);
			var shakeX = irandom_range(-range, range);
			var shakeY = irandom_range(-range, range);
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692) + shakeX;
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, abovePlayer, tempArray);
			}
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,clamp(barLevel.timer - 130, 0, 1)*dcos(clamp(9*(barLevel.timer - 130), 0, 90))]);
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, 1);
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(clamp(9*(barLevel.timer - 120), 0, 90))]);
			var color = c_white;
			if (segmentBar.damage > 0){
				color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
			}
			draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (pos + barLevel.shake.x - 1184 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 72 - 24*dsin(1.5*min(barLevel.timer, 60)) - 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) - (29 + barLevel.shake.y + shakeY)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), color, 1 - clamp(barLevel.timer - 130, 0, 1));
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (barLevel.timer >= 160){
				barLevel.state = levelBar.sectionWaiting;
				barLevel.timer = 0;
			}
		break; }
		case levelBar.sectionOnlySuspend: {
			var pos = 42 - 42*dsin(4.5*clamp(barLevel.timer - 130, 0, 20));
			var item = segmentBar.order[segmentBar.index.visual];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
			if (!surface_exists(segmentBar.surface)){
				segmentBar.surface = surface_create(740, 54);
			}
			surface_set_target(segmentBar.surface);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(spr_meter, 0, 370, -18 + pos, 1, 1, 0, segmentBar.color, 0.25);
			length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer, undefined, undefined, undefined, undefined, item.finish);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(SongTime - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(segmentBar.stunned.start - item.offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(max(original, sostenido)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(segmentBar.stunned.start - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, undefined, undefined, undefined, undefined, undefined, item.finish);
			}
			surface_reset_target();
			shader_reset();
			draw_surface(segmentBar.surface, 430 + segmentBar.shake.x, segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			var color = c_white;
			if (segmentBar.damage > 0){
				color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
			}
			draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (-184 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 29 - 24*dsin(1.5*min(barLevel.timer, 60)) - 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) - (29 + barLevel.shake.y + shakeY)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), color, 1 - clamp(barLevel.timer - 130, 0, 1));
			if (barLevel.timer >= 160){
				barLevel.state = levelBar.none;
				barLevel.timer = 0;
			}
			//---------------------------------------------------
			var item = barLevel.order[barLevel.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
		break; }
		case levelBar.sectionWaiting: {
			var item = segmentBar.order[segmentBar.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
			//------------------------------------------------------------
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692);
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, 1);
		break; }
		case levelBar.sectionResume: {
			var pos = 45*dsin(3*min(barLevel.timer, 30));
			var item = segmentBar.order[segmentBar.index.visual];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			if (!surface_exists(segmentBar.surface)){
				segmentBar.surface = surface_create(740, 54);
			}
			surface_set_target(segmentBar.surface);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(spr_meter, 0, 370, -18 + pos, 1, 1, 0, segmentBar.color, 0.25);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer);
			}
			length = array_length(item.musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer, tempArray);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(SongTime - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item.offset);
					var sostenido = 692*(segmentBar.stunned.start - item.offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(max(original, sostenido)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 16 + clamp(692*(segmentBar.stunned.start - item.offset)/item.length, 0, 692), -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			if (segmentBar.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = segmentBar.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					draw_sprite_ext(spr_goal, 0, 724, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(segmentBar.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 724, -18 + pos, diff, diff, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha*(segmentBar.lock.size + 2 - diff)/2);
				}else{
					if (segmentBar.lock.alpha < 1){
						var color = c_white;
						if (segmentBar.damage > 0){
							color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
						}
						draw_sprite_ext(spr_goal, 0, 724, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*segmentBar.lock.alpha - min(barLevel.timer - 15, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 30, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 724, -18 + pos, segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				draw_sprite_ext(spr_goal, 0, 724, -18 + pos, 0.5, 0.5, 15*dsin(segmentBar.anim), color, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 15, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 30, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 724, -18 + pos, diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = -430;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar);
				}
			}
			surface_reset_target();
			shader_reset();
			draw_surface(segmentBar.surface, 430 + segmentBar.shake.x, 40 + segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			//------------------------------------------------------
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692);
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, 1);
			if (barLevel.timer >= 45){
				barLevel.state = levelBar.section;
				barLevel.timer = 0;
			}
		break; }
		case levelBar.sectionReplacing: {
			var offset = 370 - 370*dcos(clamp(3*(barLevel.timer - 67.5), 0, 180));
			var offsetNew = 370 - 370*dcos(clamp(3*(barLevel.timer - 60), 0, 180));
			var offsetOld = 370 - 370*dcos(clamp(3*(barLevel.timer - 75), 0, 180));
			draw_sprite_part_ext(spr_meter, 0, 0, 0, 370, 32, 430 + segmentBar.shake.x + offsetOld - offset, 51 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 1, 32, 800 + segmentBar.shake.x + offsetOld - offset, 51 + segmentBar.shake.y, offsetNew - offsetOld, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 370, 32, 800 + segmentBar.shake.x + offsetNew - offset, 51 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			var item = [segmentBar.order[segmentBar.index.visual - 1], segmentBar.order[segmentBar.index.visual]];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			var length = [array_length(item[0].events), array_length(item[1].events)];
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(max(740 - offsetOld, 1), 50);
			}else{ if (surface_get_width(surface[0]) != max(740 - offsetOld, 1)){
				surface_resize(surface[0], max(740 - offsetOld, 1), 50);
			}}
			if (!surface_exists(surface[1])){
				surface[1] = surface_create(max(offsetNew, 1), 50);
			}else{ if (surface_get_width(surface[1]) != max(offsetNew, 1)){
				surface_resize(surface[1], max(offsetNew, 1), 50);
			}}
			var pos = 0;
			var abovePlayer = [[], []];
			for (var i=0;i<2;i++){
				surface_set_target(surface[i]);
				draw_clear_alpha(c_black, 0);
				for (var j=0;j<length[i] - (i == 1 and item[1].extra);j++){
					var event = item[i].events[j];
					var position = clamp(692*(event.time - item[i].offset)/item[i].length, -32, 692);
					position += offset*(i - 1);
					if (variable_struct_exists(event, "ioasfnudiqwoaiucabxiw")){
						pos = position;
					}else{
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], segmentBar, abovePlayer[i]);
					}
				}
				surface_reset_target();
			}
			var length2 = array_length(item[1].musicLoop);
			var tempArray = [];
			surface_set_target(surface[1]);
			for (var i=0;i<length2;i++){
				var event = item[1].musicLoop[i];
				var position = clamp(692*(event.start - item[1].offset)/item[1].length, -16, 692);
				var ending = clamp(692*(event.finish - item[1].offset)/item[1].length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position - 430, 0, item, segmentBar, abovePlayer[1], tempArray);
			}
			surface_reset_target();
			if (740 - offsetOld > 0){
				draw_surface(surface[0], 430 + segmentBar.shake.x - offset + offsetOld, 43 + segmentBar.shake.y);
			}
			if (offsetNew > 0){
				draw_surface(surface[1], 1170 + segmentBar.shake.x - offset, 43 + segmentBar.shake.y);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 1163 + segmentBar.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(692*(SongTime - item[1].offset)/item[1].length, 0, 692*offsetNew/740), 67 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item[1].offset);
					var sostenido = 692*(segmentBar.stunned.start - item[1].offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 1163 + segmentBar.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(max(original, sostenido)/item[1].length, 0, 692*offsetNew/740), 67 + segmentBar.shake.y, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 1163 + segmentBar.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(692*(segmentBar.stunned.start - item[1].offset)/item[1].length, 0, 692*offsetNew/740), 67 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			for (var i=0;i<2;i++){
				surface_set_target(surface[i]);
				draw_clear_alpha(c_black, 0);
				var length2 = array_length(abovePlayer[i]);
				for (var j=0;j<length2;j++){
					var event = abovePlayer[i][j];
					if (event.name == 45){
						var position = clamp(692*(event.start - item[i].offset)/item[i].length, -32, 692);
						tempArray[0] = undefined;
						tempArray[1] = clamp(692*(event.finish - item[i].offset)/item[i].length, -32, 692);
						tempArray[2] = -430;
						tempArray[3] = 0;
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], segmentBar, undefined, tempArray, offsetOld, offsetNew);
					}else{
						var position = clamp(692*(event.time - item[i].offset)/item[i].length, -32, 692);
						position += offset*(i - 1);
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], segmentBar, undefined, item[0], offsetOld, offsetNew);
					}
				}
				surface_reset_target();
			}
			if (item[1].extra){
				DrawProgressBarEvents(item[1].events[length[1] - 1], 1, max(pos, offsetOld - offset - 17) + segmentBar.shake.x, 43 + segmentBar.shake.y, item[1], segmentBar, undefined, item[0], offsetOld, offsetNew);
			}
			if (segmentBar.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = segmentBar.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)), color, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(segmentBar.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), diff, diff, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha*(segmentBar.lock.size + 2 - diff)/2);
				}else{
					if (segmentBar.lock.alpha < 1){
						var color = c_white;
						if (segmentBar.damage > 0){
							color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
						}
						draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*segmentBar.lock.alpha - min(barLevel.timer - 105, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)) + 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 105, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x - offset + offsetNew, 63 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x - offset + offsetNew, 63 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			if (740 - offsetOld > 0){
				draw_surface(surface[0], 430 + segmentBar.shake.x - offset + offsetOld, 43 + segmentBar.shake.y);
			}
			if (offsetNew > 0){
				draw_surface(surface[1], 1170 + segmentBar.shake.x - offset, 43 + segmentBar.shake.y);
			}
			if (barLevel.timer >= 135){
				barLevel.state = levelBar.section;
				segmentBar.anim = 0;
				surface_free(surface[0]);
				surface_free(surface[1]);
			}
			//----------------------------------------
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692);
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, 1);
		break; }
		case levelBar.sectionOnlyReplacing: {
			var offset = 370 - 370*dcos(clamp(3*(barLevel.timer - 67.5), 0, 180));
			var offsetNew = 370 - 370*dcos(clamp(3*(barLevel.timer - 60), 0, 180));
			var offsetOld = 370 - 370*dcos(clamp(3*(barLevel.timer - 75), 0, 180));
			draw_sprite_part_ext(spr_meter, 0, 0, 0, 370, 32, 430 + segmentBar.shake.x + offsetOld - offset, 8 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 1, 32, 800 + segmentBar.shake.x + offsetOld - offset, 8 + segmentBar.shake.y, offsetNew - offsetOld, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 370, 32, 800 + segmentBar.shake.x + offsetNew - offset, 8 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			var item = [segmentBar.order[segmentBar.index.visual - 1], segmentBar.order[segmentBar.index.visual]];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			var length = [array_length(item[0].events), array_length(item[1].events)];
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(max(740 - offsetOld, 1), 50);
			}else{ if (surface_get_width(surface[0]) != max(740 - offsetOld, 1)){
				surface_resize(surface[0], max(740 - offsetOld, 1), 50);
			}}
			if (!surface_exists(surface[1])){
				surface[1] = surface_create(max(offsetNew, 1), 50);
			}else{ if (surface_get_width(surface[1]) != max(offsetNew, 1)){
				surface_resize(surface[1], max(offsetNew, 1), 50);
			}}
			var pos = 0;
			var abovePlayer = [[], []];
			for (var i=0;i<2;i++){
				surface_set_target(surface[i]);
				draw_clear_alpha(c_black, 0);
				for (var j=0;j<length[i] - (i == 1 and item[1].extra);j++){
					var event = item[i].events[j];
					var position = clamp(692*(event.time - item[i].offset)/item[i].length, -32, 692);
					position += offset*(i - 1);
					if (variable_struct_exists(event, "ioasfnudiqwoaiucabxiw")){
						pos = position;
					}else{
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], segmentBar, abovePlayer[i]);
					}
				}
				surface_reset_target();
			}
			var length2 = array_length(item[1].musicLoop);
			var tempArray = [];
			surface_set_target(surface[1]);
			for (var i=0;i<length2;i++){
				var event = item[1].musicLoop[i];
				var position = clamp(692*(event.start - item[1].offset)/item[1].length, -16, 692);
				var ending = clamp(692*(event.finish - item[1].offset)/item[1].length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position - 430, 0, item, segmentBar, abovePlayer[1], tempArray);
			}
			surface_reset_target();
			if (740 - offsetOld > 0){
				draw_surface(surface[0], 430 + segmentBar.shake.x - offset + offsetOld, segmentBar.shake.y);
			}
			if (offsetNew > 0){
				draw_surface(surface[1], 1170 + segmentBar.shake.x - offset, segmentBar.shake.y);
			}
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 1163 + segmentBar.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(692*(SongTime - item[1].offset)/item[1].length, 0, 692*offsetNew/740), 24 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item[1].offset);
					var sostenido = 692*(segmentBar.stunned.start - item[1].offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 1163 + segmentBar.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(max(original, sostenido)/item[1].length, 0, 692*offsetNew/740), 24 + segmentBar.shake.y, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 1163 + segmentBar.shake.x - 24*dcos(clamp(3*(barLevel.timer - 60), 0, 180)) - offset + clamp(692*(segmentBar.stunned.start - item[1].offset)/item[1].length, 0, 692*offsetNew/740), 24 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			for (var i=0;i<2;i++){
				surface_set_target(surface[i]);
				draw_clear_alpha(c_black, 0);
				var length2 = array_length(abovePlayer[i]);
				for (var j=0;j<length2;j++){
					var event = abovePlayer[i][j];
					if (event.name == 45){
						var position = clamp(692*(event.start - item[i].offset)/item[i].length, -32, 692);
						tempArray[0] = undefined;
						tempArray[1] = clamp(692*(event.finish - item[i].offset)/item[i].length, -32, 692);
						tempArray[2] = -430;
						tempArray[3] = 0;
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], segmentBar, undefined, tempArray, offsetOld, offsetNew);
					}else{
						var position = clamp(692*(event.time - item[i].offset)/item[i].length, -32, 692);
						position += offset*(i - 1);
						DrawProgressBarEvents(event, 1, position - 430, 0, item[i], segmentBar, undefined, item[0], offsetOld, offsetNew);
					}
				}
				surface_reset_target();
			}
			if (item[1].extra){
				DrawProgressBarEvents(item[1].events[length[1] - 1], 1, max(pos, offsetOld - offset - 17) + segmentBar.shake.x, segmentBar.shake.y, item[1], segmentBar, undefined, item[0], offsetOld, offsetNew);
			}
			if (segmentBar.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = segmentBar.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)), color, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(segmentBar.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), diff, diff, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha*(segmentBar.lock.size + 2 - diff)/2);
				}else{
					if (segmentBar.lock.alpha < 1){
						var color = c_white;
						if (segmentBar.damage > 0){
							color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
						}
						draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*segmentBar.lock.alpha - min(barLevel.timer - 105, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)) + 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 105, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x - offset + offsetNew, 63 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x - offset + offsetNew, 63 + barLevel.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			if (740 - offsetOld > 0){
				draw_surface(surface[0], 430 + segmentBar.shake.x - offset + offsetOld, segmentBar.shake.y);
			}
			if (offsetNew > 0){
				draw_surface(surface[1], 1170 + segmentBar.shake.x - offset, segmentBar.shake.y);
			}
			if (barLevel.timer >= 135){
				barLevel.state = levelBar.sectionOnly;
				segmentBar.anim = 0;
				surface_free(surface[0]);
				surface_free(surface[1]);
			}
			//---------------------------------------------------
			var item = barLevel.order[barLevel.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
		break; }
		case levelBar.sectionExtending: {
			var offset = 370 - 370*dcos(clamp(3*(barLevel.timer - 67.5), 0, 180));
			var offsetNew = 370 - 370*dcos(clamp(3*(barLevel.timer - 60), 0, 180));
			draw_sprite_part_ext(spr_meter, 0, 0, 0, 370, 32, 430 + segmentBar.shake.x, 51 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 1, 32, 800 + segmentBar.shake.x, 51 + segmentBar.shake.y, offsetNew - offset, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 370, 32, 800 + segmentBar.shake.x + offsetNew - offset, 51 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			var item = [segmentBar.order[segmentBar.index.visual - 1], segmentBar.order[segmentBar.index.visual]];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			var timediff = item[1].length - item[0].length;
			var length = array_length(item[1].events);
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(740 + offsetNew - offset, 50);
			}else{ if (surface_get_width(surface[0]) != 740 + offsetNew - offset){
				surface_resize(surface[0], 740 + offsetNew - offset, 50);
			}}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item[1].events[i];
				var time = event.time - item[1].offset;
				var position = clamp(692*time/(item[0].length + timediff*offset/740), -32 /*-1*/, 692*item[1].length/(item[0].length + timediff*offset/740));
				/*if (position < 0){
					position = -32;
				}*/
				if (time > item[0].length){
					position += 48*(740 - offset)/740;
				}
				DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, abovePlayer);
			}
			length = array_length(item[1].musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item[1].musicLoop[i];
				var time = event.start - item[1].offset;
				var extra = 692*item[1].length/(item[0].length + timediff*offset/740);
				var position = clamp(692*time/(item[0].length + timediff*offset/740), -32, extra);
				if (time > item[0].length){
					position += 48*(740 - offset)/740;
				}
				var extra = 692*offset/740;
				var ending = clamp(692*(event.finish - item[1].offset)/(item[0].length + timediff*offset/740), -32, extra);
				var diff = extra - 692;
				if (ending - diff == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430 + 48*(740 - offset)/740;
				tempArray[3] = diff;
				DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, abovePlayer, tempArray);
			}
			surface_reset_target();
			draw_surface(surface[0], 430 + segmentBar.shake.x, 43 + segmentBar.shake.y);
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 447 + segmentBar.shake.x + clamp(692*(SongTime - item[1].offset)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 67 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item[1].offset);
					var sostenido = 692*(segmentBar.stunned.start - item[1].offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 447 + segmentBar.shake.x + clamp(max(original, sostenido)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 67 + segmentBar.shake.y, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 447 + segmentBar.shake.x + clamp(692*(segmentBar.stunned.start - item[1].offset)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 67 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			if (segmentBar.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = segmentBar.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)), color, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(segmentBar.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), diff, diff, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha*(segmentBar.lock.size + 2 - diff)/2);
				}else{
					if (segmentBar.lock.alpha < 1){
						var color = c_white;
						if (segmentBar.damage > 0){
							color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
						}
						draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*segmentBar.lock.alpha - min(barLevel.timer - 105, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)) + 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 105, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var time = event.start - item[1].offset;
					var extra = 692*item[1].length/(item[0].length + timediff*offset/740);
					var position = clamp(692*time/(item[0].length + timediff*offset/740), -16, extra);
					if (time > item[0].length){
						position += 48*(740 - offset)/740;
					}
					tempArray[0] = item[0];
					tempArray[1] = clamp(692*(event.finish - item[1].offset)/(item[0].length + timediff*offset/740), -16, extra);
					tempArray[2] = 48*(740 - offset)/740 - 430;
					tempArray[3] = extra - 692;
					DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, undefined, tempArray, timediff, offset, offsetNew);
				}else{
					var time = event.time - item[1].offset;
					var position = clamp(692*time/(item[0].length + timediff*offset/740), -16, 1432 - offset);
					if (time > item[0].length){
						position += 48*(740 - offset)/740;
					}
					DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, undefined, item[0], timediff, offset, offsetNew);
				}
			}
			surface_reset_target();
			shader_reset();
			draw_surface(surface[0], 430 + segmentBar.shake.x, 43 + segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			if (barLevel.timer >= 135){
				barLevel.state = levelBar.section;
				segmentBar.anim = 0;
				surface_free(surface[0]);
			}
			//----------------------------------------
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.stuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
			}
			pos = 447 + clamp(692*(barLevel.stuck - item.offset)/item.length, 0, 692);
			draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.stuck);
				}
			}
			draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, 1);
		break; }
		case levelBar.sectionOnlyExtending: {
			var offset = 370 - 370*dcos(clamp(3*(barLevel.timer - 67.5), 0, 180));
			var offsetNew = 370 - 370*dcos(clamp(3*(barLevel.timer - 60), 0, 180));
			draw_sprite_part_ext(spr_meter, 0, 0, 0, 370, 32, 430 + segmentBar.shake.x, 8 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 1, 32, 800 + segmentBar.shake.x, 8 + segmentBar.shake.y, offsetNew - offset, 1, segmentBar.color, 0.25);
			draw_sprite_part_ext(spr_meter, 0, 370, 0, 370, 32, 800 + segmentBar.shake.x + offsetNew - offset, 8 + segmentBar.shake.y, 1, 1, segmentBar.color, 0.25);
			var item = [segmentBar.order[segmentBar.index.visual - 1], segmentBar.order[segmentBar.index.visual]];
			var nextItem = undefined;
			if (array_length(segmentBar.order) > segmentBar.index.visual + 1){
				nextItem = segmentBar.order[segmentBar.index.visual + 1];
			}
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			var timediff = item[1].length - item[0].length;
			var length = array_length(item[1].events);
			if (!surface_exists(surface[0])){
				surface[0] = surface_create(740 + offsetNew - offset, 50);
			}else{ if (surface_get_width(surface[0]) != 740 + offsetNew - offset){
				surface_resize(surface[0], 740 + offsetNew - offset, 50);
			}}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item[1].events[i];
				var time = event.time - item[1].offset;
				var position = clamp(692*time/(item[0].length + timediff*offset/740), -32 /*-1*/, 692*item[1].length/(item[0].length + timediff*offset/740));
				/*if (position < 0){
					position = -32;
				}*/
				if (time > item[0].length){
					position += 48*(740 - offset)/740;
				}
				DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, abovePlayer);
			}
			length = array_length(item[1].musicLoop);
			var tempArray = [];
			for (var i=0;i<length;i++){
				var event = item[1].musicLoop[i];
				var time = event.start - item[1].offset;
				var extra = 692*item[1].length/(item[0].length + timediff*offset/740);
				var position = clamp(692*time/(item[0].length + timediff*offset/740), -32, extra);
				if (time > item[0].length){
					position += 48*(740 - offset)/740;
				}
				var extra = 692*offset/740;
				var ending = clamp(692*(event.finish - item[1].offset)/(item[0].length + timediff*offset/740), -32, extra);
				var diff = extra - 692;
				if (ending - diff == 692 and event.timer < 2.5){
					segmentBar.lock.enabled = true;
				}else{
					segmentBar.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = -430 + 48*(740 - offset)/740;
				tempArray[3] = diff;
				DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, abovePlayer, tempArray);
			}
			surface_reset_target();
			draw_surface(surface[0], 430 + segmentBar.shake.x, segmentBar.shake.y);
			if (segmentBar.stunned.timer == -1){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 447 + segmentBar.shake.x + clamp(692*(SongTime - item[1].offset)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 24 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}else{
				var step = delta_time/1000000;
				segmentBar.stunned.timer += step;
				var limitmax = 120*segmentBar.stunned.timer;
				if (limitmax > 3){
					var color = segmentBar.playerColor;
					if (segmentBar.stunned.damage){
						color = make_color_rgb(color_get_red(color) + (255 - color_get_red(color))/2 - (255 - color_get_red(color))/2*dcos(360/0.15*segmentBar.stunned.timer), color_get_green(color) + (32 - color_get_green(color))/2 - (32 - color_get_green(color))/2*dcos(360/0.15*segmentBar.stunned.timer),color_get_blue(color) + (112 - color_get_blue(color))/2 - (112 - color_get_blue(color))/2*dcos(360/0.15*segmentBar.stunned.timer));
					}
					var original = 692*(SongTime - item[1].offset);
					var sostenido = 692*(segmentBar.stunned.start - item[1].offset - segmentBar.stunned.backoff*(limitmax - 3)/141);
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 447 + segmentBar.shake.x + clamp(max(original, sostenido)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 24 + segmentBar.shake.y, 0.16, 0.16, 90/0.15*segmentBar.stunned.timer, color, 1);
					if ((limitmax >= 144 or (segmentBar.stunned.timer%0.15 >= 0 and segmentBar.stunned.timer%0.15 < step)) and original >= sostenido){
						segmentBar.stunned.timer = -1;
					}
				}else{
					draw_sprite_ext(spr_playeroutside, segmentBar.player, 447 + segmentBar.shake.x + clamp(692*(segmentBar.stunned.start - item[1].offset)/(item[0].length + timediff*offset/740), 0, 692*(740 + offsetNew - offset)/740), 24 + segmentBar.shake.y, 0.16, 0.16, 0, segmentBar.playerColor, 1);
				}
			}
			if (segmentBar.lock.enabled and barLevel.timer >= 15){
				if (barLevel.timer < 45){
					var diff = segmentBar.lock.size + 2 - min(barLevel.timer - 15, 15)/7.5;
					var color = c_white;
					if (segmentBar.damage > 0){
						color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
					}
					draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)), color, 1);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(segmentBar.lock.pulse, dcos(90/15*min(barLevel.timer - 30, 15)))]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180)), diff, diff, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha*(segmentBar.lock.size + 2 - diff)/2);
				}else{
					if (segmentBar.lock.alpha < 1){
						var color = c_white;
						if (segmentBar.damage > 0){
							color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
						}
						draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
						if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
							var diff = 2.7 - 0.2*segmentBar.lock.alpha - min(barLevel.timer - 105, 15)/7.5;
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
							if (nextItem.type.name == "boss"){
								draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}else{
								draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - 0.2*segmentBar.lock.alpha - diff)/2);
							}
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,segmentBar.lock.pulse]);
					draw_sprite_ext(spr_goal, 1, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(180 + clamp(3*(barLevel.timer - 60), 0, 180)), segmentBar.lock.size, segmentBar.lock.size, segmentBar.lock.rot, segmentBar.lock.color, segmentBar.lock.alpha);
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				var color = c_white;
				if (segmentBar.damage > 0){
					color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				}
				draw_sprite_ext(spr_goal, 0, 1154 + segmentBar.shake.x - offset + offsetNew, 20 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(min(2*barLevel.timer, 90)) + 360*dsin(min(2*barLevel.timer, 90)) + 360*dcos(clamp(2.4*(barLevel.timer - 60), 0, 180)), color, 1);
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					var diff = 2.7 - min(barLevel.timer - 105, 15)/7.5;
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dcos(90/15*max(barLevel.timer - 120, 0))]);
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + segmentBar.shake.x - offset + offsetNew, 63 + segmentBar.shake.y + 4*dcos(min(6*barLevel.timer, 180) + clamp(3*(barLevel.timer - 60), 0, 180)), diff, diff, 0, c_white, (2.7 - diff)/2);
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}
			surface_set_target(surface[0]);
			draw_clear_alpha(c_black, 0);
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var time = event.start - item[1].offset;
					var extra = 692*item[1].length/(item[0].length + timediff*offset/740);
					var position = clamp(692*time/(item[0].length + timediff*offset/740), -16, extra);
					if (time > item[0].length){
						position += 48*(740 - offset)/740;
					}
					tempArray[0] = item[0];
					tempArray[1] = clamp(692*(event.finish - item[1].offset)/(item[0].length + timediff*offset/740), -16, extra);
					tempArray[2] = 48*(740 - offset)/740 - 430;
					tempArray[3] = extra - 692;
					DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, undefined, tempArray, timediff, offset, offsetNew);
				}else{
					var time = event.time - item[1].offset;
					var position = clamp(692*time/(item[0].length + timediff*offset/740), -16, 1432 - offset);
					if (time > item[0].length){
						position += 48*(740 - offset)/740;
					}
					DrawProgressBarEvents(event, 1, position - 430, 0, item[1], segmentBar, undefined, item[0], timediff, offset, offsetNew);
				}
			}
			surface_reset_target();
			shader_reset();
			draw_surface(surface[0], 430 + segmentBar.shake.x, segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			if (barLevel.timer >= 135){
				barLevel.state = levelBar.sectionOnly;
				segmentBar.anim = 0;
				surface_free(surface[0]);
			}
			//---------------------------------------------------
			var item = barLevel.order[barLevel.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
		break; }
		case levelBar.sectionEnd: {
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0 and !segmentBar.damaged and barLevel.timer >= 130){
				audio_play_sound(snd_dead, 0, false, 0.75, 0, 1.3);
				var length = array_length(PlayerInstances);
				for (var i=0;i<length;i++){
					PlayerInstances[i].GetHit({x: PlayerInstances[i].x + 1, y: PlayerInstances[i].y},segmentBar.damage,true,true,true,true);
					segmentBar.damaged = true;
				}
			}
			var pos = 45 - 45*dsin(4.5*clamp(barLevel.timer - 130, 0, 20));
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				pos = 45 - 45*dsin(4.5*clamp(barLevel.timer - 150, 0, 20));
			}
			var item = segmentBar.order[segmentBar.index.visual];
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			if (!surface_exists(segmentBar.surface)){
				segmentBar.surface = surface_create(740, 54);
			}
			surface_set_target(segmentBar.surface);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(spr_meter, 0, 370, -18 + pos, 1, 1, 0, segmentBar.color, 0.25);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer, undefined, undefined, undefined, undefined, item.finish);
			}
			if (segmentBar.damage == 0 or segmentBar.damageTimer > 0 or barLevel.timer < 130){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 708, -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				var offset = 10*(3 - segmentBar.deathTimes);
				while (segmentBar.deathTimes > 0 and barLevel.timer - 130 >= offset){
					for (var i=0;i<8;i++){
						array_push(segmentBar.deathParticles,{x: 1138, y: 67, ang: 45*i, scale: 0.5, time: barLevel.timer - 130 - offset});
					}
					segmentBar.deathTimes--;
					offset = 10*(3 - segmentBar.deathTimes);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, undefined, undefined, undefined, undefined, undefined, item.finish);
			}
			surface_reset_target();
			shader_reset();
			draw_surface(segmentBar.surface, 430 + segmentBar.shake.x, 40 + segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			//--------------------------------------
			var range = max(74 - barLevel.timer/2, 0)*clamp(barLevel.timer - 150, 0, 1);
			var shakeX = irandom_range(-range, range);
			var shakeY = irandom_range(-range, range);
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 1, 1, 0, barLevel.color, 0.25);
			item = barLevel.order[barLevel.index.visual];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			pos = 447 + clamp(692*(barLevel.tempStuck - item.offset)/item.length, 0, 692) + shakeX;
			length = array_length(item.events);
			abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.tempStuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, abovePlayer, tempArray);
			}
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				var color = make_color_rgb(127.5 - 127.5*dcos(40*clamp(barLevel.timer - 170, 0, 27)), 143.5 + 111.5*dcos(40*clamp(barLevel.timer - 170, 0, 27)),183.5 + 71.5*dcos(40*clamp(barLevel.timer - 170, 0, 27)));
				draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 8, 8, 10*clamp(barLevel.timer - 170, 0, 27), color, 1);
			}else{
				draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y + shakeY, 8, 8, 0, c_cyan, 1);
			}
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x + shakeX, barLevel.shake.y + shakeY, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.tempStuck);
				}
			}
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,1 - dcos(clamp(4.5*(barLevel.timer - 150), 0, 90))]);
				var scaling = 0.2 + 0.4*dcos(clamp(4.5*(barLevel.timer - 150), 0, 90));
				draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, scaling, scaling, 0, c_pink, clamp(170 - barLevel.timer, 0, 1));
			}else{
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,clamp(barLevel.timer - 130, 0, 1)]);
				draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x + shakeX, 24 + barLevel.shake.y + shakeY, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, dcos(clamp(9*(barLevel.timer - 130), 0, 90)));
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(clamp(9*(barLevel.timer - 120), 0, 90))]);
			if (segmentBar.damage > 0){
				var color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				if (segmentBar.damageTimer == 0){
					draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (-48 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 62 - 24*dsin(1.5*min(barLevel.timer, 60)) + 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (34 + segmentBar.shake.y + shakeY)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), color, 1 - clamp(barLevel.timer - 130, 0, 1));
				}else{
					draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (pos + barLevel.shake.x - 1184 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 72 - 24*dsin(1.5*min(barLevel.timer, 60)) - 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) - (29 + barLevel.shake.y + shakeY)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), color, 1 - clamp(barLevel.timer - 130, 0, 1));
				}
			}else{
				draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (pos + barLevel.shake.x - 1184 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 72 - 24*dsin(1.5*min(barLevel.timer, 60)) - 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) - (29 + barLevel.shake.y + shakeY)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), c_white, 1 - clamp(barLevel.timer - 130, 0, 1));
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (barLevel.timer >= ((segmentBar.damage > 0 and segmentBar.damageTimer == 0) ? 200 : 160)){
				barLevel.state = levelBar.track;
				barLevel.timer = 0;
			}
		break; }
		case levelBar.sectionOut: {
			draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, 0.25);
			var item = barLevel.order[barLevel.index.visual];
			var nextItem = undefined;
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				nextItem = barLevel.order[barLevel.index.visual + 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			var pos = 447 + clamp(692*(barLevel.tempStuck - item.offset)/item.length, 0, 692);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, barLevel.tempStuck);
			}
			length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
				var ending = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
				if (ending == 692 and event.timer < 2.5){
					barLevel.lock.enabled = true;
				}else{
					barLevel.lock.enabled = false;
				}
				tempArray[0] = undefined;
				tempArray[1] = ending;
				tempArray[2] = barLevel.shake.x;
				tempArray[3] = 0;
				DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, tempArray);
			}
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				var color = make_color_rgb(127.5 - 127.5*dcos(40*clamp(barLevel.timer - 20, 0, 27)), 143.5 + 111.5*dcos(40*clamp(barLevel.timer - 20, 0, 27)),183.5 + 71.5*dcos(40*clamp(barLevel.timer - 20, 0, 27)));
				draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 10*clamp(barLevel.timer - 170, 0, 27), color, 1);
			}else{
				draw_sprite_ext(spr_pixel, 0, pos + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, 1);
			}
			var rot = 15*dsin(barLevel.anim);
			if (barLevel.lock.enabled){
				if (barLevel.lock.alpha < 1){
					if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
						if (nextItem.type.name == "boss"){
							draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}else{
							draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7 - 0.2*barLevel.lock.alpha, 0.7 - 0.2*barLevel.lock.alpha, rot, c_white, 1);
						}
					}else{
						draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,barLevel.lock.pulse]);
				draw_sprite_ext(spr_goal, 1, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, barLevel.lock.size, barLevel.lock.size, barLevel.lock.rot, barLevel.lock.color, barLevel.lock.alpha);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else{
				if (nextItem != undefined and ((!(item.type.name == "boss" or item.type.name == "boss battle") and (nextItem.type.name == "boss" or nextItem.type.name == "boss battle")) or (item.type.name == "boss" and nextItem.type.name == "boss battle")) and nextItem.type.showIconOnPrevBar){
					if (nextItem.type.name == "boss"){
						draw_sprite_ext(spr_goal, 2, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}else{
						draw_sprite_ext(spr_goal, 3, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.7, 0.7, rot, c_white, 1);
					}
				}else{
					draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, rot, c_white, 1);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				if (event.name == 45){
					var position = clamp(692*(event.start - item.offset)/item.length, -16, 692);
					tempArray[0] = undefined;
					tempArray[1] = clamp(692*(event.finish - item.offset)/item.length, -16, 692);
					tempArray[2] = barLevel.shake.x;
					tempArray[3] = 0;
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, tempArray);
				}else{
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, 1, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, undefined, undefined, undefined, undefined, barLevel.tempStuck);
				}
			}
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,1 - dcos(clamp(4.5*barLevel.timer, 0, 90))]);
				var scaling = 0.2 + 0.4*dcos(clamp(4.5*barLevel.timer, 0, 90));
				draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y, scaling, scaling, 0, c_pink, clamp(20 - barLevel.timer, 0, 1));
			}else{
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,1 - dcos(clamp(9*barLevel.timer, 0, 90))]);
				draw_sprite_ext(spr_event, 3, pos + barLevel.shake.x, 24 + barLevel.shake.y, 0.6, 0.6, 0, (segmentBar.damage > 0) ? c_pink : c_cyan, dcos(clamp(9*barLevel.timer, 0, 90)));
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (barLevel.timer >= ((segmentBar.damage > 0 and segmentBar.damageTimer == 0) ? 50 : 30)){
				barLevel.state = levelBar.track;
				barLevel.timer = 0;
			}
		break; }
		case levelBar.sectionOnlyEnd: {
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0 and !segmentBar.damaged and barLevel.timer >= 130){
				audio_play_sound(snd_dead, 0, false, 0.75, 0, 1.3);
				var length = array_length(PlayerInstances);
				for (var i=0;i<length;i++){
					PlayerInstances[i].GetHit({x: PlayerInstances[i].x + 1, y: PlayerInstances[i].y},segmentBar.damage,true,true,true,true);
					segmentBar.damaged = true;
				}
			}
			var pos = 42 - 42*dsin(4.5*clamp(barLevel.timer - 130, 0, 20));
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				pos = 42 - 42*dsin(4.5*clamp(barLevel.timer - 150, 0, 20));
			}
			var item = segmentBar.order[segmentBar.index.visual];
			var prevItem = undefined;
			if (segmentBar.index.visual > 0){
				prevItem = segmentBar.order[segmentBar.index.visual - 1];
			}
			if (!surface_exists(segmentBar.surface)){
				segmentBar.surface = surface_create(740, 54);
			}
			surface_set_target(segmentBar.surface);
			draw_clear_alpha(c_black, 0);
			draw_sprite_ext(spr_meter, 0, 370, -18 + pos, 1, 1, 0, segmentBar.color, 0.25);
			var length = array_length(item.events);
			var abovePlayer = [];
			for (var i=0;i<length;i++){
				var event = item.events[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16 /*(event.name == "warning" or event.name == "mini boss") ? -1 : 0*/, 692);
				/*if (position < 0){
					position = -16;
				}*/
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, abovePlayer, undefined, undefined, undefined, undefined, item.finish);
			}
			if (segmentBar.damage == 0 or segmentBar.damageTimer > 0 or barLevel.timer < 130){
				draw_sprite_ext(spr_playeroutside, segmentBar.player, 708, -18 + pos, 0.16, 0.16, 0, segmentBar.playerColor, 1);
			}
			if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				var offset = 10*(3 - segmentBar.deathTimes);
				while (segmentBar.deathTimes > 0 and barLevel.timer - 130 >= offset){
					for (var i=0;i<8;i++){
						array_push(segmentBar.deathParticles,{x: 1138, y: 24, ang: 45*i, scale: 0.5, time: barLevel.timer - 130 - offset});
					}
					segmentBar.deathTimes--;
					offset = 10*(3 - segmentBar.deathTimes);
				}
			}
			length = array_length(abovePlayer);
			for (var i=0;i<length;i++){
				var event = abovePlayer[i];
				var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
				DrawProgressBarEvents(event, 1, position - 430, -42 + pos, item, segmentBar, undefined, undefined, undefined, undefined, undefined, item.finish);
			}
			surface_reset_target();
			shader_reset();
			draw_surface(segmentBar.surface, 430 + segmentBar.shake.x, segmentBar.shake.y);
			shader_set(shd_preMulAlp);
			//---------------------------------------------------
			var item = barLevel.order[barLevel.index.visual];
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(clamp(9*(barLevel.timer - 120), 0, 90))]);
			if (segmentBar.damage > 0){
				var color = make_color_rgb(255, 122 + 133*dsin(clamp(2*segmentBar.damageTimer, 0, 90)), 202 + 53*dsin(clamp(2*segmentBar.damageTimer, 0, 90)));
				if (segmentBar.damageTimer == 0){
					draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (-48 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 19 - 24*dsin(1.5*min(barLevel.timer, 60)) + 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (34 + segmentBar.shake.y)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), color, 1 - clamp(barLevel.timer - 130, 0, 1));
				}else{
					draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (-184 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 29 - 24*dsin(1.5*min(barLevel.timer, 60)) - 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) - 29*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), color, 1 - clamp(barLevel.timer - 130, 0, 1));
				}
			}else{
				draw_sprite_ext(spr_goal, 0, 1169 + segmentBar.shake.x - 15*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) + (-184 - segmentBar.shake.x)*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 29 - 24*dsin(1.5*min(barLevel.timer, 60)) - 5*dcos(clamp(9*(barLevel.timer - 90), 0, 180)) - 29*(1 - dcos(clamp(4.5*(barLevel.timer - 110), 0, 90))), 0.5, 0.5, 15*dsin(segmentBar.anim)*dcos(1.5*min(barLevel.timer, 60)) + 360*dsin(1.5*min(barLevel.timer, 60))*clamp(2*(barLevel.timer - 89.5), 1, 3)*dcos(clamp(2.25*(barLevel.timer - 90), 0, 90)), c_white, 1 - clamp(barLevel.timer - 130, 0, 1));
			}
			shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			if (barLevel.timer >= ((segmentBar.damage > 0 and segmentBar.damageTimer == 0) ? 200 : 160)){
				barLevel.state = levelBar.none;
				barLevel.timer = 0;
			}
		break; }
		case levelBar.finish: {
			var item = barLevel.order[barLevel.index.visual];
			if (array_length(barLevel.order) > barLevel.index.visual + 1){
				if (item.hidden){
					item = barLevel.order[barLevel.index.visual - 1];
				}
			}else{
				item = barLevel.order[barLevel.index.visual - 1];
			}
			var prevItem = undefined;
			if (barLevel.index.visual > 0){ //THINK
				prevItem = barLevel.order[barLevel.index.visual - 1];
			}
			var length = array_length(item.musicLoop);
			for (var i=0;i<length;i++){
				var event = item.musicLoop[i];
				if (event.eject >= 0){
					event.eject += delta_time/(1000000/60);
					if (event.eject >= 30){
						event.eject = -1;
					}
				}
			}
			if (barLevel.timer <= 30){
				var counter = 30 - barLevel.timer;
				var fullAlpha = 1 - barLevel.timer/30;
				var color = make_color_rgb(color_get_red(barLevel.color)*102/255, color_get_green(barLevel.color)*102/255, color_get_blue(barLevel.color)*102/255);
				draw_sprite_ext(spr_meter, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 1, 1, 0, barLevel.color, counter/120);
				draw_sprite_ext(spr_pixel, 0, 800 + barLevel.shake.x, 24 + barLevel.shake.y, 370, 16, 0, color, barLevel.timer/60);
				length = array_length(item.events);
				var abovePlayer = [];
				for (var i=0;i<length;i++){
					var event = item.events[i];
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					/*if (position < 0){
						position = -16;
					}*/
					DrawProgressBarEvents(event, fullAlpha, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, abovePlayer, undefined, undefined, undefined, undefined, item.finish);
				}
				if (barLevel.stunned.timer == -1){
					draw_sprite_ext(spr_pixel, 0, 1139 + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, fullAlpha);
				}else{
					var step = delta_time/1000000;
					barLevel.stunned.timer += step;
					var limitmax = 120*barLevel.stunned.timer;
					if (limitmax > 3){
						var color = c_cyan;
						if (barLevel.stunned.damage){
							color = make_color_rgb(127.5 - 127.5*dcos(360/0.15*barLevel.stunned.timer), 143.5 + 111.5*dcos(360/0.15*barLevel.stunned.timer),183.5 + 71.5*dcos(360/0.15*barLevel.stunned.timer));
						}
						var original = 692;
						var sostenido = 692*(barLevel.stunned.start - item.offset - barLevel.stunned.backoff*(limitmax - 3)/141);
						draw_sprite_ext(spr_pixel, 0, 447 + barLevel.shake.x + clamp(max(original, sostenido)/item.length, 0, 692), 24 + barLevel.shake.y, 8, 8, 90/0.15*barLevel.stunned.timer, color, fullAlpha);
						if ((limitmax >= 144 or (barLevel.stunned.timer%0.15 >= 0 and barLevel.stunned.timer%0.15 < step)) and original >= sostenido){
							barLevel.stunned.timer = -1;
						}
					}else{
						draw_sprite_ext(spr_pixel, 0, 1139 + barLevel.shake.x, 24 + barLevel.shake.y, 8, 8, 0, c_cyan, fullAlpha);
					}
				}
				draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, 15*dsin(barLevel.anim)*fullAlpha, c_white, 1);
				length = array_length(abovePlayer);
				for (var i=0;i<length;i++){
					var event = abovePlayer[i];
					var position = clamp(692*(event.time - item.offset)/item.length, -16, 692);
					DrawProgressBarEvents(event, fullAlpha, position + barLevel.shake.x, barLevel.shake.y, item, barLevel, undefined, undefined, undefined, undefined, undefined, item.finish);
				}
			}else if (barLevel.timer <= 93){
				var seno = dcos(clamp(2*(barLevel.timer - 41), 0, 90));
				var movi = 370*seno;
				var color = make_color_rgb(color_get_red(barLevel.color)*102/255, color_get_green(barLevel.color)*102/255, color_get_blue(barLevel.color)*102/255);
				draw_sprite_ext(spr_pixel, 0, 1170 + barLevel.shake.x - movi, 24 + barLevel.shake.y, movi, 16, 0, color, 0.5);
				draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, 24 + barLevel.shake.y, 0.5, 0.5, 0, c_white, 1);
			}else{
				draw_sprite_ext(spr_goal, 0, 1154 + barLevel.shake.x, -16 + barLevel.shake.y + 40*(1 - dsin(clamp(4.5*(barLevel.timer - 123), 0, 90))), 0.5, 0.5, 0, c_white, 1);
				if (barLevel.timer >= 148){
					barLevel.state = levelBar.none;
					barLevel.anim = 0;
				}
			}
		break; }
	}
	switch (barBoss.state){
		case bossBar.start: {
			
		break; }
		case bossBar.track: {
			
		break; }
		case bossBar.finish: {
			
		break; }
	}
	length = array_length(segmentBar.deathParticles);
	if (length > 0){
		var step = delta_time/(1000000/60);
		for (var i=0;i<length;i++){
			var effect = segmentBar.deathParticles[i];
			effect.time += step;
			if (effect.time >= 42.5){
				array_delete(segmentBar.deathParticles, i, 1);
				i--;
				length--;
			}else{
				var scaling = 50*effect.scale*dcos(90/30*max(effect.time - 12.5, 0))/250;
				var time = dsin(90/42.5*effect.time);
				draw_sprite_ext(spr_death,1,effect.x + 250*effect.scale*dcos(effect.ang)*time,effect.y + 250*effect.scale*dsin(effect.ang)*time,scaling,scaling,0,c_white,1);
			}
		}
	}
}
DrawSongs = function(){
	for (var i=0;i<array_length(Songs);i++){
		draw_set_color(c_white);
		if (Songs[i].scroll.song > 0){
			surface_reset_target();
			if (!surface_exists(surface[1])){
				surface[1] = surface_create(405,50);
			}
			Songs[i].scroll.timer[0]++;
			if (Songs[i].scroll.timer[0] > Songs[i].scroll.song/2 + 120){
				if (Songs[i].info.song_amount > 1 and Songs[i].scroll.artist > 0 and Songs[i].scroll.timer[2] <= Songs[i].scroll.artist/1.5 + 119){
					Songs[i].scroll.timer[0]--;
				}else{
					draw_set_alpha(abs(dcos(180/30*(Songs[i].scroll.timer[0] - (Songs[i].scroll.song/2 + 120)))));
					if (Songs[i].scroll.timer[0] >= Songs[i].scroll.song/2 + 135){
						Songs[i].scroll.timer[0] = -15;
						if (Songs[i].info.song_amount > 1){
							Songs[i].scroll.timer[2] = -15;
							Songs[i].song_index = (Songs[i].song_index + 1) % Songs[i].info.song_amount;
							Songs[i].scroll.artist = 0.2*string_width(((Songs[i].info.song_type[Songs[i].song_index] != "") ? Songs[i].info.song_type[Songs[i].song_index] + " by " : "by ") + Songs[i].info.artist[Songs[i].song_index][0]) - 405;
							Songs[i].scroll.song = 0.3*string_width(Songs[i].info.song[Songs[i].song_index]) - 405;
						}
					}
				}
			}else{ if (Songs[i].scroll.timer[0] <= 0){
				draw_set_alpha(-dcos(180/30*(Songs[i].scroll.timer[0] + 30)));
			}}
			surface_set_target(surface[1]);
			draw_clear_alpha(c_black, 0);
			draw_text_transformed(-2*clamp(Songs[i].scroll.timer[0] - 60, 0, Songs[i].scroll.song/2), 1, Songs[i].info.song[Songs[i].song_index], 0.3, 0.3, 0);
			surface_reset_target();
			draw_set_alpha(1);
			surface_set_target(surface[0]);
			draw_surface(surface[1], Songs[i].x + 20, Songs[i].y);
		}else{
			if (Songs[i].info.song_amount > 1){
				Songs[i].scroll.timer[0]++;
				if (Songs[i].scroll.timer[0] > 120){
					if (Songs[i].info.song_amount > 1 and Songs[i].scroll.artist > 0 and Songs[i].scroll.timer[2] <= Songs[i].scroll.artist/1.5 + 119){
						Songs[i].scroll.timer[0]--;
					}else{
						draw_set_alpha(abs(dcos(180/30*(Songs[i].scroll.timer[0] - 120))));
						if (Songs[i].scroll.timer[0] >= 135){
							Songs[i].scroll.timer[0] = -15;
							if (Songs[i].info.song_amount > 1){
								Songs[i].scroll.timer[2] = -15;
								Songs[i].song_index = (Songs[i].song_index + 1) % Songs[i].info.song_amount;
								Songs[i].scroll.artist = 0.2*string_width(((!is_undefined(Songs[i].info.song_type) and Songs[i].info.song_type[Songs[i].song_index] != "") ? Songs[i].info.song_type[Songs[i].song_index] + " by " : "by ") + Songs[i].info.artist[Songs[i].song_index][0]) - 405;
								Songs[i].scroll.song = 0.3*string_width(Songs[i].info.song[Songs[i].song_index]) - 405;
							}
						}
					}
				}else{ if (Songs[i].scroll.timer[0] <= 0){
					draw_set_alpha(-dcos(180/30*(Songs[i].scroll.timer[0] + 30)));
				}}
			}
			draw_text_transformed(Songs[i].x + 20, Songs[i].y + 1, Songs[i].info.song[Songs[i].song_index], 0.3, 0.3, 0);
			draw_set_alpha(1);
		}
		if (Songs[i].scroll.creator > 0){
			surface_reset_target();
			if (!surface_exists(surface[2])){
				surface[2] = surface_create(280,50);
			}
			Songs[i].scroll.timer[1]++;
			if (Songs[i].scroll.timer[1] > Songs[i].scroll.creator/2 + 120){
				draw_set_alpha(abs(dcos(180/30*(Songs[i].scroll.timer[1] - (Songs[i].scroll.creator/2 + 120)))));
				if (Songs[i].scroll.timer[1] >= Songs[i].scroll.creator/2 + 135){
					Songs[i].scroll.timer[1] = -15;
				}
			}else{ if (Songs[i].scroll.timer[1] <= 0){
				draw_set_alpha(-dcos(180/30*(Songs[i].scroll.timer[1] + 30)));
			}}
			surface_set_target(surface[2]);
			draw_clear_alpha(c_black, 0);
			if (is_undefined(Songs[i].info.recreated_by)){
				draw_set_valign(fa_center);
				draw_text_transformed(-2*clamp(Songs[i].scroll.timer[1] - 60, 0, Songs[i].scroll.creator/2), 21, Songs[i].info.level_by[0], 0.3, 0.3, 0);
				draw_set_valign(fa_top);
			}else{
				draw_text_transformed(-2*clamp(Songs[i].scroll.timer[1] - 60, 0, Songs[i].scroll.creator/2), 1, Songs[i].info.level_by[0], 0.3, 0.3, 0);
			}
			surface_reset_target();
			surface_set_target(surface[0]);
			draw_set_alpha(1);
			if (is_undefined(Songs[i].info.recreated_by)){
				draw_surface(surface[2], Songs[i].x + 450, Songs[i].y + 22);
			}else{
				draw_surface(surface[2], Songs[i].x + 450, Songs[i].y);
			}
		}else{
			if (is_undefined(Songs[i].info.recreated_by)){
				draw_set_valign(fa_center);
				draw_text_transformed(Songs[i].x + 450, Songs[i].y + 43, Songs[i].info.level_by[0], 0.3, 0.3, 0);
				draw_set_valign(fa_top);
			}else{
				draw_text_transformed(Songs[i].x + 450, Songs[i].y + 1, Songs[i].info.level_by[0], 0.3, 0.3, 0);
			}
		}
		draw_set_color(make_color_rgb(0,255,255));
		if (Songs[i].scroll.artist > 0){
			surface_reset_target();
			if (!surface_exists(surface[1])){
				surface[1] = surface_create(405,50);
			}
			Songs[i].scroll.timer[2]++;
			if (Songs[i].scroll.timer[2] > Songs[i].scroll.artist/1.5 + 120){
				if (Songs[i].info.song_amount > 1 and Songs[i].scroll.timer[0] <= max(Songs[i].scroll.song/2, 0) + 121){
					Songs[i].scroll.timer[2]--;
				}else{
					draw_set_alpha(abs(dcos(180/30*(Songs[i].scroll.timer[2] - (Songs[i].scroll.artist/1.5 + 120)))));
					if (Songs[i].scroll.timer[2] >= Songs[i].scroll.artist/1.5 + 135){
						Songs[i].scroll.timer[2] = -15;
					}
				}
			}else{ if (Songs[i].scroll.timer[2] <= 0){
				draw_set_alpha(-dcos(180/30*(Songs[i].scroll.timer[2] + 30)));
			}}
			surface_set_target(surface[1]);
			draw_clear_alpha(c_black, 0);
			draw_text_transformed(-1.5*clamp(Songs[i].scroll.timer[2] - 60, 0, Songs[i].scroll.artist/1.5), -2, ((!is_undefined(Songs[i].info.song_type) and Songs[i].info.song_type[Songs[i].song_index] != "") ? Songs[i].info.song_type[Songs[i].song_index] + " by " : "by ") + Songs[i].info.artist[Songs[i].song_index][0], 0.2, 0.2, 0);
			surface_reset_target();
			draw_set_alpha(1);
			surface_set_target(surface[0]);
			draw_surface(surface[1], Songs[i].x + 20, Songs[i].y + 50);
		}else{
			if (Songs[i].info.song_amount > 1){
				Songs[i].scroll.timer[2]++;
				if (Songs[i].scroll.timer[2] > 120){
					if (Songs[i].info.song_amount > 1 and Songs[i].scroll.song > 0 and Songs[i].scroll.timer[0] <= Songs[i].scroll.song/2 + 121){
						Songs[i].scroll.timer[2]--;
					}else{
						draw_set_alpha(abs(dcos(180/30*(Songs[i].scroll.timer[2] - 120))));
					}
				}else{ if (Songs[i].scroll.timer[2] <= 0){
					draw_set_alpha(-dcos(180/30*(Songs[i].scroll.timer[2] + 30)));
				}}
			}
			draw_text_transformed(Songs[i].x + 20, Songs[i].y + 48, ((!is_undefined(Songs[i].info.song_type) and Songs[i].info.song_type[Songs[i].song_index] != "") ? Songs[i].info.song_type[Songs[i].song_index] + " by " : "by ") + Songs[i].info.artist[Songs[i].song_index][0], 0.2, 0.2, 0);
			draw_set_alpha(1);
		}
		if (!is_undefined(Songs[i].info.recreated_by)){
			if (Songs[i].scroll.based > 0){
				surface_reset_target();
				if (!surface_exists(surface[2])){
					surface[2] = surface_create(280,50);
				}
				Songs[i].scroll.timer[3]++;
				if (Songs[i].scroll.timer[3] > Songs[i].scroll.based/1.5 + 120){
					draw_set_alpha(abs(dcos(180/30*(Songs[i].scroll.timer[3] - (Songs[i].scroll.based/1.5 + 120)))));
					if (Songs[i].scroll.timer[3] >= Songs[i].scroll.based/1.5 + 135){
						Songs[i].scroll.timer[3] = -15;
					}
				}else{ if (Songs[i].scroll.timer[3] <= 0){
					draw_set_alpha(-dcos(180/30*(Songs[i].scroll.timer[3] + 30)));
				}}
				surface_set_target(surface[2]);
				draw_clear_alpha(c_black, 0);
				draw_text_transformed(-1.5*clamp(Songs[i].scroll.timer[3] - 60, 0, Songs[i].scroll.based/1.5), -2, "recreated by " + Songs[i].info.recreated_by[0], 0.2, 0.2, 0);
				surface_reset_target();
				surface_set_target(surface[0]);
				draw_set_alpha(1);
				draw_surface(surface[2], Songs[i].x + 450, Songs[i].y + 50);
			}else{
				draw_text_transformed(Songs[i].x + 450, Songs[i].y + 48, "recreated by " + Songs[i].info.recreated_by[0], 0.2, 0.2, 0);
			}
		}
		draw_set_color(make_color_rgb(Songs[i].info.color_level_type.r, Songs[i].info.color_level_type.g, Songs[i].info.color_level_type.b));
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_text_transformed(Songs[i].x + 810, Songs[i].y + 43, Songs[i].info.level_type, 0.25, 0.25, 0);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_sprite_ext(spr_rank, Songs[i].info.rank, Songs[i].x + 946, Songs[i].y + 42, 0.2, 0.2, 0, c_white, 1);
	}
}
CheckControls = function(){
	if (keyboard_check_pressed(vk_anykey)){
		maincontrols = controls.keyboard;
		if (keyboard_check_pressed(ord("A")) or keyboard_check_pressed(ord("W")) or keyboard_check_pressed(ord("S")) or keyboard_check_pressed(ord("D")) or keyboard_check_pressed(vk_enter) or keyboard_check_pressed(vk_backspace)){
			zurdo = true;
			indication[0] = "Enter";
			indication[1] = "Backspace";
		}else{ if (keyboard_check_pressed(vk_left) or keyboard_check_pressed(vk_up) or keyboard_check_pressed(vk_down) or keyboard_check_pressed(vk_right) or keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_escape)){
			zurdo = false;
			indication[0] = "Space";
			indication[1] = "ESC";
		}}
	}else{ if (gamepad_button_check_pressed(0, gp_face1) or gamepad_button_check_pressed(0, gp_face2) or gamepad_button_check_pressed(0, gp_padd) or gamepad_button_check_pressed(0, gp_padu) or gamepad_button_check_pressed(0, gp_padl) or gamepad_button_check_pressed(0, gp_padr) or gamepad_axis_value(0, gp_axislv) != 0 or gamepad_axis_value(0, gp_axislh) != 0){
		maincontrols = controls.gamepad;
		zurdo = false;
		indication[0] = "      ";
		indication[1] = "      ";
	}else{ if (gamepad_button_check_pressed(0, gp_shoulderl) or gamepad_button_check_pressed(0, gp_shoulderlb) or gamepad_axis_value(0, gp_axisrv) != 0 or gamepad_axis_value(0, gp_axisrh) != 0) {
		maincontrols = controls.gamepad;
		zurdo = true;
		indication[0] = "      ";
		indication[1] = "      ";
	}else{ if (gamepad_button_check_pressed(4, gp_face1) or gamepad_button_check_pressed(4, gp_face2) or gamepad_button_check_pressed(4, gp_padd) or gamepad_button_check_pressed(4, gp_padu) or gamepad_button_check_pressed(4, gp_padl) or gamepad_button_check_pressed(4, gp_padr) or gamepad_axis_value(4, gp_axislv) != 0 or gamepad_axis_value(4, gp_axislh) != 0){
		maincontrols = controls.generic;
		zurdo = false;
		indication[0] = "      ";
		indication[1] = "      ";
	}else{ if (gamepad_button_check_pressed(4, gp_shoulderl) or gamepad_button_check_pressed(4, gp_shoulderlb) or gamepad_axis_value(4, gp_axisrv) != 0 or gamepad_axis_value(4, gp_axisrh) != 0) {
		maincontrols = controls.generic;
		zurdo = true;
		indication[0] = "      ";
		indication[1] = "      ";
	}}}}}
}
