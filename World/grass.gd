extends Node2D

const grass_effect = preload("res://Effects/grass_effect.tscn")

func _on_hurtbox_area_entered(_area):
	create_destroyed_efffect()
	queue_free()

func create_destroyed_efffect():
	var grassEffect = grass_effect.instance()
	var world = get_tree().current_scene
	
	world.add_child(grassEffect)
	grassEffect.global_position = global_position
