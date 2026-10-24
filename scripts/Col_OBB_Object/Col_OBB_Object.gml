function ColOBBObject(_x, _y, _z, _scalex, _scaley, _scalez, _mask = 1, _group = 1) constructor{
	x = _x;
	y = _y;
	z = _z;

	rx = 0;
	ry = 0;
	rz = 0;

	scalex = _scalex;
	scaley = _scaley;
	scalez = _scalez;

	originx = 0
	originy = 0
	originz = 0

	mask = _mask
	group = _group

	position = new Vector3(x, y, z)
	size = new Vector3(scalex, scaley, scalez)
	orientation = matrix_build(0, 0, 0, rx, ry, rz, 1, 1, 1)
	origin = new Vector3(originx, originy, originz)

	shape = new ColOBB(position, size, orientation, origin);
	object = new ColObject(shape, self, mask, group);
	
	obj_game.world_3d.Add(object);
	array_push(obj_game.objects_3d, self);
	
	update = function(){
		position = new Vector3(x, y, z)
		size = new Vector3(scalex, scaley, scalez)
		orientation = matrix_build(0, 0, 0, rx, ry, rz, 1, 1, 1)
		origin = new Vector3(originx, originy, originz)
		object.mask = mask
		object.group = group

		shape.Set(position, size, orientation, origin)
		
		obj_game.world_3d.Remove(object);
		obj_game.world_3d.Add(object);
	}
	
	draw = function(){
		gpu_set_cullmode(cull_clockwise);
		var old_world = matrix_get(matrix_world)
		matrix_set(matrix_world, matrix_build(shape.position.x, shape.position.y, shape.position.z, rx, ry, rz, 1, 1, 1))
		draw_set_lighting(true);
		d3d_draw_block_simple(-scalex, -scaley, -scalez, scalex, scaley, scalez)
		draw_set_lighting(false);
		matrix_set(matrix_world, old_world)
		gpu_set_cullmode(cull_noculling);
	}
	
	clean_up = function(){
		obj_game.world_3d.Remove(object);
		array_delete(obj_game.objects_3d, array_find_index(obj_game.objects_3d, find_index), 1)
	}
	
	find_index = function(_value, _index){
		return (_value == object);
	}
}