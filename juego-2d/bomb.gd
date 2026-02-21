extends Area2D

signal exploded
signal expired

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer

func _ready():
	sprite.play("tick")
	timer.start()
	add_to_group("bomb")
	pass

func _on_timer_timeout():
	# Si nadie la tomó en 3 segundos
	expired.emit()  # IMPORTANTE
	queue_free()
	pass
#func _on_body_entered(body):
#	print("Detectado:", body.name)
#	if body.is_in_group("player"):
#		explode()
#	pass
	
func explode():
	timer.stop()
	sprite.play("explode")
	await sprite.animation_finished
	exploded.emit()
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	print("AREA DETECTADA:", area.name)
	if area.is_in_group("player"):
		explode()
	pass # Replace with function body.
