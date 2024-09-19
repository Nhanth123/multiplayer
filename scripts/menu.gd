extends Control

@export var ip_line_edit: LineEdit
@export var status_label: Label


func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)

func _process(delta: float) -> void:
	pass

func _on_host_btn_pressed() -> void:
	Lobby.create_game()


func _on_join_btn_pressed() -> void:
	Lobby.join_game(ip_line_edit.text)
	status_label.text = "Connecting..."

func _on_start_btn_pressed() -> void:
	pass # Replace with function body.

func _on_connection_failed():
	status_label.text = "Failed to connect"
