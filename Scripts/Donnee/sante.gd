extends Node
class_name Sante
signal degats_recus(quantite: int, vie_restante: int)
signal soin_recu(quantite: int, vie_restante: int)
signal mort
signal pv_a_zero
@export var vie_max : int = 100
var vie_actuelle : int
var invincible : bool = false

func _ready() -> void:
	vie_actuelle = vie_max

func subir_degats(quantite: int) -> void:
	if invincible or vie_actuelle <= 0:
		return
	vie_actuelle = max(vie_actuelle - quantite, 0)
	degats_recus.emit(quantite, vie_actuelle)
	if vie_actuelle <= 0:
		pv_a_zero.emit()
		mort.emit()


func soigner(quantite: int) -> void:
	vie_actuelle = min(vie_actuelle + quantite, vie_max)
	soin_recu.emit(quantite, vie_actuelle)

func revivre( pourcentage : float) -> void:
	vie_actuelle = int ( vie_max * (pourcentage/100))
	soin_recu.emit(vie_actuelle,vie_actuelle)
	
func forcer_mort():
	mort.emit()

func est_vivant() -> bool:
	return vie_actuelle > 0
