extends Control


@onready var Player_Col1 = get_tree().get_nodes_in_group("Player_Col1")
@onready var Player_Col2 = get_tree().get_nodes_in_group("Player_Col2")
@onready var Player_Col3 = get_tree().get_nodes_in_group("Player_Col3")
@onready var Enemy_Col1 = get_tree().get_nodes_in_group("Enemy_Col1")
@onready var Enemy_Col2 = get_tree().get_nodes_in_group("Enemy_Col2")
@onready var Enemy_Col3 = get_tree().get_nodes_in_group("Enemy_Col3")

#@onready var playerTotal_Col1 = get_tree().get_node("Player_Col1Total")
#@onready var playerTotal_Col2 = get_tree().get_node("Player_Col2Total")
#@onready var playerTotal_Col3 = get_tree().get_node("Player_Col3Total")

var dicevalue = 0;
var haveDice = false;

func _ready():
	for Col in Player_Col1:
		print(Col.text)

func Calculate(column):
	var score = 0
	var count = {}
	
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


func _on_getdice_pressed():
	var num = randi_range(1, 6)	
	dicevalue = num
	haveDice = true
	print("Have Dice", haveDice)
	print("Dice Value", dicevalue)
	print()
	
func _on_Col1_pressed():
	for col in Player_Col1:
		if !col.has_meta("value") && haveDice:
			col.set_meta("value", dicevalue)
			col.text = str(dicevalue)
			haveDice = false
			Calculate(Player_Col1)
			return
