if (room == rm_level){
	switch (state){
		case level.error:
			timer++;
			if (timer == 60){
				room_goto(rm_menu);
			}
		break;
		case level.ready:
			try{
				compilation();
			}catch (e){
				show_message(e.message);
				state = level.error;
				break;
			}
			if (!PlayerCreated){
				PlayerCreated = true;
				for (var i=0;i<Players;i++){
					var colspec = make_color_hsv(PlayerData[i].hue, PlayerData[i].saturation, PlayerData[i].value);
					var jugador = instance_create_depth(246, 250 + 400/(Players + 1)*(i + 1), 0, obj_player, {control_type: PlayerData[i].control_type, control_id: PlayerData[i].control_id, zurdo: PlayerData[i].zurdo, modo: (Mode != mode.none) ? Mode : mode.shape, red: color_get_red(colspec), green: color_get_green(colspec), blue: color_get_blue(colspec), index: PlayerData[i].index})
					with (jugador){
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
					}
					array_push(PlayerInstances, jugador);
				}
			}
			if (instanceof(Init) == "function"){
				try{
					Init();
				}catch (e){
					show_message("Init: " + e.message);
				}
			}
			for (var i=0;i<Players;i++){
				var player_instance = PlayerInstances[i];
				if (instanceof(player_instance.Init) == "function"){
					try{
						player_instance.Init(player_instance);
					}catch (e){
						show_message("PlayerInstances[" + string(i) + "]: " + e.message);
					}
				}
			}
			state = level.waiting;
		break;
		case level.waiting:
			timer++;
			if (timer >= 270){
				state = level.update;
				timer = 0;
				var barSegment = barLevel.order[0];
				if (!barSegment.hidden){
					barLevel.state = levelBar.start;
					switch (barSegment.type){
						case "boss":
							barLevel.color = c_pink;
						break;
						default:
							barLevel.color = c_cyan;
						break;
					}
					barLevel.timer = 0;
				}
				indice = barSegment.musicIndex;
				var item = Levels[selected];
				currentTrack = item.song[indice] + " by " + item.artist[indice][0];
				var track = Music[$ currentTrack];
				if (array_length(barSegment.musicLoop) > 0){
					audio_sound_loop_start(track[0], barSegment.musicLoop[0].staticStart);
					audio_sound_loop_end(track[0], barSegment.musicLoop[0].staticFinish);
				}
				music = audio_play_sound(track[0], 100, (array_length(barSegment.musicLoop) > 0));
				if (barSegment.start > 0){
					audio_sound_set_track_position(music, barSegment.start);
				}
				songtimeAboveZero = barSegment.finish;
				songDuration = songtimeAboveZero - barSegment.start;
				positionTrack = 0;
				skip = 0;
				//segSkip = 0;
				//segIndice = 0;
				//segLooping = 0;
				segment = 0;
				looping = 0;
				inLoop = false;
				segInLoop = false;
				result = false;
				isSilence = false;
			}
		break;
		case level.update:
			var length = array_length(barLevel.order);
			//var isSilence = (audio_get_name(music) == "mus_silence");
			var notPlaying = (!audio_is_playing(music) and !isSilence);
			var item = barLevel.order[barLevel.index.music];
			var length2 = array_length(item.musicSegments);
			var temp = 0;
			if (!notPlaying){
				SongTime = (isSilence ? songtimeAboveZero : 0) + audio_sound_get_track_position(music);
			}else{
				SongTime = songtimeAboveZero + 6;
			}
			var tempSeg = undefined;
			if (barLevel.stuck == -1){
				if (segment < length2 and SongTime >= item.musicSegments[segment].segmentStart and !inLoop){
					var seg = item.musicSegments[segment];
					var segBar = seg.segmentBars;
					barLevel.stuck = seg.segmentStart;
					barLevel.tempStuck = barLevel.stuck;
					barLevel.staticStuck = barLevel.stuck;
					segmentBar.anim = 0;
					segmentBar.damage = seg.damage;
					if (segmentBar.damage > 0){
						segmentBar.damaged = false;
						segmentBar.damageTimer = 0;
						segmentBar.condition = seg.condition;
					}
					segmentBar.player = seg.player;
					segmentBar.playerColor = seg.playerColor;
					segmentBar.index.visual = 0;
					segmentBar.index.music = 0;
					segmentBar.order = segBar;
					segIndice = segmentBar.order[0].musicIndex;
					segSkip = 0;
					segLooping = 0;
					segInLoop = false;
					tempSeg = seg.segmentStart - segBar[0].start;
					var length3 = array_length(Checkpoints);
					for (var i=0; i<length3; i++){
						Checkpoints[i].offset += tempSeg;
					}
					var item2 = Levels[selected];
					var indexx = segBar[0].musicIndex;
					currentTrack = item2.song[indexx] + " by " + item2.artist[indexx][0];
					var track = Music[$ currentTrack];
					if (!notPlaying){
						audio_stop_sound(music);
					}
					length3 = array_length(segBar[0].musicLoop);
					if (length3 > 0){
						audio_sound_loop_start(track[0], segBar[0].musicLoop[0].staticStart);
						audio_sound_loop_end(track[0], segBar[0].musicLoop[0].staticFinish);
					}
					music = audio_play_sound(track[0], 100, (length3 > 0));
					songtimeAboveZero = segBar[0].finish;
					if (segBar[0].start > 0){
						temp = segBar[0].start;
						audio_sound_set_track_position(music, segBar[0].start);
					}
					if (indexx != item.musicIndex){
						var from = item2.from;
						var song_type = item2.song_type;
						if (!is_undefined(from)){
							from = from[indexx];
						}
						if (!is_undefined(song_type)){
							song_type = song_type[indexx];
						}
						ShowSongTitle(string_upper(item2.song[indexx]), item2.artist[indexx], from, song_type);
					}
					notPlaying = !audio_is_playing(music);
					if (!notPlaying){
						SongTime = (isSilence ? songtimeAboveZero : 0) + max(audio_sound_get_track_position(music), segBar[0].start, temp);
					}else{
						SongTime = songtimeAboveZero + 6;
					}
					segment++;
				}
				length2 = array_length(item.musicSkip);
				while (skip < length2 and ((barLevel.stuck == -1) ? SongTime : barLevel.stuck) >= item.musicSkip[skip]){
					var _start = item.musicSkip[skip];
					var _end = item.musicSkip[skip + 1];
					if (max(audio_sound_get_track_position(music), item.start) < _end and barLevel.stuck == -1){
						temp = _end;
						audio_stop_sound(music);
						var track = Music[$ currentTrack];
						var length3 = array_length(item.musicLoop)
						music = audio_play_sound(track[0], 100, (length3 > 0 and looping < length3));
						audio_sound_set_track_position(music, _end);
					}
					var length3 = array_length(Checkpoints);
					for (var i=0; i<length3; i++){
						Checkpoints[i].offset -= _end - _start;
					}
					length3 = array_length(item.events);
					for (var i=0; i<length3; i++){
						var event = item.events[i];
						event.time += _end - _start;
						if (variable_struct_exists(event, "finish")){
							event.finish += _end - _start;
						}
						if (variable_struct_exists(event, "offset") and _end < event.finish + event.offset){
							event.offset -= _end - _start;
						}
					}
					length3 = array_length(item.musicLoop);
					for (var i=0; i<length3; i++){
						var event = item.musicLoop[i];
						event.start += _end - _start;
						event.finish += _end - _start;
						if (_end < event.finish + event.offset){
							event.offset -= _end - _start;
						}
					}
					item.start += _end - _start;
					item.offset += _end - _start;
					barLevel.stunned.start += _end - _start;
					skip += 2;
				}
			}
			var segItem = 0;
			if (barLevel.stuck == -1){
				length2 = array_length(item.musicLoop);
				if (looping < length2 and SongTime >= item.musicLoop[looping].staticStart){
					var result = false;
					try{
						result = item.musicLoop[looping].condition();
					}catch (e){
						show_message(e.message);
						state = level.error;
					}
					if (result and item.musicLoop[looping].eject == -1){
						item.musicLoop[looping].timer = 2;
						looping++;
						if (looping < length2){
							var track = Music[$ currentTrack];
							audio_sound_loop_start(track[0], item.musicLoop[looping].staticStart);
							audio_sound_loop_end(track[0], item.musicLoop[looping].staticFinish);
						}else{
							audio_sound_loop(music, false);
						}
						inLoop = false;
						if (barLevel.loop.enabled){
							barLevel.loop.enabled = false;
						}
					}else{
						inLoop = true;
						if (!barLevel.loop.enabled and item.musicLoop[looping].message != ""){
							barLevel.loop.message = item.musicLoop[looping].message;
							barLevel.loop.color = (item.musicLoop[looping].damage > 0) ? c_pink : c_cyan;
							barLevel.loop.timer = 0;
							barLevel.loop.enabled = true;
						}
						if (item.musicLoop[looping].timer < 1){
							item.musicLoop[looping].timer = min(item.musicLoop[looping].timer + delta_time/1000000, 1);
						}
					}
				}
				if (inLoop){
					if (SongTime < item.musicLoop[looping].prevSongTime and item.musicLoop[looping].eject == -1){
						item.musicLoop[looping].eject = 0;
						if (item.musicLoop[looping].shake){
							barLevel.shake.timer = 18;
						}
						barLevel.stunned.timer = 0;
						barLevel.stunned.damage = item.musicLoop[looping].damage > 0;
						length2 = array_length(Checkpoints);
						var _startLoop = item.musicLoop[looping].staticStart;
						var _endLoop = item.musicLoop[looping].staticFinish;
						for (var i=0; i<length2; i++){
							Checkpoints[i].offset += _endLoop - _startLoop;
						}
						if (item.musicLoop[looping].startSkip > -1){
							length2 = array_length(item.musicSkip);
							while (skip > item.musicLoop[looping].startSkip){
								skip -= 2;
								var _start = item.musicSkip[skip];
								var _end = item.musicSkip[skip + 1];
								length3 = array_length(item.events);
								for (var i=0; i<length3; i++){
									var event = item.events[i];
									if (variable_struct_exists(event, "offset") and _end < event.finish + event.offset + _end - _start){
										event.offset += _end - _start;
									}
									event.time -= _end - _start;
									if (variable_struct_exists(event, "finish")){
										event.finish -= _end - _start;
									}
								}
								length3 = array_length(item.musicLoop);
								for (var i=0; i<length3; i++){
									var event = item.musicLoop[i];
									if (_end < event.finish + event.offset + _end - _start){
										event.offset += _end - _start;
									}
									event.start -= _end - _start;
									event.finish -= _end - _start;
								}
								item.start -= _end - _start;
								item.offset -= _end - _start;
							}
						}
						barLevel.stunned.backoff = _endLoop - _startLoop;
						barLevel.stunned.start = item.musicLoop[looping].finish;
						if (barLevel.stunned.damage){
							length2 = array_length(PlayerInstances);
							for (var j=0;j<length2;j++){
								PlayerInstances[j].GetHit({x: PlayerInstances[j].x + 1, y: PlayerInstances[j].y},barLevel.stunned.damage,true,true,true,true);
							}
						}
						item.musicLoop[looping].looped++;
					}
					item.musicLoop[looping].prevSongTime = SongTime;
				}
				while (barLevel.index.music + 1 < length and (notPlaying or item.finish <= SongTime) and !inLoop){
					var prevItem = barLevel.order[barLevel.index.music];
					barLevel.index.music++;
					item = barLevel.order[barLevel.index.music];
					if (prevItem.endCheckpoint.enabled){
						array_push(Checkpoints, {time: prevItem.finish, offset: 0, special: true, damage: prevItem.endCheckpoint.damage, index: prevItem.endCheckpoint.index, barIndex: barLevel.index.music, segmentIndex: -1, reference: prevItem.endCheckpoint});
					}
					length2 = array_length(Checkpoints);
					for (var i=0;i<length2;i++){
						Checkpoints[i].offset += songtimeAboveZero - item.start;
					}
					length2 = array_length(item.musicLoop);
					if (indice != item.musicIndex){
						indice = item.musicIndex;
						var item2 = Levels[selected];
						currentTrack = item2.song[indice] + " by " + item2.artist[indice][0];
						var track = Music[$ currentTrack];
						if (!notPlaying){
							audio_stop_sound(music);
						}
						if (length2 > 0){
							audio_sound_loop_start(track[0], item.musicLoop[0].staticStart);
							audio_sound_loop_end(track[0], item.musicLoop[0].staticFinish);
						}
						music = audio_play_sound(track[0], 100, (length2 > 0));
						if (item.start > 0){
							temp = item.start;
							audio_sound_set_track_position(music, item.start);
						}
						songtimeAboveZero = item.finish;
						songDuration = songtimeAboveZero - item.start;
						var from = item2.from;
						var song_type = item2.song_type;
						if (!is_undefined(from)){
							from = from[indice];
						}
						if (!is_undefined(song_type)){
							song_type = song_type[indice];
						}
						ShowSongTitle(string_upper(item2.song[indice]), item2.artist[indice], from, song_type);
					}else{
						songtimeAboveZero = item.finish;
						var track = Music[$ currentTrack];
						if (length2 > 0){
							audio_sound_loop_start(track[0], item.musicLoop[0].staticStart);
							audio_sound_loop_end(track[0], item.musicLoop[0].staticFinish);
						}
						if (prevItem.finish != item.start){
							audio_stop_sound(music);
							temp = item.start;
							music = audio_play_sound(track[0], 100, (length2 > 0));
							audio_sound_set_track_position(music, item.start);
						}else if (length2 > 0){
							audio_sound_loop(music, true);
						}
					}
					skip = 0;
					segment = 0;
					looping = 0;
					notPlaying = !audio_is_playing(music);
					if (!notPlaying){
						SongTime = (isSilence ? songtimeAboveZero : 0) + max(audio_sound_get_track_position(music), item.start, temp);
					}else{
						SongTime = songtimeAboveZero + 6;
					}
				}
				if (barLevel.index.music + 1 == length and notPlaying and !isSilence){
					music = audio_play_sound(mus_silence, 100, false);
					length2 = array_length(Checkpoints);
					for (var i=0;i<length2;i++){
						Checkpoints[i].offset += songDuration - songtimeAboveZero;
					}
					notPlaying = false;
					isSilence = true;
					SongTime = (isSilence ? songtimeAboveZero : 0) + max(audio_sound_get_track_position(music), ((barLevel.stuck == -1) ? item.start : segItem.start), temp);
				}
			}else{
				segItem = segmentBar.order[segmentBar.index.music];
				length2 = array_length(segItem.musicSkip);
				while (segSkip < length2 and max(audio_sound_get_track_position(music), segItem.start) >= segItem.musicSkip[segSkip]){
					var _start = segItem.musicSkip[segSkip];
					var _end = segItem.musicSkip[segSkip + 1];
					if (max(audio_sound_get_track_position(music), segItem.start) < _end){
						temp = _end;
						audio_stop_sound(music);
						var track = Music[$ currentTrack];
						var length3 = array_length(segItem.musicLoop);
						music = audio_play_sound(track[0], 100, (length3 > 0 and segLooping < length3));
						audio_sound_set_track_position(music, _end);
					}
					var length3 = array_length(Checkpoints);
					for (var i=0; i<length3; i++){
						Checkpoints[i].offset -= _end - _start;
					}
					length3 = array_length(segItem.events);
					for (var i=0; i<length3; i++){ //Checar con los demas eventos sucesores
						var event = segItem.events[i];
						event.time += _end - _start;
						if (variable_struct_exists(event, "finish")){
							event.finish += _end - _start;
						}
						if (variable_struct_exists(event, "offset") and _end < event.finish + event.offset){
							event.offset -= _end - _start;
						}
					}
					length3 = array_length(segItem.musicLoop);
					for (var i=0; i<length3; i++){
						var event = segItem.musicLoop[i];
						event.start += _end - _start;
						event.finish += _end - _start;
						if (_end < event.finish + event.offset){
							event.offset -= _end - _start;
						}
					}
					segItem.start += _end - _start;
					segItem.offset += _end - _start;
					segmentBar.stunned.start += _end - _start;
					segSkip += 2;
				}
				length2 = array_length(segItem.musicLoop);
				if (segLooping < length2 and SongTime >= segItem.musicLoop[segLooping].staticStart){
					var result = false;
					try{
						result = segItem.musicLoop[segLooping].condition();
					}catch (e){
						show_message(e.message);
						state = level.error;
					}
					if (result and segItem.musicLoop[segLooping].eject == -1){
						segItem.musicLoop[segLooping].timer = 2;
						segLooping++;
						if (segLooping < length2){
							var track = Music[$ currentTrack];
							audio_sound_loop_start(track[0], segItem.musicLoop[segLooping].staticStart);
							audio_sound_loop_end(track[0], segItem.musicLoop[segLooping].staticFinish);
						}else{
							audio_sound_loop(music, false);
						}
						segInLoop = false;
						if (barLevel.loop.enabled){
							barLevel.loop.enabled = false;
						}
					}else{
						segInLoop = true;
						if (!barLevel.loop.enabled and segItem.musicLoop[segLooping].message != ""){
							barLevel.loop.message = segItem.musicLoop[segLooping].message;
							barLevel.loop.color = (segItem.musicLoop[segLooping].damage > 0) ? c_pink : c_cyan;
							barLevel.loop.timer = 0;
							barLevel.loop.enabled = true;
						}
						if (segItem.musicLoop[segLooping].timer < 1){
							segItem.musicLoop[segLooping].timer = min(segItem.musicLoop[segLooping].timer + delta_time/1000000, 1);
						}
					}
				}
				if (segInLoop){
					if (SongTime < segItem.musicLoop[segLooping].prevSongTime and segItem.musicLoop[segLooping].eject == -1){
						segItem.musicLoop[segLooping].eject = 0;
						if (segItem.musicLoop[segLooping].shake){
							segmentBar.shake.timer = 18;
						}
						segmentBar.stunned.timer = 0;
						segmentBar.stunned.damage = segItem.musicLoop[segLooping].damage > 0;
						length2 = array_length(Checkpoints);
						var _startLoop = segItem.musicLoop[segLooping].staticStart;
						var _endLoop = segItem.musicLoop[segLooping].staticFinish;
						for (var i=0; i<length2; i++){
							Checkpoints[i].offset += _endLoop - _startLoop;
						}
						if (segItem.musicLoop[segLooping].startSkip > -1){
							length2 = array_length(segItem.musicSkip);
							while (segSkip > segItem.musicLoop[segLooping].startSkip){
								segSkip -= 2;
								var _start = segItem.musicSkip[segSkip];
								var _end = segItem.musicSkip[segSkip + 1];
								length3 = array_length(segItem.events);
								for (var i=0; i<length3; i++){
									var event = segItem.events[i];
									if (variable_struct_exists(event, "offset") and _end < event.finish + event.offset + _end - _start){
										event.offset += _end - _start;
									}
									event.time -= _end - _start;
									if (variable_struct_exists(event, "finish")){
										event.finish -= _end - _start;
									}
								}
								length3 = array_length(segItem.musicLoop);
								for (var i=0; i<length3; i++){
									var event = segItem.musicLoop[i];
									if (_end < event.finish + event.offset + _end - _start){
										event.offset += _end - _start;
									}
									event.start -= _end - _start;
									event.finish -= _end - _start;
								}
								segItem.start -= _end - _start;
								segItem.offset -= _end - _start;
							}
						}
						segmentBar.stunned.backoff = _endLoop - _startLoop;
						segmentBar.stunned.start = segItem.musicLoop[segLooping].finish;
						if (segmentBar.stunned.damage){
							length2 = array_length(PlayerInstances);
							for (var j=0;j<length2;j++){
								PlayerInstances[j].GetHit({x: PlayerInstances[j].x + 1, y: PlayerInstances[j].y},segmentBar.stunned.damage,true,true,true,true);
							}
						}
						segItem.musicLoop[segLooping].looped++;
					}
					segItem.musicLoop[segLooping].prevSongTime = SongTime;
				}
				length2 = array_length(segmentBar.order);
				while (segmentBar.index.music + 1 <= length2 and (notPlaying or segItem.finish <= SongTime) and !segInLoop){
					if (segmentBar.index.music + 1 == length2){
						segmentBar.index.music++;
						var seg = item.musicSegments[segment - 1];
						var segBar = seg.segmentBars;
						barLevel.stuck = -1;
						tempSeg = segBar[segmentBar.index.music - 1].finish - seg.segmentStart;
						var length3 = array_length(Checkpoints);
						for (var i=0; i<length3; i++){
							Checkpoints[i].offset += tempSeg;
						}
						var item2 = Levels[selected];
						var indexx = item.musicIndex;
						currentTrack = item2.song[indexx] + " by " + item2.artist[indexx][0];
						var track = Music[$ currentTrack];
						if (!notPlaying){
							audio_stop_sound(music);
						}
						length3 = array_length(item.musicLoop);
						if (length3 > 0 and looping < length3){
							audio_sound_loop_start(track[0], item.musicLoop[looping].staticStart);
							audio_sound_loop_end(track[0], item.musicLoop[looping].staticFinish);
						}
						music = audio_play_sound(track[0], 100, (length3 > 0 and looping < length3));
						if (seg.segmentStart > 0){
							temp = seg.segmentStart;
							audio_sound_set_track_position(music, seg.segmentStart);
						}
						songtimeAboveZero = item.finish;
						if (indexx != segBar[segmentBar.index.music - 1].musicIndex and seg.showSongTitleBack){
							var from = item2.from;
							var song_type = item2.song_type;
							if (!is_undefined(from)){
								from = from[indexx];
							}
							if (!is_undefined(song_type)){
								song_type = song_type[indexx];
							}
							ShowSongTitle(string_upper(item2.song[indexx]), item2.artist[indexx], from, song_type);
						}
						notPlaying = !audio_is_playing(music);
					}else{
						var prevSegItem = segmentBar.order[segmentBar.index.music];
						segmentBar.index.music++;
						segItem = segmentBar.order[segmentBar.index.music];
						if (prevSegItem.endCheckpoint.enabled){
							array_push(Checkpoints, {time: prevSegItem.finish, offset: 0, special: true, damage: prevSegItem.endCheckpoint.damage, index: prevSegItem.endCheckpoint.index, barIndex: barLevel.index.music, segmentID: segment - 1, segmentIndex: segmentBar.index.music, reference: prevSegItem.endCheckpoint});
						}
						length2 = array_length(Checkpoints);
						for (var i=0;i<length2;i++){
							Checkpoints[i].offset += songtimeAboveZero - segItem.start;
						}
						length2 = array_length(segItem.musicLoop);
						if (segIndice != segItem.musicIndex){
							segIndice = segItem.musicIndex;
							var item2 = Levels[selected];
							currentTrack = item2.song[segIndice] + " by " + item2.artist[segIndice][0];
							var track = Music[$ currentTrack];
							if (!notPlaying){
								audio_stop_sound(music);
							}
							if (length2 > 0){
								audio_sound_loop_start(track[0], segItem.musicLoop[0].staticStart);
								audio_sound_loop_end(track[0], segItem.musicLoop[0].staticFinish);
							}
							music = audio_play_sound(track[0], 100, (length2 > 0));
							if (segItem.start > 0){
								temp = segItem.start;
								audio_sound_set_track_position(music, segItem.start);
							}
							songtimeAboveZero = segItem.finish;
							songDuration = songtimeAboveZero - segItem.start;
							var from = item2.from;
							var song_type = item2.song_type;
							if (!is_undefined(from)){
								from = from[segIndice];
							}
							if (!is_undefined(song_type)){
								song_type = song_type[segIndice];
							}
							ShowSongTitle(string_upper(item2.song[segIndice]), item2.artist[segIndice], from, song_type);
						}else{
							songtimeAboveZero = segItem.finish;
							var track = Music[$ currentTrack];
							if (length2 > 0){
								audio_sound_loop_start(track[0], segItem.musicLoop[0].staticStart);
								audio_sound_loop_end(track[0], segItem.musicLoop[0].staticFinish);
							}
							if (prevSegItem.finish != segItem.start){
								audio_stop_sound(music);
								temp = segItem.start;
								music = audio_play_sound(track[0], 100, (length2 > 0));
								audio_sound_set_track_position(music, segItem.start);
							}else if (length2 > 0){
								audio_sound_loop(music, true);
							}
						}
						segSkip = 0;
						segLooping = 0;
						notPlaying = !audio_is_playing(music);
					}
					if (!notPlaying){
						SongTime = (isSilence ? songtimeAboveZero : 0) + max(audio_sound_get_track_position(music), ((barLevel.stuck == -1) ? item.start : segItem.start), temp);
					}else{
						SongTime = songtimeAboveZero + 6;
					}
				}
			}
			if (barLevel.stuck != -1 and segmentBar.damage > 0 and segmentBar.damageTimer == 0){
				var result = false;
				try{
					result = segmentBar.condition();
				}catch (e){
					show_message(e.message);
					state = level.error;
				}
				if (result){
					segmentBar.damageTimer += delta_time/(1000000/60);
				}
			}else if (segmentBar.damageTimer > 0){
				segmentBar.damageTimer += delta_time/(1000000/60);
			}
			if (array_length(segmentBar.order) > 0){
				segItem = segmentBar.order[segmentBar.index.visual];
			}
			var timeSong = (barLevel.stuck == -1) ? SongTime : barLevel.stuck;
			item = barLevel.order[barLevel.index.visual];
			if (!Dead_Players and !barLevel.endCreated){
				if (((item.finish <= timeSong and barLevel.stuck == -1 and !inLoop) or barLevel.index.visual < barLevel.index.music) and segmentBar.index.music == array_length(segmentBar.order) and (!item.endCheckpoint.waitTriggered or item.endCheckpoint.triggered)){
					if (barLevel.index.visual + 1 < length){
						//var prevItem = barLevel.order[barLevel.index.visual];
						barLevel.index.visual++;
						item = barLevel.order[barLevel.index.visual];
						if (!item.hidden){
							switch (barLevel.state){
								case levelBar.none:
									barLevel.state = levelBar.start;
									barLevel.color = c_cyan;
									barLevel.timer = 0;
									barLevel.iconAnim = 0;
									barLevel.lock.enabled = false;
								break;
								case levelBar.track:
									if (item.extend){
										barLevel.state = levelBar.extending;
									}else{
										barLevel.state = levelBar.replacing;
									}
									length2 = array_length(item.events);
									for (var i=0;i<length2;i++){
										if (variable_struct_exists(item.events[i], "ref")){
											item.events[i].timer = item.events[i].ref.timer;
											item.events[i].anim = item.events[i].ref.anim;
											item.events[i].particles = item.events[i].ref.particles;
											if (item.events[i].name == "collectible" or item.events[i].name == "custom"){
												item.events[i].dispAnim = item.events[i].ref.dispAnim;
												if (item.events[i].name == "custom"){
													item.events[i].spriteIndex = item.events[i].ref.spriteIndex;
												}
											}
										}
									}
									barLevel.timer = 0;
									barLevel.lock.enabled = false;
								break;
								default:
									barLevel.index.visual--;
								break;
							}
						}else if (barLevel.state == levelBar.track){
							barLevel.state = levelBar.finish;
							barLevel.timer = 0;
						}else if (barLevel.state != levelBar.none and barLevel.state != levelBar.finish){
							barLevel.index.visual--;
						}
					}else if (!barLevel.endCreated){
						array_push(Checkpoints, {time: isSilence ? songtimeAboveZero : item.finish, offset: 0, reference: "END"});
						barLevel.endCreated = true;
					}
				}else if (barLevel.state == levelBar.track and barLevel.stuck != -1){
					if (!segmentBar.order[segmentBar.index.visual].hidden){
						barLevel.state = levelBar.sectionStart;
					}else{
						barLevel.state = levelBar.sectionStartHidden;
					}
					barLevel.timer = 0;
					segmentBar.lock.enabled = false;
				}else if (barLevel.state == levelBar.none and barLevel.stuck != -1){
					if (!segmentBar.order[segmentBar.index.visual].hidden){
						barLevel.state = levelBar.sectionOnlyStart;
					}
					barLevel.timer = 0;
					segmentBar.lock.enabled = false;
				}else if (((!item.hidden and barLevel.stuck != -1 and segItem.finish <= SongTime) or barLevel.stuck == -1 or segmentBar.index.visual < segmentBar.index.music) and (segmentBar.index.visual < array_length(segmentBar.order) and (!segItem.endCheckpoint.waitTriggered or segItem.endCheckpoint.triggered))){
					length2 = array_length(segmentBar.order);
					if (segmentBar.index.visual + 1 < length2){
						//var prevSegItem = segmentBar.order[segmentBar.index.visual];
						segmentBar.index.visual++;
						segItem = segmentBar.order[segmentBar.index.visual];
						if (!segItem.hidden){
							switch (barLevel.state){
								case levelBar.sectionWaiting:
									barLevel.state = levelBar.sectionResume;
									segmentBar.color = c_cyan;
									barLevel.timer = 0;
									segmentBar.anim = 0;
									segmentBar.lock.enabled = false;
								break;
								case levelBar.section: case levelBar.sectionOnly:
									if (!item.hidden){
										if (segItem.extend){
											barLevel.state = levelBar.sectionExtending;
										}else{
											barLevel.state = levelBar.sectionReplacing;
										}
									}else{
										if (segItem.extend){
											barLevel.state = levelBar.sectionOnlyExtending;
										}else{
											barLevel.state = levelBar.sectionOnlyReplacing;
										}
									}
									length2 = array_length(segItem.events);
									for (var i=0;i<length2;i++){
										if (variable_struct_exists(segItem.events[i], "ref")){
											segItem.events[i].timer = segItem.events[i].ref.timer;
											segItem.events[i].anim = segItem.events[i].ref.anim;
											segItem.events[i].particles = segItem.events[i].ref.particles;
											if (segItem.events[i].name == "collectible" or segItem.events[i].name == "custom"){
												segItem.events[i].dispAnim = segItem.events[i].ref.dispAnim;
												if (segItem.events[i].name == "custom"){
													segItem.events[i].spriteIndex = segItem.events[i].ref.spriteIndex;
												}
											}
										}
									}
									segmentBar.color2.r = color_get_red(segmentBar.color);
									segmentBar.color2.g = color_get_green(segmentBar.color);
									segmentBar.color2.b = color_get_blue(segmentBar.color);
									switch (segItem.type){ //Move this to the new color changing
										case "boss":
											segmentBar.color3.r = 255;
											segmentBar.color3.g = 32;
											segmentBar.color3.b = 112;
										break;
										default:
											segmentBar.color3.r = 0;
											segmentBar.color3.g = 255;
											segmentBar.color3.b = 255;
										break;
									}
									barLevel.timer = 0;
									segmentBar.lock.enabled = false;
								break;
								default:
									segmentBar.index.visual--;
								break;
							}
						}else if (barLevel.state == levelBar.section){
							barLevel.state = levelBar.sectionSuspend;
							barLevel.timer = 0;
						}else if (barLevel.state == levelBar.sectionOnly){
							barLevel.state = levelBar.sectionOnlySuspend;
							barLevel.timer = 0;
						}else if (barLevel.state != levelBar.sectionWaiting and barLevel.state != levelBar.sectionSuspend){
							segmentBar.index.visual--;
						}
					}else if (barLevel.state == levelBar.section){
						barLevel.state = levelBar.sectionEnd;
						barLevel.timer = 0;
					}else if (barLevel.state == levelBar.sectionWaiting){
						barLevel.state = levelBar.sectionOut;
						barLevel.timer = 0;
					}else if (barLevel.state == levelBar.sectionOnly){
						barLevel.state = levelBar.sectionOnlyEnd;
						barLevel.timer = 0;
					}
				}
			}
			if (!notPlaying){
				SongTime = (isSilence ? songtimeAboveZero : 0) + max(audio_sound_get_track_position(music), ((barLevel.stuck == -1) ? item.start : segItem.start), temp);
			}else{
				SongTime = songtimeAboveZero + 6;
			}
			switch (barLevel.state){
				case levelBar.sectionEnd:
					if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
						barLevel.tempStuck = barLevel.staticStuck + (SongTime - barLevel.staticStuck)*(0.5 - 0.5*dcos(clamp(9*(barLevel.timer - 170), 0, 180)));
					}else{
						barLevel.tempStuck = barLevel.staticStuck + (SongTime - barLevel.staticStuck)*(0.5 - 0.5*dcos(clamp(9*(barLevel.timer - 140), 0, 180)));
					}
				break;
				case levelBar.sectionOut:
					if (segmentBar.damage > 0 and segmentBar.damageTimer == 0){
						barLevel.tempStuck = barLevel.staticStuck + (SongTime - barLevel.staticStuck)*(0.5 - 0.5*dcos(clamp(9*(barLevel.timer - 20), 0, 180)));
					}else{
						barLevel.tempStuck = barLevel.staticStuck + (SongTime - barLevel.staticStuck)*(0.5 - 0.5*dcos(clamp(9*(barLevel.timer - 10), 0, 180)));
					}
				break;
			}
			if (timer > 0){ //Check functions to not flicker the progress bar on 0's
				var step = delta_time/(1000000/60);
				timer += step;
				pitch = max(80 - timer, 1)/80;
				audio_sound_pitch(music, pitch);
				if (timer >= 80){
					state = level.rewind;
					timer = 0;
					glitch.state = 1;
					if (isSilence){
						audio_sound_set_track_position(music, 6 - ((notPlaying) ? 6 : audio_sound_get_track_position(music)));
					}else{
						positionTrack = audio_sound_get_track_position(music);
					}
				}
			}
			Dead_Players = true;
			length = array_length(PlayerInstances);
			for (var i=0;i<length;i++){
				if (!PlayerInstances[i].murio){
					Dead_Players = false;
					break;
				}
			}
			if (Dead_Players and timer == 0){
				var step = delta_time/(1000000/60);
				timer += step;
				pitch = max(80 - timer, 1)/80;
				audio_sound_pitch(music, pitch);
				if (timer >= 80){
					state = level.rewind;
					timer = 0;
					glitch.state = 1;
					if (isSilence){
						audio_sound_set_track_position(music, 6 - ((notPlaying) ? 6 : audio_sound_get_track_position(music)));
					}else{
						positionTrack = audio_sound_get_track_position(music);
					}
				}
				death.timer = 0;
				death.color = c_pink;
			}
			var fun = function(a,b){
				if (a.depth - b.depth >= 0){
					return 1;
				}else{
					return -1;
				}
			}
			array_sort(Bullets.Alive, fun);
			array_sort(Background.Alive, fun);
			length = array_length(Checkpoints);
			for (var i=0;i<length;i++){
				var event = Checkpoints[i];
				var position = 1600 - 360*(SongTime + event.offset - event.time);
				var collected = false;
				length2 = array_length(PlayerInstances);
				for (var j=0;j<length2;j++){
					var offset = 0;
					switch (PlayerInstances[j].modo){
						case mode.shape:
							offset = 8;
						break;
						case mode.helicopter:
							offset = 23;
						break;
					}
					if (PlayerInstances[j].x + offset >= position and !PlayerInstances[j].murio){
						collected = true;
						if (!is_string(event.reference) and event.reference.damage != 0){
							var condition = (event.reference.damage > 0);
							PlayerInstances[j].GetHit({x: PlayerInstances[j].x + offset, y: PlayerInstances[j].y},event.reference.damage,true,condition,condition,condition);
						}
					}
				}
				if (collected){
					flash = 0;
					length2 = array_length(PlayerInstances);
					for (var j=0;j<length2;j++){
						with (PlayerInstances[j]){
							if (murio){
								maxHP = MaxHP;
								if (outsideView){
									HP = maxHP;
									if (modo == mode.shape or modo == mode.helicopter){
										x = 246;
										if (modo == mode.shape){
											y = 250 + 400/(Players + 1)*(j + 1);
										}else{
											py = 250 + 400/(Players + 1)*(j + 1);
										}
									}
								}else{
									HP = 1;
								}
								if (modo == mode.helicopter){
									handsrot = 180;
									facing = 1;
									body.x = 0;
									bounce.timer = 31;
								}
								murio = false;
								damaged = 0;
								outsideView = false;
							}else{ if (is_string(event.reference)){
								maxHP = MaxHP;
								HP = maxHP;
								//obj_game.state = level.ranking;
							}}
						}
					}
					var BGcolors = [[0,0,0], [51,0,0], [0,16,26], [1,39,49], [11,14,16], [58,35,62], [73,7,53]];
					do{
						var randomIndex = irandom(6);
						var choosedColor = make_color_rgb(BGcolors[randomIndex][0],BGcolors[randomIndex][1],BGcolors[randomIndex][2]);
					}until (levelBG != choosedColor);
					levelBG = choosedColor;
					audio_play_sound(snd_checkpoint,0,false);
					if (!is_string(event.reference)){
						barLevel.message.timer = 0;
						if (event.reference.damage > 0){
							barLevel.message.text = (!variable_struct_exists(event, "special")) ? "CHECKPOINT REACHED..." : "THIS ISN'T THE END!";
							barLevel.message.color = c_pink;
						}else if (event.reference.damage == 0){
							barLevel.message.text = (!variable_struct_exists(event, "special")) ? "CHECKPOINT REACHED" : "THERE'S MORE";
							barLevel.message.color = c_cyan;
						}else{
							barLevel.message.text = (!variable_struct_exists(event, "special")) ? "CHECKPOINT REACHED!" : "IT'S NOT OVER YET...";
							barLevel.message.color = c_green2;
						}
						if (event.reference.message != ""){
							barLevel.message.text = event.reference.message;
						}
						event.reference.triggered = true;
						currentCheckpoint[0] = event.barIndex;
						currentCheckpoint[1] = event.index;
					}
					array_delete(Checkpoints, i, 1);
					i--;
					length--;
				}
			}
			if (instanceof(Update) == "function"){
				try{
					Update(currentTrack);
				}catch (e){
					show_message(e.message);
					state = level.error;
				}
			}
			length = array_length(Background.Alive);
			for (var i=0;i<length;i++){
				with (Background.Alive[i]){
					if (instanceof(Update) == "function"){
						try{
							Update(id);
						}catch (e){
							show_message(e.message);
							obj_game.state = level.error;
						}
					}
				}
			}
			length = array_length(Bullets.Alive);
			for (var i=0;i<length;i++){
				with (Bullets.Alive[i]){
					if (instanceof(Update) == "function"){
						try{
							Update(id);
						}catch (e){
							show_message(e.message);
							obj_game.state = level.error;
						}
					}
				}
			}
			UpdateBars(tempSeg);
		break;
		case level.rewind:
			//var isSilence = (audio_get_name(music) == "mus_silence");
			var length = array_length(barLevel.order);
			var notPlaying = (!audio_is_playing(music) and !isSilence);
			while (barLevel.index.music + 1 < length and notPlaying){
				barLevel.index.music++;
				item = barLevel.order[barLevel.index.music];
				if (indice != item.musicIndex){
					indice = item.musicIndex;
					array_push(currentSong.usedIndex, indice);
					var length2 = array_length(Checkpoints);
					for (var i=0;i<length2;i++){
						Checkpoints[i].offset += songtimeAboveZero;
					}
					var item = Levels[selected];
					currentTrack = item.song[indice] + " by " + item.artist[indice][0];
					var track = Music[$ currentTrack];
					if (notPlaying){
						audio_stop_sound(music);
					}
					music = audio_play_sound(track[0], 100, false);
					songtimeAboveZero = item.finish;
					songDuration = audio_sound_length(music);
				}
				notPlaying = !audio_is_playing(music);
			}
			if (barLevel.index.music + 1 == length and notPlaying){
				music = audio_play_sound(mus_silence, 100, false);
				notPlaying = false;
			} //Do rewind for the music if multiple songs are used
			var step = delta_time/(1000000/60);
			timer += step;
			pitch = min(timer/70, 2);
			positionTrack = max(positionTrack - delta_time*pitch/1000000, 0);
			audio_sound_pitch(music, pitch);
			audio_sound_set_track_position(music, positionTrack);
			if (!notPlaying){
				SongTime = (isSilence ? songtimeAboveZero : 0) + positionTrack;
			}else{ //Check
				SongTime = 0;
			}
			var fun = function(a,b){
				if (a.depth - b.depth >= 0){
					return 1;
				}else{
					return -1;
				}
			}
			array_sort(Bullets.Alive, fun);
			array_sort(Background.Alive, fun);
			if (timer >= 140 or positionTrack == 0){
				state = level.update;
				timer = 0;
				death.timer = 0;
				death.color = c_white;
				glitch.state = 2;
				audio_stop_sound(music);
				var item = barLevel.order[max(currentCheckpoint[0], 0)];
				var indexx = item.musicIndex;
				var item2 = Levels[selected];
				currentTrack = item2.song[indexx] + " by " + item2.artist[indexx][0];
				var track = Music[$ currentTrack];
				music = audio_play_sound(track[0], 100, false);
				//move music ahead
				songtimeAboveZero = item.finish;
				songDuration = audio_sound_length(music);
				//Restart checkpoints
				var length2 = array_length(PlayerInstances);
				for (var j=0;j<length2;j++){
					with (PlayerInstances[j]){
						maxHP = MaxHP;
						HP = maxHP;
						if (modo == mode.shape or modo == mode.helicopter){
							x = 246;
							if (modo == mode.shape){
								y = 250 + 400/(Players + 1)*(j + 1);
							}else{
								py = 250 + 400/(Players + 1)*(j + 1);
							}
						}
						if (modo == mode.helicopter){
							handsrot = 180;
							facing = 1;
							body.x = 0;
							bounce.timer = 31;
						}
						murio = false;
						outsideView = false;
					}
				}
				audio_play_sound(snd_checkpoint,0,false);
				if (instanceof(Rewind) == "function"){
					try{
						Rewind();
					}catch (e){
						show_message(e.message);
						state = level.error;
					}
				}
			}
			if (instanceof(Update) == "function"){
				try{
					Update();
				}catch (e){
					show_message(e.message);
					state = level.error;
				}
			}
			var length = array_length(Bullets.Alive); 
			for (var i=0;i<length;i++){
				with (Background.Alive[i]){
					if (instanceof(Update) == "function"){
						try{
							Update(id);
						}catch (e){
							show_message(e.message);
							obj_game.state = level.error;
						}
					}
				}
			}
			length = array_length(Bullets.Alive); 
			for (var i=0;i<length;i++){
				with (Bullets.Alive[i]){
					if (instanceof(Update) == "function"){
						try{
							Update(id);
						}catch (e){
							show_message(e.message);
							obj_game.state = level.error;
						}
					}
				}
			}
			UpdateBars();
		break;
		case level.ranking:
			
		break;
		case level.finish:
			
		break;
	}
	if (glitch.state == 1){
		glitch.timer = min(glitch.timer + 1, 10);
	}else{ if (glitch.state == 2){
		glitch.timer--;
		if (glitch.timer == 0){
			glitch.state = 0;
		}
	}}
	if (glitch.timer > 0){
		if (glitch.timer <= 4){
			glitch.alpha = 1;
		}else{
			if (glitch.alpha == 0){
				glitch.alpha = irandom_range(4,10)*(irandom(40) == 6);
			}else{
				glitch.alpha--;
			}
		}
		if (glitch.timer%2 == 1 and glitch.timer < 10){
			for (var i=0;i<array_length(glitches);i++){
				glitches[i].y = irandom(900);
				glitches[i].size = irandom_range(10,84)/2;
			}
		}else{
			for (var i=0;i<array_length(glitches);i++){
				glitches[i].duration--;
				if (glitches[i].duration <= 0){
					glitches[i].y = irandom(900);
					glitches[i].vel = random_range(-2,2);
					glitches[i].size = irandom_range(10,84)/2;
					glitches[i].duration = irandom_range(10,90);
				}
				glitches[i].y += glitches[i].vel;
				}
			}
	}else{
		glitch.alpha = 0;
	}
	if (currentSong.state){
		currentSong.timer++;
		if (currentSong.timer >= 180){
			currentSong.timer = 0;
			currentSong.state = false;
		}
	}
	Camera.x = camera_get_view_x(view_camera[0]);
	Camera.y = camera_get_view_y(view_camera[0]);
}else{
	if (state == menu.waiting){
		if (audio_group_is_loaded(music_group) and audio_group_is_loaded(sound_group) and texture_is_ready("tex_grp_onetime")){
			Created = false;
			state = menu.warnings;
		}
	}else{
		if (state != menu.players and state != menu.done and state != menu.returning){
			CheckControls();
		}
		SongTime = audio_sound_get_track_position(music);
		switch (state){
			case menu.returning: {
				if (texture_is_ready("tex_grp_menu") and texture_is_ready("tex_grp_ranking")){
					timer++;
					if (timer == 1){
						for (var i=40;i<=760;i+=80){
							for (var j=-30;j<=210;j+=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						for (var i=1560;i>=840;i-=80){
							for (var j=-30;j<=210;j+=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						for (var i=40;i<=760;i+=80){
							for (var j=930;j>=290;j-=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						for (var i=1560;i>=840;i-=80){
							for (var j=930;j>=290;j-=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						data[0] = {sprite: spr_pixel, index: 0, x: 2100, y: 44, angle: 0, scale: {x: 500, y: 28}, col: make_color_rgb(0,30,30), alpha: 211/255};
						data[1] = {sprite: spr_pixel, index: 0, x: 2100, y: 450, angle: 0, scale: {x: 500, y: 378}, col: make_color_rgb(0,63,63), alpha: 211/255};
						data[2] = {sprite: -1, index: 0, x: 560, y: 115, angle: 0, scale: {x: 0.3, y: 0.3}, col: c_white, alpha: 1};
						data[3] = {notdraw: true, sprite: spr_pixel, index: 0, x: 500, y: 42 + 84*selecting[0] - selecting[1], shake: 0, shakeint: 4, angle: 0, scale: {x: 500, y: 42}, col: make_color_rgb(0,76,76), alpha: 1};
						data[4] = {ontop: true, particles: []};
						data[5] = {ontop: true, sprite: spr_pixel, index: 0, x: 800, y: 250, angle: 0, scale: {x: 16, y: 16}, col: make_color_rgb(0,255,255), alpha: 0};
						if (!is_undefined(Levels[selecting[0]].preview)){
							lvl_prev = sprite_add("Levels/" + Levels[selecting[0]].preview + "/preview.png", 1, false, false, 0, 0);
							if (sprite_exists(lvl_prev)){
								data[2].sprite = lvl_prev;
								data[2].scale = {x: 480/sprite_get_width(lvl_prev), y: 270/sprite_get_height(lvl_prev)};
							}else{
								data[2].sprite = spr_preview;
								data[2].scale = {x: 0.3, y: 0.3};
							}
						}else{
							data[2].sprite = spr_preview;
							data[2].scale = {x: 0.3, y: 0.3};
						}
						instance_create_depth(0,0,-1,obj_DJBlixer);
						audio_play_sound(snd_appear, 100, false);
					}
					if (array_length(Squares) > 0){
						for (var i=0;i<array_length(Squares);i++){
							var square = Squares[i];
							var diff = max(square.dist - 16*(square.time - timer), 0);
							square.x += diff/4*dcos(square.dir);
							square.y -= diff/4*dsin(square.dir);
							square.rot -= diff/2;
							square.col = make_color_rgb(max(255 - max(square.dist - 16*(square.time - timer), 0)*2, 0),255,255);
							square.alpha -= max(square.dist - 16*(square.time - timer) - 120, 0)/100;
							if (square.alpha <= 0){
								array_delete(Squares, i, 1);
								i--;
							}
						}
					}
					if (timer == 41){
						audio_resume_sound(music);
						audio_sound_gain(music, 1, 500)
					}else{ if (timer == 68){
						data[5].alpha = 1;
						bounce = true;
					}else{ if (timer > 68){
						var prevsqrposX = data[5].x;
						var prevsqrposY = data[5].y;
						if (timer <= 146){
							data[0].x = 1060 + 1040*dcos(90/30*max(timer - 116, 0));
							data[1].x = data[0].x;
							data[2].x = 38 + 522*dcos(90/30*max(timer - 116, 0));
							data[2].y = 175 - 60*dcos(90/30*max(timer - 116, 0));
							obj_DJBlixer.DJ.table.x = 280 + 520*dcos(90/30*max(timer - 116, 0));
							if (timer <= 138){
								var Y = 114 + 84*selecting[0] - selecting[1];
								data[5].x = 800 + 179*min(timer - 68, 60)/60;
								data[5].y = 230 + Y - 230*dsin(90/30*min(timer - 68, 30)) + (20 - Y)*dcos(90/40*max(timer - 98, 0));
							}else{
								data[5].x = data[1].x - 504;
							}
							if (timer == 146 and highestrank <= Levels[selecting[0]].rank){
								state = menu.levels
								timer = 122;
								timer2 = 0;
								timer3 = 0;
								prev_val = -1;
								data[3].shake = 11;
								highestrank = 0;
								audio_play_sound(snd_selecting, 0, false);
							}
						}else{ if (timer <= 257){
							if (timer == 147){
								data[6] = {ontop: true, sprite: spr_stamp, index: 0, x: 1506, y: 114 + 84*selecting[0] - selecting[1], angle: 0, scale: {x: 0, y: 0}, col: c_white, alpha: 0};
								data[7] = {ontop: true, sprite: spr_rank, index: highestrank, x: data[6].x, y: data[6].y, angle: 0, scale: {x: 0, y: 0}, col: c_white, alpha: 0};
							}else{ if (timer <= 167){
								data[6].angle = 90*dsin(90/20*(timer - 147));
								data[6].scale.x = 0.18 + 0.12*dsin(90/20*(timer - 147));
								data[6].scale.y = data[6].scale.x;
								data[6].alpha = (timer - 147)/20;
							}else{ if (timer <= 177){
								data[6].angle = 90*dcos(90/10*(timer - 167));
								data[6].scale.x = 0.18 + 0.12*dcos(90/10*(timer - 167));
								data[6].scale.y = data[6].scale.x;
								data[6].col = make_color_rgb(255 - 255/10*(timer - 167),255 - 150/10*(timer - 167),255 - 150/10*(timer - 167));
								data[7].scale.x = data[6].scale.x/0.9;
								data[7].scale.y = data[7].scale.x;
								data[7].alpha = 1 - dcos(90/10*(timer - 167));
								data[7].angle = data[6].angle;
								if (timer == 177){
									Levels[selecting[0]].rank = highestrank;
									data[8] = {ontop: true, sprite: spr_rank, index: highestrank, x: data[6].x, y: data[6].y, angle: 0, scale: {x: 0.2, y: 0.2}, col: c_white, alpha: 1};
									audio_play_sound(snd_cheering, 0, false);
									audio_play_sound(snd_ranking, 100, false);
								}
							}else{
								data[8].scale.x = 0.2 + min(timer - 177, 50)/100;
								data[8].scale.y = data[8].scale.x;
								data[8].alpha = max(227 - timer, 0)/50;
								data[6].alpha = min(257 - timer, 30)/30;
							}}}
						}else{
							array_delete(data, 6, 3);
							state = menu.levels
							timer = 122;
							timer2 = 0;
							timer3 = 0;
							prev_val = -1;
							data[3].shake = 11;
							highestrank = 0;
							audio_play_sound(snd_selecting, 0, false);
						}}
						data[5].angle = (data[5].angle - (8 + 12*(timer <= 138)))%360;
						if (timer%2 == 0){
							array_push(data[4].particles, {x: data[5].x, y: data[5].y + irandom_range(-6, 6), size: irandom_range(4, 8), dir: point_direction(data[5].x,data[5].y,prevsqrposX,prevsqrposY) + random_range(-30, 30), speed: random_range(3, 5), alpha: data[5].alpha});
						}
					}}}
					if (timer > 68 and (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left))){
						cursor_sprite = spr_cursor;
					}
					mouse.x = window_mouse_get_x();
					mouse.y = window_mouse_get_y();
				}
			break; }
			case menu.done: {
				timer++;
				if (timer <= 83){
					data[0].x = 1060 + 1040*dsin(90/30*clamp(timer - 15, 0, 30));
					data[1].x = data[0].x;
					data[2].x = 38 + 522*dsin(90/30*clamp(timer - 15, 0, 30));
					data[2].y = 175 - 60*dsin(90/30*clamp(timer - 15, 0, 30));
					obj_DJBlixer.DJ.table.x = 280 + 520*dsin(90/30*clamp(timer - 15, 0, 30));
					var prevsqrposX = data[5].x;
					var prevsqrposY = data[5].y;
					if (timer <= 23){
						data[5].x = data[1].x - 504;
						if (timer == 23){
							audio_play_sound(snd_popping_out, 0, false);
							audio_sound_gain(music, 0, 1000);
						}
					}else{
						data[5].x = 979 - 179*max(timer - 23, 0)/60;
						data[5].y = 344 - 94*dsin(90/20*min(timer - 23, 20)) - 230*dcos(90/40*max(timer - 43, 0));
					}
					if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
						cursor_sprite = spr_cursor;
					}
					mouse.x = window_mouse_get_x();
					mouse.y = window_mouse_get_y();
					data[5].angle = (data[5].angle + (8 - 28*(timer > 23)))%360;
					if (timer%2 == 0){
						array_push(data[4].particles, {x: data[5].x, y: data[5].y + irandom_range(-6, 6), size: irandom_range(4, 8), dir: point_direction(data[5].x,data[5].y,prevsqrposX,prevsqrposY) + random_range(-30, 30), speed: random_range(3, 5), alpha: data[5].alpha});
					}
					if (timer == 83){
						cursor_sprite = -1;
						if (!is_undefined(lvl_prev)){
							sprite_delete(lvl_prev);
							lvl_prev = undefined;
						}
						audio_stop_sound(music);
						array_delete(data, 0, array_length(data));
						for (var i=0;i<4;i++){
							if (surface_exists(surface[i])){
								surface_free(surface[i]);
							}
						}
						for (var i=40;i<=760;i+=80){
							for (var j=-30;j<=210;j+=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						for (var i=1560;i>=840;i-=80){
							for (var j=-30;j<=210;j+=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						for (var i=40;i<=760;i+=80){
							for (var j=930;j>=290;j-=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						for (var i=1560;i>=840;i-=80){
							for (var j=930;j>=290;j-=80){
								array_push(Squares, {x: i, y: j, col: c_white, alpha: 1, rot: 0, time: 83, dist: point_distance(800,250,i,j), dir: point_direction(800,250,i,j)});
							}
						}
						array_delete(Songs, 0, array_length(Songs));
						instance_destroy(obj_DJBlixer);
						bounce = false;
						texture_flush("tex_grp_menu");
						texture_flush("tex_grp_ranking");
						audio_play_sound(snd_begin, 100, false);
					}
				}else{
					for (var i=0;i<array_length(Squares);i++){
						var square = Squares[i];
						var diff = max(16*max(timer - square.time, 0) - square.dist, 0);
						square.x += diff/4*dcos(square.dir);
						square.y -= diff/4*dsin(square.dir);
						square.rot -= diff/2;
						square.col = make_color_rgb(max(255 - max(16*max(timer - square.time, 0) - square.dist, 0)*2, 0),255,255);
						square.alpha -= max(16*max(timer - square.time, 0) - square.dist - 120, 0)/100;
						if (square.alpha <= 0){
							array_delete(Squares, i, 1);
							i--;
						}
					}
					if (array_length(Squares) <= 0 and !audio_is_playing(snd_begin)){
						state = level.ready;
						timer = 0;
						room_goto(rm_level);
					}
				}
			break; }
			case menu.players: case menu.playersOut: {
				if (timer < 45){
					timer2[0]++;
				}
				if (state == menu.players){
					timer++;
				}else{
					timer--;
				}
				if (timer == 0){
					state = menu.settings;
					timer = 145;
				}else{ if (timer == 45){
					if (state == menu.players){
						for (var i=3;i<5;i++){
							if (surface_exists(surface[i])){
								surface_free(surface[i]);
							}
						}
						with (obj_player){
							instance_destroy();
						}
						PlayerData = LoadPlayerConfig();
						configurations = [instance_create_depth(0,0,0,obj_playerconf,{index: PlayerData[0].index, hue: PlayerData[0].hue, saturation: PlayerData[0].saturation, value: PlayerData[0].value}),instance_create_depth(0,0,0,obj_playerconf,{index: PlayerData[1].index, hue: PlayerData[1].hue, saturation: PlayerData[1].saturation, value: PlayerData[1].value}),instance_create_depth(0,0,0,obj_playerconf,{index: PlayerData[2].index, hue: PlayerData[2].hue, saturation: PlayerData[2].saturation, value: PlayerData[2].value}),instance_create_depth(0,0,0,obj_playerconf,{index: PlayerData[3].index, hue: PlayerData[3].hue, saturation: PlayerData[3].saturation, value: PlayerData[3].value})];
						ocupado = [false, false, false, false];
						keyboard_taken = [false, false];
						timer2 = [0, 0];
					}else{
						if (surface_exists(surface[3])){
							surface_free(surface[3]);
						}
						with (obj_playerconf){
							instance_destroy();
						}
						if (Mode != mode.none){
							var colors = [[0,255,255], [255,255,0], [255,127,0], [0,255,0]];
							if (Mode == mode.shape){
								for (var j=0;j<4;j++){
									with (instance_create_depth(77.5 + 154*(j%2),77.5 + 154*floor(j/2),0,obj_player, {modo: Mode, index: j, red: colors[j][0], green: colors[j][1], blue: colors[j][2]})){
										limits.right = 294;
										limits.down = 294;
										control_type = other.maincontrols;
									}
								}
							}else{ if (Mode == mode.helicopter){
								for (var j=0;j<4;j++){
									with (instance_create_depth(77.5 + 154*(j%2),77.5 + 154*floor(j/2),0,obj_player, {modo: Mode, index: j, red: colors[j][0], green: colors[j][1], blue: colors[j][2]})){
										limits.right = 282;
										limits.down = 282;
										if (index%2 == 0){
											special_data.playerrot = 45;
											special_data.shaperange = 42;
										}else{ if (index == 3){
											special_data.shaperange = 39;
										}}
										control_type = other.maincontrols;
									}
								}
							}}
						}
						timer2 = [146, 0];
					}
				}else{ if (timer > 75){
					if (timer == 76){
						audio_play_sound(snd_selecting, 0, false);
					}
					var available = false;
					for (var i=0;i<4;i++){
						if (!ocupado[i]){
							available = true;
							break;
						}
					}
					if (available and state == menu.players){
						if (!keyboard_taken[0] and CheckControlInput(controls.keyboard, false, action.confirm)){
							for (var i=0;i<4;i++){
								if (!ocupado[i]){
									with (configurations[i]){
										state = config.coloring;
										control_type = controls.keyboard;
										zurdo = false;
										with (player){
											control_type = other.control_type;
											zurdo = other.zurdo;
											image_alpha = 1;
										}
										slot = i;
										indication = 0;
										songtime = floor(SongTime/0.48);
									}
									audio_play_sound(snd_confirm, 0, false);
									ocupado[i] = true;
									Players++;
									break;
								}
							}
							keyboard_taken[0] = true;
						}
						if (!keyboard_taken[1] and CheckControlInput(controls.keyboard, true, action.confirm)){
							for (var i=0;i<4;i++){
								if (!ocupado[i]){
									with (configurations[i]){
										state = config.coloring;
										control_type = controls.keyboard;
										zurdo = true;
										with (player){
											control_type = other.control_type;
											zurdo = other.zurdo;
											image_alpha = 1;
										}
										slot = i;
										indication = 0;
										songtime = floor(SongTime/0.48);
									}
									audio_play_sound(snd_confirm, 0, false);
									ocupado[i] = true;
									Players++;
									break;
								}
							}
							keyboard_taken[1] = true;
						}
						for (var i=0;i<8;i++){
							if (!gamepad_is_connected(i)){
								continue;
							}
							if (CheckControlInput(controls.gamepad, false, action.confirm, false, i)){
								invalid = false;
								for (var j=0;j<4;j++){
									if (!ocupado[j]){
										with (configurations[j]){
											state = config.coloring;
											control_type = controls.gamepad;
											control_id = i;
											zurdo = false;
											with (player){
												control_type = other.control_type;
												control_id = other.control_id;
												zurdo = other.zurdo;
												image_alpha = 1;
											}
											slot = j;
											indication = 0;
											songtime = floor(SongTime/0.48);
										}
										audio_play_sound(snd_confirm, 0, false);
										ocupado[j] = true;
										Players++;
										break;
									}else{
										with (configurations[j]){
											if (control_id == i and state != config.waiting){
												other.invalid = true;
												break;
											}
										}
									}
									if (invalid){
										break;
									}
								}
							}
							if (CheckControlInput(controls.gamepad, true, action.confirm, false, i)){
								invalid = false;
								for (var j=0;j<4;j++){
									if (!ocupado[j]){
										with (configurations[j]){
											state = config.coloring;
											control_type = controls.gamepad;
											control_id = i;
											zurdo = true;
											with (player){
												control_type = other.control_type;
												control_id = other.control_id;
												zurdo = other.zurdo;
												image_alpha = 1;
											}
											slot = j;
											indication = 0;
											songtime = floor(SongTime/0.48);
										}
										audio_play_sound(snd_confirm, 0, false);
										ocupado[j] = true;
										Players++;
										break;
									}else{
										with (configurations[j]){
											if (control_id == i and state != config.waiting){
												other.invalid = true;
												break;
											}
										}
									}
									if (invalid){
										break;
									}
								}
							}
						}
					}
					with (obj_playerconf){
						if (state == config.done){
							other.canproceed = true;
						}else{ if (state != config.waiting){
							other.canproceed = false;
							break;
						}}
					}
					if (CheckControlInput(maincontrols, zurdo, action.confirm, true) and canproceed){
						cursor_sprite = -1;
						timer2[1]++;
						timer2[0] = 0;
						if (timer2[1] == 60){
							state = menu.done;
							timer = 0;
							delete PlayerData;
							PlayerData = SavePlayerConfig(configurations);
							audio_play_sound(snd_confirm, 0, false);
						}
					}else{ if (CheckControlInput(maincontrols, zurdo, action.cancel, true)){
						cursor_sprite = -1;
						timer2[0]++;
						timer2[1] = 0;
						if (timer2[0] == 60){
							state = menu.playersOut;
							timer = 75;
							audio_play_sound(snd_cancel, 0, false);
						}
					}else{ if (!(((mouse_x >= 1186 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1434 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 840 and mouse_y <= 870) or (mouse_x >= 694 + 25*(maincontrols != controls.keyboard) and mouse_x <= 985 - 25*(maincontrols != controls.keyboard) and mouse_y >= 840 and mouse_y <= 870)) and mouse_check_button(mb_left))){
						timer2[0] = 0;
						timer2[1] = 0;
					}}}
				}}}
				if (shake > 0){
					shake--;
				}
				data[5].angle = (data[5].angle + 8)%360;
				if (timer%2 == 0){
					array_push(data[4].particles, {x: data[5].x, y: data[5].y + irandom_range(-6, 6), size: irandom_range(4, 8), dir: random_range(-30, 30), speed: random_range(3, 5), alpha: data[5].alpha});
				}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (mouse_check_button(mb_left) and state == menu.players and timer > 75){
						if (mouse_x >= 694 + 25*(maincontrols != controls.keyboard) and mouse_x <= 985 - 25*(maincontrols != controls.keyboard) and mouse_y >= 840 and mouse_y <= 870 and canproceed){
							if (!CheckControlInput(maincontrols, zurdo, action.cancel, true)){
								timer2[1]++;
								timer2[0] = 0;
							}
							if (timer2[1] == 60){
								state = menu.done;
								timer = 0;
								delete PlayerData;
								PlayerData = SavePlayerConfig(configurations);
								audio_play_sound(snd_confirm, 0, false);
							}
						}else{ if (mouse_x >= 1186 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1434 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 840 and mouse_y <= 870){
							if (!CheckControlInput(maincontrols, zurdo, action.cancel, true)){
								timer2[0]++;
								timer2[1] = 0;
							}
							if (timer2[0] == 60){
								state = menu.playersOut;
								timer = 75;
								audio_play_sound(snd_cancel, 0, false);
							}
						}}
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
			break; }
			case menu.settings: case menu.settingsOut: {
				timer2[0]++;
				selecting[2] = round(selecting[2] + (selecting[1] - selecting[2])/6);
				if (abs(selecting[2] - selecting[1]) == 0){
					if (state == menu.settings){
						timer++;
					}else{
						timer--;
					}
				}
				if (timer <= 45){
					if (timer == 1 and state == menu.settings){
						var aux = Levels[selected].play_as;
						if (aux == "Shape" or aux == "Helicopter" or aux == "Boat" or aux == "Big Cube" or aux == "Multiple"){
							selecting[0] = 0;
						}else{
							selecting[0] = -1;
						}
					}
					data[3].y = 42 + 84*selected - selecting[2];
					for (var i=0;i<array_length(Songs);i++){
						var Y = 84*Songs[i].pos - selecting[2];
						while (Y < -84){
							Songs[i].pos += 10;
							Songs[i].song_index = 0;
							Songs[i].scroll = {based: 0.2*string_width("recreated by " + ((!is_undefined(Levels[Songs[i].pos].recreated_by)) ? Levels[Songs[i].pos].recreated_by[0] : "")) - 280, artist: 0.2*string_width(((!is_undefined(Levels[Songs[i].pos].song_type) and Levels[Songs[i].pos].song_type[0] != "") ? Levels[Songs[i].pos].song_type[0] + " by " : "by ") + Levels[Songs[i].pos].artist[0][0]) - 405, song: 0.3*string_width(Levels[Songs[i].pos].song[0]) - 405, creator: 0.3*string_width(Levels[Songs[i].pos].level_by[0]) - 280, timer: [0, 0, 0, 0]};
							Songs[i].info = Levels[Songs[i].pos];
							Y += 840;
						}
						while (Y > 756){
							Songs[i].pos -= 10;
							Songs[i].song_index = 0;
							Songs[i].scroll = {based: 0.2*string_width("recreated by " + ((!is_undefined(Levels[Songs[i].pos].recreated_by)) ? Levels[Songs[i].pos].recreated_by[0] : "")) - 280, artist: 0.2*string_width(((!is_undefined(Levels[Songs[i].pos].song_type) and Levels[Songs[i].pos].song_type[0] != "") ? Levels[Songs[i].pos].song_type[0] + " by " : "by ") + Levels[Songs[i].pos].artist[0][0]) - 405, song: 0.3*string_width(Levels[Songs[i].pos].song[0]) - 405, creator: 0.3*string_width(Levels[Songs[i].pos].level_by[0]) - 280, timer: [0, 0, 0, 0]};
							Songs[i].info = Levels[Songs[i].pos];
							Y -= 840;
						}
						Songs[i].y = Y;
						if (!Songs[i].selected){
							Songs[i].x = -1000 + 1000*dcos(90/30*max(timer - 15, 0));
						}else{ if (timer == 0){
							Songs[i].selected = false;
						}}
					}
					if (timer == 0){
						state = menu.levels;
						data[3].shake = 11;
						timer = 124;
						prev_val = -1;
						timer2 = 0;
						timer3 = 0;
						selecting[0] = selected;
						if (surface_exists(surface[3])){
							surface_free(surface[3]);
						}
						if (irandom(250) == 133){
							audio_play_sound(snd_dead, 0, false);
						}
						with (obj_player){
							instance_destroy();
						}
						audio_play_sound(snd_selecting, 0, false);
					}
				}else{ if (timer <= 75){
					var Y = 84*selected - selecting[2];
					data[3].y = 42 + Y - Y/2 + Y*dcos(180/30*(timer - 45))/2;
					for (var i=0;i<array_length(Songs);i++){
						if (Songs[i].selected){
							Songs[i].y = data[3].y - 42;
							break;
						}
					}
				}else{ if (timer >= 146){
					if (selecting[0] >= 0){
						if (timer == 146){
							audio_play_sound(snd_selecting, 0, false);
							shake = 11;
						}
						if (CheckControlInput(maincontrols, zurdo, action.horizontal) > 0){
							timer2[1]++;
							if (timer2[1] == 1 or (timer2[1]%20 == 0 and timer2[1] > 30)){
								cursor_sprite = -1;
								selecting[0]++;
								selecting[0] %= 4;
								shake = 11;
								audio_play_sound(snd_selecting, 0, false);
							}
						}else{ if (CheckControlInput(maincontrols, zurdo, action.horizontal) < 0){
							timer2[1]++;
							if (timer2[1] == 1 or (timer2[1]%20 == 0 and timer2[1] > 30)){
								cursor_sprite = -1;
								selecting[0]--;
								if (selecting[0] < 0){
									selecting[0] += 4;
								}
								shake = 11;
								audio_play_sound(snd_selecting, 0, false);
							}
						}else{
							timer2[1] = 0;
						}}
					}
					if (CheckControlInput(maincontrols, zurdo, action.confirm)){
						cursor_sprite = -1;
						state = menu.players;
						timer = 0;
						LoadPlayerIcons();
						audio_play_sound(snd_confirm, 0, false);
					}else{ if (CheckControlInput(maincontrols, zurdo, action.cancel)){
						cursor_sprite = -1;
						state = menu.settingsOut;
						timer = 106;
						audio_play_sound(snd_cancel, 0, false);
					}}
				}}}
				if (shake > 0){
					shake--;
				}
				data[5].y += ((data[1].y - data[1].scale.y + data[3].y) - data[5].y)/10;
				data[5].angle = (data[5].angle + 8)%360;
				if (timer%2 == 0){
					array_push(data[4].particles, {x: data[5].x, y: data[5].y + irandom_range(-6, 6), size: irandom_range(4, 8), dir: random_range(-30, 30), speed: random_range(3, 5), alpha: data[5].alpha});
				}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (mouse_check_button_pressed(mb_left) and state == menu.settings and timer >= 146){
						if (mouse_x >= 694 + 25*(maincontrols != controls.keyboard) and mouse_x <= 985 - 25*(maincontrols != controls.keyboard) and mouse_y >= 840 and mouse_y <= 870){
							state = menu.players;
							timer = 0;
							LoadPlayerIcons();
							audio_play_sound(snd_confirm, 0, false);
						}else{ if (mouse_x >= 1186 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1434 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 840 and mouse_y <= 870){
							state = menu.settingsOut;
							timer = 106;
							audio_play_sound(snd_cancel, 0, false);
						}else{ if (selecting[0] >= 0){
							if (mouse_x >= 886 and mouse_x <= 922 and mouse_y >= 624 and mouse_y <= 661){
								selecting[0]--;
								if (selecting[0] < 0){
									selecting[0] += 4;
								}
								shake = 11;
								audio_play_sound(snd_selecting, 0, false);
							}else{ if (mouse_x >= 1457 and mouse_x <= 1491 and mouse_y >= 624 and mouse_y <= 661){
								selecting[0]++;
								selecting[0] %= 4;
								shake = 11;
								audio_play_sound(snd_selecting, 0, false);
							}}
						}}}
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						if (variable_struct_exists(thing, "shakeint")){
							thing.angle = irandom_range(-thing.shakeint/10*thing.shake, thing.shakeint/10*thing.shake);
						}else{
							thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
						}
					}
				}
			break; }
			case menu.levels: {
				timer++;
				if (timer <= 55){
					data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
					data[0].scale.y = data[0].scale.x;
					data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				}
				if (timer <= 5){
					data[1].scale.x = (200 + 40*dsin(180/5*timer))/200;
					data[1].scale.y = data[1].scale.x;
				}else{ if (timer <= 25){
					data[1].alpha = 1/10*min(25 - timer, 10);
					data[2].alpha = 1/10*clamp(20 - timer, 0, 10);
					data[3].alpha = 1/10*max(15 - timer, 0);
					if (timer == 25){
						array_delete(data, 1, 3);
						data[1] = {sprite: spr_pixel, index: 0, x: 2100, y: 422, angle: 0, scale: {x: 500, y: 28}, col: make_color_rgb(0,30,30), alpha: 211/255};
					}
				}else{ if (timer <= 55){
					data[0].alpha = 1/30*(55 - timer);
					data[1].x = 1060 + 1040*dcos(90/30*(timer - 25));
					obj_DJBlixer.DJ.table.x = 280 + 520*dcos(90/30*(timer - 25));
					if (timer == 55){
						array_delete(data, 0, 1);
						data[1] = {sprite: spr_pixel, index: 0, x: 1060, y: 450, angle: 0, scale: {x: 500, y: 0}, col: make_color_rgb(0,63,63), alpha: 211/255};
						data[2] = {sprite: spr_preview, index: 0, x: 38, y: 175, angle: 0, scale: {x: 0.3, y: 0.3}, col: c_white, alpha: 0};
					}
				}else{ if (timer <= 122){
					data[0].y = 44 + 378*dcos(90/30*clamp(timer - 65, 0, 30));
					data[1].scale.y = 378 - 378*dcos(90/30*clamp(timer - 65, 0, 30));
					data[2].alpha = 1 - dcos(90/30*clamp(timer - 65, 0, 30));
					if (timer == 95){
						timer2 = 0;
						timer3 = 0;
						data[3] = {notdraw: true, sprite: spr_pixel, index: 0, x: 500, y: 42, shake: 0, shakeint: 4, angle: 0, scale: {x: 500, y: 42}, col: make_color_rgb(0,76,76), alpha: 1};
						data[4] = {ontop: true, particles: []};
						data[5] = {ontop: true, sprite: spr_pixel, index: 0, x: 558, y: 42, angle: 0, scale: {x: 16, y: 16}, col: make_color_rgb(0,255,255), alpha: 0};
					}else{ if (timer == 122){
						prev_val = -1;
						audio_play_sound(snd_selecting, 0, false);
					}}
				}else{
					prev_val = selecting[0];
					if (CheckControlInput(maincontrols, zurdo, action.vertical) < 0){
						timer2++;
						if (timer2 == 1){
							cursor_sprite = -1;
							if (selecting[0] == 0){
								selecting[0] += array_length(Levels) - 1;
							}else{
								selecting[0]--;
							}
							data[3].shake = 11;
							audio_play_sound(snd_selecting, 0, false);
						}else{ if (selecting[0] > 0 and (timer2 == 30 or (timer2 >= 50 and timer2%6 == 0))){
							cursor_sprite = -1;
							selecting[0]--;
							data[3].shake = 11;
							audio_play_sound(snd_selecting, 0, false);
						}}
					}else{ if (CheckControlInput(maincontrols, zurdo, action.vertical) > 0){
						timer2++;
						if (timer2 == 1){
							cursor_sprite = -1;
							if (selecting[0] == array_length(Levels) - 1){
								selecting[0] = 0;
							}else{
								selecting[0]++;
							}
							data[3].shake = 11;
							audio_play_sound(snd_selecting, 0, false);
						}else{ if (selecting[0] < array_length(Levels) - 1 and (timer2 == 30 or (timer2 >= 50 and timer2%6 == 0))){
							cursor_sprite = -1;
							selecting[0]++;
							data[3].shake = 11;
							audio_play_sound(snd_selecting, 0, false);
						}}
					}else{
						timer2 = 0;
					}}
					if (CheckControlInput(maincontrols, zurdo, action.confirm)){
						cursor_sprite = -1;
						state = menu.settings;
						data[3].shake = 11;
						timer = 0;
						timer2 = [0, 0];
						selected = selecting[0];
						audio_play_sound(snd_confirm, 0, false);
					}else{ if (CheckControlInput(maincontrols, zurdo, action.cancel)){
						cursor_sprite = -1;
						state = menu.levelsOut;
						timer = 0;
						audio_play_sound(snd_cancel, 0, false);
					}}
				}}}}
				if (window_mouse_get_x() != mouse.x or mouse_wheel_up() > 0 or mouse_wheel_down() > 0 or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (timer > 122){
						if (mouse_check_button_pressed(mb_left)){
							if (mouse_x >= 563 and mouse_x <= 1553 and mouse_y >= 73 and mouse_y <= 70 + 84*min(array_length(Levels), 9)){
								var aux = floor((mouse_y + selecting[2] - 70)/84);
								if (aux != selecting[0]){
									selecting[0] = aux;
									data[3].shake = 11;
									audio_play_sound(snd_selecting, 0, false);
								}else{
									state = menu.settings;
									data[3].shake = 11;
									timer = 0;
									timer2 = [0, 0];
									selected = selecting[0];
									audio_play_sound(snd_confirm, 0, false);
								}
							}else{ if (mouse_x >= 694 + 25*(maincontrols != controls.keyboard) and mouse_x <= 985 - 25*(maincontrols != controls.keyboard) and mouse_y >= 840 and mouse_y <= 870){
								state = menu.settings;
								data[3].shake = 11;
								timer = 0;
								timer2 = [0, 0];
								selected = selecting[0];
								audio_play_sound(snd_confirm, 0, false);
							}else{ if (mouse_x >= 1186 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1434 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 840 and mouse_y <= 870){
								state = menu.levelsOut;
								timer = 0;
								audio_play_sound(snd_cancel, 0, false);
							}}}
						}else{ if (mouse_x >= 563 and mouse_x <= 1553 and mouse_y >= 73 and mouse_y <= 826){
							if (mouse_wheel_up() > 0){
								timer3++;
								if (timer3%4 == 1){
									if (selecting[0] == array_length(Levels) - 1){
										selecting[0] = 0;
									}else{
										selecting[0]++;
									}
								}
							}else{ if (mouse_wheel_down() > 0){
								if (timer%4 == 1){
									if (selecting[0] == 0){
										selecting[0] += array_length(Levels) - 1;
									}else{
										selecting[0]--;
									}
								}
							}else{
								timer3 = 0;
							}}
						}}
					}
				}
				if (selecting[0] != prev_val){
					if (!is_undefined(lvl_prev)){
						if (sprite_exists(lvl_prev)){
							sprite_delete(lvl_prev);
						}
						lvl_prev = undefined;
					}
					if (!is_undefined(Levels[selecting[0]].preview)){
						lvl_prev = sprite_add("Levels/" + Levels[selecting[0]].preview + "/preview.png", 1, false, false, 0, 0);
						if (sprite_exists(lvl_prev)){
							data[2].sprite = lvl_prev;
							data[2].scale = {x: 480/sprite_get_width(lvl_prev), y: 270/sprite_get_height(lvl_prev)};
						}else{
							data[2].sprite = spr_preview;
							data[2].scale = {x: 0.3, y: 0.3};
						}
					}else{
						data[2].sprite = spr_preview;
						data[2].scale = {x: 0.3, y: 0.3};
					}
				}
				if (timer >= 95 or state == menu.settings or state == menu.levelsOut){
					if ((min(selecting[0], array_length(Levels) - 2) - 7)*84 > selecting[1]){
						selecting[1] = (min(selecting[0], array_length(Levels) - 2) - 7)*84;
					}else{ if (max(min(selecting[0] - 1, array_length(Levels) - 9), 0)*84 < selecting[1]){
						selecting[1] = max(min(selecting[0] - 1, array_length(Levels) - 9), 0)*84;
					}}
					selecting[2] = round(selecting[2] + (selecting[1] - selecting[2])/6);
					data[3].y = 42 + 84*selecting[0] - selecting[2];
					if (state == menu.levels){
						data[5].x = data[1].x - 504 - 60*dcos(90/15*min(timer - 95, 15));
					}else{
						data[5].x = data[1].x - 504;
					}
					data[5].y += ((data[1].y - data[1].scale.y + data[3].y) - data[5].y)/10;
					if (state == menu.levels){
						data[5].alpha = 1 - dcos(90/15*min(timer - 95, 15));
					}else{
						data[5].alpha = 1;
					}
					data[5].angle = (data[5].angle + 8)%360;
					if (timer%2 == 0){
						array_push(data[4].particles, {x: data[5].x, y: data[5].y + irandom_range(-6, 6), size: irandom_range(4, 8), dir: random_range(-30, 30), speed: random_range(3, 5), alpha: data[5].alpha});
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				draw_set_font(fnt_nexaBold90);
				for (var i=0;i<array_length(Songs);i++){
					if (state != menu.settings and state != menu.levelsOut){
						Songs[i].x = 1000 - 1000*dsin(90/30*clamp(timer - 75 - 2*i, 0, 30));
					}else{
						Songs[i].x = 0;
					}
					var Y = 84*Songs[i].pos - selecting[2];
					while (Y < -84){
						Songs[i].pos += 10;
						Songs[i].song_index = 0;
						Songs[i].scroll = {based: 0.2*string_width("recreated by " + ((!is_undefined(Levels[Songs[i].pos].recreated_by)) ? Levels[Songs[i].pos].recreated_by[0] : "")) - 280, artist: 0.2*string_width(((!is_undefined(Levels[Songs[i].pos].song_type) and Levels[Songs[i].pos].song_type[0] != "") ? Levels[Songs[i].pos].song_type[0] + " by " : "by ") + Levels[Songs[i].pos].artist[0][0]) - 405, song: 0.3*string_width(Levels[Songs[i].pos].song[0]) - 405, creator: 0.3*string_width(Levels[Songs[i].pos].level_by[0]) - 280, timer: [0, 0, 0, 0]};
						Songs[i].info = Levels[Songs[i].pos];
						Y += 840;
					}
					while (Y > 756){
						Songs[i].pos -= 10;
						Songs[i].song_index = 0;
						Songs[i].scroll = {based: 0.2*string_width("recreated by " + ((!is_undefined(Levels[Songs[i].pos].recreated_by)) ? Levels[Songs[i].pos].recreated_by[0] : "")) - 280, artist: 0.2*string_width(((!is_undefined(Levels[Songs[i].pos].song_type) and Levels[Songs[i].pos].song_type[0] != "") ? Levels[Songs[i].pos].song_type[0] + " by " : "by ") + Levels[Songs[i].pos].artist[0][0]) - 405, song: 0.3*string_width(Levels[Songs[i].pos].song[0]) - 405, creator: 0.3*string_width(Levels[Songs[i].pos].level_by[0]) - 280, timer: [0, 0, 0, 0]};
						Songs[i].info = Levels[Songs[i].pos];
						Y -= 840;
					}
					Songs[i].y = Y;
					if (state == menu.settings and Songs[i].pos == selecting[0]){
						Songs[i].selected = true;
						var playwith = Songs[i].info.play_as;
						data[6] = {ontop: true, icons: []};
						for (j=0;j<Songs[i].info.difficulty;j++){
							array_push(data[6].icons, {sprite: spr_difficulty, index: j, x: 885 + 100*j, y: 217, scale: {x: 90/500, y: 90/500}, angle: 0, col: c_white, alpha: 0, timer: -106 - 5*j});
						}
						if (playwith == "Shape"){
							Mode = mode.shape;
						}else{ if (playwith == "Helicopter"){
							Mode = mode.helicopter;
						}else{ if (playwith == "Boat"){
							Mode = mode.boat;
						}else{ if (playwith == "Big Cube"){
							Mode = mode.big_cube;
						}else{
							Mode = mode.none;
						}}}}
						if (Mode != mode.none){
							var colors = [[0,255,255], [255,255,0], [255,127,0], [0,255,0]];
							if (Mode == mode.shape){
								for (var j=0;j<4;j++){
									with (instance_create_depth(77.5 + 154*(j%2),77.5 + 154*floor(j/2),0,obj_player, {modo: Mode, index: j, red: colors[j][0], green: colors[j][1], blue: colors[j][2]})){
										limits.right = 294;
										limits.down = 294;
										control_type = other.maincontrols;
									}
								}
							}else{ if (Mode == mode.helicopter){
								for (var j=0;j<4;j++){
									with (instance_create_depth(77.5 + 154*(j%2),77.5 + 154*floor(j/2),0,obj_player, {modo: Mode, index: j, red: colors[j][0], green: colors[j][1], blue: colors[j][2]})){
										limits.right = 282;
										limits.down = 282;
										if (index%2 == 0){
											special_data.playerrot = 45;
											special_data.shaperange = 42;
										}else{ if (index == 3){
											special_data.shaperange = 39;
										}}
										control_type = other.maincontrols;
									}
								}
							}}
						}
					}
				}
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						if (variable_struct_exists(thing, "shakeint")){
							thing.angle = irandom_range(-thing.shakeint/10*thing.shake, thing.shakeint/10*thing.shake);
						}else{
							thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
						}
					}
				}
			break; }
			case menu.levelsOut: {
				timer++;
				if (timer <= 30){
					data[0].x = 1060 + 1040*dsin(90/30*timer);
					data[1].x = data[0].x;
					selecting[2] = selecting[2] + (selecting[1] - selecting[2])/6;
					data[3].y = 42 + 84*selecting[0] - selecting[2];
					data[5].x -= 2;
					data[5].y += ((data[1].y - data[1].scale.y + data[3].y) - data[5].y)/10;
					data[5].alpha = max(data[5].alpha - 0.04, 0);
					data[5].angle = (data[5].angle + 8)%360;
					if (timer%2 == 0){
						array_push(data[4].particles, {x: data[5].x, y: data[5].y + irandom_range(-6, 6), size: irandom_range(4, 8), dir: random_range(-30, 30), speed: random_range(3, 5), alpha: data[5].alpha});
					}
					data[2].alpha = 1 - dsin(90/30*timer);
					data[5].alpha = data[2].alpha;
					if (timer == 30){
						array_delete(data, 0, 5);
						data[0] = {sprite: spr_title, index: 0, x: 800, y: 170, scale: {x: 0, y: 0}, angle: 0, col: c_white, alpha: 0};
						data[1] = {sprite: spr_buttons, index: 0, x: 800, y: 390, angle: 0, scale: {x: 1, y: 1}, col: c_white, alpha: 0};
						data[2] = {sprite: spr_buttons, index: 2, x: 300, y: 390, angle: 0, scale: {x: 1, y: 1}, col: c_white, alpha: 0};
						data[3] = {sprite: spr_buttons, index: 4, x: 1300, y: 390, angle: 0, scale: {x: 1, y: 1}, col: c_white, alpha: 0};
						for (var i=0;i<3;i++){
							if (surface_exists(surface[i])){
								surface_free(surface[i]);
							}
						}
						if (!is_undefined(lvl_prev)){
							sprite_delete(lvl_prev);
							lvl_prev = undefined;
						}
					}
				}else{
					data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
					data[0].scale.y = data[0].scale.x;
					data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
					obj_DJBlixer.DJ.table.x = 280 + 520*dsin(90/30*min(timer - 30, 30));
					data[0].alpha = 1/30*min(timer - 30, 30);
					data[3].alpha = data[0].alpha;
					data[2].alpha = 1/30*max(timer - 35, 0);
					data[1].alpha = 1/30*max(timer - 40, 0);
					if (timer > 80){
						state = menu.title;
						timer = 0;
						selecting = 0;
						data[1].index = 1;
						data[1].shake = 11;
						data[2].shake = 0;
						data[3].shake = 0;
						audio_play_sound(snd_selecting, 0, false);
					}
				}
				if (window_mouse_get_x() != mouse.x or mouse_wheel_up() > 0 or mouse_wheel_down() > 0 or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						if (variable_struct_exists(thing, "shakeint")){
							thing.angle = irandom_range(-thing.shakeint/10*thing.shake, thing.shakeint/10*thing.shake);
						}else{
							thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
						}
					}
				}
			break; }
			case menu.nolevels: {
				timer++;
				data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
				data[0].scale.y = data[0].scale.x;
				data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				if (timer <= 20){
					data[1].scale.x = (200 + 40*dsin(180/5*min(timer, 5)))/200;
					data[1].scale.y = data[1].scale.x;
					data[4].alpha = 0.87/20*timer;
					data[5].scale.x = 1600/2*dsin(90/20*timer);
				}else{ if (CheckControlInput(maincontrols, zurdo, action.confirm)){
					cursor_sprite = -1;
					state = menu.nolevelsOut;
					timer = 0;
					audio_play_sound(snd_cancel, 0, false);
				}}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (mouse_check_button_pressed(mb_left) and state == menu.nolevels){
						if (mouse_x >= 650 + 25*(maincontrols != controls.keyboard) and mouse_x <= 950 - 25*(maincontrols != controls.keyboard) and mouse_y >= 694 and mouse_y <= 724){
							state = menu.nolevelsOut;
							timer = 0;
							audio_play_sound(snd_cancel, 0, false);
						}
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
					}
				}
			break; }
			case menu.nolevelsOut: {
				timer++;
				data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
				data[0].scale.y = data[0].scale.x;
				data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				if (timer <= 50){
					data[4].alpha = 0.87/20*min(50 - timer, 20);
					data[5].scale.x = 1600/2*dcos(90/20*max(timer - 30, 0));
				}else{
					array_delete(data, 4, 2);
					timer = 0;
					state = menu.title;
					data[1].index = 1;
					data[1].shake = 11;
					audio_play_sound(snd_selecting, 0, false);
				}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
					}
				}
			break; }
			case menu.credits: case menu.creditsOut: {
				if (state == menu.credits){
					timer++;
				}else{
					timer--;
				}
				data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
				data[0].scale.y = data[0].scale.x;
				data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				if (timer <= 5){
					if (timer == 0){
						state = menu.title;
						timer = 0;
						data[3].shake = 11;
						audio_play_sound(snd_selecting, 0, false);
					}else{ if (timer == 5){
						data[1].alpha = 1;
					}}
					data[3].scale.x = (200 + 40*dsin(180/5*timer))/200;
					data[3].scale.y = data[3].scale.x;
				}else{ if (timer <= 25){
					if (timer == 25 and state == menu.creditsOut){
						data[0].alpha = 1;
						array_delete(data, 4, 1);
					}
					data[1].alpha = 1/10*max(15 - timer, 0);
					data[2].alpha = 1/10*clamp(20 - timer, 0, 10);
					data[3].alpha = 1/10*min(25 - timer, 10);
				}else{ if (timer <= 45){
					data[0].alpha = 1/20*(45 - timer);
					data[4].scale.x = 800*dsin(90/20*(timer - 25));
				}else{ if (CheckControlInput(maincontrols, zurdo, action.confirm) and timer > 75 and state == menu.credits){
					cursor_sprite = -1;
					state = menu.creditsOut;
					data[3].index = 4;
					timer = 90;
					audio_play_sound(snd_cancel, 0, false);
				}}}}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (mouse_check_button_pressed(mb_left) and state == menu.credits and mouse_x >= 582 + 25*(maincontrols != controls.keyboard) and mouse_x <= 1020 - 25*(maincontrols != controls.keyboard) and mouse_y >= 428 and mouse_y <= 460){
						state = menu.creditsOut;
						data[3].index = 4;
						timer = 90;
						audio_play_sound(snd_cancel, 0, false);
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
					}
				}
			break; }
			case menu.options: case menu.optionsOut: {
				if (state == menu.options){
					timer++;
				}else{
					timer--;
				}
				data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
				data[0].scale.y = data[0].scale.x;
				data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				if (timer <= 5 and state == menu.options){
					if (timer == 1){
						selecting = [0, 0, 0, 0, 0, 0, 0];
					}
					data[2].scale.x = (200 + 40*dsin(180/5*timer))/200;
					data[2].scale.y = data[2].scale.x;
				}else{ if (timer == 0 and state == menu.optionsOut){
					selecting = 1;
					array_delete(data, 4, 1);
					state = menu.title;
					audio_play_sound(snd_selecting, 0, false);
					if (surface_exists(surface[0])){
						surface_free(surface[0]);
					}
					if (surface_exists(surface[1])){
						surface_free(surface[1]);
					}
				}else{ if (timer <= 75){
					camera.x = 125*16/9 - 125*16/9*dcos(180/60*max(timer - 15, 0));
					camera.y = 250 - 250*dcos(180/60*max(timer - 15, 0));
					camera_set_view_size(view_camera[0], 1600 - 250*16/9 + 250*16/9*dcos(180/60*max(timer - 15, 0)), 650 + 250*dcos(180/60*max(timer - 15, 0)));
					data[4].scale.x = 500*dsin(90/30*max(timer - 45, 0))/2;
					data[4].scale.y = 200*dsin(90/30*max(timer - 45, 0))/2;
				}else{ if (timer == 90){
					data[2].index = 2;
					audio_play_sound(snd_selecting, 0, false);
				}else{ if (timer > 90){
					if (CheckControlInput(maincontrols, zurdo, action.cancel)){
						cursor_sprite = -1;
						state = menu.optionsOut;
						timer = 90;
						SaveSettings(res);
						audio_play_sound(snd_confirm,0,false);
					}else{ if (CheckControlInput(maincontrols, zurdo, action.horizontal) < 0){
						cursor_sprite = -1;
						selecting[1]++;
						selecting[2] = 0;
						if (selecting[1] == 1 or (selecting[1]%6 == 0 and selecting[1] > 25)){
							switch (selecting[0]){
								case 0:
									Volume.music = max(Volume.music - 0.1, 0);
									audio_group_set_gain(music_group, Volume.music, 0);
									audio_play_sound(snd_selecting, 0, false);
								break;
								case 1:
									Volume.sounds = max(Volume.sounds - 0.1, 0);
									audio_group_set_gain(sound_group, Volume.sounds, 0);
									audio_play_sound(snd_selecting, 0, false);
								break;
								case 2:
									if (selecting[1] == 1){
										res--;
										if (res < 0){
											res += array_length(Resolutions);
										}
										window_set_size(Resolutions[res].x, Resolutions[res].y);
										surface_resize(application_surface, Resolutions[res].x, Resolutions[res].y);
										audio_play_sound(snd_selecting, 0, false);
									}
								break;
								case 3:
									if (selecting[1] == 1){
										window_set_fullscreen(!window_get_fullscreen());
										audio_play_sound(snd_selecting, 0, false);
									}
								break;
								default:
									Photosensitive = !Photosensitive;
									audio_play_sound(snd_selecting, 0, false);
								break;
							}
						}
					}else{ if (CheckControlInput(maincontrols, zurdo, action.horizontal) > 0){
						cursor_sprite = -1;
						selecting[1]++;
						selecting[2] = 0;
						if (selecting[1] == 1 or (selecting[1]%6 == 0 and selecting[1] > 25)){
							switch (selecting[0]){
								case 0:
									Volume.music = min(Volume.music + 0.1, 1);
									audio_group_set_gain(music_group, Volume.music, 0);
									audio_play_sound(snd_selecting, 0, false);
								break;
								case 1:
									Volume.sounds = min(Volume.sounds + 0.1, 1);
									audio_group_set_gain(sound_group, Volume.sounds, 0);
									audio_play_sound(snd_selecting, 0, false);
								break;
								case 2:
									if (selecting[1] == 1){
										res++;
										selecting[4] = 11;
										if (res >= array_length(Resolutions)){
											res -= array_length(Resolutions);
										}
										window_set_size(Resolutions[res].x, Resolutions[res].y);
										surface_resize(application_surface, Resolutions[res].x, Resolutions[res].y);
										audio_play_sound(snd_selecting, 0, false);
									}
								break;
								case 3:
									if (selecting[1] == 1){
										selecting[5] = 11;
										window_set_fullscreen(!window_get_fullscreen());
										audio_play_sound(snd_selecting, 0, false);
									}
								break;
								default:
									Photosensitive = !Photosensitive;
									selecting[6] = 11;
									audio_play_sound(snd_selecting, 0, false);
								break;
							}
						}
					}else{ if (CheckControlInput(maincontrols, zurdo, action.vertical) < 0){
						cursor_sprite = -1;
						selecting[2]++;
						selecting[1] = 0;
						if (selecting[2] == 1 or (selecting[2]%6 == 0 and selecting[2] > 25)){
							if (selecting[0] > 0){
								selecting[0]--;
								if (selecting[0] == 2){
									selecting[4] = 11;
								}else{ if (selecting[0] == 3){
									selecting[5] = 11;
								}}
							}else{
								selecting[0] = 4;
								selecting[6] = 11;
							}
							audio_play_sound(snd_selecting, 0, false);
						}
					}else{ if (CheckControlInput(maincontrols, zurdo, action.vertical) > 0){
						cursor_sprite = -1;
						selecting[2]++;
						selecting[1] = 0;
						if (selecting[2] == 1 or (selecting[2]%6 == 0 and selecting[2] > 25)){
							if (selecting[0] < 4){
								selecting[0]++;
								if (selecting[0] == 2){
									selecting[4] = 11;
								}else{ if (selecting[0] == 3){
									selecting[5] = 11;
								}else{ if (selecting[0] == 4){
									selecting[6] = 11;
								}}}
							}else{
								selecting[0] = 0;
							}
							audio_play_sound(snd_selecting, 0, false);
						}
					}else{
						selecting[1] = 0;
						selecting[2] = 0;
					}}}}}
					for (var i=4;i<=6;i++){
						if (selecting[i] > 0){
							selecting[i]--;
						}
					}
				}}}}}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (state == menu.options and timer > 90){
						if (mouse_x >= 560 and mouse_x <= 910 and mouse_y >= 695 and mouse_y <= 725){
							if (selecting[0] != 0){
								selecting[0] = 0;
								audio_play_sound(snd_selecting,0,false);
							}
							if (mouse_check_button(mb_left) and mouse_x >= 650 and mouse_x <= 904 and Volume.music != 0.1*floor((mouse_x - 631)/26)){
								Volume.music = 0.1*floor((mouse_x - 631)/26);
								audio_group_set_gain(music_group, Volume.music, 0);
								audio_play_sound(snd_selecting, 0, false);
							}
						}else{ if (mouse_x >= 560 and mouse_x <= 918 and mouse_y >= 730 and mouse_y <= 760){
							if (selecting[0] != 1){
								selecting[0] = 1;
								audio_play_sound(snd_selecting,0,false);
							}
							if (mouse_check_button(mb_left) and mouse_x >= 660 and mouse_x <= 914 and Volume.sounds != 0.1*floor((mouse_x - 641)/26)){
								Volume.sounds = 0.1*floor((mouse_x - 641)/26);
								audio_group_set_gain(sound_group, Volume.sounds, 0);
								audio_play_sound(snd_selecting, 0, false);
							}
						}else{ if (mouse_x >= 560 and mouse_x <= 984 and mouse_y >= 770 and mouse_y <= 790){
							if (selecting[0] != 2){
								selecting[0] = 2;
								selecting[4] = 11;
								audio_play_sound(snd_selecting,0,false);
							}
							if (mouse_check_button_pressed(mb_left)){
								if (mouse_x >= 804 and mouse_x <= 820){
									res--;
									selecting[4] = 11;
									if (res < 0){
										res += array_length(Resolutions);
									}
									window_set_size(Resolutions[res].x, Resolutions[res].y);
									surface_resize(application_surface, Resolutions[res].x, Resolutions[res].y);
									audio_play_sound(snd_selecting, 0, false);
								}else{ if (mouse_x >= 964){
									res++;
									selecting[4] = 11;
									if (res >= array_length(Resolutions)){
										res -= array_length(Resolutions);
									}
									window_set_size(Resolutions[res].x, Resolutions[res].y);
									surface_resize(application_surface, Resolutions[res].x, Resolutions[res].y);
									audio_play_sound(snd_selecting, 0, false);
								}}
							}
						}else{ if (mouse_x >= 560 and mouse_x <= 795 and mouse_y >= 804 and mouse_y <= 824){
							if (selecting[0] != 3){
								selecting[0] = 3;
								selecting[5] = 11;
								audio_play_sound(snd_selecting,0,false);
							}
							if (mouse_check_button_pressed(mb_left)){
								if ((mouse_x >= 700 and mouse_x <= 716) or (mouse_x >= 780)){
									selecting[5] = 11;
									window_set_fullscreen(!window_get_fullscreen());
									audio_play_sound(snd_selecting, 0, false);
								}
							}
						}else{ if (mouse_x >= 560 and mouse_x <= 935 and mouse_y >= 835 and mouse_y <= 855){
							if (selecting[0] != 4){
								selecting[0] = 4;
								selecting[6] = 11;
								audio_play_sound(snd_selecting,0,false);
							}
							if (mouse_check_button_pressed(mb_left)){
								if ((mouse_x >= 840 and mouse_x <= 855) or (mouse_x >= 917)){
									Photosensitive = !Photosensitive;
									selecting[6] = 11;
									audio_play_sound(snd_selecting, 0, false);
								}
							}
						}else{ if (mouse_check_button_pressed(mb_left) and mouse_x >= 644 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 956 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 871 and mouse_y <= 884){
							state = menu.optionsOut;
							timer = 90;
							SaveSettings(res);
							audio_play_sound(snd_confirm,0,false);
						}}}}}}
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				if (timer > 90){
					selecting[3] += (selecting[0] - selecting[3])/6;
				}
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
					}
				}
			break; }
			case menu.quitOut: {
				timer++;
				data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
				data[0].scale.y = data[0].scale.x;
				data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				if (timer <= 50){
					data[4].alpha = 0.87/20*min(50 - timer, 20);
					data[5].scale.x = 1600/2*dcos(90/20*max(timer - 30, 0));
				}else{
					array_delete(data, 4, 2);
					timer = 0;
					state = menu.title;
					if (selecting == 0){
						data[1].index = 1;
						data[1].shake = 11;
					}else{ if (selecting == 1){
						data[2].index = 3;
						data[2].shake = 11;
					}else{
						data[3].index = 5;
						data[3].shake = 11;
					}}
					audio_play_sound(snd_selecting, 0, false);
				}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
					}
				}
			break; }
			case menu.quit: {
				timer++;
				data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
				data[0].scale.y = data[0].scale.x;
				data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				if (timer <= 20){
					data[4].alpha = 0.87/20*timer;
					data[5].scale.x = 1600/2*dsin(90/20*timer);
				}else{ if (CheckControlInput(maincontrols, zurdo, action.confirm)){
					audio_play_sound(snd_confirm, 0, false);
					game_end();
				}else{ if (CheckControlInput(maincontrols, zurdo, action.cancel)){
					cursor_sprite = -1;
					state = menu.quitOut;
					timer = 0;
					audio_play_sound(snd_cancel, 0, false);
				}}}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (mouse_check_button_pressed(mb_left) and state == menu.quit){
						if (mouse_x >= 980 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1220 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 500 and mouse_y <= 530){
							state = menu.quitOut;
							timer = 0;
							audio_play_sound(snd_cancel, 0, false);
						}else{ if (mouse_x >= 340 + 25*(maincontrols != controls.keyboard) and mouse_x <= 660 - 25*(maincontrols != controls.keyboard) and mouse_y >= 500 and mouse_y <= 530){
							audio_play_sound(snd_confirm, 0, false);
							game_end();
						}}
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
					}
				}
			break; }
			case menu.title: {
				data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
				data[0].scale.y = data[0].scale.x;
				data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
				if (CheckControlInput(maincontrols, zurdo, action.horizontal) < 0){
					timer++;
					if (timer == 1 or (timer%6 == 0 and timer > 25)){
						cursor_sprite = -1;
						selecting++;
						if (selecting == 3){
							selecting = 0;
							data[1].shake = 11;
						}else{ if (selecting == 1){
							data[2].shake = 11;
						}else{
							data[3].shake = 11;
						}}
						audio_play_sound(snd_selecting, 0, false);
					}
				}else{ if (CheckControlInput(maincontrols, zurdo, action.horizontal) > 0){
					timer++;
					if (timer == 1 or (timer%6 == 0 and timer > 25)){
						cursor_sprite = -1;
						selecting--;
						if (selecting == -1){
							selecting = 2;
							data[3].shake = 11;
						}else{ if (selecting == 1){
							data[2].shake = 11;
						}else{
							data[1].shake = 11;
						}}
						audio_play_sound(snd_selecting, 0, false);
					}
				}else{ if (CheckControlInput(maincontrols, zurdo, action.confirm)){
					cursor_sprite = -1;
					if (selecting == 0){
						if (LoadLevels()){
							state = menu.levels;
							draw_set_font(fnt_nexaBold90);
							for (var i=0;i<min(array_length(Levels),10);i++){
								Songs[i] = {x: 0, y: 0, pos: i, selected: false, song_index: 0, scroll: {based: 0.2*string_width("recreated by " + ((!is_undefined(Levels[i].recreated_by)) ? Levels[i].recreated_by[0] : "")) - 280, artist: 0.2*string_width(((!is_undefined(Levels[i].song_type) and Levels[i].song_type[0] != "") ? Levels[i].song_type[0] + " by " : "by ") + Levels[i].artist[0][0]) - 405, song: 0.3*string_width(Levels[i].song[0]) - 405, creator: 0.3*string_width(Levels[i].level_by[0]) - 280, timer: [0, 0, 0, 0]}, info: Levels[i]};
							}
						}else{
							state = menu.nolevels;
							data[1].index = 0;
							data[2].index = 2;
							data[3].index = 4;
							data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 445, angle: 0, scale: {x: 800, y: 455}, col: c_black, alpha: 0};
							data[5] = {sprite: spr_pixel, index: 0, x: 800, y: 450, angle: 0, scale: {x: 0, y: 285}, col: make_color_rgb(0,63,63), alpha: 1};
						}
						data[1].shake = 11;
					}else{ if (selecting == 1){
						state = menu.options;
						data[2].shake = 11;
						data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 790, angle: 0, scale: {x: 0, y: 0}, col: make_color_rgb(0, 63, 63), alpha: 211/255};
					}else{
						state = menu.credits;
						data[3].shake = 11;
						data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 220, angle: 0, scale: {x: 0, y: 250}, col: make_color_rgb(0, 63, 63), alpha: 211/255};
					}}
					timer = 0;
					audio_play_sound(snd_confirm, 0, false);
				}else{ if (CheckControlInput(maincontrols, zurdo, action.cancel)){
					cursor_sprite = -1;
					timer = 0;
					state = menu.quit;
					data[1].index = 0;
					data[2].index = 2;
					data[3].index = 4;
					data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 445, angle: 0, scale: {x: 800, y: 455}, col: c_black, alpha: 0};
					data[5] = {sprite: spr_pixel, index: 0, x: 800, y: 450, angle: 0, scale: {x: 0, y: 100}, col: make_color_rgb(0,63,63), alpha: 1};
					audio_play_sound(snd_cancel, 0, false);
				}else{
					timer = 0;
				}}}}
				if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
					cursor_sprite = spr_cursor;
					if (mouse_check_button_pressed(mb_left) and state == menu.title){
						if (mouse_x >= 200 and mouse_x <= 400 and mouse_y >= 342 and mouse_y <= 432){
							if (selecting != 1){
								selecting = 1;
								data[2].shake = 11;
								audio_play_sound(snd_selecting, 0, false);
							}else{
								timer = 0;
								state = menu.options;
								data[2].shake = 11;
								data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 790, angle: 0, scale: {x: 0, y: 0}, col: make_color_rgb(0, 63, 63), alpha: 211/255};
								audio_play_sound(snd_confirm, 0, false);
							}
						}else{ if (mouse_x >= 700 and mouse_x <= 900 and mouse_y >= 342 and mouse_y <= 432){
							if (selecting != 0){
								selecting = 0;
								data[1].shake = 11;
								audio_play_sound(snd_selecting, 0, false);
							}else{
								timer = 0;
								if (LoadLevels()){
									state = menu.levels;
									for (var i=0;i<min(array_length(Levels),10);i++){
										Songs[i] = {x: 0, y: 0, pos: i, selected: false, song_index: 0, scroll: {based: 0.2*string_width("recreated by " + ((!is_undefined(Levels[i].recreated_by)) ? Levels[i].recreated_by[0] : "")) - 280, artist: 0.2*string_width(((!is_undefined(Levels[i].song_type) and Levels[i].song_type[0] != "") ? Levels[i].song_type[0] + " by " : "by ") + Levels[i].artist[0][0]) - 405, song: 0.3*string_width(Levels[i].song[0]) - 405, creator: 0.3*string_width(Levels[i].level_by[0]) - 280, timer: [0, 0, 0, 0]}, info: Levels[i]};
									}
								}else{
									state = menu.nolevels;
									data[1].index = 0;
									data[2].index = 2;
									data[3].index = 4;
									data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 445, angle: 0, scale: {x: 800, y: 455}, col: c_black, alpha: 0};
									data[5] = {sprite: spr_pixel, index: 0, x: 800, y: 450, angle: 0, scale: {x: 0, y: 285}, col: make_color_rgb(0,63,63), alpha: 1};
								}
								data[1].shake = 11;
								audio_play_sound(snd_confirm, 0, false);
							}
						}else{ if (mouse_x >= 1200 and mouse_x <= 1400 and mouse_y >= 342 and mouse_y <= 432){
							if (selecting != 2){
								selecting = 2;
								data[3].shake = 11;
								audio_play_sound(snd_selecting, 0, false);
							}else{
								timer = 0;
								state = menu.credits;
								data[3].shake = 11;
								data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 220, angle: 0, scale: {x: 0, y: 250}, col: make_color_rgb(0, 63, 63), alpha: 211/255};
								audio_play_sound(snd_confirm, 0, false);
							}
						}else{ if (mouse_x >= 156 + 25*(maincontrols != controls.keyboard) and mouse_x <= 405 - 25*(maincontrols != controls.keyboard) and mouse_y >= 850 and mouse_y <= 880){
							if (selecting == 0){
								if (LoadLevels()){
									state = menu.levels;
									draw_set_font(fnt_nexaBold90);
									for (var i=0;i<min(array_length(Levels),10);i++){
										Songs[i] = {x: 0, y: 0, pos: i, selected: false, song_index: 0, scroll: {based: 0.2*string_width("recreated by " + ((!is_undefined(Levels[i].recreated_by)) ? Levels[i].recreated_by[0] : "")) - 280, artist: 0.2*string_width(((!is_undefined(Levels[i].song_type) and Levels[i].song_type[0] != "") ? Levels[i].song_type[0] + " by " : "by ") + Levels[i].artist[0][0]) - 405, song: 0.3*string_width(Levels[i].song[0]) - 405, creator: 0.3*string_width(Levels[i].level_by[0]) - 280, timer: [0, 0, 0, 0]}, info: Levels[i]};
									}
								}else{
									state = menu.nolevels;
									data[1].index = 0;
									data[2].index = 2;
									data[3].index = 4;
									data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 445, angle: 0, scale: {x: 800, y: 455}, col: c_black, alpha: 0};
									data[5] = {sprite: spr_pixel, index: 0, x: 800, y: 450, angle: 0, scale: {x: 0, y: 285}, col: make_color_rgb(0,63,63), alpha: 1};
								}
								data[1].shake = 11;
							}else{ if (selecting == 1){
								state = menu.options;
								data[2].shake = 11;
								data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 790, angle: 0, scale: {x: 0, y: 0}, col: make_color_rgb(0, 63, 63), alpha: 211/255};
							}else{
								state = menu.credits;
								data[3].shake = 11;
								data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 220, angle: 0, scale: {x: 0, y: 250}, col: make_color_rgb(0, 63, 63), alpha: 211/255};
							}}
							timer = 0;
							audio_play_sound(snd_confirm, 0, false);
						}else{ if (mouse_x >= 1236 - 44*(zurdo and maincontrols == controls.keyboard) and mouse_x <= 1444 + 44*(zurdo and maincontrols == controls.keyboard) and mouse_y >= 850 and mouse_y <= 880){
							timer = 0;
							state = menu.quit;
							data[1].index = 0;
							data[2].index = 2;
							data[3].index = 4;
							data[4] = {sprite: spr_pixel, index: 0, x: 800, y: 445, angle: 0, scale: {x: 800, y: 455}, col: c_black, alpha: 0};
							data[5] = {sprite: spr_pixel, index: 0, x: 800, y: 450, angle: 0, scale: {x: 0, y: 100}, col: make_color_rgb(0,63,63), alpha: 1};
							audio_play_sound(snd_cancel, 0, false);
						}}}}}
					}
				}
				mouse.x = window_mouse_get_x();
				mouse.y = window_mouse_get_y();
				if (state != menu.nolevels and state != menu.quit){
					if (selecting == 0){
						data[1].index = 1;
						data[2].index = 2;
						data[3].index = 4;
					}else{ if (selecting == 1){
						data[1].index = 0;
						data[2].index = 3;
						data[3].index = 4;
					}else{
						data[1].index = 0;
						data[2].index = 2;
						data[3].index = 5;
					}}
				}
				if (state == menu.levels){
					selecting = [0, 0, 0];
					prev_val = 0;
				}
				for (var i=0;i<array_length(data);i++){
					var thing = data[i];
					if (variable_struct_exists(thing, "shake")){
						if (thing.shake > 0){
							thing.shake--;
						}
						thing.angle = irandom_range(-6/10*thing.shake, 6/10*thing.shake);
					}
				}
			break; }
			case menu.intro: {
				timer++;
				if (audio_get_name(music) == "mus_intro"){
					if (timer%5 == 0){
						data[array_length(data)] = {x: 0, y: 0, alpha: 1, direction: irandom(359), distance: 1000, col: c_white, scale: {x: 60/400, y: 60/400}, angle: irandom(359)};
					}
					for (var i=0;i<array_length(data);i++){
						data[i].angle++;
						data[i].distance -= 20;
						data[i].col = make_color_rgb(255,32 + 223/200*(200 - clamp(data[i].distance - 200, 0, 200)),112 + 143/200*(200 - clamp(data[i].distance - 200, 0, 200)));
						data[i].scale.x = 60/900*data[i].distance/900;
						data[i].scale.y = data[i].scale.x;
						data[i].x = 800 + data[i].distance*dcos(data[i].direction);
						data[i].y = 450 - data[i].distance*dsin(data[i].direction);
						if (data[i].distance < 300){
							data[i].alpha -= 0.125;
							if (data[i].alpha <= 0){
								array_delete(data, i, 1);
								i--;
							}
						}
					}
				}else{
					if (audio_get_name(music) != "mus_menu"){
						timer = 0;
						data = [];
						mouse.x = window_mouse_get_x();
						mouse.y = window_mouse_get_y();
						music = audio_play_sound(mus_menu,100,true);
					}
					if (window_mouse_get_x() != mouse.x or window_mouse_get_y() != mouse.y or mouse_check_button(mb_left)){
						cursor_sprite = spr_cursor;
					}
					mouse.x = window_mouse_get_x();
					mouse.y = window_mouse_get_y();
					if (timer <= 60){
						obj_DJBlixer.scale = 1 - 0.12/60*timer;
						obj_DJBlixer.DJ.table.y = 914 - 30/60*timer;
					}else{ if (timer <= 120){
						if (timer == 61){
							data[0] = {sprite: spr_shine, index: 0, x: 800, y: 170, scale: {x: 0, y: 0}, angle: 0, col: c_white, alpha: 1};
							data[1] = {sprite: spr_title, index: 0, x: 800, y: 170, scale: {x: 0, y: 0}, angle: 0, col: c_white, alpha: 1};
						}
						data[0].scale.x = 680/1000*dsin(180/30*max(timer - 90, 0));
						data[0].scale.y = data[0].scale.x;
						data[1].scale.x = dsin(90/10*clamp(timer - 100, 0, 10));
						data[1].scale.y = data[1].scale.x;
						obj_DJBlixer.scale = 0.88 - 0.28/30*min(timer - 60, 30);
						obj_DJBlixer.DJ.table.y = 884 - 69/30*min(timer - 60, 30);
					}else{
						if (timer == 121){
							array_delete(data, 0, 1);
							data[1] = {sprite: spr_buttons, index: 0, x: 800, y: 390, angle: 0, scale: {x: 1, y: 1}, col: c_white, alpha: 0};
							data[2] = {sprite: spr_buttons, index: 2, x: 300, y: 390, angle: 0, scale: {x: 1, y: 1}, col: c_white, alpha: 0};
							data[3] = {sprite: spr_buttons, index: 4, x: 1300, y: 390, angle: 0, scale: {x: 1, y: 1}, col: c_white, alpha: 0};
						}
						data[1].alpha = 1/10*clamp(timer - 210, 0, 10);
						data[2].alpha = 1/10*clamp(timer - 180, 0, 10);
						data[3].alpha = 1/10*clamp(timer - 195, 0, 10);
						data[1].angle = 6/10*random_range(10 - min(timer - 210, 10), min(timer - 210, 10) - 10);
						data[2].angle = 6/10*random_range(10 - min(timer - 180, 10), min(timer - 180, 10) - 10);
						data[3].angle = 6/10*random_range(10 - min(timer - 195, 10), min(timer - 195, 10) - 10);
					}}
					if (timer > 120){
						data[0].scale.x = 1 + 40/500*dsin(180/0.15*min(SongTime%0.48, 0.15));
						data[0].scale.y = data[0].scale.x;
						data[0].angle = random_range(6 - 6/0.15*min(SongTime%0.48, 0.15), 6/0.15*min(SongTime%0.48, 0.15) - 6);
					}
					if (timer == 300){
						state = menu.title;
						timer = 0;
						data[1].index = 1;
						data[1].shake = 11;
						data[2].shake = 0;
						data[3].shake = 0;
						bounce = true;
						texture_flush("tex_grp_onetime");
						audio_play_sound(snd_selecting, 0, false);
					}
				}
			break; }
			case menu.warnings: {
				timer++;
				timer2++;
				for (var i=0;i<8;i++){
					data[i].timer++;
					if (data[i].timer%50 <= 6){
						data[i].yscale = 1 + 0.15/6*(data[i].timer%50);
						data[i].xscale = 1 - 0.1/6*(data[i].timer%50);
					}else{ if (data[i].timer%50 <= 20){
						data[i].yscale = 1 + 0.15*dcos((data[i].timer%50 - 6)/14*270);
						data[i].xscale = 1 - 0.1*dcos((data[i].timer%50 - 6)/14*270);
					}}
					if (data[i].timer > 6 and data[i].timer <= 20){
						data[i].angle = 20/14*(data[i].timer - 6)*data[i].direction;
					}else{ if (data[i].timer > 56 and data[i].timer <= 70){
						data[i].angle = 20/14*(70 - data[i].timer)*data[i].direction;
					}}
					if (data[i].timer >= 100){
						data[i].direction = -data[i].direction;
						data[i].timer -= 100;
					}
				}
				if (timer > 60 and timer <= 120){
					image_alpha = (120 - timer)/60;
				}else{ if ((timer == 121 or timer == 241) and !CheckControlInput(maincontrols, zurdo, action.confirm)){
					timer--;
				}else{ if (timer > 120 and timer <= 240){
					image_angle = dsin((timer - 120)*1.5);
					if (timer == 180){
						text = ["Seizure Warning","This game comes with a lot of bright colored flashing lights,\nthe game comes with an option to reduce them but\ndoesn't totally remove them all for certain levels.\n\nIf you have an epileptic problem, I recommend to not play\nthis game, continue at your own risk.\n\nDiscretion is advised."];
					}
				}else{ if (timer > 240 and timer <= 300){
					image_alpha = (timer - 240)/60;
				}else{ if (timer >= 420){
					if (timer == 420){
						texture_prefetch("tex_grp_menu");
						texture_prefetch("tex_grp_ranking");
					}
					if (texture_is_ready("tex_grp_menu") and texture_is_ready("tex_grp_ranking")){
						timer = 0;
						data = [];
						state = menu.intro;
						instance_create_depth(0,0,-1,obj_DJBlixer);
						music = audio_play_sound(mus_intro,100,false);
					}
				}}}}}
			break; }
		}
		if (audio_get_name(music) == "mus_menu" and !audio_is_playing(music)){
			music = audio_play_sound(mus_menu,100,true);
		}
		if (bounce){
			camera_set_view_pos(view_camera[0], camera.x, camera.y - 4*dsin(180/0.1*min(SongTime%0.48, 0.1)));
			var songtimee = floor(SongTime/0.48);
			if (songtime != songtimee){
				songtime = songtimee;
				buttoff++;
				buttoff %= 4;
			}
		}
	}
}