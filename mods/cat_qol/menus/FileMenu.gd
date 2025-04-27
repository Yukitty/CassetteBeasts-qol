extends "res://menus/title/FileMenu.gd"


var _cat_qol_extra_files_ready: bool = true


func _ready() -> void:
	# Some constants.
	var file_button_scene: PackedScene = load("res://menus/title/FileButton.tscn")
	var regex := RegEx.new()
	regex.compile("^user://file(\\d+).json")
	var regexmatch: RegExMatch
	var highest_base_button: int = 1
	var file_buttons_dict: Dictionary = {}
	var last_file: FileButton

	# First, track the buttons for existing files
	var index: int
	for child in file_button_container.get_children():
		if child is FileButton:
			regexmatch = regex.search(child.file_path)
			if regexmatch:
				index = int(regexmatch.strings[1])
				file_buttons_dict[index] = child
				last_file = child
				if index > highest_base_button:
					highest_base_button = index

	# Instance buttons for extra files that exist beyond the first 3.
	var dir := Directory.new()
	var file_button: FileButton
	if dir.open("user://") == OK and dir.list_dir_begin(true, true) == OK:
		var file_name: String = dir.get_next()
		while not file_name.empty():
			regexmatch = regex.search("user://" + file_name)
			file_name = dir.get_next()
			if regexmatch:
				index = int(regexmatch.strings[1])
				if index in file_buttons_dict:
					continue
				if SaveSystem.storage.exists(regexmatch.strings[0]):
					file_button = file_button_scene.instance()
					file_button.name = "FileButton" + regexmatch.strings[1]
					file_button.file_path = regexmatch.strings[0]
					file_buttons_dict[index] = file_button

	# Add a button for the first available empty file if needed
	var empty: int = 1
	while true:
		if not empty in file_buttons_dict or not SaveSystem.storage.exists(file_buttons_dict[empty].file_path):
			break
		empty += 1
	if empty > highest_base_button:
		file_button = file_button_scene.instance()
		file_button.name = "FileButton%d" % empty
		file_button.file_path = "user://file%d.json" % empty
		file_buttons_dict[empty] = file_button

	# Sort buttons by file index to begin with
	# while adding them to the scene.
	# This is because the raw Directory may be sorted differently by the OS.
	var indices: Array = file_buttons_dict.keys()
	indices.sort()

	# Add (up to) the first 10 files
	for i in indices.slice(0, 9):
		if i <= highest_base_button:
			# Add callback to default buttons
			file_button = file_buttons_dict[i]
			file_button.connect("state_changed", self, "_cat_qol_check_file_states", [], CONNECT_ONESHOT)
			continue
		file_button = file_buttons_dict[i]
		file_button_container.add_child_below_node(last_file, file_button)
		last_file = file_button
		file_button.connect("focus_entered", self, "_on_file_focused", [file_button])
		file_button.connect("state_changed", self, "_cat_qol_check_file_states", [], CONNECT_ONESHOT)
		file_button.disabled = true

	# Continue adding files until we run out..!
	var block: int = 10
	while block < indices.size():
		_cat_qol_extra_files_ready = false
		yield (Co.wait(0.1), "completed")
		for i in indices.slice(block, block + 9):
			file_button = file_buttons_dict[i]
			file_button_container.add_child_below_node(last_file, file_button)
			last_file = file_button
			file_button.connect("focus_entered", self, "_on_file_focused", [file_button])
			file_button.connect("state_changed", self, "_cat_qol_check_file_states", [], CONNECT_ONESHOT)
			file_button.disabled = true
		block += 10

	# Done adding buttons, now we wait for them to load...
	assert(file_button_container.get_child(0) == file_buttons_dict[1])
	_cat_qol_extra_files_ready = true


func _cat_qol_check_file_states() -> void:
	# Check if all file buttons have finished loading
	if not _cat_qol_extra_files_ready:
		return
	for button in file_button_container.get_children():
		if button is FileButton and button.state == FileButton.State.LOADING:
			return
	# All buttons accounted for!
	# Now we can sort by file date.
	if DLC.mods_by_id.cat_qol.setting_sort_save_files:
		_cat_qol_sort_files()
	file_button_container.setup_focus()
	Controls.set_disabled(self, false)
	grab_focus()


func _cat_qol_sort_files() -> void:
	file_buttons = file_button_container.get_children()
	for node in file_buttons:
		if not node is FileButton:
			file_buttons.erase(node)
	file_buttons.sort_custom(self, "_cat_qol_sort_file_buttons_by_saved_datetime")
	var i: int = 0
	for file_button in file_buttons:
		file_button_container.move_child(file_button, i)
		i += 1


func _cat_qol_sort_file_buttons_by_saved_datetime(a: FileButton, b: FileButton) -> bool:
	assert("saved_datetime" in a and "saved_datetime" in b)
	if a.state == FileButton.State.EMPTY:
		return false
	elif b.state == FileButton.State.EMPTY:
		return true
	return b.saved_datetime < a.saved_datetime
