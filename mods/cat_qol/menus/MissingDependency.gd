extends "res://menus/BaseMenu.gd"

func grab_focus() -> void:
	.grab_focus()
	get_node("%QuitButton").grab_focus()

func _on_QuitButton_pressed() -> void:
	SceneManager.quit()
