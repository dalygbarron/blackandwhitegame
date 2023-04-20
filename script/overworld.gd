extends TileMap
class_name Overworld

const START_TILE := Vector2i(6, 7)
const TILE_SIZE := 64
const PLAYER_MOVE_TIME := 0.18
const BASE_LAYER := 0
const META_LAYER := 1
const TRANSITION_TIME := 0.2
@export var overlay_texture: Texture
@onready var hud_scene = preload("res://scene/overworld_hud.tscn")
@onready var player_scene = preload("res://scene/overworld_player.tscn")
@onready var dialogue_scene = preload("res://scene/dialogue.tscn")
var player: Dude
var player_pos := Vector2i(-1, -1)
var player_moving := true
var timer := Util.create_timer()
var dude_holder := Node2D.new()
var hud: HUD
var _bounds: Rect2i

func _init():
    modulate = Color.TRANSPARENT

func _ready():
    player = player_scene.instantiate()
    for child in get_children():
        remove_child(child)
        dude_holder.add_child(child)
    add_child(dude_holder)
    add_child(player)
    hud = hud_scene.instantiate()
    hud.set_overlay(overlay_texture)
    add_child(hud)
    if player_pos.x < 0 or player_pos.y < 0:
        var start := get_used_cells_by_id(META_LAYER, -1, START_TILE)[0]
        player_pos = start
    player.tile_pos = player_pos
    _bounds = get_used_rect()
    player.bounds = _bounds
    set_layer_modulate(META_LAYER, Color.TRANSPARENT)
    State.setup(scene_file_path.substr(6).get_basename())
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, TRANSITION_TIME)
    await tween.finished
    player_moving = false

func _notification(notif):
    if notif == NOTIFICATION_PREDELETE: timer.queue_free()
    
func _process(delta):
    var shift = Input.is_action_pressed("focus")
    if Input.is_action_pressed("ui_up"): _move_player(Vector2i(0, -1), shift)
    elif Input.is_action_pressed("ui_down"): _move_player(Vector2i(0, 1), shift)
    elif Input.is_action_pressed("ui_left"): _move_player(Vector2i(-1, 0), shift)
    elif Input.is_action_pressed("ui_right"): _move_player(Vector2i(1, 0), shift)
    
# Asynchronously moves the player by a given number of tiles and blocks itself from being
# run twice at the same time.
func _move_player(direction: Vector2i, shift := false) -> void:
    if player_moving: return
    player_moving = true
    var tween = create_tween()
    var player_pos := Vector2i(player.tile_pos)
    var player_future_pos := player_pos + direction
    var encounter_chance := 0.04
    if _bounds.has_point(player_future_pos):
        var future_data = get_cell_tile_data(BASE_LAYER, player_future_pos)
        if future_data:
            if future_data.get_custom_data("solid"):
                player_moving = false
                tween.kill()
                return
            encounter_chance += future_data.get_custom_data("encounter")
    for dude in dude_holder.get_children():
        if player_future_pos == Vector2i(dude.tile_pos) and not shift:
            tween.kill()
            await dude.action(self)
            player_moving = false
            return
        else:
            var dude_direction := _random_direction()
            var future_pos := Vector2i(dude.tile_pos) + dude_direction
            if player_future_pos == Vector2i(dude.tile_pos) and shift: future_pos = player_pos
            elif future_pos == player_future_pos or future_pos == player_pos: continue
            if _bounds.has_point(future_pos):
                var future_data = get_cell_tile_data(BASE_LAYER, future_pos)
                if future_data and future_data.get_custom_data("solid"): continue
            else: continue
            dude.flip_on(dude_direction.x)
            tween.parallel().tween_property(dude, "tile_pos", Vector2(future_pos), PLAYER_MOVE_TIME)
    player.flip_on(direction.x)
    tween.parallel().tween_property(
        player,
        "tile_pos",
        Vector2(player_future_pos),
        PLAYER_MOVE_TIME
    )
    await tween.finished
    if _bounds.has_point(player_future_pos):
        var transfer_data := get_cell_tile_data(META_LAYER, player_future_pos)
        if transfer_data and transfer_data.get_custom_data("transfer"):
            await _transfer(transfer_data.get_custom_data("transfer"))
        elif randf() < encounter_chance:
            print("encounter!!")
    else: await _transfer("-")
    player_moving = false

# Changes to a different overworld or adventure scene based on the given string.
func _transfer(to: String) -> void:
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color.TRANSPARENT, TRANSITION_TIME)
    await tween.finished
    State.change_scene(to, Vector2i(player.tile_pos))

# Just generates a random direction for dudes to move in they are bored.
func _random_direction() -> Vector2i:
    match randi() % 4:
        0: return Vector2i(-1, 0)
        1: return Vector2i(1, 0)
        2: return Vector2i(0, -1)
    return Vector2i(0, 1)

# Prints some text to the screen in a text box and waits for the user to press a button so it
# closes.
func say(title: String, text: String, pic: Texture = null) -> void:
    var dialogue = dialogue_scene.instantiate()
    dialogue.title = title
    dialogue.text = text
    dialogue.pic = pic
    hud.add_child(dialogue)
    await dialogue.complete
