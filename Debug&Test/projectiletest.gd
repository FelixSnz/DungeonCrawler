extends KinematicBody

var explo = preload("res://Entities/explosion.tscn")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var vel = Vector3.ZERO
var direction = Vector3.ZERO
var speed = .5
var damage
var not_impacted = true

signal impacted(obj)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	vel = direction * speed
	var collision = move_and_collide(vel)
	if collision and not_impacted:
		var expl = explo.instance()
		expl.translation = self.translation
		get_tree().current_scene.add_child(expl)
		not_impacted = false
		var collider = collision.collider
		emit_signal("impacted", collider)
		$AudioStreamPlayer3D.play()
		yield($AudioStreamPlayer3D, "finished")
		queue_free()
		
