extends BaseConditionalLayer

const MOD_ID := "cat_qol"

export var flag_required: String

var mod: ContentInfo = DLC.mods_by_id[MOD_ID]

func _check_conditions() -> bool:
	assert(mod != null)
	return mod.get(flag_required) == true
