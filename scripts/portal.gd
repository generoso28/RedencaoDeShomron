extends Area2D
class_name Portal

@onready var global = get_node("/root/Global")

var _next_scene: String 
var _points: int
var _player_ref = null
var _current_scene: String
func _ready():
	randomize()
	_points = randi_range(50, 70)
	$Animation.play("default")
func _on_body_entered(_body):
	if _body is Character and global._objectives_count <= 0:
		_player_ref = _body
		_current_scene = _player_ref.get_tree().get_current_scene().name
		if (_current_scene == "Level"):
			_next_scene = "res://scenes/levels/level_2.tscn"
		if (_current_scene == "Level2"):
			_next_scene = "res://scenes/levels/boss_story.tscn"
		_player_ref._update_points(_points)
		global._saved_points = global._character_points
		_body.get_tree().change_scene_to_file(_next_scene)

func _on_animation_frame_changed():
	if(global._objectives_count <= 0):
		$Animation.show()
		return
	$Animation.hide()
	pass # Replace with function body.
