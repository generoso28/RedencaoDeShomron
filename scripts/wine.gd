extends Area2D

var _player_ref = null
var _life_gain: float = 50

func _on_body_entered(_body):
	if _body is Character:
		_player_ref = _body
		_player_ref._update_health(_life_gain, false)
		queue_free()
		pass
	pass # Replace with function body.


func _on_body_exited(_body):
	if _body is Character:
		_player_ref = null
	pass # Replace with function body.
