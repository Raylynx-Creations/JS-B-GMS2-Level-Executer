for (var i=0;i<4;i++){
	DJ.hands.right[i].angle += 1;
	DJ.hands.left[i].angle += 1;
}
if (audio_get_name(obj_game.music) == "mus_intro"){
	if (SongTime <= 1.09){
		DJ.body.scale.x = 40/1000*dsin(90/0.4*min(SongTime, 0.4));
		DJ.body.scale.y = DJ.body.scale.x;
		DJ.body.col = make_color_rgb(255, 32 - abs(223*dsin(270/0.2*min(SongTime, 0.4))), 112 - 143*abs(dsin(270/0.2*min(SongTime, 0.4))));
	}else{ if (SongTime <= 3.33){
		DJ.body.sprite = (SongTime > 1.49) ? spr_DJbody : spr_circle;
		DJ.body.scale.x = (8 + 32*dcos(90/0.4*min(SongTime - 1.09, 0.4)) + 252*dsin(90/0.3*clamp(SongTime - 1.49, 0, 0.3)))/1000;
		DJ.body.scale.y = DJ.body.scale.x;
		DJ.body.col = make_color_rgb(255, 143.5 - 111.5*dcos(1620/0.4*min(SongTime - 1.09, 0.4)) - 223*dsin(90/0.2*clamp(SongTime - 1.79, 0, 0.2)), 183.5 - 71.5*dcos(1620/0.4*min(SongTime - 1.09, 0.4)) - 143*dsin(90/0.2*clamp(SongTime - 1.79, 0, 0.2)));
	}else{
		DJ.body.sprite = spr_DJbody;
		DJ.body.scale.x = 260/1000;
		DJ.body.col = make_color_rgb(255,32,112);
		if (SongTime <= 4.02){
			DJ.body.scale.y = (260 - 23*dsin(90/0.2*min(SongTime - 3.33, 0.2) + 90/0.1*clamp(SongTime - 3.63, 0, 0.1)))/1000;
			DJ.body.y = -464 - 11.5*dsin(90/0.2*min(SongTime - 3.33, 0.2) + 90/0.1*clamp(SongTime - 3.63, 0, 0.1));
		}else{
			DJ.body.scale.y = 260/1000;
			if (SongTime <= 6.8){
				DJ.body.y = -544 - 20*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			}else{ if (SongTime <= 9.5){
				DJ.body.y = -532 - 40*dcos(180/0.75*min(SongTime - 6.8, 0.75)) - 72*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) + 8*dsin(180/0.1*clamp(SongTime - 9.3, 0, 0.1));
			}else{
				DJ.body.y = -378 - 42*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075));
			}}
			if (SongTime <= 4.45){
				DJ.body.x = 40 - 160*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 40*dcos(90/0.2*max(SongTime - 4.25, 0));
				DJ.body.angle = 20*dsin(90/0.1*(min(SongTime - 4.02, 0.1) + max(SongTime - 4.25, 0)/2));
			}else{ if (SongTime <= 4.88){
				DJ.body.x = -160 + 160*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 40*dcos(90/0.2*max(SongTime - 4.68, 0));
				DJ.body.angle = -20*dsin(90/0.1*(min(SongTime - 4.45, 0.1) + max(SongTime - 4.68, 0)/2));
			}else{
				DJ.body.x = -16 - 156*dsin(90/0.1*clamp(SongTime - 9.5, 0, 0.1)) + 16*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075));
				DJ.body.angle = 22.5*dsin(90/0.1*clamp(SongTime - 9.5, 0, 0.1));
			}}
		}
	}}
	if (SongTime > 2.16 and SongTime <= 9.4){
		if (SongTime <= 2.36){
			DJ.horns[0].alpha = 1/0.1*min(SongTime - 2.16, 0.1);
			DJ.horns[1].alpha = DJ.horns[0].alpha;
			DJ.horns[0].col = make_color_rgb(255,255 - 223*dsin(90/0.1*max(SongTime - 2.26, 0)),255 - 143*dsin(90/0.1*max(SongTime - 2.26, 0)));
			DJ.horns[1].col = DJ.horns[0].col;
		}else{
			if (SongTime <= 9.3){
				DJ.horns[0].alpha = 1;
				DJ.horns[1].alpha = 1;
				DJ.horns[0].col = make_color_rgb(255,32,112);
				DJ.horns[1].col = DJ.horns[0].col;
			}else{
				DJ.horns[0].alpha = 1/0.05*min(9.4 - SongTime, 0.05);
				DJ.horns[1].alpha = DJ.horns[0].alpha;
				DJ.horns[0].col = make_color_rgb(255,32 + 223/0.05*min(SongTime - 9.35, 0.05),112 + 143/0.05*min(SongTime - 9.35, 0.05));
				DJ.horns[1].col = DJ.horns[0].col;
			}
			if (SongTime <= 3.73){
				DJ.horns[0].y = -150*dsin(45) + 11.5*dsin(90/0.2*clamp(SongTime - 3.33, 0, 0.2) + 90/0.1*max(SongTime - 3.63, 0));
			}else{
				DJ.horns[0].y = -150*dsin(45);
			}
			DJ.horns[1].y = DJ.horns[0].y;
		}
	}
	if (SongTime > 2.76){
		if (SongTime <= 3.33){
			DJ.eye.scale.x = (40*dsin(90/0.2*min(SongTime - 2.76, 0.2)) + 40*dsin(180/0.2*min(SongTime - 2.76, 0.2)))/1000;
			DJ.eye.scale.y = DJ.eye.scale.x*abs(dcos(180/0.2*max(SongTime - 3.13, 0)));
			DJ.eye.col = make_color_rgb(255,255 - 223*dsin(90/0.2*min(SongTime - 2.76, 0.2)),255 - 143*dsin(90/0.2*min(SongTime - 2.76, 0.2)));
		}else{
			if (SongTime <= 3.68){
				DJ.eye.sprite = spr_circle;
				DJ.eye.scale.x = 40/1000;
			}else{
				DJ.eye.sprite = spr_DJeye;
				DJ.eye.scale.x = 40/238;
			}
			if (SongTime <= 3.78){
				DJ.eye.scale.y = (40 - 5*dsin(90/0.2*min(SongTime - 3.33, 0.2) + 90/0.1*clamp(SongTime - 3.63, 0, 0.1)))/sprite_get_height(DJ.eye.sprite);
				DJ.eye.y = -16*dsin(90/0.2*min(SongTime - 3.33, 0.2) + 90/0.1*clamp(SongTime - 3.63, 0, 0.1)) - (9 - 9*dcos(90/0.1*clamp(SongTime - 3.63, 0, 0.1)));
				DJ.eye.col = make_color_rgb(255,143.5 - 111.5*dcos(360/0.1*max(SongTime - 3.68, 0)),183.5 - 71.5*dcos(360/0.1*max(SongTime - 3.68, 0)));
			}else{
				DJ.eye.scale.y = 40/238;
				DJ.eye.col = make_color_rgb(255,32,112);
				if (SongTime <= 7.65){
					DJ.eye.y = 1 - 10*dcos(180/0.8*clamp(SongTime - 5.75, 0, 0.8));
				}else{ if (SongTime <= 8.55){
					DJ.eye.y = 1 - 12*dcos(180/0.15*max(SongTime - 8.4, 0)) + 22*dcos(180/0.6*min(SongTime - 7.65, 0.6));
				}else{
					DJ.eye.y = -9;
				}}
			}
		}
	}
	if (SongTime > 3.33){
		if (SongTime <= 3.63){
			DJ.brows[0].scale = 42/2*dsin(90/0.2*min(SongTime - 3.33, 0.2));
			DJ.brows[1].scale = DJ.brows[0].scale;
			DJ.brows[0].x = -DJ.brows[0].scale;
			DJ.brows[1].x = -DJ.brows[0].x;
			DJ.brows[0].y = DJ.eye.y - DJ.eye.scale.y/2*1000 - 6*dcos(180/0.2*min(SongTime - 3.33, 0.2));
			DJ.brows[1].y = DJ.brows[0].y;
		}else{
			DJ.brows[0].scale = 52/2;
			DJ.brows[1].scale = 52/2;
			if (SongTime <= 3.78){
				DJ.brows[0].angle = 22.5*dcos(90/0.1*min(SongTime - 3.63, 0.1)) - 22.5;
				DJ.brows[1].angle = -DJ.brows[0].angle;
				DJ.brows[0].x = -42 + 26*dcos(DJ.brows[0].angle) - 3*dsin(DJ.brows[0].angle);
				DJ.brows[1].x = -DJ.brows[0].x;
				DJ.brows[0].y = DJ.eye.y - DJ.eye.scale.y/2*sprite_get_height(DJ.eye.sprite) + 28 - 6*(1 - dcos(90/0.1*min(SongTime - 3.63, 0.1))) - 16*dcos(90/0.1*min(SongTime - 3.63, 0.1)) - 6*dcos(DJ.brows[0].angle) + 26*dsin(DJ.brows[0].angle);
				DJ.brows[1].y = DJ.brows[0].y;
				DJ.brows[0].col = make_color_rgb(255,143.5 - 111.5*dcos(360/0.1*max(SongTime - 3.68, 0)),183.5 - 71.5*dcos(360/0.1*max(SongTime - 3.68, 0)));
				DJ.brows[1].col = DJ.brows[0].col;
			}else{
				DJ.brows[0].angle = -22.5;
				DJ.brows[1].angle = 22.5;
				DJ.brows[0].x = -42 + 26*dcos(-22.5) - 3*dsin(-22.5);
				DJ.brows[1].x = -DJ.brows[0].x;
				DJ.brows[0].y = DJ.eye.y - DJ.eye.scale.y/2*238 + 22 - 6*dcos(-22.5) + 26*dsin(-22.5);
				DJ.brows[1].y = DJ.brows[0].y;
				DJ.brows[0].col = make_color_rgb(255,32,112);
				DJ.brows[1].col = DJ.brows[0].col;
			}
		}
	}
	if (SongTime > 3.63){
		if (SongTime <= 3.78){
			DJ.mouth[0].scale = 25/1000*dsin(90/0.05*min(SongTime - 3.63, 0.05));
			DJ.mouth[1].scale = DJ.mouth[0].scale;
			DJ.mouth[0].x = -19*dsin(90/0.05*clamp(SongTime - 3.68, 0, 0.05));
			DJ.mouth[1].x = -DJ.mouth[0].x;
			DJ.mouth[0].y = 46 + 25/2*dsin(90/0.05*min(SongTime - 3.63, 0.05)) - 144*DJ.mouth[0].scale;
			DJ.mouth[1].y = DJ.mouth[0].y;
			DJ.mouth[0].col = make_color_rgb(255,143.5 - 111.5*dcos(360/0.1*max(SongTime - 3.68, 0)),183.5 - 71.5*dcos(360/0.1*max(SongTime - 3.68, 0)));
			DJ.mouth[1].col = DJ.mouth[0].col;
		}else{
			DJ.mouth[0].scale = 25/1000;
			DJ.mouth[1].scale = 25/1000;
			DJ.mouth[0].x = -19;
			DJ.mouth[1].x = 19;
			DJ.mouth[0].col = make_color_rgb(255,32,112);
			DJ.mouth[1].col = DJ.mouth[0].col;
			if (SongTime <= 7.65){
				DJ.mouth[0].y = 68.5 - 144*DJ.mouth[0].scale - 10*dcos(180/0.8*clamp(SongTime - 5.75, 0, 0.8));
			}else{ if (SongTime <= 8.55){
				DJ.mouth[0].y = 68.5 - 144*DJ.mouth[0].scale - 12*dcos(180/0.15*max(SongTime - 8.4, 0)) + 22*dcos(180/0.6*min(SongTime - 7.65, 0.6));
			}else{ if (SongTime <= 9.5){
				DJ.mouth[0].y = 58.5 - 144*DJ.mouth[0].scale;
			}else{ if (array_length(DJ.mouth) < 4){
				var col = make_color_rgb(255,32,112);
				DJ.mouth[2] = {scale: 25/1000, col: col, x: DJ.mouth[0].x, y: 84.5, angle: 0};
				DJ.mouth[3] = {scale: 25/1000, col: col, x: DJ.mouth[1].x, y: 84.5, angle: 0};
				DJ.mouth[0].y = 32.5 - 144*DJ.mouth[0].scale;
			}}}}
			DJ.mouth[1].y = DJ.mouth[0].y;
		}
	}
	if (SongTime > 4.02){
		for (var i=0;i<5;i++){
			if (DJ.hands.right[i].scale == 0){
				DJ.hands.right[i].scale = (32 + 28*floor((i + 4)/5) + 20*i + 20*floor(i/4))/((i == 4) ? 388 : 1000);
			}
		}
		if (SongTime <= 4.45){
			DJ.hands.right[0].x = 36 - 8*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 36*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[0].y = -464 - 40*dsin(90/0.1*min(SongTime - 4.02, 0.1));
			DJ.hands.right[1].x = 20 + 68*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 20*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[1].y = -444 - 80*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 20*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[2].x = 12 + 168*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 12*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[2].y = -424 - 120*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 40*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[3].x = 2 + 288*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 2*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[3].y = -404 - 160*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 60*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[4].x = -10 + 440*dsin(90/0.1*min(SongTime - 4.02, 0.1)) + 10*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[4].y = -374 - 200*dsin(90/0.1*min(SongTime - 4.02, 0.1)) - 90*dcos(90/0.2*max(SongTime - 4.25, 0));
			DJ.hands.right[4].angle = 95 + 10*dcos(90/0.2*max(SongTime - 4.25, 0));
		}else{ if (SongTime <= 6.8){
			DJ.hands.right[0].x = -12 + 164*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 40*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.right[0].y = -604 + 20*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.right[1].x = 28 + 164*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 60*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.right[1].y = -644 + 20*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 20*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.right[2].x = 100 + 160*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 80*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.right[2].y = -704 + 20*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 60*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.right[3].x = 170 + 160*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 120*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.right[3].y = -654 + 50*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 10*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.right[4].x = 250 + 150*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 180*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.right[4].y = -594 + 110*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 80*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.right[4].angle = 53 - 25*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 42*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
		}else{ if (SongTime <= 9.5){
			DJ.hands.right[0].x = 148 + 8*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) - 4*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6));
			DJ.hands.right[0].y = -516 - 8*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) - 120*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 40*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[1].x = 204 + 6*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) - 6*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 12*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[1].y = -538 - 16*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) - 120*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 50*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[2].x = 286 + 8*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) - 10*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 24*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[2].y = -592 - 22*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) - 70*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 100*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[3].x = 360 + 6*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) - 18*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 18*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[3].y = -606 - 24*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) + 42*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 116*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[4].x = 400 - 54*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) + 54*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[4].y = -630 - 6*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) + 172*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 120*dcos(180/0.75*min(SongTime - 6.8, 0.75));
			DJ.hands.right[4].angle = -71 + 37.5*dcos(180/0.15*clamp(SongTime - 8.4, 0, 0.15)) + 27.5*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) + 34*dcos(180/0.75*min(SongTime - 6.8, 0.75));
		}else{
			DJ.hands.right[0].x = 130 + 14*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 140*dsin(90/0.1*min(SongTime - 9.5, 0.1));
			DJ.hands.right[0].y = -328 - 20*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 60*dsin(90/0.1*min(SongTime - 9.5, 0.1));
			DJ.hands.right[1].x = 186 + 30*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 160*dsin(90/0.125*min(SongTime - 9.5, 0.125));
			DJ.hands.right[1].y = -332 - 20*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 112*dsin(90/0.125*min(SongTime - 9.5, 0.125));
			DJ.hands.right[2].x = 332 - 20*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 244*dsin(90/0.15*min(SongTime - 9.5, 0.15));
			DJ.hands.right[2].y = -370 - 30*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 172*dsin(90/0.15*min(SongTime - 9.5, 0.15));
			DJ.hands.right[3].x = 546 - 156*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 332*dsin(90/0.175*min(SongTime - 9.5, 0.175));
			DJ.hands.right[3].y = -328 - 180*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 184*dsin(90/0.175*min(SongTime - 9.5, 0.175));
			DJ.hands.right[4].x = 654 - 254*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 420*dsin(90/0.2*min(SongTime - 9.5, 0.2));
			DJ.hands.right[4].y = -228 - 448*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 136*dsin(90/0.2*min(SongTime - 9.5, 0.2));
			DJ.hands.right[4].angle = -435 + 265*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) + 40*dsin(90/0.2*min(SongTime - 9.5, 0.2));
		}}}
	}
	if (SongTime > 4.45){
		for (var i=0;i<5;i++){
			if (DJ.hands.left[i].scale == 0){
				DJ.hands.left[i].scale = (32 + 28*floor((i + 4)/5) + 20*i + 20*floor(i/4))/((i == 4) ? 388 : 1000);
			}
		}
		if (SongTime <= 6.8){
			DJ.hands.left[0].x = -160 + 8*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 40*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.left[0].y = -544 - 40*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 20*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.left[1].x = -124 - 68*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 4*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.left[1].y = -544 - 80*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 20*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.left[2].x = -92 - 168*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 28*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.left[2].y = -564 - 120*dsin(90/0.1*min(SongTime - 4.45, 0.1)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.left[3].x = -42 - 288*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 78*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.left[3].y = -444 - 160*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 120*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.left[4].x = 40 - 440*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 160*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
			DJ.hands.left[4].y = -284 - 200*dsin(90/0.1*min(SongTime - 4.45, 0.1)) - 280*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2)) + 100*dcos(180/0.87*clamp(SongTime - 4.88, 0, 0.87));
			DJ.hands.left[4].angle = -28 - 77*dcos(90/0.2*clamp(SongTime - 4.68, 0, 0.2));
		}else{ if (SongTime <= 9.5){
			for (var i=0;i<5;i++){
				DJ.hands.left[i].x = -DJ.hands.right[i].x;
				DJ.hands.left[i].y = DJ.hands.right[i].y;
			}
			DJ.hands.left[4].angle = -DJ.hands.right[4].angle;
		}else{
			DJ.hands.left[0].x = -128 - 16*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 164*dsin(90/0.1*min(SongTime - 9.5, 0.1));
			DJ.hands.left[0].y = -268 - 80*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 12*dsin(90/0.1*min(SongTime - 9.5, 0.1));
			DJ.hands.left[1].x = -192 - 24*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 160*dsin(90/0.125*min(SongTime - 9.5, 0.125));
			DJ.hands.left[1].y = -234 - 118*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 36*dsin(90/0.125*min(SongTime - 9.5, 0.125));
			DJ.hands.left[2].x = -246 - 66*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 120*dsin(90/0.15*min(SongTime - 9.5, 0.15));
			DJ.hands.left[2].y = -128 - 272*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 64*dsin(90/0.15*min(SongTime - 9.5, 0.15));
			DJ.hands.left[3].x = -282 - 108*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 96*dsin(90/0.175*min(SongTime - 9.5, 0.175));
			DJ.hands.left[3].y = -16 - 492*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 64*dsin(90/0.175*min(SongTime - 9.5, 0.175));
			DJ.hands.left[4].x = -196 - 204*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) - 192*dsin(90/0.2*min(SongTime - 9.5, 0.2));
			DJ.hands.left[4].y = 8 - 684*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) + 28*dsin(90/0.2*min(SongTime - 9.5, 0.2));
			DJ.hands.left[4].angle = 275 - 105*dcos(90/0.075*clamp(SongTime - 9.875, 0, 0.075)) + 75*dsin(90/0.2*min(SongTime - 9.5, 0.2));
		}}
	}
	if (SongTime > 5.95){
		if (SongTime <= 6.8){
			DJ.setup.scale = 728/500*dsin(90/0.1*min(SongTime - 5.95, 0.1));
			DJ.headphones.scale = 386/1000*dsin(90/0.1*min(SongTime - 5.95, 0.1));
			DJ.setup.col = make_color_rgb(255*dcos(90/0.1*clamp(SongTime - 6.45, 0, 0.1)),255,255);
			DJ.headphones.col = DJ.setup.col;
			DJ.headphones.y = 420 - 100*dsin(90/0.1*min(SongTime - 5.95, 0.1));
		}else{
			DJ.setup.scale = 728/500;
			DJ.headphones.scale = 386/1000;
			DJ.setup.col = make_color_rgb(0,255,255);
			DJ.headphones.col = DJ.setup.col;
			if (SongTime <= 9.5){
				DJ.headphones.y = 250 + 40*dcos(180/0.75*min(SongTime - 6.8, 0.75)) + 318*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6)) - 288*dcos(90/0.75*clamp(SongTime - 8.55, 0, 0.75));
				DJ.setup.y = -152 - 72*dcos(180/0.6*clamp(SongTime - 7.65, 0, 0.6));
			}else{
				DJ.headphones.y = -108;
				if (SongTime <= 9.6){
					DJ.setup.y = -80 - 144*dsin(90/0.1*(SongTime - 9.5));
				}else{
					DJ.setup.y = -224;
				}
			}
		}
	}
}else{
	timer++;
	if (timer <= 120){
		if (timer == 1){
			var col = make_color_rgb(255,32,112);
			if (array_length(DJ.mouth) > 2){
				array_delete(DJ.mouth,2,2);
			}
			variable_struct_remove(DJ,"horns");
			DJ.mouth[0].angle = 180;
			DJ.mouth[1].angle = 180;
			DJ.mouth[0].scale = 25/1000;
			DJ.mouth[1].scale = 25/1000;
			DJ.mouth[0].x = -19;
			DJ.mouth[1].x = 19;
			DJ.mouth[0].col = col;
			DJ.mouth[1].col = col;
			DJ.body.sprite = spr_DJbody;
			DJ.body.scale.x = 260/1000;
			DJ.body.scale.y = 260/1000;
			DJ.body.col = col;
			DJ.body.angle = 22.5;
			DJ.body.x = -172;
			DJ.eye.scale.x = 40/238;
			DJ.eye.scale.y = 40/238;
			DJ.eye.col = col;
			DJ.eye.sprite = spr_DJeye;
			DJ.brows[0].scale = 52/2;
			DJ.brows[1].scale = 52/2;
			DJ.brows[0].angle = -22.5;
			DJ.brows[1].angle = 22.5;
			DJ.brows[0].x = -42 + 26*dcos(-22.5) - 3*dsin(-22.5);
			DJ.brows[1].x = -DJ.brows[0].x;
			DJ.brows[0].col = col;
			DJ.brows[1].col = col;
			DJ.setup.scale = 728/500;
			DJ.headphones.scale = 386/1000;
			DJ.setup.col = make_color_rgb(0,255,255);
			DJ.headphones.col = DJ.setup.col;
			DJ.headphones.y = -108;
			DJ.setup.y = -224;
			for (var i=0;i<5;i++){
				if (DJ.hands.right[i].scale == 0){
					DJ.hands.right[i].scale = (32 + 28*floor((i + 4)/5) + 20*i + 20*floor(i/4))/((i == 4) ? 388 : 1000);
				}
				if (DJ.hands.left[i].scale == 0){
					DJ.hands.left[i].scale = (32 + 28*floor((i + 4)/5) + 20*i + 20*floor(i/4))/((i == 4) ? 388 : 1000);
				}
			}
			DJ.hands.right[0].x = -10;
			DJ.hands.right[1].x = 26;
			DJ.hands.right[2].x = 88;
			DJ.hands.right[3].x = 214;
			DJ.hands.right[4].y = -364;
			DJ.hands.left[0].x = -292;
			DJ.hands.left[1].x = -352;
			DJ.hands.left[2].x = -366;
			DJ.hands.left[3].x = -378;
			DJ.hands.left[4].x = -388;
			DJ.hands.left[4].y = 36;
			DJ.hands.left[4].angle = -10;
		}
		DJ.body.y = -426 + 48*abs(dcos(90/15*timer));
		DJ.eye.y = -32.5 + 44*abs(dcos(90/15*(timer - 7.5)));
		DJ.mouth[0].y = 35 - 144*DJ.mouth[0].scale + 44*abs(dcos(90/15*(timer - 7.5)));
		DJ.mouth[1].y = DJ.mouth[0].y;
		DJ.hands.right[0].y = -420 + 32*abs(dcos(90/15*timer));
		DJ.hands.right[1].y = -468 + 24*abs(dcos(90/15*timer));
		DJ.hands.right[2].y = -558 + 16*abs(dcos(90/15*timer));
		DJ.hands.right[3].y = -520 + 8*abs(dcos(90/15*timer));
		DJ.hands.left[0].y = -320 + 40*abs(dcos(90/15*timer));
		DJ.hands.left[1].y = -302 + 32*abs(dcos(90/15*timer));
		DJ.hands.left[2].y = -208 + 16*abs(dcos(90/15*timer));
		DJ.hands.left[3].y = -88 + 8*abs(dcos(90/15*timer));
	}else{ if (timer <= 135){
		if (timer == 121){
			var col = make_color_rgb(255,32,112);
			DJ.mouth[2] = {scale: 25/1000, col: col, x: -38, y: 0, angle: 0};
			DJ.mouth[3] = {scale: 25/1000, col: col, x: 0, y: 0, angle: 0};
			DJ.mouth[4] = {scale: 25/1000, col: col, x: 38, y: 0, angle: 0};
		}
		DJ.mouth[2].y = 75 - 10*dcos(90/15*(timer - 120)) + 10.5*dcos(90/7*min(timer - 120, 7)) - 144*DJ.mouth[0].scale;
		DJ.mouth[3].y = DJ.mouth[2].y;
		DJ.mouth[4].y = DJ.mouth[2].y;
		DJ.mouth[0].y = 42 + 10*dcos(90/15*(timer - 120)) + 10.5*dcos(90/7*min(timer - 120, 7)) - 144*DJ.mouth[2].scale;
		DJ.mouth[1].y = DJ.mouth[0].y;
		DJ.eye.y = -9 + 20.5*dcos(90/15*(timer - 120));
		DJ.body.x = -172 + 92*dsin(90/15*(timer - 120));
		DJ.body.y = -378 - 64*dsin(90/15*(timer - 120));
		DJ.body.angle = 22.5 - 37.5*dsin(90/15*(timer - 120));
		DJ.hands.right[0].x = -10 + 68*dsin(90/15*(timer - 120));
		DJ.hands.right[0].y = -388 + 24*dsin(90/15*(timer - 120));
		DJ.hands.right[1].x = 26 + 76*dsin(90/15*(timer - 120));
		DJ.hands.right[1].y = -444 + 28*dsin(90/15*(timer - 120));
		DJ.hands.right[2].x = 88 + 76*dsin(90/15*(timer - 120));
		DJ.hands.right[2].y = -542 + 44*dsin(90/15*(timer - 120));
		DJ.hands.right[3].x = 214 + 64*dsin(90/15*(timer - 120));
		DJ.hands.right[3].y = -512 - 12*dsin(90/15*(timer - 120));
		DJ.hands.left[0].x = -292 + 50*dsin(90/15*(timer - 120));
		DJ.hands.left[0].y = -280 - 146*dsin(90/15*(timer - 120));
		DJ.hands.left[1].x = -352 + 46*dsin(90/15*(timer - 120));
		DJ.hands.left[1].y = -270 - 196*dsin(90/15*(timer - 120));
		DJ.hands.left[2].x = -366 + 32*dsin(90/15*(timer - 120));
		DJ.hands.left[2].y = -192 - 376*dsin(90/15*(timer - 120));
		DJ.hands.left[3].x = -378 + 70*dsin(90/15*(timer - 120));
		DJ.hands.left[3].y = -80 - 620*dsin(90/15*(timer - 120));
		DJ.hands.left[4].x = -388 + 132*dsin(90/15*(timer - 120));
		DJ.hands.left[4].y = 36 - 880*dsin(90/15*(timer - 120));
		DJ.hands.left[4].angle = -10 - 192.5*dsin(90/15*(timer - 120));
	}else{ if (timer <= 225){
		DJ.mouth[2].y = 69 + 6*abs(dcos(90/15*(timer - 135))) - 144*DJ.mouth[0].scale;
		DJ.mouth[3].y = DJ.mouth[2].y;
		DJ.mouth[4].y = DJ.mouth[2].y;
		DJ.mouth[0].y = 48 - 6*abs(dcos(90/15*(timer - 135))) - 144*DJ.mouth[2].scale;
		DJ.mouth[1].y = DJ.mouth[0].y;
		DJ.body.x = -90 + 10*abs(dcos(90/15*(timer - 135)));
		DJ.body.y = -414 - 28*abs(dcos(90/15*(timer - 135)));
		DJ.hands.right[0].x = 48 + 10*abs(dcos(90/15*(timer - 135)));
		DJ.hands.right[0].y = -350 - 14*abs(dcos(90/15*(timer - 135)));
		DJ.hands.right[1].x = 88 + 14*abs(dcos(90/15*(timer - 135)));
		DJ.hands.right[1].y = -402 - 14*abs(dcos(90/15*(timer - 135)));
		DJ.hands.right[2].x = 152 + 12*abs(dcos(90/15*(timer - 135)));
		DJ.hands.right[2].y = -486 - 12*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[0].x = -244 + 2*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[0].y = -386 - 40*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[1].x = -308 + 2*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[1].y = -406 - 60*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[2].x = -398 + 64*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[2].y = -456 - 112*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[3].x = -382 + 74*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[3].y = -570 - 130*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[4].x = -304 + 48*abs(dcos(90/15*(timer - 135)));
		DJ.hands.left[4].y = -706 - 138*abs(dcos(90/15*(timer - 135)));
	}else{ if (timer <= 240){
		DJ.mouth[2].y = 65 + 10*dcos(90/15*(timer - 225)) - 144*DJ.mouth[0].scale;
		DJ.mouth[3].y = DJ.mouth[2].y;
		DJ.mouth[4].y = DJ.mouth[2].y;
		DJ.mouth[0].y = 52 - 10*dcos(90/15*(timer - 225)) - 144*DJ.mouth[2].scale;
		DJ.mouth[1].y = DJ.mouth[0].y;
		DJ.body.x = -104 + 24*dcos(90/15*(timer - 225));
		DJ.body.y = -394 - 48*dcos(90/15*(timer - 225));
		DJ.body.angle = 15 - 30*dcos(90/15*(timer - 225));
		DJ.hands.right[0].x = 54 + 4*dcos(90/15*(timer - 225));
		DJ.hands.right[0].y = -366 + 2*dcos(90/15*(timer - 225));
		DJ.hands.right[1].x = 100 + 2*dcos(90/15*(timer - 225));
		DJ.hands.right[1].y = -416;
		DJ.hands.right[2].x = 162 + 2*dcos(90/15*(timer - 225));
		DJ.hands.right[2].y = -498;
		DJ.hands.right[3].x = 276 + 2*dcos(90/15*(timer - 225));
		DJ.hands.right[3].y = -512 - 12*dcos(90/15*(timer - 225));
		DJ.hands.left[0].x = -218 - 24*dcos(90/15*(timer - 225));
		DJ.hands.left[0].y = -282 - 144*dcos(90/15*(timer - 225));
		DJ.hands.left[1].x = -276 - 30*dcos(90/15*(timer - 225));
		DJ.hands.left[1].y = -242 - 224*dcos(90/15*(timer - 225));
		DJ.hands.left[2].x = -364 + 30*dcos(90/15*(timer - 225));
		DJ.hands.left[2].y = -192 - 376*dcos(90/15*(timer - 225));
		DJ.hands.left[3].x = -464 + 156*dcos(90/15*(timer - 225));
		DJ.hands.left[3].y = -272 - 428*dcos(90/15*(timer - 225));
		DJ.hands.left[4].x = -418 + 162*dcos(90/15*(timer - 225));
		DJ.hands.left[4].y = -434 - 410*dcos(90/15*(timer - 225));
		DJ.hands.left[4].angle = -257.5 + 55*dcos(90/15*(timer - 225));
	}else{
		if (timer == 241){
			array_delete(DJ.mouth,2,3);
			DJ.mouth[0].y = 58.5 - 144*DJ.mouth[0].scale;
			DJ.mouth[1].y = DJ.mouth[0].y;
		}
		DJ.body.y = -397 + 34*abs(dsin(90/15*(timer - 240)));
		DJ.hands.right[0].x = 54 + 2*abs(dsin(90/15*(timer - 240)));
		DJ.hands.right[0].y = -366 + 10*abs(dsin(90/15*(timer - 240)));
		DJ.hands.right[1].y = -416 + 8*abs(dsin(90/15*(timer - 240)));
		DJ.hands.right[2].y = -498 + 6*abs(dsin(90/15*(timer - 240)));
		DJ.hands.left[0].y = -282 + 30*abs(dsin(90/15*(timer - 240)));
		DJ.hands.left[1].x = -276 + 6*abs(dsin(90/15*(timer - 240)));
		DJ.hands.left[1].y = -242 + 34*abs(dsin(90/15*(timer - 240)));
		DJ.hands.left[2].y = -192 + 6*abs(dsin(90/15*(timer - 240)));
		DJ.hands.left[4].y = -434 + 34*abs(dsin(90/15*(timer - 240)));
	}}}}
	DJ.hands.right[4].x = 282 - 48*(dcos(90/6*min(timer%30, 6)) + (1 - dcos(90/6*clamp(timer%30 - 15, 0, 6))));
	DJ.hands.right[4].angle = 5 - 40*(dcos(90/6*min(timer%30, 6)) + (1 - dcos(90/6*clamp(timer%30 - 15, 0, 6))));
	DJ.brows[0].y = 22 + DJ.eye.y - DJ.eye.scale.y/2*238 - 6*dcos(-22.5) + 26*dsin(-22.5);
	DJ.brows[1].y = DJ.brows[0].y;
}
