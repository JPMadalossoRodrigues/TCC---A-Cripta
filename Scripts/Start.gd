extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Data.load()
	MusicController.play("res://Sounds/MenuTrack.ogg")
	get_tree().change_scene("res://Cenas/Menu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
