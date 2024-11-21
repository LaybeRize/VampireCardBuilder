extends Node2D

func get_normal_trollface() -> Node2D:
	return $TrollFace.duplicate()
	
func get_rotating_amogus() -> Node2D:
	return $RotatingAmogus.duplicate()

func get_moving_stuff() -> Node2D:
	return $MovingStuff.duplicate()

func get_clock() -> Node2D:
	return $RotatingClock.duplicate()
