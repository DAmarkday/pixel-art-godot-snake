extends Node2D
class_name BaseBullet

@export var speed = 500
@export var dir = Vector2.ZERO
@onready var sprite = $ColorRect
var _tick = 0
var velocity = Vector2(500, 0)
# physic默认在项目设置里是60帧，process就是实际游戏帧率
func _physics_process(delta):
	global_position += velocity*delta
	#update_sprite_rotation()
	_tick+=delta
	if Engine.get_physics_frames() % 20:
		if _tick>=3:
			queue_free()
			pass

# 更新 Sprite2D 的旋转以匹配 velocity 方向
#func update_sprite_rotation() -> void:
	#if velocity != Vector2.ZERO:
		#sprite.rotation = velocity.angle()  # velocity.angle() 返回弧度

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity=dir *  speed
	#update_sprite_rotation()
	#look_at(get_global_mouse_position())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# 提供方法让房屋修改子弹方向
func set_direction(new_direction: Vector2) -> void:
	#pass
	 #反弹前的矢量速度和反弹后的矢量做角度差
	#var handledVector = new_direction.normalized()
	#var rotation=handledVector.angle_to(velocity)
	#sprite.rotation = sprite.rotation-rotation  # velocity.angle() 返回弧度
	#
	#velocity = handledVector * speed
	#rotate()
	
	var old_velocity = velocity.normalized()  # 入射方向
#
	var new_velocity = new_direction.normalized()
	#
	# 计算反弹前后方向的角度差
	var angle_diff = new_velocity.angle_to(old_velocity)
	# 如果贴图朝上，需在玩家脚本中设置初始旋转：
	# sprite.rotation = new_velocity.angle() - PI / 2
	
	#var offset = position - collisionP
	#var new_offset = offset.rotated(angle_diff)
	#position = position + new_offset
	#sprite.pivot_offset = Vector2(0,0)

	rotation -= angle_diff  # 基于当前旋转减去角度差
	velocity = new_velocity * speed
	# 调试：打印角度信息
	# print("Angle diff: ", rad_to_deg(angle_diff), " Sprite rotation: ", rad_to_deg(sprite.rotation))
	# update_sprite_rotation()



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
