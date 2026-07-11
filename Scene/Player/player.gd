extends CharacterBody3D

@onready var animation: AnimationPlayer = $mesh/player_animation/AnimationPlayer
@onready var mesh: Node3D = $mesh

@onready var camera: Node3D = $logique_cam



var vitesse : float = 3.0
var force_de_saut : float = 4.5
var vitesse_marche : float = 3.0
var vitesse_course : float = 6.5
var courir = false 


func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("courir"):
		vitesse = vitesse_course
		courir = true
	else:

		vitesse = vitesse_marche
		courir = false

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = force_de_saut


	var input_dir := Input.get_vector("gauche", "droite", "devant","derriere")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP,camera.global_rotation.y)
	animation_player(direction)
	move_and_slide()
	
	
func animation_player(_direction : Vector3):
	_direction = _direction.normalized()
	if _direction:
		if courir :
			if animation.current_animation != "courir" :
				animation.play("courir")
		else :
			# Securiter
			if animation.current_animation != "marche":
				animation.play("marche")

		velocity.x = _direction.x * vitesse
		velocity.z = _direction.z * vitesse
		
		mesh.look_at(position + _direction)
	else:
		if animation.current_animation != "idle":
			animation.play("idle")
		velocity.x = move_toward(velocity.x, 0, vitesse)
		velocity.z = move_toward(velocity.z, 0, vitesse)
