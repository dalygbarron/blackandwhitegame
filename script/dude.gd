extends Sprite2D
class_name Dude

var tile_pos: Vector2: set = _set_tile_pos, get = _get_tile_pos
var flip: bool: set = _set_flip
var bounds := Rect2i(): set = _set_bounds
var _offset := Vector2()

func _ready() -> void:
    tile_pos = Vector2i(position / Overworld.TILE_SIZE)
    
func _set_tile_pos(new_tile_pos: Vector2) -> void:
    tile_pos = new_tile_pos
    position = new_tile_pos * Overworld.TILE_SIZE + _offset

func _get_tile_pos() -> Vector2:
    return Vector2i(tile_pos)
    
func _set_flip(new_flip: bool) -> void:
    flip = new_flip
    if flip:
        transform = Transform2D.FLIP_X
        _offset.x = Overworld.TILE_SIZE
    else:
        transform = Transform2D.IDENTITY
        _offset.x = 0
    position = tile_pos * Overworld.TILE_SIZE + _offset

func _set_bounds(rect: Rect2i) -> void:
    bounds = rect
    if $camera:
        rect = Rect2i(rect.position * Overworld.TILE_SIZE, rect.size * Overworld.TILE_SIZE)
        var delta := Vector2i(get_viewport().get_visible_rect().size) - rect.size
        if delta.x > 0:
            rect.position.x -= delta.x * 0.5
            rect.size.x += delta.x
        if delta.y > 0:
            rect.position.y -= delta.y * 0.5
            rect.size.y += delta.y
        $camera.limit_left = rect.position.x
        $camera.limit_top = rect.position.y
        $camera.limit_right = rect.end.x
        $camera.limit_bottom = rect.end.y

func flip_on(value: float) -> void:
    if value < 0: self.flip = true
    elif value > 0: self.flip = false

func action(overworld: Overworld) -> void:
    printerr("action needs to be implemented")
