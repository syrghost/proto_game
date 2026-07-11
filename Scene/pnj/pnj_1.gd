extends CharacterBody3D
@onready var animation_pnj: AnimationPlayer = $anime_pnj/AnimationPlayer

var peut_parler : bool = false
@export var donnee : Donnee_PNJ


func _ready() -> void:
	add_to_group("pnj")
	DialogueManager.dialogue_termine.connect(_on_dialogue_terminer)
func parler() -> void:
	match donnee.type_dialogue :
		Donnee_PNJ.dialogue_possible.simple :
			peut_parler = true
			DialogueManager.demarrer_dialogue(donnee)

func _physics_process(delta: float) -> void:
		if not is_on_floor():
			velocity += get_gravity() * delta
		if peut_parler :
			animation_pnj.play("Parler")
		else :
			animation_pnj.play("En_attente")


func _on_dialogue_terminer():
	peut_parler = false
