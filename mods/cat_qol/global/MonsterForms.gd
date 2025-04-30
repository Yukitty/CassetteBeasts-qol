extends "res://global/MonsterForms.gd"


func reload() -> void:
	.reload()

	# Group unnumbered monster forms by evolution tree.
	# My brain must be fried, because I can't think of a way to do this
	# properly inside of _sort_forms_by_index, instead of as an extra step...
	var i: int = 0
	while i < by_index.size():
		var form: MonsterForm = by_index[i]
		i += 1
		if form.bestiary_index < 0:
			for cond in form.evolutions:
				if cond.evolved_form and cond.evolved_form.bestiary_index < 0:
					by_index.erase(cond.evolved_form)
					by_index.insert(i, cond.evolved_form)
					i += 1


# Additional sorting for non-indexed monsters.
func _sort_forms_by_index(a: MonsterForm, b: MonsterForm) -> bool:
	# Start with vanilla sort, if sorting by category or index is actually possible.
	if a.bestiary_category != b.bestiary_category or a.bestiary_index != b.bestiary_index:
		return ._sort_forms_by_index(a, b)

	# Categorize by DLC
	var casecmp: int = a.require_dlc.casecmp_to(b.require_dlc)
	if casecmp < 0:
		return true
	elif casecmp > 0:
		return false

	# Categorize by mod id, if we can figure it out
	var a_mod_id: String = ""
	var b_mod_id: String = ""
	var mod: ContentInfo
	if a.battle_sprite_path.begins_with("res://mods/"):
		mod = load("res://mods/%s/metadata.tres" % a.battle_sprite_path.trim_prefix("res://mods/").get_slice('/', 0))
		a_mod_id = mod.id
	if b.battle_sprite_path.begins_with("res://mods/"):
		mod = load("res://mods/%s/metadata.tres" % b.battle_sprite_path.trim_prefix("res://mods/").get_slice('/', 0))
		b_mod_id = mod.id
	casecmp = a_mod_id.casecmp_to(b_mod_id)
	if casecmp < 0:
		return true
	elif casecmp > 0:
		return false

	# Sort by max AP and move slots
	if a.max_ap > b.max_ap:
		return false
	elif a.max_ap < b.max_ap:
		return true
	elif a.move_slots > b.move_slots:
		return false
	elif a.move_slots < b.move_slots:
		return true

	# Sort by stat totals
	var a_total: int = a.max_hp + a.melee_attack + a.melee_defense + a.ranged_attack + a.ranged_defense + a.speed
	var b_total: int = b.max_hp + b.melee_attack + b.melee_defense + b.ranged_attack + b.ranged_defense + b.speed
	return a_total < b_total
