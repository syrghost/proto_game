extends Node

@onready var joueur: Node3D = $"../mesh"
func _ready() -> void:
	IventaireManager.objet_jete.connect(_on_objet_jete)
	print("Objet_jeter prêt, connecté au signal")

func _on_objet_jete(objet: Objet) -> void:
	print("Signal objet_jete reçu : ", objet)
	if objet.chemin_scene_monde == "":
		print("ECHEC : chemin_scene_monde vide")
		return

	var scene : PackedScene = load(objet.chemin_scene_monde)
	print("Scene chargée : ", scene)
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)

# instancie l'objet et prend la position devant le joueur
	var direction_devant := joueur.global_transform.basis.z
	var direction_haut := joueur.global_transform.basis.y
	var direction_x := joueur.global_transform.basis.x
	instance.global_position = joueur.global_position + ( direction_haut * 1 - direction_devant * 0.5 -direction_x * 0.2)
	instance.global_rotation = Vector3(0.0,0.0,PI/4) 
	print("Instance placée à : ", instance.global_position)
