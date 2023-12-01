extends CharacterBody2D
class_name Slime

var _is_dead: bool = false
var _player_ref = null
var _speed: float = 40

var _attack_level: float = 5
var _attack_distance: float = 50
var _points_to_kill: int
var _health: float = 50
var _distance: float

var _attack_time: float = 0.7

@onready var global = get_node("/root/Global")

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation_player: AnimationPlayer = null

func _ready():
	randomize()
	_points_to_kill = randi_range(10, 20)
	_speed = randf_range(35,45)
	_health = randf_range(40, 60)
	global._objectives_count += 1
	$AttackTimer.wait_time = _attack_time
	$AttackTimer.start()
	$ProgressBar._change_values(_health)
	$ProgressBar._update_health(_health)
	
func _update_distance() -> void:
	if(_player_ref!=null):
		_distance = global_position.distance_to(_player_ref.global_position)
		
func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		$AttackTimer.start()
		_player_ref = _body
		
func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("character"):
		$AttackTimer.stop()
		_player_ref = null

func _physics_process(_delta: float) -> void:
	if _is_dead == true:
		return
	_animate()
	if _player_ref != null:
		if _player_ref._is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		
		velocity = _direction * _speed
		move_and_slide()
		_update_distance()

func _animate() -> void:
	if not _is_dead:
		if velocity.x > 0:
			_texture.flip_h = false
		if velocity.x < 0:
			_texture.flip_h = true
		if velocity != Vector2.ZERO:
			_animation_player.play("walk")
			return
		_animation_player.play("idle")
		
	pass

func _update_health(_level: float):
	if not _is_dead:
		_health -= _level
		$ProgressBar._update_health(_health)
		if _health <= 0:
			die()

func die() -> void:
	_is_dead = true
	_animation_player.play("death")
	_player_ref._update_points(_points_to_kill)
	await get_tree().create_timer(0.2).timeout
	global._objectives_count -= 1


func _on_animation_finished(_anim_name: String) -> void:
	if(_anim_name == "death"):
		queue_free()
	
func _on_attack_timer_timeout():
	if _player_ref != null and _distance < _attack_distance and not _is_dead:
		_attack_level = randf_range(3,8)
		$AttackAudio.play()
		_player_ref._update_health(_attack_level, true)
	_update_distance()
