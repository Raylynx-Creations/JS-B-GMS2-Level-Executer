if (false and !Created){
	Dead_Players = false;
	array_delete(PlayerInstances,0,array_length(PlayerInstances));
	if (variable_struct_names_count(Sounds) > 0){
		var names = variable_struct_get_names(Sounds);
		for (var i=0;i<array_length(names);i++){
			audio_destroy_stream(variable_struct_get(Sounds, names[i]));
			variable_struct_remove(Sounds, names[i]);
		}
	}
	if (variable_struct_names_count(Music) > 0){
		var names = variable_struct_get_names(Music);
		for (var i=0;i<array_length(names);i++){
			//To be done
			variable_struct_remove(Music, names[i]);
		}
	}
	if (variable_struct_names_count(Sprites) > 0){
		var names = variable_struct_get_names(Sprites);
		for (var i=0;i<array_length(names);i++){
			sprite_delete(variable_struct_get(Sprites, names[i]).sprite);
			variable_struct_remove(Sprites, names[i]);
		}
	}
	state = menu.returning;
	timer = 0;
	//selecting[1] = 0; //remove
	//data = []; //remove
	selecting[0] = selected;
	selecting[2] = selecting[1];
	draw_set_font(fnt_nexaBold90);
	for (var i=selecting[1]/84;i<min(array_length(Levels),10 + selecting[1]/84);i++){
		Songs[i] = {x: 0, y: 84*i - selecting[1], pos: i, selected: false, song_index: 0, song_amount: Levels[i].song_amount, scroll: {based: 0.2*string_width("recreated by " + Levels[i].recreated_by[0]) - 280, artist: 0.2*string_width(((Levels[i].song_type[0]) ? Levels[i].song_type[0] + " by " : "by ") + Levels[i].artist[0][0]) - 405, song: 0.3*string_width(Levels[i].song[0]) - 405, creator: 0.3*string_width(Levels[i].level_by[0]) - 280, timer: [0, 0, 0, 0]}, info: Levels[i]};
	}
	texture_prefetch("tex_grp_menu");
	texture_prefetch("tex_grp_ranking");
	music = audio_play_sound(mus_menu,100,true,0);
	audio_pause_sound(music);
}else{ if (room == rm_level){
	Dead_Players = false;
	PlayerCreated = false;
	Draw = -1;
	levelBG = c_black;
	SongTime = 0;
	currentCheckpoint[0] = -1;
	currentCheckpoint[1] = -1;
	songtimeAboveZero = -1;
	var path = Levels[selected].dir;
	LoadSprites(path);
	Load3DModels(path);
	LoadMusic(path);
	LoadSounds(path);
	LoadScript(path);
}}