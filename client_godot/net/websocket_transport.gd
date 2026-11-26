extends "byte_transport.gd"

var _peer: WebSocketPeer = WebSocketPeer.new()
var _connected: bool = false
var close_code: int = 0



const MAX_PACKETS: int = 16384
var flood: int = 0
var backlog: int = 0

func start(endpoint: Dictionary) -> Error:
	stop()
	close_code = 0
	_peer = WebSocketPeer.new()

	_peer.inbound_buffer_size = MAX_QUEUE * 16
	_peer.outbound_buffer_size = MAX_QUEUE
	_peer.max_queued_packets = MAX_PACKETS
	flood = 0
	backlog = 0

	if not OS.has_feature("web"):
		_peer.handshake_headers = PackedStringArray(["Origin: " + str(endpoint["origin"])])
	var result: Error = _peer.connect_to_url(endpoint["url"])
	active = result == OK
	return result

func poll() -> void :
	if not active:
		return
	_peer.poll()
	var state: int = _peer.get_ready_state()
	if state == WebSocketPeer.STATE_CLOSED:
		close_code = _peer.get_close_code()
		fail("Mất kết nối với máy chủ.")
		return
	if state != WebSocketPeer.STATE_OPEN:
		return
	if not _connected:
		_connected = true
		opened.emit()

	var count: int = 0
	backlog = _peer.get_available_packet_count()
	flood = 2 if backlog >= MAX_PACKETS - 1 else (1 if backlog >= (MAX_PACKETS * 3) >> 2 else 0)
	while active and _peer.get_available_packet_count() > 0 and count < 4096:
		var data: PackedByteArray = _peer.get_packet()
		if _peer.was_string_packet():
			fail("Máy chủ gửi dữ liệu không đúng dạng.")
			return
		bytes_received.emit(data)
		count += 1

func send_bytes(data: PackedByteArray) -> Error:
	if not active or not _connected:
		return ERR_UNCONFIGURED
	if _peer.get_current_outbound_buffered_amount() + data.size() > MAX_QUEUE:
		return ERR_BUSY
	return _peer.send(data, WebSocketPeer.WRITE_MODE_BINARY)

func stop() -> void :
	if _peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_peer.close(1000)

	_peer = WebSocketPeer.new()
	_connected = false
	active = false
