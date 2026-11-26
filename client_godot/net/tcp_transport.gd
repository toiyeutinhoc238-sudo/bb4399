extends "byte_transport.gd"

var _peer: StreamPeerTCP = StreamPeerTCP.new()
var _connected: bool = false
var _output: PackedByteArray = PackedByteArray()

func start(endpoint: Dictionary) -> Error:
	stop()
	_peer = StreamPeerTCP.new()
	var result: Error = _peer.connect_to_host(endpoint["host"], int(endpoint["port"]))
	active = result == OK
	return result

func poll() -> void :
	if not active:
		return
	_peer.poll()
	var status: int = _peer.get_status()
	if status == StreamPeerTCP.STATUS_ERROR or status == StreamPeerTCP.STATUS_NONE:
		fail("Mất kết nối với máy chủ.")
		return
	if status != StreamPeerTCP.STATUS_CONNECTED:
		return
	if not _connected:
		_connected = true
		_peer.set_no_delay(true)
		opened.emit()
	if not active:
		return
	if not _output.is_empty():
		var sent: Array = _peer.put_partial_data(_output)
		if sent[0] != OK:
			fail("Không gửi được dữ liệu tới máy chủ.")
			return
		_output = _output.slice(int(sent[1]))

	var count: int = mini(_peer.get_available_bytes(), 65536)
	if count > 0:
		var received: Array = _peer.get_partial_data(count)
		if received[0] != OK:
			fail("Không đọc được dữ liệu từ máy chủ.")
		else:
			bytes_received.emit(received[1])

func send_bytes(data: PackedByteArray) -> Error:
	if not active or not _connected:
		return ERR_UNCONFIGURED
	if _output.size() + data.size() > MAX_QUEUE:
		return ERR_BUSY
	_output.append_array(data)
	return OK

func stop() -> void :
	_peer.disconnect_from_host()
	_output.clear()
	_connected = false
	active = false
