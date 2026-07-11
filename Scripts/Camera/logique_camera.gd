extends Node3D



@export var sensibiliter_sourir : float = 0.005
func  _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED :
		if event is InputEventMouseMotion :
			# tau est egale a 360°
			rotation.y -= event.relative.x * sensibiliter_sourir
			rotation.y = wrapf(rotation.y , 0.0 , TAU)
			
			
			rotation.x -= event.relative.y * sensibiliter_sourir
			rotation.x = clamp(rotation.x , -PI/4 , PI/4)
