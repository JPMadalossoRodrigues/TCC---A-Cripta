extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_window_size(Vector2(1280,720))
	

func _novo_jogo():
	get_tree().change_scene("res://Cenas/Game.tscn")

func _on_Missoes_button_down():
	get_tree().change_scene("res://Cenas/Missoes.tscn")

func _on_Creditos_button_down():
	get_tree().change_scene("res://Cenas/Creditos.tscn")

func _on_Sair_button_down():
	Data.save()
	get_tree().quit()


func _on_Loja_button_down():
	get_tree().change_scene("res://Cenas/Loja.tscn")
