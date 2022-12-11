extends Area2D

export var show_hit = true

const hit_effect = preload("res://Effects/hit_effect.tscn")

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

var invincible = false setget set_invincible
signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true: emit_signal("invincibility_started")
	else: emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func _on_Timer_timeout():
	self.invincible = false

func create_hit_effect():
	var effect = hit_effect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func _on_hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)

func _on_hurtbox_invincibility_ended():
	collisionShape.disabled = false
