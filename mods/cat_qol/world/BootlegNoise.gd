extends Spatial

onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
onready var timer: Timer = $Timer

func _ready() -> void:
	reset_timer()

func reset_timer() -> void:
	timer.start(1 + randf())

func _on_Timer_timeout() -> void:
	if is_visible_in_tree():
		audio.play()
	reset_timer()
