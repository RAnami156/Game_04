extends CharacterBody2D

@onready var animPlayer = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null  
var speed = 100
var chase = false

enum {
	IDLE,
	RUN,
	CHASE
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			RUN:
				run_state()
			CHASE:
				chase_state()
				
func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))

func _on_player_position_update(player_pos):
	player = player_pos

func _physics_process(delta: float) -> void:
	if player != null:  # Проверка, что player определен
		var direction = (player - self.position).normalized()
		
		if not is_on_floor():
			velocity.y += gravity * delta
	
		if direction.x < 0:
			animPlayer.flip_h = true
		else:
			animPlayer.flip_h = false
		if state == CHASE:
			chase_state()
		if state == RUN:
			run_state()
		
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	chase = true
	state = CHASE

func _on_detector_body_exited(body: Node2D) -> void:
	chase = false
	
func idle_state():
	animPlayer.play("Idle")
	velocity.x = 0  # Персонаж не двигается в состоянии покоя
	if chase:
		state = CHASE

func run_state():
	var direction = (player - self.position).normalized()
	if chase:
		velocity.x = direction.x * speed
		animPlayer.play("Run")
	else:
		velocity.x = 0
		state = IDLE

func chase_state():
	var direction = (player - self.position).normalized()
	velocity.x = direction.x * speed  
	
	state = RUN
