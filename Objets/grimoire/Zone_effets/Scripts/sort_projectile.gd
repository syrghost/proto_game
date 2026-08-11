extends Area3D
class_name SortProjectile

var vitesse : float = 10.0
var degats : int = 0
var direction : Vector3 = Vector3.ZERO
var duree_vie : float = 5.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func lancer(dir: Vector3, vit: float, deg: int) -> void:
	direction = dir
	vitesse = vit
	degats = deg
	look_at(global_position + direction, Vector3.UP)
	await get_tree().create_timer(duree_vie).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * vitesse * delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ennemis"):
		var sante_node = body.get_node_or_null("Sante")
		if sante_node:
			sante_node.subir_degats(degats)
		queue_free()
