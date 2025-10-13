import 'package:flutter/material.dart';
import 'package:animax_player/animax_player.dart';
import 'default_player/default_player.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerPage(),
              ),
            );
          },
          child: const Text('Play Player'),
        ),
      ),
    );
  }
}

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
          onPressed: () => Navigator.pop(context),
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
