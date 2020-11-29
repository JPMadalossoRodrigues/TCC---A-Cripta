extends Control

# Load the music player node
onready var _player = $AudioStreamPlayer

# Calling this function will load the given track, and play it
func play(track_url : String):
	stop()
	var new_track = load(track_url)
	_player.stream = new_track
	_player.volume_db =-30
	_player.play()

# Calling this function will stop the music
func stop():
	_player.stop()
