extends Node

@export var level_container: Node
@export var level_scene: PackedScene
@export var ui: Control
@export var ip_line_edit: LineEdit
@export var status_label: Label
@export var not_connected_hbox: HBoxContainer
@export var host_hbox: HBoxContainer


func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connection_to_server)

func _process(_delta: float) -> void:
	pass

func _on_host_btn_pressed() -> void:
	not_connected_hbox.hide()
	host_hbox.show()
	Lobby.create_game()
	status_label.text = "Hosting!"

func _on_join_btn_pressed() -> void:
	not_connected_hbox.hide()
	Lobby.join_game(ip_line_edit.text)
	status_label.text = "Connecting..."

func _on_start_btn_pressed() -> void:
	hide_menu.rpc()
	change_level.call_deferred(level_scene)

func _on_connection_failed():
	status_label.text = "Failed to connect"
	not_connected_hbox.show()

func _on_connection_to_server():
	status_label.text = "Connected!"

func change_level(scene):
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
	level_container.add_child(scene.instantiate())


@rpc("call_local", "authority", "reliable")
func hide_menu():
	ui.hide()
