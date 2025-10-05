extends Control

@onready var player = get_parent().get_parent()

var celebrating = false
var celebStarted = 0

func _process(_delta: float) -> void:
	var currTime = player.currTime
	$Label.text = "Score: " + str(player.points)
		
	var globalTimes : String = "[right]"
	for i in Global.times.size():
		var time = float(Global.times[i])
		if(time == float(200000)):
			break
		
	$RichTextLabel.text = globalTimes
	
	if(celebrating):
		if(player.currTime - celebStarted > 3):
			celebrating = false
			$Celebrate.text = "R to retry\nQ to main menu"
			

func celebrate(text):
	celebStarted = player.currTime
	celebrating = true
	$Celebrate.text = text
