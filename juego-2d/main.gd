extends Node

@export var mob_scene: PackedScene
@export var bomb_scene: PackedScene
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over():
	$Music.stop()
	$DeathSound.play() 
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	pass

func new_game():
	$Music.play()
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	pass


func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	pass # Replace with function body.


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)
	pass # Replace with function body.


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	pass # Replace with function body.


func _on_bomb_timer_timeout() -> void:
	
	if get_tree().get_nodes_in_group("bomb").size() > 0:
		return

	var bomb = bomb_scene.instantiate()

	var screen_size = get_viewport().get_visible_rect().size
	bomb.position = Vector2(
		randf_range(0, screen_size.x),
		randf_range(0, screen_size.y)
	)

	add_child(bomb)

	bomb.exploded.connect(_on_bomb_exploded)
	bomb.expired.connect(_on_bomb_expired)

	$BombTimer.stop()
	
	pass # Replace with function body.

func _on_bomb_exploded():
	print("EXPLOTO")
	get_tree().call_group("mobs", "queue_free")

	# Esperar 5 segundos antes de permitir otra bomba
	await get_tree().create_timer(5).timeout
	$BombTimer.start()

func _on_bomb_expired():
	print("EXPIRÓ")
	await get_tree().create_timer(5).timeout
	$BombTimer.start()
