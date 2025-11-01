extends Panel
class_name ArtifactStackGui

@onready var artifactSprite: Sprite2D = $artifact

# This holds the actual ArtifactsItem resource
var artifact: ArtifactsItem = null

func set_artifact(a: ArtifactsItem):
	artifact = a
	update_gui()

func update_gui():
	if !artifact:
		artifactSprite.visible = false
		return
	
	artifactSprite.texture = artifact.texture
	artifactSprite.visible = true

# Optional: clear the GUI
func clear():
	artifact = null
	artifactSprite.visible = false
