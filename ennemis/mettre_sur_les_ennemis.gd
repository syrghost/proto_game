extends CharacterBody3D
class_name Ennemi

@export var type_ennemi : TypeEnnemi
@onready var sante: Node = $Sante
@onready var zone_detection_joueur: Area3D = $zone_detection_joueur
@onready var mesh: Node3D = $mesh
@onready var hit_box_arme_ou_main: Area3D = $hit_box_arme_ou_main

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
# ---------------------------SCENE VIE AU DESSUS ENNEMI -------------------------
const barre_de_vie_ennemi = preload("res://ui/UI_FOCUS_ENNEMI/ui_barre_de_vie_ennemi/ui_barre_vie_ennemi.tscn")
#--------------------------------------------------------------------------------------
enum Etat { patrouille, poursuite, attaque, mort }
var etat_actuel : Etat = Etat.patrouille

var joueur_detecte : Node3D = null
var peut_attaquer : bool = true
var en_transition : bool = false

func _ready() -> void:
	sante.vie_max = type_ennemi.vie_max
	sante.mort.connect(_on_mort)
	sante.degats_recus.connect(_on_degats_recus)
	zone_detection_joueur.joueur_detecte.connect(_on_joueur_detecte)
	zone_detection_joueur.joueur_perdu.connect(_on_joueur_perdu)
	hit_box_arme_ou_main.monitoring = false
	#------------------instanciation de la barre de vie-------------------
	while UiManager.canvas_ui == null:
			await get_tree().process_frame
	var barre = barre_de_vie_ennemi.instantiate()
	UiManager.canvas_ui.add_child(barre)
	barre.configurer(self,sante)
	#---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	match etat_actuel:
		Etat.patrouille:
			mode_patrouille(delta)
		Etat.poursuite:
			mode_poursuite(delta)
		Etat.attaque:
			pass  # géré par la coroutine attaquer()
		Etat.mort:
			pass
	move_and_slide()

func mode_patrouille(delta: float) -> void:
	if animation.current_animation != type_ennemi.animation_idle:
		animation.play(type_ennemi.animation_idle)
	velocity = Vector3.ZERO
	move_and_slide()

func mode_poursuite(delta: float) -> void:
	if not is_instance_valid(joueur_detecte):
		etat_actuel = Etat.patrouille
		return

	var distance = global_position.distance_to(joueur_detecte.global_position)

	if distance <= type_ennemi.portee_attaque and peut_attaquer:
		attaquer()
		return

	nav_agent.target_position = joueur_detecte.global_position
	var next_pos = nav_agent.get_next_path_position()

	var direction = next_pos - global_position
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * type_ennemi.vitesse_deplacement
	velocity.z = direction.z * type_ennemi.vitesse_deplacement

	if direction.length() > 0.1:
		mesh.look_at(mesh.global_position - direction, Vector3.UP)

	if animation.current_animation != type_ennemi.animation_marche:
		animation.play(type_ennemi.animation_marche)

func attaquer() -> void:
	if en_transition:
		return
	en_transition = true
	peut_attaquer = false
	etat_actuel = Etat.attaque
	velocity = Vector3.ZERO

	var nom_anim : String
	var degats : int
	var hitbox_a_utiliser : Area3D

	if type_ennemi.arme_equipee:
		nom_anim = type_ennemi.arme_equipee.animation_attaqe_arme
		degats = type_ennemi.arme_equipee.dommage_arme
		hitbox_a_utiliser = type_ennemi.arme_equipee.find_child("detection_ennemi")  # référence vers la hitbox de l'arme équipée, si applicable
	else:
		nom_anim = type_ennemi.animation_attaque
		degats = type_ennemi.degat_attaque_main
		hitbox_a_utiliser = hit_box_arme_ou_main  # adapte le chemin exact vers ta hitbox à mains nues

	animation.play(nom_anim)

	await get_tree().create_timer(0.2).timeout  # délai avant l'impact, à ajuster
	await hitbox_a_utiliser.activer(degats, "joueur")
	await get_tree().create_timer(0.15).timeout
	hitbox_a_utiliser.desactiver()

	await animation.animation_finished
	en_transition = false
	etat_actuel = Etat.poursuite

	await get_tree().create_timer(type_ennemi.cooldown_attaque).timeout
	peut_attaquer = true

func _on_joueur_detecte(joueur: Node3D) -> void:
	joueur_detecte = joueur
	if etat_actuel == Etat.patrouille:
		etat_actuel = Etat.poursuite

func _on_joueur_perdu(joueur: Node3D) -> void:
	if joueur == joueur_detecte:
		joueur_detecte = null
		if etat_actuel != Etat.attaque:
			etat_actuel = Etat.patrouille

func _on_degats_recus(quantite: int, vie_restante: int) -> void:
	print("Ennemi touché : -", quantite, " PV, reste ", vie_restante)

func _on_mort() -> void:
	etat_actuel = Etat.mort
	set_physics_process(false)
	if type_ennemi.animation_mort != "":
		animation.play(type_ennemi.animation_mort)
		await animation.animation_finished
	queue_free()
