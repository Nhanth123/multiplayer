extends Node2D


@export var player_scene : PackedScene
@export var players_container: Node2D
@export var spawn_points: Array[Node2D]

var next_spawn_point_index = 0

func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	for id in multiplayer.get_peers():
		print(id)
		add_player(id)
		
	add_player(1)

func _exit_tree() -> void:
	if multiplayer.multiplayer_peer == null:
		return
	
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_disconnected.disconnect(delete_player)
	

func add_player(id):
	var player_instance = player_scene.instantiate()
	player_instance.position = get_spawn_point()
	player_instance.name = str(id)
	players_container.add_child(player_instance)

func delete_player(id):
	if not players_container.has_node(str(id)):
		return
	
	players_container.get_node(str(id)).queue_free()

func get_spawn_point():
	var spawn_point = spawn_points[next_spawn_point_index].position
	next_spawn_point_index += 1
	if next_spawn_point_index >= len(spawn_points):
		next_spawn_point_index = 0
	return spawn_point


func _on_pressure_plate_toggle(_state: Variant) -> void:
	pass # Replace with function body.
