extends StaticBody2D

@onready var _label: TextEdit = $CanvasLayer/Label
@onready var _font: FontFile = preload("res://assets/KIN668.TTF")

func _on_area_body_entered(_body):
	if _body is Character:
		_label.show()
	pass # Replace with function body.


func _on_area_2d_body_exited(_body):
	if _body is Character:
		_label.hide()
	pass # Replace with function body.
