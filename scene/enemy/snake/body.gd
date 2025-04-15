extends Node2D
class_name BossSnakeBody


var enemy_data:EnemyBossBodyData



func _ready():
	enemy_data = EnemyBossBodyData.new()
	
	enemy_data.on_hit.connect(on_hit)
	enemy_data.on_death.connect(on_death)
	
	pass

func on_hit(_damage):
	#current_state = State.HIT
	#
	#Game.show_label(self,'-%s' %_damage)
	#hit_audio.play()
	#
	#anim.play("hit")
	#await anim.animation_finished
	#current_state = State.IDLE
	pass


func on_death():
	pass
	#if current_state == State.DEATH:
		#return
	#current_state = State.DEATH
	#coll.call_deferred("set_disabled",true)
	#shadow.hide()
	#anim.play('death')
	#await anim.animation_finished
	#
	#EnemyManager.handleEnemyCounts.emit(-1)
	#queue_free()

	
