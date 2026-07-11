extends CanvasLayer
@onready var panel: Panel = $panel
@onready var Nom_pnj: Label = $panel/Nom_pnj
@onready var dialogue_pnj: Label = $"panel/dialogue pnj"



func _ready() -> void:
	visible = false
	DialogueManager.dialogue_demarre.connect(_on_dialogue_demarre)
	DialogueManager.ligne_affichee.connect(_on_ligne_affichee)
	DialogueManager.dialogue_termine.connect(_on_dialogue_termine)

func _on_dialogue_demarre(nom_pnj: String) -> void:
	visible = true
	Nom_pnj.text = nom_pnj

func _on_ligne_affichee(texte: String) -> void:
	dialogue_pnj.text = texte

func _on_dialogue_termine() -> void:
	visible = false
