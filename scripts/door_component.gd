extends Area2D
class_name DoorComponent

var _new_position: Vector2
@onready var global = get_node("/root/Global")
var _scene:String

var _player_ref: Character = null
@export_category("Objects")
@onready var _animation: AnimationPlayer = $Animation

func _on_body_entered(_body) -> void:
	if _body is Character:
		global._count_position += 1
		_player_ref = _body
		_scene = _player_ref.get_tree().get_current_scene().name
		_animation.play("open")


func _on_animation_finished(_anim_name: String) -> void:
	if _anim_name == "open":
		if(_scene == "Level"):
			if(global._count_position % 2 == 0):
				_new_position = Vector2(615,245)
			elif(global._count_position % 2 == 1):
				_new_position = Vector2(1243,350)
		elif (_scene == "Level2"):
			if(global._count_position % 2 == 1):
				_new_position = Vector2(615,245)
			elif(global._count_position % 2 == 0):
				_new_position = Vector2(1243,350)
		_change_position()
	
func _change_position() -> void:
	if(_scene == "Heaven"):
		_player_ref.set_physics_process(false)
		$Exit.show()
		return
	_player_ref.global_position = _new_position
	_animation.play("close")

func _on_exit_button_pressed():
	_player_ref.set_physics_process(true)
	_player_ref.get_tree().change_scene_to_file("res://scenes/levels/start.tscn")
	global._character_points = 0
	global._character_life = 220


func _on_cancel_button_pressed():
	_player_ref.set_physics_process(true)
	await get_tree().create_timer(0.2).timeout
	_animation.play("close")
	$Exit.hide()
