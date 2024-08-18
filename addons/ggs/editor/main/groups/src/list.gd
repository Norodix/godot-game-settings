@tool
extends ItemList

const _TYPE: ggsCore.ItemType = ggsCore.ItemType.GROUP

@onready var Menu: PopupMenu = $ContextMenu


func _ready() -> void:
	item_selected.connect(_on_item_selected)
	item_clicked.connect(_on_item_clicked)
	empty_clicked.connect(_on_empty_clicked)
	Menu.id_pressed.connect(_on_Menu_id_pressed)
	GGS.Event.item_selected.connect(_on_Global_item_selected)


func _on_item_selected(item_index: int) -> void:
	var item: String = get_item_text(item_index)
	GGS.Event.item_selected.emit(_TYPE, item)


#region Loading
func load_items() -> void:
	clear()
	
	var items: PackedStringArray = _load_from_disc()
	for item in items:
		add_item(item)
	
	GGS.Event.item_selected.emit(_TYPE, "")


func _load_from_disc() -> PackedStringArray:
	var path: String = GGS.Pref.data.paths["settings"]
	path = path.path_join(GGS.State.selected_category)
	
	var dirs: PackedStringArray = DirAccess.get_directories_at(path)
	return GGS.Util.remove_underscored(dirs)


func _on_Global_item_selected(item_type: ggsCore.ItemType, item_name: String) -> void:
	if item_type == ggsCore.ItemType.CATEGORY:
		if item_name.is_empty():
			clear()
			print("TODO: disabling the list - group/list.gd::45")
			return
		
		load_items()

#endregion


#region Context Menu
func _show_menu(at_position: Vector2, disable_item_actions: bool) -> void:
	# For some reason the menu won't popup at the exact cursor location
	# without this offset.
	var offset: Vector2 = Vector2(0, -22)
	
	Menu.position = global_position + at_position - offset
	Menu.set_item_actions_disabled(disable_item_actions)
	Menu.popup()


func _on_item_clicked(_index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		_show_menu(at_position, false)


func _on_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		_show_menu(at_position, true)


func _on_Menu_id_pressed(id: int) -> void:
	var selected_idx: int = get_selected_items()[0]
	var item: String = get_item_text(selected_idx)
	
	match id:
		Menu.ItemId.RENAME:
			GGS.Event.rename_requested.emit(_TYPE, item)
		
		Menu.ItemId.DELETE:
			GGS.Event.delete_requested.emit(_TYPE, item)
		
		Menu.ItemId.FILESYSTEM_GODOT:
			GGS.Util.show_item_in_filesystem_godot(_TYPE, item)
		
		Menu.ItemId.FILESYSTEM_OS:
			GGS.Util.show_item_in_filesystem_os(_TYPE, item)
		
		Menu.ItemId.RELOAD:
			load_items()
			print("GGS - Reload Categories: Successful.")


func _on_Global_rename_confirmed(item_type: ggsCore.ItemType, _prev_name: String, _new_name: String) -> void:
	if item_type != ggsCore.ItemType.CATEGORY:
		return
	
	load_items()


func _on_Global_delete_confirmed(item_type: ggsCore.ItemType, _item_name: String) -> void:
	if item_type != ggsCore.ItemType.CATEGORY:
		return
	
	load_items()

#endregion
