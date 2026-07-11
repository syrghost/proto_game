extends Node
class_name Sante

signal degats_recus(quantite: int, vie_restante: int)
signal soin_recu(quantite: int, vie_restante: int)
signal mort

@export var vie_max : int = 100
var vie_actuelle : int

func _ready() -> void:
	vie_actuelle = vie_max

func subir_degats(quantite: int) -> void:
	if vie_actuelle <= 0:
		return  # déjà mort, on ignore les dégâts supplémentaires
	vie_actuelle = max(vie_actuelle - quantite, 0)
	degats_recus.emit(quantite, vie_actuelle)
	if vie_actuelle <= 0:
		mort.emit()

func soigner(quantite: int) -> void:
	vie_actuelle = min(vie_actuelle + quantite, vie_max)
	soin_recu.emit(quantite, vie_actuelle)

func est_vivant() -> bool:
	return vie_actuelle > 0
