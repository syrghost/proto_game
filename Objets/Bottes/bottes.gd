extends Objet
class_name Bottes

@export_category("Statistiques")
@export var vitesse_bonus : float = 0.0
@export var defense : int = 0
@export var scene_modele : PackedScene

func _init():
	type_objet = TypeObjet.BOTTES
	empilable = false
	quantite_max = 1
