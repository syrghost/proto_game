extends Objet
class_name Bouclier

@export_category("Statistiques")
@export var reduction_degats : float = 0.5  # 0.5 = bloque 50% des dégâts en blocage normal
@export var scene_modele : PackedScene

@export_category("Parade")
@export var fenetre_parade : float = 0.2  # secondes après le début du blocage où la parade parfaite est possible
@export var etourdissement_ennemi : float = 1.5  # durée d'étourdissement infligée en cas de parade réussie

@export_category("Animation")
@export var animation_bloquer : String
@export var animation_parade : String
@export var animation_dmg_blocage : String

func _init():
	type_objet = TypeObjet.Bouclier  
	empilable = false
	quantite_max = 1
