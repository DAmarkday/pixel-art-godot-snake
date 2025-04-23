extends Node2D
class_name BaseBullet

@export var speed = 500
@export var dir = Vector2.ZERO
var _tick = 0
var velocity = null
# physic默认在项目设置里是60帧，process就是实际游戏帧率
func _physics_process(delta):
	global_position += velocity*delta
	_tick+=delta
	if Engine.get_physics_frames() % 20:
		if _tick>=3:
			queue_free()
			pass


# Called when the node enters the scene tree for the first time.
func _ready():
	velocity=dir *  speed
	#look_at(get_global_mouse_position())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#func _on_area_2d_body_entered(body):
	#print('1111')
	#if body is BossSnakeBody:
		##Game.damage(Game.player,body)
		##set_physics_process(false)
		#
		##var ins = _pre_hit_effect.instantiate()
		##ins.global_position = global_position
		#
		##Game.map.add_child(ins)
		#queue_free()
	#pass # Replace with function body.


#func _on_area_2d_body_entered(body):
	##var body = body.get_parent()
	#if body is BossSnakeBody:
		#body.on_hit(5)
		#set_physics_process(false)
		#queue_free()
		#
	##if body is Village:
		##set_physics_process(false)
		##queue_free()
	#pass # Replace with function body.
