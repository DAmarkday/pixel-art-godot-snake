extends Node2D
var map = preload("res://ui/Map.tscn")
var snake = preload("res://scene/enemy/snake/Snake.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 初始化地图
	var mapNode=map.instantiate()
	add_child(mapNode)
	
	var snakeNode=snake.instantiate()
	add_child(snakeNode)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
