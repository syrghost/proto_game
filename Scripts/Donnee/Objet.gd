extends Resource
class_name Objet

enum TypeObjet {
	ARME,
	ARMURE,
	BOTTES,
	GRIMOIRE,
	CONSOMMABLE,
	Resu,
	CLE,
	Bouclier
}
enum Element {
	FEU,
	FOUDRE,
	VENT,
	TERRE
}

@export_category("Indispensable")
@export var id : String
@export var nom : String
@export_multiline var description : String
@export var icone : Texture2D
@export var type_objet : TypeObjet

@export_category("Inventaire")
@export var empilable : bool = true
@export var quantite_max : int = 99
