extends Objet
class_name Arme


@export_category("Statistiques")
@export var effet = EffetCombat
@export var scene_modele : PackedScene  # le modèle 3D de l'arme à afficher en main
@export var chemin_scene_monde  : String # celui poser au sol 
@export var dommage_arme : int


@export_category("animation combat")
@export var animation_ranger_arme : String
@export var animation_sortir_arme : String
@export var animation_idle_arme : String
@export var animation_attaqe_arme : String
@export var animation_combo_arme :Array[String]
@export var animation_marche_combat_arme : String
@export_category("animation_esquive")
@export var esquive_avant : String
@export var esquive_arriere : String
@export var esquive_gauche : String
@export var esquive_droite : String
@export var distance_esquive : float = 2.0
@export var duree_esquive : float = 0.3
@export_category("animation focus_blend tree")
@export var focus_devant : String
@export var focus_derriere : String
@export var focus_gauche : String
@export var focus_droite : String


@export_category("player")
@export var vitesse_player_avec_arme : float
@export var vitesse_attaque : float = 1.0
