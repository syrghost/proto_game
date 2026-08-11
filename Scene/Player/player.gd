extends CharacterBody3D
@onready var animation: AnimationPlayer = $mesh/player_animation/AnimationPlayer
@onready var mesh: Node3D = $mesh
@onready var camera: Node3D = $logique_cam
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_3d: Camera3D = $logique_cam/Camera3D
@onready var sante: Sante = $Sante
@onready var mana: Mana = $Mana
@onready var point_spawm_sort: Marker3D = $mesh/player_animation/Armature/Skeleton3D/PointAttachementArme/Point_spawm_sort

var vitesse : float = 3.0
var force_de_saut : float = 4.5
var vitesse_marche : float = 3.0
var vitesse_course : float = 6.5

var vitesse_marche_base : float = 3.0
var vitesse_course_base : float = 6.5


var courir = false
var peut_bouger = true
var direction : Vector3
var attaque = false

# --- Dash d'attaque ---
var dash_en_cours : bool = false
var dash_direction : Vector3
var dash_vitesse : float = 0.0

func _ready() -> void:
	EtatAnimationJoueur.player = self
	EtatAnimationJoueur.animation = animation
	EtatAnimationJoueur.animation_tree = animation_tree
	EtatAnimationJoueur.camera = camera_3d
	EtatAnimationJoueur.sante_player = sante
	EtatAnimationJoueur.mana_player = mana
	IventaireManager.connecter_sante()
	IventaireManager.armure_equipee.connect(_recalculer_vitesse)
	IventaireManager.armure_desequipee.connect(_recalculer_vitesse)
	IventaireManager.bottes_equipees.connect(_recalculer_vitesse)
	IventaireManager.bottes_desequipees.connect(_recalculer_vitesse)
	_recalculer_vitesse()
	print(animation_tree.get_tree_root())
	
	#------------------------------- Teste -----------------------------
	var resu = load("res://Objets/consommable/Resu/petite_resu.tres")
	IventaireManager.ajouter_objet(resu , 2)
	await get_tree().create_timer(1.0).timeout
	sante.subir_degats(9999)  # force les PV à 0 pour déclencher pv_a_zero
	var potion = load("res://Objets/consommable/potion_soin/petite_potion_soin.tres")
	IventaireManager.ajouter_objet(potion,3)
	if potion != null:
		print("potion bien ajouter")
	print("type_objet de la potion : ", potion.type_objet)
	var potion_soin = load("res://Objets/consommable/potion_soin/potion_soin.tres")
	IventaireManager.ajouter_objet(potion_soin,10)
	var potion_mana = load("res://Objets/consommable/potion_mana/petite_potion_mana.tres")
	IventaireManager.ajouter_objet(potion_mana,4)
	var armure_test = load("res://Objets/Armure/ressource/test.tres")
	var bottes_test = load("res://Objets/Bottes/ressourse/bottes_test.tres")
	IventaireManager.ajouter_objet(armure_test)
	IventaireManager.ajouter_objet(bottes_test)
	var epee = load("res://Objets/Arme/ressource_arme/Epee/epee.tres")
	IventaireManager.ajouter_objet(epee)
	var baton = load("res://Objets/Arme/ressource_arme/baton/baton.tres")
	IventaireManager.ajouter_objet(baton)
	var grimoire = load("res://Objets/grimoire/ressource/sort_feu.tres")
	IventaireManager.ajouter_objet(grimoire)
	SortManager.apprendre_sort(grimoire)
	var foudre = load("res://Objets/grimoire/ressource/foudre.tres")
	SortManager.apprendre_sort(foudre)
	IventaireManager.ajouter_objet(foudre)
	var bouclier_test = load("res://Objets/Bouclier/ressource/bouclier_test.tres")
	IventaireManager.ajouter_objet(bouclier_test)
	#--	------------------------------------------------------------------------


func lancer_dash_attaque(distance: float, duree: float) -> void:
	dash_direction = -mesh.global_transform.basis.z
	dash_vitesse = distance / duree
	dash_en_cours = true
	await get_tree().create_timer(duree).timeout
	dash_en_cours = false
func lancer_esquive(direction_souhaitee: Vector3, distance: float, duree: float) -> void:
	dash_direction = direction_souhaitee.normalized() if direction_souhaitee != Vector3.ZERO else -mesh.global_transform.basis.z
	dash_vitesse = distance / duree
	dash_en_cours = true
	await get_tree().create_timer(duree).timeout
	dash_en_cours = false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("courir") and EtatAnimationJoueur.sprint_autoriser:
		vitesse = vitesse_course
		courir = true
	else:
		vitesse = vitesse_marche
		courir = false

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = force_de_saut

	if dash_en_cours:
		if direction:
			velocity.x = dash_direction.x * dash_vitesse
			velocity.z = dash_direction.z * dash_vitesse
	elif peut_bouger:
		var input_dir := Input.get_vector("gauche", "droite", "devant", "derriere")

		if input_dir.length() > 0.3:  # seuil : ignore les impulsions trop faibles
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
		else:
			direction = Vector3.ZERO

		if EtatAnimationJoueur.verrouillage_actif and EtatAnimationJoueur.cible_verrouillee:
			var pos_cible = EtatAnimationJoueur.cible_verrouillee.global_position
			mesh.look_at(Vector3(pos_cible.x, position.y, pos_cible.z))
		elif direction:
			mesh.look_at(position + direction)

		if direction:
			velocity.x = direction.x * vitesse
			velocity.z = direction.z * vitesse
		else:
			velocity.x = move_toward(velocity.x, 0, vitesse)
			velocity.z = move_toward(velocity.z, 0, vitesse)
	else:
		velocity.x = move_toward(velocity.x, 0, vitesse)
		velocity.z = move_toward(velocity.z, 0, vitesse)

	move_and_slide()


func _recalculer_vitesse(_arg = null) -> void:
	vitesse_marche = vitesse_marche_base + IventaireManager.obtenir_bonus_vitesse()
	vitesse_course = vitesse_course_base + IventaireManager.obtenir_bonus_vitesse()
