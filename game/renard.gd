extends CharacterBody2D

@export var VITESSE_MAX = 50
@export var ACCELERATION = 400
@export var VITESSE_ERRANCE = 30

# --- NOUVEAU : SYSTÈME DE VIE ---
var pv : int = 3
var est_invulnerable : bool = false
# ------------------------------

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
	
	# Le renard recule s'il vient de prendre un coup (Optionnel)
	if not est_invulnerable:
		velocity = velocity.move_toward(direction_voulue * (VITESSE_MAX if cible else VITESSE_ERRANCE), ACCELERATION * delta)

	if velocity.x > 2: 
		$Sprite2D.flip_h = true
	elif velocity.x < -2:
		$Sprite2D.flip_h = false
	
	move_and_slide()

# --- LA FONCTION QUI MANQUAIT ---
func subir_degats():
	if est_invulnerable:
		return
		
	pv -= 1
	print("Le renard a mal ! PV restants : ", pv)
	
	# Effet Rouge
	est_invulnerable = true
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 0.1)
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
	
	# Petit recul
	velocity = -velocity.normalized() * 200
	move_and_slide()
	
	await get_tree().create_timer(0.4).timeout
	est_invulnerable = false

	if pv <= 0:
		mourir()

func mourir():
	print("Renard vaincu !")
	queue_free() # C'est ICI qu'il meurt pour de bon

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

# Pour attaquer l'ours
func _on_zone_degats_body_entered(body):
	if body.name == "Player":
		if body.has_method("recevoir_degats"):
			body.recevoir_degats(1)
