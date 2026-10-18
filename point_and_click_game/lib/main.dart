import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'game/adventure_game.dart';
import 'game/inventory.dart';
import 'ui/home_screen.dart';
import 'ui/inventory_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => InventoryManager(),
      child: const PointAndClickApp(),
    ),
  );
}

class PointAndClickApp extends StatelessWidget {
  const PointAndClickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vocab Adventure Game',
      debugShowCheckedModeBanner: false,
      home: MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return HomeScreen(
        onStartGame: () {
          setState(() {
            _isPlaying = true;
          });
        },
      );
    }

    return GameScreen(
      onBackToHome: () {
        setState(() {
          _isPlaying = false;
        });
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  final VoidCallback onBackToHome;

  const GameScreen({super.key, required this.onBackToHome});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? _dialogueTitle;
  String? _dialogueDesc;
  String? _characterImage;
  VoidCallback? _onDialogueDismiss;
  bool _isDemoEnded = false;

  late AdventureGame _game;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final inventory = Provider.of<InventoryManager>(context, listen: false);
    _game = AdventureGame(
      inventory: inventory,
      showDialogue: (title, description, {characterImage, VoidCallback? onDismiss}) {
        setState(() {
          _dialogueTitle = title;
          _dialogueDesc = description;
          _characterImage = characterImage;
          _onDialogueDismiss = onDismiss;
        });
      },
      onDemoEnd: () {
        setState(() {
          _isDemoEnded = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),

          // 💡 ปุ่มเฉลยตำแหน่งกุญแจ (มุมขวาบน)
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 5,
              ),
              icon: const Icon(Icons.lightbulb_rounded, color: Colors.black),
              label: const Text(
                'เฉลย 💡',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () {
                _game.revealKeyLocation();
              },
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: InventoryBar(),
          ),

          // 👧 แสดงตัวละครอลิสขนาดยอดนิยมสไตล์ Otome Game
          if (_dialogueTitle != null && _characterImage != null)
            Positioned(
              left: 20,
              bottom: 120,
              child: Image.asset(
                'assets/images/$_characterImage',
                height: 380,
                fit: BoxFit.contain,
              ),
            ),

          // 💬 กล่องข้อความ Visual Novel / Otome Style
          if (_dialogueTitle != null)
            Positioned(
              bottom: 75,
              left: 15,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  final callback = _onDialogueDismiss;
                  setState(() {
                    _dialogueTitle = null;
                    _dialogueDesc = null;
                    _characterImage = null;
                    _onDialogueDismiss = null;
                  });
                  if (callback != null) callback();
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade300, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _dialogueTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _dialogueDesc!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'แตะเพื่อดำเนินเรื่องต่อ ▶',
                          style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_isDemoEnded)
            Container(
              color: Colors.black87,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 80),
                      const SizedBox(height: 10),
                      const Text(
                        '🎉 จบเดโม่แล้วจ้า! 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ขอบคุณที่ร่วมทดสอบเล่นเกมทดลองเวอร์ชันเดโม่นี้!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.replay, color: Colors.black),
                            label: const Text(
                              'เล่นใหม่อีกครั้ง',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                _isDemoEnded = false;
                              });
                              _initGame();
                            },
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.exit_to_app, color: Colors.white),
                            label: const Text(
                              'ออกจากเกม',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              SystemNavigator.pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}