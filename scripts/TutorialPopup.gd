# TutorialPopup.gd — safe version
extends PopupPanel

@onready var title_label = $VBoxContainer/TitleLabel
@onready var body_label = $VBoxContainer/BodyLabel
@onready var controls_grid = $VBoxContainer/ControlsGrid
@onready var dont_show_cb = $VBoxContainer/DontShowAgain
@onready var continue_btn = $VBoxContainer/HBoxContainer/ContinueButton
@onready var skip_btn = $VBoxContainer/HBoxContainer/SkipButton
# We will locate reopen_btn in _ready() safely

const SETTINGS_PATH : String = "user://settings.cfg"
var reopen_btn : Button = null

func _ready() -> void:
	# ensure this node processes while the tree is paused
	self.pause_mode = Node.PAUSE_MODE_PROCESS

	# locate reopen button safely: search the whole scene for a node named "ShowTutorialButton"
	reopen_btn = get_tree().get_root().find_node("ShowTutorialButton", true, false) as Button

	# connect signals only if nodes exist
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)
	if skip_btn:
		skip_btn.pressed.connect(_on_skip_pressed)
	if reopen_btn:
		reopen_btn.pressed.connect(_on_reopen_pressed)

	# set UI text (optional; you can edit in editor too)
	title_label.text = "How to Play"
	body_label.bbcode_text = "[b]Objective:[/b]\nComplete objectives and survive."

	_populate_controls()

	if _should_show_on_start():
		_show_and_pause()

# rest of functions unchanged (safe versions)
func _populate_controls() -> void:
	for child in controls_grid.get_children():
		controls_grid.remove_child(child)
		child.queue_free()

	var actions = [
		{"label":"Interact", "action":"ui_accept"},
		{"label":"Pause / Cancel", "action":"ui_cancel"},
		{"label":"Left", "action":"ui_left"},
		{"label":"Right", "action":"ui_right"},
		{"label":"Up", "action":"ui_up"},
		{"label":"Down", "action":"ui_down"},
		{"label":"Attack", "action":"attack"},
	]

	for pair in actions:
		var name_lbl = Label.new()
		name_lbl.text = pair.label
		name_lbl.valign = VAlign.CENTER
		controls_grid.add_child(name_lbl)

		var key_lbl = Label.new()
		key_lbl.text = _action_to_string(pair.action)
		key_lbl.valign = VAlign.CENTER
		controls_grid.add_child(key_lbl)

func _action_to_string(action_name: String) -> String:
	var evs = InputMap.get_action_list(action_name)
	if evs.size() == 0:
		return "—"
	for ev in evs:
		var t := ev.as_text().strip_edges()
		if t != "":
			return t
	return str(evs[0])

func _show_and_pause() -> void:
	popup_centered()
	get_tree().paused = true

func _on_continue_pressed() -> void:
	_close_and_apply_pref()

func _on_skip_pressed() -> void:
	_close_and_apply_pref()

func _on_reopen_pressed() -> void:
	_show_and_pause()

func _close_and_apply_pref() -> void:
	get_tree().paused = false
	hide()
	if dont_show_cb.pressed:
		_set_show_on_start(false)

func _should_show_on_start() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		return bool(cfg.get_value("tutorial", "show_on_start", true))
	return true

func _set_show_on_start(value: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("tutorial", "show_on_start", value)
	cfg.save(SETTINGS_PATH)
