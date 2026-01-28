import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hilo/models/number.dart';
import 'package:hilo/screens/history.dart';
import 'package:provider/provider.dart';
import 'package:hilo/provider/app_provider.dart';
import 'package:hilo/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hilo Dice Tracker',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Light background
        primaryColor: const Color(0xFF2E7CF6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7CF6),
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
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
  final formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedFilter = 'All'; // Track selected filter
  bool _sortByFrequency = false; // Track sort state
  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).loadNumbers();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _submitNumber() {
    setState(() {
      _attemptedSubmit = true;
    });
    if (formKey.currentState!.validate()) {
      var number = _numberController.text;
      var provider = Provider.of<AppProvider>(context, listen: false);
      provider.addNumber(Numbers(int.parse(number)));
      _numberController.clear();
      setState(() {
        _attemptedSubmit = false;
      });
    }
  }

  void _resetHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 40,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Reset?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Are you sure you want to clear all\nhistory? This action cannot be undone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      Provider.of<AppProvider>(context, listen: false).clearHistory();
    }
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyHistory()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dashboard Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEFF5), // Light grey/blue ish
                    image: DecorationImage(
                      // image: AssetImage('assets/images/bg_card.jpg'),
                      image: AssetImage('assets/images/bg.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dice Tracker Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          // color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analyze dice frequency patterns from\nyour input data',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          // color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Cards
                Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    final currentResult =
                        provider.numbers.isNotEmpty
                            ? provider.numbers.first.value
                                .toString() // Assuming list is ordered new first
                            : '---';
                    final count = provider.numbers.length;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'CURRENT RESULT',
                            currentResult,
                            imagePath: 'assets/images/dice.png',
                            isHighlight: true, // Blue number
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'COUNT DICE',
                            '$count',
                            unit: 'rolls',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Input Section
                // const Text(
                //   'Input Result',
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //     color: Color(0xFF64748B),
                //   ),
                // ),
                // const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 10,
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: _numberController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3),
                            FilteringTextInputFormatter.allow(RegExp(r'[1-6]')),
                          ],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign:
                              TextAlign
                                  .center, // Number usually aligns right or usually left? Image shows icon right. Text seems right aligned? No, placeholder 123 is right.
                          // Let's assume left input, icon right.
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 17,
                            ),
                            filled: true,
                            fillColor: const Color(
                              0xFFF1F5F9,
                            ), // Light grey background
                            hintText:
                                _focusNode.hasFocus
                                    ? 'Enter a number from 1 to 6'
                                    : 'Input Result',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            // suffixIcon: Padding(
                            //   padding: const EdgeInsets.only(right: 20),
                            //   child: Align(
                            //     alignment: Alignment.centerRight,
                            //     widthFactor: 1.0,
                            //     child: Text(
                            //       '1 to 6',
                            //       style: TextStyle(
                            //         color: Colors.grey[400],
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 14,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1), // Grey border
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1), // Grey border
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return _attemptedSubmit
                                  ? 'Please enter a number'
                                  : null;
                            }
                            if (value.length != 3) {
                              return 'Please enter a 3-digit number';
                            }
                            // Check if all digits are between 1-6
                            for (int i = 0; i < value.length; i++) {
                              int digit = int.tryParse(value[i]) ?? 0;
                              if (digit < 1 || digit > 6) {
                                return 'Each digit must be between 1 and 6';
                              }
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submitNumber(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton.icon(
                        onPressed: _submitNumber,
                        // icon: const Icon(
                        //   Icons.check,
                        //   size: 18,
                        //   color: Colors.white,
                        // ),
                        label: const Text(
                          'Enter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6), // Blue
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          side: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _resetHistory,
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                          color: Color(0xFFEF4444),
                        ),
                        label: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            244,
                            244,
                          ), // Light Red
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton.icon(
                        onPressed: _navigateToHistory,
                        icon: const Icon(
                          Icons.history,
                          size: 18,
                          color: Color(0xFF3B82F6),
                        ),
                        label: const Text(
                          'History',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 1.5,
                          ),
                          // backgroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 244, 248, 255),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedFilter == 'All'),
                      _buildFilterChip('Single', _selectedFilter == 'Single'),
                      _buildFilterChip('Pair', _selectedFilter == 'Pair'),
                      _buildFilterChip('Triple', _selectedFilter == 'Triple'),
                      _buildFilterChip('Sum', _selectedFilter == 'Sum'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Data Table Header/Body
                Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              left: 24,
                              right: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'DICE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _sortByFrequency = !_sortByFrequency;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'FREQUENCY',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              _sortByFrequency
                                                  ? const Color(0xFF3B82F6)
                                                  : const Color(0xFF64748B),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        _sortByFrequency
                                            ? Icons.expand_more
                                            : Icons.unfold_more,
                                        size: 16,
                                        color:
                                            _sortByFrequency
                                                ? const Color(0xFF3B82F6)
                                                : const Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table Rows
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Column(children: _buildStatsRows(provider)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value, {
    IconData? icon,
    String? imagePath,
    bool isHighlight = false,
    String? unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != null) ...[
                Image.asset(
                  imagePath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show dice for CURRENT RESULT inline

              // if (title == 'CURRENT RESULT' && value != '-') ...[
              //   // ..._buildDiceRow(value),
              //   const SizedBox(width: 15),
              // ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color:
                      isHighlight
                          ? const Color(0xFF2E7CF6)
                          : const Color(0xFF1E293B),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiceRow(String value) {
    String paddedValue = value.padLeft(3, '0');
    List<Widget> dice = [];

    for (int i = 0; i < 3 && i < paddedValue.length; i++) {
      int digit = int.tryParse(paddedValue[i]) ?? 0;
      if (digit >= 1 && digit <= 6) {
        dice.add(_buildDice(digit));
        if (i < 2) dice.add(const SizedBox(width: 4));
      }
    }

    return dice;
  }

  Widget _buildDice(int number) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: const Color.fromARGB(255, 177, 188, 201),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 1,
            offset: const Offset(0, 0.5),
          ),
        ],
      ),
      child: CustomPaint(painter: DicePainter(number)),
    );
  }

  // Filter chip method
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? const Color(0xFF2E7CF6) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = label;
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border:
                  isSelected
                      ? null
                      : Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatsRows(AppProvider provider) {
    List<Widget> rows = [];

    // Use the new getStatsRows method which uses the user's logic
    // We pass the filter and sort preference.
    final stats = provider.getStatsRows(
      _selectedFilter,
      sortByFreq: _sortByFrequency,
    );

    if (stats.isEmpty) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 132),
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
      return rows;
    }

    for (var stat in stats) {
      rows.add(
        _buildStatRow(
          stat.dice,
          stat.frequency,
          categoryLabel: stat.label.isNotEmpty ? stat.label : null,
        ),
      );
    }

    return rows;
  }

  Widget _buildStatRow(String dice, String frequency, {String? categoryLabel}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 16,
          left: 24,
          right: 32,
        ),
        child: Row(
          children: [
            // Dice Number/Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dice,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                ),
              ),
            ),
            if (categoryLabel != null) ...[
              const SizedBox(width: 12),
              Text(
                categoryLabel,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const Spacer(),

            // Frequency
            Text(
              frequency,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DicePainter extends CustomPainter {
  final int number;

  DicePainter(this.number);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFEF4444) // Red dots
          ..style = PaintingStyle.fill;

    final double dotRadius = size.width * 0.08;
    final double padding = size.width * 0.25;
    final double center = size.width / 2;

    // Define dot positions
    final positions = {
      'topLeft': Offset(padding, padding),
      'topRight': Offset(size.width - padding, padding),
      'center': Offset(center, center),
      'middleLeft': Offset(padding, center),
      'middleRight': Offset(size.width - padding, center),
      'bottomLeft': Offset(padding, size.height - padding),
      'bottomRight': Offset(size.width - padding, size.height - padding),
    };

    // Draw dots based on number
    switch (number) {
      case 1:
        canvas.drawCircle(positions['center']!, dotRadius, paint);
        break;
      case 2:
        canvas.drawCircle(positions['topLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomRight']!, dotRadius, paint);
        break;
      case 3:
        canvas.drawCircle(positions['topLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['center']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomRight']!, dotRadius, paint);
        break;
      case 4:
        canvas.drawCircle(positions['topLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['topRight']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomRight']!, dotRadius, paint);
        break;
      case 5:
        canvas.drawCircle(positions['topLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['topRight']!, dotRadius, paint);
        canvas.drawCircle(positions['center']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomRight']!, dotRadius, paint);
        break;
      case 6:
        canvas.drawCircle(positions['topLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['topRight']!, dotRadius, paint);
        canvas.drawCircle(positions['middleLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['middleRight']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomLeft']!, dotRadius, paint);
        canvas.drawCircle(positions['bottomRight']!, dotRadius, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) => oldDelegate.number != number;
}
