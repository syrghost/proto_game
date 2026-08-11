extends Area3D
class_name SortZone
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func declencher(degats: int, rayon: float) -> void:
	# Ajuste le rayon de la CollisionShape3D (suppose une SphereShape3D ou CylinderShape3D)
	
	if collision_shape.shape is SphereShape3D:
		collision_shape.shape.radius = rayon
	elif collision_shape.shape is CylinderShape3D:
		collision_shape.shape.radius = rayon

	await get_tree().physics_frame  # laisse le temps à la shape de se mettre à jour
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		print("body trouvé : ", body.name, " groupes: ", body.get_groups())
		if body.is_in_group("ennemis"):
			var sante_node = body.get_node_or_null("Sante")
			if sante_node:
				sante_node.subir_degats(degats)

	# Optionnel : garder l'effet visuel affiché un court instant avant de disparaître
	await get_tree().create_timer(1.0).timeout
	queue_free()
