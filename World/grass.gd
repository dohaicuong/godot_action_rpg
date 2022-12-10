extends Node2D

func _on_hurtbox_area_entered(area):
	create_destroyed_efffect()
	queue_free()

func create_destroyed_efffect():
	var grass_effect = load("res://Effects/grass_effect.tscn")
	var grassEffect = grass_effect.instance()
	
	var world = get_tree().current_scene
	
	world.add_child(grassEffect)
	grassEffect.global_position = global_position
