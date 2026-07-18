extends Node

@export var point_attache : Node3D  # glisse le Marker3D/PointArme ici
var instance_arme_actuelle : Node3D = null

func _ready() -> void:
	IventaireManager.arme_equipee.connect(_on_arme_equipee)
	EtatAnimationJoueur.arme_sorti.connect(_on_arme_sorti)
	EtatAnimationJoueur.arme_ranger.connect(_on_arme_ranger)

func _on_arme_equipee(arme: Arme) -> void:
	if instance_arme_actuelle:
		instance_arme_actuelle.queue_free()
		instance_arme_actuelle = null

	if arme and arme.scene_modele:
		instance_arme_actuelle = arme.scene_modele.instantiate()
		point_attache.add_child(instance_arme_actuelle)
		instance_arme_actuelle.visible = false #cacher tand que l'animation n'a pas jouer
		
func _on_arme_sorti():
	if instance_arme_actuelle:
		instance_arme_actuelle.visible = true
func  _on_arme_ranger():
	if instance_arme_actuelle:
		instance_arme_actuelle.visible = false
