extends Node

var correct_answers_count: int = 0
var incorrect_answers_count: int = 0
var distraction_level: int = 0

func add_correct_answer():
    correct_answers_count += 1
    print("correct answers %s" % correct_answers_count)

func add_incorrect_answer():
    incorrect_answers_count += 1
    print("incorrect answers %s" % incorrect_answers_count)