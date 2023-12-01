extends Node2D

@onready var global = get_node("/root/Global")

var _new_slime = preload("res://scenes/slime.tscn")
var _new_necromancer = preload("res://scenes/necromancer.tscn")
var _new_wine = preload("res://scenes/components/wine.tscn")
var _new_locker = preload("res://scenes/components/locker.tscn")

var _count_slime: int = 0
var _count_wine: int = 0
var _count_necromancer: int = 0
var _count_locker: int = 0




# Called when the node enters the scene tree for the first time.
func _ready():
	global._objectives_count = 0
	print(get_tree().get_current_scene().name)
	randomize()
	$NewSlime.wait_time = randf_range(2, 6)
	$NewSlime.start()
	$NewNecromancer.wait_time = randf_range(6, 10)
	$NewNecromancer.start()
	$NewWine.wait_time = randf_range(8, 12)
	$NewWine.start()
	$NewLocker.wait_time = randf_range(6, 10)
	$NewLocker.start()

func _on_new_slime_timeout():
	if _count_slime < randf_range(4,7):
		var _enemy = _new_slime.instantiate()
		add_child(_enemy)
		_enemy.position.x = randf_range(-225, 865)
		_enemy.position.y = randf_range(-110, 525)
		
		_count_slime +=1

func _on_new_necromancer_timeout():
	if _count_necromancer < randi_range(2,4):
		var _enemy = _new_necromancer.instantiate()
		add_child(_enemy)
		_enemy.position.x = randf_range(-225, 865)
		_enemy.position.y = randf_range(-110, 525)
		_count_necromancer +=1

func _on_new_wine_timeout():
	if _count_wine < randi_range(2,4):
		var _wine = _new_wine.instantiate()
		add_child(_wine)
		_wine.position.x = randf_range(-225, 865)
		_wine.position.y = randf_range(-110, 525)
		_count_wine +=1
	pass # Replace with function body.


func _on_new_locker_timeout():
	if _count_locker < randi_range(3,6):
		var _locker = _new_locker.instantiate()
		add_child(_locker)
		_locker.position.x = randf_range(-225, 865)
		_locker.position.y = randf_range(-110, 525)
		_count_locker +=1
		
