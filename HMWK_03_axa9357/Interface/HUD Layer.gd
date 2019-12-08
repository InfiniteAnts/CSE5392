extends CanvasLayer

var elapsedTime = 0
var lastTime    = 0
const no_of_levels = 3
#-----------------------------------------------------------
func _ready() :
  elapsedTime = 0

#-----------------------------------------------------------
func _process( delta ) :
  _updateHUDTime( delta )

#-----------------------------------------------------------
func _updateHUDTime( delta ) :
  elapsedTime += delta

  if elapsedTime - lastTime > 1 :
    lastTime = elapsedTime

    get_node( 'LevelTime' ).text = getTimeStr()

func getTimeStr() :
  var minutes = int( elapsedTime / 60 )
  var seconds = int( elapsedTime - minutes*60 )

  return '%02d:%02d' % [ minutes, seconds ]

#-----------------------------------------------------------
var maxAmmo = 0
var numAmmo = 0

func _resetAmmo( qty ) :
  maxAmmo = qty
  numAmmo = qty
  _setAmmoMessage()

func _setAmmoMessage() :
  get_node( 'Ammo' ).text = '%d / %d' % [ numAmmo, maxAmmo ]

func _ammoUsed() :
  var success = numAmmo != 0

  if success :
    numAmmo -= 1

  _setAmmoMessage()
  return success

func _updateAmmo(qty):
	numAmmo += qty
	numAmmo = clamp(numAmmo, 0, maxAmmo)
	_setAmmoMessage()
#-----------------------------------------------------------
var maxOpponents = 0
var numOpponents = 0

func _updateOpponents():
	numOpponents += 1
	maxOpponents += 1

func _resetOpponents( qty ) :
  maxOpponents = qty
  numOpponents = qty
  _setOpponentMessage()

func _setOpponentMessage() :
  get_node( 'Opponents' ).text = '%d / %d' % [ numOpponents, maxOpponents ]

func _opponentDied() :
  numOpponents -= 1
  _setOpponentMessage()

  if numOpponents == 0 :
    Global.next_level()
    var timeStr = $'../HUD Layer'.getTimeStr()
  
    print( 'Last opponent died at %s.' % timeStr )

	# Game completed
    if Global.level > no_of_levels:
        Global.level = 1
        $'../Message Layer/Message'.activate( 'Completed the Game!\n%s' % timeStr )
    else:
        $'../Message Layer/Message/Background/Restart'.text = 'Next'
        $'../Message Layer/Message'.activate( 'Player Wins!\n%s' % timeStr )
#-----------------------------------------------------------
var playerHealth = 3
var max_playerHealth = 3
func _setPlayerHealth():
	get_node('Player_Health').text = '%d / %d' % [playerHealth, max_playerHealth]
	
func _playerHit():
	playerHealth -= 1
	_setPlayerHealth()

func _playerHeal(qty):
	playerHealth += qty
	playerHealth = clamp(playerHealth, 0, max_playerHealth)
	$'../Player'.heal(qty)
	_setPlayerHealth()
	
func _gotKey():
	$Key.visible = true