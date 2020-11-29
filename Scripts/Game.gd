extends Node2D
const PlayerScene = preload("res://Cenas/Player.tscn")
const PumpikinHeadScene = preload("res://Cenas/PumpikinHead.tscn")
const AlmaFogoScene = preload("res://Cenas/AlmaFogo.tscn")
const SlimeScene = preload("res://Cenas/Slime.tscn")
const AlmaAguaScene = preload("res://Cenas/AlmaAgua.tscn")
const GhostScene = preload("res://Cenas/Ghost.tscn")
const AlmaArScene = preload("res://Cenas/AlmaAr.tscn")
const PlantScene = preload("res://Cenas/Plant.tscn")
const AlmaTerraScene = preload("res://Cenas/AlmaTerra.tscn")
const LabelScene = preload("res://Cenas/Label.tscn")

const TILE_SIZE = 32
const LEVEL_SIZE = [Vector2(30,30), Vector2(35,35), Vector2(40,40), Vector2(45,45), Vector2(50,50), Vector2(50,50), Vector2(50,50), Vector2(50,50), Vector2(50,50), Vector2(50,50)]
const LEVEL_ROOM = [5,7,9,12,15,15,15,15,15,15]
const MIN_ROOM_SIZE = 5
const MAX_ROOM_SIZE = 10

const LEVEL_ENEMY = [5,8,12,18,26,26,26,26,26,26]
enum Tile { Grama,ChaoClaro,ChaoEscuro,Escada,CantoCDDentro,CantoBDDentro,CantoBEDentro,CantoCEDentro,ParedeCima,ParedeEsquerda,ParedeBaixo,ParedeDireita,PortaAbertaCima,PortaAbertaDireita,PortaAbertaBaixo,PortaAbertaEsquerda,PortaFechadaCima,PortaFechadaEsquerda,PortaFechadaBaixo,PortaFechadaDireita,CantoCDFora,CantoBDFora,CantoBEFora,CantoCEFora,CriptaAntiga,CriptaNova}
enum Elementos { Terra, Agua, Ar, Fogo}
enum TipoPortas {AbertaCima,AbertaBaixo,AbertaEsquerda,AbertaDireita,FechadaCima,FechadaBaixo,FechadaEsquerda,FechadaDireita}
enum Telhados{Centro,InferiorDireito,InferiorEsquerdo,SuperiorDireito,SuperiorEsquerdo,Direita,Esquerda,Baixo, Cima}

onready var tile_map = $Mapa
onready var timer = $Timer
onready var sfx = $SFX


var carta = 0
var contagem = 0

var level_atual = 1
var level_size
var mapa = []
var salas = []
var telhado = []


var pathfinding = AStar.new()

var slimes = []
var ghost = []
var pumpikin_head = []
var plant = []

var almas_chao = []
var player
var pausado = true
var destino = Vector2(-1,-1)
var destino_antigo

var vida_extra = 0
var alma_aleatoria = false
var roubo_vida = false

class Alma extends Reference:  
	var sprite_node
	var elemento
	var tile
	
	func _init(_game,_tile,_elemento):
		elemento = _elemento
		tile = _tile
		
		match _elemento:
			0:
				sprite_node = AlmaTerraScene.instance()
			1:
				sprite_node = AlmaAguaScene.instance()
			2:
				sprite_node = AlmaArScene.instance()
			3:
				sprite_node = AlmaFogoScene.instance()
		sprite_node.position = (tile + Vector2(0.5,0.5)) * TILE_SIZE
		sprite_node.position.x = sprite_node.position.x
		sprite_node.position.y = sprite_node.position.y
		_game.add_child(sprite_node)
	
	func remove(_game, _alma):
		_game.almas_chao.erase(_alma)
		sprite_node.queue_free()

class Slime extends Reference:
	var sprite_node
	var provocado = false
	var tile
	var dano = 5
	var hp = 30
	var hp_max = 30
	var nivel
	func _init(_game,_tile):
		if _game.level_atual == 1:
			nivel = 1
		else:
			nivel = rand_range(_game.level_atual - _game.level_atual/2,_game.level_atual)
		var dano = 10 * nivel
		var hp_max = 30 * nivel
		var hp = hp_max
		tile = _tile
		sprite_node = SlimeScene.instance()
		sprite_node.position = _tile * TILE_SIZE
		_game.add_child(sprite_node)
	
	func acao(_game):
		if provocado == true:
			var my_point = _game.pathfinding.get_closest_point(Vector3(tile.x, tile.y, 0))
			var player_point = _game.pathfinding.get_closest_point(Vector3(_game.player.tile.x, _game.player.tile.y, 0))
			var path = _game.pathfinding.get_point_path(my_point,player_point)
			var block = false
			if path:
				if path.size() > 1:
					var move_tile = Vector2(path[1].x,path[1].y)
					var tile_type = _game.mapa[path[1].x][path[1].y]
					if tile.x < move_tile.x:
						sprite_node.set_flip_h(true)
					elif tile.x>move_tile.x:
						sprite_node.set_flip_h(false)
					if  tile_type == Tile.PortaFechadaCima or tile_type == Tile.PortaFechadaDireita or tile_type == Tile.PortaFechadaBaixo or tile_type == Tile.PortaFechadaEsquerda:
						block = true
					if path.size()==2:
						if hp > 0:
							ataque(_game)
					else:
						for enemy in _game.ghost:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.pumpikin_head:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.plant:
							if enemy.tile == move_tile:
								block = true
								break
						if !block:
							sprite_node.get_node("Tween").interpolate_property(sprite_node, 'position', tile * TILE_SIZE, move_tile * TILE_SIZE, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
							sprite_node.play("Andar")
							sprite_node.get_node("Tween").start()
							tile = move_tile
			yield(_game.get_tree().create_timer(1.0), "timeout")
	
	func morte(_game,_enemy):
		sprite_node.play("Morte")
		yield(_game.get_tree().create_timer(1.0), "timeout")
		
		var alma = Alma.new(_game,tile, Elementos.Agua)
		_game.almas_chao.append(alma)
		
		Data.add_inimigo_agua()
		_game.slimes.erase(_enemy)
		sprite_node.queue_free()
	
	func ataque(_game):
		sprite_node.play("Ataque")
		var dmg = dano
		if _game.player.turnos > 0:
			if _game.player.elemento_ativo == Elementos.Terra:
				dmg -= dmg/2
		_game.player.hp = max(0 , _game.player.hp - dmg)
		yield(_game.get_tree().create_timer(0.5), "timeout")
		var txt = LabelScene.instance()
		var PosX = _game.player.tile.x * TILE_SIZE 
		var PosY = (_game.player.tile.y * TILE_SIZE) - 21
		txt.position = Vector2(PosX, PosY)
		txt.set_text("-" + var2str(dmg), Color.red)
		_game.add_child(txt) 
		_game.player.sprite_node.get_node("HP").rect_size.x = TILE_SIZE * _game.player.hp/_game.player.hp_max
		_game.player.assustado = true
		if _game.player.hp == 0:
			_game.player.morte(_game)

class Ghost extends Reference:
	var sprite_node
	var provocado= false
	var tile
	var dano = 5
	var hp = 30
	var hp_max = 30
	var nivel
	
	func _init(_game,_tile):
		if _game.level_atual == 1:
			nivel = 1
		else:
			nivel = rand_range(_game.level_atual - _game.level_atual/2,_game.level_atual)
		var dano = 10 * nivel
		var hp_max = 30 * nivel
		var hp = hp_max
		tile = _tile
		sprite_node = GhostScene.instance()
		sprite_node.position = _tile * TILE_SIZE
		_game.add_child(sprite_node)
	
	func acao(_game):
		if provocado == true:
			var my_point = _game.pathfinding.get_closest_point(Vector3(tile.x, tile.y, 0))
			var player_point = _game.pathfinding.get_closest_point(Vector3(_game.player.tile.x, _game.player.tile.y, 0))
			var path = _game.pathfinding.get_point_path(my_point,player_point)
			var block = false
			if path:
				if path.size() > 1:
					var move_tile = Vector2(path[1].x,path[1].y)
					var tile_type = _game.mapa[path[1].x][path[1].y]
					if tile.x < move_tile.x:
						sprite_node.set_flip_h(true)
					elif tile.x>move_tile.x:
						sprite_node.set_flip_h(false)
					if  tile_type == Tile.PortaFechadaCima or tile_type == Tile.PortaFechadaDireita or tile_type == Tile.PortaFechadaBaixo or tile_type == Tile.PortaFechadaEsquerda:
						block = true
					if path.size()==2:
						if hp > 0:
							ataque(_game)
					else:
						for enemy in _game.ghost:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.pumpikin_head:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.plant:
							if enemy.tile == move_tile:
								block = true
								break
						if !block:
							sprite_node.get_node("Tween").interpolate_property(sprite_node, 'position', tile * TILE_SIZE, move_tile * TILE_SIZE, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
							sprite_node.play("Andar")
							sprite_node.get_node("Tween").start()
							tile = move_tile
			yield(_game.get_tree().create_timer(1.0), "timeout")

	func morte(_game,_enemy):
		sprite_node.play("Morte")
		yield(_game.get_tree().create_timer(1.0), "timeout")
		
		var alma = Alma.new(_game,tile, Elementos.Ar)
		_game.almas_chao.append(alma)
		
		Data.add_inimigo_ar()
		_game.ghost.erase(_enemy)
		sprite_node.queue_free()
	
	func ataque(_game):
		sprite_node.play("Ataque")
		var dmg = dano
		if _game.player.turnos > 0:
			if _game.player.elemento_ativo == Elementos.Terra:
				dmg -= dmg/2
		_game.player.hp = max(0 , _game.player.hp - dmg)
		yield(_game.get_tree().create_timer(0.5), "timeout")
		var txt = LabelScene.instance()
		var PosX = _game.player.tile.x * TILE_SIZE 
		var PosY = (_game.player.tile.y * TILE_SIZE) - 21 
		txt.position = Vector2(PosX, PosY)
		txt.set_text("-" + var2str(dmg), Color.red)
		_game.add_child(txt)
		_game.player.sprite_node.get_node("HP").rect_size.x = TILE_SIZE * _game.player.hp/_game.player.hp_max
		_game.player.assustado = true
		if _game.player.hp == 0:
			_game.player.morte(_game)

class PumpikinHead extends Reference:
	var sprite_node
	var provocado = false
	var tile
	var dano = 5
	var hp = 30
	var hp_max = 30
	var nivel
	
	func _init(_game,_tile):
		if _game.level_atual == 1:
			nivel = 1
		else:
			nivel = rand_range(_game.level_atual - _game.level_atual/2,_game.level_atual)
		var dano = 10 * nivel
		var hp_max = 30 * nivel
		var hp = hp_max
		tile = _tile
		sprite_node = PumpikinHeadScene.instance()
		sprite_node.position = _tile * TILE_SIZE
		_game.add_child(sprite_node)
	
	func acao(_game):
		if provocado == true:
			var my_point = _game.pathfinding.get_closest_point(Vector3(tile.x, tile.y, 0))
			var player_point = _game.pathfinding.get_closest_point(Vector3(_game.player.tile.x, _game.player.tile.y, 0))
			var path = _game.pathfinding.get_point_path(my_point,player_point)
			var block = false
			if path:
				if path.size() > 1:
					var move_tile = Vector2(path[1].x,path[1].y)
					var tile_type = _game.mapa[path[1].x][path[1].y]
					if tile.x < move_tile.x:
						sprite_node.set_flip_h(false)
					elif tile.x>move_tile.x:
						sprite_node.set_flip_h(true)
					if  tile_type == Tile.PortaFechadaCima or tile_type == Tile.PortaFechadaDireita or tile_type == Tile.PortaFechadaBaixo or tile_type == Tile.PortaFechadaEsquerda:
						block = true
					if path.size()==2:
						if hp > 0:
							ataque(_game)
					else:
						for enemy in _game.ghost:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.pumpikin_head:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.plant:
							if enemy.tile == move_tile:
								block = true
								break
						if !block:
							sprite_node.get_node("Tween").interpolate_property(sprite_node, 'position', tile * TILE_SIZE, move_tile * TILE_SIZE, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
							sprite_node.play("Andar")
							sprite_node.get_node("Tween").start()
							tile = move_tile
			yield(_game.get_tree().create_timer(1.0), "timeout")
	
	func morte(_game,_enemy):
		sprite_node.play("Morte")
		yield(_game.get_tree().create_timer(1.0), "timeout")
		
		var alma = Alma.new(_game,tile, Elementos.Fogo)
		_game.almas_chao.append(alma)
		
		Data.add_inimigo_fogo()
		_game.pumpikin_head.erase(_enemy)
		sprite_node.queue_free()
	
	func ataque(_game):
		sprite_node.play("Ataque")
		var dmg = dano
		if _game.player.turnos > 0:
			if _game.player.elemento_ativo == Elementos.Terra:
				dmg -= dmg/2
		_game.player.hp = max(0 , _game.player.hp - dmg)
		yield(_game.get_tree().create_timer(0.5), "timeout")
		var txt = LabelScene.instance()
		var PosX = _game.player.tile.x * TILE_SIZE 
		var PosY = (_game.player.tile.y * TILE_SIZE) - 21 
		txt.position = Vector2(PosX, PosY)
		txt.set_text("-" + var2str(dmg), Color.red)
		_game.add_child(txt)
		_game.player.sprite_node.get_node("HP").rect_size.x = TILE_SIZE * _game.player.hp/_game.player.hp_max
		_game.player.assustado = true
		if _game.player.hp == 0:
			_game.player.morte(_game)

class Plant extends Reference:
	var sprite_node
	var provocado = false
	var tile
	var dano = 5
	var hp = 30
	var hp_max = 30
	var nivel
	
	func _init(_game,_tile):
		if _game.level_atual == 1:
			nivel = 1
		else:
			nivel = rand_range(_game.level_atual - _game.level_atual/2,_game.level_atual)
		var dano = 10 * nivel
		var hp_max = 30 * nivel
		var hp = hp_max
		tile = _tile
		sprite_node = PlantScene.instance()
		sprite_node.position = _tile * TILE_SIZE
		_game.add_child(sprite_node)
	
	func acao(_game):
		if provocado == true:
			var my_point = _game.pathfinding.get_closest_point(Vector3(tile.x, tile.y, 0))
			var player_point = _game.pathfinding.get_closest_point(Vector3(_game.player.tile.x, _game.player.tile.y, 0))
			var path = _game.pathfinding.get_point_path(my_point,player_point)
			var block = false
			if path:
				if path.size() > 1:
					var move_tile = Vector2(path[1].x,path[1].y)
					var tile_type = _game.mapa[path[1].x][path[1].y]
					if tile.x < move_tile.x:
						sprite_node.set_flip_h(false)
					elif tile.x>move_tile.x:
						sprite_node.set_flip_h(true)
					if  tile_type == Tile.PortaFechadaCima or tile_type == Tile.PortaFechadaDireita or tile_type == Tile.PortaFechadaBaixo or tile_type == Tile.PortaFechadaEsquerda:
						block = true
					if path.size()==2:
						if hp > 0:
							ataque(_game)
					else:
						for enemy in _game.ghost:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.pumpikin_head:
							if enemy.tile == move_tile:
								block = true
								break
						for enemy in _game.plant:
							if enemy.tile == move_tile:
								block = true
								break
						if !block:
							sprite_node.get_node("Tween").interpolate_property(sprite_node, 'position', tile * TILE_SIZE, move_tile * TILE_SIZE, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
							sprite_node.play("Andar")
							sprite_node.get_node("Tween").start()
							tile = move_tile
			yield(_game.get_tree().create_timer(0.5), "timeout")
	
	func morte(_game,_enemy):
		sprite_node.play("Morte")
		yield(_game.get_tree().create_timer(1.0), "timeout")
		var alma = Alma.new(_game,tile, Elementos.Terra)
		_game.almas_chao.append(alma)
		
		Data.add_inimigo_terra()
		_game.plant.erase(_enemy)
		sprite_node.queue_free()
	
	func ataque(_game):
		sprite_node.play("Ataque")
		var dmg = dano
		if _game.player.turnos > 0:
			if _game.player.elemento_ativo == Elementos.Terra:
				dmg -= dmg/2
		_game.player.hp = max(0 , _game.player.hp - dmg)
		yield(_game.get_tree().create_timer(1), "timeout")
		var txt = LabelScene.instance()
		var PosX = _game.player.tile.x * TILE_SIZE 
		var PosY = (_game.player.tile.y * TILE_SIZE) - 21 
		txt.position = Vector2(PosX, PosY)
		txt.set_text("-" + var2str(dmg), Color.red)
		_game.add_child(txt)
		_game.player.sprite_node.get_node("HP").rect_size.x = TILE_SIZE * _game.player.hp/_game.player.hp_max
		_game.player.assustado = true
		if _game.player.hp == 0:
			_game.player.morte(_game)

class Player extends Reference:
	var sprite_node
	var tile
	var dano = 20
	var hp = 100
	var hp_max = 100
	var almas = []
	var almas_max = 10
	var elemento_ativo
	var turnos = 0
	var turnos_max_fogo = 10
	var turnos_max_terra = 10
	var turnos_max_agua = 10
	var turnos_max_ar = 10
	var nivel
	var xp
	var xp_max
	var xp_ganho = 10
	var pontos = 0
	var assustado = false
	var turno_ar 
	
	func _init(_game,_tile):
		xp = 0
		xp_max = 100
		nivel = 1
		pontos = 0
		tile = _tile
		sprite_node = PlayerScene.instance()
		sprite_node.get_node("XP").rect_size.x = TILE_SIZE * xp/xp_max
		sprite_node.position = _tile * TILE_SIZE
		_game.add_child(sprite_node)
	
	func acao(_game,_destino):
		if assustado:
			_game.destino = Vector2(-1,-1)
			assustado = false
		else:
			if _destino.x >= 0 && _destino.x < _game.level_size.x && _destino.y >= 0 && _destino.y < _game.level_size.y:
				var tile_type = _game.mapa[_destino.x][_destino.y]
				if tile_type != Tile.Grama and tile_type != Tile.CantoCDFora and tile_type != Tile.CantoBDFora and tile_type != Tile.CantoBEFora and tile_type != Tile.CantoCEFora and tile_type != Tile.ParedeCima and tile_type != Tile.ParedeEsquerda and tile_type != Tile.ParedeBaixo and tile_type != Tile.ParedeDireita:
					if !sprite_node.get_node("Tween").is_active():
						var my_point = _game.pathfinding.get_closest_point(Vector3(tile.x, tile.y, 0))
						var objetivo = _game.pathfinding.get_closest_point(Vector3(_destino.x, _destino.y, 0))
						var path = _game.pathfinding.get_point_path(my_point,objetivo)
						if path and path.size() > 1:
							var proximo_tile =  Vector2(path[1].x, path[1].y)
							var acao = false
							if proximo_tile.x > tile.x:
								sprite_node.set_flip_h(false)
							elif proximo_tile.x < tile.x:
								sprite_node.set_flip_h(true)
							for enemy in _game.slimes:
								if enemy.tile == proximo_tile:
									if path.size() == 2:
										if sprite_node.animation == "Idle" or sprite_node.animation == "Andar":
											ataque(_game,enemy)
									acao = true
							for enemy in _game.ghost:
								if enemy.tile == proximo_tile:
									if path.size() == 2:
										if sprite_node.animation == "Idle" or sprite_node.animation == "Andar":
											ataque(_game,enemy)
									acao = true
							for enemy in _game.pumpikin_head:
								if enemy.tile == proximo_tile:
									if path.size() == 2:
										if sprite_node.animation == "Idle" or sprite_node.animation == "Andar":
											ataque(_game,enemy)
									acao = true
							for enemy in _game.plant:
								if enemy.tile == proximo_tile:
									if path.size() == 2:
										if sprite_node.animation == "Idle" or sprite_node.animation == "Andar":
											ataque(_game,enemy)
									acao = true
							if sprite_node.animation == "Ataque" and sprite_node.frame == 4:
								_game.destino = Vector2(-1,-1)
								acao = true
							if !acao:
								for alma in _game.almas_chao:
									if alma.tile == proximo_tile:
										if path.size() == 2:
											coleta_alma(_game,alma)
											acao = true
							if !acao:
								if proximo_tile.x != tile.x and proximo_tile.y != tile.y:
									var dif_x = _game.mapa[proximo_tile.x][tile.y]
									var dif_y = _game.mapa[tile.x][proximo_tile.y]
									if dif_x != Tile.Grama and dif_x != Tile.CantoCDFora and dif_x != Tile.CantoBDFora and dif_x != Tile.CantoBEFora and dif_x != Tile.CantoCEFora and dif_x != Tile.ParedeCima and dif_x != Tile.ParedeEsquerda and dif_x != Tile.ParedeBaixo and dif_x != Tile.ParedeDireita:
										proximo_tile = Vector2(proximo_tile.x,tile.y)
									elif dif_y != Tile.Grama and dif_y != Tile.CantoCDFora and dif_y != Tile.CantoBDFora and dif_y != Tile.CantoBEFora and dif_y != Tile.CantoCEFora and dif_y != Tile.ParedeCima and dif_y != Tile.ParedeEsquerda and dif_y != Tile.ParedeBaixo and dif_y != Tile.ParedeDireita:
										proximo_tile = Vector2(tile.x,proximo_tile.y)
								tile_type = _game.mapa[proximo_tile.x][proximo_tile.y]
								match tile_type:
									Tile.ChaoClaro, Tile.ChaoEscuro, Tile.PortaAbertaBaixo, Tile.PortaAbertaCima, Tile.PortaAbertaDireita, Tile.PortaAbertaEsquerda:
										sprite_node.get_node("Tween").interpolate_property (sprite_node, 'position', tile * TILE_SIZE, proximo_tile * TILE_SIZE, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
										sprite_node.play("Andar")
										sprite_node.get_node("Tween").start()
										tile = proximo_tile
									Tile.PortaFechadaBaixo, Tile.PortaFechadaCima, Tile.PortaFechadaDireita, Tile.PortaFechadaEsquerda:
										_game.add_tile(proximo_tile)
										if _game.mapa[proximo_tile.x][proximo_tile.y] ==Tile.PortaFechadaCima:
											_game.mapa[proximo_tile.x][proximo_tile.y] = Tile.PortaAbertaCima
										if _game.mapa[proximo_tile.x][proximo_tile.y] ==Tile.PortaFechadaDireita:
											_game.mapa[proximo_tile.x][proximo_tile.y] = Tile.PortaAbertaDireita
										if _game.mapa[proximo_tile.x][proximo_tile.y] ==Tile.PortaFechadaBaixo:
											_game.mapa[proximo_tile.x][proximo_tile.y] = Tile.PortaAbertaBaixo
										if _game.mapa[proximo_tile.x][proximo_tile.y] ==Tile.PortaFechadaEsquerda:
											_game.mapa[proximo_tile.x][proximo_tile.y] = Tile.PortaAbertaEsquerda
									Tile.Escada, Tile.CriptaNova:
										_game.level_atual +=1
										if _game.level_atual >= _game.LEVEL_SIZE.size():
												MusicController.stop()
												_game.get_node("UI").get_node("Vitoria").visible = true
										else:
											_game.cria_level()
							if turnos > 0:
								if  elemento_ativo == Elementos.Agua:
									hp += 3
									hp = min(hp,hp_max)
									sprite_node.get_node("HP").rect_size.x = TILE_SIZE * hp/hp_max
									for enemy in _game.slimes:
										enemy.acao(_game)
									for enemy in _game.ghost:
										enemy.acao(_game)
									for enemy in _game.pumpikin_head:
										enemy.acao(_game)
									for enemy in _game.plant:
										enemy.acao(_game)
								elif  elemento_ativo == Elementos.Ar:
									if turno_ar == true:
										for enemy in _game.slimes:
											enemy.acao(_game)
										for enemy in _game.ghost:
											enemy.acao(_game)
										for enemy in _game.pumpikin_head:
											enemy.acao(_game)
										for enemy in _game.plant:
											enemy.acao(_game)
										turno_ar = false 
								else:
									for enemy in _game.slimes:
										enemy.acao(_game)
									for enemy in _game.ghost:
										enemy.acao(_game)
									for enemy in _game.pumpikin_head:
										enemy.acao(_game)
									for enemy in _game.plant:
										enemy.acao(_game)
								turnos -= 1
							if turnos == 0:
								sprite_node.get_node("Efeito").visible = false
								for enemy in _game.slimes:
									enemy.acao(_game)
								for enemy in _game.ghost:
									enemy.acao(_game)
								for enemy in _game.pumpikin_head:
									enemy.acao(_game)
								for enemy in _game.plant:
									enemy.acao(_game)
						else:
							_game.destino = Vector2(-1,-1)
					else:
						_game.stop()
				else:
					_game.destino = Vector2(-1,-1)
			else:
				_game.destino = Vector2(-1,-1)
	
	func morte(_game):
		if _game.vida_extra == 1:
			hp = hp_max/2
			_game.vida_extra = 2
			sprite_node.get_node("HP").rect_size.x = TILE_SIZE * hp/hp_max
		else:
			sprite_node.get_node("Tween").interpolate_property (_game.timer, 'position', Vector3(0,0,0), Vector3(32,0,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			sprite_node.play("Morte")
			sprite_node.get_node("Tween").start()
			MusicController.stop()
			_game.get_node("UI").get_node("Morte").visible = true
			
	
	func ataque(_game,_enemy):
		var dmg = dano
		if turnos > 0:
			if  elemento_ativo == Elementos.Fogo:
				dmg += dmg/2
		_game.play("res://Sounds/Attack.ogg")
		sprite_node.get_node("Tween").interpolate_property (_game.timer, 'position', Vector3(0,0,0), Vector3(32,0,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		sprite_node.play("Ataque")
		sprite_node.get_node("Tween").start()
		
		_enemy.hp = max(0 , _enemy.hp - dmg)
		var txt = LabelScene.instance()
		var PosX = _enemy.tile.x * TILE_SIZE 
		var PosY = (_enemy.tile.y * TILE_SIZE) - 21 
		txt.position = Vector2(PosX, PosY)
		txt.set_text("-" + var2str(dmg), Color.red)
		_game.add_child(txt)
		
		if _enemy.hp == 0:
			if _game.roubo_vida:
				var hp_perdido = hp_max - hp
				hp = hp_perdido * 0.10
			xp += xp_ganho
			_game.add_child(txt)
			if xp >= xp_max:
				xp = 0
				xp_max = xp_max + 50
				nivel += 1
				pontos += 1
			_enemy.morte(_game,_enemy)
			_game.player.sprite_node.get_node("XP").rect_size.x = TILE_SIZE * _game.player.xp/_game.player.xp_max
	
	func coleta_alma(_game,_alma):
		_game.play("res://Sounds/Almas.ogg")
		sprite_node.get_node("Tween").interpolate_property (_game.timer, 'position', Vector3(0,0,0), Vector3(32,0,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		sprite_node.get_node("Tween").start()
		if almas.size() < almas_max:

			almas.append(_alma)
			_alma.remove(_game, _alma)
			if almas.size() == 1:
				sprite_node.get_node("Pix").visible = true
				match _alma.elemento:
					0:
						sprite_node.get_node("Pix").play("TerraTransicao")
						yield(_game.get_tree().create_timer(1.0), "timeout")
						sprite_node.get_node("Pix").play("TerraIdle")
					1:
						sprite_node.get_node("Pix").play("AguaTransicao")
						yield(_game.get_tree().create_timer(1.0), "timeout")
						sprite_node.get_node("Pix").play("AguaIdle")
					2:
						sprite_node.get_node("Pix").play("ArTransicao")
						yield(_game.get_tree().create_timer(1.0), "timeout")
						sprite_node.get_node("Pix").play("ArIdle")
					3:
						sprite_node.get_node("Pix").play("FogoTransicao")
						yield(_game.get_tree().create_timer(1.0), "timeout")
						sprite_node.get_node("Pix").play("FogoIdle")
	
	func usa_alma(_game):
		if almas.size() > 0:
			elemento_ativo = almas[0].elemento
			match elemento_ativo:
				Elementos.Fogo:
					Data.add_alma_fogo()
				Elementos.Agua:
					Data.add_alma_agua()
				Elementos.Terra:
					Data.add_alma_terra()
				Elementos.Ar:
					Data.add_alma_ar()
			match almas[0].elemento:
				Elementos.Terra:
					turnos = turnos_max_terra
					sprite_node.get_node("Pix").play ("TerraTransicao", true)
					yield(_game.get_tree().create_timer(1.0), "timeout")
					sprite_node.get_node("Efeito").visible = true
					sprite_node.get_node("Efeito").play ("Shield")
					if almas.size() > 1:

						match almas[1].elemento:
							Elementos.Terra:
								sprite_node.get_node("Pix").play ("TerraTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("TerraIdle")
							Elementos.Agua:
								sprite_node.get_node("Pix").play ("AguaTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("AguaIdle")
							Elementos.Ar:
								sprite_node.get_node("Pix").play ("ArTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("ArIdle")
							Elementos.Fogo:
								sprite_node.get_node("Pix").play ("FogoTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("FogoIdle")
					else:
						sprite_node.get_node("Pix").visible = false
				Elementos.Agua:
					turnos = turnos_max_agua
					sprite_node.get_node("Pix").play ("AguaTransicao", true)
					yield(_game.get_tree().create_timer(1.0), "timeout")
					sprite_node.get_node("Efeito").visible = true
					sprite_node.get_node("Efeito").play ("Heal")
					if almas.size() > 1:
						match almas[1].elemento:
							Elementos.Terra:
								sprite_node.get_node("Pix").play ("TerraTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("TerraIdle")
							Elementos.Agua:
								sprite_node.get_node("Pix").play ("AguaTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("AguaIdle")
							Elementos.Ar:
								sprite_node.get_node("Pix").play ("ArTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("ArIdle")
							Elementos.Fogo:
								sprite_node.get_node("Pix").play ("FogoTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("FogoIdle")
					else:
						sprite_node.get_node("Pix").visible = false
				Elementos.Ar:
					turno_ar = true
					turnos = turnos_max_ar
					sprite_node.get_node("Pix").play ("ArTransicao", true)
					yield(_game.get_tree().create_timer(1.0), "timeout")
					sprite_node.get_node("Efeito").visible = true
					sprite_node.get_node("Efeito").play ("Speed")
					if almas.size() > 1:
						
						match almas[1].elemento:
							Elementos.Terra:
								sprite_node.get_node("Pix").play ("TerraTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("TerraIdle")
							Elementos.Agua:
								sprite_node.get_node("Pix").play ("AguaTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("AguaIdle")
							Elementos.Ar:
								sprite_node.get_node("Pix").play ("ArTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("ArIdle")
							Elementos.Fogo:
								sprite_node.get_node("Pix").play ("FogoTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("FogoIdle")
					else:
						sprite_node.get_node("Pix").visible = false
				Elementos.Fogo:
					turnos = turnos_max_fogo
					sprite_node.get_node("Pix").play ("FogoTransicao", true)
					yield(_game.get_tree().create_timer(1.0), "timeout")
					sprite_node.get_node("Efeito").visible = true
					sprite_node.get_node("Efeito").play ("Atack")
					if almas.size() > 1:
						match almas[1].elemento:
							Elementos.Terra:
								sprite_node.get_node("Pix").play ("TerraTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("TerraIdle")
							Elementos.Agua:
								sprite_node.get_node("Pix").play ("AguaTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("AguaIdle")
							Elementos.Ar:
								sprite_node.get_node("Pix").play ("ArTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("ArIdle")
							Elementos.Fogo:
								sprite_node.get_node("Pix").play ("FogoTransicao")
								yield(_game.get_tree().create_timer(1.0), "timeout")
								sprite_node.get_node("Pix").play ("FogoIdle")
					else:
						sprite_node.get_node("Pix").visible = false
			var temp = almas[0]
			almas.erase(temp)

func _ready():
	inicia_jogo()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if player.hp > 0 and !pausado:
				var click = get_global_mouse_position()
				var temp = Vector2(click.x as int/TILE_SIZE,click.y as int/TILE_SIZE)
				destino = temp

func _process(delta):
	var click = get_global_mouse_position()
	if !pausado and destino != Vector2(-1,-1):
		player.acao(self,Vector2(destino.x,destino.y))
		call_deferred("atualiza_mapa")
	else:
		player.sprite_node.play("Idle")
	call_deferred("atualiza_inimigos")
 
func inicia_jogo():
	OS.set_window_size(Vector2(1280,720))
	MusicController.play("res://Sounds/GameTrack.ogg")
	randomize()
	pausado = false
	level_atual = 1
	$UI/Pause.visible = false
	$UI/Morte.visible = false
	cria_level()
	call_deferred("atualiza_mapa")
	call_deferred("atualiza_inimigos")
	player.assustado = false
	if Data.loja_dobro_xp.comprado:
		player.xp_ganho = 20
	if Data.loja_inicia_ponto.comprado:
		player.pontos = 1
	if Data.loja_turnos_fogo.comprado:
		player.turnos_max_fogo = 20
	else:
		player.turnos_max_fogo = 10
	if Data.loja_turnos_terra.comprado:
		player.turnos_max_terra = 20
	else:
		player.turnos_max_terra = 10
	if Data.loja_turnos_agua.comprado:
		player.turnos_max_agua = 20
	else:
		player.turnos_max_agua = 10
	if Data.loja_turnos_ar.comprado:
		player.turnos_max_ar = 20
	else:
		player.turnos_max_ar = 10
	if Data.carta:
		$UI/Carta.visible = true
		pausado = true
	else:
		$UI/Carta.visible = false

func atualiza_mapa():
	var salaAtual = Rect2(-1, -1, -1, -1)
	for sala in salas:
		if player.tile.x > sala.position.x - 1 and player.tile.y > sala.position.y  - 1:
			if player.tile.x < sala.position.x + sala.size.x  and player.tile.y < sala.position.y + sala.size.y :
				salaAtual = sala
				break
				
	for x in range(level_size.x):
		for y in range(level_size.y):
			tile_map.set_cell(x,y,mapa[x][y])
	
	for telhados in telhado:
		telhados.modulate.a = 1
	
	for x in range(salaAtual.position.x,salaAtual.position.x + salaAtual.size.x):
		for y in range(salaAtual.position.y,salaAtual.position.y + salaAtual.size.y):
			for telhados in telhado:
				if telhados.position == Vector2(x,y) * TILE_SIZE:
						telhados.modulate.a = 0

func atualiza_inimigos():
	var player_centro = Vector2((player.tile.x + 0.5) * TILE_SIZE,(player.tile.y + 0.5) * TILE_SIZE)
	var space_state = get_world_2d().direct_space_state

	for enemy in slimes:
		if enemy.sprite_node.animation == "Ataque" and enemy.sprite_node.frame == 4:
			enemy.sprite_node.play("Idle")
		elif enemy.sprite_node.animation == "Andar" and enemy.sprite_node.frame == 5:
			enemy.sprite_node.play("Idle")
		var enemy_center = Vector2((enemy.tile.x+ 0.5) * TILE_SIZE,(enemy.tile.y + 0.5) * TILE_SIZE)
		var oculto = space_state.intersect_ray(player_centro, enemy_center)
		if !oculto:
			if !enemy.provocado:
				player.assustado = true
			enemy.provocado = true
		else:
			enemy.provocado = false
	for enemy in ghost:
		if enemy.sprite_node.animation == "Ataque" and enemy.sprite_node.frame == 4:
			enemy.sprite_node.play("Idle")
		elif enemy.sprite_node.animation == "Andar" and enemy.sprite_node.frame == 3:
			enemy.sprite_node.play("Idle")
		var enemy_center = Vector2((enemy.tile.x+ 0.5) * TILE_SIZE,(enemy.tile.y + 0.5) * TILE_SIZE)
		var oculto = space_state.intersect_ray(player_centro, enemy_center)
		if !oculto:
			if !enemy.provocado:
				player.assustado = true
			enemy.provocado = true
		else:
			enemy.provocado = false
	for enemy in pumpikin_head:
		if enemy.sprite_node.animation == "Ataque" and enemy.sprite_node.frame == 4:
			enemy.sprite_node.play("Idle")
		elif enemy.sprite_node.animation == "Andar" and enemy.sprite_node.frame == 6:
			enemy.sprite_node.play("Idle")
		var enemy_center = Vector2((enemy.tile.x+ 0.5) * TILE_SIZE,(enemy.tile.y + 0.5) * TILE_SIZE)
		var oculto = space_state.intersect_ray(player_centro, enemy_center)
		if !oculto:
			if !enemy.provocado:
				player.assustado = true
			enemy.provocado = true
		else:
			enemy.provocado = false
	for enemy in plant:
		if enemy.sprite_node.animation == "Ataque" and enemy.sprite_node.frame == 3:
			enemy.sprite_node.play("Idle")
		elif enemy.sprite_node.animation == "Andar" and enemy.sprite_node.frame == 5:
			enemy.sprite_node.play("Idle")
		var enemy_center = Vector2((enemy.tile.x+ 0.5) * TILE_SIZE,(enemy.tile.y + 0.5) * TILE_SIZE)
		var oculto = space_state.intersect_ray(player_centro, enemy_center)
		if !oculto:
			if !enemy.provocado:
				player.assustado = true
			enemy.provocado = true
		else:
			enemy.provocado = false

func cria_level():
	destino = Vector2(-1,-1)
	mapa.clear()
	salas.clear()
	tile_map.clear()
	
	for enemy in slimes:
		enemy.sprite_node.queue_free()
	slimes.clear()
	for enemy in ghost:
		enemy.sprite_node.queue_free()
	ghost.clear()
	for enemy in pumpikin_head:
		enemy.sprite_node.queue_free()
	pumpikin_head.clear()
	for enemy in plant:
		enemy.sprite_node.queue_free()
	plant.clear()
	
	for telhados in telhado:
		telhados.queue_free()
	telhado.clear()
	
	for alma in almas_chao:
		alma.sprite_node.queue_free()
	almas_chao.clear()
	
	level_size = LEVEL_SIZE[level_atual]
	for x in range(level_size.x):
		mapa.append([])
		for y in range(level_size.y):
			mapa[x].append(Tile.Grama)

	var tiles_livres = [Rect2(Vector2(2,2), level_size - Vector2(4,4))]
	var num_salas = LEVEL_ROOM[level_atual]
	
	for i in range(num_salas):
		add_sala(tiles_livres)
		if tiles_livres.empty():
			break
	
	conecta_salas()
	
	var sala_inicial = salas.front()
	var player_x = sala_inicial.position.x + 1 + randi() % int(sala_inicial.size.x - 2)
	var player_y = sala_inicial.position.y + 1 + randi() % int(sala_inicial.size.y - 2)
	if level_atual == 1:
		player =  Player.new(self,Vector2(player_x,player_y))
	else:
		player.tile = Vector2(player_x,player_y)
		player.sprite_node.position = player.tile * TILE_SIZE
	if alma_aleatoria:
		var alma_x = sala_inicial.position.x + 1 + randi() % int(sala_inicial.size.x - 2)
		var alma_y = sala_inicial.position.y + 1 + randi() % int(sala_inicial.size.y - 2)
		var alma = Alma.new(self,Vector2(alma_x,alma_y), randi()%4)
		almas_chao.append(alma)
	var sala_final = salas.back()
	var escada_x = sala_final.position.x + 1 + randi() % int(sala_final.size.x - 2)
	var escada_y = sala_final.position.y + 1 + randi() % int(sala_final.size.y - 2)
	if level_atual >= LEVEL_SIZE.size():
		mapa[escada_x][escada_y] = Tile.CriptaNova
	else:
		mapa[escada_x][escada_y] = Tile.Escada
	call_deferred("atualiza")
	
	for i in range(LEVEL_ENEMY[level_atual]):
		var room = salas[1 + randi()% (salas.size()-1)]
		var x  = room.position.x + 1 + randi()% int (room.size.x -2) 
		var y  = room.position.y + 1 + randi()% int (room.size.y -2) 
		
		var blocked = false
		for enemy in slimes:
			if enemy.tile.x == x && enemy.tile.y == y:
				blocked = true
		for enemy in ghost:
			if enemy.tile.x == x && enemy.tile.y == y:
				blocked = true
		for enemy in pumpikin_head:
			if enemy.tile.x == x && enemy.tile.y == y:
				blocked = true
		for enemy in plant:
			if enemy.tile.x == x && enemy.tile.y == y:
				blocked = true
		if !blocked:
			var temp = randi()%4
			match temp:
				0:
					var enemy = Plant.new(self,Vector2(x,y))
					plant.append(enemy)
				1:
					var enemy = Slime.new(self,Vector2(x,y))
					slimes.append(enemy)
				2:
					var enemy = Ghost.new(self,Vector2(x,y))
					ghost.append(enemy)
				3:
					var enemy = PumpikinHead.new(self,Vector2(x,y))
					pumpikin_head.append(enemy)
	
	for telhados in telhado:
		if mapa[telhados.position.x/TILE_SIZE][telhados.position.y/TILE_SIZE] == Tile.Grama or mapa[telhados.position.x/TILE_SIZE][telhados.position.y/TILE_SIZE] == Tile.ChaoClaro:
			telhado.erase(telhados)
			telhado.queue_free()
	
	atualiza_caminho()

func add_sala(_tiles_livres):
	var regiao = _tiles_livres[randi()%_tiles_livres.size()]
	
	var size_x = MIN_ROOM_SIZE
	if regiao.size.x > MIN_ROOM_SIZE:
		size_x += randi()%int(regiao.size.x - MIN_ROOM_SIZE)
	size_x = min(size_x, MAX_ROOM_SIZE)
	var size_y = MIN_ROOM_SIZE
	if regiao.size.y > MIN_ROOM_SIZE:
		size_y += randi()% int(regiao.size.y - MIN_ROOM_SIZE)
	size_y = min(size_y, MAX_ROOM_SIZE)
	
	var pos_x = regiao.position.x
	if regiao.size.x > size_x:
		pos_x += randi() % int(regiao.size.x - size_x)
	var pos_y = regiao.position.y
	if regiao.size.y > size_y:
		pos_y += randi() % int(regiao.size.y - size_y)
	
	var sala = Rect2(pos_x, pos_y, size_x, size_y)
	salas.append(sala)
	var sprite = Sprite.new()
	self.add_child(sprite)
	
	for x in range(pos_x + 1, pos_x + size_x - 1):
		mapa[x][pos_y] = Tile.ParedeBaixo
		sprite = Sprite.new()
		sprite.texture = load("res://Sprites/Tiles/TelhadoMeioSuperior.png")
		sprite.position = Vector2(x,pos_y) * TILE_SIZE
		sprite.centered = false
		sprite.z_index = 5
		telhado.append(sprite)
		self.add_child(sprite)
		mapa[x][pos_y + size_y - 1] = Tile.ParedeCima
		sprite = Sprite.new()
		sprite.texture = load("res://Sprites/Tiles/TelhadoMeioInferior.png")
		sprite.position = Vector2(x,pos_y + size_y - 1) * TILE_SIZE
		sprite.centered = false
		sprite.z_index = 5
		telhado.append(sprite)
		self.add_child(sprite)

	for y in range(pos_y + 1, pos_y + size_y - 1):
		mapa[pos_x][y] = Tile.ParedeDireita
		sprite = Sprite.new()
		sprite.texture = load("res://Sprites/Tiles/TelhadoMeioEsquerda.png")
		sprite.position = Vector2(pos_x,y) * TILE_SIZE
		sprite.centered = false
		sprite.z_index = 5
		telhado.append(sprite)
		self.add_child(sprite)
		mapa[pos_x + size_x - 1][y] = Tile.ParedeEsquerda
		sprite = Sprite.new()
		sprite.texture = load("res://Sprites/Tiles/TelhadoMeioDireita.png")
		sprite.position = Vector2(pos_x + size_x - 1,y) * TILE_SIZE
		sprite.centered = false
		sprite.z_index = 5
		telhado.append(sprite)
		self.add_child(sprite)
		for x in range(pos_x + 1, pos_x + size_x - 1):
			mapa[x][y] = Tile.ChaoEscuro
			sprite = Sprite.new()
			sprite.texture = load("res://Sprites/Tiles/Telhado.png")
			sprite.position = Vector2(x,y) * TILE_SIZE
			sprite.centered = false
			sprite.z_index = 5
			telhado.append(sprite)
			self.add_child(sprite)
	mapa[pos_x][pos_y] = Tile.CantoCEFora
	sprite = Sprite.new()
	sprite.texture = load("res://Sprites/Tiles/TelhadoCantoSuperiorEsquerdo.png")
	sprite.position = Vector2(pos_x,pos_y) * TILE_SIZE
	sprite.centered = false
	sprite.z_index = 5
	telhado.append(sprite)
	self.add_child(sprite)
	mapa[pos_x + size_x - 1][pos_y] = Tile.CantoCDFora
	sprite = Sprite.new()
	sprite.texture = load("res://Sprites/Tiles/TelhadoCantoSuperiorDireito.png")
	sprite.position = Vector2(pos_x + size_x - 1,pos_y) * TILE_SIZE
	sprite.centered = false
	sprite.z_index = 5
	telhado.append(sprite)
	self.add_child(sprite)
	mapa[pos_x][pos_y+ size_y - 1] = Tile.CantoBEFora
	sprite = Sprite.new()
	sprite.texture = load("res://Sprites/Tiles/TelhadoCantoInferiorEsquerdo.png")
	sprite.position = Vector2(pos_x,pos_y+ size_y - 1) * TILE_SIZE
	sprite.centered = false
	sprite.z_index = 5
	telhado.append(sprite)
	self.add_child(sprite)
	mapa[pos_x + size_x - 1][pos_y+ size_y - 1] = Tile.CantoBDFora
	sprite = Sprite.new()
	sprite.texture = load("res://Sprites/Tiles/TelhadoCantoInferiorDireito.png")
	sprite.position = Vector2(pos_x + size_x - 1,pos_y+ size_y - 1) * TILE_SIZE
	sprite.centered = false
	sprite.z_index = 5
	telhado.append(sprite)
	self.add_child(sprite)
	cut_region(_tiles_livres, sala)

func conecta_salas():
	var grafo_preto = AStar.new()
	var ponto_id = 0
	
	for x in range(level_size.x):
		for y in range(level_size.y):
			if mapa[x][y] == Tile.Grama:
				grafo_preto.add_point(ponto_id, Vector3(x,y,0))
				if x > 0 && mapa[x-1][y] == Tile.Grama:
					var ponto_esq = grafo_preto.get_closest_point(Vector3(x-1,y,0))
					grafo_preto.connect_points(ponto_id, ponto_esq)
				if y > 0 && mapa[x][y-1] == Tile.Grama:
					var ponto_baixo = grafo_preto.get_closest_point(Vector3(x,y-1,0))
					grafo_preto.connect_points(ponto_id, ponto_baixo)
				ponto_id += 1
	
	var grafo_salas = AStar.new()
	ponto_id = 0
	for sala in salas:
		var centro = sala.position + sala.size/2
		grafo_salas.add_point(ponto_id, Vector3(centro.x,centro.y,0))
		ponto_id +=1
	
	while !todos_conectados(grafo_salas):
		add_conexao(grafo_preto, grafo_salas)

func cut_region(_tiles_limpos, _regiao_removida):
	var regiao_apagada = []
	var regiao_adicionada = []
	
	for regiao in _tiles_limpos:
		if regiao.intersects(_regiao_removida):
			regiao_apagada.append(regiao)
			
			var borda_esq = _regiao_removida.position.x - regiao.position.x - 1
			var borda_dir = regiao.end.x - _regiao_removida.end.x - 1
			var borda_cima = _regiao_removida.position.y - regiao.position.y - 1
			var borda_baixo = regiao.end.y - _regiao_removida.end.y - 1
			
			if borda_esq >= MIN_ROOM_SIZE:
				regiao_adicionada.append(Rect2(regiao.position, Vector2(borda_esq, regiao.size.y)))
			if borda_dir >= MIN_ROOM_SIZE:
				regiao_adicionada.append(Rect2(Vector2(_regiao_removida.end.x + 1, regiao.position.y),Vector2(borda_dir, regiao.size.y)))
			if borda_cima >= MIN_ROOM_SIZE:
				regiao_adicionada.append(Rect2(regiao.position, Vector2(regiao.size.x, borda_cima)))
			if borda_baixo >= MIN_ROOM_SIZE:
				regiao_adicionada.append(Rect2(Vector2(regiao.position.x, _regiao_removida.end.y + 1),Vector2(regiao.size.x, borda_baixo)))
				
	for regiao in regiao_apagada:
		_tiles_limpos.erase(regiao)
	for regiao in regiao_adicionada:
		_tiles_limpos.append(regiao)

func todos_conectados(_grafo):
	var pontos = _grafo.get_points()
	var inicio = pontos.pop_back()
	
	for ponto in pontos:
		var caminho = _grafo.get_point_path(inicio, ponto)
		if !caminho:
			return false
	return true

func add_conexao(_grafo_preto, _grafo_salas):
	var sala_inicial = ultimo_ponto_conectado(_grafo_salas)
	var sala_final = sala_mais_proxima_desconectada(_grafo_salas,sala_inicial)
	
	var porta_inicial = gera_porta(salas[sala_inicial])
	var porta_final = gera_porta(salas[sala_final])
	
	var inicio = _grafo_preto.get_closest_point(porta_inicial)

	var fim =  _grafo_preto.get_closest_point(porta_final)

	var caminho = _grafo_preto.get_point_path(inicio, fim)
	
	if mapa[porta_inicial.x][porta_inicial.y -1] == Tile.ChaoEscuro:
		mapa[porta_inicial.x][porta_inicial.y]=Tile.PortaFechadaCima
	if mapa[porta_inicial.x][porta_inicial.y + 1] == Tile.ChaoEscuro:
		mapa[porta_inicial.x][porta_inicial.y]=Tile.PortaFechadaBaixo
	if mapa[porta_inicial.x - 1][porta_inicial.y] == Tile.ChaoEscuro:
		mapa[porta_inicial.x][porta_inicial.y]=Tile.PortaFechadaEsquerda
	if mapa[porta_inicial.x + 1][porta_inicial.y] == Tile.ChaoEscuro:
		mapa[porta_inicial.x][porta_inicial.y]=Tile.PortaFechadaDireita
	
	if mapa[porta_final.x][porta_final.y -1] == Tile.ChaoEscuro:
		mapa[porta_final.x][porta_final.y]=Tile.PortaFechadaCima
	if mapa[porta_final.x][porta_final.y + 1] == Tile.ChaoEscuro:
		mapa[porta_final.x][porta_final.y]=Tile.PortaFechadaBaixo
	if mapa[porta_final.x - 1][porta_final.y] == Tile.ChaoEscuro:
		mapa[porta_final.x][porta_final.y]=Tile.PortaFechadaEsquerda
	if mapa[porta_final.x + 1][porta_final.y] == Tile.ChaoEscuro:
		mapa[porta_final.x][porta_final.y]=Tile.PortaFechadaDireita
		 
	for posicao in caminho:
		mapa[posicao.x][posicao.y] = Tile.ChaoClaro

	_grafo_salas.connect_points(sala_inicial, sala_final)

func ultimo_ponto_conectado(_grafo):
	var pontos = _grafo.get_points()
	var ultimo
	var conectados = []
	
	for ponto in pontos:
		var count = _grafo.get_point_connections(ponto).size()
		if !ultimo || count < ultimo:
			ultimo = count
			conectados = [ponto]
		elif count == ultimo:
			conectados.append(ponto)
	return conectados[randi()% conectados.size()]

func sala_mais_proxima_desconectada(_grafo,_alvo):
	var posicao = _grafo.get_point_position(_alvo)
	var pontos = _grafo.get_points()
	
	var menor_distancia
	var conectados = []
	
	for ponto in pontos:
		if ponto == _alvo:
			continue
		
		var caminho = _grafo.get_point_path(ponto, _alvo)
		if caminho:
			continue
		
		var dist = (_grafo.get_point_position(ponto) - posicao).length()
		if !menor_distancia || dist < menor_distancia:
			menor_distancia = dist
			conectados = [ponto]
		elif dist == menor_distancia:
			conectados.append(ponto)
	
	return conectados[randi()% conectados.size()]

func gera_porta(_sala):
	var opcoes = []
	for x in range(_sala.position.x + 1, _sala.end.x - 2):
		if mapa[x+1][_sala.position.y] != Tile.PortaFechadaCima and mapa[x+1][_sala.position.y] != Tile.PortaFechadaBaixo and mapa[x+1][_sala.position.y] != Tile.PortaFechadaEsquerda and mapa[x+1][_sala.position.y] != Tile.PortaFechadaDireita:
			opcoes.append(Vector3(x, _sala.position.y,0))
		if mapa[x+1][_sala.end.y] != Tile.PortaFechadaCima and mapa[x+1][_sala.end.y] != Tile.PortaFechadaBaixo and mapa[x+1][_sala.end.y] != Tile.PortaFechadaEsquerda and mapa[x+1][_sala.end.y] != Tile.PortaFechadaDireita:
			opcoes.append(Vector3(x, _sala.end.y - 1,0))
	for y in range(_sala.position.y + 1, _sala.end.y - 2):
		if mapa[_sala.position.x][y+1] != Tile.PortaFechadaCima and mapa[_sala.position.x][y+1] != Tile.PortaFechadaBaixo and mapa[_sala.position.x][y+1] != Tile.PortaFechadaEsquerda and mapa[_sala.position.x][y+1] != Tile.PortaFechadaDireita:
			opcoes.append(Vector3(_sala.position.x, y,0))
		if mapa[_sala.end.x][y+1] != Tile.PortaFechadaCima and mapa[_sala.end.x][y+1] != Tile.PortaFechadaBaixo and mapa[_sala.end.x][y+1] != Tile.PortaFechadaEsquerda and mapa[_sala.end.x][y+1] != Tile.PortaFechadaDireita:
			opcoes.append(Vector3(_sala.end.x - 1, y ,0))
	return opcoes[randi()%opcoes.size()]

func atualiza_caminho():
	pathfinding = AStar.new()
	for x in range(level_size.x):
		for y in range(level_size.y):
			var tile = mapa[x][y]
			var _tile = Vector2(x,y)
			if tile ==Tile.ChaoClaro or tile ==Tile.ChaoEscuro or tile == Tile.PortaAbertaCima or tile == Tile.PortaAbertaDireita or tile == Tile.PortaAbertaBaixo or tile == Tile.PortaAbertaEsquerda or tile == Tile.PortaFechadaDireita or tile == Tile.PortaFechadaCima or tile == Tile.PortaFechadaBaixo or tile == Tile.PortaFechadaEsquerda or tile == Tile.Escada:
				add_tile(_tile)

func add_tile(_tile):
	var novo_ponto = pathfinding.get_available_point_id()
	pathfinding.add_point(novo_ponto, Vector3(_tile.x,_tile.y,0))

	var points_to_connect = []
	if _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.ChaoClaro or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.ChaoEscuro or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaAbertaCima or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaAbertaDireita or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaAbertaBaixo or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaAbertaEsquerda or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaFechadaBaixo or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaFechadaCima or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaFechadaDireita or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.PortaFechadaEsquerda or _tile.x > 0 && mapa[_tile.x-1][_tile.y] == Tile.Escada:
		points_to_connect.append(pathfinding.get_closest_point(Vector3(_tile.x-1,_tile.y,0)))
	if _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.ChaoClaro or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.ChaoEscuro or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaAbertaCima or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaAbertaDireita or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaAbertaBaixo or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaAbertaEsquerda or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaFechadaBaixo or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaFechadaCima or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaFechadaDireita or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.PortaFechadaEsquerda or _tile.y > 0 && mapa[_tile.x][_tile.y-1] == Tile.Escada:
		points_to_connect.append(pathfinding.get_closest_point(Vector3(_tile.x,_tile.y-1,0)))
	if _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.ChaoClaro or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.ChaoEscuro or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaAbertaCima or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaAbertaDireita or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaAbertaBaixo or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaAbertaEsquerda or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaFechadaBaixo or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaFechadaCima or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaFechadaDireita or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.PortaFechadaEsquerda or _tile.x < level_size.x - 1 && mapa[_tile.x+1][_tile.y] == Tile.Escada:
		points_to_connect.append(pathfinding.get_closest_point(Vector3(_tile.x+1,_tile.y,0)))
	if _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.ChaoClaro or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.ChaoEscuro or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaAbertaCima or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaAbertaDireita or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaAbertaBaixo or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaAbertaEsquerda or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaFechadaBaixo or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaFechadaCima or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaFechadaDireita or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.PortaFechadaEsquerda or _tile.y < level_size.y - 1 && mapa[_tile.x][_tile.y+1] == Tile.Escada:
		points_to_connect.append(pathfinding.get_closest_point(Vector3(_tile.x,_tile.y+1,0)))

	for points in points_to_connect:
		pathfinding.connect_points(points,novo_ponto)

func _Pause_Continue():
	destino = Vector2(-1,-1)
	pausado = false
	$UI/Pause.visible = false
	$UI/Dados.visible = false

func _Pause_MenuPrincipal():
	MusicController.play("res://Sounds/MenuTrack.ogg")
	get_tree().change_scene("res://Cenas/Menu.tscn")

func _Pause__Sair():
	Data.save()
	get_tree().quit()

func _Pausar():
	if !pausado:
		destino = Vector2(-1,-1)
		pausado = true
		$UI/Pause.visible = true

func UsarAlma():
	if !pausado:
		destino = Vector2(-1,-1)
		player.usa_alma(self)

func _on_Menu_button_down():
	Data.save()
	MusicController.play("res://Sounds/MenuTrack.ogg")
	get_tree().change_scene("res://Cenas/Menu.tscn")

func _on_DadosBtn_button_down():
	if !pausado:
		destino = Vector2(-1,-1)
		pausado = true
		$UI/Dados.visible = true
		$UI/Dados/HPAtual.text = var2str(int(player.hp)) 
		$UI/Dados/HPMax.text = var2str(int(player.hp_max)) 
		$UI/Dados/XPAtual.text = var2str(int(player.xp)) 
		$UI/Dados/XPMax.text = var2str(int(player.xp_max)) 
		$UI/Dados/Pontos.text = var2str(int(player.pontos))
		$UI/Dados/BarraHP.rect_size.x = 200 * player.hp/player.hp_max
		$UI/Dados/BarraXP.rect_size.x = 200 * player.xp/player.xp_max
		
		if roubo_vida == true:
			$UI/Dados/BtnRouboVida.visible = false
			$UI/Dados/VlRouboVIda.text = "Comprado"
		if alma_aleatoria == true:
			$UI/Dados/BtnAlma.visible = false
			$UI/Dados/VlAlma.text = "Comprado"
		if vida_extra != 0:
			$UI/Dados/BtnVida.visible = false
			$UI/Dados/VlVida.text = "Comprado"
		
		if player.pontos < 1:
			$UI/Dados/BtnRouboVida.disabled = true
			$UI/Dados/BtnAlma.disabled = true
		if player.pontos < 3:
			$UI/Dados/BtnVida.disabled = true
		
		if player.almas.size() > 0:
			match player.almas[0].elemento:
				Elementos.Terra:
					$UI/Dados/Alma1.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma1.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma1.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma1.animation = "Ar"
		else:
			$UI/Dados/Alma1.visible = false
		if player.almas.size() > 1:
			match player.almas[1].elemento:
				Elementos.Terra:
					$UI/Dados/Alma2.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma2.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma2.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma2.animation = "Ar"
		else:
			$UI/Dados/Alma2.visible = false
		if player.almas.size() > 2:
			match player.almas[2].elemento:
				Elementos.Terra:
					$UI/Dados/Alma3.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma3.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma3.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma3.animation = "Ar"
		else:
			$UI/Dados/Alma3.visible = false
		if player.almas.size() > 3:
			match player.almas[3].elemento:
				Elementos.Terra:
					$UI/Dados/Alma4.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma4.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma4.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma4.animation = "Ar"
		else:
			$UI/Dados/Alma4.visible = false
		if player.almas.size() > 4:
			match player.almas[4].elemento:
				Elementos.Terra:
					$UI/Dados/Alma5.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma5.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma5.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma5.animation = "Ar"
		else:
			$UI/Dados/Alma5.visible = false
		if player.almas.size() > 5:
			match player.almas[5].elemento:
				Elementos.Terra:
					$UI/Dados/Alma6.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma6.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma6.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma6.animation = "Ar"
		else:
			$UI/Dados/Alma6.visible = false
		if player.almas.size() > 6:
			match player.almas[6].elemento:
				Elementos.Terra:
					$UI/Dados/Alma7.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma7.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma7.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma7.animation = "Ar"
		else:
			$UI/Dados/Alma7.visible = false
		if player.almas.size() > 7:
			match player.almas[7].elemento:
				Elementos.Terra:
					$UI/Dados/Alma8.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma8.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma8.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma8.animation = "Ar"
		else:
			$UI/Dados/Alma8.visible = false
		if player.almas.size() > 8:
			match player.almas[8].elemento:
				Elementos.Terra:
					$UI/Dados/Alma9.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma9.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma9.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma9.animation = "Ar"
		else:
			$UI/Dados/Alma9.visible = false
		if player.almas.size() > 9:
			match player.almas[9].elemento:
				Elementos.Terra:
					$UI/Dados/Alma10.animation = "Terra"
				Elementos.Agua:
					$UI/Dados/Alma10.animation = "Agua"
				Elementos.Fogo:
					$UI/Dados/Alma10.animation = "Fogo"
				Elementos.Ar:
					$UI/Dados/Alma10.animation = "Ar"
		else:
			$UI/Dados/Alma10.visible = false

func play(track_url : String):
	stop()
	var new_track = load(track_url)
	sfx.stream = new_track
	sfx.volume_db = -30
	sfx.play()

func stop():
	sfx.stop()

func _on_BtnRouboVida_button_down():
	destino = Vector2(-1,-1)
	player.pontos-=1
	$UI/Dados/Pontos.text = var2str(int(player.pontos))
	$UI/Dados/BtnRouboVida.visible = false
	$UI/Dados/VlRouboVIda.text = "Comprado"
	roubo_vida = true

func _on_BtnAlma_button_down():
	destino = Vector2(-1,-1)
	player.pontos-=1
	$UI/Dados/Pontos.text = var2str(int(player.pontos))
	$UI/Dados/BtnAlma.visible = false
	$UI/Dados/VlAlma.text = "Comprado"
	alma_aleatoria = true

func _on_BtnVida_button_down():
	destino = Vector2(-1,-1)
	player.pontos-=3
	$UI/Dados/Pontos.text = var2str(int(player.pontos))
	$UI/Dados/BtnVida.visible = false
	$UI/Dados/VlVida.text = "Comprado"
	vida_extra = true


func Carta_continue():
	if carta == 0:
		$UI/Carta/Label.text= "Pelo o que eu fiquei sabendo, os inimigos ao morreram, deixam cair suas almas. A espada que você empunha tem o poder de consumir a energia dessas almas. Talvez isso ajude na sua jornada. Preciso que você adentre até o final do cemitério, encontre a cripta de Líllica e destrua a lápide do túmulo para liberar a maldição. Somente assim, então, o reino voltará a ter paz."
		carta = 1
	else:
		$UI/Carta.visible = false
		Data.carta = false
		pausado = false
