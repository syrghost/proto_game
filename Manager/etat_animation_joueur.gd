extends Node
var arme:Arme
signal arme_ranger
signal arme_sorti
#-------------------------------POUR DETECTION ENNEMI------------------------
var ennemis_a_portee : Array[Node3D] = []
var cible_verrouillee : Node3D = null
var verrouillage_actif : bool = false
var hitbox_arme: Area3D

#---------------------------------------------------------------------------------
#------------------------------- POUR COMBO ----------------------------
var index_combo : int = 0
var input_attaque_en_attente : bool = false
#-------------------------------------------------------------------------
var en_transition : bool = false
enum Etat{
	normal,
	idle_combat,
	Attaque
}
var etat_actuel = Etat.normal
var nombre_ennemis = 0
var animation : AnimationPlayer
var animation_tree : AnimationTree
var player : CharacterBody3D
var sprint_autoriser : bool = true
var camera : Camera3D
var sante_player : Sante
var mana_player : Mana

var indicateur_zone : Node3D = null
var sort_zone_en_attente: Grimoire = null

#----------------------------- POUR LE BOUCLIER ----------------------------------------
var en_blocage : bool = false
var temps_debut_blocage : float = 0.0


func _ready() -> void:
	IventaireManager.arme_equipee.connect(_on_arm_equipee)
	IventaireManager.arme_desequipee.connect(_on_arm_desequipee)
func _on_arm_equipee(nouvelle_arme : Arme):
	arme = nouvelle_arme
	if nouvelle_arme != null:
		mettre_a_jour_blend_arme(nouvelle_arme)

func _on_arm_desequipee(_arme_retirer : Arme):
	arme = null
	if etat_actuel != Etat.normal:
		# L'arme a été retirée depuis l'inventaire pendant le combat : on force le retour
		en_transition = false
		player.peut_bouger = true
		etat_actuel = Etat.normal
		index_combo = 0

func _physics_process(_delta: float) -> void:
	match etat_actuel:
		Etat.normal:
			mode_exploration()
		Etat.idle_combat:
			mode_idle_combat()
		Etat.Attaque:
			mode_attaque()

func mode_exploration():
	sprint_autoriser = true
	if en_transition or en_blocage :
		return
	if player.direction:
		if player.courir:
			if animation.current_animation != "courir":
				animation.play("courir")
		else:
			if animation.current_animation != "marche":
				animation.play("marche")
	else:
		if animation.current_animation != "idle":
			animation.play("idle")

func mode_idle_combat():
	sprint_autoriser = not(verrouillage_actif and cible_verrouillee)
	if en_transition or en_blocage:
		return
	if arme == null:
		changement_d_etat(Etat.normal)
		return

	if player.direction:
		player.vitesse = arme.vitesse_player_avec_arme
		if verrouillage_actif and cible_verrouillee:
			animation_tree.active = true
			var dir_relative = calculer_direction_relative(player.direction, player.mesh.global_transform)
			animation_tree.set("parameters/blend_position", dir_relative)
		else:
			animation_tree.active = false
			if animation.current_animation != arme.animation_marche_combat_arme:
				animation.play(arme.animation_marche_combat_arme, 0.2)
	else:
		animation_tree.active = false
		if animation.current_animation != arme.animation_idle_arme:
			animation.play(arme.animation_idle_arme, 0.2)

func mode_attaque():
	pass
func calculer_direction_relative(dir_monde: Vector3, mesh_transform: Transform3D) -> Vector2:
	if dir_monde == Vector3.ZERO:
		return Vector2.ZERO
	var forward = -mesh_transform.basis.z
	var right = mesh_transform.basis.x
	var avant_arriere = forward.dot(dir_monde)   # positif = avance, négatif = recule
	var gauche_droite = right.dot(dir_monde)      # positif = droite, négatif = gauche
	return Vector2(gauche_droite, avant_arriere)


#--------------------------------------------METTRE A JOUR LES ANIMATION DE FOCUS DE L ARME DE L ANIM TREE------------------
func mettre_a_jour_blend_arme(nouvelle_arme: Arme) -> void:
	var blend_space := animation_tree.tree_root as AnimationNodeBlendSpace2D
	if blend_space == null:
		print("pas trouver")
		return

	for i in blend_space.get_blend_point_count():
		var pos = blend_space.get_blend_point_position(i)
		var node = blend_space.get_blend_point_node(i)
		if node is AnimationNodeAnimation:
			if pos == Vector2(0, 0):
				node.animation = nouvelle_arme.animation_idle_arme
				print("c'est moi")
			elif pos == Vector2(0, 1):
				print("devant")
				node.animation = nouvelle_arme.focus_devant
			elif pos == Vector2(0, -1):
				print("focus_derriere")
				node.animation = nouvelle_arme.focus_derriere
			elif pos == Vector2(-1, 0):
				node.animation = nouvelle_arme.focus_gauche
			elif pos == Vector2(1, 0):
				node.animation = nouvelle_arme.focus_droite
#---------------------------------------------------------------------------------------------------------------------------------

#---------------------------------------------- GESTION DE ENTREE --------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("degainer") :
		if etat_actuel == Etat.normal:
			degainer_arme()
		elif etat_actuel == Etat.idle_combat and not (verrouillage_actif and cible_verrouillee) :
			ranger_arme()
	if event.is_action_pressed("Attaque") :
		if  etat_actuel == Etat.idle_combat and not (arme is Baton) :
			if en_blocage:
				arreter_blocage()
			player.attaque = true
			changement_d_etat(Etat.Attaque)
		elif etat_actuel == Etat.Attaque :
			input_attaque_en_attente = true
	if event.is_action_pressed("cibler"):
		basculer_verrouillage()
	if event.is_action_pressed("esquive") and etat_actuel == Etat.idle_combat:
		esquiver()
	if event.is_action_pressed("focus_suivant") and verrouillage_actif:
		changer_cible(1)
	if event.is_action_pressed("focus_precedent") and verrouillage_actif:
		changer_cible(-1)
	if event.is_action_pressed("lancer_sort"):
		tenter_lancer_sort()
		print("je clique")
	if event.is_action_released("lancer_sort") and indicateur_zone :
		valider_sort_zone()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			SortManager.changer_sort_actif(1)
			if SortManager.sort_actif:
				print("Sort actif : ", SortManager.sort_actif.nom_sort)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			SortManager.changer_sort_actif(-1)
	if event.is_action_pressed("bloquer") :
		demarrer_blocage()
	if event.is_action_released("bloquer"):
		arreter_blocage()

func demarrer_blocage() -> void:
	if IventaireManager.bouclier_equipe_actuel == null:
		return
	if etat_actuel == Etat.Attaque or en_transition:
		return
	en_blocage = true
	temps_debut_blocage = Time.get_ticks_msec() / 1000.0
	animation.play(IventaireManager.bouclier_equipe_actuel.animation_bloquer)
	sprint_autoriser = false
	player.peut_bouger = false

func arreter_blocage() -> void:
	en_blocage = false
	sprint_autoriser = true
	player.peut_bouger = true

func tenter_lancer_sort() -> void:
	if en_transition : 
		return
	if arme == null or not (arme is Baton):
		return
	var sort = SortManager.sort_actif
	if sort == null:
		return
	if mana_player.mana_actuelle < sort.cout_mana:
		print("Pas assez de mana")
		return
	en_transition = true
	player.peut_bouger = false

	match sort.type_sort:
		Grimoire.TypeSort.PROJECTILE:
			lancer_projectile(sort)
		Grimoire.TypeSort.ZONE:
			demarrer_visee_zone(sort)

func lancer_projectile(sort: Grimoire) -> void:
	mana_player.consommer(sort.cout_mana)
	animation.play(sort.animation_incantation)
	await get_tree().create_timer(1.4).timeout
	var projectile = sort.scene_effet.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = player.point_spawm_sort.global_position

	var direction_tir : Vector3
	if verrouillage_actif and cible_verrouillee:
		direction_tir = (cible_verrouillee.global_position - projectile.global_position).normalized()
	else:
		direction_tir = -player.mesh.global_transform.basis.z

	projectile.lancer(direction_tir, sort.vitesse_projectile, sort.degats_sort)
	await  animation.animation_finished
	
	en_transition =false
	player.peut_bouger = true


func demarrer_visee_zone(sort: Grimoire) -> void:
	sort_zone_en_attente = sort
	indicateur_zone = sort.scene_indicateur.instantiate()
	get_tree().current_scene.add_child(indicateur_zone)
	if indicateur_zone.has_method("definir_rayon"):
		indicateur_zone.definir_rayon(sort.rayon_zone)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# position initial de la zone
	var devant_joueur = player.global_position - player.mesh.global_transform.basis.z * 3.0
	indicateur_zone.global_position = devant_joueur


func _process(_delta: float) -> void:
	if indicateur_zone:
		var pos_sol = obtenir_position_souris_sur_sol()
		if pos_sol:
			indicateur_zone.global_position = pos_sol

func obtenir_position_souris_sur_sol() -> Vector3:
	var pos_ecran = get_viewport().get_mouse_position()
	var origine = camera.project_ray_origin(pos_ecran)
	var direction = camera.project_ray_normal(pos_ecran)
	var espace = get_viewport().world_3d.direct_space_state
	var params = PhysicsRayQueryParameters3D.create(origine, origine + direction * 1000)
	params.exclude = [player.get_rid()]
	var resultat = espace.intersect_ray(params)
	return resultat.position if resultat else player.global_position

func valider_sort_zone() -> void:
	var sort = sort_zone_en_attente
	var pos_finale = indicateur_zone.global_position
	indicateur_zone.queue_free()
	indicateur_zone = null
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	mana_player.consommer(sort.cout_mana)
	player.mesh.look_at(Vector3(pos_finale.x, player.position.y, pos_finale.z))

	animation.play(sort.animation_incantation)
	await animation.animation_finished

	var effet = sort.scene_indicateur.instantiate()
	get_tree().current_scene.add_child(effet)
	effet.global_position = pos_finale
	effet.declencher(sort.degats_sort, sort.rayon_zone)

	en_transition = false
	player.peut_bouger = true
	sort_zone_en_attente = null

func esquiver() -> void:
	if arme == null or en_transition:
		return
	en_transition = true
	player.peut_bouger = false
	animation_tree.active = false

	var direction_esquive = player.direction if player.direction else -player.mesh.global_transform.basis.z
	player.mesh.look_at(player.position + direction_esquive)

	var vitesse_lecture = 2.0
	animation.play(arme.esquive_avant, -1, vitesse_lecture)
	var duree_reelle = animation.get_animation(arme.esquive_avant).length / vitesse_lecture

	player.lancer_esquive(direction_esquive, arme.distance_esquive, duree_reelle)

	player.sante.invincible = true
	await get_tree().create_timer(duree_reelle).timeout
	player.sante.invincible = false

	player.velocity.x = 0
	player.velocity.z = 0
	en_transition = false
	player.peut_bouger = true
	changement_d_etat(Etat.idle_combat)
#---------------------------------- J AI PAS ENCORE D ANIMATION POUR LES 4 DIRECTION --------------------------- 
#func esquiver() -> void:
	#if arme == null or en_transition:
		#return
	#en_transition = true
	#player.peut_bouger = false
	#animation_tree.active = false

	#var nom_anim : String
	#if player.direction:
		#var dir_relative = calculer_direction_relative(player.direction, player.mesh.global_transform)
		# Détermine quel axe domine : avant/arrière ou gauche/droite
		#if abs(dir_relative.y) >= abs(dir_relative.x):
			#nom_anim = arme.esquive_avant if dir_relative.y > 0 else arme.esquive_arriere
		#else:
			#nom_anim = arme.esquive_droite if dir_relative.x > 0 else arme.esquive_gauche
	#else:
		#nom_anim = arme.esquive_arriere  # esquive par défaut si aucune direction (repli arrière)

	#animation.play(nom_anim, -1, 1.0)
	#player.lancer_dash_attaque(arme.distance_esquive, arme.duree_esquive)
	#await animation.animation_finished

	#en_transition = false
	#player.peut_bouger = true
	#changement_d_etat(Etat.idle_combat)
#-------------------------------------------------------------------------------------------------------
#------------------------ pour le focus de la camera un zoom leger --------------------------------
@export var fov_normal : float = 80.0
@export var fov_focus : float = 65.0
#-------------------------------------------------------------------------------------------------
func basculer_verrouillage() -> void:
	if verrouillage_actif:
		verrouillage_actif = false
		cible_verrouillee = null
		var tween = create_tween()
		tween.tween_property(camera,"fov",fov_normal,0.2)
	else:
		cible_verrouillee = trouver_ennemi_plus_proche()
		if cible_verrouillee:
			verrouillage_actif = true
			if etat_actuel == Etat.normal :
				degainer_arme()
		#petit effet de zoom
			var tween = create_tween()
			tween.tween_property(camera, "fov", fov_focus, 0.2)

func trouver_ennemi_plus_proche() -> Node3D:
	var plus_proche : Node3D = null
	var distance_min : float = INF
	for ennemi in ennemis_a_portee:
		if not is_instance_valid(ennemi):
			continue
		var d = player.global_position.distance_to(ennemi.global_position)
		if d < distance_min:
			distance_min = d
			plus_proche = ennemi
	return plus_proche

func degainer_arme() -> void:
	# Si aucune arme équipée, on tente d'en équiper une depuis l'inventaire
	if arme == null:
		var arme_dispo = IventaireManager.obtenir_premiere_arme()
		if arme_dispo:
			IventaireManager.equiper_arme(arme_dispo)
			print("arme equiper")
			# arme est mis à jour immédiatement via le signal (synchrone)
	if arme == null:
		return  # toujours rien à équiper, on annule le dégainage
	player.peut_bouger = false 
	en_transition = true
	etat_actuel = Etat.idle_combat
	animation.play(arme.animation_sortir_arme)
	await animation.animation_finished
	arme_sorti.emit()
	en_transition = false
	player.peut_bouger = true

func ranger_arme() -> void:
	player.peut_bouger = false
	en_transition = true
	etat_actuel = Etat.Attaque  # verrou temporaire le temps de l'anim
	animation_tree.active = false
	arme_ranger.emit()
	animation.play(arme.animation_ranger_arme)
	await animation.animation_finished
	IventaireManager.desequiper_arme()
	en_transition = false
	changement_d_etat(Etat.normal)
	player.peut_bouger = true

func changement_d_etat(nouvelle_etat):
	etat_actuel = nouvelle_etat
	match etat_actuel:
		Etat.normal:
			mode_exploration()
		Etat.idle_combat:
			index_combo = 0
			animation.play(arme.animation_idle_arme)
		Etat.Attaque:
			if arme == null:
				return

			player.peut_bouger = false
			input_attaque_en_attente = false
			animation_tree.active = false
			if arme.animation_combo_arme.is_empty():
				# Pas de combo défini : attaque simple unique
				animation.play(arme.animation_attaque_arme, -1, arme.vitesse_attaque)
				player.lancer_dash_attaque(1.5, 0.25)
				
				# activation / desactivation de la hitbox de l'arme
				if hitbox_arme :
					await get_tree().create_timer(0.15).timeout
					hitbox_arme.activer(arme.dommage_arme)
					await get_tree().create_timer(0.2).timeout
					hitbox_arme.desactiver()
				await animation.animation_finished
				player.peut_bouger = true
				player.attaque = false
				index_combo = 0
				changement_d_etat(Etat.idle_combat)
			else:
				# Combo défini : on enchaîne selon index_combo
				var nom_anim = arme.animation_combo_arme[index_combo]
				animation.play(nom_anim, -1, arme.vitesse_attaque)
				player.lancer_dash_attaque(1.5, 0.25)
				if hitbox_arme :
					await get_tree().create_timer(0.15).timeout
					hitbox_arme.activer(arme.dommage_arme)
					await get_tree().create_timer(0.2).timeout
					hitbox_arme.desactiver()
				await animation.animation_finished

				if input_attaque_en_attente and index_combo < arme.animation_combo_arme.size() - 1:
					index_combo += 1
					changement_d_etat(Etat.Attaque)
				else:
					player.peut_bouger = true
					player.attaque = false
					index_combo = 0
					changement_d_etat(Etat.idle_combat)

func _on_detection_enemis_body_entered(body: Node3D) -> void:
	if body.is_in_group("ennemis"):
		nombre_ennemis += 1
		ennemis_a_portee.append(body)
		# Ne dégaine plus automatiquement — juste dispo pour alerte/musique plus tard

func _on_detection_enemis_body_exited(body: Node3D) -> void:
	if body.is_in_group("ennemis"):
		nombre_ennemis -= 1
		nombre_ennemis = max(0, nombre_ennemis)
		ennemis_a_portee.erase(body)
		if body == cible_verrouillee:
			# La cible verrouillée est sortie donc desactivation
			cible_verrouillee = null
			verrouillage_actif = false
			var tween = create_tween()
			tween.tween_property(camera,"fov",fov_normal,0.2)

#-----------------------------------------CHANGER CIBLE ENNEMIS----------------------------------
func changer_cible(direction: int) -> void:
	# direction : 1 = suivant (droite), -1 = précédent (gauche)
	if not verrouillage_actif or ennemis_a_portee.size() <= 1:
		return

	var candidats = ennemis_a_portee.filter(func(e): return is_instance_valid(e) and e != cible_verrouillee)
	if candidats.is_empty():
		return

	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

	candidats.sort_custom(func(a, b):
		var angle_a = right.dot((a.global_position - camera.global_position).normalized())
		var angle_b = right.dot((b.global_position - camera.global_position).normalized())
		if direction > 0:
			return angle_a > angle_b
		else:
			return angle_a < angle_b
	)

	cible_verrouillee = candidats[0]


func lancer_sort_actif() -> void:
	var sort = SortManager.sort_actif
	if sort == null or mana_player == null:
		return
	if not mana_player.consommer(sort.cout_mana):
		print("Pas assez de mana")
		return
	animation.play(sort.animation_incantation)
	# instancier scene_effet en fonction du type_sort (projectile lancé devant, ou zone à la position ciblée)
