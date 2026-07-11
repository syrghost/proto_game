extends Node

signal objet_ajoute(objet: Objet, quantite: int)
signal objet_retire(objet: Objet, quantite: int)
signal arme_equipee(arme: Arme)
signal arme_desequipee(arme: Arme)
signal objet_jete(objet: Objet)

var contenu : Dictionary = {}  # { objet_id : {objet: Objet, quantite: int} }
var arme_equipee_actuelle : Arme = null

func ajouter_objet(objet: Objet, quantite: int = 1) -> void:
	if objet.id in contenu:
		contenu[objet.id].quantite += quantite
	else:
		contenu[objet.id] = {"objet": objet, "quantite": quantite}
	objet_ajoute.emit(objet, quantite)

func retirer_objet(objet: Objet, quantite: int = 1) -> void:
	if objet.id in contenu:
		contenu[objet.id].quantite -= quantite
		if contenu[objet.id].quantite <= 0:
			contenu.erase(objet.id)
		objet_retire.emit(objet, quantite)

func possede(objet_id: String) -> bool:
	return objet_id in contenu

func equiper_arme(arme: Arme) -> void:
	arme_equipee_actuelle = arme
	arme_equipee.emit(arme)

func desequiper_arme() -> void:
	var arme_retiree = arme_equipee_actuelle
	arme_equipee_actuelle = null
	arme_equipee.emit(null)
	arme_desequipee.emit(arme_retiree)

func jeter_objet(objet: Objet, quantite: int) -> void:
	if arme_equipee_actuelle == objet:
		desequiper_arme()
	retirer_objet(objet, quantite)
	objet_jete.emit(objet)
