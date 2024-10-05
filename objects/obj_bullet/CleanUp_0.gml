array_delete(obj_game.Bullets.Alive,array_find_index(obj_game.Bullets.Alive,function(a,b){return a.id == id}),1);
array_push(obj_game.Bullets.Dead,self);