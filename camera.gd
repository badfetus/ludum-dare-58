extends Camera3D

var mouseDelta = Vector2()
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _process(delta):
	rotation_degrees.x -= mouseDelta.y * Global.sens * delta
	rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
	rotation_degrees.y -= mouseDelta.x * Global.sens * delta
	mouseDelta = Vector2()
