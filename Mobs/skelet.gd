extends CharacterBody2D

@onready var animPlayer = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null  # Инициализируем player как null

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
		
		move_and_slide()
