extends Button

@onready var backgroundSprite = $background
@onready var container: CenterContainer = $CenterContainer
@onready var artifacts = preload("res://Inventory/Artifacts/playerArtifacts.tres")

var artifactItem: ArtifactsItem = null
var index: int

func insert(artifact: ArtifactsItem):
	if !artifact:
		return
		
	if not (artifact is ArtifactsItem):
		print("only artifacts can be placed")
		return	
	clear()
	
	artifactItem = artifact
	backgroundSprite.frame = 1
	var texture = TextureRect.new()
	texture.texture = artifact.texture
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(texture)
	
	if index >= 0 and artifacts.items.size():
		artifacts.item[index] = artifact
	else:
		if artifacts.items.size() <= index:
			artifacts.items.resize(index + 1)
		artifacts.items[index] = artifact
		
	if Engine.has_singleton("Global"):
		Global.recalc_artifacts()
		
		
func take_item() -> ArtifactsItem:
	if !artifactItem:
		return null
	var item = artifactItem
	clear()
	
	if index >= 0 and index < artifacts.items.size():
		artifacts.item[index] = null
	
	if Engine.has_singleton("Global"):
		Global.recalc_artifacts()
	
	return item
	
func is_empty() -> bool:
	return artifactItem == null
				
func clear():
	if container.get_child_count() > 0:
		for child in container.get_children():
			child.queue_free()
	artifactItem = null
	backgroundSprite.frame = 0
	
