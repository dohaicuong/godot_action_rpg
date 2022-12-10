extends KinematicBody2D

const ACCELERATION = 10
const MAX_SPEED = 100
const FRICTION = 10

enum {
	MOVE,
	ROLL,
	ATTACK,
}
var state = MOVE

onready var velocity = Vector2.ZERO
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get('parameters/playback')

func _ready():
	animationTree.active = true

func _physics_process(_delta):
	var input_vector = get_input_vector()
	animation_register(input_vector)

	match state:
		MOVE:
			movement_system(input_vector)
			if Input.is_action_just_pressed('attack'): state = ATTACK
		ROLL:
			pass
		ATTACK:
			attack_system()

func animation_register(input_vector):
	if input_vector != Vector2.ZERO:
		animationTree.set('parameters/idle/blend_position', input_vector)
		animationTree.set('parameters/run/blend_position', input_vector)
		animationTree.set('parameters/attack/blend_position', input_vector)
	else:
		pass

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
	velocity = move_and_slide(velocity)

func attack_system():
	velocity = Vector2.ZERO
	animationState.travel('attack')

func on_attack_animation_finished():
	state = MOVE
