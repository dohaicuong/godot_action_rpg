extends KinematicBody2D

const enemy_deadth_effect = preload("res://Effects/enemy_death_effect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 40
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE,
}
var state = IDLE

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
onready var stats = $stats
onready var playerDetectionArea = $player_detection_area
onready var sprite = $bat
onready var hurtbox = $hurtbox

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		WANDER: pass
		CHASE:
			var player = playerDetectionArea.player
			if player != null:
				var to_player_direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(to_player_direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionArea.can_see_player():
		state = CHASE

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()

func _on_stats_on_no_health():
	queue_free()
	
	var enemyDeathEffect = enemy_deadth_effect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = global_position
