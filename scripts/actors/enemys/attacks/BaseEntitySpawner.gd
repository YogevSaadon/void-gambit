# scripts/actors/enemys/attacks/BaseEntitySpawner.gd
extends Node2D
class_name BaseEntitySpawner

## Base class for enemy spawners that create persistent entities (ships, missiles, etc.)
## Handles tracking and capping of spawned entities to prevent performance issues

# ===== CONFIGURATION =====
@export var max_entities_per_spawner: int = 6
@export var cleanup_interval: float = 1.0  # How often to cleanup dead entities

# ===== TRACKING =====
var spawned_entities: Array[Node] = []
var _owner_enemy: BaseEnemy
var _cleanup_timer: float = 0.0

# ===== INITIALIZATION =====
func _ready() -> void:
	_owner_enemy = _find_parent_enemy()
	_cleanup_timer = randf_range(0.0, cleanup_interval)

# ===== MAIN SPAWNING METHOD =====
func try_spawn_entity() -> Node:
	"""
	Attempt to spawn a new entity if under the cap
	Returns the spawned entity or null if at capacity
	"""
	_cleanup_dead_entities()
	
	if spawned_entities.size() >= max_entities_per_spawner:
		return null
	
	var entity = _create_entity()
	if entity:
		spawned_entities.append(entity)
		_setup_entity(entity)
		return entity
	
	return null

# ===== ENTITY MANAGEMENT =====
func _cleanup_dead_entities() -> void:
	"""Remove invalid references from tracking array"""
	var original_count = spawned_entities.size()
	spawned_entities = spawned_entities.filter(func(entity): return is_instance_valid(entity))
	

func _physics_process(delta: float) -> void:
	"""Periodic cleanup to prevent array bloat"""
	_cleanup_timer -= delta
	if _cleanup_timer <= 0.0:
		_cleanup_timer = cleanup_interval
		_cleanup_dead_entities()

# ===== VIRTUAL METHODS (OVERRIDE IN SUBCLASSES) =====
func _create_entity() -> Node:
	"""Override this to create the specific entity type"""
	push_error("BaseEntitySpawner: _create_entity() must be overridden in subclass")
	return null

func _setup_entity(entity: Node) -> void:
	"""Override this to configure the entity after creation"""
	# Default implementation - apply power scaling if owner exists
	if _owner_enemy and entity.has_method("_apply_combat_scaling"):
		entity.power_level = _owner_enemy.power_level
		entity._apply_combat_scaling()

# ===== UTILITY METHODS =====
func get_entity_count() -> int:
	"""Get current number of live entities"""
	_cleanup_dead_entities()
	return spawned_entities.size()

func get_available_slots() -> int:
	"""Get number of entities that can still be spawned"""
	return max_entities_per_spawner - get_entity_count()

func is_at_capacity() -> bool:
	"""Check if spawner is at maximum capacity"""
	return get_entity_count() >= max_entities_per_spawner

func force_cleanup() -> void:
	"""Immediately cleanup all dead entities"""
	_cleanup_dead_entities()

# ===== HELPER METHODS =====
func _find_parent_enemy() -> BaseEnemy:
	"""Find the BaseEnemy parent that owns this spawner"""
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	
	if not p:
		push_error("BaseEntitySpawner: No BaseEnemy parent found")
	
	return p as BaseEnemy

# ===== DEBUG =====
func get_spawner_debug_info() -> Dictionary:
	"""Get debug information about spawner state"""
	return {
		"spawner_type": get_class(),
		"entity_count": get_entity_count(),
		"max_entities": max_entities_per_spawner,
		"available_slots": get_available_slots(),
		"at_capacity": is_at_capacity(),
		"owner_enemy": _owner_enemy.enemy_type if _owner_enemy else "none"
	}