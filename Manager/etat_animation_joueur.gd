extends Node
var arme:Arme
signal arme_ranger
signal arme_sorti
#-------------------------------POUR DETECTION ENNEMI------------------------
var ennemis_a_portee : Array[Node3D] = []
var cible_verrouillee : Node3D = null
var verrouillage_actif : bool = false

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
	if en_transition :
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
	if en_transition:
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
		if  etat_actuel == Etat.idle_combat:
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

	await get_tree().create_timer(duree_reelle).timeout

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
				animation.play(arme.animation_attaqe_arme, -1, arme.vitesse_attaque)
				player.lancer_dash_attaque(1.5, 0.25)
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
