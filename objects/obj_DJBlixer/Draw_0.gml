var angle = DJ.body.angle;
draw_sprite_ext(DJ.body.sprite,0,DJ.table.x + DJ.body.x*scale,DJ.table.y + DJ.body.y*scale,DJ.body.scale.x*scale,DJ.body.scale.y*scale,DJ.body.angle,DJ.body.col,1);
draw_sprite_ext(DJ.eye.sprite,0,DJ.table.x + (DJ.body.x + DJ.eye.x*dcos(angle) + DJ.eye.y*dsin(angle))*scale,DJ.table.y + (DJ.body.y + DJ.eye.y*dcos(angle) - DJ.eye.x*dsin(angle))*scale,DJ.eye.scale.x*scale,DJ.eye.scale.y*scale,angle,DJ.eye.col,1);
for (var i=0;i<array_length(DJ.brows);i++){
	draw_sprite_ext(spr_pixel,0,DJ.table.x + (DJ.body.x + DJ.brows[i].x*dcos(angle) + DJ.brows[i].y*dsin(angle))*scale,DJ.table.y + (DJ.body.y + DJ.brows[i].y*dcos(angle) - DJ.brows[i].x*dsin(angle))*scale,DJ.brows[i].scale*scale,12/2*scale,DJ.brows[i].angle + angle,DJ.brows[i].col,1);
}
if (SongTime > 2.16 and SongTime <= 9.4 and audio_get_name(obj_game.music) == "mus_intro"){
	for (var i=0;i<array_length(DJ.horns);i++){
		draw_sprite_ext(spr_triangle,0,DJ.table.x + (DJ.body.x + DJ.horns[i].x*dcos(angle) + DJ.horns[i].y*dsin(angle))*scale,DJ.table.y + (DJ.body.y + DJ.horns[i].y*dcos(angle) - DJ.horns[i].x*dsin(angle))*scale,25/1000*scale,25/1000*scale,DJ.horns[i].angle + angle,DJ.horns[i].col,DJ.horns[i].alpha);
	}
}
for (var i=0;i<array_length(DJ.mouth);i++){
	draw_sprite_ext(spr_triangle,0,DJ.table.x + (DJ.body.x + DJ.mouth[i].x*dcos(angle) + DJ.mouth[i].y*dsin(angle))*scale,DJ.table.y + (DJ.body.y + DJ.mouth[i].y*dcos(angle) - DJ.mouth[i].x*dsin(angle))*scale,25/1000*scale,DJ.mouth[i].scale*scale,DJ.mouth[i].angle + angle,DJ.mouth[i].col,1);
}
for (var i=0;i<array_length(DJ.hands.left);i++){
	draw_sprite_ext((i == 4) ? spr_DJhand : ((i == 0) ? spr_circle : spr_spikeball),0,DJ.table.x + DJ.hands.left[i].x*scale,DJ.table.y + DJ.hands.left[i].y*scale,DJ.hands.left[i].scale*scale,DJ.hands.left[i].scale*scale,DJ.hands.left[i].angle,DJ.hands.left[i].col,1);
}
for (var i=0;i<array_length(DJ.hands.right);i++){
	draw_sprite_ext((i == 4) ? spr_DJhand : ((i == 0) ? spr_circle : spr_spikeball),0,DJ.table.x + DJ.hands.right[i].x*scale,DJ.table.y + DJ.hands.right[i].y*scale,DJ.hands.right[i].scale*scale,DJ.hands.right[i].scale*scale,DJ.hands.right[i].angle,DJ.hands.right[i].col,1);
}
if (SongTime > 5.75 and SongTime <= 6.45 and audio_get_name(obj_game.music) == "mus_intro"){
	var mult = dsin(90/0.1*(min(SongTime - 5.75, 0.1) + max(SongTime - 6.35, 0)));
	draw_sprite_ext(spr_shine,0,800,690,1200/1000*mult,1200/1000*mult,0,c_white,1);
	for (var i=0;i<8;i++){
		draw_sprite_ext(spr_light,0,800,690,800/1000*mult,800/1000*mult,45*i - 240*SongTime,c_white,1);
	}
	var col = (SongTime <= 6.15) ? c_white : make_color_rgb(0,255,255);
	draw_sprite_ext(spr_hole,0,800,690,(1200/0.2*(min(SongTime - 5.75, 0.2) - max(SongTime - 6.25, 0)))/1000,(1200/0.2*(min(SongTime - 5.75, 0.2) - max(SongTime - 6.25, 0)))/1000,0,col,(max(5.95 - SongTime, 0) + max(SongTime - 6.25, 0))/0.2);
	draw_sprite_ext(spr_hole,0,800,690,(1200/0.2*(clamp(SongTime - 5.85, 0, 0.2) - clamp(SongTime - 6.15, 0, 0.2)))/1000,(1200/0.2*(clamp(SongTime - 5.85, 0, 0.2) - clamp(SongTime - 6.15, 0, 0.2)))/1000,0,col,(clamp(6.05 - SongTime, 0, 0.2) + clamp(SongTime - 6.15, 0, 0.2))/0.2);
}
draw_sprite_ext(spr_DJheadphones,DJ.headphones.index,DJ.table.x + (DJ.body.x + DJ.headphones.y*dsin(angle))*scale,DJ.table.y + (DJ.body.y + DJ.headphones.y*dcos(angle))*scale,DJ.headphones.scale*scale,DJ.headphones.scale*scale,angle,DJ.headphones.col,1);
draw_sprite_ext(spr_DJsetup,0,DJ.table.x,DJ.table.y + DJ.setup.y*scale,DJ.setup.scale*scale,DJ.setup.scale*scale,0,DJ.setup.col,1);
if (not (audio_get_name(obj_game.music) == "mus_intro")){
	draw_sprite_ext(spr_DJtable,0,DJ.table.x,DJ.table.y,828/500*scale,828/500*scale,0,c_white,1);
}
