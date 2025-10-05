extends CharacterBody3D
class_name Pickup

@onready var player: Player = get_parent().get_parent().get_node("Player")

var startY
var currTime = 0
var color = "[color=white]"

func _ready() -> void:
	startY = position.y

func _physics_process(delta: float) -> void:
	currTime += delta
	position.y = startY + sin(currTime * 2) * 0.5

func collect():
	applyEffect()
	queue_free()
	
func applyEffect():
	player.points += 500
