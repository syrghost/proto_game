extends Control
@onready var barre_vie: ProgressBar = $barre_vie

func _ready() -> void:
	while EtatAnimationJoueur.sante_player == null:
		await get_tree().process_frame
	var sante_joueur = EtatAnimationJoueur.sante_player
	barre_vie.max_value = sante_joueur.vie_max
	barre_vie.value = sante_joueur.vie_actuelle
	sante_joueur.degats_recus.connect(_on_vie_changee)
	sante_joueur.soin_recu.connect(_on_vie_changee)

func _on_vie_changee(_quantite: int, vie_restante: int) -> void:
	barre_vie.value = vie_restante
