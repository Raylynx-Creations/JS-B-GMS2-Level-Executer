if (ds_map_find_value(async_load, "event_type") == "gamepad discovered"){
	var indice = ds_map_find_value(async_load, "pad_index");
	gamepad_set_axis_deadzone(indice, 0.4);
	gamepad_set_button_threshold(indice, 0.5);
	if (indice >= 4 and gamepad_get_mapping(indice) == "no mapping"){
		var mapping = gamepad_get_guid(indice) + "," + gamepad_get_description(indice) + ",a:b0,b:b1,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,lefttrigger:b6,righttrigger:b7,guide:b8,start:b9,leftstick:b10,rightstick:b11,dpup:h0.1,dpright:h0.2,dpdown:h0.4,dpleft:h0.8,leftx:a0,lefty:a1,rightx:a2,righty:a3";
		gamepad_test_mapping(indice, mapping);
	}
    if (indice == 0){
        maincontrols = controls.gamepad;
		indication[0] = "      ";
		indication[1] = "      ";
    }else{ if (indice == 4){
		maincontrols = controls.generic;
		indication[0] = "      ";
		indication[1] = "      ";
	}}
}else{ if (ds_map_find_value(async_load, "event_type") == "gamepad lost"){
	var indice = ds_map_find_value(async_load, "pad_index");
	if (indice == 0 or indice == 4){
		if (gamepad_is_connected(0)){
			maincontrols = controls.gamepad;
	        indication[0] = "      ";
			indication[1] = "      ";
		}else{ if (gamepad_is_connected(4)){
			maincontrols = controls.generic;
	        indication[0] = "      ";
			indication[1] = "      ";
		}else{
			maincontrols = controls.keyboard;
			if (zurdo){
				indication[0] = "Enter";
				indication[1] = "Backspace";
			}else{
				indication[0] = "Space";
				indication[1] = "ESC";
			}
		}}
    }
}}