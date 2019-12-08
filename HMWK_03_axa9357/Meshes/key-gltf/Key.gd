extends Spatial

export var rotationRate = 150

var box = null
#-----------------------------------------------------------
func _process( delta ) :
  var rot_speed = deg2rad( rotationRate )
  rotate_y( rot_speed*delta )

#-----------------------------------------------------------
func _on_Area_body_entered(body):
	if body.name == 'Player':
		$'../HUD Layer'._gotKey()
		self.queue_free()

func setBox(p):
	box = p