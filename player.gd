extends RigidBody3D

class_name Player

@onready
var camera: Camera3D = $Camera3D

var mouseDelta = Vector2()
var holdDuration = 0
var on_floor: bool = false # now global!
var currTime = 0.0
var lastTimeOnFloor = -100
var lastJump = -100
var lastShot = -100

var lastIce = -100

var shotCD = 0.5
var points: int = 1000

var item = 0
var itemTexts = ["No item", "Dash", "Jump"]
var colors = [Color.WHITE, Color.RED, Color.YELLOW]

var reached = [false, false, false, false]

var stoppedJump = true

var finished = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	var silver = get_parent().get_meta("Silver")
	var gold = get_parent().get_meta("Gold")
	var dev = get_parent().get_meta("Dev")
	var levelIdx: int = get_parent().get_meta("level") - 1
	var pb = Global.times[levelIdx]
	find_child("VBoxContainer").setTargetTimes(pb, dev, gold, silver)

func _physics_process(delta: float) -> void:
	currTime = currTime + delta

	updateItemBox()
	handlePoints()
	controlPlayer(delta)
	applyDrag()

func updateItemBox():
	var itemBox = find_child("item")
	itemBox.color = colors[item]
	var label: Label = itemBox.get_child(0)
	label.text = itemTexts[item]

func handlePoints():
	if !finished:
		points -= 1
	
func controlPlayer(delta):
	handleUI()
	if position.y < -10:
		get_parent().restart()
	walk()
	jump(delta)

func handleUI():
	if Input.is_action_just_pressed("Controls"):
		var controlUI = find_child("Controls")
		controlUI.visible = !controlUI.visible

func _input(event: InputEvent) -> void:
	if finished:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			points -= 50
			$Camera3D/RayCast3D.force_raycast_update()
			if(!$Camera3D/RayCast3D.is_colliding()):
				return
			var collider = $Camera3D/RayCast3D.get_collider()
			if collider is Pickup:
				collider.collect()
		elif event.button_index == MOUSE_BUTTON_RIGHT and item != 0:
			useItem()

func useItem():
	match item:
		1:
			var camRot = camera.rotation
			var horizontalRotation = camRot.y
	
			var impulse = Vector3()
			impulse.y = getNormalisedAngle(camRot.x)
			impulse.y = impulse.y * 30 * 1
			impulse.x = sin(horizontalRotation) * 30 * 1 * abs(cos(getNormalisedAngle(camRot.x)))
			impulse.z = cos(horizontalRotation) * 30 * 1 * abs(cos(getNormalisedAngle(camRot.x)))
			apply_central_impulse(impulse)
		2:
			var force = 20
			if(linear_velocity.y < 0):
				force += -linear_velocity.y * mass
			apply_central_impulse(Vector3(0, force, 0))
	item = 0

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
	if(currTime - lastIce < 0.25):
		drag *= 0.25
	apply_central_impulse(drag)

var maxJump = 0.2
var jumpForce = 40
var initialJumpMult = 25
func jump(delta):	
	if on_floor and Input.is_action_pressed("Jump") and (currTime - lastJump > leeway * 1.2):
		apply_central_impulse(Vector3(0, jumpForce * delta * initialJumpMult, 0))
		stoppedJump = false
		lastJump = currTime
	elif !stoppedJump:
		apply_central_impulse(Vector3(0, jumpForce * delta, 0))
		if(currTime - lastJump >= maxJump):
			stoppedJump = true
		if(!Input.is_action_pressed("Jump")):
			stoppedJump = true
func getNormalisedAngle(angle: float) -> float:
	var normAngle = fmod(angle, (PI * 2))
	#if(normAngle > PI):
		#normAngle -= 2 * PI
	return normAngle
				
var leeway = 0.25

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if finished:
		return
	on_floor = false
	
	var i := 0
	while i < state.get_contact_count():
		var object = state.get_contact_collider_object(i)
		if object is Pickup:
			i+=1
			object.collect()
			continue
		if object is Goal:
			finished = true
			var levelIdx: int = get_parent().get_meta("level") - 1
			var oldPb = Global.times[levelIdx]
			
			if(points > oldPb):
				Global.times[levelIdx] = points
				Global.medal[levelIdx] = 1
				if(points >= get_parent().get_meta("Silver")): #offset by 0.001 so that if the visible decimals equal you get it
					Global.medal[levelIdx] = 2
				if(points >= get_parent().get_meta("Gold")):
					Global.medal[levelIdx] = 3
				if(points >= get_parent().get_meta("Dev")):
					Global.medal[levelIdx] = 4
				Global.saveData()
				$Camera3D/Control.celebrate("New PB!")
			else:
				$Camera3D/Control.celebrate("Win!")
		if object is IceFloor:
			lastIce = currTime
		if object is JumpFloor:
			apply_central_impulse(Vector3(0, 40, 0))
			lastJump = currTime
			
		var normal := state.get_contact_local_normal(i)
		var this_contact_on_floor = normal.dot(Vector3.UP) > 0.5

		# boolean math, will stay true if any one contact is on floor
		on_floor = on_floor or this_contact_on_floor
		i += 1
	if (on_floor):
		lastTimeOnFloor = currTime
	elif (currTime - lastTimeOnFloor < leeway):
		on_floor = true
		
	if(on_floor and currTime - lastTimeOnFloor > leeway):
		stoppedJump = true
