extends Control
@onready var point: Label = $point
var camera : Camera3D

func _ready() -> void:
	point.visible = false
	camera = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	if not is_instance_valid(camera):
		camera = get_viewport().get_camera_3d()
		return
	if not (EtatAnimationJoueur.verrouillage_actif and EtatAnimationJoueur.cible_verrouillee):
		point.visible = false
		return
	var cible = EtatAnimationJoueur.cible_verrouillee
	if not is_instance_valid(cible):
		point.visible = false
		return
	var pos_monde = cible.global_position + Vector3(0, 0.5, 0)
	var direction_cam = -camera.global_transform.basis.z
	var vers_cible = (pos_monde - camera.global_position).normalized()
	if direction_cam.dot(vers_cible) > 0:
		point.visible = true
		var pos_ecran = camera.unproject_position(pos_monde)
		point.position = pos_ecran - point.size / 2
	else:
		point.visible = false
