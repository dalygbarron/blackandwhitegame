extends Node

# Creates a timer node and adds it to this object which lets you use it.
# However, you need to remember to free this node manually because it is part of
# a global object.
func create_timer() -> Timer:
    var timer := Timer.new()
    timer.one_shot = true
    add_child(timer)
    return timer

# Waits on a timer for the given amount of seconds
func wait(timer: Timer, seconds: float) -> void:
    timer.wait_time = seconds
    timer.start()
    await timer.timeout
