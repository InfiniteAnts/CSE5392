extends KinematicBody

const MOVE_SPEED = 3

const Cooldown = preload('res://Cooldown.gd')
onready var explosion_cooldown = Cooldown.new(0.1)

const SENSE_DISTANCE = 30

onready var raycast = $RayCast
onready var anim_player = $AnimationPlayer


var blast_area
var explosion_particles

var explosion_wait_timer = 0
const explosion_life_time = 1.45
onready var explosion = false


var player = null
var dead = false
var health = 1

onready var hit_cooldown = Cooldown.new(0.5)
onready var pause_cooldown = Cooldown.new(10)
onready var zombie_pause = false

#-----------------------------------------------------------
func _ready() :

  anim_player.play( 'walk' )
  add_to_group( 'zombies' )
  blast_area = $Area
  explosion_particles = $Particles

  explosion_particles.emitting = false
  explosion_particles.one_shot = true

#-----------------------------------------------------------
func _physics_process( delta ) :
  if dead :
    return

  if player == null :
    return

  hit_cooldown.tick(delta)
  pause_cooldown.tick(delta)
  var distance = translation.distance_to(player.translation)

  if pause_cooldown.is_ready():
    zombie_pause = false

  # If zombies too far away, they stop their chase
  if zombie_pause:
     anim_player.stop()

  # Else they chase the player
  else:
    zombie_pause = false
    var vec_to_player = player.translation - translation
    vec_to_player = vec_to_player.normalized()
    raycast.cast_to = vec_to_player * 1.5
    move_and_collide(vec_to_player * MOVE_SPEED * delta)
    anim_player.play()

  if raycast.is_colliding() :
    var coll = raycast.get_collider()
    if coll != null and coll.name == 'Player' and hit_cooldown.is_ready():
      coll.hit()
      zombie_pause = true
#-----------------------------------------------------------
func hurt( howMuch = 1 ) :
  health -= howMuch

  if health <= 0 :
    dead = true
    $CollisionShape.disabled = true
    anim_player.play( 'die' )
    explosion_particles.emitting = true
    var bodies = blast_area.get_overlapping_bodies()
    for body in bodies:
        if body.has_method('hit') and explosion_cooldown.is_ready():
          body.hit()
        elif body.has_method('hurt') and body != self and explosion_cooldown.is_ready():
          body.hurt()
    explosion = true
    Global.explosion()
    print( '%s died.' % name )
    $'../Zombie Audio'._playSound( 'die' )
    $'../HUD Layer'._opponentDied()

  else :
    anim_player.play( 'wounded' )
    print( '%s wounded by %d, now has %d.' % [ name, howMuch, health ] )
    $'../Zombie Audio'._playSound( 'grunt' )


func explode():

	$Sprite3D.visible = false
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


#-----------------------------------------------------------
func setHealth( hp ) :
  health =  hp

#-----------------------------------------------------------
func set_player( p ) :
  player = p

#-----------------------------------------------------------
