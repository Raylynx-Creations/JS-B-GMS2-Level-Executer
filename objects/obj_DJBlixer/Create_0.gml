timer = 0;
var col = make_color_rgb(255,32,112);
DJ = {table: {x: 800, y: 914},
	setup: {col: c_white, scale: 0, y: -224},
	headphones: {col: c_white, scale: 0, y: 0, index: ((irandom(99) == 33) ? 1 : 0)},
	hands: {left: [{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0}],
		right: [{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0},{col: col, scale: 0, x: 0, y: 0, angle: 0}]},
	mouth: [{scale: 0, col: c_white, x: 0, y: 0, angle: 180}, {scale: 0, col: c_white, x: 0, y: 0, angle: 180}],
	brows: [{col: col, scale: 0, x: 0, y: 0, angle: 0}, {col: col, scale: 0, x: 0, y: 0, angle: 0}],
	eye: {col: c_white, sprite: spr_circle, scale: {x: 0, y: 0}, x: 0, y: 0},
	horns: [{col: c_white, angle: 45, alpha: 0, x: -150*dsin(45), y: -150*dsin(45)},{col: c_white, angle: -45, alpha: 0, x: 150*dsin(45), y: -150*dsin(45)}],
	body: {scale: {x: 0, y: 0}, col: col, sprite: spr_circle, angle: 0, x: 0, y: -464}};
if (obj_game.state == menu.intro){
	scale = 1;
}else{
	scale = 0.6;
	DJ.table.y = 815
}
