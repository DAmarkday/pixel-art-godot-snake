extends Area2D
class_name VillageArea
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _calculate_normal(collision_point):
	var shape = $CollisionShape2D.shape as RectangleShape2D
	var shape_pos = $CollisionShape2D.global_position
	var extents = shape.extents
	var left = shape_pos.x - extents.x
	var right = shape_pos.x + extents.x
	var top = shape_pos.y - extents.y
	var bottom = shape_pos.y + extents.y

	# 根据碰撞点判断法线
	if abs(collision_point.x - left) < 10:
		return Vector2(1, 0) # 左墙，法线向右
	elif abs(collision_point.x - right) < 10:
		return Vector2(-1, 0) # 右墙，法线向左
	elif abs(collision_point.y - top) < 10:
		return Vector2(0, 1) # 上墙，法线向下
	elif abs(collision_point.y - bottom) < 10:
		return Vector2(0, -1) # 下墙，法线向上
	return Vector2(0, 0) # 默认（避免错误）

func _on_area_entered(area: Area2D) -> void:
	if area is BaseBulletArea:
		var node = area.get_parent() as BaseBullet
		var collision_point = node.global_position
		var normal = _calculate_normal(collision_point)
		# 计算子弹的反弹速度
		node.velocity = node.velocity.bounce(normal).normalized() * node.speed
		#area.clear()
	pass # Replace with function body.
