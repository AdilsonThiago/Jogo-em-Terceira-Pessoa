extends RigidBody

#variaveis de controle

var AllowMove = true #generico
var need_run = true
var Axys = Vector2(0,0)
var Speed = 0.0
var Target = null #alvo para perseguirmos
var update = 0
var myPath = [] #armazenara pontos no mapa para chegar até o jogador desviando de obstaculos
export(NodePath) var Navigator #O path do mapa para o monstro navegar
var Nav = null

onready var AnimatorTree = $AnimationTree #pega o node de animação
onready var AnimatorNode = AnimatorTree["parameters/StateMachine/playback"] #pega o recurso do node de animação

#atributos

export(float) var Force = 15.0
export(float) var MaxSpeed = 7.0

func _ready():
	AnimatorTree["parameters/StateMachine/BasicController/blend_position"] = 0.0
	Nav = get_node(Navigator)
	pass

func _process(delta):
	Speed = sqrt(abs(linear_velocity.x) * abs(linear_velocity.x) + abs(linear_velocity.z) * abs(linear_velocity.z))
	if AllowMove:
		if Target != null:
			update -= delta
			if update <= 0:
				myPath = Nav.get_simple_path(translation,Target.translation,true)
				update = 0.5
			else:
				if myPath.size() > 0:
					var distance = Vector2(translation.x,translation.z).distance_to(Vector2(myPath[0].x,myPath[0].z))
					#igual pegar seno e cosseno sacas? pegamos as coordenas e dividimos pela distancia para termos apenas o vetor de movimentação desejado
					Axys = Vector2(myPath[0].x - translation.x,myPath[0].z - translation.z) / distance
					if distance > 5 || myPath.size() > 1:
						need_run = true
					else:
						need_run = false
					if distance < 1:
						myPath.remove(0)
		if abs(Axys.x) > 0 || abs(Axys.y) > 0:
			#montando o vetor de movimentação
			var MoveVector = Vector3(Axys.x,0,Axys.y)
			#a velocidade máxima permitida vai depender se o inimigo quer correr
			var maxspeed = MaxSpeed * 0.4
			if need_run:
				maxspeed = MaxSpeed
			if Speed < maxspeed:
				apply_impulse(Vector3(0,0,0),MoveVector * Force * delta)
		if Speed > 0.5:
			#corrigindo a rotação subtraindo 90 do angulo (de onde tirei 90? veja os angulos e o plano cartesiano)
			$Armature.rotation.y = -Vector2(0,0).angle_to_point(Vector2(linear_velocity.x,linear_velocity.z)) - deg2rad(90)
		AnimatorTree["parameters/StateMachine/BasicController/blend_position"] = Speed / MaxSpeed
	pass

func _on_Area_body_entered(body):
	#pegamos o alvo no campo de visão
	if body.is_in_group("player"):
		Target = body
		print("targtd")
	pass
