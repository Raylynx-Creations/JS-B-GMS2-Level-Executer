draw_sprite(spr_body, 0, x, y);
draw_sprite(spr_eye, 0, x + Eye.x, y + Eye.y);
for (var i=0;i<2;i++){
	draw_sprite_ext(spr_ribon, 0, x + Ribons[0].x*(1 - 2*i), y + Ribons[0].y, 1, 1, Ribons[0].rot*(1 - 2*i), c_white, 1);
	draw_sprite_ext(spr_ribon, 0, x + Ribons[1].x*(1 - 2*i), y + Ribons[1].y, 0.64, 0.64, Ribons[1].rot*(1 - 2*i), c_white, 1);
}
draw_sprite_ext(spr_stick, 0, x + Stick.x, y + Stick.y, 1, 1, Stick.rot, c_white, 1);
var col = c_ltgrey
for (var i=0;i<6;i++){
	var mov = {x: 0, y: 0, rot: 0};
	for (var j=3*floor(i/3);j<i;j++){
		mov.x += 156*dsin(mov.rot + Diamonds[j].rot);
		mov.y += 156*dcos(mov.rot + Diamonds[j].rot);
		mov.rot += Diamonds[j].rot;
	}
	if (i == 3){
		col = c_white;
	}
	draw_sprite_ext(spr_diamond, 0, x + Stick.x + 353*dcos(Stick.rot) + mov.x, y + Stick.y - 353*dsin(Stick.rot) + mov.y, 1, 1, Diamonds[i].rot + mov.rot, col, 1);
}
