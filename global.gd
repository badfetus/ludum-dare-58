extends Node

var times = [-10000, -10000, -10000, -10000]
var medal = [0, 0, 0, 0]

var sens : float = 200.0
var musicVol: float = -10.0

var maxVol = 0.0
var minVol = -20
var volStep = 0.5

var minSensitivity = 20
var maxSensitivity = 2000


func updateTime(index: int, time: float) -> bool:
	if(time < times[index]):
		times[index] = time
		saveData()
		return true
	return false

func saveData():
	var save_game = FileAccess.open("user://savefile.save", FileAccess.WRITE)
	var dict = {
		"times" : times,
		"medals" : medal,
		"vol": musicVol,
		"sens": sens
	}
	var json_string = JSON.stringify(dict)
	print(json_string)
	save_game.store_line(json_string)

func _process(_delta):
	var save = false
	if Input.is_action_just_pressed("VolUp"): 
		musicVol += volStep
		musicVol = min(musicVol, maxVol)
	if Input.is_action_just_pressed("VolDown"): 
		musicVol -= volStep
		musicVol = max(musicVol, minVol)
		
	var volume = GlobalAudioStreamPlayer.volume_db
	if(volume == -80):
		volume = minVol
	if volume != musicVol:
		var effectiveVol = musicVol
		if(effectiveVol == minVol):
			effectiveVol = -80
		GlobalAudioStreamPlayer.volume_db = effectiveVol
		save = true
		
	if Input.is_action_just_pressed("SensUp"): 
		sens *= 1.25
		save = true
	if Input.is_action_just_pressed("SensDown"): 
		sens *= 0.8
		save = true
	
	sens = min(maxSensitivity, sens)
	sens = max(minSensitivity, sens)
	
	if save:
		saveData()
	
	if Input.is_action_just_pressed("FullScreen"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)


# Called when the node enters the scene tree for the first time.
func _ready():
	if not FileAccess.file_exists("user://savefile.save"):
		saveData()
		return # No save file

	var save_game = FileAccess.open("user://savefile.save", FileAccess.READ)
	var json_string = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK: #parse error
		saveData()
		return
	
	var dict : Dictionary = json.get_data()
	if(dict.has("times")):
		times = dict.get("times")
		medal = dict.get("medals")
		musicVol = dict.get("vol")
		sens = dict.get("sens")
		GlobalAudioStreamPlayer.volume_db = musicVol
		return
	else: #savefile missing data
		saveData() 
		return
		
