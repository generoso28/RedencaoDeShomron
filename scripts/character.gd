extends CharacterBody2D
class_name Character

@onready var global = get_node("/root/Global")

var _health: float = 220
var _points: float = 0
var _state_machine
var _is_attacking: bool = false
var _is_dead: bool = false


var _attack_level: float = 20



@export_category("Variables")
@export var _move_speed: float = 64.0
@export var _friction: float = 0.8
@export var _acceleration: float = 0.4

@export_category("Objects")
@export var _attack_timer: Timer = null
@export var _animation_tree: AnimationTree = null

func _ready() -> void:
		_health = global._character_life
		_points = global._character_points
		_animation_tree.active = true
		_state_machine = _animation_tree["parameters/playback"]
		$ProgressBar._change_values(220)
		$ProgressBar._update_health(_health)
		
		

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	_move()
	_attack()
	_animate()
	move_and_slide()
	
	
func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if _direction != Vector2.ZERO:
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)

func _attack() -> void:
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		set_physics_process(false)
		$AttackAudio.play()
		_is_attacking = true
		_attack_timer.start()

	
func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return
	if velocity.length() > 1:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")

func _on_attack_timer_timeout():
	set_physics_process(true)
	_is_attacking = false

func _on_attack_area_body_entered(_body) -> void:
	if _body.is_in_group("enemy"):
		_body._update_health(_attack_level)
	pass # Replace with function body.

func _update_health(_life_change: float, _is_enemy: bool): #if _is_enemy is true, the life will be subtracted, else the life will be added, because it is a wine elixir
	if _is_enemy:
		if (_health-_life_change<0):
			_health = 0
			return
		_health -= _life_change
	else:
		_health += _life_change
	global._character_life = round(_health)
	$HUD._update_points()
	$ProgressBar._update_health(_health)
	if _health <= 0:
		die()

func _update_points(_gained_points: float) -> void:
	_points += _gained_points
	global._character_points = _points
	$HUD._update_points()
	pass

func die() -> void:
	_is_dead = true
	global._character_points = global._saved_points
	_points = global._character_points
	$HUD._update_points()
	_state_machine.travel("death")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
	
	
	
