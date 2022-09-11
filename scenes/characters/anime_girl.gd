extends RigidBody

#variaveis de controle

var AllowMove = true #permitir movimento = verdade
var OnAir = true #normalmente vamos começar um pouco a cima do chão
var button_run = false #botão para correr
var button_jump = false #botão para pular
var button_hook = false #botão para dar soco
var Axys = Vector2(0,0) #vector para movimentação com relação a camera
export(NodePath) var CamPath #caminho para a camera no nosso cenario
var Cam = null #armazenara a id da camera
var Speed = 0.0 #armazena a velocidade atual do jogador
onready var AnimatorTree = $AnimationTree #pega o node de animação
onready var AnimatorNode = AnimatorTree["parameters/StateMachine/playback"] #pega o recurso do node de animação

#atributos

export(float) var Force = 15.0
export(float) var MaxSpeed = 7.0

func _ready():
	#pegando a referência do node da camera
	Cam = get_node(CamPath)
	#resetando a animação (BasicController) para a posição 0.0
	AnimatorTree["parameters/StateMachine/BasicController/blend_position"] = 0.0
	pass

func _input(event):
	#pegando as direcionais e as teclas pressionadas do teclado
	if event.is_action_pressed("bt_up"):
		Axys.y = -1
	elif event.is_action_released("bt_up"):
		Axys.y = 0
	elif event.is_action_pressed("bt_down"):
		Axys.y = 1
	elif event.is_action_released("bt_down"):
		Axys.y = 0
	elif event.is_action_pressed("bt_right"):
		Axys.x = -1
	elif event.is_action_released("bt_right"):
		Axys.x = 0
	elif event.is_action_pressed("bt_left"):
		Axys.x = 1
	elif event.is_action_released("bt_left"):
		Axys.x = 0
	elif event.is_action_pressed("bt_run"):
		button_run = true
	elif event.is_action_released("bt_run"):
		button_run = false
	elif event.is_action_pressed("bt_jump"):
		button_jump = true
	elif event.is_action_released("bt_jump"):
		button_jump = false
	elif event.is_action_pressed("bt_hook"):
		button_hook = true
	elif event.is_action_released("bt_hook"):
		button_hook = false
	pass

func _process(delta):
	#delta é o intervalo de segundos da ultima execução deste processo
	#pegando o angulo da camera
	var SideDirection = Vector2(Cam.translation.x,Cam.translation.z).angle_to_point(Vector2(translation.x,translation.z))
	#rotacionando ela com base nesse angulo
	Cam.rotation.y = - SideDirection + deg2rad(90)
	Cam.translation = translation + Vector3(cos(SideDirection),0.5,sin(SideDirection)) * 5
	#função para descobrir a velocidade total do jogador (somando vetores)
	Speed = sqrt(abs(linear_velocity.x) * abs(linear_velocity.x) + abs(linear_velocity.z) * abs(linear_velocity.z))
	if AllowMove:
		if button_jump:
			#pular
			AnimatorNode.travel("Jump Up")
			AllowMove = false
		elif button_hook:
			AnimatorNode.travel("Right Hook")
			AllowMove = false
		elif abs(Axys.x) > 0 || abs(Axys.y) > 0:
			#pega a direçao horizontal com relação a camera
			var HorizontalDirection = SideDirection + deg2rad(90)
			#montando o vetor de movimentação
			var MoveVector = Vector3(cos(SideDirection) * Axys.y + cos(HorizontalDirection) * Axys.x,0,sin(SideDirection) * Axys.y + sin(HorizontalDirection) * Axys.x)
			#a velocidade máxima permitida vai depender se o jogador está pressionando a tecla de correr
			var maxspeed = MaxSpeed * 0.4
			if button_run:
				maxspeed = MaxSpeed
			if Speed < maxspeed:
				apply_impulse(Vector3(0,0,0),MoveVector * Force * delta)
		if Speed > 0.5:
			#corrigindo a rotação subtraindo 90 do angulo (de onde tirei 90? veja os angulos e o plano cartesiano)
			$Armature.rotation.y = -Vector2(0,0).angle_to_point(Vector2(linear_velocity.x,linear_velocity.z)) - deg2rad(90)
		#parametro da animação de 0 - 1, onde 1 é correndo, 0.4 é andando e 0 é parado
		AnimatorTree["parameters/StateMachine/BasicController/blend_position"] = Speed / MaxSpeed
	pass

func EndAnimation():
	#chamada no fim das animações, libera o controle do personagem
	AllowMove = true
	#transição, voltando a animação normal
	AnimatorNode.travel("Basic Controller")
	pass

func Jump():
	apply_impulse(Vector3(0,0,0),Vector3(0,6,0))
	OnAir = true
	pass

func _on_anime_girl_body_entered(body):
	if OnAir:
		AnimatorNode.travel("Jump Down")
		OnAir = false
	pass

func _on_anime_girl_body_exited(body):
#	OnAir = true
	pass
