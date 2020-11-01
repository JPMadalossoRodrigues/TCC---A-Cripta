extends AnimatedSprite


func _AcabouAnimacao():
	if get_animation() == "Ataque":
		print("PumpikinAtacaou")
	play("Idle")
