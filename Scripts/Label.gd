extends Node2D

func set_text(_txt, _color):
	$Timer.start()
	$Label.text = str(_txt)
	$Label.add_color_override("font_color", _color)

func Clear():
	$Label.text = str("")
