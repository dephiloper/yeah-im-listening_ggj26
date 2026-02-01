class_name Dialogue extends Node2D

var option_prefix: String = "[?]"

@export var characters_per_second: float = 30.0
@export var delay_between_lines: float = 3.0
@export var time_option: float = 10.0

@export var max_shake_rate: int = 50
@export var max_shake_offset: int = 10

@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var distraction_manager: DistractionManager = %DistractionManager

@export var dialogue_options: Array[Button]
@export var option_timer_container: ColorRect
@export var option_timer_bar: ColorRect

var tween: Tween
var current_line_index: int = 0

# for now to simplify don't use distracted lines
var distracted_lines: Array[PackedStringArray]
var current_distracted_text: String
var is_very_distracted: bool = false
var distraction_level: int

var dialogue_entries: Array[DialogueEntry] = []
var current_branch_lines: PackedStringArray = []
var current_branch_index: int = -1
var is_in_branch: bool = false
var waiting_for_option: bool = false
var time_since_option_start: float = 0
var timer_bar_original_width: float


class DialogueEntry:
	var text: String = ""
	var options: Array[DialogueOption] = []

	func has_options() -> bool:
		return options.size() > 0


class DialogueOption:
	var text: String = ""
	var branch_lines: PackedStringArray = []


func _ready() -> void:
	dialogue_entries = load_dialogue_entries()
	distracted_lines = load_distracted_lines()
	current_line_index = 0
	hide_dialogue_options()
	scroll_text(dialogue_entries[current_line_index].text)
	timer_bar_original_width = option_timer_bar.size.x


func _process(delta: float) -> void:
	rich_text_label.text = get_text()
	if waiting_for_option:
		time_since_option_start += delta
		var ratio = clamp(time_since_option_start / time_option, 0.0, 1.0)
		option_timer_bar.size.x = lerp(timer_bar_original_width, 0.0, ratio)
		if time_since_option_start >= time_option:
			var current_entry = dialogue_entries[current_line_index]
			select_option(current_entry.options.size() - 1)


func get_text() -> String:
	var distraction_intesity: float = 0
	if distraction_manager.active_distraction:
		distraction_intesity = distraction_manager.active_distraction.distraction_value

	var shake_rate = max_shake_rate * distraction_intesity
	var shake_offset_lvl = max_shake_offset * distraction_intesity

	var active_text: String
	if (
		is_in_branch
		and current_branch_index >= 0
		and current_branch_index < current_branch_lines.size()
	):
		active_text = current_branch_lines[current_branch_index]
	elif current_line_index < dialogue_entries.size():
		active_text = dialogue_entries[current_line_index].text
	else:
		active_text = ""

	return (
		"[shake rate=%s level=%s connected=1]%s[/shake]"
		% [shake_rate, shake_offset_lvl, active_text]
	)


func load_dialogue_entries() -> Array[DialogueEntry]:
	var file = FileAccess.open("res://dialogues/test.txt", FileAccess.READ)
	var text = file.get_as_text()
	var split_lines = text.split("\n")

	var entries: Array[DialogueEntry] = []
	var current_entry: DialogueEntry = null
	var current_option: DialogueOption = null

	for line in split_lines:
		var stripped = line.strip_edges()
		if stripped == "":
			continue

		if stripped.begins_with(option_prefix):
			if current_entry == null:
				current_entry = DialogueEntry.new()
				entries.append(current_entry)

			current_option = DialogueOption.new()
			current_option.text = stripped.substr(len(option_prefix)).strip_edges()
			current_entry.options.append(current_option)
		elif (line.begins_with("\t") or line.begins_with("    ")) and current_option != null:
			current_option.branch_lines.append(stripped)
		else:
			current_entry = DialogueEntry.new()
			current_entry.text = stripped
			entries.append(current_entry)
			current_option = null

	return entries


func load_distracted_lines() -> Array[PackedStringArray]:
	var file = FileAccess.open("res://dialogues/annoyed.txt", FileAccess.READ)
	var text = file.get_as_text()
	var split_lines = text.split("\n")
	var line_block: PackedStringArray = []
	var lines: Array[PackedStringArray] = []
	for line in split_lines:
		if line.strip_edges() != "":
			line_block.append(line)
		else:
			lines.append(line_block)
			line_block = []
	return lines


func scroll_text(text: String) -> void:
	if tween:
		tween.kill()

	rich_text_label.text = text
	rich_text_label.visible_characters = 0

	var total_characters = rich_text_label.get_total_character_count()
	var duration = total_characters / characters_per_second

	tween = create_tween()
	tween.tween_property(rich_text_label, "visible_characters", total_characters, duration)
	tween.tween_callback(scroll_next_line).set_delay(delay_between_lines)


func scroll_next_line() -> void:
	if is_in_branch:
		current_branch_index += 1
		if current_branch_index < current_branch_lines.size():
			scroll_text(current_branch_lines[current_branch_index])
		else:
			is_in_branch = false
			current_branch_index = -1
			current_branch_lines = []
			current_line_index += 1
			advance_to_next_entry()
		return

	var current_entry = dialogue_entries[current_line_index]
	if current_entry.has_options():
		show_dialogue_options(current_entry.options)
		waiting_for_option = true
		return

	current_line_index += 1
	advance_to_next_entry()


func advance_to_next_entry() -> void:
	if current_line_index >= dialogue_entries.size():
		current_line_index = dialogue_entries.size() - 1
		return

	var entry = dialogue_entries[current_line_index]

	if entry.text == "" and entry.has_options():
		show_dialogue_options(entry.options)
		waiting_for_option = true
		return

	scroll_text(entry.text)


func show_dialogue_options(options: Array[DialogueOption]) -> void:
	distraction_manager.pause_distraction()
	for i in range(dialogue_options.size()):
		if i < options.size():
			dialogue_options[i].text = options[i].text
			dialogue_options[i].visible = true
		else:
			dialogue_options[i].visible = false
	option_timer_container.visible = true
	option_timer_bar.size.x = timer_bar_original_width


func hide_dialogue_options() -> void:
	for option_label in dialogue_options:
		option_label.visible = false
	option_timer_container.visible = false

	# DEBUG if you want to play the distraction right away :>
	# distraction_manager.resume_distraction()


func select_option(option_index: int) -> void:
	time_since_option_start = 0
	if not waiting_for_option:
		return

	var current_entry = dialogue_entries[current_line_index]
	if option_index < 0 or option_index >= current_entry.options.size():
		return

	waiting_for_option = false
	hide_dialogue_options()

	var selected_option = current_entry.options[option_index]

	if selected_option.branch_lines.size() > 0:
		is_in_branch = true
		current_branch_lines = selected_option.branch_lines
		current_branch_index = 0
		scroll_text(current_branch_lines[0])
	else:
		current_line_index += 1
		advance_to_next_entry()

	distraction_manager.resume_distraction()


func _on_npc_distraction_too_long(level: int) -> void:
	return


func _on_npc_distraction_stopped() -> void:
	return


func _select_option_1() -> void:
	select_option(0)


func _select_option_2() -> void:
	select_option(1)


func _select_option_3() -> void:
	select_option(2)
