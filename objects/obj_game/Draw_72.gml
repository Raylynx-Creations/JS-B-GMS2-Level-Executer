/// @description Camera
	
var _x = Scroll.range*dsin(Scroll.offset*(SongTime - Scroll.time)/0.5)
var _y = Scroll.range*dsin(Scroll.offset*(SongTime - Scroll.time)/0.3)
var _angle = Scroll.angle*dsin(Scroll.angle_speed*(SongTime - Scroll.angle_time))
var _camW = camera_get_view_width(camera_view)
var _camH = camera_get_view_height(camera_view)
var _camX = Camera.x + _x + _camW/2
var _camY = Camera.y + _y + _camH/2

var _view = matrix_build_lookat(_camX, _camY, -16000, _camX, _camY, 0, dsin(_angle), dcos(_angle), 0)
var _proj = matrix_build_projection_ortho(_camW, _camH, 0, 32000)

camera_set_view_mat(camera_view, _view)
camera_set_proj_mat(camera_view, _proj)

camera_apply(camera_view);