extends CharacterBody2D

const WALK_SPEED = 150.0 
const SPRINT_SPEED = 350.0 

var is_attacking: bool = false
@onready var collision_attaque = $ZoneAttaque/CollisionShape2D
@onready var sprite_ours = $PlayerSprite

var texture_normale = preload("res://img/Ours.png")
var texture_attaque = preload("res://img/Ours_attaque.png")

func _physics_process(_delta):
	if Input.is_key_pressed(KEY_SPACE) and is_attacking == false:
		lancer_attaque()

	var current_speed = WALK_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = SPRINT_SPEED

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction.x < 0:
		sprite_ours.flip_h = true 
	elif direction.x > 0:
		sprite_ours.flip_h = false 
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)

	move_and_slide()

func lancer_attaque():
	is_attacking = true
	if sprite_ours:
		sprite_ours.texture = texture_attaque
	collision_attaque.disabled = false
	await get_tree().create_timer(0.4).timeout
	collision_attaque.disabled = true
	if sprite_ours:
		sprite_ours.texture = texture_normale
	is_attacking = false

func _on_zone_attaque_body_entered(body):
	if body.is_in_group("Ennemis"):
		body.queue_free()
