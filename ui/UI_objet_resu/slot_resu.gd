extends TextureButton
@onready var icone: TextureRect = $icone
@onready var label_pourcentage: Button = $label_pourcentage



var resu_reference : Resu

signal resu_clique(resu: Resu)

func configurer(resu: Resu) -> void:
	resu_reference = resu
	icone.texture = resu.icone
	label_pourcentage.text = str(resu.pourcentage_pv) + "%"

func _on_pressed() -> void:
	resu_clique.emit(resu_reference)
