import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SpaceInvadersGame());
}

// Widget principal que inicia el juego
class SpaceInvadersGame extends StatelessWidget {
  const SpaceInvadersGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

// Pantalla principal del juego
class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 16;
  static const double step = 1 / gridSize;

  int playerX = 0; // Posición del jugador en la pantalla
  List<int> aliensX = [-5, 0, 5]; // Posiciones iniciales de los aliens
  List<bool> aliensMovingRight = [true, false, true]; // Dirección del movimiento de cada alien
  List<Offset> bullets = []; // Lista de balas disparadas
  int score = 0; // Puntuación del jugador

  @override
  void initState() {
    super.initState();
    _startGameLoop(); // Inicia el bucle del juego
  }

  // Bucle principal del juego que actualiza la posición de los aliens y las balas
  void _startGameLoop() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Mueve los aliens de izquierda a derecha
        for (int i = 0; i < aliensX.length; i++) {
          aliensX[i] += aliensMovingRight[i] ? 1 : -1;
          if (aliensX[i] > 6) aliensMovingRight[i] = false;
          if (aliensX[i] < -6) aliensMovingRight[i] = true;
        }

        // Mueve las balas hacia arriba
        bullets = bullets.map((b) => Offset(b.dx, (b.dy * gridSize - 1).round() / gridSize)).toList();
        bullets.removeWhere((b) => b.dy < -0.1); // Elimina las balas fuera de la pantalla
        
        _checkBulletCollisions(); // Verifica colisiones con los aliens
      });
    });
  }

  // Verifica si alguna bala impactó a un alien
  void _checkBulletCollisions() {
    for (int i = 0; i < aliensX.length; i++) {
      if (_checkCollision(aliensX[i], (i + 1) * 0.15)) {
        setState(() {
          aliensX[i] = 100; // Mueve el alien fuera de la pantalla
          score += 10; // Aumenta la puntuación
        });
      }
    }
  }

  // Comprueba si una bala ha impactado a un alien
  bool _checkCollision(int alienX, double alienY) {
    return bullets.any((b) => (b.dx * gridSize).round() == alienX && (b.dy * gridSize).round() == (alienY * gridSize).round());
  }

  // Mueve al jugador a la izquierda o derecha dentro de los límites
  void movePlayer(int dx) {
    setState(() {
      playerX += dx;
      playerX = playerX.clamp(-8, 8);
    });
  }

  // Dispara una bala desde la posición del jugador
  void shoot() {
    setState(() {
      bullets.add(Offset(playerX / gridSize, 0.9));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Área de juego
          Expanded(
            flex: 9,
            child: CustomPaint(
              painter: GamePainter(playerX, aliensX, bullets),
              child: Container(),
            ),
          ),
          // Controles del jugador
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => movePlayer(-1),
                  child: const Icon(Icons.arrow_left),
                ),
                ElevatedButton(
                  onPressed: shoot,
                  child: const Icon(Icons.arrow_upward),
                ),
                ElevatedButton(
                  onPressed: () => movePlayer(1),
                  child: const Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
          // Mostrar puntuación
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Score: $score",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// Se encarga de dibujar los elementos del juego en la pantalla
class GamePainter extends CustomPainter {
  final int playerX;
  final List<int> aliensX;
  final List<Offset> bullets;

  GamePainter(this.playerX, this.aliensX, this.bullets);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint playerPaint = Paint()..color = Colors.blue;
    final Paint alienPaint = Paint()..color = Colors.red;
    final Paint bulletPaint = Paint()..color = Colors.yellow;

    // Dibuja al jugador como un triángulo
    Path player = Path()
      ..moveTo(size.width / 2 + playerX * (size.width / 16), size.height - 50)
      ..lineTo(size.width / 2 + playerX * (size.width / 16) - 16, size.height - 20)
      ..lineTo(size.width / 2 + playerX * (size.width / 16) + 16, size.height - 20)
      ..close();
    canvas.drawPath(player, playerPaint);

    // Dibuja los aliens como rectángulos
    for (int i = 0; i < aliensX.length; i++) {
      double yPos = (i + 1) * 50;
      if (aliensX[i] < 50) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(size.width / 2 + aliensX[i] * (size.width / 16), yPos),
            width: 32,
            height: 32,
          ),
          alienPaint,
        );
      }
    }

    // Dibuja las balas como pequeños círculos
    for (Offset bullet in bullets) {
      canvas.drawCircle(
        Offset(size.width / 2 + bullet.dx * size.width, bullet.dy * size.height),
        4,
        bulletPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
