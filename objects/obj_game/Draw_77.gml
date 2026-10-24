/*shader_reset();
//shader_set(shd_blur);
//shader_set_uniform_f(shader_get_uniform(shd_blur, "texel"), 1/surface_get_width(application_surface), 1/surface_get_height(application_surface));
window_center(); //Remove when finished
if (window_get_fullscreen()){
	draw_surface_ext(application_surface, 0, 0, window_get_width()/Resolutions[res].x, window_get_height()/Resolutions[res].y, 0, c_white, 1);
}else{
	draw_surface(application_surface, 0, 0);
}
//shader_reset();
shader_set(shd_preMulAlp);
shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);