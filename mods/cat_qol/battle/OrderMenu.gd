extends "res://battle/ui/OrderMenu.gd"

func flee() -> void:
	# If there is a recordable bootleg, add a confirmation dialog
	if _has_recordable_bootlegs(fighter):
		yield (battle.cassette_player.defocus(), "completed")
		if not yield (MenuHelper.confirm("BATTLE_FLEE_BOOTLEG_CONFIRM", 1, 1), "completed"):
			_on_Submenu_canceled()
			return

	# Normal flee
	.flee()

func _has_recordable_bootlegs(fighter: Node) -> bool:
	var teams = fighter.battle.get_teams(false, true)
	for team_id in teams:
		if team_id == fighter.team:
			continue
		for f in teams[team_id]:
			if f.is_recordable() and f.is_bootleg():
				return true
	return false
