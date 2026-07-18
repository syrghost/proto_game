extends CharacterBody3D
@onready var animation: AnimationPlayer = $mesh/player_animation/AnimationPlayer
@onready var mesh: Node3D = $mesh
@onready var camera: Node3D = $logique_cam
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_3d: Camera3D = $logique_cam/Camera3D

var vitesse : float = 3.0
var force_de_saut : float = 4.5
var vitesse_marche : float = 3.0
var vitesse_course : float = 6.5
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
	print(animation_tree.get_tree_root())

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
