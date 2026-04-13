extends CharacterBody2D
 
var happy_count := 0
var sad_count := 0
var faces := []
 
var button_rect := Rect2(10, 10, 120, 40)
 
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if button_rect.has_point(event.position):
			_generate_faces()
 
func _generate_faces():
	faces.clear()
	var count = randi_range(1, 10)
	var viewport_size = get_viewport_rect().size
 
	for i in count:
		var size = randi_range(20, 150)
		var r = size / 2.0
		var face = {
			"size": size,
			"eyes": randi_range(2, 6),
			"eye_color": Color(randf(), randf(), randf()),
			"happy": randf() < 0.5,
			"pos": Vector2(
				randf_range(r + 10, viewport_size.x - r - 10),
				randf_range(r + 70, viewport_size.y - r - 10)
			)
		}
		if face.happy:
			happy_count += 1
		else:
			sad_count += 1
		faces.append(face)
 
	queue_redraw()
 
func _draw():
	# Button
	draw_rect(button_rect, Color(0.2, 0.2, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(18, 33), "Click Me", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
 
	# Stats
	draw_string(ThemeDB.fallback_font, Vector2(150, 33), "Happy: %d   Sad: %d" % [happy_count, sad_count], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
 
	# Faces
	for face in faces:
		_draw_face(face)
 
func _draw_face(face: Dictionary):
	var pos: Vector2 = face.pos
	var r = face.size / 2.0
 
	# Face
	draw_circle(pos, r, Color(1.0, 0.85, 0.5))
	draw_arc(pos, r, 0, TAU, 64, Color(0.6, 0.4, 0.1), max(1.5, face.size * 0.03))
 
	# Eyes
	var eye_r = max(2.5, face.size * 0.07)
	var eye_count: int = face.eyes
	var rows = 1 if eye_count <= 3 else 2
	var eyes_top = ceil(float(eye_count) / 2.0) if rows == 2 else eye_count
	var eyes_bot = eye_count - eyes_top if rows == 2 else 0
	var spacing = min(face.size * 0.18, (r * 1.2) / (eyes_top + 1))
 
	for row in rows:
		var in_row = eyes_top if row == 0 else eyes_bot
		if in_row == 0:
			continue
		var row_y = pos.y + (-r * 0.2 if row == 0 else r * 0.05)
		var start_x = pos.x - (spacing * (in_row - 1)) / 2.0
		for i in in_row:
			var ep = Vector2(start_x + i * spacing, row_y)
			draw_circle(ep, eye_r, face.eye_color)
			draw_circle(ep + Vector2(-eye_r * 0.3, -eye_r * 0.3), eye_r * 0.3, Color(1, 1, 1, 0.7))
 
	# Mouth (quadratic bezier)
	var mouth_y = pos.y + r * 0.42
	var mouth_w = r * 0.55
	var mouth_h = r * 0.22
	var steps = 20
	var points := PackedVector2Array()
 
	for s in steps + 1:
		var t = float(s) / float(steps)
		var mt = 1.0 - t
		var bx = pos.x + lerp(-mouth_w, mouth_w, t)
		var by: float
		if face.happy:
			by = mt * mt * mouth_y + 2.0 * mt * t * (mouth_y + mouth_h * 2.0) + t * t * mouth_y
		else:
			by = mt * mt * (mouth_y + mouth_h) + 2.0 * mt * t * (mouth_y - mouth_h * 0.8) + t * t * (mouth_y + mouth_h)
		points.append(Vector2(bx, by))
 
	draw_polyline(points, Color(0, 0, 0, 0.8), max(1.5, face.size * 0.025), true)
