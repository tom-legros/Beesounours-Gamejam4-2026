extends CharacterBody2D

var pv_max : int = 10
var pv : int = pv_max
var vitesse_normale = 35
var vitesse_charge = 350
var acc_charge = 800


var scene_petite_abeille = preload("res://abeille.tscn")

var est_actif : bool = false
var est_invulnerable : bool = false
var en_train_de_charger : bool = false
var joueur_cible = null

@onready var sprite = $Sprite2D

func _ready():
	sprite.modulate = Color(0.6, 0.6, 0.6) 

func _physics_process(delta):
	if not est_actif:
		return

	if joueur_cible == null:
		joueur_cible = get_tree().current_scene.find_child("Player", true, false)
	
	if joueur_cible:
		if en_train_de_charger:
			velocity = velocity.move_toward(velocity.normalized() * vitesse_charge, acc_charge * delta)
		else:
			var direction = global_position.direction_to(joueur_cible.global_position)
			velocity = direction * vitesse_normale

			if direction.x > 0: sprite.flip_h = false
			else: sprite.flip_h = true
			sprite.position.y = sin(Time.get_ticks_msec() * 0.005) * 5.0
	
	move_and_slide()

func reveiller_boss():
	if est_actif: return 
	est_actif = true
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
	tween.tween_property(sprite, "scale", Vector2(2.5, 2.5), 0.2)
	tween.tween_property(sprite, "scale", Vector2(2.2, 2.2), 0.2)
	
	
	boucle_attaque()


func boucle_attaque():
	await get_tree().create_timer(1.0).timeout
	

	while pv > 0 and est_actif:
		var est_enerve = (pv <= 4)
		
		var temps_attente = 4.0
		if est_enerve: temps_attente = 2.5
		
		await get_tree().create_timer(temps_attente).timeout
		if pv <= 0: break 

		faire_apparaitre_minions(est_enerve)
		await get_tree().create_timer(0.8).timeout
		if pv <= 0: break


		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(2.5, 2.5), 0.2)
		tween.tween_property(sprite, "modulate", Color.ORANGE, 0.2)
		tween.tween_property(sprite, "scale", Vector2(2.2, 2.2), 0.2)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
		await tween.finished
		

		en_train_de_charger = true
		sprite.position.y = 0 
		
		if joueur_cible:
			var direction_dash = global_position.direction_to(joueur_cible.global_position)
			velocity = direction_dash * vitesse_charge
		
		await get_tree().create_timer(0.6).timeout
		

		velocity = Vector2.ZERO
		en_train_de_charger = false

func faire_apparaitre_minions(est_enerve: bool):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(sprite, "scale", Vector2(2.8, 2.8), 0.2)
	tween.tween_property(sprite, "scale", Vector2(2.2, 2.2), 0.2)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	var nombre = 1
	if est_enerve: nombre = 2
	
	for i in range(nombre):
		var minion = scene_petite_abeille.instantiate()
		var decalage = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		minion.global_position = global_position + decalage
		get_parent().add_child(minion)


func subir_degats():

	if not est_actif:
		reveiller_boss()

	if est_invulnerable: return
		
	pv -= 1
	est_invulnerable = true
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.8, 2.5), 0.05)
	tween.tween_property(sprite, "scale", Vector2(2.2, 2.2), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	velocity = -velocity.normalized() * 80
	move_and_slide()
	
	await get_tree().create_timer(0.2).timeout
	est_invulnerable = false

	if pv <= 0:
		mourir()

func mourir():
	est_actif = false
	set_physics_process(false)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "rotation_degrees", 360 * 2, 1.5)
	tween.tween_property(self, "scale", Vector2.ZERO, 1.5)
	tween.tween_property(sprite, "modulate", Color.BLACK, 1.5)
	
	if joueur_cible and joueur_cible.has_method("gagner_vie"):
		joueur_cible.gagner_vie(3)
	
	await tween.finished
	queue_free()

func _on_zone_degats_body_entered(body):
	if body.name == "Player":
		if body.has_method("recevoir_degats"):
			body.recevoir_degats(1, global_position)

func _on_zone_detection_body_entered(body):
	if body.name == "Player":
		reveiller_boss()
