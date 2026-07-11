extends TextureButton

@onready var icone: TextureRect = $Icone
@onready var label_quantite: Label = $Quantiter


var objet_reference : Objet
var quantite_reference : int

signal slot_clique(objet: Objet, quantite: int, position_ecran: Vector2)

func configurer(objet: Objet, quantite: int) -> void:
	objet_reference = objet
	quantite_reference = quantite
	icone.texture = objet.icone
	label_quantite.visible = quantite > 1
	label_quantite.text = str(quantite)

func _on_pressed() -> void:
	slot_clique.emit(objet_reference, quantite_reference, get_global_mouse_position())
