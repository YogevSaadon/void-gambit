# FINAL CORRECTED Fix All Actor Scaling Tool Script
# Save this as "fix_actor_scaling_final.gd" and run it via Tools → Execute Script
@tool
extends EditorScript

# EXACT data from your actual scene files
var actor_scaling_data = {
	"res://scenes/actors/Player.tscn": {
		"node_scale": Vector2(2.5, 2.5),
		"sprite_name": "Sprite",  # Player uses "Sprite" not "Sprite2D"
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(0.516506, 0.00709733),
		"has_damage_anchor": false,
		"has_power_indicator": false,
		"collision_shapes": []
	},
	
	"res://scenes/actors/enemys/Biter.tscn": {
		"node_scale": Vector2(2.9, 2.9),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.02, 0.02),
		"sprite_rotation": 0.0,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(-20, -20),
		"color_rect_size": Vector2(40, 40),
		"damage_zone_collision": {"type": "circle", "radius": 9.0},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(12, 12)}
		]
	},
	
	"res://scenes/actors/enemys/ChildShip.tscn": {
		"node_scale": Vector2(2.0, 2.0),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(0, 0),
		"color_rect_size": Vector2(20, 20),
		"damage_zone_collision": {"type": "circle", "radius": 7.51665},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(12, 11.5), "position": Vector2(-1.5, 0.25)}
		]
	},
	
	"res://scenes/actors/enemys/Diamond.tscn": {
		"node_scale": Vector2(5.2, 5.2),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(20, 20),
		"color_rect_size": Vector2(40, 40),
		"damage_zone_collision": {"type": "circle", "radius": 8.67806},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(19.3333, 16.2222), "position": Vector2(0.111111, 0.111111)}
		]
	},
	
	"res://scenes/actors/enemys/EnemyMissle.tscn": {
		"node_scale": Vector2(1.0, 1.0),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(-140, -40),
		"color_rect_size": Vector2(40, 80),
		"damage_zone_collision": {"type": "circle", "radius": 4.0, "position": Vector2(9, 0)},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(24, 12), "position": Vector2(1, 0)}
		]
	},
	
	"res://scenes/actors/enemys/GoldShip.tscn": {
		"node_scale": Vector2(3.3, 3.3),
		"sprite_name": "Sprite2D2",  # GoldShip uses Sprite2D2!
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(1.41143, -0.00261868),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(-60, -60),
		"color_rect_size": Vector2(54, 48),
		"damage_zone_collision": {"type": "circle", "radius": 7.88461},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(23.9394, 15.1515), "position": Vector2(1.9697, 0)}
		]
	},
	
	"res://scenes/actors/enemys/MiniBiter.tscn": {
		"node_scale": Vector2(1.5, 1.5),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": 0.0,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(380, 60),
		"color_rect_size": Vector2(40, 40),
		"damage_zone_collision": {"type": "circle", "radius": 9.21954},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(20, 21), "position": Vector2(0, -0.5)}
		]
	},
	
	"res://scenes/actors/enemys/MotherShip.tscn": {
		"node_scale": Vector2(8.0, 8.0),
		"sprite_name": "Sprite2D2",  # MotherShip also uses Sprite2D2!
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(-0.25, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(30, 30),
		"color_rect_size": Vector2(30, 30),
		"damage_zone_collision": {"type": "circle", "radius": 10.1312},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(17.5, 21.875), "position": Vector2(0.125, -0.3125)}
		]
	},
	
	"res://scenes/actors/enemys/Rectangle.tscn": {
		"node_scale": Vector2(2.0, 2.0),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(20, 20),
		"color_rect_size": Vector2(40, 40),
		"damage_zone_collision": {"type": "circle", "radius": 10.6719},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(26.6667, 14), "position": Vector2(0, 0.333333)}
		]
	},
	
	"res://scenes/actors/enemys/Star.tscn": {
		"node_scale": Vector2(4.0, 4.0),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": 0.0,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(24.2424, 24.2424),
		"color_rect_size": Vector2(40, 40),
		"damage_zone_collision": {"type": "circle", "radius": 8.50647, "position": Vector2(0, -0.606061)},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(17.2727, 16.9697), "position": Vector2(0.454546, 0)}
		]
	},
	
	"res://scenes/actors/enemys/Triangle.tscn": {
		"node_scale": Vector2(3.0, 3.0),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.02, 0.02),
		"sprite_rotation": 4.71239,  # Different rotation!
		"sprite_position": Vector2(1, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(0, -40),
		"color_rect_size": Vector2(60, 60),
		"damage_zone_collision": {"type": "circle", "radius": 7.66667},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(14, 12)}
		]
	},
	
	"res://scenes/actors/enemys/Tank.tscn": {
		"node_scale": Vector2(3.5, 3.5),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.03),
		"sprite_rotation": 4.71239,  # Same as Triangle
		"sprite_position": Vector2(2, 0),
		"has_damage_anchor": true,
		"damage_anchor_pos": Vector2(0, -14),
		"has_power_indicator": true,
		"power_indicator_scale": Vector2(0.05, 0.05),
		"color_rect_offset": Vector2(-20, -20),
		"color_rect_size": Vector2(80, 80),
		"damage_zone_collision": {"type": "circle", "radius": 20.0},
		"collision_shapes": [
			{"type": "rect", "size": Vector2(23, 21), "position": Vector2(0.5, 0.5)}
		]
	},
	
	"res://scenes/weapons/spawners/MiniShip.tscn": {
		"node_scale": Vector2(1.0, 1.0),
		"sprite_name": "Sprite2D",
		"sprite_scale": Vector2(0.03, 0.041),
		"sprite_rotation": PI/2,
		"sprite_position": Vector2(0, 0),
		"has_damage_anchor": false,
		"has_power_indicator": false,
		"collision_shapes": []
	}
}

func _run():
	print("=== FINAL CORRECTED ACTOR SCALING FIX ===")
	print("Using EXACT data from your scene files:")
	print("• Player uses 'Sprite' not 'Sprite2D'")
	print("• GoldShip & MotherShip use 'Sprite2D2'")
	print("• Preserving sprite rotations and positions")
	print("• Proper size calculations")
	print("")
	
	var fixed_count = 0
	var skipped_count = 0
	
	for scene_path in actor_scaling_data.keys():
		if fix_actor_scaling(scene_path):
			fixed_count += 1
		else:
			skipped_count += 1
	
	print("")
	print("=== FINAL FIX COMPLETE ===")
	print("Fixed: %d scenes" % fixed_count)
	print("Skipped: %d scenes" % skipped_count)
	print("")
	print("🎯 ALL ISSUES SHOULD BE FIXED:")
	print("   • Player normal size (not tiny)")
	print("   • Ships normal size (not huge)")
	print("   • Damage numbers above actors")
	print("   • ColorRects proper size")
	print("   • All sprites properly positioned/rotated")

func fix_actor_scaling(scene_path: String) -> bool:
	if not FileAccess.file_exists(scene_path):
		print("❌ SKIP: %s (file not found)" % scene_path)
		return false
	
	var data = actor_scaling_data[scene_path]
	var node_scale = data.node_scale
	
	# Skip if already at scale 1,1
	if node_scale.is_equal_approx(Vector2.ONE):
		print("✅ SKIP: %s (already scale 1,1)" % scene_path.get_file())
		return false
	
	print("🔧 FIXING: %s" % scene_path.get_file())
	print("   Node scale: %s → (1,1)" % node_scale)
	
	# Load and instantiate scene
	var packed_scene = load(scene_path)
	if not packed_scene:
		print("❌ ERROR: Could not load scene %s" % scene_path)
		return false
	
	var root = packed_scene.instantiate()
	if not root:
		print("❌ ERROR: Could not instantiate scene %s" % scene_path)
		return false
	
	# Fix root node scale
	root.scale = Vector2.ONE
	
	# Fix sprite using EXACT sprite name from data
	var sprite = root.get_node_or_null(data.sprite_name)
	if sprite:
		# Calculate final visual size and apply to sprite
		var final_sprite_scale = data.sprite_scale * node_scale
		var final_position = data.sprite_position * node_scale
		
		sprite.scale = final_sprite_scale
		sprite.position = final_position
		sprite.rotation = data.sprite_rotation  # Keep original rotation
		
		print("   %s scale: %s → %s" % [data.sprite_name, data.sprite_scale, final_sprite_scale])
		print("   %s position: %s → %s" % [data.sprite_name, data.sprite_position, final_position])
	else:
		print("   ⚠️  WARNING: %s not found in %s" % [data.sprite_name, scene_path.get_file()])
	
	# Fix damage anchor positioning
	if data.has_damage_anchor:
		var damage_anchor = root.get_node_or_null("DamageAnchor")
		if damage_anchor:
			var new_pos = data.damage_anchor_pos * node_scale
			damage_anchor.position = new_pos
			print("   DamageAnchor: %s → %s" % [data.damage_anchor_pos, new_pos])
	
	# Fix power indicator
	if data.has_power_indicator:
		var power_indicator = root.get_node_or_null("PowerIndicator")
		if power_indicator:
			# Keep PowerIndicator at original scale (don't scale it)
			power_indicator.scale = data.power_indicator_scale
			print("   PowerIndicator scale: %s" % data.power_indicator_scale)
			
			# Fix ColorRect - keep original dimensions
			var color_rect = power_indicator.get_node_or_null("ColorRect")
			if color_rect:
				color_rect.offset_left = data.color_rect_offset.x
				color_rect.offset_top = data.color_rect_offset.y
				color_rect.offset_right = data.color_rect_offset.x + data.color_rect_size.x
				color_rect.offset_bottom = data.color_rect_offset.y + data.color_rect_size.y
				print("   ColorRect: offset=%s, size=%s" % [data.color_rect_offset, data.color_rect_size])
	
	# Fix damage zone collision
	if "damage_zone_collision" in data:
		var damage_zone = root.get_node_or_null("DamageZone")
		if damage_zone:
			var damage_collision = damage_zone.get_node_or_null("CollisionShape2D")
			if damage_collision and damage_collision.shape:
				_fix_collision_shape(damage_collision, data.damage_zone_collision, node_scale)
	
	# Fix main collision shapes
	for shape_data in data.collision_shapes:
		var collision = root.get_node_or_null("CollisionShape2D")
		if collision and collision.shape:
			_fix_collision_shape(collision, shape_data, node_scale)
	
	# Fix weapon muzzle positions
	var weapon_node = root.get_node_or_null("WeaponNode")
	if weapon_node:
		var muzzle = weapon_node.get_node_or_null("Muzzle")
		if muzzle:
			var old_muzzle_pos = muzzle.position
			var new_muzzle_pos = old_muzzle_pos * node_scale
			muzzle.position = new_muzzle_pos
			print("   Muzzle position: %s → %s" % [old_muzzle_pos, new_muzzle_pos])
	
	# Save the fixed scene
	var new_packed_scene = PackedScene.new()
	var pack_result = new_packed_scene.pack(root)
	if pack_result != OK:
		print("❌ ERROR: Could not pack scene %s" % scene_path)
		root.queue_free()
		return false
	
	var save_result = ResourceSaver.save(new_packed_scene, scene_path)
	if save_result != OK:
		print("❌ ERROR: Could not save scene %s" % scene_path)
		root.queue_free()
		return false
	
	# Cleanup
	root.queue_free()
	print("✅ SUCCESS: %s fixed and saved!" % scene_path.get_file())
	return true

func _fix_collision_shape(collision_node: CollisionShape2D, shape_data: Dictionary, scale_factor: Vector2):
	"""Fix collision shape based on type and scale factor"""
	var shape = collision_node.shape
	
	# Fix collision position if specified
	if "position" in shape_data:
		var new_pos = shape_data.position * scale_factor
		collision_node.position = new_pos
		print("   Collision position: → %s" % new_pos)
	
	# Fix shape based on type
	if shape_data.type == "circle" and shape is CircleShape2D:
		var new_radius = shape_data.radius * scale_factor.x
		shape.radius = new_radius
		print("   Circle radius: → %.2f" % new_radius)
		
	elif shape_data.type == "rect" and shape is RectangleShape2D:
		var new_size = shape_data.size * scale_factor
		shape.size = new_size
		print("   Rect size: → %s" % new_size)
