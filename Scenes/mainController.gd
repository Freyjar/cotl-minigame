extends Control


@onready var Player_Col1 = get_tree().get_nodes_in_group("Player_Col1")
@onready var Player_Col2 = get_tree().get_nodes_in_group("Player_Col2")
@onready var Player_Col3 = get_tree().get_nodes_in_group("Player_Col3")
@onready var Enemy_Col1 = get_tree().get_nodes_in_group("Enemy_Col1")
@onready var Enemy_Col2 = get_tree().get_nodes_in_group("Enemy_Col2")
@onready var Enemy_Col3 = get_tree().get_nodes_in_group("Enemy_Col3")

@onready var playerTotal_Col1 = get_tree().get_nodes_in_group("column_totals")[0]
@onready var playerTotal_Col2 = get_tree().get_nodes_in_group("column_totals")[1]
@onready var playerTotal_Col3 = get_tree().get_nodes_in_group("column_totals")[2]

@onready var playerOverallTotal = get_tree().get_nodes_in_group("overall_total")[0]
@onready var enemyOverallTotal = get_tree().get_nodes_in_group("overall_total")[1]

var dicevalue = 0;
var haveDice = false;

func _ready():
	print(playerTotal_Col1)
	print(playerTotal_Col2)
	print(playerTotal_Col3)
	for Col in Player_Col1:
		print(Col.text)

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
		print("this is v", v)
		
			
	for v in count:
		var c = count[v]
		
		if c == 1:
			score += v
		if c == 2:
			score += (v + v) * 2
		elif c == 3:
			score += (v + v + v) * 3	
		print("this is the second loop c", c)
		print("score is: ", score)
		columnTotal.text = str(score)

func CalculateOverallTotal(col1, col2, col3):
	var col1total = int(col1.text)
	var col2total = int(col2.text)
	var col3total = int(col3.text)
	var overallTotal = 0
	
	overallTotal = col1total + col2total + col3total
	playerOverallTotal.text = str(overallTotal)


func _on_getdice_pressed():
	var num = randi_range(1, 6)	
	dicevalue = num
	haveDice = true
	print("Have Dice", haveDice)
	print("Dice Value", dicevalue)
	print()
	
func column_button_pressed(column, column_total_label):
	for col in column:
		if !col.has_meta("value") && haveDice:
			col.set_meta("value", dicevalue)
			haveDice = false
			Calculate(column, column_total_label)
			CalculateOverallTotal(playerTotal_Col1, playerTotal_Col2, playerTotal_Col3)
			col.text = str(dicevalue)
			return


func _on_column1_pressed():
	column_button_pressed(Player_Col1, playerTotal_Col1)
	
func _on_column2_pressed():
	column_button_pressed(Player_Col2, playerTotal_Col2)

func _on_column3_pressed():
	column_button_pressed(Player_Col3, playerTotal_Col3)
