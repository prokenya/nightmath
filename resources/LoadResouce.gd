extends Node

# Словарь для хранения кэша ресурсов
var resource_cache: Dictionary = {}

# Метод для загрузки ресурса
func load_resource(path: String) -> Resource:
	# Проверяем, есть ли ресурс в кэше
	if resource_cache.has(path):
		return resource_cache[path]
	
	# Если ресурса нет в кэше, загружаем его
	var resource = load(path)
	if resource:
		resource_cache[path] = resource
	return resource

# Метод для очистки кэша
func clear_cache():
	resource_cache.clear()

# Метод для удаления конкретного ресурса из кэша
func unload_resource(path: String):
	if resource_cache.has(path):
		resource_cache.erase(path)
