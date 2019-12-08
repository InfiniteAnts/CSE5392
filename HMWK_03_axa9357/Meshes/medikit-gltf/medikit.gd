extends Spatial

export var rotationRate = 150
export var quantity     = 0
var box = null
#-----------------------------------------------------------
func _process( delta ) :
  var rot_speed = deg2rad( rotationRate )
  rotate_y( rot_speed*delta )

#-----------------------------------------------------------
func setQuantity( qty ) :
  quantity = qty

#-----------------------------------------------------------
func _on_Area_body_entered(body):
	if body.name == 'Player':
		$'../HUD Layer'._playerHeal(quantity)
		self.queue_free()

func setBox(p):
	box = p