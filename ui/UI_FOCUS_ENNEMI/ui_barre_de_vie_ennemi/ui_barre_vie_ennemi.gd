extends Control
@onready var barre: ProgressBar = $vie_ennemi


var cible : Node3D
var camera : Camera3D
var offset_hauteur : float = 2.0 #hauteur_barre

func configurer(ennemi: Node3D, sante_ennemi: Node) -> void:
	cible = ennemi
	barre.max_value = sante_ennemi.vie_max
	barre.value = sante_ennemi.vie_actuelle
	sante_ennemi.degats_recus.connect(_on_vie_changee)
	sante_ennemi.mort.connect(_on_mort)

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	visible = false

func _process(_delta: float) -> void:
	if not is_instance_valid(cible) or not is_instance_valid(camera):
		queue_free()
		return

	var pos_monde = cible.global_position + Vector3(0, offset_hauteur, 0)
	var direction_cam = -camera.global_transform.basis.z
	var vers_cible = (pos_monde - camera.global_position).normalized()

	if direction_cam.dot(vers_cible) > 0:
		var pos_ecran = camera.unproject_position(pos_monde)
		position = pos_ecran - size / 2
	else:
		visible = false

func _on_vie_changee(_quantite: int, vie_restante: int) -> void:
	visible = true
	barre.value = vie_restante

func _on_mort() -> void:
	queue_free()
