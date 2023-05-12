extends Reference

const _REGULAR: DynamicFontData = preload("fonts/OpenDyslexic-Regular.woff2")
const _BOLD: DynamicFontData = preload("fonts/OpenDyslexic-Bold.woff2")
const _ITALIC: DynamicFontData = preload("fonts/OpenDyslexic-Italic.woff2")

const DYSLEXIC_FONTS: Dictionary = {
	preload("res://ui/fonts/regular/regular_20.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_24.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_24_bold.tres"): _BOLD,
	preload("res://ui/fonts/regular/regular_24_italic.tres"): _ITALIC,
	preload("res://ui/fonts/regular/regular_30.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_30_bold.tres"): _BOLD,
	preload("res://ui/fonts/regular/regular_30_italic.tres"): _ITALIC,
	preload("res://ui/fonts/regular/regular_36.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_36_bold.tres"): _BOLD,
	preload("res://ui/fonts/regular/regular_36_italic.tres"): _ITALIC,
	preload("res://ui/fonts/regular/regular_40.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_40_bold.tres"): _BOLD,
	preload("res://ui/fonts/regular/regular_40_italic.tres"): _ITALIC,
	preload("res://ui/fonts/regular/regular_50.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_50_bold.tres"): _BOLD,
	preload("res://ui/fonts/regular/regular_50_italic.tres"): _ITALIC,
	preload("res://ui/fonts/regular/regular_70.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_85.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_100.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_140.tres"): _REGULAR,
	preload("res://ui/fonts/regular/regular_190.tres"): _REGULAR,

	preload("res://ui/fonts/archangel/archangel_40.tres"): _REGULAR,
	preload("res://ui/fonts/archangel/archangel_50.tres"): _REGULAR,
	preload("res://ui/fonts/archangel/archangel_60.tres"): _REGULAR,
	preload("res://ui/fonts/archangel/archangel_70.tres"): _REGULAR,
	preload("res://ui/fonts/archangel/archangel_70_bold.tres"): _BOLD,
	preload("res://ui/fonts/archangel/archangel_100.tres"): _REGULAR,
}
var backup_fonts: Dictionary

func change_font(enable: bool) -> void:
	if enable:
		for font in DYSLEXIC_FONTS:
			backup_fonts[font] = {
				"font_data": font.font_data,
				"size": font.size,
				"extra_spacing_top": font.extra_spacing_top,
				"extra_spacing_bottom": font.extra_spacing_bottom,
				"extra_spacing_char": font.extra_spacing_char,
			}
			font.font_data = DYSLEXIC_FONTS[font]
			font.extra_spacing_top = -int(font.size * 0.12)
			font.extra_spacing_bottom = -int(font.size * 0.12)
			font.extra_spacing_char = -int(font.size * 0.04)
			font.size = int(font.size * 0.8)
			font.emit_changed()
		return

	for font in backup_fonts:
		for property in backup_fonts[font]:
			font.set(property, backup_fonts[font][property])
		font.emit_changed()
