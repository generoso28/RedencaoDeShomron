extends CanvasLayer
var _label: Label 
@onready var _global = get_node("/root/Global")
@onready var _font: FontFile = preload("res://assets/KIN668.TTF")

func _ready():
	_add_label()  # Inicializa o _label no _ready
	
func _add_label():
	if _label == null:
		_label = Label.new()
		add_child(_label)
		_label.set_position(Vector2(24,16))
		_label.add_theme_font_override("font", _font)
		await get_tree().create_timer(0.1).timeout
		_update_points()
		return
	

func _update_points() -> void:
	if _label != null:
		_label.text = "Vida: " + str(_global._character_life) + "\nPontos: "  + str(_global._character_points)
		return
	_add_label()
	
	
	
