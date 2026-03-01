extends Node3D

@export var phys_bone_simulator : PhysicalBoneSimulator3D
@export var animation_tree : AnimationTree

func ragdoll():
	phys_bone_simulator.physical_bones_start_simulation()
