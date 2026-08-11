
extends Node
var focus_ennemi_cible: Control
var popup_resu_actuel : PopupPanel = null

func _ready() -> void:
	IventaireManager.demande_choix_resu.connect(_on_demande_choix_resu)

func _on_demande_choix_resu(liste_resu: Array) -> void:
	get_tree().paused = true
	if popup_resu_actuel:
		popup_resu_actuel.queue_free()
	var scene = preload("res://ui/UI_objet_resu/popup_resu.tscn")
	popup_resu_actuel = scene.instantiate()
	popup_resu_actuel.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(popup_resu_actuel)
	popup_resu_actuel.ouvrir_pour(liste_resu)
