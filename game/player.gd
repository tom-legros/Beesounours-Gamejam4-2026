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
@onready var barre_vie = get_tree().current_scene.find_child("BarreVie", true, false)
@onready var slash_sprite: AnimatedSprite2D = $ZoneAttaque/SlashSprite


var texture_normale = preload("res://img/Ours_Walking1.png")
var texture_attaque = preload("res://img/Ours_attaque.png")
var texture_arriere = preload("res://img/Ours_arriere1.png")
var texture_avant = preload("res://img/Ours_avant.png")

var pv_max : int = 3
var pv_actuels : int = pv_max
var est_invulnerable : bool = false 


func recevoir_degats(montant: int):
	if est_invulnerable or pv_actuels <= 0:
		return
	pv_actuels -= montant
	camera.offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
	await get_tree().create_timer(0.1).timeout
	camera.offset = Vector2.ZERO
	if barre_vie:
		barre_vie.value = pv_actuels
	print("PV restants : ", pv_actuels)
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)
	
	if pv_actuels <= 0:
		mourir()
	else:
		est_invulnerable = true
		await get_tree().create_timer(1.0).timeout
		est_invulnerable = false

func mourir():
	print("L'ours a rendu l'âme...")
	set_physics_process(false) 
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()

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
		if not is_attacking:
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
	elif not is_attacking:
		animated_sprite.play("idle")
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)
	move_and_slide()

func lancer_attaque():
	if is_attacking:
		return

	is_attacking = true
	velocity = Vector2.ZERO

	animated_sprite.play("attaque")

	await get_tree().create_timer(0.15).timeout
	collision_attaque.disabled = false

	slash_sprite.visible = true
	slash_sprite.play("slash")

	await get_tree().create_timer(0.25).timeout
	collision_attaque.disabled = true

	is_attacking = false


	
func _on_zone_attaque_body_entered(body):
	if body == self:
		return  
	if body.is_in_group("Ennemis") or body.get_parent().is_in_group("Ennemis"):
		var cible = body if body.is_in_group("Ennemis") else body.get_parent()
		cible.modulate = Color.WHITE * 10
		await get_tree().create_timer(0.05).timeout
		cible.queue_free()


func _on_slash_sprite_animation_finished():
	slash_sprite.visible = false
