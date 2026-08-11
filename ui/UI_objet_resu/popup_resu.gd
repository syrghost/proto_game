extends PopupPanel
@onready var conteneur: HBoxContainer = $VBoxContainer/HBoxContainer

var slot_resu_scene = preload("res://ui/UI_objet_resu/slot_resu.tscn")

func ouvrir_pour(liste_resu: Array) -> void:
	for enfant in conteneur.get_children():
		enfant.queue_free()
	for entree in liste_resu:
		var slot = slot_resu_scene.instantiate()
		conteneur.add_child(slot)
		slot.configurer(entree.objet)
		slot.resu_clique.connect(_on_resu_clique)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	popup_centered()

func _on_resu_clique(resu: Resu) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	IventaireManager.utiliser_resu(resu)
	queue_free()

func _on_bouton_non_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	IventaireManager.refuse_resu()
	queue_free()
