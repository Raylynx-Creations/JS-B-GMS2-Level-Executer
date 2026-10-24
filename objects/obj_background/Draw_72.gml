if (ismodelnodshnsodhau){
	//gpu_set_ztestenable(true);

	gpu_set_cullmode(cull_clockwise);
	gpu_set_tex_repeat(true);

	var _old_world = matrix_get(matrix_world); 
	
	matrix_set(matrix_world, transform_matrixsoikdnasoidaoknk);
	
	draw_set_lighting(true);
	
	draw_light_define_ambient(image_blend);
	
	shader_reset();
	
	spriteiomdsfilasmdanls.Submit();
	
	shader_set(shd_preMulAlp);
	shader_set_uniform_f_array(shader_get_uniform(shd_preMulAlp, "u_Color"), [1,1,1,0]);
	
	draw_set_lighting(false);
	
	matrix_set(matrix_world, _old_world);
	
	gpu_set_cullmode(cull_noculling);
	gpu_set_tex_repeat(false);
	
	//gpu_set_ztestenable(false);
}