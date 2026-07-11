extends Resource
class_name Donnee_PNJ

enum dialogue_possible{
	simple,
	quete,
	objectif_suite
}

@export_category("indispensable")
@export var id : int
@export var dialogue : Array[String] = [] 
@export var nom_pnj : String

@export_category("type_dialogue")
@export var type_dialogue : dialogue_possible
