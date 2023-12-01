extends StaticBody2D
class_name Locker

var _player_ref = null
var _points: int
var flag: bool = false
@onready var global = get_node("/root/Global")

@export_category("Objects")
@onready var _animation: AnimationPlayer = $Animation

func _ready() -> void:
	randomize()
	_points = randi_range(30, 55)
	global._objectives_count += 1
	
func _on_detection_area_body_entered(_body) -> void:
	if _body is Character and flag == false:
		_player_ref = _body
		_player_ref._update_points(_points)
		_animation.play("open")

func _on_animation_finished(_anim_name: String):
	if(_anim_name == "open"):
		global._objectives_count -= 1
		flag = true
