extends Node3D

@export var phys_bone_simulator : PhysicalBoneSimulator3D
@export var animation_tree : AnimationTree
@export var smoke_particles : GPUParticles3D

func ragdoll():
	phys_bone_simulator.physical_bones_start_simulation()
	smoke_particles.hide()
	await get_tree().create_timer(8.0).timeout
	queue_free()
