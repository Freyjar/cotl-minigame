extends Control


@onready var Player_Col1: Array = get_tree().get_nodes_in_group("Player_Col1")
@onready var Player_Col2: Array = get_tree().get_nodes_in_group("Player_Col2")
@onready var Player_Col3: Array = get_tree().get_nodes_in_group("Player_Col3")
@onready var Enemy_Col1: Array = get_tree().get_nodes_in_group("Enemy_Col1")
@onready var Enemy_Col2: Array = get_tree().get_nodes_in_group("Enemy_Col2")
@onready var Enemy_Col3: Array = get_tree().get_nodes_in_group("Enemy_Col3")

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

var dicevalue : int = 0
var haveDice : bool = false
var turn : String = ''

func _ready():
	var turnrand = randi_range(1,2)
	print(turnrand)
	if(turnrand == 1):
		print("player turn")
		turn = 'player'
	elif(turnrand == 2):
		print("enemy turn")
		turn = 'enemy'
		
	if(turn == 'enemy'):
		enemy_moves()	

func Calculate(column, columnTotal):

	var count = {}
	var score = 0
	for col in column:
		if !col.has_meta("value"):
			continue
		
		var v = col.get_meta("value")
		if v in count:
			count[v] += 1
		else:
			count[v] = 1
		#print("this is v", v)
		
			
	for v in count:
		var c = count[v]
		
		if c == 1:
			score += v
		elif c == 2:
			score += (v + v) * 2
		elif c == 3:
			score += (v + v + v) * 3	
		#print("this is the second loop c", c)
		#print("score is: ", score)
	columnTotal.text = str(score)

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
	
func column_button_pressed(column, column_total_label, overall_total_label):
	var opposingcolumn: Array
	var opposingcolumn_total
	if(column == Player_Col1):
		opposingcolumn = Enemy_Col1
		opposingcolumn_total = enemyTotal_Col1
	elif (column == Player_Col2):
		opposingcolumn = Enemy_Col2
		opposingcolumn_total = enemyTotal_Col2
	elif (column == Player_Col3):
		opposingcolumn = Enemy_Col3
		opposingcolumn_total = enemyTotal_Col3
		
	for col in column:
		if !col.has_meta("value") && haveDice && turn == 'player':
			col.set_meta("value", dicevalue)
			deleteDice(dicevalue, opposingcolumn, opposingcolumn_total)
			haveDice = false
			turn = 'enemy'
			Calculate(column, column_total_label)
			CalculateOverallTotal(playerTotal_Col1, playerTotal_Col2, playerTotal_Col3, overall_total_label)
			col.text = str(dicevalue)
			
			turn = "enemy"
			check_endGame(playerOverallTotal, enemyOverallTotal)
			enemy_moves()
			return
			
			
func enemy_moves():		
	var enemy_dice = randi_range(1, 6)
	var columns = [
		[Enemy_Col1, enemyTotal_Col1],
		[Enemy_Col2, enemyTotal_Col2],
		[Enemy_Col3, enemyTotal_Col3]
	]
	#choosing from the list of columns ^^^
	var choice = columns[randi_range(0, 2)]
	#assigning chosen column values to variables
	var column = choice[0]
	var total_label = choice[1]
	var column_full = true
	
	var opposingcolumn: Array
	var opposingcolumn_total
	if(column == Enemy_Col1):
		opposingcolumn = Player_Col1
		opposingcolumn_total = playerTotal_Col1
	elif (column == Enemy_Col2):
		opposingcolumn = Player_Col2
		opposingcolumn_total = playerTotal_Col2
	elif (column == Enemy_Col3):
		opposingcolumn = Player_Col3
		opposingcolumn_total = playerTotal_Col3
	
	#reassign if the column doesn't have space
	for col in column:
		if !col.has_meta("value"):
			column_full = false
			break
			
	if(column_full):
		enemy_moves()

	for col in column:
		if !col.has_meta("value"):
			col.set_meta("value", enemy_dice)
			col.text = str(enemy_dice)

			deleteDice(enemy_dice, opposingcolumn, opposingcolumn_total)
			Calculate(column, total_label)
			
			CalculateOverallTotal(
				enemyTotal_Col1,
				enemyTotal_Col2,
				enemyTotal_Col3,
				enemyOverallTotal
			)
			turn = "player"
			check_endGame(playerOverallTotal, enemyOverallTotal)
			return
		
func deleteDice(dice, opposingcolumn, opposingcolumn_total): 
	
	#first get the dice
	#second get the opposing column
	#FOR LOOP OPPOSING COLUMN TO CHECK IF THE DIE IS EQUAL TO ANY 
	#IF IT IS EQUAL TO ANY: DELETE THE OPPOSING COLUMN 
	
	for col in opposingcolumn:
		if col.has_meta("value") && col.get_meta("value") == dice:
			col.remove_meta("value")
			col.text = ""
			Calculate(opposingcolumn, opposingcolumn_total)

			CalculateOverallTotal(
				enemyTotal_Col1,
				enemyTotal_Col2,
				enemyTotal_Col3,
				enemyOverallTotal
			)
			CalculateOverallTotal(
				playerTotal_Col1,
				playerTotal_Col2,
				playerTotal_Col3,
				playerOverallTotal
			)
			print('deleted', opposingcolumn)
		
		
		
func check_endGame(playertotal, enemytotal) -> void:
	print("check please")
	if all_columns_full(Player_Col1, Player_Col2, Player_Col3):
		print("gameend player1 board full")
	if all_columns_full(Enemy_Col1, Enemy_Col2, Enemy_Col3):
		print("gameend enemy board full")		
		
	if(safe_int(playertotal) > safe_int(enemytotal)):
		print("player wins")
	else:
		print("enemy wins")	
		
func all_columns_full(col1, col2, col3):
	for col in col1:
		if !col.has_meta("value"):
			return false
	for col in col2:
		if !col.has_meta("value"):
			return false
	for col in col3:
		if !col.has_meta("value"):
			return false
	return true		

	
##############################
#Button functions
##############################
func _on_column1_pressed():
	column_button_pressed(Player_Col1, playerTotal_Col1, playerOverallTotal)
	
func _on_column2_pressed():
	column_button_pressed(Player_Col2, playerTotal_Col2, playerOverallTotal)

func _on_column3_pressed():
	column_button_pressed(Player_Col3, playerTotal_Col3, playerOverallTotal)
