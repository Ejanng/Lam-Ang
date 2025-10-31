extends Resource

class_name Artifacts

signal updated

@export var items: Array[ArtifactsItem]

func equip(artifact: ArtifactsItem):
	if artifact in items:
		return
	items.append(artifact)
	updated.emit()
	Global.recalc_artifacts()
	
func unequip(artifact: ArtifactsItem):
	if artifact in items:
		items.erase(artifact)
	updated.emit()
	Global.recalc_artifacts()
	
func has_artifact(artifactName: String) -> bool:
	for item in items:
		if item.name == artifactName:
			return true
	return false
