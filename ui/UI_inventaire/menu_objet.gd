extends PopupPanel

@onready var bouton_equiper: Button = $VBoxContainer/Equiper
@onready var bouton_desequiper: Button = $VBoxContainer/Désequiper
@onready var bouton_jeter: Button = $VBoxContainer/jetter

var objet_cible : Objet
var quantite_cible : int

func ouvrir_pour(objet: Objet, quantite: int, position_ecran: Vector2) -> void:
	objet_cible = objet
	quantite_cible = quantite

	if objet is Resu:
		bouton_equiper.visible = false
		bouton_desequiper.visible = false
		bouton_jeter.visible = false
		return

	if objet is Consommable:
		bouton_equiper.text = "Utiliser"
		bouton_equiper.visible = true
		bouton_desequiper.visible = false
	elif objet is Arme:
		var est_equipee = IventaireManager.arme_equipee_actuelle == objet
		bouton_equiper.text = "Équiper"
		bouton_equiper.visible = not est_equipee
		bouton_desequiper.visible = est_equipee
	elif objet is Armure:
		var est_equipee = IventaireManager.armure_equipee_actuelle == objet
		bouton_equiper.text = "Équiper"
		bouton_equiper.visible = not est_equipee
		bouton_desequiper.visible = est_equipee
	elif objet is Bottes:
		var est_equipee = IventaireManager.bottes_equipees_actuelles == objet
		bouton_equiper.text = "Équiper"
		bouton_equiper.visible = not est_equipee
		bouton_desequiper.visible = est_equipee

	bouton_jeter.visible = true
	position = position_ecran
	popup()

func _on_bouton_equiper_pressed() -> void:
	if objet_cible is Consommable:
		IventaireManager.utiliser_consommable(objet_cible)
	elif objet_cible is Arme:
		IventaireManager.equiper_arme(objet_cible)
	elif objet_cible is Armure:
		IventaireManager.equiper_armure(objet_cible)
	elif objet_cible is Bottes:
		IventaireManager.equiper_bottes(objet_cible)
	elif objet_cible is Bouclier :
		IventaireManager.equiper_bouclier(objet_cible)
	hide()

func _on_bouton_desequiper_pressed() -> void:
	if objet_cible is Arme:
		IventaireManager.desequiper_arme()
	elif objet_cible is Armure:
		IventaireManager.desequiper_armure()
	elif objet_cible is Bottes:
		IventaireManager.desequiper_bottes()
	elif objet_cible is Bouclier :
		IventaireManager.desequiper_bouclier()
	hide()

func _on_bouton_jeter_pressed() -> void:
	IventaireManager.jeter_objet(objet_cible, 1)
	hide()
