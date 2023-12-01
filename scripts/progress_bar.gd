extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _change_values(_max_value: float) -> void:
	$ProgressBar.max_value = _max_value
	pass
func _update_health(_life: float) -> void:
	$ProgressBar.value = _life
	pass
