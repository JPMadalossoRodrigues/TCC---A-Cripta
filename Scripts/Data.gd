extends Node

const FILE_NAME = "res://data.json"

var missao_alma_fogo = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_alma_agua = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_alma_terra = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_alma_ar = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}

var missao_inimigo_fogo = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_inimigo_agua = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_inimigo_terra = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}
var missao_inimigo_ar = {
	"nivel":1,
	"objetivo": 10,
	"progressao": 0
}

var loja_inicia_ponto = {
	"comprado": false,
	"preco": 200
}

var loja_turnos_fogo = {
	"comprado": false,
	"preco": 100
}

var loja_turnos_agua = {
	"comprado": false,
	"preco": 100
}

var loja_turnos_ar = {
	"comprado": false,
	"preco": 100
}

var loja_turnos_terra = {
	"comprado": false,
	"preco": 100
}

var loja_dobro_xp = {
	"comprado": false,
	"preco": 500
}

var moedas = 0

func save():
	var node_data = {
		"missao_alma_fogo" : missao_alma_fogo,
		"missao_alma_agua" : missao_alma_agua,
		"missao_alma_ar" : missao_alma_ar,
		"missao_alma_terra" : missao_alma_terra,
		"missao_inimigo_fogo" : missao_inimigo_fogo,
		"missao_inimigo_agua" : missao_inimigo_agua,
		"missao_inimigo_ar" : missao_inimigo_ar,
		"missao_inimigo_terra" : missao_inimigo_terra,
		"loja_inicia_ponto":loja_inicia_ponto,
		"loja_turnos_fogo":loja_turnos_fogo,
		"loja_turnos_agua":loja_turnos_agua,
		"loja_turnos_ar":loja_turnos_ar,
		"loja_turnos_terra":loja_turnos_terra,
		"loja_dobro_xp":loja_dobro_xp,
		"moedas":moedas
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
			missao_alma_fogo = data.missao_alma_fogo
			missao_alma_agua = data.missao_alma_agua
			missao_alma_terra = data.missao_alma_terra
			missao_alma_ar = data.missao_alma_ar
			
			missao_inimigo_fogo = data.missao_inimigo_fogo
			missao_inimigo_agua = data.missao_inimigo_agua
			missao_inimigo_terra = data.missao_inimigo_terra
			missao_inimigo_ar = data.missao_inimigo_ar
			
			loja_inicia_ponto= data.loja_inicia_ponto
			loja_turnos_fogo=data.loja_turnos_fogo
			loja_turnos_agua=data.loja_turnos_agua
			loja_turnos_ar= data.loja_turnos_ar
			loja_turnos_terra = data.loja_turnos_terra
			loja_dobro_xp = data.loja_dobro_xp
			
			moedas = data.moedas
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")

func add_alma_fogo():
	missao_alma_fogo.progressao += 1
	if missao_alma_fogo.progressao >= missao_alma_fogo.objetivo:
		missao_alma_fogo.nivel += 1
		missao_alma_fogo.progressao = 0
		moedas += 100
		if missao_alma_fogo.nivel == 2:
			missao_alma_fogo.objetivo = 50
		else:
			missao_alma_fogo.objetivo = missao_alma_fogo.objetivo * 2
func add_alma_agua():
	missao_alma_agua.progressao += 1
	if missao_alma_agua.progressao >= missao_alma_agua.objetivo:
		missao_alma_agua.nivel += 1
		missao_alma_agua.progressao = 0
		moedas += 100
		if missao_alma_agua.nivel == 2:
			missao_alma_agua.objetivo = 50
		else:
			missao_alma_agua.objetivo = missao_alma_agua.objetivo * 2
func add_alma_terra():
	missao_alma_terra.progressao += 1
	if missao_alma_terra.progressao >= missao_alma_terra.objetivo:
		missao_alma_terra.nivel += 1
		missao_alma_terra.progressao = 0
		moedas += 100
		if missao_alma_terra.nivel == 2:
			missao_alma_terra.objetivo = 50
		else:
			missao_alma_terra.objetivo = missao_alma_terra.objetivo * 2
func add_alma_ar():
	missao_alma_ar.progressao += 1
	if missao_alma_ar.progressao >= missao_alma_ar.objetivo:
		missao_alma_ar.nivel += 1
		missao_alma_ar.progressao = 0
		moedas += 100
		if missao_alma_ar.nivel == 2:
			missao_alma_ar.objetivo = 50
		else:
			missao_alma_ar.objetivo = missao_alma_ar.objetivo * 2
func add_inimigo_fogo():
	missao_inimigo_fogo.progressao += 1
	if missao_inimigo_fogo.progressao >= missao_inimigo_fogo.objetivo:
		missao_inimigo_fogo.nivel += 1
		missao_inimigo_fogo.progressao = 0
		moedas += 50
		if missao_inimigo_fogo.nivel == 2:
			missao_inimigo_fogo.objetivo = 50
		else:
			missao_inimigo_fogo.objetivo = missao_inimigo_fogo.objetivo * 2
func add_inimigo_agua():
	missao_inimigo_agua.progressao += 1
	if missao_inimigo_agua.progressao >= missao_inimigo_agua.objetivo:
		missao_inimigo_agua.nivel += 1
		missao_inimigo_agua.progressao = 0
		moedas += 50
		if missao_inimigo_agua.nivel == 2:
			missao_inimigo_agua.objetivo = 50
		else:
			missao_inimigo_agua.objetivo = missao_inimigo_agua.objetivo * 2
func add_inimigo_terra():
	missao_inimigo_terra.progressao += 1
	if missao_inimigo_terra.progressao >= missao_inimigo_terra.objetivo:
		missao_inimigo_terra.nivel += 1
		missao_inimigo_terra.progressao = 0
		moedas += 50
		if missao_inimigo_terra.nivel == 2:
			missao_inimigo_terra.objetivo = 50
		else:
			missao_inimigo_terra.objetivo = missao_inimigo_terra.objetivo * 2
func add_inimigo_ar():
	missao_inimigo_ar.progressao += 1
	if missao_inimigo_ar.progressao >= missao_inimigo_ar.objetivo:
		missao_inimigo_ar.nivel += 1
		missao_inimigo_ar.progressao = 0
		moedas += 50
		if missao_inimigo_ar.nivel == 2:
			missao_inimigo_ar.objetivo = 50
		else:
			missao_inimigo_ar.objetivo = missao_inimigo_ar.objetivo * 2

