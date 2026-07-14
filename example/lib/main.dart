import 'package:flutter/material.dart';
import 'package:spring_indicator/spring_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spring Indicator Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Spring Indicator Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = PageController();

  final pages = const [
    _DemoPage(
      title: 'Page 1',
      icon: Icons.favorite,
      color: Colors.red,
    ),
    _DemoPage(
      title: 'Page 2',
      icon: Icons.star,
      color: Colors.green,
    ),
    _DemoPage(
      title: 'Page 3',
      icon: Icons.home,
      color: Colors.blue,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Spring Indicator Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return pages[index];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 40,
            ),
            child: SpringIndicator(
              controller: _controller,
              itemCount: pages.length,
              color: Colors.deepPurple,
              colors: pages.map((p) => p.color).toList(),
              inactiveColor: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  const _DemoPage(
      {required this.title, required this.icon, required this.color});

  final String title;

  final IconData icon;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.deepPurple,
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
