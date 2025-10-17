import 'package:flutter/material.dart';
import 'default_player/default_player.dart';
import 'default_player/hls_player.dart';
import 'default_player/from_network_player.dart';
import 'default_player/vast_ad_player.dart';
import 'default_player/custom_ad_player.dart';

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
      body: Column(
        children: [
          ListTile(
            title: const Text('Default Video Player'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DefaultPage()),
              );
            },
          ),
          ListTile(
            title: const Text('HLS Video Player'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HlsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('From Network Video Player'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FromNetworkPage()),
              );
            },
          ),
          ListTile(
            title: const Text('VAST Ad Video Player'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VastADPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Custom Ad Video Player'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomAdPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DefaultPage extends StatelessWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(
        title: const Text('Default Player'),
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
            child: DefaultVideoPlayer(),
          ),
        ),
      ),
    );
  }
}

class HlsPage extends StatelessWidget {
  const HlsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(
        title: const Text('HLS Player'),
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
            child: HlsVideoPlayer(),
          ),
        ),
      ),
    );
  }
}

class FromNetworkPage extends StatelessWidget {
  const FromNetworkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(
        title: const Text('From Network Player'),
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
            child: FromNetworkVideoPlayer(),
          ),
        ),
      ),
    );
  }
}

class VastADPage extends StatelessWidget {
  const VastADPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(
        title: const Text('VAST Ad Player'),
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
            child: VastADVideoPlayer(),
          ),
        ),
      ),
    );
  }
}

class CustomAdPage extends StatelessWidget {
  const CustomAdPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 245, 250, 1),
      appBar: AppBar(
        title: const Text('Custom Ad Player'),
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
            child: CustomADPlayer(),
          ),
        ),
      ),
    );
  }
}
