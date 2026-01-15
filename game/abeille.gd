extends CharacterBody2D

# VITESSE (Réglée pour être esquivable)
@export var VITESSE_MAX = 45 
@export var ACCELERATION = 200 
@export var VITESSE_ERRANCE = 20

var pv : int = 1
var est_invulnerable : bool = false

var cible = null
var direction_errance = Vector2.ZERO
var temps_errance = 0.0
var random_offset : float = 0.0 

@onready var sprite = $Sprite2D

func _ready():
	choisir_direction_aleatoire()
	random_offset = randf_range(0, 100.0)
	
	# Animation Pop
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)

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
		velocity = velocity.move_toward(direction_voulue * (VITESSE_MAX if cible else VITESSE_ERRANCE), ACCELERATION * delta)
	
	if velocity.x > 2: sprite.flip_h = false
	elif velocity.x < -2: sprite.flip_h = true
	
	move_and_slide()
	
	# --- C'EST ICI QUE C'ETAIT CASSE ---
	# On regarde ce qu'on a touché
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		# IMPORTANT : On vérifie que c'est bien le JOUEUR
		if body.name == "Player":
			print("L'abeille a piqué le joueur !")
			
			if body.has_method("recevoir_degats"):
				# On essaie d'envoyer le recul, sinon juste les dégâts
				# (Pour éviter les bugs si ton player.gd n'est pas à jour)
				body.recevoir_degats(1, global_position)
			
			# L'abeille ne meurt QUE si elle a touché le Player
			mourir() 
			return # On arrête tout pour cette frame
	# -----------------------------------
	
	# Animation Buzz
	var temps = Time.get_ticks_msec() * 0.01
	sprite.position.y = sin(temps * 0.5 + random_offset) * 3.0
	sprite.rotation_degrees = sin(temps * 2.0 + random_offset) * 10.0

func subir_degats():
	if est_invulnerable: return
	pv -= 1
	est_invulnerable = true
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	velocity = -velocity.normalized() * 150
	move_and_slide()
	
	await get_tree().create_timer(0.2).timeout
	est_invulnerable = false
	
	if pv <= 0: mourir(true) # True = Tué par le joueur

# J'ai ajouté un paramètre pour savoir si c'est le joueur qui l'a tuée ou si elle s'est suicidée
func mourir(tuee_par_joueur = false):
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# On ne gagne de la vie que si on l'a TUÉE (pas si elle nous pique)
	if tuee_par_joueur:
		var joueur = get_tree().current_scene.find_child("Player", true, false)
		if joueur and joueur.has_method("gagner_vie"):
			joueur.gagner_vie(1)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation_degrees", 360, 0.4)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4)
	
	await tween.finished
	queue_free()

func choisir_direction_aleatoire():
	var angle = randf_range(0, 2 * PI)
	direction_errance = Vector2(cos(angle), sin(angle))
	temps_errance = randf_range(1.5, 4.0)

func _on_vision_body_entered(body):
	if body.name == "Player": 
		cible = body

func _on_vision_body_exited(body):
	if body == cible:
		cible = null
