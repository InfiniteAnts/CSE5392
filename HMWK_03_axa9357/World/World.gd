extends Spatial

const DEFAULT_MAX_AMMO = 10
var level = Global.level
var index = 0
var rng = RandomNumberGenerator.new()
#-----------------------------------------------------------
func _ready() :
  get_tree().paused = false

  var levelData = _getLevelData( level )

  var ammo = levelData.get( 'AMMO', null )
  if ammo != null :
    _addAmmo( ammo.get( 'tscn', null ), ammo.get( 'instances', [] ) )

  var medikits = levelData.get('HEALTH', null)
  if medikits != null:
    _addMedikit(medikits.get('tscn', null), medikits.get('instances', []))

  var zombies = levelData.get( 'ZOMBIES', null )
  if zombies != null :
    _addZombies( zombies.get( 'tscn', null ), zombies.get( 'instances', [] ), false)

  var obstacles = levelData.get('OBSTACLES', null )
  if obstacles != null:
    _addObstacles(obstacles.get('tscn', null), obstacles.get('instances', []) )

  var portal = levelData.get('PORTAL', null)
  if portal != null:
    _addPortal(portal.get('tscn', null), portal.get('instance'))

  var arenaSize = levelData.get('arenaSize', null)
  if arenaSize != null:
    _addArena(arenaSize.get('floor_tscn', null), arenaSize.get('wall_tscn', null), arenaSize.get('dimensions', []))

  var key = levelData.get('KEY', null)
  if key != null:
    _addKey(key.get('tscn', null), key.get('instance'))

  get_node( 'HUD Layer' )._resetAmmo( levelData.get( 'maxAmmo', DEFAULT_MAX_AMMO ) )
  get_node('HUD Layer')._setPlayerHealth()

#-----------------------------------------------------------
func _input( __ ) :    # Not using event so don't name it.
  if Input.is_action_just_pressed( 'maximize' ) :
    OS.window_fullscreen = not OS.window_fullscreen

#-----------------------------------------------------------
func _addAmmo( model, instances ) :
  var inst
  var index = 0

  if model == null :
    print( 'There were %d ammo but no model?' % len( instances ) )
    return

  var ammoScene = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var amount  = Utils.dieRoll( instInfo[ 1 ] )

    inst = ammoScene.instance()
    inst.name = 'Ammo-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setQuantity( amount )
    print( '%s at %s, %d rounds.' % [ inst.name, str( pos ), amount ] )

    get_node( '.' ).add_child( inst )

#----------------------------------------------------------------------
func _addKey( model, instance):
  var inst

  if model == null :
    print( 'There wasbut no key model?' )
    return

  var keyScene = load( model )

  inst = keyScene.instance()
  inst.name = 'Key'
  inst.translation = Vector3( instance[0], instance[1], instance[2] )
  print( '%s at %s' % [ inst.name, str( instance )])
  get_node( '.' ).add_child( inst )

#----------------------------------------------------------------------
func _addPortal(model, instance):
	var inst
	
	if model == null:
		print('There was no model of portal')
		return
		
	var portalScene = load(model)
	
	var pos = instance[0]
	var health = Utils.dieRoll(instance[1])
	
	inst = portalScene.instance()
	inst.name = 'Portal'
	inst.translation = Vector3(pos[0], pos[1], pos[2])
	inst.setHealth(health)
	
	get_node( '.' ).add_child( inst )
	
func _addMedikit( model, instances ) :
  var inst
  var index = 0

  if model == null :
    print( 'There were %d medkits but no model?' % len( instances ) )
    return

  var mediScene = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var amount  = Utils.dieRoll( instInfo[ 1 ] )

    inst = mediScene.instance()
    inst.name = 'Medikit-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setQuantity( amount )
    print( '%s at %s, %d health.' % [ inst.name, str( pos ), amount ] )

    get_node( '.' ).add_child( inst )




#-------------------------------------------------------------
func _addObstacles(model, instances):
	var inst
	var index = 0
	
	if model == null:
		print('There were %d obstacles but no model?' % len(instances))
		return
	
	var obstacleScene = load(model)
	
	for instInfo in instances:
		index += 1
		
		inst = obstacleScene.instance()
		inst.name = 'Obstacle-%02d' % index
		inst.translation = Vector3(instInfo[0], instInfo[1],  instInfo[2])
		print('%s at %s.' % [inst.name, str(instInfo)])
		
		get_node('.').add_child(inst)

#-----------------------------------------------------------
func _addZombies( model, instances, update_flag ) :
  var inst

  if model == null :
    print( 'There were %d zombie but no model?' % len( instances ) )
    return

  var zombieScene = load( model )
  
  if update_flag:
    get_node('HUD Layer')._updateOpponents()
  else:
    get_node( 'HUD Layer' )._resetOpponents( len( instances ) )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( instInfo[ 1 ] )

    inst = zombieScene.instance()
    inst.name = 'Zombie-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setHealth( hp )
    inst.set_player(get_node('Player'))
    print( '%s at %s, %d hp' % [ inst.name, str( pos ), hp ] )

    get_node( '.' ).add_child( inst )

#-----------------------------------------------------------
func _getLevelData( levelNumber ) :
  var levelData = {}

  var fName = 'res://Levels/Level-%02d.json' % levelNumber

  var file = File.new()
  if file.file_exists( fName ) :
    file.open( fName, file.READ )
    var text_data = file.get_as_text()
    var result_json = JSON.parse( text_data )

    if result_json.error == OK:  # If parse OK
      levelData = result_json.result

    else :
      print( 'Error        : ', result_json.error)
      print( 'Error Line   : ', result_json.error_line)
      print( 'Error String : ', result_json.error_string)

  else :
    print( 'Level %d config file did not exist.' % levelNumber )

  return levelData

#-----------------------------------------------------------
func _addArena(floor_model, wall_model, dimensions):
	var level_floor
	var wall_1
	var wall_2
	var wall_3
	var wall_4
	
	if floor_model == null or wall_model == null:
		print('Error')
		return
	
	var Floor = load(floor_model)
	var Scene = load(wall_model)
	
	level_floor = Floor.instance()
	level_floor.name = 'Level_Floor'
	level_floor.scale = Vector3(dimensions[0] /2, 1, dimensions[1] / 2)
	level_floor.translation = Vector3(0, -2, 0)
	get_node('.').add_child(level_floor)
	
	wall_1 = Scene.instance()
	wall_1.name = 'Wall_1'
	wall_1.scale = Vector3(dimensions[0] / 2, 2, 1)
	wall_1.translation = Vector3(0, 0, -dimensions[1] / 2)
	get_node('.').add_child(wall_1)
	
	wall_3 = Scene.instance()
	wall_3.name = 'Wall_3'
	wall_3.scale = Vector3(dimensions[0] / 2, 2, 1)
	wall_3.translation = Vector3(0, 0, dimensions[1] / 2)
	get_node('.').add_child(wall_3)
	
	wall_2 = Scene.instance()
	wall_2.name = 'Wall_2'
	wall_2.scale = Vector3(1, 2, dimensions[1] / 2)
	wall_2.translation = Vector3(-dimensions[0] / 2, 0, 0)
	get_node('.').add_child(wall_2)
	
	wall_4 = Scene.instance()
	wall_4.name = 'Wall_4'
	wall_4.scale = Vector3(1, 2, dimensions[1] / 2)
	wall_4.translation = Vector3(dimensions[0] / 2, 0, 0)
	get_node('.').add_child(wall_4)
	
func _on_Timer_timeout():
	if not Global.exploded:
		var v = rng.randi_range( 1, 11 )
		if v > 9:
			_addZombies('res://Zombie/Radioactive_Zombie.tscn', [[[ -18.0, 0, -16.0 ], "3+3d6" ]], true)
		else:
			_addZombies('res://Zombie/Zombie.tscn', [[[ -18.0, 0, -16.0 ], "0+1d6" ]], true)
		if $Timer.wait_time > 2:
			$Timer.wait_time -= 1
		$Timer.start()
	
	
