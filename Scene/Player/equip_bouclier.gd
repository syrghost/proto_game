extends Node

@export var point_attache_bouclier : Node3D 
var instance_bouclier : Node3D = null


func _ready() -> void:
	IventaireManager.bouclier_equipe.connect(equiper_visuel_bouclier)
	IventaireManager.bouclier_desequipe.connect(desequiper_visuel_bouclier)

func equiper_visuel_bouclier(bouclier: Bouclier) -> void:
	if instance_bouclier:
		instance_bouclier.queue_free()
		instance_bouclier = null
	if bouclier and bouclier.scene_modele:
		instance_bouclier = bouclier.scene_modele.instantiate()
		point_attache_bouclier.add_child(instance_bouclier)

func desequiper_visuel_bouclier() -> void:
	if instance_bouclier:
		instance_bouclier.queue_free()
		instance_bouclier = null
