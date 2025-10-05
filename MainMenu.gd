extends ColorRect

@onready var Global = get_node("/root/Global")
var arr = []
var callArr = [loadLevel1, loadLevel2, loadLevel3, loadLevel4]

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	process_mode = Node.PROCESS_MODE_ALWAYS
	arr.resize(4)
	for i in 4:
		var lvl = i + 1
		arr[i] = find_child(str(lvl)) 
		arr[i].text = str(lvl)
		arr[i].pressed.connect(callArr[i])
		var _button: Button = arr[i]
		print(arr[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var awards = ["🏆","🥇","🥈","🥉"]
	var levelsCompleted = 0
	var totalTime = int(0)
	
	for i in 4:
		if(Global.medal[i] > 0):
			arr[i].text = awards[4 - Global.medal[i]]
			levelsCompleted += 1
			totalTime += Global.times[i]
		
		var button: Button = arr[i]
		button.get_child(0).text = "[center]" + str(int(Global.times[i]))
		
	$LevelLabel.text = "Levels completed: " + str(levelsCompleted)
	$TimeLabel.text = "[right]Total score: " + str(int(totalTime))

func loadLevel(lvl):
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Level" + str(lvl) + ".tscn")
	
func loadLevel1():
	loadLevel(1)
func loadLevel2():
	loadLevel(2)
func loadLevel3():
	loadLevel(3)
func loadLevel4():
	loadLevel(4)
