extends CharacterBody2D
class_name Dragon

var _is_dead: bool = false
var _player_ref = null
var _speed: float = 30
var _state_machine
var _direction: Vector2 = global_position

var _attack_level: float = 60
var _attack_distance: float = 200
var _is_attacking: bool = false
var _points_to_kill: float = 144000
var _health: float = 300
var _distance: float

var _attack_time: float = 7.3

var _is_being_attacked: bool = false

@onready var global = get_node("/root/Global")

@export_category("Variables")
@export var _move_speed: float = 55
@export var _friction: float = 0.3
@export var _acceleration: float = 0.6

@export_category("Objects")
@onready var _texture: AnimatedSprite2D = $Texture
var _anim_name: String = ""

func _ready():
	randomize()
	_texture.play()
	$AttackTimer.wait_time = _attack_time
	$AttackTimer.start()
	$ProgressBar._change_values(_health)
	$ProgressBar._update_health(_health)
	
func _update_distance() -> void:
	if(_player_ref!=null):
		_distance = global_position.distance_to(_player_ref.global_position)
		
func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = _body
		
func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = null

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	if _player_ref != null:
		if _player_ref._is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		_direction = global_position.direction_to(_player_ref.global_position)
		velocity = _direction * _speed
		_move()
		_animate()
		move_and_slide()
		_update_distance()

func _move() -> void:
	if _direction != Vector2.ZERO:
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)


func _animate() -> void:
	if not _is_dead:
		if velocity.x > 0:
			_texture.flip_h = true
		if velocity.x < 0:
			_texture.flip_h = false
		if not _is_being_attacked and not _is_attacking:
			if velocity != Vector2.ZERO:
				_texture.play("walk")
				_anim_name="walk"
				return
			_texture.play("idle")
			_anim_name="idle"

func _update_health(_level: float):
	await get_tree().create_timer(0.1).timeout
	if not _is_dead and not _is_being_attacked:
		_is_being_attacked = true
		_health -= _level
		$ProgressBar._update_health(_health)
		if _health <= 0:
			die()
			return
		_texture.play("being_attacked")
		_anim_name="being_attacked"
		await get_tree().create_timer(1).timeout
		_is_being_attacked = false
		

func die() -> void:
	_is_dead = true
	_player_ref._update_points(_points_to_kill)
	$AttackAudio.stop()
	$DeathAudio.play()
	_texture.play("death")
	_anim_name="death"

func _on_animation_finished() -> void:
	if(_anim_name == "death"):
		queue_free()
		get_tree().change_scene_to_file("res://scenes/levels/end.tscn")

func _on_attack_timer_timeout():
	if _player_ref != null and _distance < _attack_distance and not _is_dead and not _is_attacking:
		_attack_level = randf_range(50,70)
		var _character = _player_ref
		_is_attacking = true
		$AttackAudio.play()
		_texture.play("attack")
		_anim_name="attack"
		await  get_tree().create_timer(2.8).timeout
		print(str(_character))
		_character._update_health(_attack_level, true)
		await get_tree().create_timer(0.6).timeout
		_is_attacking = false
	_update_distance()
	pass # Replace with function body.
