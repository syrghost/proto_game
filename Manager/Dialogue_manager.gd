extends Node

signal dialogue_demarre(nom_pnj: String)
signal ligne_affichee(texte: String)
signal dialogue_termine

var pnj_actuel : Donnee_PNJ
var index_ligne : int = 0
var en_dialogue : bool = false

func demarrer_dialogue(pnj: Donnee_PNJ) -> void:
	if pnj.dialogue.is_empty():
		return

	pnj_actuel = pnj
	index_ligne = 0
	en_dialogue = true
	dialogue_demarre.emit(pnj.nom_pnj)
	afficher_ligne_actuelle()

func avancer() -> void:
	if not en_dialogue:
		return

	index_ligne += 1
	if index_ligne >= pnj_actuel.dialogue.size():
		terminer_dialogue()
	else:
		afficher_ligne_actuelle()

func afficher_ligne_actuelle() -> void:
	ligne_affichee.emit(pnj_actuel.dialogue[index_ligne])

func terminer_dialogue() -> void:
	en_dialogue = false
	pnj_actuel = null
	index_ligne = 0
	dialogue_termine.emit()
