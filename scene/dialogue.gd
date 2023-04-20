extends GUI

var title: String: set = _set_title
var text: String: set = _set_text
var pic: Texture: set = _set_pic

func _set_title(title: String) -> void:
    $vbox/title.text = title

func _set_text(text: String) -> void:
    $vbox/text.text = text

func _set_pic(pic: Texture) -> void:
    $vbox/pic.texture = pic

func _process(delta):
    if Input.is_action_just_pressed("fire"):
        queue_free()
        complete.emit()
