extends Area2D

@export var speed = 400
var screen_size
signal hit

# Variabel Baru untuk Swipe
var touch_start_pos = Vector2.ZERO
var swipe_direction = Vector2.ZERO
var min_swipe_threshold = 50 # Jarak minimal swipe dalam pixel
var target_direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size;

func _input(event):
	if event is InputEventScreenDrag:
		# Selama jari digeser-geser di layar
		var drag_vector = event.relative # Jarak geser antar frame
		target_direction = event.relative.normalized()
		
		if drag_vector.length() > 5: # Threshold kecil biar sensitif
			if abs(drag_vector.x) > abs(drag_vector.y):
				swipe_direction = Vector2(1, 0) if drag_vector.x > 0 else Vector2(-1, 0)
			else:
				swipe_direction = Vector2(0, 1) if drag_vector.y > 0 else Vector2(0, -1)
	if event is InputEventScreenTouch:
		if not event.pressed:
			target_direction = Vector2.ZERO
			swipe_direction = Vector2.ZERO # Stop instan saat lepas jari

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	
	if velocity == Vector2.ZERO:
		swipe_direction = swipe_direction.lerp(target_direction, 0.15)
		velocity = swipe_direction
	
	if velocity.length() > 0.1:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
		
		if abs(velocity.x) * 2 > abs(velocity.y):
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.flip_v = false
		else:
			$AnimatedSprite2D.animation = "up"
			$AnimatedSprite2D.flip_v = velocity.y > 0
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(body: Node2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
