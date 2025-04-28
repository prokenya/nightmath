extends Resource 
class_name Data

@export var items:Dictionary
#id:[world_item,inventory_item,texture,st_lim,subnode,name]

@export var tasks:Dictionary

@export var in_code_localisation:Dictionary = {
	"en":[
	"Write your name!",
	"Sorry, such a person is dead",
	"hello ",
	"goodbye ",
	"I don't have any more assignments for you.",
	"stop!",
	"this task has been written off",
	],
	"ru":[
		"Напишите свое имя!",
		"К сожалению, такой человек мертв.",
		"привет ",
		"Прощай ",
		"у меня больше нет заданий для тебя",
		"стой!",
		"списано!"
		],
	"uk":[
		"Напишіть своє ім'я!",
		"На жаль, така людина померла",
		"привіт ",
		"Прощавай ",
		"У мене більше немає для тебе завдань.",
		"стій!",
		"списано з Рєщєбніка"]
	}

func save() -> void:
	ResourceSaver.save(self, "res://resources/gamedata.tres")

static  func load_or_create() -> Data:
	var res: Data = load("res://resources/gamedata.tres") as Data
	if !res:
		res = Data.new()
	return res
