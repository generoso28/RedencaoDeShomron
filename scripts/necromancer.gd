extends CharacterBody2D
class_name Necromancer

var _is_dead: bool = false
var _player_ref = null
var _speed: float = 30
var _state_machine
var _direction: Vector2 = global_position

var _attack_level: float = 25
var _super_attack_level: float = 45
var _attack_distance: float = 70
var _is_attacking: bool = false
var _is_super_attacking: bool = false
var _points_to_kill: int
var _health: float = 180
var _distance: float

var _attack_time: float = 2
var _super_attack_time: float = 7

var _is_being_attacked: bool = false

@onready var global = get_node("/root/Global")

@export_category("Variables")
@export var _move_speed: float = 63.0
@export var _friction: float = 0.3
@export var _acceleration: float = 0.6

@export_category("Objects")
@export var _animation_tree: AnimationTree = null

func _ready():
	randomize()
	_points_to_kill = randi_range(40, 65)
	_speed = randf_range(28,35)
	_health = randf_range(40, 60)
	_animation_tree.active = true
	_state_machine = _animation_tree["parameters/playback"]
	global._objectives_count += 1
	$AttackTimer.wait_time = _attack_time
	$SuperAttackTimer.wait_time = _super_attack_time
	$AttackTimer.start()
	$SuperAttackTimer.start()
	$ProgressBar._change_values(_health)
	$ProgressBar._update_health(_health)
	
func _update_distance() -> void:
	if(_player_ref!=null):
		_distance = global_position.distance_to(_player_ref.global_position)
		
func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		$BodyEnteredAudio.play()
		
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
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		_animation_tree["parameters/being_attacked/blend_position"] = _direction
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)


func _animate() -> void:
	if _is_being_attacked:
		_state_machine.travel("being_attacked")
		return
	if _is_attacking:
		$AttackAudio.play()
		if _is_super_attacking:
			_state_machine.travel("super_attack")
			return
		_state_machine.travel("attack")
		return
	if velocity.length() > 1:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")

func _update_health(_level: float):
	if not _is_dead and not _is_being_attacked:
		_is_being_attacked = true
		_health -= _level
		$ProgressBar._update_health(_health)
		await get_tree().create_timer(0.5).timeout
		if _health <= 0:
			die()
		_is_being_attacked = false

func die() -> void:
	_is_dead = true
	_state_machine.travel("death")
	_player_ref._update_points(_points_to_kill)
	await get_tree().create_timer(0.2).timeout
	global._objectives_count -= 1
	


func _on_animation_finished(_anim_name: String) -> void:
	if(_anim_name == "death"):
		queue_free()
	if(_anim_name == "being_attacked"):
		_is_attacking = false
	if(_anim_name == "super_attack"):
		_is_attacking = false
		_is_super_attacking = false
		return
	if(_anim_name == "attack"):
		_is_attacking = false
	
	
func _on_attack_timer_timeout():
	if _player_ref != null and _distance < _attack_distance and not _is_dead and not _is_super_attacking:
		_attack_level = randf_range(20, 30)
		_is_attacking = true
		_player_ref._update_health(_attack_level, true)
		await get_tree().create_timer(1.7).timeout
		_is_attacking = false
	_update_distance()

func _on_super_attack_timeout():
	if _player_ref != null and _distance < _attack_distance and not _is_dead and not _is_super_attacking:
		_super_attack_level = randf_range(40, 50)
		_is_super_attacking = true
		_is_attacking = true
		_player_ref._update_health(_super_attack_level, true)
		await get_tree().create_timer(1.3).timeout
		_is_attacking = false
		_is_super_attacking = false
	_update_distance()
