extends Objet
class_name Arme

@export_category("Statistiques")
@export var effet : EffetCombat
@export var scene_modele : PackedScene  # modèle 3D unique : main, sol, ennemi
@export var dommage_arme : int

@export_category("Animation combat")
@export var animation_ranger_arme : String
@export var animation_sortir_arme : String
@export var animation_idle_arme : String
@export var animation_attaque_arme : String
@export var animation_combo_arme : Array[String]
@export var animation_marche_combat_arme : String

@export_category("Animation esquive")
@export var esquive_avant : String
@export var esquive_arriere : String
@export var esquive_gauche : String
@export var esquive_droite : String
@export var distance_esquive : float = 2.0
@export var duree_esquive : float = 0.3

@export_category("Animation focus (blend tree)")
@export var focus_devant : String
@export var focus_derriere : String
@export var focus_gauche : String
@export var focus_droite : String

@export_category("Player")
@export var vitesse_player_avec_arme : float
@export var vitesse_attaque : float = 1.0

func _init():
	type_objet = TypeObjet.ARME
	empilable = false
	quantite_max = 1
