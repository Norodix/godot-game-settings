extends Control


func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		print("MOVING!")
