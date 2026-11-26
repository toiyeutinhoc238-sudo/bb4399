extends RefCounted

signal opened
signal bytes_received(data: PackedByteArray)
signal ended(reason: String)

const MAX_QUEUE: int = 262144
var active: bool = false

func start(_endpoint: Dictionary) -> Error:
	return ERR_UNAVAILABLE

func poll() -> void :
	pass

func send_bytes(_data: PackedByteArray) -> Error:
	return ERR_UNAVAILABLE

func stop() -> void :
	active = false

func fail(reason: String) -> void :
	stop()
	ended.emit(reason)
