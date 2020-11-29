extends Node2D

func _ready():
	OS.set_window_size(Vector2(1280,720))
	$Missoes/MissaoalmaaguaTotal.text = var2str(int(Data.missao_alma_agua.progressao))+"/"+var2str(int(Data.missao_alma_agua.objetivo))
	$Missoes/MissaoalmafogoTotal.text = var2str(int(Data.missao_alma_fogo.progressao))+"/"+var2str(int(Data.missao_alma_fogo.objetivo))
	$Missoes/MissaoalmaterraTotal.text = var2str(int(Data.missao_alma_terra.progressao))+"/"+var2str(int(Data.missao_alma_terra.objetivo))
	$Missoes/MissaoalmaarTotal.text = var2str(int(Data.missao_alma_ar.progressao))+"/"+var2str(int(Data.missao_alma_ar.objetivo))
	$Missoes/MissaoinimigoaguaTotal.text = var2str(int(Data.missao_inimigo_agua.progressao))+"/"+var2str(int(Data.missao_inimigo_agua.objetivo))
	$Missoes/MissaoinimigofogoTotal.text = var2str(int(Data.missao_inimigo_fogo.progressao))+"/"+var2str(int(Data.missao_inimigo_fogo.objetivo))
	$Missoes/MissaoinimigoterraTotal.text = var2str(int(Data.missao_inimigo_terra.progressao))+"/"+var2str(int(Data.missao_inimigo_terra.objetivo))
	$Missoes/MissaoinimigoarTotal.text = var2str(int(Data.missao_inimigo_ar.progressao))+"/"+var2str(int(Data.missao_inimigo_ar.objetivo))
func _on_Voltar_button_down():
	get_tree().change_scene("res://Cenas/Menu.tscn")
