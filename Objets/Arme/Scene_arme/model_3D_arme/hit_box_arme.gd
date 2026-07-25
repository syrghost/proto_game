extends Area3D
var deja_touches : Array[Node3D] = []
var degats : int = 0
var groupe_cible : String = "ennemis"  # par défaut, pour le joueur
@export var arme : Arme

func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)
	if arme:
		degats = arme.dommage_arme

func activer(quantite_degats: int, cible: String = "ennemis") -> void:
	deja_touches.clear()
	degats = quantite_degats
	groupe_cible = cible
	monitoring = true
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func desactiver() -> void:
	monitoring = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(groupe_cible) and body not in deja_touches:
		deja_touches.append(body)
		var sante_node = body.get_node_or_null("Sante")
		if sante_node:
			sante_node.subir_degats(degats)
