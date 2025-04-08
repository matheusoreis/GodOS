# Entidade
As entidades do jogo, como Jogadores, Monstros, NPCs, Bosses, entre outras, são representadas por nodes do tipo CharacterBody2D. A classe Entidade serve como a classe base para todas essas entidades, centralizando e gerenciando a lógica e os comportamentos comuns entre elas. A Entidade contém componentes essenciais que padronizam seu funcionamento e tornam mais fácil a criação de novas entidades. Cada tipo específico de entidade pode herdar da classe Entidade e adicionar suas próprias lógicas e animações.

## Sprite
A Sprite é um node do tipo [Node2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html) que armazena a imagem base da entidade. Ele é responsável por renderizar a representação visual da entidade no jogo, como o jogador, inimigos ou NPCs. A entidade base não possui uma sprite padrão, mas cada tipo de entidade pode definir a sua própria aparência.

## Animation
A Animation é um node do tipo [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) que gerencia as animações da entidade. A classe Entidade possui animações básicas, como andando e parado, que são comuns a todas as entidades. No entanto, cada tipo de entidade pode adicionar suas próprias animações.

## Collision
A Collision é um node do tipo [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) que define a forma de colisão da entidade. Na Entidade base, a [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) não tem um [Shape2D](https://docs.godotengine.org/en/stable/classes/class_shape2d.html) atribuído, pois cada tipo de entidade terá um formato de colisão específico. Isso permite maior flexibilidade ao criar diferentes formas de colisão para entidades diferentes.

## Parâmetros
Os Parâmetros é uma node do tipo [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html) representam os dados e características da entidade, como saúde, força, velocidade, etc. A classe Entidade base não possui parâmetros específicos, pois cada tipo de entidade pode ter um conjunto único de parâmetros.

## StateMachine
A StateMachine é uma node do tipo [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html) que armazena e gerencia os estados da máquina de estados finitos da entidade. A Entidade Base possui, por padrão, apenas o estado "stopped" parado, que representa o estado inicial ou o comportamento padrão da entidade quando ela não está realizando nenhuma ação específica.

## Multiplayer
O componente Multiplayer é uma node do tipo [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html) que armazena e gerencia os [MultiplayerSynchronizer](https://docs.godotengine.org/en/stable/classes/class_multiplayersynchronizer.html) de cada entidade, garantindo que os estados e as ações das entidades sejam sincronizados corretamente entre o servidor e os clientes
