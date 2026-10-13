extends Control

@onready var playerTotal_Col1 = get_tree().get_nodes_in_group("column_totals")[0]
@onready var playerTotal_Col2 = get_tree().get_nodes_in_group("column_totals")[1]
@onready var playerTotal_Col3 = get_tree().get_nodes_in_group("column_totals")[2]

@onready var enemyTotal_Col1 = get_tree().get_nodes_in_group("enemy_column_totals")[0]
@onready var enemyTotal_Col2 = get_tree().get_nodes_in_group("enemy_column_totals")[1]
@onready var enemyTotal_Col3 = get_tree().get_nodes_in_group("enemy_column_totals")[2]

@onready var playerOverallTotal = get_tree().get_nodes_in_group("overall_total")[0]
@onready var enemyOverallTotal = get_tree().get_nodes_in_group("overall_total")[1]

@onready var dicenumber_selected = get_tree().get_nodes_in_group("dice")[0]

@export_group("Player Dice")
@export var Player_Dice_Sprites : Array[Sprite2D]
@export_group("Enemy Dice")
@export var Enemy_Dice_Sprites : Array[Sprite2D]

@export_group("Dice Faces")
@export var dice_faces: Array[Texture2D]

@export_group("Dice Spacing")
@export var dice_spacing: Vector2 = Vector2(32,32)


var dicevalue : int = 0
var haveDice : bool = false
var turn : String = ''
var game_over: bool = false

var Player_Col1: Array[int] = [0,0,0]
var Player_Col2: Array[int] = [0,0,0]
var Player_Col3: Array[int] = [0,0,0]

var Enemy_Col1: Array[int] = [0,0,0]
var Enemy_Col2: Array[int] = [0,0,0]
var Enemy_Col3: Array[int] = [0,0,0]

func _ready() -> void:
	var turnrand: int = randi_range(1,2)
	print(turnrand)
	if(turnrand == 1):
		print("player turn")
		turn = 'player'
	elif(turnrand == 2):
		print("enemy turn")
		turn = 'enemy'
		
	if(turn == 'enemy'):
		enemy_moves()	
		
	arrange_dice(Player_Dice_Sprites)
	arrange_dice(Enemy_Dice_Sprites)


func arrange_dice(sprites: Array[Sprite2D]) -> void:
	for i in range(sprites.size()):
		var slot_index: int = i % 3
		sprites[i].position = Vector2(
			0,
			slot_index * dice_spacing.y
		)
func Calculate(column: Array[int], columnTotal: Label) -> void:
	var count: Dictionary = {}
	var score: int = 0

	for value in column:
		if value == 0:
			continue

		count[value] = count.get(value, 0) + 1

	for value in count:
		var amount: int = count[value]
		score += value * amount * amount

	columnTotal.text = str(score)


func update_dice_sprite(sprite: Sprite2D, value: int) -> void:
	if value == 0:
		sprite.visible = false
		return

	sprite.texture = dice_faces[value - 1]
	sprite.visible = true


func get_column_sprites(is_player: bool, column_index: int) -> Array[Sprite2D]:
	var sprites: Array[Sprite2D] = []
	var source: Array[Sprite2D] = Player_Dice_Sprites if is_player else Enemy_Dice_Sprites
	
	for i in range(3):
		sprites.append(source[column_index * 3 + i])
	print("Requested column: ", column_index + 1)
	print("First sprite returned: ", source[column_index * 3].name)
	return sprites


func get_first_empty_slot(column: Array[int]) -> int:
	for i in range(column.size()):
		if column[i] == 0:
			return i

	return -1


func CalculateOverallTotal(col1, col2, col3, overall_label):
	var total = safe_int(col1) + safe_int(col2) + safe_int(col3)
	overall_label.text = str(total)
	
func safe_int(label):
	return int(label.text) if label.text.is_valid_int() else 0
	
func _on_getdice_pressed():
	var num = randi_range(1, 6)	
	dicevalue = num
	haveDice = true
	dicenumber_selected.text = "Dice: " + str(dicevalue)
	

func column_button_pressed(column_index: int) -> void:
	if turn != "player" or not haveDice:
		return

	var column: Array[int]
	var opposing_column: Array[int]
	var column_total_label: Label
	var opposing_total: Label

	match column_index:
		0:
			column = Player_Col1
			opposing_column = Enemy_Col1
			column_total_label = playerTotal_Col1
			opposing_total = enemyTotal_Col1
		1:
			column = Player_Col2
			opposing_column = Enemy_Col2
			column_total_label = playerTotal_Col2
			opposing_total = enemyTotal_Col2
		2:
			column = Player_Col3
			opposing_column = Enemy_Col3
			column_total_label = playerTotal_Col3
			opposing_total = enemyTotal_Col3

	var slot: int = get_first_empty_slot(column)
	if slot == -1:
		print("That column is full!")
		return

	column[slot] = dicevalue

	var sprites := get_column_sprites(true, column_index)
	update_dice_sprite(sprites[slot], dicevalue)

	deleteDice(dicevalue, opposing_column, opposing_total, false, column_index)
	Calculate(column, column_total_label)
	update_all_totals()

	haveDice = false
	turn = "enemy"
	check_endGame(playerOverallTotal, enemyOverallTotal)

	if not game_over:
		await get_tree().create_timer(1.0).timeout
		enemy_moves()
			

func enemy_moves() -> void:
	if turn != "enemy":
		return

	if all_columns_full(Enemy_Col1, Enemy_Col2, Enemy_Col3):
		check_endGame(playerOverallTotal, enemyOverallTotal)
		return

	var columns: Array = [
		[Enemy_Col1, enemyTotal_Col1, 0, Player_Col1, playerTotal_Col1],
		[Enemy_Col2, enemyTotal_Col2, 1, Player_Col2, playerTotal_Col2],
		[Enemy_Col3, enemyTotal_Col3, 2, Player_Col3, playerTotal_Col3]
	]

	var available_columns: Array = []

	for entry in columns:
		if get_first_empty_slot(entry[0]) != -1:
			available_columns.append(entry)

	var choice: Array = available_columns.pick_random()
	var column: Array[int] = choice[0]
	var total_label: Label = choice[1]
	var column_index: int = choice[2]
	var opposing_column: Array[int] = choice[3]
	var opposing_total: Label = choice[4]

	var enemy_dice: int = randi_range(1, 6)
	var slot: int = get_first_empty_slot(column)

	print("Enemy rolled: ", enemy_dice)
	print("Enemy column: ", column_index + 1)
	print("Player column before deletion: ", opposing_column)
	column[slot] = enemy_dice

	var sprites: Array[Sprite2D] = get_column_sprites(false, column_index)
	update_dice_sprite(sprites[slot], enemy_dice)

	deleteDice(enemy_dice, opposing_column, opposing_total, true, column_index)

	Calculate(column, total_label)
	update_all_totals()

	turn = "player"
	check_endGame(playerOverallTotal, enemyOverallTotal)



func deleteDice(
	dice: int,
	opposing_column: Array[int],
	opposing_column_total: Label,
	opposing_is_player: bool,
	column_index: int
) -> void:
	var sprites: Array[Sprite2D] = get_column_sprites(
		opposing_is_player, column_index
	)

	for i in range(opposing_column.size()):
		print("Checking slot ", i,
			" | Dice to match: ", dice,
			" | Existing dice: ", opposing_column[i])

		if dice != 0 and opposing_column[i] == dice:
			print("MATCH! Deleting slot ", i)
			opposing_column[i] = 0
			update_dice_sprite(sprites[i], 0)

	Calculate(opposing_column, opposing_column_total)
	update_all_totals()
		

func update_all_totals() -> void:
	Calculate(Player_Col1, playerTotal_Col1)
	Calculate(Player_Col2, playerTotal_Col2)
	Calculate(Player_Col3, playerTotal_Col3)

	Calculate(Enemy_Col1, enemyTotal_Col1)
	Calculate(Enemy_Col2, enemyTotal_Col2)
	Calculate(Enemy_Col3, enemyTotal_Col3)

	CalculateOverallTotal(
		playerTotal_Col1, playerTotal_Col2,
		playerTotal_Col3, playerOverallTotal
	)

	CalculateOverallTotal(
		enemyTotal_Col1, enemyTotal_Col2,
		enemyTotal_Col3, enemyOverallTotal
	)


func check_endGame(playertotal: Label, enemytotal: Label) -> void:
	if not all_columns_full(Player_Col1, Player_Col2, Player_Col3) \
	and not all_columns_full(Enemy_Col1, Enemy_Col2, Enemy_Col3):
		return

	if game_over:
		return

	game_over = true

	var player_score: int = safe_int(playertotal)
	var enemy_score: int = safe_int(enemytotal)

	if player_score > enemy_score:
		print("Player wins!")
	elif enemy_score > player_score:
		print("Enemy wins!")
	else:
		print("It's a tie!")
		

func all_columns_full(
	col1: Array[int],
	col2: Array[int],
	col3: Array[int]
) -> bool:
	for value in col1:
		if value == 0:
			return false

	for value in col2:
		if value == 0:
			return false

	for value in col3:
		if value == 0:
			return false

	return true


	
##############################
#Button functions
##############################
func _on_column1_pressed():
	column_button_pressed(0)
	
func _on_column2_pressed():
	column_button_pressed(1)

func _on_column3_pressed():
	column_button_pressed(2)
