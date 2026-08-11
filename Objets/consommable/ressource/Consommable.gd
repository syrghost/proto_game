extends Objet
class_name Consommable

enum TypeEffet {
	SOIN,
	MANA
}

@export_category("Effet")
@export var type_effet : TypeEffet
@export var valeur : float   # PV rendus (soin) ou mana rendue

func _init():
	type_objet = TypeObjet.CONSOMMABLE
	empilable = true
