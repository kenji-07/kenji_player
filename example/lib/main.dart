import 'package:flutter/material.dart';
import 'package:animax_player/animax_player.dart';
import 'default_player/default_player.dart';
import 'default_player/test.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animax Player Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// 🎬 Эхний хуудас — Play Player товчтой
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 👉 Play Player товч дарахад дараагийн хуудсанд шилжинэ
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayerPage(),
                  ),
                );
              },
              child: const Text('Play Player'),
            ),
            ElevatedButton(
              onPressed: () {
                // 👉 Play Player товч дарахад дараагийн хуудсанд шилжинэ
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleVideoPlayerTest(),
                  ),
                );
              },
              child: const Text('Play Player test'),
            )
          ],
        ),
      ),
    );
  }
}

// 🎥 Хоёр дахь хуудас — Видео тоглуулагч
class PlayerPage extends StatelessWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnimaxPlayerController _controller = AnimaxPlayerController();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(
        title: const Text('Animax Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 👈 буцах үйлдэл
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: AnimaxVideoPlayer(
              controller: _controller,
            ),
          ),
        ),
      ),
    );
  }
}
