extends AnimatedSprite


func _AcabouAnimacao(object, key):
	if get_animation() == "Ataque":
		print("SlimeAtacaou")
	play("Idle")
