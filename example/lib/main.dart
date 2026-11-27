import 'package:material_ui/material_ui.dart';
import 'package:spring_indicator/spring_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

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
  const new({super.key, required this.title});

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
    _DemoPage(title: 'Page 1', icon: Icons.favorite, color: Colors.red),
    _DemoPage(title: 'Page 2', icon: Icons.star, color: Colors.green),
    _DemoPage(title: 'Page 3', icon: Icons.home, color: Colors.blue),
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
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SliderControl(
                        label: 'Radius Max',
                        valueLabel: _radiusMax.toStringAsFixed(1),
                        min: 4,
                        max: 16,
                        divisions: 24,
                        value: _radiusMax,
                        onChanged: (value) {
                          setState(() => _radiusMax = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SliderControl(
                        label: 'Radius Min',
                        valueLabel: _radiusMin.toStringAsFixed(1),
                        min: 2,
                        max: 8,
                        divisions: 12,
                        value: _radiusMin,
                        onChanged: (value) {
                          setState(() => _radiusMin = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SliderControl(
                        label: 'Spacing',
                        valueLabel: _spacing.toStringAsFixed(1),
                        min: 8,
                        max: 48,
                        divisions: 20,
                        value: _spacing,
                        onChanged: (value) {
                          setState(() => _spacing = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SliderControl(
                        label: 'Acceleration',
                        valueLabel: _acceleration.toStringAsFixed(2),
                        min: 0,
                        max: 1,
                        divisions: 20,
                        value: _acceleration,
                        onChanged: (value) {
                          setState(() => _acceleration = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SliderControl(
                        label: 'Head Move Offset',
                        valueLabel: _headMoveOffset.toStringAsFixed(2),
                        min: 0,
                        max: 1,
                        divisions: 20,
                        value: _headMoveOffset,
                        onChanged: (value) {
                          setState(() => _headMoveOffset = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Orientation'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButton<Axis>(
                              value: _axis,
                              items: [
                                DropdownMenuItem(
                                  value: Axis.horizontal,
                                  child: Text(
                                    'Horizontal',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: Axis.vertical,
                                  child: Text(
                                    'Vertical',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _axis = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
              colors: pages.map((p) => p.color).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderControl extends StatelessWidget {
  const new({
    required this.label,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $valueLabel',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DemoPage extends StatelessWidget {
  const new({required this.title, required this.icon, required this.color});

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
            Icon(icon, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
