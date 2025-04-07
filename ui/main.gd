extends Node2D
var _map = preload("res://ui/Map.tscn")
var _snake = preload("res://scene/enemy/snake/Snake.tscn")

const _player = preload("res://scene/player/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 初始化地图
	var mapNode=_map.instantiate()
	add_child(mapNode)
	
	var snakeNode=_snake.instantiate()
	add_child(snakeNode)
	
	var instance = _player.instantiate()
	instance.position = Vector2(320,160)
	add_child(instance)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
