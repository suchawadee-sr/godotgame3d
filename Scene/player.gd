extends CharacterBody3D

signal hit

# How fast the player moves in meters per second.
@export var speed = 8
# The downward acceleration while in the air, in meters per second squared.
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
# Vertical impulse applied to the character upon bouncing over a mob
# in meters per second.
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

# --- Animation control ---
var current_anim = ""

func play_anim(name: String):
	if current_anim == name:
		return
	$Pivot/Character/AnimationPlayer.play(name)
	current_anim = name


func _physics_process(delta):
	# We create a local variable to store the input direction
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly
	if Input.is_action_pressed("move_right"):
		direction.x = direction.x + 1
	if Input.is_action_pressed("move_left"):
		direction.x = direction.x - 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z = direction.z + 1
	if Input.is_action_pressed("move_forward"):
		direction.z = direction.z - 1

	# Prevent diagonal movement being very fast
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)
		# ถ้าเดิน
		if is_on_floor():
			play_anim("Walk")
	else:
		# Idle เฉพาะตอนอยู่บนพื้น
		if is_on_floor():
			play_anim("Idle")

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		# ถ้าอยู่กลางอากาศและกำลังตก
		if target_velocity.y < 0:
			play_anim("Jump_toIdle")

	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		play_anim("Gallop_Jump")

	# Iterate through all collisions that occurred this frame
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)

		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				target_velocity.y = bounce_impulse
				break

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse


func die():
	hit.emit()
	queue_free()


func _on_mob_detector_body_entered(body):
	die()
