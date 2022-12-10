extends Node

export var max_health = 6 setget set_max_health
var health = max_health setget set_health

signal on_no_health
signal on_health_changed(value)
signal on_max_health_changed(value)

func set_health(value):
	health = value
	emit_signal("on_health_changed", health)
	if health <= 0: emit_signal("on_no_health")

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("on_max_health_changed", max_health)

func _ready():
	self.health = max_health
