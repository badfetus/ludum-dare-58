extends VBoxContainer

func setTargetTimes(pbTime, devTime, goldTime, silverTime):
	var times = [pbTime, devTime, goldTime, silverTime]
	var targets = [$pb, $dev, $gold, $silver]
	var names = ["PB", "Dev", "Gold", "Silver"]
	
	for n in targets.size():
		targets[n].text = "[right]" + names[n] + ": " + str(int(times[n]))
