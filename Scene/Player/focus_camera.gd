extends Camera3D

@export var Spring_arm : Node3D
@export var lerp_vitesse : float  = 1.0

func _process(delta: float) -> void:
	position = lerp(position, Spring_arm.position, delta * lerp_vitesse)
