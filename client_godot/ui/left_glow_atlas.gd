extends RefCounted

const FILE: String = "res://assets/ui/hall/left_glow.png"

const R: Dictionary = {
	"lgl_fizz": [2, 2, 50, 50], 
	"lgl_fizz_white": [54, 2, 50, 50], 
	"lgl_quest": [106, 2, 50, 50], 
	"lgl_quest_white": [158, 2, 50, 50], 
}

const FRAMES = 26

const BOB = [0.0, -0.25, -0.5, -0.75, -1.0, -1.25, -1.5, -1.75, -2.0, -2.25, -2.5, -2.75, -3.0, -2.75, -2.55, -2.3, -2.1, -1.85, -1.6, -1.4, -1.15, -0.9, -0.7, -0.45, -0.25, 0.0]

const GLOW = [0.0, 0.0431, 0.0824, 0.1255, 0.1686, 0.2078, 0.251, 0.2941, 0.3333, 0.3765, 0.4196, 0.4588, 0.502, 0.4627, 0.4235, 0.3843, 0.349, 0.3098, 0.2706, 0.2314, 0.1922, 0.1529, 0.1176, 0.0784, 0.0392, 0.0]

const SIDE = 50

const CELLS = {"col_quest": "lgl_quest", "main_livepoint": "lgl_fizz"}
