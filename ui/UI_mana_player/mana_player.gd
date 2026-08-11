extends Control
@onready var barre_mana: ProgressBar = $barre_mana


func _ready() -> void:
	while EtatAnimationJoueur.mana_player == null:
		await get_tree().process_frame
	var mana_joueur = EtatAnimationJoueur.mana_player
	barre_mana.max_value = mana_joueur.mana_max
	barre_mana.value = mana_joueur.mana_actuelle
	mana_joueur.mana_consommee.connect(_on_mana_changee)
	mana_joueur.mana_recuperee.connect(_on_mana_changee)

func _on_mana_changee(_quantite: int, mana_restante: int) -> void:
	barre_mana.value = mana_restante
