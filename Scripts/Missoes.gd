extends Node2D

func _ready():
	OS.set_window_size(Vector2(1280,720))
	$Missoes/MissaoaguaTotal.text = var2str(int(Data.missao_agua.progressao))+"/"+var2str(int(Data.missao_agua.objetivo))
	$Missoes/MissaoaguaNivel.text = var2str(int(Data.missao_agua.nivel))
	$Missoes/MissaofogoTotal.text = var2str(int(Data.missao_fogo.progressao))+"/"+var2str(int(Data.missao_fogo.objetivo))
	$Missoes/MissaofogoNivel.text = var2str(int(Data.missao_fogo.nivel))
	$Missoes/MissaoterraTotal.text = var2str(int(Data.missao_terra.progressao))+"/"+var2str(int(Data.missao_terra.objetivo))
	$Missoes/MissaoterraNivel.text = var2str(int(Data.missao_terra.nivel))
	$Missoes/MissaoarTotal.text = var2str(int(Data.missao_ar.progressao))+"/"+var2str(int(Data.missao_ar.objetivo))
	$Missoes/MissaoarNivel.text = var2str(int(Data.missao_ar.nivel))
func _on_Voltar_button_down():
	get_tree().change_scene("res://Cenas/Menu.tscn")
