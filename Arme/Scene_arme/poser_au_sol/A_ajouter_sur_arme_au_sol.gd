extends RigidBody3D

@export var objet : Arme
@export var quantite : int = 1


func _ready() -> void:
	add_to_group("ramassable")

func ramasser() -> void:
	IventaireManager.ajouter_objet(objet, quantite)
	queue_free()
