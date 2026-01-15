extends CharacterBody2D

@export var VITESSE_MAX = 60
@export var ACCELERATION = 300
@export var VITESSE_ERRANCE = 50

var pv : int = 3
var est_invulnerable : bool = false

var cible = null
var direction_errance = Vector2.ZERO
var temps_errance = 0.0

@onready var sprite = $Sprite2D

func _ready():
	choisir_direction_aleatoire()
	sprite.scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.5)

func _physics_process(delta):
	var direction_voulue = Vector2.ZERO
	
	if cible != null:
		direction_voulue = global_position.direction_to(cible.global_position)
	else:
		temps_errance -= delta
		if temps_errance <= 0:
			choisir_direction_aleatoire()
		direction_voulue = direction_errance
	
	if not est_invulnerable:
		var vitesse_actuelle = VITESSE_MAX if cible else VITESSE_ERRANCE
		velocity = velocity.move_toward(direction_voulue * vitesse_actuelle, ACCELERATION * delta)
	
	if velocity.x > 0:
		sprite.flip_h = true 
	elif velocity.x < 0:
		sprite.flip_h = false

	
	move_and_slide()
	if not est_invulnerable and velocity.length() > 5:
		var vitesse_rebond = 0.02 if cible else 0.01
		var hauteur_rebond = 4.0 if cible else 2.0
		sprite.position.y = -abs(sin(Time.get_ticks_msec() * vitesse_rebond) * hauteur_rebond)
	else:
		sprite.position.y = lerp(sprite.position.y, 0.0, 0.2)

func subir_degats():
	if est_invulnerable:
		return
		
	pv -= 1
	est_invulnerable = true
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.4, 0.6), 0.1).set_trans(Tween.TRANS_BOUNCE)
	
	tween.chain().tween_property(sprite, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	velocity = -velocity.normalized() * 150
	move_and_slide()
	
	await get_tree().create_timer(0.4).timeout
	est_invulnerable = false

	if pv <= 0:
		mourir()

func mourir():
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("ZoneDegats/CollisionShape2D"):
		$ZoneDegats/CollisionShape2D.set_deferred("disabled", true)
	
	sprite.position.y = 0 
	
	var joueur = get_tree().current_scene.find_child("Player", true, false)
	if joueur and joueur.has_method("gagner_vie"):
		joueur.gagner_vie(1)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "rotation_degrees", 720, 1.0)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 1.0)
	tween.tween_property(sprite, "modulate", Color(1,1,1,0), 1.0)
	
	await tween.finished
	queue_free()

func choisir_direction_aleatoire():
	var angle = randf_range(0, 2 * PI)
	direction_errance = Vector2(cos(angle), sin(angle))
	temps_errance = randf_range(1.0, 3.0)

func _on_vision_body_entered(body):
	if body.name == "Player":
		cible = body
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func _on_vision_body_exited(body):
	if body == cible:
		cible = null



func _on_zone_degats_body_entered(body):
	if body.name == "Player":
		if body.has_method("recevoir_degats"):
			body.recevoir_degats(1, global_position)
			var direction_recul = global_position.direction_to(body.global_position) * -1

			velocity = direction_recul * 600
			move_and_slide()
