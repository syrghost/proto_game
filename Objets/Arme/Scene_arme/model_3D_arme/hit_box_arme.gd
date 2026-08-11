extends Area3D
var deja_touches : Array[Node3D] = []
var degats : int = 0
var groupe_cible : String = "ennemis"
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
			var degats_finaux = degats
			if body.is_in_group("joueur"):
				degats_finaux = calculer_degats_reduits(degats, self)
			sante_node.subir_degats(degats_finaux)

func attaque_vient_de_face(attaquant: Node3D) -> bool:
	var direction_joueur = -EtatAnimationJoueur.player.mesh.global_transform.basis.z
	var direction_vers_attaquant = (attaquant.global_position - EtatAnimationJoueur.player.global_position).normalized()
	var angle = rad_to_deg(direction_joueur.angle_to(direction_vers_attaquant))
	return angle < 90.0

func calculer_degats_reduits(degats_bruts: int, attaquant: Node3D) -> int:
	var defense = 0
	if IventaireManager.armure_equipee_actuelle:
		defense += IventaireManager.armure_equipee_actuelle.defense
	if IventaireManager.bottes_equipees_actuelles:
		defense += IventaireManager.bottes_equipees_actuelles.defense

	var degats_apres_defense = max(degats_bruts - defense, 1)

	if EtatAnimationJoueur.en_blocage and IventaireManager.bouclier_equipe_actuel and attaque_vient_de_face(attaquant):
		var temps_ecoule = Time.get_ticks_msec() / 1000.0 - EtatAnimationJoueur.temps_debut_blocage
		var bouclier = IventaireManager.bouclier_equipe_actuel
		if temps_ecoule <= bouclier.fenetre_parade:
			print("Parade parfaite !")
			EtatAnimationJoueur.animation.play(bouclier.animation_parade)
			var ennemi = attaquant.get_parent()
			if ennemi.has_method("etourdir"):
				var direction_recul = (ennemi.global_position - EtatAnimationJoueur.player.global_position).normalized()
				ennemi.etourdir(bouclier.etourdissement_ennemi, direction_recul)
			return 0
		else:
			EtatAnimationJoueur.animation.play(bouclier.animation_dmg_blocage)
			return int(degats_apres_defense * (1.0 - bouclier.reduction_degats))

	return degats_apres_defense
