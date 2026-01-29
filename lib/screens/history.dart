import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hilo/provider/app_provider.dart';
import 'package:hilo/models/number.dart';

class MyHistory extends StatefulWidget {
  const MyHistory({super.key});

  @override
  State<MyHistory> createState() => _MyHistoryState();
}

class _MyHistoryState extends State<MyHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Top-left gradient
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFBFDBFE).withOpacity(0.6),
                    const Color(0xFFBFDBFE).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom-right gradient
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFBFDBFE).withOpacity(0.6),
                    const Color(0xFFBFDBFE).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFBFDBFE).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Color.fromARGB(
                                  255,
                                  154,
                                  187,
                                  228,
                                ).withOpacity(1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF1D4ED8),
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Roll History', // Keeping English for consistency or "ประวัติการทอย" as requested before? Keeping Thai as per previous flow if needed but user asked "white mode".
                                  // Let's stick closer to the "Dice Analysis" look which was English. But previous convo had Thai.
                                  // I will use "Roll History" to match "Dice Analysis" English.
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/dice.png',
                                  width: 20,
                                  height: 20,
                                ),
                                // const Icon(Icons.history, color: Color(0xFF64748B), size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // List
                    Expanded(
                      child: Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          // Data is already sorted newest first from database
                          if (provider.numbers.isEmpty) {
                            return Center(
                              child: Text(
                                'No historical data available.',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: provider.numbers.length,
                            itemBuilder: (context, index) {
                              final number = provider.numbers[index];

                              return HistoryItem(
                                key: ValueKey(number),
                                number: number,
                                index: index,
                              );
                            },
                          );

                          // return ShaderMask(
                          //   shaderCallback: (Rect bounds) {
                          //     return LinearGradient(
                          //       begin: Alignment.topCenter,
                          //       end: Alignment.bottomCenter,
                          //       colors: [
                          //         Colors.white,
                          //         Colors.white,
                          //         Colors.white.withOpacity(0.0),
                          //       ],
                          //       stops: const [0.0, 0.85, 1.0],
                          //     ).createShader(bounds);
                          //   },
                          //   blendMode: BlendMode.dstIn,
                          //   child: ListView.builder(
                          //     padding: const EdgeInsets.symmetric(horizontal: 16),
                          //     itemCount: provider.numbers.length,
                          //     itemBuilder: (context, index) {
                          //       final number = provider.numbers[index];

                          //       return HistoryItem(
                          //         key: ValueKey(number),
                          //         number: number,
                          //         index: index,
                          //       );
                          //     },
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryItem extends StatefulWidget {
  final Numbers number;
  final int index;

  const HistoryItem({super.key, required this.number, required this.index});

  @override
  State<HistoryItem> createState() => _HistoryItemState();
}

enum ItemState { normal, edit, delete }

class _HistoryItemState extends State<HistoryItem> {
  ItemState _currentState = ItemState.normal;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _startEdit() {
    _editController.text = widget.number.value.toString();
    setState(() {
      _currentState = ItemState.edit;
    });
  }

  void _cancelAction() {
    setState(() {
      _currentState = ItemState.normal;
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E), // Green
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _saveEdit() {
    final text = _editController.text.trim();
    final newValue = int.tryParse(text);

    // Validate: must have exactly 3 digits and all digits must be 1-6
    if (newValue == null) {
      _showErrorToast('Please enter a valid number');
      return;
    }

    if (text.length != 3) {
      _showErrorToast('Number must have exactly 3 digits');
      return;
    }

    // Check if all digits are between 1-6
    for (int i = 0; i < text.length; i++) {
      int digit = int.parse(text[i]);
      if (digit < 1 || digit > 6) {
        _showErrorToast('All digits must be between 1-6');
        return;
      }
    }

    Provider.of<AppProvider>(
      context,
      listen: false,
    ).updateNumber(widget.index, Numbers(newValue));
    setState(() {
      _currentState = ItemState.normal;
    });
    _showToast('Saved successfully');
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // Red
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _requestDelete() {
    setState(() {
      _currentState = ItemState.delete;
    });
  }

  void _confirmDelete() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    // Remove the number
    provider.removeNumber(widget.index);

    // Show toast
    messenger.showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E), // Green
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Deleted successfully',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Calculate sum of three dice digits
  int _calculateDiceSum(int value) {
    String valueStr = value.toString().padLeft(3, '0');
    int sum = 0;
    for (int i = 0; i < valueStr.length && i < 3; i++) {
      sum += int.parse(valueStr[i]);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color:
                  _currentState == ItemState.delete
                      ? Color(0xFFFEF2F2)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _currentState == ItemState.delete
                        ? Colors.red.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildContent(),
          ),
          if (_currentState != ItemState.delete)
            Positioned(
              left: 0,
              top: 2,
              bottom: 2,
              child: Container(
                width: 5.5,
                decoration: BoxDecoration(
                  color:
                      _calculateDiceSum(widget.number.value) >= 11
                          ? const Color(0xFF3B82F6) // Blue for HI
                          : const Color(0xFFEF4444), // Red for LO
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case ItemState.edit:
        return Row(
          children: [
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFEFF6FF),
              ),
              child: TextField(
                controller: _editController,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(3),
                  FilteringTextInputFormatter.allow(RegExp(r'[1-6]')),
                ],
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                autofocus: true,
              ),
            ),
            const Spacer(),
            _buildSmallButton(
              'Save',
              const Color(0xFF3B82F6),
              _saveEdit,
            ), // Save
            const SizedBox(width: 8),
            _buildSmallButton(
              'Cancel',
              const Color(0xFFE2E8F0),
              _cancelAction,
              textColor: const Color.fromARGB(255, 37, 37, 37),
            ),
          ],
        );

      case ItemState.delete:
        return Row(
          children: [
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       color: Colors.red.withOpacity(0.2),
            //       width: 1,
            //     ),
            //     color: const Color(0xFFFEE2E2),
            //     shape: BoxShape.circle,
            //   ),
            //   child: Center(
            //     child: const Icon(
            //       Icons.warning_amber_rounded,
            //       color: Color(0xFFDC2626),
            //       size: 20,
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Delete Entry ${widget.number.value}?',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This action cannot be undone.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSmallButton(
                  'Delete',
                  const Color(0xFFEF4444),
                  _confirmDelete,
                ),
                const SizedBox(width: 8),
                _buildSmallButton(
                  'Cancel',
                  Colors.white,
                  _cancelAction,
                  textColor: const Color.fromARGB(255, 37, 37, 37),
                  borderColor: const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ],
        );

      case ItemState.normal:
        final val = widget.number.value;
        final sum = _calculateDiceSum(val);
        final isHigh = sum >= 11;

        return Row(
          children: [
            Text(
              val.toString().padLeft(3, '0'), // 001, 123
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (isHigh
                        ? const Color(0xFFDBEAFE) // Light Blue
                        : const Color(0xFFFFE4E6)), // Light Red
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isHigh
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFFDA4AF),
                  width: 1,
                ),
              ),
              child: Text(
                isHigh ? 'HI' : 'LO',
                style: TextStyle(
                  color:
                      isHigh
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFBE123C),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                onPressed: _startEdit,
                splashRadius: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                onPressed: _requestDelete,
                splashRadius: 20,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildSmallButton(
    String label,
    Color color,
    VoidCallback onTap, {
    Color? textColor,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
