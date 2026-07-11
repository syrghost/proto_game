# projectile.gd
extends Node3D

var effet_associe : EffetCombat
var vitesse : float

func configurer(effet: EffetCombat) -> void:
	effet_associe = effet
	vitesse = effet.vitesse_projectile

func lancer() -> void:
	pass  # démarre le mouvement, ex: dans _physics_process

func _on_body_entered(body: Node3D) -> void:
	var sante := body.get_node_or_null("Sante") as Sante
	if sante and sante.est_vivant():
		sante.subir_degats(effet_associe.degats)

	if effet_associe.declenche_zone_a_impact:
		var gestionnaire = get_tree().get_first_node_in_group("gestionnaire_combat")
		gestionnaire._executer_zone(effet_associe, global_position)

	queue_free()
