extends Node

@export var point_attache : Node3D  # glisse le Marker3D/PointArme ici
var instance_arme_actuelle : Node3D = null

func _ready() -> void:
	IventaireManager.arme_equipee.connect(_on_arme_equipee)


func _on_arme_equipee(arme: Arme) -> void:
	print("Signal reçu, arme = ", arme)
	print("point_attache = ", point_attache)

	if instance_arme_actuelle:
		instance_arme_actuelle.queue_free()
		instance_arme_actuelle = null

	if arme and arme.scene_modele:
		print("scene_modele valide, instanciation...")
		instance_arme_actuelle = arme.scene_modele.instantiate()
		point_attache.add_child(instance_arme_actuelle)
		print("Arme ajoutée à point_attache")
	else:
		print("ECHEC : arme ou scene_modele est null")
