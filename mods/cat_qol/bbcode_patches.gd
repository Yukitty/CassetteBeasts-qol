extends Reference

const TEXT_WAVE_REDUCED: String = "[wave amp=10 freq=4]"
const TEXT_SHAKE_REDUCED: String = "[shake level=6]"

var mod: ContentInfo

func _on_translation(_src_message: String, message: String) -> String:
	if not mod:
		mod = DLC.mods_by_id.cat_qol

	# Abort if text movement is full or there are no relevant tags
	if mod.setting_text_movement == mod.TextMovement.FULL or not ("[shake" in message or "[wave" in message):
		return ""

	var s: int
	var e: int

	# Edit [shake] tags
	s = 0
	while true:
		s = message.find("[shake", s)
		if s == -1:
			break
		e = message.find("]", s)
		assert(e != -1)
		e += 1
		match mod.setting_text_movement:
			mod.TextMovement.DISABLED:
				message = message.substr(0, s) + "[b]" + message.substr(e)
				s += 3
			mod.TextMovement.REDUCED:
				message = message.substr(0, s) + TEXT_SHAKE_REDUCED + message.substr(e)
				s += TEXT_SHAKE_REDUCED.length()
	if mod.setting_text_movement == mod.TextMovement.DISABLED:
		message = message.replace("[/shake]", "[/b]")

	# Edit [wave] tags
	s = 0
	while true:
		s = message.find("[wave", s)
		if s == -1:
			break
		e = message.find("]", s)
		assert(e != -1)
		e += 1
		match mod.setting_text_movement:
			mod.TextMovement.DISABLED:
				message = message.substr(0, s) + "[i]" + message.substr(e)
				s += 3
			mod.TextMovement.REDUCED:
				message = message.substr(0, s) + TEXT_WAVE_REDUCED + message.substr(e)
				s += TEXT_WAVE_REDUCED.length()
	if mod.setting_text_movement == mod.TextMovement.DISABLED:
		message = message.replace("[/wave]", "[/i]")

	return message
