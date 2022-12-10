extends KinematicBody2D

const ACCELERATION = 10
const MAX_SPEED = 100
const ROLL_SPEED = 125
const FRICTION = 10

enum {
	MOVE,
	ROLL,
	ATTACK,
}
var state = MOVE
var stats = PlayerStats

onready var velocity = Vector2.ZERO
onready var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get('parameters/playback')
onready var swordHitbox = $hitbox_pivot/sword_hitbox
onready var hurtbox = $hurtbox

func _ready():
	stats.connect("on_no_health", self, "queue_free")
	animationTree.active = true

func _physics_process(_delta):
	var input_vector = get_input_vector()
	animation_register(input_vector)
	sword_hitbox_vector_system(input_vector)

	match state:
		MOVE:
			movement_system(input_vector)
			if Input.is_action_just_pressed('attack'): state = ATTACK
			if Input.is_action_just_pressed("roll"): state = ROLL
		ROLL:
			roll_system(input_vector)
		ATTACK:
			attack_system()

	velocity = move_and_slide(velocity)

func animation_register(input_vector):
	if input_vector != Vector2.ZERO:
		animationTree.set('parameters/idle/blend_position', input_vector)
		animationTree.set('parameters/run/blend_position', input_vector)
		animationTree.set('parameters/attack/blend_position', input_vector)
		animationTree.set('parameters/roll/blend_position', input_vector)

func sword_hitbox_vector_system(input_vector):
	if input_vector != Vector2.ZERO:
		swordHitbox.knockback_vector = input_vector

func get_input_vector():
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	
	return input_vector

func movement_system(input_vector):
	if input_vector != Vector2.ZERO:
		animationState.travel('run')
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		animationState.travel('idle')
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)

func attack_system():
	velocity = Vector2.ZERO
	animationState.travel('attack')

func on_attack_animation_finished():
	state = MOVE

func roll_system(input_vector):
	#if input_vector != Vector2.ZERO:
	roll_vector = input_vector
	
	velocity = roll_vector * ROLL_SPEED
	animationState.travel('roll')

func on_roll_animation_finished():
	state = MOVE

func _on_hurtbox_area_entered(_area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
