extends Node












const Client = preload("../game_client.gd")








signal released
const HOLD_GRACE: float = 0.3
static var _holders: Array = []

static func hold_enter(owner: Object) -> void :
	if owner == null:
		return
	for ref: Variant in _holders:
		if ref is WeakRef and (ref as WeakRef).get_ref() == owner:
			return
	_holders.append(weakref(owner))

static func hold_leave(owner: Object) -> void :
	var keep: Array = []
	for ref: Variant in _holders:
		if ref is WeakRef:
			var who: Variant = (ref as WeakRef).get_ref()
			if who != null and who != owner:
				keep.append(ref)
	_holders = keep


static func held() -> bool:
	for ref: Variant in _holders:
		if not ref is WeakRef:
			continue
		var who: Variant = (ref as WeakRef).get_ref()
		if who == null:
			continue
		if who is CanvasItem and not (who as CanvasItem).is_visible_in_tree():
			continue
		return true
	return false

var _held_was: bool = false
var _held_calm: float = 0.0

const GAP: float = 0.1
const OPEN_IN: Array = ["lobby", "hall", "room"]
const LIVE: Array = ["lobby", "hall", "room", "battle"]

var client: Client
var popping: String = ""
var _ids: Array = []
var _params: Array = []
var _openers: Dictionary = {}
var _calm: bool = false
var _wait: int = 0

var hold: bool = false:
	set(value):
		var was: bool = hold
		hold = value
		if was and not value:
			_pop.call_deferred()

func _ready() -> void :
	if client != null and not client.changed.is_connected(_on_state):
		client.changed.connect(_on_state)


func _process(delta: float) -> void :
	if held():
		_held_was = true
		_held_calm = 0.0
	elif _held_was:
		_held_calm += delta
		if _held_calm >= HOLD_GRACE:
			_held_was = false
			_held_calm = 0.0
			released.emit()
			_pop()


func busy() -> bool:
	return hold or held()


func register(id: String, opener: Callable) -> void :
	_openers[id] = opener

func append(id: String, param: Variant = null) -> void :
	_ids.append(id)
	_params.append(param)
	_pop()

func has(id: String) -> bool:
	return _ids.has(id)


func param(id: String, fallback: Variant = null) -> Variant:
	var at: int = _ids.find(id)
	return _params[at] if at >= 0 else fallback

func waiting() -> Array:
	return _ids.duplicate()


func closed() -> void :
	_wait += 1
	if not is_inside_tree():
		_wake(_wait)
		return
	_calm = true
	var ticket: int = _wait
	get_tree().create_timer(GAP).timeout.connect( func() -> void : _wake(ticket))

func _wake(ticket: int) -> void :
	if ticket != _wait:
		return
	_calm = false
	popping = ""
	_pop()

func _on_state() -> void :
	if client == null:
		return
	if client.state not in LIVE:
		clear()
		return
	_pop()


func clear() -> void :
	_ids.clear()
	_params.clear()
	popping = ""
	_calm = false
	_wait += 1

func _pop() -> void :
	if client == null or not popping.is_empty() or _calm or client.state not in OPEN_IN or hold or held():
		return
	while not _ids.is_empty():
		var id: String = str(_ids.pop_front())
		var value: Variant = _params.pop_front()
		var opener: Callable = _openers.get(id, Callable())
		if not opener.is_valid():
			continue
		popping = id
		if opener.call(value) == true:
			return
		popping = ""
