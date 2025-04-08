extends Node2D

# 状态枚举
enum State {
	IDLE,
	SEEKING,
	EATING
}

# 移动相关参数
@export var speed = 100.0  # 移动速度（像素/秒）
@export var segment_distance = 10.0  # 身体段之间的距离
var screen_width = 0
var screen_height = 0

var body_scene = preload("res://scene/enemy/snake/Body.tscn")  # 蛇身段场景
var food_scene = preload("res://scene/enemy/snake/Body.tscn")  # 食物场景

# 蛇的属性
var snake_body = []  # 存储蛇身体位置
var direction = Vector2.RIGHT  # 当前方向
var food = null
var current_state = State.IDLE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.map = self
	
	# 初始化蛇
	snake_body.append(Vector2(screen_width / 2, screen_height / 2))
	for i in range(3):
		snake_body.append(snake_body[-1] - Vector2(segment_distance, 0))
	
	for body in snake_body:
			print("Body: ", body)
	spawn_food()
	update_visuals()
	# 进入初始状态
	enter_state(State.SEEKING)
	pass # Replace with function body.


func _process(delta):
	# 根据当前状态执行逻辑
	match current_state:
		State.IDLE:
			process_idle(delta)
		State.SEEKING:
			process_seeking(delta)
		State.EATING:
			process_eating(delta)

# 状态处理函数
func process_idle(_delta):
	# 空闲状态：可以在这里添加重启逻辑
	pass

func process_seeking(delta):
	var head = snake_body[0]
	# 计算朝向食物的方向
	direction = (food.position - head).normalized()
	
	# 移动蛇头
	var velocity = direction * speed * delta
	var new_head = head + velocity
	
	# 边界循环
	new_head.x = wrapf(new_head.x, 0, screen_width)
	new_head.y = wrapf(new_head.y, 0, screen_height)
	snake_body[0] = new_head
	
	# 更新身体段位置
	for i in range(1, snake_body.size()):
		var prev_segment = snake_body[i - 1]
		var current_segment = snake_body[i]
		var segment_direction = (prev_segment - current_segment).normalized()
		var distance = (prev_segment - current_segment).length()
		
		if distance > segment_distance:
			snake_body[i] = prev_segment - segment_direction * segment_distance
	
	# 检查是否接近食物
	if new_head.distance_to(food.position) < 20.0:
		enter_state(State.EATING)
	
	update_visuals()

func process_eating(_delta):
	# 进食状态：增加身体长度并生成新食物
	snake_body.append(snake_body[-1])  # 添加新段到尾部
	spawn_food()
	enter_state(State.SEEKING)  # 立即返回寻食状态

# 状态切换函数
func enter_state(new_state):
	current_state = new_state
	match new_state:
		State.IDLE:
			print("Entered Idle State")
		State.SEEKING:
			print("Entered Seeking State")
		State.EATING:
			print("Entered Eating State")

# 生成食物
func spawn_food():
	if food:
		food.queue_free()
	
	food = food_scene.instantiate()
	food.position = Vector2(
		randf_range(0, screen_width),
		randf_range(0, screen_height)
	)
	add_child(food)

# 更新视觉表现
func update_visuals():
	# 清除旧的视觉节点
	for child in get_children():
		if child.is_in_group("snake_body"):
			child.queue_free()
	
	# 更新蛇的身体显示
	for i in snake_body.size():
		var body = body_scene.instantiate()
		body.position = snake_body[i]
		body.add_to_group("snake_body")
		if i == 0:
			body.modulate = Color.RED  # 头部标红
		add_child(body)

# 可选：调试用输入
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:  # 按 R 重置
			enter_state(State.IDLE)
			snake_body.clear()
			snake_body.append(Vector2(screen_width / 2, screen_height / 2))
			for i in range(3):
				snake_body.append(snake_body[-1] - Vector2(segment_distance, 0))
			spawn_food()
			update_visuals()
			enter_state(State.SEEKING)
			
			
func setCurActiveRange(w:int,h:int):
	screen_width = w
	screen_height = h
	
	
