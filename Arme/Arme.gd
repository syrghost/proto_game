extends Objet
class_name Arme


@export_category("Statistiques")
@export var effet = EffetCombat
@export var vitesse_attaque : float = 1.0
@export var scene_modele : PackedScene  # le modèle 3D de l'arme à afficher en main
@export var chemin_scene_monde  : String # celui poser au sol 
