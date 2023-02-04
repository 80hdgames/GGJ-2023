class_name Constants 

const GAME_VERSION = "v1.0"

const PLAYER_NODE_GROUP = "Player"
const HUD_NODE_GROUP = "HUD"
const PICKUP_NODE_GROUP = "Veggie"

const TITLE_SCREEN_SCENE = "res://Scenes/Start.tscn"
const PLAYER_SETUP_SCENE = "res://Scenes/PlayerSetup.tscn"
const GAME_SCENE = "res://Scenes/Game.tscn"


const GAMEPAD_DEVICE_ID_ADD = 2 # Desktop players snag the first 2 indexes

const PLAYER_COLORS :Array[Color] = [
	Color.RED,
	Color.DODGER_BLUE,
	Color.GREEN,
	Color.YELLOW,
	Color.PURPLE,
	Color.CYAN,
	Color.WHITE,
	Color.CHOCOLATE
]
const PLAYER_START_POSITIONS = [
	Vector3.ZERO,
	Vector3.FORWARD * 2,
	Vector3.BACK * 2,
	Vector3.LEFT * 2,
	Vector3.RIGHT * 2,
	Vector3.FORWARD * 4,
	Vector3.BACK * 4,
	Vector3.LEFT * 4,
]
