extends Node

const FILE_NAME = "res://data.json"

var missao_fogo = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_agua = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_terra = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_ar = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}

func save():
	var node_data = {
		"fogo" : missao_fogo,
		"agua" : missao_agua,
		"ar" : missao_ar,
		"terra" : missao_terra,
	}   
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(node_data))
	file.close()
 
func load():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			missao_fogo = data.fogo
			missao_agua = data.agua
			missao_terra = data.terra
			missao_ar = data.ar
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")

func add_fogo():
	missao_fogo.progressao += 1
	if missao_fogo.progressao >= missao_fogo.objetivo:
		missao_fogo.nivel += 1
		missao_fogo.progressao = 0
		if missao_fogo.nivel == 2:
			missao_fogo.objetivo = 50
		else:
			missao_fogo.objetivo = missao_fogo.objetivo * 2
func add_agua():
	missao_agua.progressao += 1
	if missao_agua.progressao >= missao_agua.objetivo:
		missao_agua.nivel += 1
		missao_agua.progressao = 0
		if missao_agua.nivel == 2:
			missao_agua.objetivo = 50
		else:
			missao_agua.objetivo = missao_agua.objetivo * 2
func add_terra():
	missao_terra.progressao += 1
	if missao_terra.progressao >= missao_terra.objetivo:
		missao_terra.nivel += 1
		missao_terra.progressao = 0
		if missao_terra.nivel == 2:
			missao_terra.objetivo = 50
		else:
			missao_terra.objetivo = missao_terra.objetivo * 2
func add_ar():
	missao_ar.progressao += 1
	if missao_ar.progressao >= missao_ar.objetivo:
		missao_ar.nivel += 1
		missao_ar.progressao = 0
		if missao_ar.nivel == 2:
			missao_ar.objetivo = 50
		else:
			missao_ar.objetivo = missao_ar.objetivo * 2
