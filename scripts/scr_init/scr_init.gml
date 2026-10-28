randomize();
catspeak_force_init();
//application_surface_draw_enable(false);
os_powersave_enable(false);
gpu_set_ztestenable(true);
gpu_set_texfilter(true);
gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
display_set_gui_size(1600, 900);
shader_set(shd_preMulAlp);
shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);

draw_light_define_direction(1, .25, -1, .5, c_dkgray);
draw_light_define_direction(2, -.25, 1, -.5, c_black);
draw_light_enable(1, true);
draw_light_enable(2, true);

globalvar SongTime, Models, Volume, Resolutions, Photosensitive, Levels, Sprites, Sounds, Music, Mode, MaxHP, Scroll, Camera, Players, PlayerInstances, Dead_Players, Player_icons;
Volume = {music: 1, sounds: 1};
Resolutions = [{x: 800, y: 450}, {x: 852, y: 480}, {x: 1200, y: 675}, {x: 1280, y: 720}, {x: 1366, y: 768}, {x: 1600, y: 900}];
Photosensitive = false;
Mode = mode.helicopter;
Dead_Players = false;
MaxHP = 1;
Scroll = {x: 0, y: 0, range: 0, time: 0, offset: 0, angle: 0, angle_time: 0, angle_speed: 0};
Players = 1; //0
PlayerInstances = [];
SongTime = 0;
Player_icons = [];
Levels = [];
Camera = {x: 0, y: 0};
Sprites = {};
Models = {};
Sounds = {};
Music = {};
#region Constants
#macro c_cyan 16776960
#macro c_pink 7348479
#macro c_green2 #2EFF23
enum mode{
	shape,
	helicopter,
	boat,
	big_cube,
	none
}
enum level{
	error,
	waiting,
	ready,
	update,
	rewind,
	ranking,
	finish
}
enum config{
	waiting,
	coloring,
	players,
	playersOut,
	done
}
enum feel{
	normal,
	fear,
	happy,
	sad,
	worried
}
enum menu{
	waiting,
	warnings,
	intro,
	title,
	credits,
	creditsOut,
	options,
	optionsOut,
	quit,
	quitOut,
	nolevels,
	nolevelsOut,
	levels,
	levelsOut,
	settings,
	settingsOut,
	players,
	playersOut,
	done,
	returning
}
enum controls{
	keyboard,
	gamepad,
	generic
}
enum action{
	horizontal,
	vertical,
	confirm,
	cancel
}
enum levelBar{
	start,
	track,
	extending,
	replacing,
	sectionStart,
	sectionStartHidden,
	sectionOnlyStart,
	section,
	sectionOnly,
	sectionSuspend,
	sectionOnlySuspend,
	sectionWaiting,
	sectionResume,
	sectionReplacing,
	sectionOnlyReplacing,
	sectionExtending,
	sectionOnlyExtending,
	sectionEnd,
	sectionOnlyEnd,
	sectionOut,
	finish,
	none
}
enum bossBar{
	start,
	track,
	finish,
	none
}
enum goalType{
	normal,
	boss,
	bossFight,
	death
}
#endregion
#region Save and Load functions
function LoadSprites(path){
	if (directory_exists("Levels/" + path + "/Sprites")){
		var dir = "";
		var specil_sprites = [];
		var found = file_exists("Levels/" + path + "/Sprites/sprites.json");
		if (found){
			var file = file_text_open_read("Levels/" + path + "/Sprites/sprites.json");
			var info = "";
			while (!file_text_eof(file)){
				info += file_text_read_string(file);
				file_text_readln(file);
			}
			file_text_close(file);
			info = json_parse(info);
			var names = variable_struct_get_names(info);
			var length = array_length(names);
			for (var i=0;i<length;i++){
				dir = "Levels/" + path + "/Sprites/" + names[i];
				if (file_exists(dir)){
					var data = variable_struct_get(info, names[i]);
					if (!variable_struct_exists(data, "images")){
						data.images = 1;
					}
					if (!variable_struct_exists(data, "loops")){
						data.loops = true;
					}
					if (!variable_struct_exists(data, "animation_speed")){
						data.animation_speed = 1;
					}
					if (!variable_struct_exists(data, "animation_times")){
						data.animation_times = 10;
					}
					Sprites[$ names[i]] = {sprite: -1};
					if (string_last_pos(".gif", names[i]) == string_length(names[i]) - 3){
						Sprites[$ names[i]].animation_times = [];
						Sprites[$ names[i]].animation_speed = max(data.animation_speed, 0);
						Sprites[$ names[i]].loops = data.loops;
						Sprites[$ names[i]].sprite = sprite_add_gif(dir, 0, 0, Sprites[$ names[i]].animation_times);
						Sprites[$ names[i]].images = array_length(Sprites[$ names[i]].animation_times);
					}else{
						if (data.animation_times){
							Sprites[$ names[i]].animation_times = data.animation_times;
							Sprites[$ names[i]].animation_speed = max(data.animation_speed, 0);
							Sprites[$ names[i]].loops = data.loops;
						}
						Sprites[$ names[i]].images = max(data.images, 1);
						Sprites[$ names[i]].sprite = sprite_add(dir, Sprites[$ names[i]].images, false, false, 0, 0);
					}
					sprite_set_offset(Sprites[$ names[i]].sprite, sprite_get_width(Sprites[$ names[i]].sprite)/2, sprite_get_height(Sprites[$ names[i]].sprite)/2);
					sprite_collision_mask(Sprites[$ names[i]].sprite, true, 1, 0, 0, 0, 0, 0, 100);
					array_push(specil_sprites, names[i]);
				}
			}
		}
		dir = file_find_first("Levels/" + path + "/Sprites/*.png", 0);
		var func = function(elem,index){return (elem == dir)};
		while (dir != ""){
			if (array_find_index(specil_sprites,func) < 0){
				Sprites[$ dir] = {sprite: sprite_add("Levels/" + path + "/Sprites/" + dir, 1, false, false, 0, 0), animated: false, animation_speed: 1};
				sprite_set_offset(Sprites[$ dir].sprite, sprite_get_width(Sprites[$ dir].sprite)/2, sprite_get_height(Sprites[$ dir].sprite)/2);
				sprite_collision_mask(Sprites[$ dir].sprite, true, 1, 0, 0, 0, 0, 0, 100);
			}
			dir = file_find_next();
		}
		file_find_close();
		dir = file_find_first("Levels/" + path + "/Sprites/*.gif", 0);
		var func = function(elem,index){return (elem == dir)};
		while (dir != ""){
			if (array_find_index(specil_sprites,func) < 0){
				Sprites[$ dir] = {sprite: -1, loops: true, animation_speed: 1, animation_times: []};
				Sprites[$ dir].sprite = sprite_add_gif("Levels/" + path + "/Sprites/" + dir, 0, 0, Sprites[$ dir].animation_times);
				Sprites[$ dir].images = array_length(Sprites[$ dir].animation_times);
				sprite_set_offset(Sprites[$ dir].sprite, sprite_get_width(Sprites[$ dir].sprite)/2, sprite_get_height(Sprites[$ dir].sprite)/2);
				sprite_collision_mask(Sprites[$ dir].sprite, true, 1, 0, 0, 0, 0, 0, 100);
			}
			dir = file_find_next();
		}
		file_find_close();
	}
}
function Load3DModels(path){
	if (directory_exists("Levels/" + path + "/Models")){
		var dir = file_find_first("Levels/" + path + "/Models/*.obj", 0);
		while (dir != ""){
			Models[$ dir] = DotobjModelLoadFromFileAsync("Levels/" + path + "/Models/" + dir);
			dir = file_find_next();
		}
		file_find_close();
	}
}
function areModelsLoaded(){
	var names = struct_get_names(Models)
	var length = array_length(names)
	if (names == 0){
		return true	
	}
	for (var i = 0; i < length; i++){
		if (!Models[$ names[i]].loaded){
			return false
		}
	}
	for (var i = 0; i < length; i++){
		Models[$ names[i]].Freeze();
	}
	return true
}
function LoadMusic(path){
	var dir = file_find_first("Levels/" + path + "/Music/*.ogg", 0);
	while (dir != ""){
		var pos = string_last_pos(".",dir);
		var name = string_delete(dir,pos,string_length(dir) - pos + 1);
		var location = "Levels/" + path + "/Music/" + dir;
		var waveform = sound_audio_load(location);
		//Later add a way to wait for the async to finish
		var audio = audio_create_stream(location);
		Music[$ name] = [audio, waveform];
		dir = file_find_next();
	}
	file_find_close();
}
function LoadSounds(path){
	if (directory_exists("Levels/" + path + "/Sounds")){
		var dir = file_find_first("Levels/" + path + "/Sounds/*.ogg", 0);
		while (dir != ""){
			Sounds[$ dir] = audio_create_stream("Levels/" + path + "/Sounds/" + dir);
			dir = file_find_next();
		}
		file_find_close();
	}
}
function LoadScript(path){
	var file = file_text_open_read("Levels/" + path + "/script.jsabf");
	var str = "";
	while (!file_text_eof(file)){
		str += file_text_read_string(file) + "\n";
		file_text_readln(file);
	}
	file_text_close(file);
	try{
		obj_game.compilation = Catspeak.compileGML(Catspeak.parseString(str));
		obj_game.state = level.ready;
	}catch (e){
		show_message(e.message);
		obj_game.state = level.error;
	}
}
function LoadPlayerIcons(){
	for (var i=0;i<array_length(Player_icons);i++){
		sprite_delete(Player_icons[i].sprite);
	}
	array_delete(Player_icons, 0, array_length(Player_icons));
	if (directory_exists("Custom Shapes")){
		var dir = file_find_first("Custom Shapes/*.json", 0);
		while (dir != ""){
			var data = {};
			var str = "";
			var file = file_text_open_read("Custom Shapes/" + dir);
			while (!file_text_eof(file)){
				str += file_text_read_string(file);
				file_text_readln(file);
			}
			file_text_close(file);
			str = json_parse(str);
			data.spr_mask = str.hasMask;
			data.spr_inside = str.hasDotted;
			if (variable_struct_exists(str, "offsetHeliHands")){
				data.shaperange = 36 + str.offsetHeliHands;
			}else{
				data.shaperange = 36;
			}
			if (variable_struct_exists(str, "rotationOffsetHeli")){
				data.playerrot = str.rotationOffsetHeli;
			}else{
				data.playerrot = 0;
			}
			data.icon_name = str.sprite;
			data.sprite = sprite_add("Custom Shapes/" + str.sprite, 1 + ((str.hasMask and str.hasDotted) ? 2 : ((str.hasDotted or str.hasMask) ? 1 : 0)), false, false, 50, 50);
			if (sprite_exists(data.sprite)){
				sprite_collision_mask(data.sprite, false, 0, 25, 25, 74, 74, bboxkind_rectangular, 0);
				array_push(Player_icons, data);
			}
			dir = file_find_next();
		}
		file_find_close();
	}
}
function LoadLevels(){
	array_delete(Levels, 0, array_length(Levels));
	if (directory_exists("Levels")){
		var dir = file_find_first("Levels/*", fa_directory);
		var info = {};
		if (file_exists("Ranks.json")){
			var file = file_text_open_read("Ranks.json");
			while (!file_text_eof(file)){
				info += file_text_read_string(file);
				file_text_readln(file);
			}
			file_text_close(file);
			info = json_parse(info);
		}
		while (dir != ""){
			if (file_exists("Levels/" + dir + "/script.jsabf")){
				var data = {preview: (file_exists("Levels/" + dir + "/preview.png")) ? dir : undefined};
				if (file_exists("Levels/" + dir + "/details.json")){
					var file = file_text_open_read("Levels/" + dir + "/details.json");
					var str = "";
					while (!file_text_eof(file)){
						str += file_text_read_string(file);
						file_text_readln(file);
					}
					file_text_close(file);
					str = json_parse(str);
					data.song = str.song;
					data.artist = str.artist;
					if (variable_struct_exists(str, "from")){
						data.from = str.from;
					}else{
						data.from = undefined;
					}
					if (variable_struct_exists(str, "bg_slot") and file_exists("Levels/" + dir + "/" + str.bg_slot)){
						if (string_last_pos(".gif", str.bg_slot) == string_length(str.bg_slot) - 3){
							var _times = [];
							data.bg_slot = [sprite_add_gif("Levels/" + dir + "/" + str.bg_slot, 0, 0, _times), _times];
						}else{
							data.bg_slot = [sprite_add("Levels/" + dir + "/" + str.bg_slot, 1, false, false, 0, 0), 1];
						}
					}else{
						data.bg_slot = undefined;
					}
					if (variable_struct_exists(str, "song_type")){
						data.song_type = str.song_type;
					}else{
						data.song_type = undefined;
					}
					data.level_by = str.level_by;
					if (variable_struct_exists(str, "recreated_by")){
						data.recreated_by = str.recreated_by;
					}else{
						data.recreated_by = undefined;
					}
					data.song_amount = array_length(data.song);
					data.level_type = str.level_type;
					data.color_level_type = str.color_level_type;
					data.difficulty = str.difficulty;
					data.play_as = str.play_as;
					data.hp = str.hp;
					data.version = str.version;
					var rankTitle = "";
					var length = array_length(data.song);
					for (var i=0;i<length;i++){
						rankTitle += data.song[i] + data.artist[i][0];
					}
					var recreatedby = data.recreated_by;
					if (is_undefined(recreatedby)){
						recreatedby = "";
					}else{
						recreatedby = recreatedby[0];
					}
					rankTitle += data.level_by[0] + recreatedby;
					if (variable_struct_exists(info, rankTitle)){
						data.rank = variable_struct_get(info, rankTitle);
					}else{
						data.rank = 0;
					}
					data.dir = dir;
				}else{
					data.song = ["Details missing"];
					data.artist = [["Details missing"]];
					data.from = undefined;
					data.song_type = undefined;
					data.song_amount = 0;
					data.level_by = ["Details missing"];
					data.recreated_by = undefined;
					data.level_type = "Details\nmissing";
					data.color_level_type = {r: 127, g: 127, b: 127};
					data.difficulty = 0;
					data.play_as = "Missing";
					data.version = "0.0.0";
					data.hp = 1;
					data.rank = 0;
					data.dir = dir;
				}
				array_push(Levels, data);
			}
			dir = file_find_next();
		}
		file_find_close();
	}
	if (array_length(Levels) > 0){
		return true;
	}else{
		return false;
	}
}
function LoadSettings(){
	if (!file_exists("Settings.json")){
		var struct = {Music: 1, Sound: 1, Fullscreen: false, Resolution: 1, mode: 0, Photosensitive: false};
		var file = file_text_open_write("Settings.json");
		file_text_write_string(file, json_stringify(struct));
		file_text_close(file);
	}
	var file = file_text_open_read("Settings.json");
	var data = "";
	while (!file_text_eof(file)){
		data += file_text_read_string(file);
		file_text_readln(file);
	}
	file_text_close(file);
	data = json_parse(data);
	Volume.music = data.Music;
	Volume.sounds = data.Sound;
	window_set_fullscreen(data.Fullscreen);
	Photosensitive = data.Photosensitive;
	var res = data.Resolution;
	audio_group_set_gain(music_group, Volume.music, 0);
	audio_group_set_gain(sound_group, Volume.sounds, 0);
	mode = data.mode;
	window_set_size(Resolutions[res].x, Resolutions[res].y);
	surface_resize(application_surface, Resolutions[res].x, Resolutions[res].y);
	return res;
}
function SaveSettings(res){
	var struct = {Music: Volume.music, Sound: Volume.sounds, Fullscreen: window_get_fullscreen(), mode: mode, Resolution: res, Photosensitive: Photosensitive};
	var file = file_text_open_write("Settings.json");
	file_text_write_string(file, json_stringify(struct));
	file_text_close(file);
}
function SavePlayerConfig(instances){
	var array = [];
	for (var i=0;i<4;i++){
		array_push(array, {index: instances[i].index, hue: instances[i].hue, saturation: instances[i].saturation, value: instances[i].value});
	}
	var file = file_text_open_write("PlayerConfig.json");
	file_text_write_string(file, json_stringify(array));
	file_text_close(file);
	for (var i=0;i<4;i++){
		array[i].control_type = instances[i].control_type;
		array[i].control_id = instances[i].control_id;
		array[i].zurdo = instances[i].zurdo;
	}
	return array;
}
function LoadPlayerConfig(){
	if (!file_exists("PlayerConfig.json")){
		var array = [{index: 0, hue: 127, saturation: 255, value: 255}, {index: 1, hue: 42, saturation: 255, value: 255}, {index: 2, hue: 85, saturation: 255, value: 255}, {index: 3, hue: 21, saturation: 255, value: 255}];
		var file = file_text_open_write("PlayerConfig.json");
		file_text_write_string(file, json_stringify(array));
		file_text_close(file);
	}
	var file = file_text_open_read("PlayerConfig.json");
	var data = "";
	while (!file_text_eof(file)){
		data += file_text_read_string(file);
		file_text_readln(file);
	}
	file_text_close(file);
	data = json_parse(data);
	for (var i=0;i<4;i++){
		if (data[i].index - 3 > array_length(Player_icons)){
			data[i].index = array_length(Player_icons) + 3;
		}
	}
	return data;
}
#endregion
function DrawProgressBarEvents(event, fullAlpha, positionX, positionY, item, bar, array = undefined, item2 = undefined, timediff = undefined, offset = undefined, offset2 = undefined, stuck = -1){
	timeSong = SongTime*max(-stuck, 0) + max(stuck, 0);
	switch (event.name){
		case "checkpoint": {
			var color = c_cyan;
			if (event.damage > 0){
				color = c_pink;
			}else if (event.damage < 0){
				color = c_green2;
			}
			if (event.special){
				if (bar == segmentBar){
					draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, color, fullAlpha*(positionX + ((barLevel.state == levelBar.sectionReplacing or barLevel.state == levelBar.sectionExtending) ? 430 : 0) < 692));
				}else{
					draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, color, fullAlpha*(positionX + ((barLevel.state == levelBar.replacing or barLevel.state == levelBar.extending) ? 430 : 0) < 692));
				}
			}else{
				draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, color, fullAlpha);
			}
		break; }
		case "warning": {
			if (!event.updated){
				event.updated = true;
				var step = delta_time/1000000;
				if (timeSong < event.time){
					if (event.anim == 0.75){
						event.anim = 0;
					}else if (event.anim > 0.5){
						event.anim = min(event.anim + step, 0.75);
					}else{
						event.anim = max(event.anim - step, 0);
					}
				}else if (timeSong < event.finish){
					if (event.anim <= 0.5){
						if (!event.checkpoint or !event.waitTriggered or event.triggered){
							event.anim = min(event.anim + step, 0.5);
						}else{
							event.anim = 0;
						}
					}else{
						event.anim = max(event.anim - step, 0.5);
					}
				}else if (timeSong >= event.finish){
					if (event.anim == 0){
						event.anim = 0.75;
					}else{
						event.anim = clamp(event.anim + step, 0.5, 0.75);
					}
				}
			}
			if (event.anim == 0){
				if (!event.hidden){
					if (event.checkpoint and event.damage != 0){
						if (event.damage > 0){
							draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_pink, fullAlpha);
						}else{
							draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_green2, fullAlpha);
						}
					}else{
						switch (event.behavior){
							case "threat":
								draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_pink, fullAlpha);
							break;
							case "recovery":
								draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_green2, fullAlpha);
							break;
							default: //"danger", "bonus"
								draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_cyan, fullAlpha);
							break;
						}
					}
				}else{ if (event.checkpoint){
					if (event.damage > 0){
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_pink, fullAlpha);
					}else if (damage == 0){
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_cyan, fullAlpha);
					}else{
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_green2, fullAlpha);
					}
				}}
			}else if (event.anim <= 0.5){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				var curR, curG, curB, color, diff, time, rot, width = 0;
				time = event.anim;
				switch (event.behavior){
					case "bonus": case "recovery":
						curR = 46;
						curG = 255;
						curB = 35;
					break;
					default: //"danger","threat"
						curR = 255;
						curG = 32;
						curB = 112;
					break;
				}
				event.timer++;
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					color = make_color_rgb(curR, curG, curB);
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, color, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					gpu_set_colorwriteenable(true, true, true, true);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					color = make_color_rgb(curR, curG, curB);
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				rot = 20*dsin(135*event.timer/60);
				if (event.hidden){
					diff = 1 - 0.5*dcos(90/0.25*min(time, 0.25));
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						color = make_color_rgb(curR, curG, curB);
						draw_set_alpha((time < 0.5) ? 0.25 - 0.25*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : 0.25);
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha));
						}else{
							surface_free(event.surface2);
						}
					}
					if (event.checkpoint){
						var checkcolor;
						if (event.damage > 0){
							checkcolor = c_pink;
						}else if (event.damage == 0){
							checkcolor = c_cyan;
						}else{
							checkcolor = c_green2;
						}
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, checkcolor, fullAlpha*2*(1 - diff));
					}
					if (time < 0.5){
						var coseno = dcos(90/0.25*clamp(time - 0.25, 0, 0.25));
						if (event.colorProgressBar and time >= 0.25 and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
						curR = curR - 255;
						curG = curG - 255;
						curB = curB - 255;
						color = make_color_rgb(255 + curR - curR*coseno, 255 + curG - curG*coseno, 255 + curB - curB*coseno);
					}else{
						color = make_color_rgb(curR, curG, curB);
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = color;
						}
					}
					var diff2 = diff - 0.4*(diff - 0.5);
					draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, diff2, diff2, rot*2*(diff - 0.5), color, fullAlpha*2*(diff - 0.5));
				}else{
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						color = make_color_rgb(curR, curG, curB);
						draw_set_alpha((time < 0.25) ? 0.25 - 0.25*dcos(90/0.25*time) : 0.25);
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha));
						}else{
							surface_free(event.surface2);
						}
					}
					if (time < 0.25){
						var prevR, prevG, prevB, coseno;
						if (event.checkpoint and event.damage != 0){
							if (event.damage > 0){
								prevR = 255;
								prevG = 32;
								prevB = 112;
							}else{
								prevR = 46;
								prevG = 255;
								prevB = 35;
							}
						}else{
							switch (event.behavior){
								case "threat":
									prevR = 255;
									prevG = 32;
									prevB = 112;
								break;
								case "recovery":
									prevR = 46;
									prevG = 255;
									prevB = 35;
								break;
								default: //"bonus","danger"
									prevR = 0;
									prevG = 255;
									prevB = 255;
								break;
							}
						}
						coseno = dcos(90/0.25*time);
						if (event.colorProgressBar and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
						curR = curR - prevR;
						curG = curG - prevG;
						curB = curB - prevB;
						diff = 0.8 - 0.3*coseno;
						color = make_color_rgb(prevR + curR - curR*coseno, prevG + curG - curG*coseno, prevB + curB - curB*coseno);
					}else{
						diff = 0.8;
						color = make_color_rgb(curR, curG, curB);
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = color;
						}
					}
					draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, diff, diff, rot*(diff - 0.5)/0.3, color, fullAlpha);
				}
			}else if (event.anim < 0.75){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				if (event.colorProgressBar){
					if (!bar.color4){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
						bar.color4 = true;
					}else if (bar.color3.r == -1){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
					}
				}
				var color, diff2, prevR, prevG, prevB, curR, curG, curB, width = 0;
				event.timer++;
				rot = 20*dsin(135*event.timer/60);
				switch (event.behavior){
					case "bonus": case "recovery":
						prevR = 46;
						prevG = 255;
						prevB = 35;
					break;
					default: //"danger","threat"
						prevR = 255;
						prevG = 32;
						prevB = 112;
					break;
				}
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					color = make_color_rgb(prevR, prevG, prevB);
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, color, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_colorwriteenable(true, true, true, true);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					color = make_color_rgb(prevR, prevG, prevB);
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				if (event.checkpoint and event.damage != 0){
					if (event.damage > 0){
						curR = 255;
						curG = 32;
						curB = 112;
					}else{
						curR = 46;
						curG = 255;
						curB = 35;
					}
				}else{
					switch (event.behavior){
						case "threat":
							curR = 255;
							curG = 32;
							curB = 112;
						break;
						case "recovery":
							curR = 46;
							curG = 255;
							curB = 35;
						break;
						default: //"bonus","danger"
							curR = 0;
							curG = 255;
							curB = 255;
						break;
					}
				}
				coseno = dcos(90*(event.anim - 0.5)/0.25);
				if (bar.color4){
					bar.color = make_color_rgb(prevR + (bar.color3.r - prevR)*(1 - coseno), prevG + (bar.color3.g - prevG)*(1 - coseno), prevB + (bar.color3.b - prevB)*(1 - coseno));
				}
				diff2 = 0.5 + 0.3*coseno;
				if (surface_exists(event.surface1)){
					if (string_pos("particles", event.visualType)){
						draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff2 - 0.5)/0.3);
					}else{
						surface_free(event.surface1);
					}
				}
				if (string_pos("filled", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					color = make_color_rgb(curR, curG, curB);
					draw_set_alpha(0.25*fullAlpha*(diff2 - 0.5)/0.3);
					draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
					draw_set_alpha(1);
				}
				if (surface_exists(event.surface2)){
					if (string_pos("marked", event.visualType)){
						draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff2 - 0.5)/0.3);
					}else{
						surface_free(event.surface2);
					}
				}
				curR = curR - prevR;
				curG = curG - prevG;
				curB = curB - prevB;
				color = make_color_rgb(prevR + curR*(1 - coseno), prevG + curG*(1 - coseno), prevB + curB*(1 - coseno));
				if (event.time > item.offset){
					draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, diff2, diff2, rot/0.3*(diff2 - 0.5), color, fullAlpha);
				}else{
					draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, diff2, diff2, rot/0.3*(diff2 - 0.5), color, fullAlpha*(diff2 - 0.5)/0.3);
				}
			}else if (event.anim == 0.75){
				if (event.time > item.offset){
					if (bar.color4){
						bar.color = make_color_rgb(bar.color3.r, bar.color3.g, bar.color3.b);
						bar.color2.r = -1;
						bar.color2.g = -1;
						bar.color2.b = -1;
						bar.color3.r = -1;
						bar.color3.g = -1;
						bar.color3.b = -1;
						bar.color4 = false;
					}
					if (event.checkpoint and event.damage != 0){
						if (event.damage > 0){
							color = c_pink;
						}else{
							color = c_green2;
						}
					}else{
						switch (event.behavior){
							case "threat":
								color = c_pink;
							break;
							case "recovery":
								color = c_green2;
							break;
							default: //"bonus","danger"
								color = c_cyan;
							break;
						}
					}
					draw_sprite_ext(spr_event, 1, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, color, fullAlpha);
				}else if (bar.color4){
					bar.color = make_color_rgb(bar.color3.r, bar.color3.g, bar.color3.b);
					bar.color2.r = -1;
					bar.color2.g = -1;
					bar.color2.b = -1;
					bar.color3.r = -1;
					bar.color3.g = -1;
					bar.color3.b = -1;
					bar.color4 = false;
				}
			}
			if (event.anim == 0.75 or event.anim == 0){
				if (surface_exists(event.surface1)){
					surface_free(event.surface1);
				}
				if (surface_exists(event.surface2)){
					surface_free(event.surface2);
				}
			}
		break; }
		case "mini boss": {
			if (!event.updated){
				event.updated = true;
				var step = delta_time/1000000;
				if (timeSong < event.time){
					if (event.anim == 0.75){
						event.anim = 0;
					}else if (event.anim > 0.5){
						event.anim = min(event.anim + step, 0.75);
					}else{
						event.anim = max(event.anim - step, 0);
					}
				}else if (timeSong < event.finish){
					if (event.anim <= 0.5){
						if (!event.checkpoint or !event.waitTriggered or event.triggered){
							event.anim = min(event.anim + step, 0.5);
						}else{
							event.anim = 0;
						}
					}else{
						event.anim = max(event.anim - step, 0.5);
					}
				}else if (timeSong >= event.finish){
					if (event.anim == 0){
						event.anim = 0.75;
					}else{
						event.anim = clamp(event.anim + step, 0.5, 0.75);
					}
				}
			}
			if (event.anim == 0){
				if (!event.hidden){
					if (event.checkpoint){
						if (event.damage > 0){
							draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_pink, fullAlpha);
						}else if (event.damage == 0){
							draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_cyan, fullAlpha);
						}else{
							draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_green2, fullAlpha);
						}
					}else{
						switch (event.behavior){
							case "threat":
								draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_pink, fullAlpha);
							break;
							default: //"danger"
								draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_gray, fullAlpha);
							break;
						}
					}
				}else{ if (event.checkpoint){
					if (event.damage > 0){
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_pink, fullAlpha);
					}else if (event.damage == 0){
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_cyan, fullAlpha);
					}else{
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_green2, fullAlpha);
					}
				}}
			}else if (event.anim <= 0.5){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				var curR = 255, curG = 32, curB = 112, color, diff, time, rot, width = 0;
				time = event.anim;
				event.timer++;
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					color = make_color_rgb(curR, curG, curB);
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, color, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_colorwriteenable(true, true, true, true);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					color = make_color_rgb(curR, curG, curB);
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				rot = 20*dsin(135*event.timer/60);
				if (event.hidden){
					diff = 1 - 0.5*dcos(90/0.25*min(time, 0.25));
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						color = make_color_rgb(curR, curG, curB);
						draw_set_alpha((time < 0.5) ? 0.25 - 0.25*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : 0.25);
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha));
						}else{
							surface_free(event.surface2);
						}
					}
					if (event.checkpoint){
						var checkcolor;
						if (event.damage > 0){
							checkcolor = c_pink;
						}else if (event.damage == 0){
							checkcolor = c_cyan;
						}else{
							checkcolor = c_green2;
						}
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, checkcolor, fullAlpha*2*(1 - diff));
					}
					if (time < 0.5){
						var coseno = dcos(90/0.25*clamp(time - 0.25, 0, 0.25));
						if (event.colorProgressBar and time >= 0.25 and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
						curR = curR - 255;
						curG = curG - 255;
						curB = curB - 255;
						color = make_color_rgb(255 + curR - curR*coseno, 255 + curG - curG*coseno, 255 + curB - curB*coseno);
					}else{
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						color = make_color_rgb(curR, curG, curB);
						if (bar.color4){
							bar.color = color;
						}
					}
					var diff2 = diff - 0.4*(diff - 0.5);
					draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, diff2, diff2, rot*2*(diff - 0.5), color, fullAlpha*2*(diff - 0.5));
				}else{
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						color = make_color_rgb(curR, curG, curB);
						draw_set_alpha((time < 0.25) ? 0.25 - 0.25*dcos(90/0.25*time) : 0.25);
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha));
						}else{
							surface_free(event.surface2);
						}
					}
					if (time < 0.25){
						var prevR, prevG, prevB, coseno;
						if (event.checkpoint){
							if (event.damage > 0){
								prevR = 255;
								prevG = 32;
								prevB = 112;
							}else if (event.damage == 0){
								prevR = 0;
								prevG = 255;
								prevB = 255;
							}else{
								prevR = 46;
								prevG = 255;
								prevB = 35;
							}
						}else{
							switch (event.behavior){
								case "threat":
									prevR = 255;
									prevG = 32;
									prevB = 112;
								break;
								default: //"danger"
									prevR = 127;
									prevG = 127;
									prevB = 127;
								break;
							}
						}
						if (event.colorProgressBar and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						coseno = dcos(90/0.25*time);
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
						curR = curR - prevR;
						curG = curG - prevG;
						curB = curB - prevB;
						diff = 0.8 - 0.3*coseno;
						color = make_color_rgb(prevR + curR - curR*coseno, prevG + curG - curG*coseno, prevB + curB - curB*coseno);
					}else{
						diff = 0.8;
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						color = make_color_rgb(curR, curG, curB);
						if (bar.color4){
							bar.color = color;
						}
					}
					draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, diff, diff, rot*(diff - 0.5)/0.3, color, fullAlpha);
				}
			}else if (event.timer < 0.75){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				if (event.colorProgressBar){
					if (!bar.color4){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
						bar.color4 = true;
					}else if (bar.color3.r == -1){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
					}
				}
				var color, diff2, prevR = 255, prevG = 32, prevB = 112, curR, curG, curB, width = 0;
				event.timer++;
				rot = 20*dsin(135*event.timer/60);
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					color = make_color_rgb(prevR, prevG, prevB);
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, color, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_colorwriteenable(true, true, true, true);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					color = make_color_rgb(prevR, prevG, prevB);
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				if (event.checkpoint){
					if (event.damage > 0){
						curR = 255;
						curG = 32;
						curB = 112;
					}else if (event.damage == 0){
						curR = 0;
						curG = 255;
						curB = 255;
					}else{
						curR = 46;
						curG = 255;
						curB = 35;
					}
				}else{
					switch (event.behavior){
						case "threat":
							curR = 255;
							curG = 32;
							curB = 112;
						break;
						default: //"danger"
							curR = 127;
							curG = 127;
							curB = 127;
						break;
					}
				}
				coseno = dcos(90/0.25*(event.anim - 0.5));
				if (bar.color4){
					bar.color = make_color_rgb(prevR + (bar.color3.r - prevR)*(1 - coseno), prevG + (bar.color3.g - prevG)*(1 - coseno), prevB + (bar.color3.b - prevB)*(1 - coseno));
				}
				diff2 = 0.5 + 0.3*coseno;
				if (surface_exists(event.surface1)){
					if (string_pos("particles", event.visualType)){
						draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff2 - 0.5)/0.3);
					}else{
						surface_free(event.surface1);
					}
				}
				if (string_pos("filled", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					color = make_color_rgb(curR, curG, curB);
					draw_set_alpha(0.25*fullAlpha*(diff2 - 0.5)/0.3);
					draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
					draw_set_alpha(1);
				}
				if (surface_exists(event.surface2)){
					if (string_pos("marked", event.visualType)){
						draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff2 - 0.5)/0.3);
					}else{
						surface_free(event.surface2);
					}
				}
				curR = curR - prevR;
				curG = curG - prevG;
				curB = curB - prevB;
				color = make_color_rgb(prevR + curR - curR*coseno, prevG + curG - curG*coseno, prevB + curB - curB*coseno);
				if (event.time > item.offset){
					draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, diff2, diff2, rot/0.3*(diff2 - 0.5), color, fullAlpha);
				}else{
					draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, diff2, diff2, rot/0.3*(diff2 - 0.5), color, fullAlpha*(diff2 - 0.5)/0.3);
				}
			}else if (event.anim == 0.75){
				if (event.time > item.offset){
					if (bar.color4){
						bar.color = make_color_rgb(bar.color3.r, bar.color3.g, bar.color3.b);
						bar.color2.r = -1;
						bar.color2.g = -1;
						bar.color2.b = -1;
						bar.color3.r = -1;
						bar.color3.g = -1;
						bar.color3.b = -1;
						bar.color4 = false;
					}
					if (event.checkpoint){
						if (event.damage > 0){
							color = c_pink;
						}else if (event.damage == 0){
							color = c_cyan;
						}else{
							color = c_green2;
						}
					}else{
						switch (event.behavior){
							case "threat":
								color = c_pink;
							break;
							default: //"danger"
								color = c_gray;
							break;
						}
					}
					draw_sprite_ext(spr_event, 2, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, color, fullAlpha);
				}else if (bar.color4){
					bar.color = make_color_rgb(bar.color3.r, bar.color3.g, bar.color3.b);
					bar.color2.r = -1;
					bar.color2.g = -1;
					bar.color2.b = -1;
					bar.color3.r = -1;
					bar.color3.g = -1;
					bar.color3.b = -1;
					bar.color4 = false;
				}
			}
			if (event.anim == 0 or event.anim == 0.75){
				if (surface_exists(event.surface1)){
					surface_free(event.surface1);
				}
				if (surface_exists(event.surface2)){
					surface_free(event.surface2);
				}
			}
		break; }
		case "collectible": {
			if (!event.updated){
				event.updated = true;
				var step = delta_time/1000000;
				if (event.dispAnim >= 0 and event.dispAnim < 0.5){
					event.dispAnim = min(event.dispAnim + step, 0.5);
				}
				if (timeSong < event.time){
					if (event.anim == 0.75){
						event.anim = 0;
					}else if (event.anim > 0.5){
						event.anim = min(event.anim + step, 0.75);
					}else{
						event.anim = max(event.anim - step, 0);
					}
				}else if (timeSong < event.finish){
					if (event.anim <= 0.5){
						event.anim = min(event.anim + step, 0.5);
					}else{
						event.anim = max(event.anim - step, 0.5);
					}
				}else if (timeSong >= event.finish){
					if (event.anim == 0){
						event.anim = 0.75;
					}else{
						event.anim = clamp(event.anim + step, 0.5, 0.75);
					}
				}
			}
			if (event.anim == 0){
				if (!event.hidden){
					if (event.dispAnim > 0){
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
					}
					draw_sprite_ext(spr_event, 4, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, 0.5, 0.5, 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), c_white, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}else if (event.anim <= 0.5){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				var diff, time, rot, width = 0;
				time = event.anim;
				event.timer++;
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, c_gray, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					gpu_set_colorwriteenable(true, true, true, true);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				rot = 20*dsin(135*event.timer/60);
				if (event.hidden){
					diff = 1 - 0.5*dcos(90/0.25*min(time, 0.25));
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						draw_set_alpha(((time < 0.5) ? 0.25 - 0.25*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : 0.25)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, c_gray, c_gray, c_gray, c_gray, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface2);
						}
					}
					if (time < 0.5){
						var coseno = dcos(90/0.25*clamp(time - 0.25, 0, 0.25));
						if (event.colorProgressBar and time >= 0.25 and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (127 - bar.color2.r)*(1 - coseno), bar.color2.g + (127 - bar.color2.g)*(1 - coseno), bar.color2.b + (127 - bar.color2.b)*(1 - coseno));
						}
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(coseno, dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25))]);
					}else{
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = c_gray;
						}
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
					}
					var diff2 = diff - 0.4*(diff - 0.5);
					draw_sprite_ext(spr_event, 4, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, (event.animateIcon ? diff2 : 0.5), (event.animateIcon ? diff2 : 0.5), (event.animateIcon ? rot*2*(diff - 0.5) : 0) + 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), c_white, fullAlpha*2*(diff - 0.5)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}else{
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						draw_set_alpha(((time < 0.25) ? 0.25 - 0.25*dcos(90/0.25*time) : 0.25)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, c_gray, c_gray, c_gray, c_gray, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface2);
						}
					}
					if (time < 0.25){
						var coseno = dcos(90/0.25*time);
						if (event.colorProgressBar and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (127 - bar.color2.r)*(1 - coseno), bar.color2.g + (127 - bar.color2.g)*(1 - coseno), bar.color2.b + (127 - bar.color2.b)*(1 - coseno));
						}
						diff = 0.8 - 0.3*coseno;
					}else{
						diff = 0.8;
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = c_gray;
						}
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
					draw_sprite_ext(spr_event, 4, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, (event.animateIcon ? diff : 0.5), (event.animateIcon ? diff : 0.5), (event.animateIcon ? rot*(diff - 0.5)/0.3 : 0) + 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), c_white, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}else if (event.anim < 0.75){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				if (event.colorProgressBar){
					if (!bar.color4){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
						bar.color4 = true;
					}else if (bar.color3.r == -1){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
					}
				}
				var time = event.anim - 0.5, width = 0;
				event.timer++;
				rot = 20*dsin(135*event.timer/60);
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, c_gray, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_colorwriteenable(true, true, true, true);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, c_gray, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				coseno = dcos(90/0.25*time);
				if (bar.color4){
					bar.color = make_color_rgb(127 + (bar.color3.r - 127)*(1 - coseno), 127 + (bar.color3.g - 127)*(1 - coseno), 127 + (bar.color3.b - 127)*(1 - coseno));
				}
				diff = 0.5 + 0.3*coseno;
				if (surface_exists(event.surface1)){
					if (string_pos("particles", event.visualType)){
						draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff - 0.5)/0.3*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					}else{
						surface_free(event.surface1);
					}
				}
				if (string_pos("filled", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					draw_set_alpha(0.25*(diff - 0.5)/0.3*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, c_gray, c_gray, c_gray, c_gray, false);
					draw_set_alpha(1);
				}
				if (surface_exists(event.surface2)){
					if (string_pos("marked", event.visualType)){
						draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff - 0.5)/0.3*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					}else{
						surface_free(event.surface2);
					}
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
				draw_sprite_ext(spr_event, 4, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, (event.animateIcon ? diff : 0.5), (event.animateIcon ? diff : 0.5), (event.animateIcon ? rot/0.3*(diff - 0.5) : 0) + 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), c_gray, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else if (event.anim == 0.75){
				if (bar.color4){
					bar.color = make_color_rgb(bar.color3.r, bar.color3.g, bar.color3.b);
					bar.color2.r = -1;
					bar.color2.g = -1;
					bar.color2.b = -1;
					bar.color3.r = -1;
					bar.color3.g = -1;
					bar.color3.b = -1;
					bar.color4 = false;
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
				draw_sprite_ext(spr_event, 4, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, 0.5, 0.5, 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), c_gray, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}
			if (event.anim == 0.75 or event.anim == 0){
				if (surface_exists(event.surface1)){
					surface_free(event.surface1);
				}
				if (surface_exists(event.surface2)){
					surface_free(event.surface2);
				}
			}
		break; }
		case "custom": {
			var sprite = spr_event;
			var size = 1;
			if (is_struct(event.sprite)){
				sprite = event.sprite.sprite;
				size = 64/max(sprite_get_width(sprite), sprite_get_height(sprite), 64);
			}
			if (!event.updated){
				event.updated = true;
				if (is_struct(event.sprite) and variable_struct_exists(event.sprite, "animation_times") and !event.pauseIconAnim){
					event.sprite.timer += delta_time*event.sprite.animation_speed/10000;
					if (is_array(event.sprite.animation_times)){
						while ((event.spriteIndex + 1 < event.sprite.images or event.sprite.loops) and event.sprite.timer >= event.sprite.animation_times[event.spriteIndex % event.sprite.images]){
							event.sprite.timer -= event.sprite.animation_times[event.spriteIndex % event.sprite.images];
							if (event.sprite.loops){
								event.spriteIndex = (event.spriteIndex + 1) % event.sprite.images;
							}
						}
					}else{
						while ((event.spriteIndex + 1 < event.sprite.images or event.sprite.loops) and event.sprite.timer >= event.sprite.animation_times){
							event.sprite.timer -= event.sprite.animation_times;
							if (event.sprite.loops){
								event.spriteIndex = (event.spriteIndex + 1) % event.sprite.images;
							}
						}
					}
				}
				var step = delta_time/1000000;
				if (event.dispAnim >= 0 and event.dispAnim < 0.5){
					event.dispAnim = min(event.dispAnim + step, 0.5);
				}
				if (timeSong < event.time){
					if (event.anim == 0.75){
						event.anim = 0;
					}else if (event.anim > 0.5){
						event.anim = min(event.anim + step, 0.75);
					}else{
						event.anim = max(event.anim - step, 0);
					}
				}else if (timeSong < event.finish){
					if (event.anim <= 0.5){
						if (!event.checkpoint or !event.waitTriggered or event.triggered){
							event.anim = min(event.anim + step, 0.5);
						}else{
							event.anim = 0;
						}
					}else{
						event.anim = max(event.anim - step, 0.5);
					}
				}else if (timeSong >= event.finish){
					if (event.anim == 0){
						event.anim = 0.75;
					}else{
						event.anim = clamp(event.anim + step, 0.5, 0.75);
					}
				}
			}
			if (event.anim == 0){
				if (!event.hidden){
					if (event.dispAnim > 0){
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
					}
					draw_sprite_ext(sprite, event.spriteIndex, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, 0.5*size, 0.5*size, 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), event.iconColor.start, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}else if (event.checkpoint and !event.hideCheckpoint){
					if (event.damage > 0){
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_pink, fullAlpha);
					}else if (damage == 0){
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_cyan, fullAlpha);
					}else{
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, c_green2, fullAlpha);
					}
				}
			}else if (event.anim <= 0.5){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				var curR = color_get_red(event.iconColor.active), curG = color_get_green(event.iconColor.active), curB = color_get_blue(event.iconColor.active), diff, time, rot, width = 0;
				time = event.anim;
				event.timer++;
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, event.visualColor, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					gpu_set_colorwriteenable(true, true, true, true);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				rot = 20*dsin(135*event.timer/60);
				if (event.hidden){
					diff = 1 - 0.5*dcos(90/0.25*min(time, 0.25));
					if (event.checkpoint){
						var checkcolor;
						if (event.damage > 0){
							checkcolor = c_pink;
						}else if (event.damage == 0){
							checkcolor = c_cyan;
						}else{
							checkcolor = c_green2;
						}
						if (!event.hideCheckpoint){
							draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, checkcolor, fullAlpha*max(2*(1 - diff), 1 - dcos(90*max(event.dispAnim - 0.25, 0)/0.25)));
						}else{
							draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, checkcolor, fullAlpha*(1 - dcos(90*max(event.dispAnim - 0.25, 0)/0.25)));
						}
					}
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						draw_set_alpha(((time < 0.5) ? 0.25 - 0.25*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : 0.25)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, event.visualColor, event.visualColor, event.visualColor, event.visualColor, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface2);
						}
					}
					if (time < 0.5){
						var coseno = dcos(90/0.25*clamp(time - 0.25, 0, 0.25));
						if (event.colorProgressBar and time >= 0.25 and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,max(coseno, dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25))]);
					}else{
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(curR, curG, curB);
						}
						shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
					}
					var diff2 = diff - 0.4*(diff - 0.5);
					draw_sprite_ext(sprite, event.spriteIndex, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, (event.animateIcon ? diff2 : 0.5)*size, (event.animateIcon ? diff2 : 0.5)*size, (event.animateIcon ? rot*2*(diff - 0.5) : 0) + 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), make_color_rgb(curR, curG, curB), fullAlpha*2*(diff - 0.5)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}else{
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						draw_set_alpha(((time < 0.25) ? 0.25 - 0.25*dcos(90/0.25*time) : 0.25)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, event.visualColor, event.visualColor, event.visualColor, event.visualColor, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha)*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
						}else{
							surface_free(event.surface2);
						}
					}
					var color;
					if (time < 0.25){
						var prevR = color_get_red(event.iconColor.start), prevG = color_get_green(event.iconColor.start), prevB = color_get_blue(event.iconColor.start), coseno;
						coseno = dcos(90/0.25*time);
						if (event.colorProgressBar and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
						curR = curR - prevR;
						curG = curG - prevG;
						curB = curB - prevB;
						diff = 0.8 - 0.3*coseno;
						color = make_color_rgb(prevR + curR - curR*coseno, prevG + curG - curG*coseno, prevB + curB - curB*coseno);
					}else{
						diff = 0.8;
						color = make_color_rgb(curR, curG, curB);
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = color;
						}
					}
					if (event.checkpoint){
						var checkcolor;
						if (event.damage > 0){
							checkcolor = c_pink;
						}else if (event.damage == 0){
							checkcolor = c_cyan;
						}else{
							checkcolor = c_green2;
						}
						draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, checkcolor, fullAlpha*(1 - dcos(90*max(event.dispAnim - 0.25, 0)/0.25)));
					}
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
					draw_sprite_ext(sprite, event.spriteIndex, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, (event.animateIcon ? diff : 0.5)*size, (event.animateIcon ? diff : 0.5)*size, (event.animateIcon ? rot*(diff - 0.5)/0.3 : 0) + 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), color, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
			}else if (event.anim < 0.75){
				if (is_array(array)){
					array_push(array, event);
					return;
				}
				if (event.colorProgressBar){
					if (!bar.color4){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
						bar.color4 = true;
					}else if (bar.color3.r == -1){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
					}
				}
				var time = event.anim - 0.5, color, diff2, prevR = color_get_red(event.iconColor.active), prevG = color_get_green(event.iconColor.active), prevB = color_get_blue(event.iconColor.active), curR = color_get_red(event.iconColor.start), curG = color_get_green(event.iconColor.start), curB = color_get_blue(event.iconColor.start), width = 0;
				event.timer++;
				rot = 20*dsin(135*event.timer/60);
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.timer%moder == 0){
						var variator = (event.timer%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, event.visualColor, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_colorwriteenable(true, true, true, true);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.timer;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, event.visualColor, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				coseno = dcos(90/0.25*time);
				if (bar.color4){
					bar.color = make_color_rgb(prevR + (bar.color3.r - prevR)*(1 - coseno), prevG + (bar.color3.g - prevG)*(1 - coseno), prevB + (bar.color3.b - prevB)*(1 - coseno));
				}
				diff2 = 0.5 + 0.3*coseno;
				if (surface_exists(event.surface1)){
					if (string_pos("particles", event.visualType)){
						draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff2 - 0.5)/0.3*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					}else{
						surface_free(event.surface1);
					}
				}
				if (string_pos("filled", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					draw_set_alpha(0.25*(diff2 - 0.5)/0.3*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, event.visualColor, event.visualColor, event.visualColor, event.visualColor, false);
					draw_set_alpha(1);
				}
				if (surface_exists(event.surface2)){
					if (string_pos("marked", event.visualType)){
						draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*(diff2 - 0.5)/0.3*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
					}else{
						surface_free(event.surface2);
					}
				}
				curR = curR - prevR;
				curG = curG - prevG;
				curB = curB - prevB;
				color = make_color_rgb(prevR + curR - curR*coseno, prevG + curG - curG*coseno, prevB + curB - curB*coseno);
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
				if (event.checkpoint){
					var checkcolor;
					if (event.damage > 0){
						checkcolor = c_pink;
					}else if (event.damage == 0){
						checkcolor = c_cyan;
					}else{
						checkcolor = c_green2;
					}
					draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, checkcolor, fullAlpha*(1 - dcos(90*max(event.dispAnim - 0.25, 0)/0.25)));
				}
				draw_sprite_ext(sprite, event.spriteIndex, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, (event.animateIcon ? diff : 0.5)*size, (event.animateIcon ? diff : 0.5)*size, (event.animateIcon ? rot/0.3*(diff - 0.5) : 0) + 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), color, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}else if (event.anim == 0.75){
				if (bar.color4){
					bar.color = make_color_rgb(bar.color3.r, bar.color3.g, bar.color3.b);
					bar.color2.r = -1;
					bar.color2.g = -1;
					bar.color2.b = -1;
					bar.color3.r = -1;
					bar.color3.g = -1;
					bar.color3.b = -1;
					bar.color4 = false;
				}
				if (event.checkpoint){
					var checkcolor;
					if (event.damage > 0){
						checkcolor = c_pink;
					}else if (event.damage == 0){
						checkcolor = c_cyan;
					}else{
						checkcolor = c_green2;
					}
					draw_sprite_ext(spr_event, 0, 447 + positionX, 24 + positionY, 0.5, 0.5, 0, checkcolor, fullAlpha*(1 - dcos(90*max(event.dispAnim - 0.25, 0)/0.25)));
				}
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25)]);
				draw_sprite_ext(sprite, event.spriteIndex, 447 + positionX, 24 - 18*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25) + positionY, 0.5*size, 0.5*size, 360*dsin(90*clamp(event.dispAnim, 0, 0.25)/0.25), event.iconColor.start, fullAlpha*dcos(90*max(event.dispAnim - 0.25, 0)/0.25));
				shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
			}
			if (event.anim == 0.75 or event.anim == 0){
				if (surface_exists(event.surface1)){
					surface_free(event.surface1);
				}
				if (surface_exists(event.surface2)){
					surface_free(event.surface2);
				}
			}
		break; }
		case 45: {
			if (event.timer == 0){
				var color = 0;
				if (event.damage > 0){
					color = c_pink;
				}else{
					color = c_cyan;
				}
				if (!event.hidden){
					if (item2[1] - item2[3] == 692){
						bar.lock.color = color;
						bar.lock.alpha = 1;
						bar.lock.pulse = 0;
						bar.lock.rot = 0;
						bar.lock.size = 0.75;
						//draw_sprite_ext(spr_goal, 1, 1154 + timediff, 24 + positionY, 0.75, 0.75, 0, color, fullAlpha);
					}else{
						draw_sprite_ext(spr_event, 5, 455 + item2[1] + item2[2], 24 + positionY, 0.75, 0.75, 0, color, fullAlpha);
					}
				}else if (item2[1] - item2[3] == 692){
					bar.lock.color = color;
					bar.lock.alpha = 0;
					bar.lock.pulse = 0;
					bar.lock.rot = 0;
					bar.lock.size = 0;
				}
			}else if (event.timer <= 1){
				if (is_array(array) and item2[1] - item2[3] != 692){
					array_push(array, event);
					return;
				}
				var curR, curG, curB, color, diff = 0.75, time, rot, coseno = 0, width = 0;
				time = event.timer;
				if (event.damage > 0){
					curR = 255;
					curG = 32;
					curB = 112;
				}else{
					curR = 0;
					curG = 255;
					curB = 255;
				}
				if (item2[1] - item2[3] != 692 or (item2[1] - item2[3] == 692 and is_array(array))){
					event.anim++;
				}
				color = make_color_rgb(curR, curG, curB);
				rot = 20*dsin(135*event.anim/60);
				if (event.hidden){
					if (time < 0.5){
						diff = 2.75 - 8*min(time, 0.25);
						coseno = dcos(90/0.25*clamp(time - 0.25, 0, 0.25));
						if (event.colorProgressBar and time >= 0.25 and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
						curR = curR - 255;
						curG = curG - 255;
						curB = curB - 255;
					}else{
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = color;
						}
						if (event.eject >= 0){
							event.eject += delta_time/(1000000/60);
							diff = 0.3 + 0.45*dsin(18*min(event.eject, 5)) + 0.45*dcos(9*clamp(event.eject - 20, 0, 10));
							coseno = dsin(18*min(event.eject, 5))*dcos(9*clamp(event.eject - 10, 0, 10));
							if (event.eject >= 30){
								event.eject = -1;
							}
						}
					}
					if (item2[1] - item2[3] == 692 and is_array(array)){
						bar.lock.color = color;
						bar.lock.alpha = (time < 0.5) ? (2.75 - diff)/2 : 1;
						bar.lock.pulse = coseno;
						bar.lock.rot = rot*bar.lock.alpha;
						bar.lock.size = diff;
						//draw_sprite_ext(spr_goal, 1, 1154 + timediff, 24 + positionY, diff, diff, rot, color, fullAlpha*((time < 0.5) ? (2.75 - diff)/2 : 1));
						array_push(array, event);
						return;
					}
					if (string_pos("particles", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2[0].finish - item.start;
								width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2[0].finish - item.start;
										width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(event.finish - event.start)/item.length;
									}
								}else{
									width = 692*(event.finish - event.start)/item.length;
								}
							}
							width = max(width, 1);
						}
						var moder = max(floor(13 - width/78.6), 4);
						if (event.anim%moder == 0){
							var variator = (event.anim%(2*moder))/moder;
							array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
						}
						if (!surface_exists(event.surface1)){
							event.surface1 = surface_create(width, 32);
						}else if (surface_get_width(event.surface1) != width){
							surface_resize(event.surface1, width, 32);
						}
						surface_set_target(event.surface1);
						draw_clear_alpha(c_black, 0);
						var length = array_length(event.particles);
						for (var i=0;i<length;i++){
							var object = event.particles[i];
							object.y += object.speed;
							object.rotation += 4;
							if (object.y > -10 and object.y < 42){
								draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, color, 1);
							}else{
								array_delete(event.particles, i, 1);
								i--;
								length--;
							}
						}
						shader_reset();
						gpu_set_colorwriteenable(false, false, false, true);
						gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
						draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
						gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
						gpu_set_colorwriteenable(true, true, true, true);
						surface_reset_target();
						shader_set(shd_preMulAlp);
					}
					if (string_pos("marked", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2[0].finish - item.start;
								width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2[0].finish - item.start;
										width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(event.finish - event.start)/item.length;
									}
								}else{
									width = 692*(event.finish - event.start)/item.length;
								}
							}
							width = max(width, 1);
						}
						if (!surface_exists(event.surface2)){
							event.surface2 = surface_create(width, 32);
						}else if (surface_get_width(event.surface2) != width){
							surface_resize(event.surface2, width, 32);
						}
						surface_set_target(event.surface2);
						draw_clear_alpha(c_black, 0);
						var counter = event.anim;
						for (var i=2; i < width - 2; i++){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, color, 1);
							}
							counter++;
						}
						for (var i=2; i < 30; i++){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, color, 1);
							}
							counter++;
						}
						for (var i=width - 2; i > 2; i--){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, color, 1);
							}
							counter++;
						}
						for (var i=30; i > 2; i--){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, color, 1);
							}
							counter++;
						}
						surface_reset_target();
					}
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						draw_set_alpha((time < 0.5) ? 0.25 - 0.25*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : 0.25);
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.5) ? fullAlpha - fullAlpha*dcos(90/0.25*clamp(time - 0.25, 0, 0.25)) : fullAlpha));
						}else{
							surface_free(event.surface2);
						}
					}
					if (item2[1] - item2[3] != 692){
						if (coseno > 0){
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,coseno]);
							draw_sprite_ext(spr_event, 5, 455 + item2[1] + item2[2], 24 + positionY, diff, diff, rot, color, fullAlpha*((time < 0.5) ? (2.75 - diff)/2 : 1));
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}else{
							draw_sprite_ext(spr_event, 5, 455 + item2[1] + item2[2], 24 + positionY, diff, diff, rot, color, fullAlpha*((time < 0.5) ? (2.75 - diff)/2 : 1));
						}
					}
				}else{
					if (time < 0.25){
						coseno = dcos(90/0.25*time);
						if (event.colorProgressBar and !bar.color4){
							bar.color2.r = color_get_red(bar.color);
							bar.color2.g = color_get_green(bar.color);
							bar.color2.b = color_get_blue(bar.color);
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = make_color_rgb(bar.color2.r + (curR - bar.color2.r)*(1 - coseno), bar.color2.g + (curG - bar.color2.g)*(1 - coseno), bar.color2.b + (curB - bar.color2.b)*(1 - coseno));
						}
					}else{
						if (event.colorProgressBar and !bar.color4){
							bar.color3.r = -1;
							bar.color3.g = -1;
							bar.color3.b = -1;
							bar.color4 = true;
						}
						if (bar.color4){
							bar.color = color;
						}
						if (event.eject >= 0){
							event.eject += delta_time/(1000000/60);
							diff = 0.3 + 0.45*dsin(18*min(event.eject, 5)) + 0.45*dcos(9*clamp(event.eject - 20, 0, 10));
							coseno = dsin(18*min(event.eject, 5))*dcos(9*clamp(event.eject - 10, 0, 10));
							if (event.eject >= 30){
								event.eject = -1;
							}
						}
					}
					if (item2[1] - item2[3] == 692 and is_array(array)){
						bar.lock.color = color;
						bar.lock.alpha = 1;
						bar.lock.pulse = 0;
						bar.lock.rot = rot*((time < 0.25) ? (1 - coseno) : 1);
						bar.lock.size = diff;
						//draw_sprite_ext(spr_goal, 1, 1154 + timediff, 24 + positionY, diff, diff, rot, color, fullAlpha);
						array_push(array, event);
						return;
					}
					if (string_pos("particles", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2[0].finish - item.start;
								width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2[0].finish - item.start;
										width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(event.finish - event.start)/item.length;
									}
								}else{
									width = 692*(event.finish - event.start)/item.length;
								}
							}
							width = max(width, 1);
						}
						var moder = max(floor(13 - width/78.6), 4);
						if (event.anim%moder == 0){
							var variator = (event.anim%(2*moder))/moder;
							array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
						}
						if (!surface_exists(event.surface1)){
							event.surface1 = surface_create(width, 32);
						}else if (surface_get_width(event.surface1) != width){
							surface_resize(event.surface1, width, 32);
						}
						surface_set_target(event.surface1);
						draw_clear_alpha(c_black, 0);
						var length = array_length(event.particles);
						for (var i=0;i<length;i++){
							var object = event.particles[i];
							object.y += object.speed;
							object.rotation += 4;
							if (object.y > -10 and object.y < 42){
								draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, color, 1);
							}else{
								array_delete(event.particles, i, 1);
								i--;
								length--;
							}
						}
						shader_reset();
						gpu_set_colorwriteenable(false, false, false, true);
						gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
						draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
						gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
						gpu_set_colorwriteenable(true, true, true, true);
						surface_reset_target();
						shader_set(shd_preMulAlp);
					}
					if (string_pos("marked", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2[0].finish - item.start;
								width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2[0].finish - item.start;
										width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(event.finish - event.start)/item.length;
									}
								}else{
									width = 692*(event.finish - event.start)/item.length;
								}
							}
							width = max(width, 1);
						}
						if (!surface_exists(event.surface2)){
							event.surface2 = surface_create(width, 32);
						}else if (surface_get_width(event.surface2) != width){
							surface_resize(event.surface2, width, 32);
						}
						surface_set_target(event.surface2);
						draw_clear_alpha(c_black, 0);
						var counter = event.anim;
						for (var i=2; i < width - 2; i++){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, color, 1);
							}
							counter++;
						}
						for (var i=2; i < 30; i++){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, color, 1);
							}
							counter++;
						}
						for (var i=width - 2; i > 2; i--){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, color, 1);
							}
							counter++;
						}
						for (var i=30; i > 2; i--){
							if (counter%16 < 6){
								draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, color, 1);
							}
							counter++;
						}
						surface_reset_target();
					}
					if (surface_exists(event.surface1)){
						if (string_pos("particles", event.visualType)){
							draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha));
						}else{
							surface_free(event.surface1);
						}
					}
					if (string_pos("filled", event.visualType)){
						if (width == 0){
							if (barLevel.state == levelBar.extending){
								diff = item2.finish - item.start;
								width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
							}else if (barLevel.state == levelBar.replacing){
								var pixelOld = item2.length/692;
								diff = item2.finish - item.start;
								width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
							}else{
								if (bar == segmentBar){
									if (barLevel.state == levelBar.sectionExtending){
										diff = item2.finish - item.start;
										width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
									}else if (barLevel.state == levelBar.sectionReplacing){
										var pixelOld = item2.length/692;
										diff = item2.finish - item.start;
										width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
									}else{
										width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
									}
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}
							width = max(width, 1);
						}
						draw_set_alpha((time < 0.25) ? 0.25 - 0.25*dcos(90/0.25*time) : 0.25);
						draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
						draw_set_alpha(1);
					}
					if (surface_exists(event.surface2)){
						if (string_pos("marked", event.visualType)){
							draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, ((time < 0.25) ? fullAlpha - fullAlpha*dcos(90/0.25*time) : fullAlpha));
						}else{
							surface_free(event.surface2);
						}
					}
					if (item2[1] - item2[3] != 692){
						if (coseno > 0 and time >= 0.25){
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,coseno]);
							draw_sprite_ext(spr_event, 5, 455 + item2[1] + item2[2], 24 + positionY, diff, diff, rot, color, fullAlpha);
							shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
						}else{
							draw_sprite_ext(spr_event, 5, 455 + item2[1] + item2[2], 24 + positionY, diff, diff, rot*((time < 0.25) ? (1 - coseno) : 1), color, fullAlpha);
						}
					}
				}
			}else if (event.timer < 2.5){
				if (is_array(array) and item2[1] - item2[3] != 692){
					array_push(array, event);
					return;
				}
				if (event.colorProgressBar){
					if (!bar.color4){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
						bar.color4 = true;
					}else if (bar.color3.r == -1){
						switch (bar.order[bar.index.visual].type){
							case "boss":
								bar.color3.r = 255;
								bar.color3.g = 32;
								bar.color3.b = 112;
							break;
							default:
								bar.color3.r = 0;
								bar.color3.g = 255;
								bar.color3.b = 255;
							break;
						}
					}
				}
				var time = event.timer - 2, prevR, prevG, prevB, color, width = 0;
				if (item2[1] - item2[3] != 692 or (item2[1] - item2[3] == 692 and is_array(array))){
					event.anim++;
				}
				rot = 20*dsin(135*event.anim/60);
				if (event.damage > 0){
					prevR = 255;
					prevG = 32;
					prevB = 112;
				}else{
					prevR = 0;
					prevG = 255;
					prevB = 255;
				}
				color = make_color_rgb(prevR, prevG, prevB);
				var coseno = dcos(90/0.25*max(time - 0.25, 0));
				if (bar.color4){
					bar.color = make_color_rgb(prevR + (bar.color3.r - prevR)*(1 - coseno), prevG + (bar.color3.g - prevG)*(1 - coseno), prevB + (bar.color3.b - prevB)*(1 - coseno));
				}
				if (item2[1] - item2[3] == 692 and is_array(array)){
					bar.lock.color = color;
					bar.lock.alpha = coseno;
					bar.lock.pulse = 1 - dcos(90/0.25*min(time, 0.25));
					bar.lock.rot = rot;
					bar.lock.size = 0.75;
					//draw_sprite_ext(spr_goal, 1, 1154 + timediff, 24 + positionY, 0.75, 0.75, rot, color, fullAlpha*coseno);
					array_push(array, event);
					return;
				}
				if (string_pos("particles", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2[0].finish - item.start;
							width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2[0].finish - item.start;
									width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(event.finish - event.start)/item.length;
								}
							}else{
								width = 692*(event.finish - event.start)/item.length;
							}
						}
						width = max(width, 1);
					}
					var moder = max(floor(13 - width/78.6), 4);
					if (event.anim%moder == 0){
						var variator = (event.anim%(2*moder))/moder;
						array_push(event.particles, {x: random(width), y: 42 - 52*variator, speed: -0.5 + variator, rotation: random(360)});
					}
					if (!surface_exists(event.surface1)){
						event.surface1 = surface_create(width, 32);
					}else if (surface_get_width(event.surface1) != width){
						surface_resize(event.surface1, width, 32);
					}
					surface_set_target(event.surface1);
					draw_clear_alpha(c_black, 0);
					var length = array_length(event.particles);
					for (var i=0;i<length;i++){
						var object = event.particles[i];
						object.y += object.speed;
						object.rotation += 4;
						if (object.y > -10 and object.y < 42){
							draw_sprite_ext(spr_spikeball, 0, object.x, object.y, 0.016, 0.016, object.rotation, color, 1);
						}else{
							array_delete(event.particles, i, 1);
							i--;
							length--;
						}
					}
					shader_reset();
					gpu_set_colorwriteenable(false, false, false, true);
					gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
					draw_sprite_ext(spr_eventEffect, 0, 0, 0, width, 1, 0, c_white, 1);
					gpu_set_colorwriteenable(true, true, true, true);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					surface_reset_target();
					shader_set(shd_preMulAlp);
				}
				if (string_pos("marked", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2[0].finish - item.start;
							width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2[0].finish - item.start;
									width = 692*(min(event.finish + diff, item2[0].finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.start + diff, item2[0].offset - 16*item2[0].length/692))/(item2[0].length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									width = min(min(offset, 31), 740 - timediff) + min(692*(event.finish - event.start)/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(event.finish - event.start)/item.length;
								}
							}else{
								width = 692*(event.finish - event.start)/item.length;
							}
						}
						width = max(width, 1);
					}
					if (!surface_exists(event.surface2)){
						event.surface2 = surface_create(width, 32);
					}else if (surface_get_width(event.surface2) != width){
						surface_resize(event.surface2, width, 32);
					}
					surface_set_target(event.surface2);
					draw_clear_alpha(c_black, 0);
					var counter = event.anim;
					for (var i=2; i < width - 2; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 2, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=2; i < 30; i++){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, width - 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=width - 2; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, i, 30, 2, 2, 0, color, 1);
						}
						counter++;
					}
					for (var i=30; i > 2; i--){
						if (counter%16 < 6){
							draw_sprite_ext(spr_pixel, 0, 2, i, 2, 2, 0, color, 1);
						}
						counter++;
					}
					surface_reset_target();
				}
				if (surface_exists(event.surface1)){
					if (string_pos("particles", event.visualType)){
						draw_surface_ext(event.surface1, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*coseno);
					}else{
						surface_free(event.surface1);
					}
				}
				if (string_pos("filled", event.visualType)){
					if (width == 0){
						if (barLevel.state == levelBar.extending){
							diff = item2.finish - item.start;
							width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
						}else if (barLevel.state == levelBar.replacing){
							var pixelOld = item2.length/692;
							diff = item2.finish - item.start;
							width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
						}else{
							if (bar == segmentBar){
								if (barLevel.state == levelBar.sectionExtending){
									diff = item2.finish - item.start;
									width = 692*(min(event.finish + diff, item2.finish + (item.finish - item.start - item.totalSkip)*offset/740) - max(event.time + diff, item2.offset - 16*item2.length/692))/(item2.length + timediff*offset/740) - min(positionX + 432, 0)*offset2/740 + offset2 - offset;
								}else if (barLevel.state == levelBar.sectionReplacing){
									var pixelOld = item2.length/692;
									diff = item2.finish - item.start;
									width = min(692*(min(event.finish + diff + event.offsetS + event.offsetEndS, item2.finish) + item2.totalSkip - event.prevOffset - event.prevOffsetEnd - max(event.time + item2.totalSkip + diff - event.prevOffset + event.offsetS, item2.offset - 16*item2.length/692))/item2.length + min(offset, 31), 740 - timediff) + min(692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length + 1, max(offset - 31, 0));
								}else{
									width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
								}
							}else{
								width = 692*(min(event.finish, item.finish - event.offset - event.offsetEnd) - max(event.time, item.offset - 16*item.length/692))/item.length;
							}
						}
						width = max(width, 1);
					}
					draw_set_alpha(0.25*coseno);
					draw_rectangle_color(446 + positionX, 8 + positionY, 445 + width + positionX, 39 + positionY, color, color, color, color, false);
					draw_set_alpha(1);
				}
				if (surface_exists(event.surface2)){
					if (string_pos("marked", event.visualType)){
						draw_surface_ext(event.surface2, 446 + positionX, 8 + positionY, 1, 1, 0, c_white, fullAlpha*coseno);
					}else{
						surface_free(event.surface2);
					}
				}
				if (item2[1] - item2[3] != 692){
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,1 - dcos(90/0.25*min(time, 0.25))]);
					draw_sprite_ext(spr_event, 5, 455 + item2[1] + item2[2], 24 + positionY, 0.75, 0.75, rot, color, fullAlpha*coseno);
					shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
				}
				event.timer += delta_time/1000000;
			}else{
				if (bar.color4){
					bar.color = make_color_rgb(bar.color3.r, bar.color3.g, bar.color3.b);
					bar.color2.r = -1;
					bar.color2.g = -1;
					bar.color2.b = -1;
					bar.color3.r = -1;
					bar.color3.g = -1;
					bar.color3.b = -1;
					bar.color4 = false;
				}
				if (event.damage > 0){
					color = c_pink;
				}else{
					color = c_cyan;
				}
			}
			if (event.timer >= 2.5){
				if (surface_exists(event.surface1)){
					surface_free(event.surface1);
				}
				if (surface_exists(event.surface2)){
					surface_free(event.surface2);
				}
			}
		}
	}
}
function CheckControlInput(control, zurdo, act, checkhold=false, idd=0){
	if (control == controls.keyboard){
		if (zurdo){
			if (act == action.horizontal){
				return (keyboard_check(ord("D")) - keyboard_check(ord("A")));
			}else{ if (act == action.vertical){
				return (keyboard_check(ord("S")) - keyboard_check(ord("W")));
			}else{ if (act == action.confirm){
				if (checkhold){
					return keyboard_check(vk_enter);
				}else{
					return keyboard_check_pressed(vk_enter);
				}
			}else{ if (act == action.cancel){
				if (checkhold){
					return keyboard_check(vk_backspace);
				}else{
					return keyboard_check_pressed(vk_backspace);
				}
			}}}}
		}else{
			if (act == action.horizontal){
				return (keyboard_check(vk_right) - keyboard_check(vk_left));
			}else{ if (act == action.vertical){
				return (keyboard_check(vk_down) - keyboard_check(vk_up));
			}else{ if (act == action.confirm){
				if (checkhold){
					return keyboard_check(vk_space);
				}else{
					return keyboard_check_pressed(vk_space);
				}
			}else{ if (act == action.cancel){
				if (checkhold){
					return keyboard_check(vk_escape);
				}else{
					return keyboard_check_pressed(vk_escape);
				}
			}}}}
		}
	}else{ if (control == controls.gamepad){
		if (!zurdo){
			if (act == action.horizontal){
				return clamp(gamepad_axis_value(idd, gp_axislh) + gamepad_button_check(idd, gp_padr) - gamepad_button_check(idd, gp_padl), -1, 1);
			}else{ if (act == action.vertical){
				return clamp(gamepad_axis_value(idd, gp_axislv) + gamepad_button_check(idd, gp_padd) - gamepad_button_check(idd, gp_padu), -1, 1);
			}else{ if (act == action.confirm){
				if (checkhold){
					return gamepad_button_check(idd, gp_face1);
				}else{
					return gamepad_button_check_pressed(idd, gp_face1);
				}
			}else{ if (act == action.cancel){
				if (checkhold){
					return gamepad_button_check(idd, gp_face2);
				}else{
					return gamepad_button_check_pressed(idd, gp_face2);
				}
			}}}}
		}else{
			if (act == action.horizontal){
				return gamepad_axis_value(idd, gp_axisrh);
			}else{ if (act == action.vertical){
				return gamepad_axis_value(idd, gp_axisrv);
			}else{ if (act == action.confirm){
				if (checkhold){
					return gamepad_button_check(idd, gp_shoulderl);
				}else{
					return gamepad_button_check_pressed(idd, gp_shoulderl);
				}
			}else{ if (act == action.cancel){
				if (checkhold){
					return gamepad_button_check(idd, gp_shoulderlb);
				}else{
					return gamepad_button_check_pressed(idd, gp_shoulderlb);
				}
			}}}}
		}
	}else{
		if (!zurdo){
			if (act == action.horizontal){
				return clamp(gamepad_axis_value(4 + idd, gp_axislh) + gamepad_button_check(4 + idd, gp_padr) - gamepad_button_check(4 + idd, gp_padl), -1, 1);
			}else{ if (act == action.vertical){
				return clamp(gamepad_axis_value(4 + idd, gp_axislv) + gamepad_button_check(4 + idd, gp_padd) - gamepad_button_check(4 + idd, gp_padu), -1, 1);
			}else{ if (act == action.confirm){
				if (checkhold){
					return gamepad_button_check(4 + idd, gp_face1);
				}else{
					return gamepad_button_check_pressed(4 + idd, gp_face1);
				}
			}else{ if (act == action.cancel){
				if (checkhold){
					return gamepad_button_check(4 + idd, gp_face2);
				}else{
					return gamepad_button_check_pressed(4 + idd, gp_face2);
				}
			}}}}
		}else{
			if (act == action.horizontal){
				return gamepad_axis_value(4 + idd, gp_axisrh);
			}else{ if (act == action.vertical){
				return gamepad_axis_value(4 + idd, gp_axisrv);
			}else{ if (act == action.confirm){
				if (checkhold){
					return gamepad_button_check(4 + idd, gp_shoulderl);
				}else{
					return gamepad_button_check_pressed(4 + idd, gp_shoulderl);
				}
			}else{ if (act == action.cancel){
				if (checkhold){
					return gamepad_button_check(4 + idd, gp_shoulderlb);
				}else{
					return gamepad_button_check_pressed(4 + idd, gp_shoulderlb);
				}
			}}}}
		}
	}}
}
#region Gameplay functions
function getSprite(spr){
	var spr_copy = -1;
	switch (spr){
		case "circle.png":
			spr_copy = {sprite: spr_circle, animated: false};
		break;
		case "circle wave.png":
			spr_copy = {sprite: spr_circle_wave, animated: false};
		break;
		case "explosive ball.png":
			spr_copy = {sprite: spr_explosiveball, animated: false};
		break;
		case "spike ball.png":
			spr_copy = {sprite: spr_spikeball, animated: false};
		break;
		case "triangle.png":
			spr_copy = {sprite: spr_triangle, animated: false};
		break;
		case "pixel2x2.png":
			spr_copy = {sprite: spr_pixel, animated: false};
		break;
		case "explotion.gif":
			var speeed = 100/60;
			spr_copy = {sprite: spr_explotion, animation_speed: 1, loops: false, animation_times: [speeed,speeed,speeed,speeed,speeed,speeed]};
		break;
		default:
			spr = Sprites[$ spr];
			if (is_struct(spr)){
				spr_copy = {};
				var names = variable_struct_get_names(spr);
				var length = array_length(names);
				for (var i=0;i<length;i++){
					var value = variable_struct_get(spr,names[i]);
					if (is_array(value)){
						var temp = [];
						array_copy(temp,0,value,0,array_length(value));
						variable_struct_set(spr_copy,names[i],temp);
					}else{
						variable_struct_set(spr_copy,names[i],value);
					}
				}
			}else{
				spr_copy = undefined;
			}
		break;
	}
	if (spr_copy != undefined and variable_struct_exists(spr_copy,"animation_times")){
		spr_copy.index = 0;
		spr_copy.timer = 0;
	}
	return spr_copy;
}
function getModel(mdl){
	var mdl_copy = -1;
	switch (mdl){
		default:
			mdl = Models[$ mdl];
			if (is_struct(mdl)){
				mdl_copy = variable_clone(mdl);
			}else{
				mdl_copy = undefined;
			}
		break;
	}
	return mdl_copy;
}
function setLevel(a){
	if (obj_game.state == level.ready or obj_game.state == level.waiting){
		var length = array_length(a);
		var item = Levels[obj_game.selected];
		for (var i=0;i<length;i++){
			var indexx = a[i].musicIndex;
			var filename = item.song[indexx] + " by " + item.artist[indexx][0];
			var track = Music[$ filename];
			if (!variable_struct_exists(a[i],"finish")){
				a[i].finish = audio_sound_length(track[0]);
			}else{
				a[i].finish = min(a[i].finish, audio_sound_length(track[0]));
			}
			if (!variable_struct_exists(a[i],"start")){
				a[i].start = 0;
			}else{
				a[i].start = min(a[i].start, audio_sound_length(track[0]));
			}
			if (!variable_struct_exists(a[i],"type")){
				a[i].type = {name: "none", keepIconOnThisBar: false, showIconOnPrevBar: false};
			}else{
				if (!variable_struct_exists(a[i].type,"name")){
					a[i].type.name = "none";
				}else{
					a[i].type.name = string_lower(a[i].type.name);
					if (!variable_struct_exists(a[i].type,"showIconOnPrevBar")){
						a[i].type.showIconOnPrevBar = true;
					}
					if (!variable_struct_exists(a[i].type,"keepIconOnThisBar")){
						a[i].type.keepIconOnThisBar = true;
					}
				}
			}
			if (!variable_struct_exists(a[i],"hidden")){
				a[i].hidden = false;
			}
			if (!variable_struct_exists(a[i],"endCheckpoint") or i + 1 == length){
				a[i].endCheckpoint = {enabled: false, waitTriggered: false};
			}else{
				a[i].endCheckpoint.enabled = true;
				a[i].endCheckpoint.triggered = false;
				if (!variable_struct_exists(a[i].endCheckpoint, "waitTriggered")){
					a[i].endCheckpoint.waitTriggered = false;
				}
				if (!variable_struct_exists(a[i].endCheckpoint, "damage")){
					a[i].endCheckpoint.damage = 0;
				}
				if (!variable_struct_exists(a[i].endCheckpoint, "message")){
					a[i].endCheckpoint.message = "";
				}
			}
			if (!variable_struct_exists(a[i],"musicSkip")){
				a[i].musicSkip = [];
			}
			if (!variable_struct_exists(a[i],"musicLoop")){
				a[i].musicLoop = [];
			}else{
				var length2 = array_length(a[i].musicLoop);
				for (var j=0;j<length2;j++){
					a[i].musicLoop[j].prevSongTime = -1;
					a[i].musicLoop[j].eject = -1;
					a[i].musicLoop[j].looped = 0;
					a[i].musicLoop[j].surface1 = -1;
					a[i].musicLoop[j].surface2 = -1;
					a[i].musicLoop[j].particles = [];
					a[i].musicLoop[j].timer = 0;
					a[i].musicLoop[j].startSkip = -1;
					a[i].musicLoop[j].anim = 0;
					a[i].musicLoop[j].name = 45;
					if (!variable_struct_exists(a[i].musicLoop[j], "visualType")){
						a[i].musicLoop[j].visualType = "none";
					}else{
						a[i].musicLoop[j].visualType = string_lower(a[i].musicLoop[j].visualType);
					}
					if (!variable_struct_exists(a[i].musicLoop[j], "damage")){
						a[i].musicLoop[j].damage = 0;
					}else{
						a[i].musicLoop[j].damage = max(a[i].musicLoop[j].damage, 0);
					}
					if (!variable_struct_exists(a[i].musicLoop[j], "aboveLayer")){
						a[i].musicLoop[j].aboveLayer = false;
					}
					if (!variable_struct_exists(a[i].musicLoop[j], "message") or string_replace_all(a[i].musicLoop[j].message," ","") == ""){
						a[i].musicLoop[j].message = "";
					}
					if (!variable_struct_exists(a[i].musicLoop[j], "hidden")){
						a[i].musicLoop[j].hidden = false;
					}
					if (!variable_struct_exists(a[i].musicLoop[j], "shake")){
						a[i].musicLoop[j].shake = false;
					}
					if (!variable_struct_exists(a[i].musicLoop[j], "colorProgressBar")){
						a[i].musicLoop[j].colorProgressBar = false;
					}
				}
			}
			var length2 = array_length(a[i].musicSkip); //Checar que todos los loops y segmentos esten dentro del rango de la barra y que los skips no esten fuera
			var newArray = [];
			a[i].totalSkip = 0;
			for (var j=1; j<length2; j+=2){
				var _start = a[i].musicSkip[j - 1];
				var _end = a[i].musicSkip[j];
				if (_start < a[i].finish and _end > a[i].finish){
					a[i].finish = _start;
				}
				if (_start < a[i].start and _end > a[i].start){
					a[i].start = _end;
				}
				var length3 = array_length(newArray);
				var handled = false;
				for (var k=1; k<length3; k+=2){
					var __start = newArray[k - 1];
					var __end = newArray[k];
					if (_start >= __start and _start <= __end and _end >= __start and _end <= __end){
						handled = true;
						break;
					}else if (_start >= __start and _start <= __end and _end > __end){
						newArray[k] = _end;
						handled = true;
					}else if (_end >= __start and _end <= __end and _start < __start){
						newArray[k - 1] = _start;
						handled = true;
					}
				}
				if (!handled and _end > _start){
					array_push(newArray, _start);
					array_push(newArray, _end);
					a[i].totalSkip += _end - _start;
				}
			}
			array_sort(newArray, true);
			a[i].musicSkip = newArray;
			length2 = array_length(a[i].musicLoop);
			newArray = [];
			for (var j=0; j<length2; j++){
				var _start = a[i].musicLoop[j].start;
				var _end = a[i].musicLoop[j].finish;
				if (_start > a[i].finish){
					_start = a[i].finish;
				}else if (_start < a[i].start){
					_start = a[i].start;
				}
				if (_end > a[i].finish){
					_end = a[i].finish;
				}else if (_end < a[i].start){
					_end = a[i].start;
				}
				if (_start >= _end){
					continue;
				}
				a[i].musicLoop[j].length = _end - _start;
				var length3 = array_length(newArray);
				var handled = false;
				for (var k=0; k<length3; k++){
					if (_end == newArray[k]){
						handled = true;
						break;
					}
				}
				if (!handled){
					var length4 = array_length(a[i].musicSkip);
					var offset = 0;
					var offsetEnd = 0;
					var terminate = false;
					for (var k=1; k<length4; k+=2){ //Verify if all this for instruction is ok
						var __start = a[i].musicSkip[k - 1];
						var __end = a[i].musicSkip[k];
						if (_start >= __start and _start < __end and _end > __end){
							_start = __end;
						}else if (_end > __start and _end <= __end and _start < __start){
							_end = __start;
						}else if (_end >= __start and _end < __end and _start >= __start and _start < __end){
							terminate = true;
							break;
						}else if (__start > _start and __start < _end and __end > _start and __end < _end){
							if (a[i].musicLoop[j].startSkip == -1){
								a[i].musicLoop[j].startSkip = k - 1;
							}
							offsetEnd += __end - __start;
						}else if (__end <= _start){
							offset += __end - __start;
						}
					}
					if (terminate){
						continue;
					}
					a[i].musicLoop[j].offset = offset;
					a[i].musicLoop[j].offsetEnd = offsetEnd;
					a[i].musicLoop[j].offsetS = offset;
					a[i].musicLoop[j].offsetEndS = offsetEnd;
					a[i].musicLoop[j].start = _start - offset;
					a[i].musicLoop[j].finish = _end - offset - offsetEnd;
					a[i].musicLoop[j].staticStart = _start;
					a[i].musicLoop[j].staticFinish = _end;
					array_push(newArray, a[i].musicLoop[j]);
				}
			}
			var func = function(elem1, elem2){
				return sign(elem1.finish - elem2.finish);
			}
			array_sort(newArray, func);
			a[i].musicLoop = newArray;
			if (!variable_struct_exists(a[i],"musicSegments") or obj_game.configuringSegments){
				a[i].musicSegments = [];
			}else{
				obj_game.configuringSegments = true;
				length2 = array_length(a[i].musicSegments);
				length3 = array_length(a[i].musicLoop);
				var length4 = array_length(a[i].musicSkip);
				for (var j=0; j<length2; j++){
					var abort = false;
					var segmento = a[i].musicSegments[j];
					if (!variable_struct_exists(segmento,"showSongTitleBack")){
						segmento.showSongTitleBack = true;
					}
					if (!variable_struct_exists(segmento,"damage")){
						segmento.damage = 0;
					}else{
						segmento.damage = max(segmento.damage, 0);
						if (segmento.damage > 0 and !variable_struct_exists(segmento, "condition")){
							segmento.condition = function(){return false;};
						}
						segmento.damageTimer = 0;
					}
					for (k=0; k<length3; k++){
						var _start = a[i].musicLoop[k].start;
						var _end = a[i].musicLoop[k].finish;
						if (segmento.segmentStart > _start and segmento.segmentStart < _end){
							abort = true;
							break;
						}
					}
					if (abort){
						array_delete(a[i].musicSegments, j, 1);
						j--;
						length2--;
					}else{
						for (var k=1; k<length4; k+=2){
							var _start = a[i].musicSkip[k - 1];
							var _end = a[i].musicSkip[k];
							if (segmento.segmentStart >= _start and segmento.segmentStart < _end){
								segmento.segmentStart = _end;
								break;
							}
						}
						setLevel(a[i].musicSegments[j].segmentBars);
					}
				}
				obj_game.configuringSegments = false;
			}
			if (!variable_struct_exists(a[i],"extend")){
				a[i].extend = false;
			}
			if (!variable_struct_exists(a[i],"extra")){
				a[i].extra = false;
			}
			if (!variable_struct_exists(a[i],"events")){
				a[i].events = [];
			}
			a[i].offset = a[i].start;
			a[i].length = a[i].finish - a[i].start - a[i].totalSkip;
			if (a[i].extend and i > 0){
				a[i].length += a[i - 1].length;
				a[i].offset -= a[i - 1].length;
			}
		}
		for (var i=0;i<length;i++){
			var pos = -1;
			var index = -1;
			var indicator = 0;
			var specialOne = 0;
			if (a[i].extend and i > 0){
				var length2 = array_length(a[i - 1].events);
				var eventsCopy = [];
				for (var j=0;j<length2;j++){
					var duplicate = variable_clone(a[i - 1].events[j]);
					duplicate.created = true;
					if (duplicate.name != "checkpoint"){
						duplicate.ref = a[i - 1].events[j];
						if (duplicate.name == "collectible" or duplicate.name == "custom"){
							duplicate.collected = duplicate.ref.collected;
						}
					}else if (duplicate.special){
						specialOne = 1;
					}
					array_push(eventsCopy, duplicate);
				}
				for (var j=0;j<length2;j++){
					eventsCopy[j].time -= a[i - 1].finish - a[i].start - a[i - 1].totalSkip;
					if (variable_struct_exists(eventsCopy[j], "finish")){
						eventsCopy[j].finish -= a[i - 1].finish - a[i].start - a[i - 1].totalSkip;
					}
				}
				length2 = array_length(a[i].events);
				for (var j=0;j<length2;j++){
					array_push(eventsCopy, a[i].events[j]);
				}
				a[i].events = eventsCopy;
			}
			var length3 = array_length(a[i].events);
			for (var j=specialOne; j<length3; j++){
				var event = a[i].events[j];
				event.name = string_lower(event.name);
				if (event.name != "checkpoint"){
					if (!variable_struct_exists(event, "hidden")){
						event.hidden = false;
					}
					if (event.name == "collectible" or !variable_struct_exists(event, "checkpoint")){
						event.checkpoint = false;
					}
					if (event.checkpoint and !variable_struct_exists(event, "waitTriggered")){
						event.waitTriggered = false;
					}
					if ((event.name == "collectible" or event.name == "custom") and !variable_struct_exists(event, "ref")){	
						event.dispAnim = -1;
						event.time = max(event.time, a[i].start);
						event.finish = min(event.finish, a[i].finish);
						if (event.name == "custom"){
							if (!variable_struct_exists(event, "sprite")){
								event.sprite = undefined;
								if (!variable_struct_exists(event, "spriteIndex")){
									event.spriteIndex = 4;
								}
							}else{
								event.sprite = getSprite(event.sprite);
								if (!variable_struct_exists(event, "spriteIndex")){
									if (is_undefined(event.sprite)){
										event.spriteIndex = 4;
									}else{
										event.spriteIndex = 0;
									}
								}							
							}
							if (!variable_struct_exists(event, "pauseIconAnim")){
								event.pauseIconAnim = false;
							}
							if (!variable_struct_exists(event, "visualColor")){
								event.visualColor = c_white;
							}
							if (!variable_struct_exists(event, "iconColor")){
								event.iconColor = {start: c_white, active: c_white};
							}else{
								if (!variable_struct_exists(event.iconColor, "start")){
									event.iconColor.start = c_white;
								}
								if (!variable_struct_exists(event.iconColor, "active")){
									event.iconColor.active = c_white;
								}
							}
						}
						if (!variable_struct_exists(event, "collected")){
							event.collected = function(){return false;};
						}
						if (!variable_struct_exists(event, "animateIcon")){
							event.animateIcon = true;
						}
					}
					event.anim = 0;
					event.updated = false;
					event.offset = 0;
					event.offsetEnd = 0;
					event.offsetS = 0;
					event.offsetEndS = 0;
					if (!variable_struct_exists(event, "prevOffset")){
						event.prevOffset = 0;
					}
					if (!variable_struct_exists(event, "prevOffsetEnd")){
						event.prevOffsetEnd = 0;
					}
					if (event.name != "collectible" and event.name != "custom" and !variable_struct_exists(event, "behavior")){
						event.behavior = "warning";
					}
					if (!variable_struct_exists(event, "visualType")){
						event.visualType = "none";
					}else{
						event.visualType = string_lower(event.visualType);
					}
					if (!variable_struct_exists(event, "colorProgressBar")){
						event.colorProgressBar = false;
					}
					event.surface1 = -1;
					event.surface2 = -1;
					event.timer = 0;
					event.particles = [];
				}else{
					event.special = false;
				}
				if (event.name == "checkpoint" or event.checkpoint){
					var length2 = array_length(a[i].musicLoop);
					var allowed = true;
					for (var k=0; k<length2; k++){
						var _start = a[i].musicLoop[k].staticStart;
						var _end = a[i].musicLoop[k].staticFinish;
						if (event.time >= _start and event.time < _end){
							allowed = false;
							break;
						}
					}
					if (event.time >= a[i].finish){
						allowed = false;
					}
					if (!allowed){
						if (event.name == "checkpoint"){
							array_delete(a[i].events, j, 1);
							j--;
							length3--;
							continue;
						}else{
							event.checkpoint = false;
						}
					}else{
						if (!variable_struct_exists(event, "damage")){
							event.damage = 0;
						}
						if (!variable_struct_exists(event, "message") or string_replace_all(event.message," ","") == ""){
							event.message = "";
						}
					}
				}
				var length2 = array_length(a[i].musicSkip);
				var terminate = false;
				if (variable_struct_exists(event, "finish")){
					for (var k=1; k<length2; k+=2){
						var _start = a[i].musicSkip[k - 1];
						var _end = a[i].musicSkip[k];
						if (event.time >= _start and event.time < _end and event.finish > _end){
							event.time = _end;
						}else if (event.finish > _start and event.finish <= _end and event.time < _start){
							event.finish = _start;
						}else if (event.finish >= _start and event.finish < _end and event.time >= _start and event.time < _end){
							array_delete(a[i].events, j, 1);
							length3--;
							terminate = true;
							break;
						}else if (_start > event.time and _start < event.finish and _end > event.time and _end < event.finish){
							event.offsetEnd += _end - _start;
						}else if (_end <= event.time){
							event.offset += _end - _start;
						}
					}
					event.offsetS = event.offset;
					event.offsetEndS = event.offsetEnd;
					event.time -= event.offset;
					event.finish -= event.offset + event.offsetEnd;
				}else{
					var offset = 0;
					for (var k=1; k<length2; k+=2){
						var _start = a[i].musicSkip[k - 1];
						var _end = a[i].musicSkip[k];
						if (event.time >= _start and event.time < _end){
							array_delete(a[i].events, j, 1);
							length3--;
							terminate = true;
							break;
						}else if (_end <= event.time){
							offset += _end - _start;
						}
					}
					event.time -= offset;
				}
				if (terminate){
					array_delete(a[i].events, j, 1);
					j--;
					length3--;
					continue;
				}
				if (!variable_struct_exists(event,"ref") and !variable_struct_exists(event, "created") and (!a[i].extra or j != (array_length(a[i].events) - 1)) and (event.name == "checkpoint" or (event.name != "checkpoint" and event.checkpoint))){
					event.created = false;
					if (event.name != "checkpoint" and event.checkpoint and event.waitTriggered){
						event.triggered = false;
					}
				}
				if ((event.name == "warning" or event.name == "mini boss") and event.finish + event.offset + event.offsetEnd > a[i].finish){
					if (event.finish + event.offset + event.offsetEnd > indicator){
						if (i + 1 < length and !a[i + 1].extend){
							if (pos == -1){
								pos = array_length(a[i + 1].events);
							}else{
								a[i].events[index].finish = a[i].finish - event.offset - event.offsetEnd;
							}
							index = j;
							event.ioasfnudiqwoaiucabxiw = true;
							var duplicate = variable_clone(event);
							duplicate.created = true;
							duplicate.ref = event;
							duplicate.prevOffset = event.offset;
							duplicate.prevOffsetEnd = event.offsetEnd;
							duplicate.time += event.offset;
							duplicate.finish += event.offset + event.offsetEnd;
							a[i + 1].events[pos] = duplicate;
							a[i + 1].extra = true;
						}else{
							if (index != -1){
								a[i].events[index].finish = a[i].finish - event.offset - event.offsetEnd;
							}
							index = j;
						}
						indicator = event.finish + event.offset + event.offsetEnd;
					}else{
						event.finish = a[i].finish - event.offset - event.offsetEnd;
					}
				}
			}
			if (i + 1 < length and !a[i + 1].extend and a[i + 1].extra and indexx == a[i + 1].musicIndex){
				a[i + 1].events[pos].time -= a[i].finish - a[i + 1].start;
				a[i + 1].events[pos].finish -= a[i].finish - a[i + 1].start;
			}
			if (a[i].endCheckpoint.enabled){
				array_insert(a[i].events, 0, {name: "checkpoint", special: true, index: a[i].endCheckpoint.index, music_pos: a[i].endCheckpoint.music_pos, time: a[i].finish, offset: a[i].totalSkip, damage: a[i].endCheckpoint.damage});
			}
		}
		if (obj_game.configuringSegments){
			return;
		}
		obj_game.barLevel.order = a;
		var index = obj_game.barLevel.order[0].musicIndex;
		obj_game.currentSong = {timer: -120, levelby: [], recreatedby: [], title: string_upper(item.song[index]), artist: [], from: [], state: true, type: item.song_type[index], version: item.version};
		array_copy(obj_game.currentSong.levelby,0,item.level_by,0,array_length(item.level_by));
		if (item.level_by[1] != ""){
			var itemm = obj_game.currentSong.levelby;
			itemm[1] = getSprite(itemm[1]);
			if (itemm[1] != undefined and variable_struct_exists(itemm[1],"animation_times")){
				itemm[1].index = 0;
				itemm[1].timer = 0;
			}
		}
		obj_game.currentSong.recreatedby = variable_clone(item.recreated_by);
		if (!is_undefined(item.recreated_by) and item.recreated_by[1] != ""){
			var itemm = obj_game.currentSong.recreatedby;
			itemm[1] = getSprite(itemm[1]);
		}
		array_copy(obj_game.currentSong.artist,0,item.artist[index],0,array_length(item.artist[index]));
		if (item.artist[index][1] != ""){
			var itemm = obj_game.currentSong.artist;
			itemm[1] = getSprite(itemm[1]);
		}
		obj_game.currentSong.from = variable_clone(item.from);
		if (!is_undefined(item.from) and item.from[index][1] != ""){
			var itemm = obj_game.currentSong.from;
			itemm[1] = getSprite(itemm[1]);
		}
	}
}
function killBullet(a){
	a.DeathTime = min(SongTime, a.DeathTime);
}
function createbullet(born,death,spr,xx,yy,deep,scalex,scaley,color,alpha,hurt,init,upd,drw,dsh=false,hit=function(a,b){a.GetHit(b,1)},clean=-1){
	spr = getSprite(spr);
	var bullet = instance_create_depth(xx,yy,deep,obj_bullet,{SpawnTime: born, DeathTime: death, ignoreDash: dsh, Init: init, Update: upd, Draw: drw, CleanUp: clean, canHit: hit, canHurt: hurt, spriteiomdsfilasmdanls: spr, sprite_index: spr.sprite, image_xscale: scalex, image_yscale: scaley, image_blend: color, image_alpha: alpha});
	array_push(obj_game.Bullets.Alive, bullet);
	return bullet;
}
function createbackground(born,death,spr,xx,yy,deep,scalex,scaley,color,alpha,init,upd,drw,clean=-1){
	spr = getSprite(spr);
	var bullet = instance_create_depth(xx,yy,deep,obj_background,{SpawnTime: born, DeathTime: death, Init: init, Update: upd, Draw: drw, CleanUp: clean, spriteiomdsfilasmdanls: spr, ismodelnodshnsodhau: false, sprite_index: spr.sprite, image_xscale: scalex, image_yscale: scaley, image_blend: color, image_alpha: alpha});
	array_push(obj_game.Background.Alive, bullet);
	return bullet;
}
function createmodel(born,death,mdl,xx,yy,zz,_scalex,_scaley,_scalez,color,alpha,init,upd,drw,clean=-1){
	mdl = getModel(mdl);
	var bullet = instance_create_depth(xx,yy,0,obj_background,{z: zz, SpawnTime: born, DeathTime: death, Init: init, Update: upd, Draw: drw, CleanUp: clean, rx: 0, ry: 0, rz: 0, spriteiomdsfilasmdanls: mdl, ismodelnodshnsodhau: true, scalex: _scalex, scaley: _scaley, scalez: _scalez, image_blend: color, image_alpha: alpha});
	array_push(obj_game.Background.Alive, bullet);
	return bullet;
}
function declareInit(a){
	obj_game.Init = a;
}
function declareUpdate(a){
	obj_game.Update = a;
}
function declareDraw(a){
	obj_game.Draw = a;
}
function declareRewind(a){
	obj_game.Rewind = a;
}
function playSound(sound, loop){
	switch (sound){
		case "checkpoint.ogg":
			sound = snd_checkpoint;
		break;
		case "helicopter_bonk.ogg":
			sound = snd_bonk;
		break;
		case "player_dead.ogg":
			sound = snd_dead;
		break;
		case "player_hit.ogg":
			sound = snd_hit;
		break;
		default:
			sound = Sounds[$ sound];
		break;
	}
	return audio_play_sound(sound,0,loop);
}
function volumeSound(soundID,volume,time=0){
	audio_sound_gain(soundID,volume,time);
}
function getPlayers(a,b=1,xx=0,yy=0){
	switch (a){
		case "better":
			var result = [];
			array_copy(result,0,PlayerInstances,0,array_length(PlayerInstances));
			var fun = function(a,b){
				if (a.rank > b.rank){
					return -1;
				}else{
					return 1;
				}
			}
			array_sort(result,fun);
			var result2 = [[]];
			var pos = 0;
			var inserted = false;
			for (var i=0;i<array_length(result);i++){
				if (!inserted){
					if (!result[i].murio){
						array_push(result2[0],result[i]);
						inserted = true;
					}
					continue;
				}
				if (result2[pos][0].HP == result[i].HP){
					array_push(result2[pos],result[i]);
				}else{
					pos++;
					array_push(result2,[result[i]]);
				}
			}
			return result2[min(b-1,array_length(result2)-1)];
		break;
		case "worst":
			var result = [];
			array_copy(result,0,PlayerInstances,0,array_length(PlayerInstances));
			var fun = function(a,b){
				if (a.rank < b.rank){
					return -1;
				}else{
					return 1;
				}
			}
			array_sort(result,fun);
			var result2 = [[]];
			var pos = 0;
			var inserted = false;
			for (var i=0;i<array_length(result);i++){
				if (!inserted){
					if (!result[i].murio){
						array_push(result2[0],result[i]);
						inserted = true;
					}
					continue;
				}
				if (result2[pos][0].HP == result[i].HP){
					array_push(result2[pos],result[i]);
				}else{
					pos++;
					array_push(result2,[result[i]]);
				}
			}
			return result2[min(b-1,array_length(result2)-1)];
		break;
		case "strongest":
			var result = [];
			array_copy(result,0,PlayerInstances,0,array_length(PlayerInstances));
			var fun = function(a,b){
				if (a.HP > b.HP){
					return -1;
				}else{
					return 1;
				}
			}
			array_sort(result,fun);
			var result2 = [[]];
			var pos = 0;
			var inserted = false;
			for (var i=0;i<array_length(result);i++){
				if (!inserted){
					if (!result[i].murio){
						array_push(result2[0],result[i]);
						inserted = true;
					}
					continue;
				}
				if (result2[pos][0].HP == result[i].HP){
					array_push(result2[pos],result[i]);
				}else{
					pos++;
					array_push(result2,[result[i]]);
				}
			}
			return result2[min(b-1,array_length(result2)-1)];
		break;
		case "weakest":
			var result = [];
			array_copy(result,0,PlayerInstances,0,array_length(PlayerInstances));
			var fun = function(a,b){
				if (a.HP < b.HP){
					return -1;
				}else{
					return 1;
				}
			}
			array_sort(result,fun);
			var result2 = [[]];
			var pos = 0;
			var inserted = false;
			for (var i=0;i<array_length(result);i++){
				if (!inserted){
					if (!result[i].murio){
						array_push(result2[0],result[i]);
						inserted = true;
					}
					continue;
				}
				if (result2[pos][0].HP == result[i].HP){
					array_push(result2[pos],result[i]);
				}else{
					pos++;
					array_push(result2,[result[i]]);
				}
			}
			return result2[min(b-1,array_length(result2)-1)];
		break;
		case "nearest":
			var result = [];
			for (var i=0;i<array_length(PlayerInstances);i++){
				var player = PlayerInstances[i];
				array_push(result, [player,point_distance(xx,yy,player.x,player.y)]);
			}
			var fun = function(a,b){
				if (a[1] < b[1]){
					return -1;
				}else{
					return 1;
				}
			}
			array_sort(result,fun);
			var result2 = [[]];
			var distance = result[0][1];
			var pos = 0;
			var inserted = false;
			for (var i=0;i<array_length(result);i++){
				if (!inserted){
					if (!result[i][0].murio){
						array_push(result2[0],result[i][0]);
						inserted = true;
					}
					continue;
				}
				if (distance == result[i][1]){
					array_push(result2[pos],result[i][0]);
				}else{
					pos++;
					array_push(result2,[result[i][0]]);
					distance = result[i][1];
				}
			}
			return result2[min(b-1,array_length(result2)-1)];
		break;
		case "farthest":
			var result = [];
			for (var i=0;i<array_length(PlayerInstances);i++){
				var player = PlayerInstances[i];
				array_push(result, [player,point_distance(xx,yy,player.x,player.y)]);
			}
			var fun = function(a,b){
				if (a[1] > b[1]){
					return -1;
				}else{
					return 1;
				}
			}
			array_sort(result,fun);
			var result2 = [[]];
			var distance = result[0][1];
			var pos = 0;
			var inserted = false;
			for (var i=0;i<array_length(result);i++){
				if (!inserted){
					if (!result[i][0].murio){
						array_push(result2[0],result[i][0]);
						inserted = true;
					}
					continue;
				}
				if (distance == result[i][1]){
					array_push(result2[pos],result[i][0]);
				}else{
					pos++;
					array_push(result2,[result[i][0]]);
					distance = result[i][1];
				}
			}
			return result2[min(b-1,array_length(result2)-1)];
		break;
		case "random":
			var result = [];
			var inserted = false;
			for (var i=0;i<array_length(PlayerInstances);i++){
				var player = PlayerInstances[i];
				if (!player.murio){
					array_push(result, player);
					inserted = true;
				}
			}
			if (!inserted){
				array_push(result, undefined);
			}
			return result[irandom(array_length(result)-1)];
		break;
	}
}
function maximum(a){
	var result = a[0];
	for (var i=1;i<array_length(a);i++){
		result = max(result, a[i]);
	}
	return result;
}
function getSongtime(){
	return SongTime;
}
function getLoops(){
	if (obj_game.barLevel.stuck == -1){
		return obj_game.barLevel.order[obj_game.barLevel.index.music].musicLoop[obj_game.looping].looped;
	}else{
		return obj_game.segmentBar.order[obj_game.segmentBar.index.music].musicLoop[obj_game.segLooping].looped;
	}
}
function beats_to_seconds(arg0)
{
    return arg0 / 2.1333333333333333;
}

function update_skeleton(arg0, arg1)
{
    if (arg0.skull_throw > -1)
    {
        var _time_skull = songTime - arg0.skull_throw;
        var _color, _head_color;
        
        if (_time_skull <= beats_to_seconds(2.3))
        {
            _color = make_colour_rgb(255, 143.5 - (111.5 * dcos((360 * _time_skull) / 0.1)), 183.5 - (71.5 * dcos((360 * _time_skull) / 0.1)));
            _head_color = _color;
        }
        else if (_time_skull <= beats_to_seconds(4) && arg0.skull_explode > -1)
        {
            _color = 7348479;
            _head_color = make_colour_rgb(255, 143.5 - (111.5 * dcos((360 * _time_skull) / 0.1)), 183.5 - (71.5 * dcos((360 * _time_skull) / 0.1)));
        }
        else
        {
            _color = 7348479;
            _head_color = 7348479;
        }
        
        arg0.body.image_blend = _color;
        arg0.right_arm_top.image_blend = _color;
        arg0.right_arm_bottom.image_blend = _color;
        arg0.right_hand.image_blend = _color;
        arg0.left_arm_top.image_blend = _color;
        arg0.left_arm_bottom.image_blend = _color;
        arg0.left_hand.image_blend = _color;
        arg0.right_leg_top.image_blend = _color;
        arg0.right_leg_bottom.image_blend = _color;
        arg0.left_leg_top.image_blend = _color;
        arg0.left_leg_bottom.image_blend = _color;
        arg0.head.image_blend = _head_color;
        arg0.jaw.image_blend = _head_color;
        
        if (_time_skull < beats_to_seconds(1))
        {
            var _time_2 = ((arg0.skull_throw - arg0.SpawnTime) + arg0.offset) % beats_to_seconds(2);
            var _mult_skull = min(_time_skull / beats_to_seconds(0.3), 1);
            var _mult_2 = min(_time_2 / beats_to_seconds(0.3), 1) * (1 - _mult_skull);
            arg0.right_arm_angles[0] = (-60 * _mult_2) + (150 * _mult_skull);
            arg0.right_arm_angles[1] = (120 * _mult_2) - (230 * _mult_skull);
            arg0.right_arm_angles[2] = (-60 * _mult_2) + (10 * _mult_skull);
            arg0.head_data.jaw = 20 * _mult_2;
        }
        else if (_time_skull < beats_to_seconds(2))
        {
            var _mult_skull = min((_time_skull - beats_to_seconds(1)) / beats_to_seconds(0.3), 1);
            arg0.right_arm_angles[0] = 150 - (90 * _mult_skull);
            arg0.right_arm_angles[1] = 130;
            arg0.right_arm_angles[2] = 10 - (30 * _mult_skull);
            arg0.head_data.jaw = 0;
        }
        else if (_time_skull < beats_to_seconds(3))
        {
            var _mult_skull = min((_time_skull - beats_to_seconds(2)) / beats_to_seconds(0.3), 1);
            arg0.right_arm_angles[0] = 70 + (100 * _mult_skull);
            arg0.right_arm_angles[1] = 130 - (110 * _mult_skull);
            arg0.right_arm_angles[2] = -20 + (10 * _mult_skull);
            arg0.head_data.jaw = 20 * _mult_skull;
        }
        else if (_time_skull < beats_to_seconds(3.3))
        {
            var _time_2 = ((arg0.skull_throw - arg0.SpawnTime) + arg0.offset) % beats_to_seconds(2);
            var _mult_skull = 1 - min((_time_skull - beats_to_seconds(3)) / beats_to_seconds(0.3), 1);
            var _mult_2 = min(_time_2 / beats_to_seconds(0.3), 1) * (1 - _mult_skull);
            arg0.right_arm_angles[0] = (-60 * _mult_2) + (170 * _mult_skull);
            arg0.right_arm_angles[1] = (120 * _mult_2) - (340 * _mult_skull);
            arg0.right_arm_angles[2] = (-60 * _mult_2) - (10 * _mult_skull);
            arg0.head_data.jaw = 20;
        }
        else
        {
            arg0.right_arm_angles[0] = -arg0.left_arm_angles[0];
            arg0.right_arm_angles[1] = -arg0.left_arm_angles[1];
            arg0.right_arm_angles[2] = -arg0.left_arm_angles[2];
            
            if (_time_skull < beats_to_seconds(4))
            {
                var _mult_2 = min((4 - _time_skull) / 0.3, 1);
                arg0.head_data.jaw = 20 * _mult_2;
            }
            else if (_time_skull < beats_to_seconds(5.8))
            {
                var _time_2 = ((arg0.skull_throw - arg0.SpawnTime) + arg0.offset) % beats_to_seconds(2);
                var _mult_skull = clamp((_time_skull - beats_to_seconds(5.7)) / beats_to_seconds(0.1), 0, 1);
                var _mult_2 = min(_time_2 / beats_to_seconds(0.3), 1) * _mult_skull;
                arg0.head_data.jaw = 20 * _mult_2;
            }
            else
            {
                arg0.head_data.jaw = 20 * arg1;
                arg0.skull_throw = -1;
                arg0.skull_explode = -1;
            }
        }
        
        if (_time_skull < beats_to_seconds(2))
        {
            var _mult_skull = clamp((_time_skull - beats_to_seconds(1)) / beats_to_seconds(0.3), 0, 1);
            var _distance = 419.761;
            var _angle = 310.749345;
            var _head_angle = (_angle + 180) - (90 * _mult_skull);
            var _head_x = ((_distance * dcos(_angle)) + (_distance * dcos(_head_angle))) * arg0.image_xscale;
            var _head_y = (arg0.body_height + 638 + (_distance * dsin(_angle)) + (_distance * dsin(_head_angle))) * arg0.image_xscale;
            arg0.head_data.x = (arg0.x - (_head_y * dsin(arg0.image_angle))) + (_head_x * dcos(arg0.image_angle));
            arg0.head_data.y = arg0.y - (_head_y * dcos(arg0.image_angle)) - (_head_x * dsin(arg0.image_angle));
            arg0.head_data.angle = arg0.image_angle - (120 * _mult_skull);
        }
        else if (_time_skull < beats_to_seconds(2.3))
        {
            var _mult_skull = min((_time_skull - beats_to_seconds(2)) / beats_to_seconds(0.3), 1);
            var _distance = 419.761;
            var _distance_head = _distance + (339.044 * _mult_skull);
            var _angle = 310.749345;
            var _head_angle = _angle + 90 + (50 * _mult_skull);
            var _head_x = ((_distance * dcos(_angle)) + (_distance_head * dcos(_head_angle))) * arg0.image_xscale;
            var _head_y = (arg0.body_height + 638 + (_distance * dsin(_angle)) + (_distance_head * dsin(_head_angle))) * arg0.image_xscale;
            arg0.head_data.x = (arg0.x - (_head_y * dsin(arg0.image_angle))) + (_head_x * dcos(arg0.image_angle));
            arg0.head_data.y = arg0.y - (_head_y * dcos(arg0.image_angle)) - (_head_x * dsin(arg0.image_angle));
            arg0.head_data.angle = (arg0.image_angle - 120) + (120 * _mult_skull);
        }
        else if (_time_skull < beats_to_seconds(4))
        {
            var _mult_skull = (_time_skull - beats_to_seconds(2.3)) / beats_to_seconds(1.7);
            var _time_2 = ((arg0.skull_throw - arg0.SpawnTime) + arg0.offset) % beats_to_seconds(2);
            var _mult_2 = 1 - (min(_time_2 / beats_to_seconds(0.3), 1) * clamp((beats_to_seconds(1.3) - _time_2) / beats_to_seconds(0.3), 0, 1));
            var _distance = 419.761;
            var _distance_head = 758.805;
            var _angle = 310.749345;
            var _head_angle = _angle + 140;
            var _head_x = ((_distance * dcos(_angle)) + (_distance_head * dcos(_head_angle))) * arg0.image_xscale * (1 - (_mult_skull / 2));
            var _head_y = ((2090 - (455 * _mult_2)) + (((2000 - (1000 * (arg0.skull_explode >= 0))) + (455 * _mult_2)) * dsin(90 * _mult_skull)) + (_distance * dsin(_angle)) + (_distance_head * dsin(_head_angle))) * arg0.image_xscale;
            arg0.head_data.x = (arg0.x - (_head_y * dsin(arg0.image_angle))) + (_head_x * dcos(arg0.image_angle));
            arg0.head_data.y = arg0.y - (_head_y * dcos(arg0.image_angle)) - (_head_x * dsin(arg0.image_angle));
            arg0.head_data.angle = arg0.image_angle + (180 * _mult_skull);
        }
        else if (_time_skull < beats_to_seconds(5.7))
        {
            var _mult_skull = (_time_skull - beats_to_seconds(4)) / beats_to_seconds(1.7);
            var _time_2 = ((arg0.skull_throw - arg0.SpawnTime) + arg0.offset) % beats_to_seconds(2);
            var _mult_2 = min(_time_2 / beats_to_seconds(0.3), 1) * clamp((beats_to_seconds(1.3) - _time_2) / beats_to_seconds(0.3), 0, 1);
            var _distance = 419.761;
            var _distance_head = 758.805;
            var _angle = 310.749345;
            var _head_angle = _angle + 140;
            var _head_x = ((_distance * dcos(_angle)) + (_distance_head * dcos(_head_angle))) * arg0.image_xscale * (0.5 - (_mult_skull / 2));
            var _head_y = ((2090 - (455 * _mult_2 * (1 - dcos(90 * _mult_skull)))) + (((2000 - (1000 * (arg0.skull_explode >= 0))) + (_distance * dsin(_angle)) + (_distance_head * dsin(_head_angle))) * dcos(90 * _mult_skull))) * arg0.image_xscale;
            arg0.head_data.x = (arg0.x - (_head_y * dsin(arg0.image_angle))) + (_head_x * dcos(arg0.image_angle));
            arg0.head_data.y = arg0.y - (_head_y * dcos(arg0.image_angle)) - (_head_x * dsin(arg0.image_angle));
            arg0.head_data.angle = arg0.image_angle + 180 + (180 * _mult_skull);
        }
        else
        {
            var _head_y = (arg0.body_height + 638) * arg0.image_xscale;
            arg0.head_data.x = arg0.x - (_head_y * dsin(arg0.image_alpha));
            arg0.head_data.y = arg0.y - (_head_y * dcos(arg0.image_angle));
            arg0.head_data.angle = arg0.image_angle;
        }
    }
    else
    {
        arg0.right_arm_angles[0] = -arg0.left_arm_angles[0];
        arg0.right_arm_angles[1] = -arg0.left_arm_angles[1];
        arg0.right_arm_angles[2] = -arg0.left_arm_angles[2];
        var _head_y = (arg0.body_height + 638) * arg0.image_xscale;
        arg0.head_data.x = arg0.x - (_head_y * dsin(arg0.image_alpha));
        arg0.head_data.y = arg0.y - (_head_y * dcos(arg0.image_angle));
        arg0.head_data.angle = arg0.image_angle;
        arg0.head_data.jaw = 20 * arg1;
    }
    
    arg0.left_leg_bottom.image_angle = arg0.image_angle + arg0.leg_angles[0];
    arg0.right_leg_bottom.image_angle = arg0.image_angle - arg0.leg_angles[0];
    arg0.left_leg_top.image_angle = arg0.left_leg_bottom.image_angle + arg0.leg_angles[1];
    arg0.right_leg_top.image_angle = arg0.right_leg_bottom.image_angle - arg0.leg_angles[1];
    arg0.left_arm_top.image_angle = arg0.image_angle + arg0.left_arm_angles[0];
    arg0.right_arm_top.image_angle = arg0.image_angle + arg0.right_arm_angles[0];
    arg0.left_arm_bottom.image_angle = arg0.left_arm_top.image_angle + arg0.left_arm_angles[1];
    arg0.right_arm_bottom.image_angle = arg0.right_arm_top.image_angle + arg0.right_arm_angles[1];
    arg0.left_hand.image_angle = arg0.left_arm_bottom.image_angle + arg0.left_arm_angles[2];
    arg0.right_hand.image_angle = arg0.right_arm_bottom.image_angle + arg0.right_arm_angles[2];
    arg0.body.image_angle = arg0.image_angle;
    arg0.head.image_angle = arg0.head_data.angle;
    arg0.jaw.image_angle = arg0.head_data.angle;
    var _body_y = arg0.body_height * arg0.image_xscale;
    arg0.body.x = arg0.x - (_body_y * dsin(arg0.image_angle));
    arg0.body.y = arg0.y - (_body_y * dcos(arg0.image_angle));
    var _leg_bottom_x = 497 * dsin(arg0.left_leg_bottom.image_angle) * arg0.image_xscale;
    var _leg_bottom_y = 497 * dcos(arg0.left_leg_bottom.image_angle) * arg0.image_xscale;
    var _leg_top_x = 497 * dsin(arg0.left_leg_top.image_angle) * arg0.image_xscale;
    var _leg_top_y = 497 * dcos(arg0.left_leg_top.image_angle) * arg0.image_xscale;
    var _leg_x_offset = 190 * dcos(arg0.image_angle) * arg0.image_xscale;
    var _leg_y_offset = -190 * dsin(arg0.image_angle) * arg0.image_xscale;
    arg0.left_leg_bottom.x = arg0.x - _leg_x_offset - (_leg_bottom_x / 2);
    arg0.left_leg_bottom.y = arg0.y - _leg_y_offset - (_leg_bottom_y / 2);
    arg0.right_leg_bottom.x = arg0.x + _leg_x_offset + (_leg_bottom_x / 2);
    arg0.right_leg_bottom.y = (arg0.y + _leg_y_offset) - (_leg_bottom_y / 2);
    arg0.left_leg_top.x = arg0.left_leg_bottom.x - (_leg_bottom_x / 2) - (_leg_top_x / 2);
    arg0.left_leg_top.y = arg0.left_leg_bottom.y - (_leg_bottom_y / 2) - (_leg_top_y / 2);
    arg0.right_leg_top.x = arg0.right_leg_bottom.x + (_leg_bottom_x / 2) + (_leg_top_x / 2);
    arg0.right_leg_top.y = arg0.right_leg_bottom.y - (_leg_bottom_y / 2) - (_leg_top_y / 2);
    var _left_arm_top_x = 442 * dsin(arg0.left_arm_top.image_angle) * arg0.image_xscale;
    var _left_arm_top_y = 442 * dcos(arg0.left_arm_top.image_angle) * arg0.image_xscale;
    var _left_arm_bottom_x = 323 * dsin(arg0.left_arm_bottom.image_angle) * arg0.image_xscale;
    var _left_arm_bottom_y = 323 * dcos(arg0.left_arm_bottom.image_angle) * arg0.image_xscale;
    var _left_hand_x = ((40 * dcos(arg0.left_hand.image_angle)) + (157 * dsin(arg0.left_hand.image_angle))) * arg0.image_xscale;
    var _left_hand_y = ((157 * dcos(arg0.left_hand.image_angle)) - (40 * dsin(arg0.left_hand.image_angle))) * arg0.image_xscale;
    var _right_arm_top_x = 442 * dsin(arg0.right_arm_top.image_angle) * arg0.image_xscale;
    var _right_arm_top_y = 442 * dcos(arg0.right_arm_top.image_angle) * arg0.image_xscale;
    var _right_arm_bottom_x = 323 * dsin(arg0.right_arm_bottom.image_angle) * arg0.image_xscale;
    var _right_arm_bottom_y = 323 * dcos(arg0.right_arm_bottom.image_angle) * arg0.image_xscale;
    var _right_hand_x = ((-40 * dcos(arg0.right_hand.image_angle)) + (157 * dsin(arg0.right_hand.image_angle))) * arg0.image_xscale;
    var _right_hand_y = ((157 * dcos(arg0.right_hand.image_angle)) - (40 * dsin(arg0.right_hand.image_angle))) * arg0.image_xscale;
    var _arm_x_offset = ((274 * dcos(arg0.image_angle)) + (320 * dsin(arg0.image_angle))) * arg0.image_xscale;
    var _arm_y_offset = ((320 * dcos(arg0.image_angle)) - (274 * dsin(arg0.image_angle))) * arg0.image_xscale;
    arg0.left_arm_top.x = (arg0.body.x - _arm_x_offset) + (_left_arm_top_x / 2);
    arg0.left_arm_top.y = (arg0.body.y - _arm_y_offset) + (_left_arm_top_y / 2);
    arg0.left_arm_bottom.x = arg0.left_arm_top.x + (_left_arm_top_x / 2) + (_left_arm_bottom_x / 2);
    arg0.left_arm_bottom.y = arg0.left_arm_top.y + (_left_arm_top_y / 2) + (_left_arm_bottom_y / 2);
    arg0.left_hand.x = arg0.left_arm_bottom.x + (_left_arm_bottom_x / 2) + (_left_hand_x / 2);
    arg0.left_hand.y = arg0.left_arm_bottom.y + (_left_arm_bottom_y / 2) + (_left_hand_y / 2);
    arg0.right_arm_top.x = arg0.body.x + _arm_x_offset + (_right_arm_top_x / 2);
    arg0.right_arm_top.y = (arg0.body.y - _arm_y_offset) + (_right_arm_top_y / 2);
    arg0.right_arm_bottom.x = arg0.right_arm_top.x + (_right_arm_top_x / 2) + (_right_arm_bottom_x / 2);
    arg0.right_arm_bottom.y = arg0.right_arm_top.y + (_right_arm_top_y / 2) + (_right_arm_bottom_y / 2);
    arg0.right_hand.x = arg0.right_arm_bottom.x + (_right_arm_bottom_x / 2) + (_right_hand_x / 2);
    arg0.right_hand.y = arg0.right_arm_bottom.y + (_right_arm_bottom_y / 2) + (_right_hand_y / 2);
    arg0.head.x = arg0.head_data.x - (20 * dsin(arg0.head_data.angle) * arg0.image_xscale);
    arg0.head.y = arg0.head_data.y - (20 * dcos(arg0.head_data.angle) * arg0.image_xscale);
    arg0.jaw.x = arg0.head_data.x + ((145 + arg0.head_data.jaw) * dsin(arg0.head_data.angle) * arg0.image_xscale);
    arg0.jaw.y = arg0.head_data.y + ((145 + arg0.head_data.jaw) * dcos(arg0.head_data.angle) * arg0.image_xscale);
}
function set_level_scroll(arg0, arg1)
{
    Scroll.x = arg0;
    Scroll.y = arg1;
}
function set_level_wobble(_time, _distance, _strength){
	Scroll.time = _time;
	Scroll.range = _distance;
	Scroll.offset = _strength;
}
function set_level_tilt(_time, _angle, _speed){
	Scroll.angle = _angle
	Scroll.angle_time = _time
	Scroll.angle_speed = _speed
}
function set_level_position(_x, _y){
	Camera.x = _x;
	Camera.y = _y;
}
function get_level_position(){
	return Camera;
}
function get_level_scroll(){
	return Scroll
}
#endregion
#region Adding function to Catspeak
Catspeak.applyPreset(CatspeakPreset.ARRAY);
Catspeak.applyPreset(CatspeakPreset.MATH);
Catspeak.applyPreset(CatspeakPreset.RANDOM);
Catspeak.applyPreset(CatspeakPreset.TYPE);
Catspeak.interface.exposeFunction("beats_to_seconds", beats_to_seconds);
Catspeak.interface.exposeFunction("update_skeleton", update_skeleton);
Catspeak.interface.exposeConstant("Players", PlayerInstances);
Catspeak.interface.exposeConstant("spr_pixel", spr_pixel);
Catspeak.interface.exposeConstant("c_pink", c_pink);
Catspeak.interface.exposeFunction("get_songtime", getSongtime);
Catspeak.interface.exposeFunction("get_loops", getLoops);
Catspeak.interface.exposeFunction("create_bullet", createbullet);
Catspeak.interface.exposeFunction("create_background", createbackground);
Catspeak.interface.exposeFunction("create_model", createmodel);
Catspeak.interface.exposeFunction("draw_sprite_ext", draw_sprite_ext);
Catspeak.interface.exposeFunction("init_event", declareInit);
Catspeak.interface.exposeFunction("update_event", declareUpdate);
Catspeak.interface.exposeFunction("draw_event", declareDraw);
Catspeak.interface.exposeFunction("rewind_event", declareRewind);
Catspeak.interface.exposeFunction("draw_clear_alpha", draw_clear_alpha);
Catspeak.interface.exposeFunction("make_color_hsv", make_color_hsv);
Catspeak.interface.exposeFunction("make_color_rgb", make_color_rgb);
Catspeak.interface.exposeFunction("kill_bullet", killBullet);
Catspeak.interface.exposeFunction("get_players", getPlayers);
Catspeak.interface.exposeFunction("get_sprite", getSprite);
Catspeak.interface.exposeFunction("get_model", getModel);
Catspeak.interface.exposeFunction("play_sound", playSound);
Catspeak.interface.exposeFunction("volume_sound", volumeSound);
Catspeak.interface.exposeFunction("set_level", setLevel);
Catspeak.interface.exposeFunction("show_message", show_message);
Catspeak.interface.exposeFunction("instance_exists", instance_exists);
Catspeak.interface.exposeFunction("show_debug_message", show_debug_message);
Catspeak.interface.exposeFunction("set_level_scroll", set_level_scroll);
Catspeak.interface.exposeFunction("get_level_scroll", get_level_scroll);
Catspeak.interface.exposeFunction("set_level_wobble", set_level_wobble);
Catspeak.interface.exposeFunction("set_level_tilt", set_level_tilt);
Catspeak.interface.exposeFunction("set_level_position", set_level_position);
Catspeak.interface.exposeFunction("get_level_position", get_level_position);
Catspeak.interface.exposeFunction("create_obb_collision", ColOBBObject);
#endregion