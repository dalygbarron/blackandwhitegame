extends Node

const SCENE_PUSH := "+"
const SCENE_POP := "-"
const SCENE_CHANGE := ">"
var _scenes := []
var _scene_positions := []
var _setup := false

# This should get called at the start of each overworld thing just to make sure that shit is set up.
func setup(name: String) -> void:
    if _setup: return
    _scenes.push_back(name)
    _setup = true

# Changes scenes, by either pushing, popping, or changing the last one. Should write better docs but
# I am fucking tired.
func change_scene(name: String, position := Vector2i()) -> void:
    var actual_name = name.substr(1)
    var new_position = Vector2i(-1, -1)
    if name.begins_with(SCENE_POP):
        new_position = _scene_positions.pop_back()
        _scenes.pop_back()
        actual_name = _scenes.back()
    elif name.begins_with(SCENE_PUSH):
        _scenes.push_back(actual_name)
        _scene_positions.push_back(position)
    elif name.begins_with(SCENE_CHANGE):
        _scenes[_scenes.size()] = actual_name
        # TODO: This is a little useless for overworld areas unless we implement
        # a way to do multiple entrances and exits.
    var new_scene = load("res://%s.tscn" % actual_name).instantiate()
    if new_scene is Overworld: new_scene.player_pos = new_position
    var tree := get_tree()
    tree.current_scene.queue_free()
    tree.root.add_child(new_scene)
    tree.current_scene = new_scene
