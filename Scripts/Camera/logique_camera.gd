extends Node3D
@export var sensibiliter_sourir : float = 0.005
@export var vitesse_rotation_focus : float = 5.0
@export var sensibiliter_sourir_focus : float = 0.002  # réduite pendant le focus

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			if EtatAnimationJoueur.verrouillage_actif:
				# Contrôle manuel réduit, en plus de la correction automatique
				rotation.y -= event.relative.x * sensibiliter_sourir_focus
			else:
				rotation.y -= event.relative.x * sensibiliter_sourir
				rotation.y = wrapf(rotation.y, 0.0, TAU)

			rotation.x -= event.relative.y * sensibiliter_sourir
			rotation.x = clamp(rotation.x, -PI/4, PI/4)
func _process(delta: float) -> void:
	if EtatAnimationJoueur.verrouillage_actif and EtatAnimationJoueur.cible_verrouillee:
		var cible = EtatAnimationJoueur.cible_verrouillee
		if is_instance_valid(cible):
			var direction_vers_cible = (cible.global_position - global_position)
			direction_vers_cible.y = 0
			if direction_vers_cible.length() > 0.01:
				var angle_cible = atan2(-direction_vers_cible.x, -direction_vers_cible.z)
				var facteur = 1.0 - exp(-vitesse_rotation_focus * delta)  # lissage exponentiel, indépendant du framerate
				rotation.y = lerp_angle(rotation.y, angle_cible, facteur)
