extends CharacterBody2D

var vitesse = 60
var cible = null

func _physics_process(_delta):
	if cible != null:
		var direction = global_position.direction_to(cible.global_position)
		velocity = direction * vitesse
		if direction.x > 0:
			$Sprite2D.flip_h = true
		elif direction.x < 0:
			$Sprite2D.flip_h = false
		move_and_slide()
		
func _on_vision_body_entered(body):
	if body.name == "Player": 
		cible = body
		print("Je te vois !")

func _on_vision_body_exited(body):
	if body == cible:
		cible = null
		print("Il est parti...")
