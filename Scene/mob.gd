extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 5
# Maximum speed of the mob in meters per second.
@export var max_speed = 8

# Emitted when the player jumped on the mob
signal squashed

# เก็บ reference ของ AnimationPlayer (อยู่ใต้ FrogArmature)
@onready var anim_player: AnimationPlayer = $FrogArmature/AnimationPlayer

var current_anim := ""

# ฟังก์ชันนี้จะถูกเรียกเพียงครั้งเดียวเมื่อโหนดพร้อมใช้งาน
func _ready():
	# ตรวจสอบว่ามี AnimationPlayer และมีแอนิเมชันชื่อ "Frog_Jump" หรือไม่
	if anim_player and anim_player.has_animation("Frog_Jump"):
		# ตั้งค่าให้แอนิเมชัน "Frog_Jump" เล่นวนลูป
		anim_player.get_animation("Frog_Jump").loop_mode = Animation.LOOP_LINEAR

func play_anim(name: String):
	if current_anim == name:
		return
	if anim_player: # ป้องกัน null
		anim_player.play(name)
		current_anim = name

func _physics_process(_delta):
	move_and_slide()

# This function will be called from the Main scene.
func initialize(start_position, player_position):
	# วาง mob ไว้ที่ start_position และหันไปทาง player
	look_at_from_position(start_position, player_position, Vector3.UP)
	# หมุนแบบสุ่ม -45 ถึง 45 องศา
	rotate_y(randf_range(-PI / 4, PI / 4))

	# random speed
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)

	# set animation speed scale
	if anim_player:
		anim_player.speed_scale = float(random_speed) / float(min_speed)

	# เล่นแอนิเมชัน Frog_Jump ตอน spawn
	play_anim("Frog_Jump")

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()

func squash():
	squashed.emit()
	# TODO: ถ้ามีแอนิเมชันตาย (เช่น Frog_Death) ใส่ตรงนี้
	# play_anim("Frog_Death")
	# await anim_player.animation_finished
	queue_free()
