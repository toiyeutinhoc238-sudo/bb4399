extends RefCounted







const Atlas = preload("helper_select_atlas.gd")
const HelperAtlas = preload("helper_atlas.gd")
const GarageModel = preload("garage_model.gd")
const BagModel = preload("bag_model.gd")

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)

var uuid: String = ""
var row: int = 0


func open(view) -> void :
	uuid = ""
	row = 0
	view._sheet_id = "select"

func _lines(view) -> int:
	return maxi(int(Atlas.TILE.rows), view._lines(view._list.size()))

func _top(view) -> int:
	return maxi(0, _lines(view) - int(Atlas.TILE.rows))


func activate(view, id: String) -> void :
	if id.begins_with("hs:cell:"):
		if not view._find(id.substr(8)).is_empty():
			uuid = id.substr(8)
	elif id == "hs:ok":
		view._close()
		var rec: Dictionary = view._find(uuid)
		if uuid.is_empty() or rec.is_empty():
			return
		if view._busy():
			return
		if view.client.helper_battle(str(rec.uuid)):
			view._wait("battle", rec)
		else:
			view._fail()
	elif id in ["hs:close", "cancel"]:
		view._close()
	elif id.begins_with("sb:hs:"):
		row = clampi(row + (-1 if id.ends_with(":up") else 1), 0, _top(view))


func wheel(view, step: int, at: Vector2) -> void :
	var tile: Array = Atlas.NODES.tlHelpers
	var spot: Vector2 = at / view._f - view._centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	if Rect2(float(tile[0]), float(tile[1]), float(tile[2]), float(tile[3])).has_point(spot):
		row = clampi(row + step, 0, _top(view))

func draw(view) -> void :
	if not view._cells.has("hs_frame"):
		view._use(Atlas.FILE, Atlas.R)
	row = clampi(row, 0, _top(view))
	view.draw_rect(Rect2(Vector2.ZERO, view.size), DIM)
	view._hit("shade", Rect2(Vector2.ZERO, view.size), false)
	var at: Vector2 = view._centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	var frame: Vector2 = at + view._hv(Atlas.PANELS.frame)
	view._hit("panel", Rect2(frame * view._f, view._cell_size("hs_frame") * view._f), false)
	view._fblit("hs_frame", frame)
	var tile: Array = Atlas.NODES.tlHelpers
	var first: Vector2 = at + view._hv(tile)
	var cols: int = int(Atlas.TILE.cols)
	var step: float = float(Atlas.TILE.cell) + float(Atlas.TILE.gap)
	var from: int = row * cols
	var cell: Dictionary = HelperAtlas.CELL
	for i in range(cols * int(Atlas.TILE.rows)):
		var spot: Vector2 = first + Vector2((i % cols) * step, floori(float(i) / cols) * step)
		view._fblit("hp_cell_bg", spot)
		if from + i >= view._list.size():
			continue
		var rec: Dictionary = view._list[from + i]
		view._draw_cell_helper(rec, spot)
		if str(rec.uuid) == uuid:
			view._fblit("hs_select", spot + view._hv(Atlas.SELECT_AT))
			if rec.battle:
				view._fblit("hp_cell_battle", spot + view._hv(cell.battle))
		var id: String = "hs:cell:" + str(rec.uuid)
		var rect: Rect2 = Rect2(spot * view._f, view._hv(cell.bg, 2) * view._f)
		view._hit(id, rect)
		view._htip_on(id, rect, rec, "", true)
	_draw_scroll(view, first, float(tile[2]), float(tile[3]))
	view._fbutton("hs:ok", "hs_confirm", at + view._hv(Atlas.NODES.btnConfirm))
	view._fbutton("hs:close", "public_button_close", at + view._hv(Atlas.NODES.btnClose))
	view._draw_tip()


func _draw_scroll(view, first: Vector2, wide: float, high: float) -> void :
	var total: int = _lines(view)
	var shown: int = int(Atlas.TILE.rows)
	if total <= shown:
		return
	var spot: Vector2 = first + Vector2(wide - 19.0, 0)
	view._fbutton("sb:hs:up", "hp_sb_up", spot)
	view._fbutton("sb:hs:down", "hp_sb_down", spot + Vector2(0, high - 19.0))
	var track: float = high - 38.0
	view._hslice("hp_sb_bk", spot + Vector2(0, 19), track)
	var thumb: float = maxf(20.0, track * shown / total)
	var y: float = (track - thumb) * row / maxf(1.0, float(total - shown))
	view._hslice("hp_sb_thumb", spot + Vector2(0, 19.0 + y), thumb)
	view._knob_hit("slide:hs", Rect2((spot + Vector2(0, 19.0 + y)) * view._f, Vector2(19, thumb) * view._f), row, total - shown, (track - thumb) * view._f, 
		func(value: float) -> void : row = clampi(roundi(value), 0, total - shown))
