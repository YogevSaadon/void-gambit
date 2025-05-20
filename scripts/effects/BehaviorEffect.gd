# res://scripts/effects/BehaviorEffect.gd
extends Node
class_name BehaviorEffect
## Base class for any “game-play effect” item.
## Concrete subclasses override activate()/deactivate().

var player : Player        # set in activate()
var pd     : PlayerData
var pem    : Node          # PassiveEffectManager (or whoever instanced me)

func activate(_player: Player, _pd: PlayerData, _pem: Node) -> void:
	"""
	Called once when the effect becomes active (item picked up / equipped).
	Connect signals or start timers here.
	"""
	player = _player
	pd     = _pd
	pem    = _pem

func deactivate() -> void:
	"""
	Called when the effect should stop (item sold / unequipped).
	Disconnect signals, stop timers, free nodes, etc.
	Default: just delete myself.
	"""
	queue_free()
