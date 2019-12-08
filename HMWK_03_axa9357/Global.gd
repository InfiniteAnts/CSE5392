extends Node

var level = 1
var exploded = false

func next_level():
    level += 1
	
func explosion():
	exploded = true