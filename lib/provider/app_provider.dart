import 'package:flutter/foundation.dart';
import 'package:hilo/models/number.dart';
import 'package:hilo/database/number_db.dart';

class AppProvider with ChangeNotifier {
  List<Numbers> _numbers = [];

  List<Numbers> get numbers => _numbers;

  Future<void> loadNumbers() async {
    var db = NumberDB();
    List<Numbers> loadedNumbers = await db.LoadAllData();
    _numbers = loadedNumbers;
    // Sort logic can go here if needed, for now just load as is.
    // Usually DB returns in key order (insertion order)
    notifyListeners();
  }

  Numbers getNumber(int index) {
    return _numbers[index];
  }

  void addNumber(Numbers number) async {
    var db = NumberDB();
    int newId = await db.InsertData(number);

    // Create new object with ID to store in local state
    Numbers numberWithId = Numbers(number.value, id: newId);

    _numbers.insert(0, numberWithId); // Insert at top for "newest first" visual
    notifyListeners();
  }

  void removeNumber(int index) async {
    // index here matches the UI list which might be reversed or not.
    // However, if we assume _numbers matches UI order (newest first?):
    // We should be careful.
    // Let's rely on the method in HistoryItem being passed valid UI index.

    Numbers numberToRemove = _numbers[index];
    if (numberToRemove.id != null) {
      var db = NumberDB();
      await db.DeleteData(numberToRemove.id!);
      _numbers.removeAt(index);
      notifyListeners();
    }
  }

  void updateNumber(int index, Numbers number) async {
    Numbers originalNumber = _numbers[index];
    if (originalNumber.id != null) {
      // Create updated object preserving the ID
      Numbers updatedNumber = Numbers(number.value, id: originalNumber.id);

      var db = NumberDB();
      await db.UpdateData(updatedNumber);

      _numbers[index] = updatedNumber;
      notifyListeners();
    }
  }

  void clearHistory() async {
    // This requires a "Delete All" method in DB or iterating.
    // For simplicity, let's iterate deletions or just drop store if DB supports it.
    // Iterating for now is safest without changing DB interface too much.
    var db = NumberDB();
    for (var n in _numbers) {
      if (n.id != null) {
        await db.DeleteData(n.id!);
      }
    }
    _numbers.clear();
    notifyListeners();
  }
}
