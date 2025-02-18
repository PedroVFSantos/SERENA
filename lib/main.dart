import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitor',
      theme: ThemeData(
        primaryColor: const Color(0xFFD90429),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',

        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/heartRate': (context) => const HeartRatePage(),
        '/stressRate': (context) => const StressRatePage(),
        '/steps': (context) => const StepsPage(),
        '/temperature': (context) => const TemperaturePage(),
      },
    );
  }
}

// Página inicial
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(context, 'Heart Rate', Icons.favorite, '/heartRate'),
          _buildCard(context, 'Stress Rate', Icons.mood_bad, '/stressRate'),
          _buildCard(context, 'Steps', Icons.directions_walk, '/steps'),
          _buildCard(context, 'Temperature', Icons.thermostat, '/temperature'),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFD90429)),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _checkLogin(
      BuildContext context, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final registeredEmail = prefs.getString('email');
    final registeredPassword = prefs.getString('password');

    if (registeredEmail == null || registeredPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not registered. Please sign up!'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (registeredEmail == email && registeredPassword == password) {
      Navigator.pushNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect email or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Color(0xFFD90429), size: 64),
              const SizedBox(height: 16),
              const Text('SERENA',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _checkLogin(
                      context, emailController.text, passwordController.text);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2D42)),
                child: const Text('Sign In',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text('Not a member? Sign up!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleSignup() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2B2D42),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Icon(
              Icons.person_add,
              size: 100,
              color: Color(0xFFD90429),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2D42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Monitor Cardiaco

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({super.key});

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  String heartRate = '0 bpm';
  List<FlSpot> heartRateData = [];
  Timer? timer;
  bool isAlertShowing = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchHeartRate();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _showWarningDialog() {
    if (!isAlertShowing) {
      isAlertShowing = true;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 16),
              SizedBox(width: 6),
              Text('High Heart Rate Warning'),
            ],
          ),
          content: const Text(
              'Your heart rate is dangerously high! Please sit down, take deep breaths, and consider seeking medical attention if it persists.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                isAlertShowing = false;
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _fetchHeartRate() {
    final random = Random();
    int simulatedHeartRate = 80 + random.nextInt(101);

    setState(() {
      heartRate = '$simulatedHeartRate bpm';
      heartRateData.add(FlSpot(
          heartRateData.length.toDouble(), simulatedHeartRate.toDouble()));

      if (simulatedHeartRate > 160) {
        _showWarningDialog();
      }
    });
  }

  void _showStatistics() {
    if (heartRateData.isEmpty) return;

    double avgHeartRate =
        heartRateData.map((spot) => spot.y).reduce((a, b) => a + b) /
            heartRateData.length;
    double maxHeartRate = heartRateData.map((spot) => spot.y).reduce(max);
    double minHeartRate = heartRateData.map((spot) => spot.y).reduce(min);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Heart Rate Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Maximum'),
              trailing: Text('${maxHeartRate.toStringAsFixed(1)} bpm'),
            ),
            ListTile(
              leading: const Icon(Icons.trending_down),
              title: const Text('Minimum'),
              trailing: Text('${minHeartRate.toStringAsFixed(1)} bpm'),
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Average'),
              trailing: Text('${avgHeartRate.toStringAsFixed(1)} bpm'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeartRateColor(int rate) {
    if (rate > 160) {
      return Colors.red;
    } else if (rate > 120) {
      return Colors.orange;
    } else {
      return const Color(0xFFD90429);
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentRate = int.parse(heartRate.split(' ')[0]);

    return Scaffold(
      appBar: AppBar(title: const Text("Heart Rate Monitor")),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 64,
                color: _getHeartRateColor(currentRate),
              ),
              const SizedBox(height: 16),
              Text(
                heartRate,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getHeartRateColor(currentRate),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: 70,
                    maxY: 190,
                    lineBarsData: [
                      LineChartBarData(
                        spots: heartRateData,
                        isCurved: true,
                        color: const Color(0xFFD90429),
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _showStatistics,
                icon: const Icon(Icons.analytics),
                label: const Text('Statistics'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Stress
class StressRatePage extends StatelessWidget {
  const StressRatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stress Rate Monitor")),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mood_bad, size: 64, color: Color(0xFFD90429)),
            SizedBox(height: 16),
            Text(
              'Stress Level: High',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

//Passos
class StepsPage extends StatelessWidget {
  const StepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Steps Monitor")),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 64, color: Color(0xFFD90429)),
            SizedBox(height: 16),
            Text(
              '1000 Steps',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

//Temperatura
class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  double temperature = 36.5;
  double hydrationLevel = 100.0;
  Timer? _timer;
  bool isAlertShowing = false;

  @override
  void initState() {
    super.initState();
    _startTemperatureSimulation();
  }

  void _startTemperatureSimulation() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        temperature = 35.0 + Random().nextDouble() * 5;
      });
    });
  }

  void _startDehydrationSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        hydrationLevel -= Random().nextDouble() * 10;
        if (hydrationLevel <= 20 && !isAlertShowing) {
          _showDehydrationWarning();
        }
      });

      if (hydrationLevel <= 0) {
        hydrationLevel = 0;
        _timer?.cancel();
      }
    });
  }

  void _showDehydrationWarning() {
    isAlertShowing = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dehydration Alert"),
        content: const Text(
            "Your hydration level is very low! Drink water immediately."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              isAlertShowing = false;
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _openDehydrationPopup() {
    _startDehydrationSimulation();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dehydration"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Dehydration: ${hydrationLevel.toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: hydrationLevel / 100,
              backgroundColor: Colors.grey[300],
              color: hydrationLevel > 50 ? Colors.red : Colors.red,
              minHeight: 20,
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Temperature Monitor")),
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centraliza horizontalmente
        children: [
          const Spacer(
              flex: 2), // Empurra o termômetro um pouco mais para baixo

          // Termômetro centralizado
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.thermostat,
                  size: 120,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  "${temperature.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Spacer(flex: 3), // Ajusta o espaço abaixo do termômetro

          // Botão de Desidratação (centralizado na parte inferior)
          Padding(
            padding:
                const EdgeInsets.only(bottom: 40), // Mantém o botão mais abaixo
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _openDehydrationPopup,
                icon: const Icon(Icons.water_drop, color: Colors.white),
                label: const Text("Dehydration",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
