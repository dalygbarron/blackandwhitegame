extends CanvasLayer
class_name HUD

# Adds an overlay texture to appear multiplied under the hud
func set_overlay(texture: Texture) -> void:
    $overlay.texture = texture

# Runs a nice battle for you to enjoy playing :) and doesn't return until it is over, at which point
# a true return value means win, false means lose.
func run_battle(filename: String) -> bool:
    var battle = load(filename).instantiate()
    $battleHolder.add_child(battle)
    $anim.play("enter_battle")
    return await battle.complete
