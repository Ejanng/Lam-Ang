extends Button

@onready var backgroundSprite = $background
@onready var container: CenterContainer = $CenterContainer
@onready var artifacts: Artifacts = preload("res://Inventory/Artifacts/playerArtifacts.tres")

var artifactItem: ArtifactStackGui
var index: int = -1

func insert(artifactStack: ArtifactStackGui):
	if !artifactStack:
		return
	
	clear()  # remove previous
	
	artifactItem = artifactStack
	backgroundSprite.frame = 1
	
	# Add the icon/texture
	var texture = TextureRect.new()
	texture.texture = artifactStack.artifact.texture  # Assuming ArtifactStackGui has .artifact property
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(texture)
	
	# ✅ Update the underlying Artifacts Resource
	if index >= 0:
		if artifacts.slots.size() <= index:
			artifacts.slots.resize(index + 1)
		
		# make sure the slot exists
		if !artifacts.slots[index]:
			artifacts.slots[index] = ArtifactsSlot.new()
		
		artifacts.slots[index].item = artifactStack.artifact
	
	if Engine.has_singleton("Global"):
		Global.recalc_artifacts()

func take_item() -> ArtifactStackGui:
	if !artifactItem:
		return null
	
	var item = artifactItem
	clear()
	
	# ✅ Remove from resource correctly
	if index >= 0 and index < artifacts.slots.size():
		if artifacts.slots[index]:
			artifacts.slots[index].item = null
	
	if Engine.has_singleton("Global"):
		Global.recalc_artifacts()
	
	return item

func is_empty() -> bool:
	return artifactItem == null

func clear():
	# Free children nodes
	for child in container.get_children():
		child.queue_free()
	artifactItem = null
	backgroundSprite.frame = 0
