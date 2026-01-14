extends Area2D

@onready var Player =get_node("../Player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body:Node2D)->void:
	if body == Player:
		body.global_position=Vector2(2130,55)
