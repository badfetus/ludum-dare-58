extends RigidBody3D

@onready
var camera: Camera3D = $Camera3D

var mouseDelta = Vector2()
var holdDuration = 0
var on_floor: bool = false # now global!
var currTime = 0
var lastTimeOnFloor = -100
var lastJump = -100

var reached = [false, false, false, false]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	currTime = currTime + delta
	controlPlayer()
	applyDrag()
	
func controlPlayer():
	walk()
	jump()
	
func handleCheats():
	if Input.is_action_just_pressed("Cheat"): 
			var camRot = camera.rotation
			var horizontalRotation = camRot.y
	
			var impulse = Vector3()
			impulse.y = getNormalisedAngle(camRot.x)
			impulse.y = impulse.y * 30 * 1
			impulse.x = sin(horizontalRotation) * 30 * 1 * abs(cos(getNormalisedAngle(camRot.x)))
			impulse.z = cos(horizontalRotation) * 30 * 1 * abs(cos(getNormalisedAngle(camRot.x)))
			apply_central_impulse(impulse)
	if Input.is_action_just_pressed("Cheat2"): 
		apply_central_impulse(linear_velocity * -1)


func _input(_event: InputEvent) -> void:
	pass

func walk():
	var camRot = camera.rotation
	var horizontalRotation = camRot.y
	
	var walkInput = Vector3()
	if Input.is_action_pressed("Forward"):
		walkInput.x += 1
	if Input.is_action_pressed("Back"):
		walkInput.x -= 1
	if Input.is_action_pressed("Right"):
		walkInput.z += 1
	if Input.is_action_pressed("Left"):
		walkInput.z -= 1
	
	walkInput = walkInput.normalized()
	var walkOutput = Vector3()

	walkOutput.x = sin(horizontalRotation) * walkInput.x - cos(horizontalRotation) * walkInput.z
	walkOutput.z = cos(horizontalRotation) * walkInput.x + sin(horizontalRotation) * walkInput.z
	
	walkOutput *= 0.5
	if(!on_floor):
		walkOutput *= 0.5
	apply_central_impulse(walkOutput)
	
func applyDrag():
	var dragCoeff = linear_velocity.abs() * linear_velocity.abs() * 0.001
	var drag = linear_velocity.normalized() * dragCoeff * -1
	#drag.y = 0
	apply_central_impulse(drag)


func jump():	
	if on_floor and Input.is_action_pressed("Jump") and (currTime - lastJump > 0.25):
		apply_central_impulse(Vector3(0, 20, 0))
		lastJump = currTime

func getNormalisedAngle(angle: float) -> float:
	var normAngle = fmod(angle, (PI * 2))
	if(normAngle > PI):
		normAngle -= 2 * PI
	return normAngle

func _on_body_entered(body):
	if(body.name.begins_with("CP")):
		var index = int(body.name.substr(2)) - 1
		#Global.updateTime(index, currTime)
		if(!reached[index]):
			reached[index] = true
			$Camera3D/Control.celebrate(index)
		
		
var leeway = 0.1

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	on_floor = false
	
	var i := 0
	while i < state.get_contact_count():
		var normal := state.get_contact_local_normal(i)
		var this_contact_on_floor = normal.dot(Vector3.UP) > 0.5

		# boolean math, will stay true if any one contact is on floor
		on_floor = on_floor or this_contact_on_floor
		i += 1
	if (on_floor):
		lastTimeOnFloor = currTime
	elif (currTime - lastTimeOnFloor < leeway):
		on_floor = true
