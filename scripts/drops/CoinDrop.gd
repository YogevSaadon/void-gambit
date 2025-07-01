# res://scripts/drops/CoinDrop.gd
extends DropPickup
class_name CoinDrop

# Clean and simple - just set the currency type
func _ready() -> void:
	super._ready()
	currency_type = Currency.COIN  # That's it!
