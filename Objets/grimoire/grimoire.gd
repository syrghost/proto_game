extends Objet
class_name Grimoire

enum TypeSort {
	PROJECTILE,
	ZONE
}

@export_category("Sort")
@export var element : Element
@export var type_sort : TypeSort
@export var nom_sort : String
@export var cout_mana : int = 10
@export var degats_sort : int = 0
@export var rayon_zone : float = 3.0        # utilisé si ZONE
@export var vitesse_projectile : float = 10.0  # utilisé si PROJECTILE
@export var scene_effet : PackedScene       # projectile ou VFX de zone
@export var animation_incantation : String
@export var scene_indicateur : PackedScene # node 3d

func _init():
	type_objet = TypeObjet.GRIMOIRE
	empilable = false
	quantite_max = 1
