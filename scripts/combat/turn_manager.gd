class_name TurnManager
extends Node
## Pure turn-based initiative: player units then enemies, repeat.

var _units: Array[CombatUnit] = []
var _index: int = -1
var active: bool = false


func setup(units: Array[CombatUnit]) -> void:
	_units.clear()
	for u in units:
		if u != null and u.is_alive:
			_units.append(u)
	_index = -1


func add_unit(unit: CombatUnit) -> void:
	if unit and not _units.has(unit):
		_units.append(unit)


func remove_unit(unit: CombatUnit) -> void:
	_units.erase(unit)


func start() -> void:
	active = true
	_advance()


func stop() -> void:
	active = false


func get_active_unit() -> CombatUnit:
	if _index < 0 or _index >= _units.size():
		return null
	return _units[_index]


func notify_action_resolved() -> void:
	## Call after the active unit finishes shoot/move/skip.
	var unit := get_active_unit()
	if unit:
		unit.end_turn()
	_advance()


func living_on_team(team: CombatUnit.Team) -> Array[CombatUnit]:
	var result: Array[CombatUnit] = []
	for u in _units:
		if u and u.is_alive and u.team == team:
			result.append(u)
	return result


func _advance() -> void:
	if not active:
		return
	_prune_dead()
	if _units.is_empty():
		return
	var safety := _units.size() + 1
	while safety > 0:
		safety -= 1
		_index = (_index + 1) % _units.size()
		var unit := _units[_index]
		if unit and unit.is_alive:
			unit.begin_turn()
			return


func _prune_dead() -> void:
	var alive: Array[CombatUnit] = []
	for u in _units:
		if u and u.is_alive:
			alive.append(u)
	_units = alive
	if _index >= _units.size():
		_index = _units.size() - 1
