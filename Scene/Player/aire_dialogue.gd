extends Area3D
@onready var player: Node3D = $"../mesh"

var pnj_a_portee : Array[Node] = []
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("parler"):
		if DialogueManager.en_dialogue:
			DialogueManager.avancer()
			print("je parle encore")
		elif pnj_a_portee.size()> 0 :
			pnj_a_portee[0].parler()
			print("premiere parole")



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("pnj"):
		body.rotation =  player.global_rotation
		pnj_a_portee.append(body)
		print("bienvenue")


func _on_body_exited(body: Node3D) -> void:
	if body in pnj_a_portee:
		pnj_a_portee.erase(body)
		DialogueManager.terminer_dialogue()
		print("aurevoir")
		
