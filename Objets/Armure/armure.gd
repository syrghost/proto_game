extends Objet
class_name Armure

@export_category("Statistiques")
@export var defense : int = 0
@export var vitesse_bonus : float = 0.0  # certaines armures peuvent ralentir/accélérer
@export var scene_modele : PackedScene  # à équiper visuellement sur le mesh du joueur

func _init():
	type_objet = TypeObjet.ARMURE
	empilable = false
	quantite_max = 1
