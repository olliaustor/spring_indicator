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

  double _radiusMax = 12;
  double _radiusMin = 5;
  double _spacing = 24;
  double _acceleration = 0.5;
  double _headMoveOffset = 0.6;
  Axis _axis = Axis.horizontal;

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
    final textStyle = Theme.of(context).textTheme.labelMedium;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Spring Indicator Demo'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // radiusMax slider
                Text(
                  'Radius Max: ${_radiusMax.toStringAsFixed(1)}',
                  style: textStyle,
                ),
                Slider(
                  value: _radiusMax,
                  min: 4,
                  max: 16,
                  divisions: 24,
                  onChanged: (value) {
                    setState(() => _radiusMax = value);
                  },
                ),

                // radiusMin slider
                Text(
                  'Radius Min: ${_radiusMin.toStringAsFixed(1)}',
                  style: textStyle,
                ),
                Slider(
                  value: _radiusMin,
                  min: 2,
                  max: 8,
                  divisions: 12,
                  onChanged: (value) {
                    setState(() => _radiusMin = value);
                  },
                ),

                // spacing slider
                Text(
                  'Spacing: ${_spacing.toStringAsFixed(1)}',
                  style: textStyle,
                ),
                Slider(
                  value: _spacing,
                  min: 8,
                  max: 48,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() => _spacing = value);
                  },
                ),

                // acceleration slider
                Text(
                  'Acceleration: ${_acceleration.toStringAsFixed(2)}',
                  style: textStyle,
                ),
                Slider(
                  value: _acceleration,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() => _acceleration = value);
                  },
                ),

                // headMoveOffset slider
                Text(
                  'Head Move Offset: ${_headMoveOffset.toStringAsFixed(2)}',
                  style: textStyle,
                ),
                Slider(
                  value: _headMoveOffset,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() => _headMoveOffset = value);
                  },
                ),
                Text(
                  'Orientation',
                  style: textStyle,
                ),
                DropdownButton<Axis>(
                  value: _axis,
                  items: [
                    DropdownMenuItem(
                      value: Axis.horizontal,
                      child: Text(
                        'Horizontal',
                        style: textStyle,
                      ),
                    ),
                    DropdownMenuItem(
                      value: Axis.vertical,
                      child: Text(
                        'Vertical',
                        style: textStyle,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _axis = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
            padding: const EdgeInsets.only(top: 10, bottom: 24),
            child: SpringIndicator(
              controller: _controller,
              itemCount: pages.length,
              radiusMax: _radiusMax,
              radiusMin: _radiusMin,
              spacing: _spacing,
              acceleration: _acceleration,
              headMoveOffset: _headMoveOffset,
              axis: _axis,
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
