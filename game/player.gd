extends CharacterBody2D

const WALK_SPEED = 150.0  # Vitesse de marche normale
const SPRINT_SPEED = 350.0 # Vitesse quand on sprint

func _physics_process(_delta):
	
	var current_speed = WALK_SPEED

	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = SPRINT_SPEED

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)

	move_and_slide()
