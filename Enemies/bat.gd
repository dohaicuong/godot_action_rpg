extends KinematicBody2D

const enemy_deadth_effect = preload("res://Effects/enemy_death_effect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 40
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

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
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0: update_wander()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0: update_wander()
			accelerate_toward(delta, wanderController.target_position)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
			var player = playerDetectionArea.player
			if player != null:
				accelerate_toward(delta, player.global_position)
			else:
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func accelerate_toward(delta, point):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionArea.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()

func _on_stats_on_no_health():
	queue_free()
	
	var enemyDeathEffect = enemy_deadth_effect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = global_position
