timer++;y = 450 - 10*dsin(2*timer);
Ribons[0].rot = 97.5 + 2.5*dsin(2*timer);
Ribons[1].rot = 37.5 + 2.5*dsin(2*timer);
Stick.posdiff = {x: x + Stick.x + 353*dcos(Stick.rot), y: y + Stick.y - 353*dsin(Stick.rot)};
Stick.y = 125 - 10*dsin(2*timer);
Stick.rot = 15 + 2.5*dsin(2*timer);
Stick.posdiff.x = x + Stick.x + 353*dcos(Stick.rot) - Stick.posdiff.x;
Stick.posdiff.y = y + Stick.y - 353*dsin(Stick.rot) - Stick.posdiff.y;
for (var i=0;i<6;i++){
	var rot = 0;
	for (var j=3*floor(i/3);j<i;j++){
		rot += Diamonds[i].rot;
	}
	while (Diamonds[i].rot < 0){
		Diamonds[i].rot += 360;
	}
	Diamonds[i].rot %= 360;
	Diamonds[i].force += Stick.posdiff.x/20*dcos(Diamonds[i].rot + rot);
	Diamonds[i].force += Stick.posdiff.y/20*dsin(Diamonds[i].rot + rot);
	Diamonds[i].force = clamp(Diamonds[i].force, -30, 30);
	Diamonds[i].rot += Diamonds[i].force/7;
	while (Diamonds[i].rot < 0){
		Diamonds[i].rot += 360;
	}
	Diamonds[i].rot %= 360;
	Diamonds[i].force /= 1.005;
	Diamonds[i].force -= irandom_range(3,8)*2*dsin(Diamonds[i].rot + rot)/irandom_range(5,10);
}
