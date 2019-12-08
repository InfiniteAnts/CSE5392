extends Spatial

#var player = null
var health = 1

const Cooldown = preload('res://Cooldown.gd')
onready var explosion_cooldown = Cooldown.new(0.1)

var blast_area
var explosion_particles

var explosion_wait_timer = 0
const explosion_life_time = 1.45

onready var explosion = false
func _ready():
	blast_area = $Area
	explosion_particles = $Particles

	explosion_particles.emitting = false
	explosion_particles.one_shot = true
	
func _process(delta):
	
	explosion_cooldown.tick(delta)
	
	if explosion:
		
		explosion_wait_timer += delta
		
		if explosion_wait_timer >= explosion_life_time:
			self.queue_free()

func hurt(howMuch = 1):
  health -= howMuch
  if health <= 0:
    explode()

func explode():

	$'node-0'.visible = false
	$CollisionShape.disabled = true
	explosion_particles.emitting = true
	var bodies = blast_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method('hit') and explosion_cooldown.is_ready():
			body.hit()
		elif body.has_method('hurt') and body != self and explosion_cooldown.is_ready():
			body.hurt()
	explosion = true
	Global.explosion()
	
func setHealth( hp ) :
  health =  hp
