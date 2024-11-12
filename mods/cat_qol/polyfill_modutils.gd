# Bare-minimum polyfill of cat_modutils as used by cat_qol
extends Reference


var callbacks: Reference
var trans_patch: Reference
var settings: Reference


func _init() -> void:
	callbacks = load("res://mods/cat_qol/polyfill_modutils/callbacks.gd").new()
	trans_patch = load("res://mods/cat_qol/polyfill_modutils/trans_patch.gd").new()
	settings = load("res://mods/cat_qol/polyfill_modutils/settings.gd").new(self)
