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
      backgroundColor: const Color(0xFF060B19), // Dark Navy Background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
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
                      // Back Button mostly implicit in navigation, but here we can just use the header title
                      // Or add a specific back button if needed.
                      // Current design shows "Roll History" centered.
                      // We'll trust system back swipe or add a leading implementation if requested.
                      // Adding a tap listener to go back for convenience since there's no explicit back button in the mockup header
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.history,
                          color: Color(0xFF5A9DFF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ประวัติการทอย', // Roll History
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.casino, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  // Show most recent first? Usually history is reversed.
                  // Assuming provider.numbers is ordered by insertion (oldest first).
                  // We likely want newest on top.
                  final reversedList = provider.numbers.reversed.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: reversedList.length,
                    itemBuilder: (context, index) {
                      // Calculate actual index in original list for updates/deletes
                      final originalIndex = provider.numbers.length - 1 - index;
                      final number = reversedList[index];

                      return HistoryItem(
                        key: ValueKey(
                          number,
                        ), // Assuming Number object identity/hash is stable enough or recreating widgets is fine
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
    // Widget will be removed from tree by parent list rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1623),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _currentState == ItemState.normal
                  ? const Color(0xFF1E2738)
                  : (_currentState == ItemState.delete
                      ? Colors.redAccent.withOpacity(0.5)
                      : const Color(0xFF2E7CF6).withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case ItemState.edit:
        return Row(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2E7CF6)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _editController,
                style: const TextStyle(
                  color: Colors.white,
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
              'บันทึก',
              const Color(0xFF2E7CF6),
              _saveEdit,
            ), // Save
            const SizedBox(width: 8),
            _buildSmallButton('ยกเลิก', Colors.grey, _cancelAction), // Cancel
          ],
        );

      case ItemState.delete:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ลบรายการ ${widget.number.value.toString().padLeft(3, '0')}?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ไม่สามารถย้อนกลับได้',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSmallButton(
                  'ลบ',
                  const Color(0xFFDC2626), // Red 600
                  _confirmDelete,
                ),
                const SizedBox(width: 8),
                _buildSmallButton(
                  'ยกเลิก',
                  Colors.transparent,
                  _cancelAction,
                  textColor: Colors.white70,
                  borderColor: Colors.white24,
                ),
              ],
            ),
          ],
        );

      case ItemState.normal:
        final val = widget.number.value;
        final isHigh = val > 10; // Simple HI/LO logic
        // 11-18 = High (Hi), 3-10 = Low (Lo) based on typical Sic Bo rules
        // Assuming user just inputs Sum. If input is 1-6 multiple times, logic differs.
        // Based on "012", "003", seems to be Sum input or single dice?
        // 0-999?
        // Let's stick to simple > 10 is HI for now.

        return Row(
          children: [
            Text(
              val.toString().padLeft(3, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                // specialized font usually looks good for numbers
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isHigh
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFF450A0A))
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isHigh
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              child: Text(
                isHigh ? 'HI' : 'LO', // สูง / ต่ำ
                style: TextStyle(
                  color:
                      isHigh
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFFF87171),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
              onPressed: _startEdit,
              splashRadius: 20,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.grey),
              onPressed: _requestDelete,
              splashRadius: 20,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
