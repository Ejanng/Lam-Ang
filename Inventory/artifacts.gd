extends Resource

class_name Artifacts

signal updated

@export var slots: Array[ArtifactsSlot] = []

func insert(artifact: ArtifactsItem):
	# Check if already equipped (no duplicates)
	for slot in slots:
		if slot.item and slot.item.name == artifact.name:
			print("Artifact already equipped:", artifact.name)
			return

	# Find an empty slot
	for slot in slots:
		if slot.item == null:
			slot.item = artifact
			updated.emit()
			Global.recalc_artifacts()
			return
	
	print("No empty artifact slot available.")

func removeSlot(artifactSlot: ArtifactsSlot):
	var index = slots.find(artifactSlot)
	if index < 0:
		return
	remove_at_index(index)

func remove_at_index(index: int) -> void:
	slots[index] = ArtifactsSlot.new()
	updated.emit()
	Global.recalc_artifacts()

func insertSlot(index: int, artifactSlot: ArtifactsSlot):
	if index < 0 or index >= slots.size(): 
		return
	slots[index] = artifactSlot
	updated.emit()
	Global.recalc_artifacts()

func unequip(artifact: ArtifactsItem):
	for i in range(slots.size()):
		if slots[i].item and slots[i].item.name == artifact.name:
			remove_at_index(i)
			return

func has_artifact(artifactName: String) -> bool:
	for slot in slots:
		if slot.item and slot.item.name == artifactName:
			return true
	return false

func get_equipped_artifacts() -> Array[ArtifactsItem]:
	var equipped: Array[ArtifactsItem] = []
	for slot in slots:
		if slot.item:
			equipped.append(slot.item)
	return equipped
