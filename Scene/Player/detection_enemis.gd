extends Area3D


func _ready() -> void:
	body_entered.connect(EtatAnimationJoueur._on_detection_enemis_body_entered)
	body_exited.connect(EtatAnimationJoueur._on_detection_enemis_body_exited)
