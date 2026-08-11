extends Node

signal objet_ajoute(objet: Objet, quantite: int)
signal objet_retire(objet: Objet, quantite: int)
signal arme_equipee(arme: Arme)
signal arme_desequipee(arme: Arme)
signal objet_jete(objet: Objet)
signal demande_choix_resu(liste_resu : Array)
signal armure_equipee(armure: Armure)
signal armure_desequipee
signal bottes_equipees(bottes: Bottes)
signal bottes_desequipees

var contenu : Dictionary = {}  # { objet_id : {objet: Objet, quantite: int} }
var arme_equipee_actuelle : Arme = null
var armure_equipee_actuelle : Armure = null
var bottes_equipees_actuelles : Bottes = null

signal bouclier_equipe(bouclier: Bouclier)
signal bouclier_desequipe()

var bouclier_equipe_actuel : Bouclier = null

func connecter_sante() -> void : 
	EtatAnimationJoueur.sante_player.pv_a_zero.connect(_on_pv_a_zero)

func obtenir_toutes_resu() -> Array :
	var liste : Array = []
	for id in contenu :
		var entree = contenu[id]
		if entree.objet is Resu:
			liste.append(entree)
	return liste
func _on_pv_a_zero() -> void : 
	var liste_resu = obtenir_toutes_resu()
	if liste_resu.is_empty():
		EtatAnimationJoueur.sante_player.forcer_mort()
		return
	demande_choix_resu.emit(liste_resu)


# la pour demander si ont peut resu ou non
func utiliser_resu(resu: Resu) -> void:
	retirer_objet(resu, 1)
	EtatAnimationJoueur.sante_player.revivre(resu.pourcentage_pv)


func refuse_resu() -> void:
	EtatAnimationJoueur.sante_player.forcer_mort()

func ajouter_objet(objet: Objet, quantite: int = 1) -> void:
	if objet.id in contenu:
		contenu[objet.id].quantite += quantite
	else:
		contenu[objet.id] = {"objet": objet, "quantite": quantite}
	objet_ajoute.emit(objet, quantite)
	# equipement automatique si aucune arme est equipee
	#if objet is Arme and arme_equipee_actuelle == null :
		#equiper_arme(objet)

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

func obtenir_premiere_arme() -> Arme:
	for id in contenu:
		var entree = contenu[id]
		if entree.objet is Arme:
			return entree.objet
	return null
func utiliser_consommable(consommable: Consommable) -> void:
	match consommable.type_effet:
		Consommable.TypeEffet.SOIN:
			EtatAnimationJoueur.sante_player.soigner(consommable.valeur)
		Consommable.TypeEffet.MANA:
			EtatAnimationJoueur.mana_player.recuperer(consommable.valeur)
	retirer_objet(consommable, 1)
	
func equiper_armure(armure: Armure) -> void:
	armure_equipee_actuelle = armure
	armure_equipee.emit(armure)


func desequiper_armure() -> void:
	armure_equipee_actuelle = null
	armure_desequipee.emit()
	
func equiper_bottes(bottes: Bottes) -> void:
	bottes_equipees_actuelles = bottes
	bottes_equipees.emit(bottes)

func desequiper_bottes() -> void:
	bottes_equipees_actuelles = null
	bottes_desequipees.emit()


func obtenir_bonus_vitesse() -> float:
	var bonus = 0.0
	if armure_equipee_actuelle:
		bonus += armure_equipee_actuelle.vitesse_bonus
	if bottes_equipees_actuelles:
		bonus += bottes_equipees_actuelles.vitesse_bonus
	return bonus




func equiper_bouclier(bouclier: Bouclier) -> void:
	bouclier_equipe_actuel = bouclier
	bouclier_equipe.emit(bouclier)

func desequiper_bouclier() -> void:
	bouclier_equipe_actuel = null
	bouclier_equipe.emit(null)
	bouclier_desequipe.emit()
