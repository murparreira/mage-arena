extends Node

const MAX_RANGE = 150

@export var longsword_ability: PackedScene

var base_damage = 4
var additional_damage_from_upgrades = 0
var additional_damage_percent = 1
var base_wait_time
var longsword_number = 1
var number_of_enemies_to_hit

func _ready():
	var attack_gain_level = MetaProgression.save_data["meta_upgrades"]["attack_gain"]["level"]
	if attack_gain_level >= 1:
		base_damage *= 1 + (attack_gain_level * .2)
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy : Node2D): 
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)

	if longsword_number > enemies.size():
		number_of_enemies_to_hit = enemies.size()
	else :
		number_of_enemies_to_hit = min(longsword_number, 5)

	for i in number_of_enemies_to_hit:
		var longsword_instance = longsword_ability.instantiate() as Node2D
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		foreground_layer.add_child(longsword_instance)
		longsword_instance.hitbox_component.damage = (base_damage + additional_damage_from_upgrades) * additional_damage_percent
		longsword_instance.global_position = enemies[i].global_position
		longsword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4

		var enemy_direction = enemies[i].global_position - longsword_instance.global_position
		longsword_instance.rotation = enemy_direction.angle()

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "longsword":
		if current_upgrades["longsword"]["quantity"] == 2:
			additional_damage_from_upgrades += 2
			pass
		elif current_upgrades["longsword"]["quantity"] == 3:
			additional_damage_from_upgrades += 4
			pass
		elif current_upgrades["longsword"]["quantity"] == 4:
			additional_damage_from_upgrades += 6
			pass
		elif current_upgrades["longsword"]["quantity"] == 5:
			additional_damage_from_upgrades += 8
			pass
		print("Longsword level upgraded. Now: ", current_upgrades["longsword"]["quantity"])
	elif upgrade.id == "cooldown_reduction":
		var percent_reduction = current_upgrades["cooldown_reduction"]["quantity"] * 0.1
		$Timer.wait_time = base_wait_time * (1 - percent_reduction)
		$Timer.start()
		print("Longsword wait time decreased. Now: ", $Timer.wait_time)
	elif upgrade.id == "buff_damage":
		additional_damage_percent = 1 + (current_upgrades["buff_damage"]["quantity"] * .1)
		print("Longsword damage increased. Now: ", base_damage * additional_damage_percent)
	elif upgrade.id == "ability_quantity":
		longsword_number += 1
		print("Number of Longswords increased. Now: ", longsword_number)
