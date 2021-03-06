extends Spatial

onready var animationPlayer = $AnimationPlayer
onready var rayCastAttack = $BodyAxis/spider/RayCastAttack
onready var rayCastCollide = $RayCastCollide
onready var stats = $Stats
onready var body = $BodyAxis/spider
onready var hurtBox = $HurtBox

const static_directions = {
	"right": Vector3.RIGHT,
	"left": Vector3.LEFT,
	"forward": Vector3.FORWARD,
	"back": Vector3.BACK
	}

var has_moved = false
var can_move = true
var can_attack = true
export(int) var damage = 1
var can_dead = true

signal has_attacked
signal damaged(ref)
signal dead(ref)

enum STATES {
	IDLE,
	CHASING,
	WANDERING
}

var state = STATES.IDLE
var cell_size = 4

func _ready():
	pass

func _physics_process(_delta):
	look_at_player()
	
	if stats.health == 0 and can_dead:
		can_dead = false
		animationPlayer.stop()
		animationPlayer.play("dead")
#		yield(animationPlayer, "animation_finished")

func get_target_step(target_pos):
	var path = Global.grid_map.find_path(self.translation, target_pos)
	if path and path.size() > 1:
		return path[1]
	else:
		return null

func make_step(player_pos, target_step):
	if can_move:
		if animationPlayer.is_playing():
			yield(animationPlayer, "animation_finished")
		var target_direction = self.translation.direction_to(target_step)
		rayCastCollide.cast_to = target_direction * cell_size
		rayCastCollide.force_raycast_update()
		if !rayCastCollide.is_colliding():
			if target_step != player_pos:
				$Tween.interpolate_property(self, "translation", translation, \
				target_step, .5, Tween.TRANS_SINE, Tween.EASE_OUT)
				$Tween.start()
			else:
				pass
#				print("target step is player pos")
		else:
			pass
#			print("infront the enemy is colliding")
	else:
		pass
#		print("cant move")

func try_to_tackle(player, player_pos):
	if player != null:
		if can_attack:
			if player.tween.is_active():
				yield(player.tween, "tween_completed")
			var directions = static_directions.values()
			for dir in directions:
				var rel = self.translation + dir * cell_size
				if rel.is_equal_approx(player_pos):
					if animationPlayer.is_playing():
						yield(animationPlayer,"animation_finished")
					animationPlayer.play("tackle")

func check_raycast():
	if rayCastAttack.is_colliding():
		var collider = rayCastAttack.get_collider()
		var obj = collider.get_parent()
		$damageSound.play()
		if obj.script != null:
			obj.damage(damage)

func end_turn_and_free():
	end_turn()
	queue_free()

func disable_movement():
	can_attack = false
	can_move = false
	$CollisionShape.disabled = true
	hurtBox.get_node("CollisionShape").disabled = true

func damage_self(amount):
	emit_signal("damaged", self)
	
#	animationPlayer.play("damage_shake")
	stats.health -= amount

func end_turn():
	emit_signal("has_attacked")
	
func look_at_player():
	var player = Global.player
	if player != null and can_move:
		$BodyAxis.look_at(player.global_transform.origin, Vector3.UP)

func _on_Stats_no_health():
	emit_signal("dead", self)
	animationPlayer.play("dead")


func _on_HurtBox_area_entered(area):
	
	var posible_spell = area.get_parent()
	if posible_spell.is_in_group("spells"):
	
		stats.health -= posible_spell.damage
		posible_spell.impact(self)
		
		
