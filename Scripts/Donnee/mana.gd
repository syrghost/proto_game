extends Node
class_name Mana

signal mana_recuperee(quantite: int, mana_restante: int)
signal mana_consommee(quantite: int, mana_restante: int)

@export var mana_max : int = 50
@export var regen_par_seconde : float = 2.0
@export var delai_avant_regen : float = 1.0  # temps d'attente après consommation avant que la regen reprenne

var mana_actuelle : float
var temps_depuis_derniere_conso : float = 0.0

func _ready() -> void:
	mana_actuelle = mana_max

func _process(delta: float) -> void:
	if mana_actuelle >= mana_max:
		return
	temps_depuis_derniere_conso += delta
	if temps_depuis_derniere_conso >= delai_avant_regen:
		var ancienne_mana = int(mana_actuelle)
		mana_actuelle = min(mana_actuelle + regen_par_seconde * delta, mana_max)
		if int(mana_actuelle) != ancienne_mana:
			mana_recuperee.emit(int(mana_actuelle) - ancienne_mana, int(mana_actuelle))

func consommer(quantite: int) -> bool:
	if mana_actuelle < quantite:
		return false
	mana_actuelle -= quantite
	temps_depuis_derniere_conso = 0.0
	mana_consommee.emit(quantite, int(mana_actuelle))
	return true

func recuperer(quantite: int) -> void:
	mana_actuelle = min(mana_actuelle + quantite, mana_max)
	mana_recuperee.emit(quantite, int(mana_actuelle))
