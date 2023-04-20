extends Node2D
class_name Battle

signal complete(bool)

var kills_to_win: int: set = _set_kills_to_win

func _ready() -> void:
    for child in get_children():
        if child is Fighter:
            child.battle = self

func _set_kills_to_win(kills: int) -> void:
    kills_to_win = kills
    if kills == 0: complete.emit(true)

class Fighter extends Node2D:
    var battle: Battle
