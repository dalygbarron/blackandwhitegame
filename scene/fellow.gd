extends Dude

func action(overworld: Overworld) -> void:
    await overworld.say(name, "hello", load("res://pics/gun.png"))
    await overworld.hud.run_battle("res://battle/test.tscn")
    await overworld.say(name, "goodbye")
