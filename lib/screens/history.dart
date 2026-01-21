import 'package:flutter/material.dart';
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
    // Determine overall background color to match main app
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Light background to match Main
      body: SafeArea(
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Color(0xFFFBFDBFE)),
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
                  // Show most recent first
                  final reversedList = provider.numbers.reversed.toList();

                  if (reversedList.isEmpty) {
                    return Center(
                      child: Text(
                        'No historical data available.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: reversedList.length,
                    itemBuilder: (context, index) {
                      // Calculate actual index in original list for updates/deletes
                      final originalIndex = provider.numbers.length - 1 - index;
                      final number = reversedList[index];

                      return HistoryItem(
                        key: ValueKey(number),
                        number: number,
                        index: originalIndex,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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

  void _saveEdit() {
    final newValue = int.tryParse(_editController.text);
    if (newValue != null) {
      Provider.of<AppProvider>(
        context,
        listen: false,
      ).updateNumber(widget.index, Numbers(newValue));
      setState(() {
        _currentState = ItemState.normal;
      });
    }
  }

  void _requestDelete() {
    setState(() {
      _currentState = ItemState.delete;
    });
  }

  void _confirmDelete() {
    Provider.of<AppProvider>(context, listen: false).removeNumber(widget.index);
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
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color:
                      widget.number.value > 10
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red.withOpacity(0.2),
                  width: 1,
                ),
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
        final isHigh = val > 10;

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
