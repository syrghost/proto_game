extends Area3D

var objets_a_portee : Array[Node] = []

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("parler") and objets_a_portee.size() > 0:
		objets_a_portee[0].ramasser()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ramassable"):
		objets_a_portee.append(body)
		print("ajouter")

func _on_body_exited(body: Node3D) -> void:
	if body in objets_a_portee:
		objets_a_portee.erase(body)
