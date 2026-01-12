extends CharacterBody2D

const WALK_SPEED = 70
const SPRINT_SPEED = 150

const ZOOM_NORMAL = Vector2(5.0, 5.0) 
const ZOOM_RUN = Vector2(3.5, 3.5) 
const ZOOM_SPEED = 5.0

var is_attacking: bool = false


@onready var zone_attaque_node = $ZoneAttaque 
@onready var collision_attaque = $ZoneAttaque/CollisionShape2D
@onready var sprite_ours = $PlayerSprite
@onready var camera = $Camera2D
@onready var animated_sprite = $PlayerSprite


var texture_normale = preload("res://img/Ours_Walking1.png")
var texture_attaque = preload("res://img/Ours_attaque.png")
var texture_arriere = preload("res://img/Ours_arriere1.png")
var texture_avant = preload("res://img/Ours_avant.png")

func _physics_process(_delta):
	animated_sprite.speed_scale = 1
	if Input.is_key_pressed(KEY_SPACE) and is_attacking == false:
		lancer_attaque()
	var current_speed = WALK_SPEED
	var target_zoom = ZOOM_NORMAL 
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = SPRINT_SPEED
		target_zoom = ZOOM_RUN
		animated_sprite.speed_scale = 4
	if camera:
		camera.zoom = camera.zoom.lerp(target_zoom, ZOOM_SPEED * _delta)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction.x != 0:
		animated_sprite.play("walking")
		if direction.x > 0:
			animated_sprite.flip_h = false
			zone_attaque_node.rotation_degrees = 0  
		else:
			animated_sprite.flip_h = true
			zone_attaque_node.rotation_degrees = 180 
	elif direction.y != 0:
		animated_sprite.flip_h = false 
		if direction.y > 0:
			animated_sprite.play("devant")
			zone_attaque_node.rotation_degrees = 90  
		else: 
			animated_sprite.play("arriere")         
			zone_attaque_node.rotation_degrees = -90 
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)
	move_and_slide()

func lancer_attaque():
	is_attacking = true
	if animated_sprite:
		animated_sprite.play("attaque")
	collision_attaque.disabled = false
	await get_tree().create_timer(0.4).timeout
	collision_attaque.disabled = true
	if animated_sprite:
		animated_sprite.play("walking")
	is_attacking = false

	
func _on_zone_attaque_body_entered(body):
	if body == self:
		return  
	if body.is_in_group("Ennemis"):
		body.queue_free()
