extends Control

@export var type_filtre : Objet.TypeObjet
@onready var grille : GridContainer = $GridContainer

var menu_objet_scene = preload("res://ui/UI_inventaire/menu_objet.tscn")
var menu_actuel : PopupPanel = null

func _ready() -> void:
	IventaireManager.objet_ajoute.connect(_on_inventaire_change)
	IventaireManager.objet_retire.connect(_on_inventaire_change)
	rafraichir()

func _on_inventaire_change(_objet, _quantite) -> void:
	rafraichir()

func rafraichir() -> void:
	for enfant in grille.get_children():
		enfant.queue_free()

	for entree in IventaireManager.contenu.values():
		if entree.objet.type_objet == type_filtre:
			var slot = preload("res://ui/UI_inventaire/slot_objet.tscn").instantiate()
			grille.add_child(slot)
			slot.configurer(entree.objet, entree.quantite)
			slot.slot_clique.connect(_on_slot_clique)

func _on_slot_clique(objet: Objet, quantite: int, position_ecran: Vector2) -> void:
	if menu_actuel:
		menu_actuel.queue_free()
	menu_actuel = menu_objet_scene.instantiate()
	add_child(menu_actuel)
	menu_actuel.ouvrir_pour(objet, quantite, position_ecran)
