extends Node2D

enum State {
	IDLE,
	SEEKING,
	EATING
}

# 导出参数，方便编辑器调整
@export var speed: float = 100.0  # 蛇移动速度（降低到50.0，突出缓慢转弯）
@export var base_segment_distance: float = 9.0  # 身体段基础间距（增大到16.0，宽松弧线）
@export var eating_growth_factor: float = 0.2  # 增长比例（保持0.2）
@export var turn_smoothing: float = 0.3  # 转弯平滑因子（降低到0.3，渐进转向）
@export var path_smoothing: float = 0.5  # 路径曲线平滑因子（提高到0.5，圆润弧线）

# 预加载场景
@onready var head_scene = preload("res://scene/enemy/snake/Head.tscn")  # 蛇头场景
@onready var body_scene = preload("res://scene/enemy/snake/Body.tscn")  # 蛇身场景
@onready var tail_scene = preload("res://scene/enemy/snake/Tail.tscn")  # 蛇尾场景
@onready var food_scene = preload("res://scene/enemy/snake/Food.tscn")  # 食物场景

# 游戏状态变量
var snake_body: Array[Vector2] = []  # 存储蛇身体段位置
var direction: Vector2 = Vector2.RIGHT  # 当前移动方向
var food: Node2D = null  # 当前食物实例
var current_state: State = State.IDLE  # 当前状态
var screen_width: float = 0  # 屏幕宽度
var screen_height: float = 0  # 屏幕高度
var path_points: Array[Vector2] = []  # 路径点，仅存储位置

func _ready() -> void:
	# 初始化游戏
	Game.map = self
	初始化蛇()
	生成食物()
	更新视觉效果()
	进入状态(State.SEEKING)

# 初始化蛇的起点位置
func 初始化蛇() -> void:
	snake_body.clear()
	path_points.clear()
	var start_pos = Vector2(screen_width / 2, screen_height / 2)  # 居中起始
	snake_body.append(start_pos)
	# 初始化4段身体，确保间距精确
	for i in range(3):
		var pos = start_pos - Vector2(base_segment_distance * (i + 1), 0)
		snake_body.append(pos)
		path_points.append(pos)
	path_points.append(start_pos)

# 每帧处理
func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			处理空闲状态(delta)
		State.SEEKING:
			处理寻食状态(delta)
		State.EATING:
			处理进食状态(delta)

# 空闲状态逻辑
func 处理空闲状态(_delta: float) -> void:
	pass

# 寻食状态：蛇追逐食物
func 处理寻食状态(delta: float) -> void:
	var head = snake_body[0]
	var target_direction = (food.position - head).normalized()  # 目标方向
	
	# 非常平滑的转向，生成宽松圆弧
	direction = direction.lerp(target_direction, turn_smoothing * delta * 10.0).normalized()
	
	# 移动蛇头
	var velocity = direction * speed * delta
	var new_head = head + velocity
	
	# 屏幕边界循环
	new_head.x = wrapf(new_head.x, 0, screen_width)
	new_head.y = wrapf(new_head.y, 0, screen_height)
	
	# 记录路径点，增加密度
	path_points.insert(0, new_head)
	snake_body[0] = new_head
	
	var segment_distance = 获取动态间距()
	
	# 更新身体段位置，沿着平滑曲线
	for i in range(1, snake_body.size()):
		var target = 获取平滑路径点位置(i * segment_distance)
		snake_body[i] = target  # 直接设置，确保间距
	
	# 清理多余路径点
	清理路径点(snake_body.size() * segment_distance)
	
	# 检查是否吃到食物
	if new_head.distance_to(food.position) < segment_distance:
		进入状态(State.EATING)
	
	更新视觉效果()

# 进食状态：增加身体长度
func 处理进食状态(_delta: float) -> void:
	var segment_distance = 获取动态间距()
	var last_segment = snake_body[-1]
	var second_last = snake_body[-2] if snake_body.size() >= 2 else last_segment
	var tail_direction = (last_segment - second_last).normalized()
	var new_segment = last_segment - tail_direction * segment_distance
	snake_body.append(new_segment)
	path_points.append(new_segment)
	
	生成食物()
	进入状态(State.SEEKING)

# 切换状态
func 进入状态(new_state: State) -> void:
	current_state = new_state
	print("进入状态：", State.keys()[new_state])

# 生成新食物
func 生成食物() -> void:
	if food:
		food.queue_free()
	
	food = food_scene.instantiate()
	var margin = base_segment_distance * 2  # 避免食物贴边
	food.position = Vector2(
		randf_range(margin, screen_width - margin),
		randf_range(margin, screen_height - margin)
	)
	add_child(food)

# 更新蛇的视觉表现
func 更新视觉效果() -> void:
	# 清除旧的视觉节点
	for child in get_children():
		if child.is_in_group("snake_body"):
			child.queue_free()
	
	var base_scale = 1.0 + max(0, snake_body.size() - 4) * eating_growth_factor  # 基础缩放
	
	for i in range(snake_body.size()):
		var body: Node2D
		var scale = base_scale
		
		# 选择段类型
		if i == 0:
			body = head_scene.instantiate()
		elif i == snake_body.size() - 1:
			body = tail_scene.instantiate()
			scale *= 1.15  # 尾部稍大
		else:
			body = body_scene.instantiate()
		
		# 计算平滑的旋转角度
		var rotation = direction.angle()
		if i > 0:
			# 使用曲线切线方向，增强圆弧感
			var segment_dir = (snake_body[i-1] - snake_body[i]).normalized()
			var target_rotation = segment_dir.angle()
			# 增加延迟旋转，模拟渐进弧线
			if i == snake_body.size() - 1 and snake_body.size() > 2:
				var prev_dir = (snake_body[i-2] - snake_body[i-1]).normalized()
				rotation = lerp_angle(prev_dir.angle(), target_rotation, 0.9)
			else:
				rotation = lerp_angle(rotation, target_rotation, 0.7)
		
		body.position = snake_body[i]
		body.rotation = rotation
		body.scale = Vector2(scale, scale)
		body.add_to_group("snake_body")
		#body.z_index = snake_body.size() - i
		
		add_child(body)

# 处理输入（重置游戏）
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_R:
			进入状态(State.IDLE)
			初始化蛇()
			生成食物()
			更新视觉效果()
			进入状态(State.SEEKING)

# 计算动态间距
func 获取动态间距() -> float:
	var growth_scale = 1.0 + max(0, snake_body.size() - 4) * eating_growth_factor
	return base_segment_distance * growth_scale

# 设置屏幕范围
func setCurActiveRange(w: int, h: int) -> void:
	screen_width = w
	screen_height = h

# 获取平滑路径点位置，使用Catmull-Rom样条
func 获取平滑路径点位置(distance: float) -> Vector2:
	var accumulated_distance: float = 0.0
	for i in range(path_points.size() - 1):
		var p1 = path_points[i]
		var p2 = path_points[i + 1]
		var segment_length = p1.distance_to(p2)
		
		if accumulated_distance + segment_length >= distance:
			var remaining = distance - accumulated_distance
			var t = clamp(remaining / segment_length, 0.0, 1.0)
			
			# 使用Catmull-Rom样条插值
			if i >= 1 and i < path_points.size() - 2:
				var p0 = path_points[i-1]
				var p3 = path_points[i+2]
				return catmull_rom_interpolate(p0, p1, p2, p3, t)
			else:
				return p1.lerp(p2, t)
		
		accumulated_distance += segment_length
	
	# 如果距离超出，返回最后一个点
	return path_points[-1] if path_points.size() > 0 else snake_body[0]

# Catmull-Rom样条插值，调整张力以形成宽松弧线
func catmull_rom_interpolate(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 = t * t
	var t3 = t2 * t
	# Catmull-Rom公式，调整张力（path_smoothing）使弧线更宽松
	var tension = 1.0 - path_smoothing  # 降低张力，弧线更圆润
	var a = (-tension * p0 + 2.0 * tension * p1 - tension * p2) / 2.0
	var b = (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) / 2.0
	var c = (-p0 + p2) / 2.0
	var d = p1
	return a * t3 + b * t2 + c * t + d

# 清理多余路径点
func 清理路径点(max_distance: float) -> void:
	var accumulated_distance: float = 0.0
	var keep_points = path_points.size()
	for i in range(path_points.size() - 1):
		var p1 = path_points[i]
		var p2 = path_points[i + 1]
		accumulated_distance += p1.distance_to(p2)
		if accumulated_distance > max_distance + base_segment_distance * 5:  # 增加缓冲
			keep_points = i + 5  # 多保留点支持宽松弧线
			break
	if keep_points < path_points.size():
		path_points.resize(keep_points)
