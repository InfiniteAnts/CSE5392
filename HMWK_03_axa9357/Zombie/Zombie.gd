extends KinematicBody

const MOVE_SPEED = 3

const Cooldown = preload('res://Cooldown.gd')

const SENSE_DISTANCE = 30

onready var raycast = $RayCast
onready var anim_player = $AnimationPlayer

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
    print( '%s died.' % name )
    $'../Zombie Audio'._playSound( 'die' )
    $'../HUD Layer'._opponentDied()

  else :
    anim_player.play( 'wounded' )
    print( '%s wounded by %d, now has %d.' % [ name, howMuch, health ] )
    $'../Zombie Audio'._playSound( 'grunt' )

#-----------------------------------------------------------
func setHealth( hp ) :
  health =  hp

#-----------------------------------------------------------
func set_player( p ) :
  player = p

#-----------------------------------------------------------
