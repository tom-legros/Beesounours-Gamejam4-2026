extends CharacterBody2D

@export var VITESSE_MAX = 80
@export var ACCELERATION = 400
@export var VITESSE_ERRANCE = 30

var cible = null
var direction_errance = Vector2.ZERO
var temps_errance = 0.0

func _ready():
	choisir_direction_aleatoire()

func _physics_process(delta):
	var direction_voulue = Vector2.ZERO

	if cible != null:
		direction_voulue = global_position.direction_to(cible.global_position)
	else:
		temps_errance -= delta
		if temps_errance <= 0:
			choisir_direction_aleatoire()
		direction_voulue = direction_errance

	velocity = velocity.move_toward(direction_voulue * (VITESSE_MAX if cible else VITESSE_ERRANCE), ACCELERATION * delta)

	if velocity.x > 2: 
		$Sprite2D.flip_h = true
	elif velocity.x < -2:
		$Sprite2D.flip_h = false
	move_and_slide()

func choisir_direction_aleatoire():
	var angle = randf_range(0, 2 * PI)
	direction_errance = Vector2(cos(angle), sin(angle))
	temps_errance = randf_range(1.5, 4.0)

func _on_vision_body_entered(body):
	if body.name == "Player": 
		cible = body
		print("Le renard vous a repéré !")

func _on_vision_body_exited(body):
	if body == cible:
		cible = null
		choisir_direction_aleatoire()
		
func _on_zone_degats_body_entered(body):
	if body.name == "Player":
		body.recevoir_degats(1) 
