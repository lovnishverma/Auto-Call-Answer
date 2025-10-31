import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AutoCallApp());
}

class AutoCallApp extends StatefulWidget {
  const AutoCallApp({super.key});

  @override
  State<AutoCallApp> createState() => _AutoCallAppState();
}

class _AutoCallAppState extends State<AutoCallApp> with TickerProviderStateMixin {
  static const platform =
  MethodChannel('com.lovnishverma.autocall/accessibility');

  bool accessibilityEnabled = false;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    checkAccessibilityStatus();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> checkAccessibilityStatus() async {
    try {
      final bool result = await platform.invokeMethod('checkAccessibilityStatus');
      setState(() {
        accessibilityEnabled = result;
      });
    } on PlatformException catch (e) {
      print("Error checking accessibility: ${e.message}");
      setState(() {
        accessibilityEnabled = false;
      });
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        accessibilityEnabled = false;
      });
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
      Future.delayed(const Duration(milliseconds: 500), () {
        checkAccessibilityStatus();
      });
    } on PlatformException catch (e) {
      print("Failed to open accessibility settings: '${e.message}'.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAccessibilityStatus();
    }
  }

  Future<void> requestBatteryExemption() async {
    try {
      await platform.invokeMethod('requestBatteryExemption');
    } on PlatformException catch (e) {
      print("Failed to request battery exemption: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.blue.shade700,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Auto Call Answer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade600,
                        Colors.blue.shade800,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Hero Card
                      _buildStatusHeroCard(),

                      const SizedBox(height: 24),

                      // Setup Steps
                      _buildSectionHeader('Setup Steps', Icons.list_alt_rounded),
                      const SizedBox(height: 16),
                      _buildSetupSteps(),

                      const SizedBox(height: 32),

                      // Quick Actions
                      _buildSectionHeader('Quick Actions', Icons.bolt_rounded),
                      const SizedBox(height: 16),
                      _buildQuickActions(),

                      const SizedBox(height: 32),

                      // How it works
                      _buildHowItWorksCard(),

                      const SizedBox(height: 32),

                      // Footer
                      _buildFooter(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeroCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: accessibilityEnabled
              ? [Colors.green.shade400, Colors.green.shade700]
              : [Colors.orange.shade400, Colors.deepOrange.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: (accessibilityEnabled ? Colors.green : Colors.orange).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: accessibilityEnabled ? 1.0 : 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      accessibilityEnabled
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      size: 60,
                      color: accessibilityEnabled
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              accessibilityEnabled ? 'All Set!' : 'Setup Required',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              accessibilityEnabled
                  ? 'Your app is ready to auto-answer calls'
                  : 'Complete the setup to activate auto-answering',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.95),
                height: 1.4,
              ),
            ),
            if (!accessibilityEnabled) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Follow the steps below',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSetupSteps() {
    return Column(
      children: [
        _buildStepCard(
          stepNumber: '1',
          title: 'Phone Permission',
          description: 'Allow the app to access phone functions',
          icon: Icons.phone_android_rounded,
          color: Colors.blue,
          instructions: 'Settings → Apps → Auto Call → Permissions → Phone',
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          stepNumber: '2',
          title: 'Accessibility Service',
          description: 'Enable accessibility to answer calls automatically',
          icon: Icons.accessibility_new_rounded,
          color: Colors.orange,
          instructions: 'Tap "Enable Service" button below',
          isHighlighted: !accessibilityEnabled,
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          stepNumber: '3',
          title: 'Background Running',
          description: 'Disable battery optimization for continuous operation',
          icon: Icons.battery_charging_full_rounded,
          color: Colors.green,
          instructions: 'Tap "Allow Background" button below',
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required MaterialColor color,
    required String instructions,
    bool isHighlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted
            ? Border.all(color: color.shade300, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? color.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isHighlighted ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.shade400, color.shade600],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color.shade600, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      instructions,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionButton(
          label: accessibilityEnabled
              ? 'Manage Accessibility'
              : 'Enable Accessibility Service',
          icon: Icons.settings_accessibility_rounded,
          gradient: [Colors.orange.shade400, Colors.deepOrange.shade600],
          onPressed: openAccessibilitySettings,
          isPrimary: !accessibilityEnabled,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: 'Allow Background Running',
          icon: Icons.battery_charging_full_rounded,
          gradient: [Colors.green.shade400, Colors.green.shade600],
          onPressed: requestBatteryExemption,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      height: isPrimary ? 70 : 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: isPrimary ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isPrimary ? 17 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'How It Works',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Once all permissions are granted, this app will automatically answer all incoming calls. '
                    'The accessibility service detects incoming calls and simulates the answer action, '
                    'ensuring you never miss important calls.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade50, Colors.purple.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.purple.shade100,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: Colors.pink.shade400,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Made with love by',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Lovnish Verma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '© 2026 All Rights Reserved',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}