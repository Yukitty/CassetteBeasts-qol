# Bare-minimum polyfill of cat_modutils.callbacks as used by cat_qol
extends Reference


# State
var _class_ready: Dictionary
var _scene_ready: Dictionary


func _init() -> void:
	DLC.get_tree().connect("node_added", self, "_on_node_added")


func _on_node_added(node: Node) -> void:
	var scene_path: String = node.filename
	var script_path: String

	if node.get_script():
		script_path = node.get_script().resource_path

	# Only connect callbacks once
	if node.get_meta("modutils_ready", false):
		return
	node.set_meta("modutils_ready", true)

	# Catch script nodes being instanced
	if not script_path.empty() and _class_ready.has(script_path):
		for callback in _class_ready[script_path]:
			node.connect("ready", callback.owner, callback.function, [node] + callback.binds, CONNECT_DEFERRED)

	# Catch specific scenes being instanced
	if _scene_ready.has(scene_path):
		for callback in _scene_ready[scene_path]:
			node.connect("ready", callback.owner, callback.function, [node] + callback.binds, CONNECT_DEFERRED)


# Class callbacks can be used to mass-edit many scenes that share a common ancestor
func connect_class_ready(script, callback_owner: Object, callback_function: String, callback_binds: Array = []) -> void:
	if script is Resource:
		script = script.resource_path
	assert(script is String)
	if not script in _class_ready:
		_class_ready[script] = []
	_class_ready[script].push_back({
		"owner": callback_owner,
		"function": callback_function,
		"binds": callback_binds,
		})


# Scene instance callbacks can be used to inject content into an existing scene
# when it spawns, even for sub-scenes that aren't typically the root.
func connect_scene_ready(scene: String, callback_owner: Object, callback_function: String, callback_binds: Array = []) -> void:
	if not scene in _scene_ready:
		_scene_ready[scene] = []
	_scene_ready[scene].push_back({
		"owner": callback_owner,
		"function": callback_function,
		"binds": callback_binds,
		})
