extends Objet
class_name Resu

@export_category("Effet")
@export var pourcentage_pv : float = 3.0  # % des PV max rendus à la résurrection

func _init():
	type_objet = TypeObjet.Resu
	empilable = true
