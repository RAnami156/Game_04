extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	CHASE,
	RUN
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			CHASE:
				chase_state()
			RUN:
				run_state()

@onready var animPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false
var speed = 50
var damage = 10

func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))

func _on_player_position_update(player_pos):
	player = player_pos

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if state == CHASE:
		chase_state()
	if state == RUN:
		run_state()

	move_and_slide()

func _on_detector_body_entered(_body):
	chase = true
	state = CHASE  # Устанавливаем состояние в CHASE при входе в зону детектора

func _on_attack_range_body_entered(_body):
	state = ATTACK

func _on_detector_body_exited(body):
	chase = false
	velocity.x = 0
	state = IDLE
	
func idle_state():
	animPlayer.play("Idle")
	await get_tree().create_timer(1).timeout
	$AttackDirection/AttackRange/CollisionShape2D.disabled = false

	# Гриб остается в состоянии IDLE до входа в зону детектора
	if chase:
		state = CHASE

func attack_state():
	velocity.x = 0  # Останавливаем движение при атаке
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	$AttackDirection/AttackRange/CollisionShape2D.disabled = true
	state = IDLE

func chase_state():
	var direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
	state = RUN  # Устанавливаем состояние в RUN после определения направления

func run_state():
	var direction = (player - self.position).normalized()
	if chase == true:
		velocity.x = direction.x * speed
		animPlayer.play("Run")
	else:
		velocity.x = 0
		state = IDLE

	

func _on_hit_box_area_entered(area):
	Signals.emit_signal("enemy_attack", damage)
