extends Node2D
class_name BaseWeapon

const _pre_bullet = preload("res://scene/bullet/BaseBullet.tscn")

@export var bullets_per_magazine = 30  # 每弹夹子弹数
@export var max_magazine_counts = 5 # 最大弹夹数量
@export var cur_total_bullets_counts = 150  # 当前子弹数量
@export var weapon_reload_rof= 0.42 # 武器换弹速度,数值越大换弹速度越慢

@export var damage = 5
@export var weapon_rof = 0.2
@export var weapon_name = '默认枪械'

var player:Player


@onready var sprite = $Sprite2D
@onready var bullet_point = $BulletPoint

var current_rof_tick = 0

var current_bullet_count_in_single_magazine = 0 # 在当前弹夹中所有的子弹数量
var current_magazine_counts = 0 # 当前的弹夹数量

func shoot():
	var instance = _pre_bullet.instantiate()
	instance.global_position = bullet_point.global_position
	instance.dir = global_position.direction_to(get_global_mouse_position())
	
	#instance.current_weapon = self 
	get_tree().root.add_child(instance)
	
	#current_bullet_count_in_single_magazine -=1
	#weapon_anim()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	# 更新节流计时器
	current_rof_tick +=delta
	if Input.is_action_pressed("fire") and current_rof_tick >= weapon_rof:
			# 计时器归零时执行操作并重置计时器
		shoot()	
		current_rof_tick=0
