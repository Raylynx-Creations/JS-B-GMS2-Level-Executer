array_delete(obj_game.Background.Alive,array_find_index(obj_game.Background.Alive,function(a,b){return a.id == id}),1);
array_push(obj_game.Background.Dead,self);