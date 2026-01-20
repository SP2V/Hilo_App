import 'package:flutter/material.dart';
import 'package:hilo/models/number.dart';
import 'package:hilo/screens/history.dart';
import 'package:provider/provider.dart';
import 'package:hilo/provider/app_provider.dart';

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF060B19,
        ), // Dark Navy Background
        primaryColor: const Color(0xFF1A73E8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.dark,
          surface: const Color(0xFF131B2C),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dice Tracker'),
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

  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).loadNumbers();
  }

  void _submitNumber() {
    if (formKey.currentState!.validate()) {
      var number = _numberController.text;
      var provider = Provider.of<AppProvider>(context, listen: false);
      provider.addNumber(Numbers(int.parse(number)));
      _numberController.clear();

      // Removed SnackBar to keep UI clean as per modern design,
      // or we can add a subtle one if needed.
    }
  }

  void _resetHistory() {
    Provider.of<AppProvider>(context, listen: false).clearHistory();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1623),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.casino, color: Color(0xFF5A9DFF)),
                      const SizedBox(width: 8),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Cards
              // Consumer<AppProvider>(
              //   builder: (context, provider, child) {
              //     final currentResult =
              //         provider.numbers.isNotEmpty
              //             ? provider.numbers.last.value
              //             : '-';
              //     final count = provider.numbers.length;

              //     return Row(
              //       children: [
              //         Expanded(
              //           child: _buildStatCard(
              //             'ผลลัพธ์ล่าสุด',
              //             '$currentResult',
              //             Icons.casino_outlined,
              //             Colors.blueAccent,
              //           ),
              //         ),
              //         const SizedBox(width: 16),
              //         Expanded(
              //           child: _buildStatCard(
              //             'จำนวนครั้ง',
              //             '$count ครั้ง',
              //             null,
              //             null,
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),

              const SizedBox(height: 24),

              // Entry Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1623),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            color: Colors.blueAccent,
                            margin: const EdgeInsets.only(right: 8),
                          ),
                          const Text(
                            'บันทึกข้อมูล',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numberController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'ระบุแต้ม...',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF050B18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                suffixIcon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'กรุณาระบุ';
                                if (int.tryParse(value) == null)
                                  return 'ตัวเลขไม่ถูกต้อง';
                                return null;
                              },
                              onFieldSubmitted: (_) => _submitNumber(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: _submitNumber,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2E7CF6),
                                    Color(0xFF1A5BB8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    'บันทึก',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'รีเซ็ต',
                              Icons.refresh,
                              Colors.redAccent.withOpacity(0.8),
                              _resetHistory,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.white10,
                          ),
                          Expanded(
                            child: _buildActionButton(
                              'ประวัติ',
                              Icons.history,
                              Colors.grey,
                              _navigateToHistory,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Analysis Section (Visual Only for now)
              // Container(
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF0F1623),
              //     borderRadius: BorderRadius.circular(24),
              //     border: Border.all(color: Colors.white10),
              //   ),
              //   padding: const EdgeInsets.all(20),
              //   child: Column(
              //     children: [
              //       Row(
              //         children: [
              //           Container(
              //             width: 3,
              //             height: 16,
              //             color: Colors.blueAccent,
              //             margin: const EdgeInsets.only(right: 8),
              //           ),
              //           const Text(
              //             'วิเคราะห์ผล',
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 16),
              //       SingleChildScrollView(
              //         scrollDirection: Axis.horizontal,
              //         child: Row(
              //           children: [
              //             _buildAnalysisTab('ทั้งหมด', true),
              //             _buildAnalysisTab('เตี่ยว', false),
              //             _buildAnalysisTab('คู่', false),
              //             _buildAnalysisTab('ตอง', false),
              //             _buildAnalysisTab('รวม', false),
              //           ],
              //         ),
              //       ),
              //       const SizedBox(height: 16),
              //       _buildFrequencyTable(),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData? icon,
    Color? iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: iconColor ?? Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2E7CF6) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFrequencyTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7CF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'แต้ม',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ความถี่',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Dummy data rows for visualization
          for (var i = 1; i <= 6; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: const Border(bottom: BorderSide(color: Colors.white10)),
                color:
                    i % 2 == 0
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.02),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$i', style: const TextStyle(color: Colors.white)),
                  Text(
                    '${(i * 10 / 7).toStringAsFixed(0)}% (จำลอง)',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
