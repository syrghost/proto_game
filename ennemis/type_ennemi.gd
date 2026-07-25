extends Resource
class_name TypeEnnemi

@export_category("Statistiques")
@export var vie_max : int = 50
@export var vitesse_deplacement : float = 3.0
@export var portee_attaque : float = 2.0
@export var portee_detection : float = 8.0
@export var cooldown_attaque : float = 1.5
@export var degat_attaque_main : int  = 15

@export_category("Animations")
@export var animation_idle : String
@export var animation_marche : String
@export var animation_attaque : String  # utilisée seulement si pas d'arme équipée
@export var animation_mort : String

@export_category("Équipement")
@export var arme_equipee : Arme  # optionnelle : si null, l'ennemi attaque "à mains nues"
