extends Area3D
signal joueur_detecte(joueur: Node3D)
signal joueur_perdu(joueur: Node3D)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("joueur"):
		print("detecter")
		joueur_detecte.emit(body)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("joueur"):
		joueur_perdu.emit(body)
