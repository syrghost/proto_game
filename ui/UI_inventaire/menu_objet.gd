extends PopupPanel


@onready var bouton_equiper: Button = $VBoxContainer/Equiper
@onready var bouton_desequiper: Button = $VBoxContainer/Désequiper
@onready var bouton_jeter: Button = $VBoxContainer/jetter


var objet_cible : Objet
var quantite_cible : int

func ouvrir_pour(objet: Objet, quantite: int, position_ecran: Vector2) -> void:
	objet_cible = objet
	quantite_cible = quantite

	# Affiche/cache les boutons selon le contexte
	var est_equipee = objet is Arme and IventaireManager.arme_equipee_actuelle == objet
	bouton_equiper.visible = objet is Arme and not est_equipee
	bouton_desequiper.visible = est_equipee
	bouton_jeter.visible = true

	position = position_ecran
	popup()

func _on_bouton_equiper_pressed() -> void:
	IventaireManager.equiper_arme(objet_cible)
	hide()

func _on_bouton_desequiper_pressed() -> void:
	IventaireManager.desequiper_arme()
	hide()

func _on_bouton_jeter_pressed() -> void:
	IventaireManager.jeter_objet(objet_cible, 1)
	hide()
