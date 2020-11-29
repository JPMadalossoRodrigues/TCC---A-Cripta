extends Node2D

func _ready():
	atualiza_dados()


func atualiza_dados():
	$Itens/Moedas.text = "$ "+var2str(int(Data.moedas)) 
	if Data.moedas < 500:
		$Itens/LojaXPComprar.disabled = true
	if Data.moedas < 200:
		$Itens/LojaPontosComprar.disabled = true
	if Data.moedas < 100:
		$Itens/LojaTurnosfogoComprar.disabled = true
		$Itens/LojaTurnosaguaComprar.disabled = true
		$Itens/LojaTurnosarComprar.disabled = true
		$Itens/LojaTurnosterraComprar.disabled = true
	if Data.loja_dobro_xp.comprado:
		$Itens/LojaXPPreco.text = "Comprado"
		$Itens/LojaXPComprar.disabled = true
	if Data.loja_inicia_ponto.comprado:
		$Itens/LojaPontosPreco.text = "Comprado"
		$Itens/LojaPontosComprar.disabled = true
	if Data.loja_turnos_agua.comprado:
		$Itens/LojaTurnosaguaPreco.text = "Comprado"
		$Itens/LojaTurnosaguaComprar.disabled = true
	if Data.loja_turnos_fogo.comprado:
		$Itens/LojaTurnosfogoPreco.text = "Comprado"
		$Itens/LojaTurnosfogoComprar.disabled = true
	if Data.loja_turnos_terra.comprado:
		$Itens/LojaTurnosterraPreco.text = "Comprado"
		$Itens/LojaTurnosterraComprar.disabled = true
	if Data.loja_turnos_ar.comprado:
		$Itens/LojaTurnosarPreco.text = "Comprado"
		$Itens/LojaTurnosarComprar.disabled = true


func _on_Voltar_button_down():
	get_tree().change_scene("res://Cenas/Menu.tscn")


func _on_LojaTurnosfogoComprar_button_down():
	Data.loja_turnos_fogo.comprado = true
	Data.moedas -= 100
	atualiza_dados()
func _on_LojaTurnosaguaComprar_button_down():
	Data.loja_turnos_agua.comprado = true
	Data.moedas -=100
	atualiza_dados()
func _on_LojaTurnosterraComprar_button_down():
	Data.loja_turnos_terra.comprado = true
	Data.moedas -=100
	atualiza_dados()
func _on_LojaTurnosarComprar_button_down():
	Data.loja_turnos_ar.comprado = true
	Data.moedas -=100
	atualiza_dados()


func _on_LojaPontosComprar_button_down():
	Data.loja_inicia_ponto.comprado = true
	Data.moedas -=200
	atualiza_dados()


func _on_LojaXPComprar_button_down():
	Data.loja_dobro_xp.comprado = true
	Data.moedas -=500
	atualiza_dados()
