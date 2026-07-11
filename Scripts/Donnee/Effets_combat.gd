extends Resource
class_name EffetCombat

enum TypeApplication {
	IMMEDIAT_MELEE,   # hitbox proche activée un court instant
	PROJECTILE,       # instancie un projectile qui vole
	ZONE_AU_SOL       # zone d'effet à une position (autour du joueur ou à l'impact)
}

@export var type_application : TypeApplication
@export var degats : int = 10

# Pour mélée
@export var portee : float = 1.5
@export var largeur : float = 1.0

# Pour projectile
@export var scene_projectile : PackedScene
@export var vitesse_projectile : float = 20.0

# Pour zone (utilisé seul, OU après impact d'un projectile)
@export var rayon_zone : float = 2.0
@export var duree_zone : float = 1.0
@export var scene_effet_visuel_zone : PackedScene

# Un projectile qui explose en zone à l'impact (boule de feu)
@export var declenche_zone_a_impact : bool = false
