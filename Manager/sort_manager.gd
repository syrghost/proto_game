extends Node

signal sort_appris(grimoire: Grimoire)
signal sort_change(grimoire: Grimoire)

var sorts_connus : Array[Grimoire] = []
var sort_actif : Grimoire = null
var magie_debloquee : bool = false

func apprendre_sort(grimoire: Grimoire) -> void:
	if grimoire not in sorts_connus:
		sorts_connus.append(grimoire)
		if sort_actif == null:
			sort_actif = grimoire
		sort_appris.emit(grimoire)

func changer_sort_actif(direction: int) -> void:
	if sorts_connus.is_empty():
		return
	var index = sorts_connus.find(sort_actif)
	index = (index + direction) % sorts_connus.size()
	if index < 0:
		index += sorts_connus.size()
	sort_actif = sorts_connus[index]
	sort_change.emit(sort_actif)
