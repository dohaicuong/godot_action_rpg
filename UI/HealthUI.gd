extends Control

var max_hearts = 4 setget set_max_hearts
var hearts = 4 setget set_hearts

onready var heart_ui = $HeartUI
onready var heart_ui_empty = $HeartUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heart_ui != null:
		heart_ui.rect_size.x = hearts * 15

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heart_ui_empty != null:
		heart_ui_empty.rect_size.x = max_hearts * 15

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	# warning-ignore:return_value_discarded
	PlayerStats.connect("on_health_changed", self, "set_hearts")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("on_max_health_changed", self, "set_max_hearts")
