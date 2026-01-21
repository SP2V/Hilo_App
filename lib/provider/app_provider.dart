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
    notifyListeners();
  }

  Numbers getNumber(int index) {
    return _numbers[index];
  }

  void addNumber(Numbers number) async {
    var db = NumberDB();
    int newId = await db.InsertData(number);

    Numbers numberWithId = Numbers(number.value, id: newId);

    _numbers.insert(0, numberWithId);
    notifyListeners();
  }

  void removeNumber(int index) async {
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
      Numbers updatedNumber = Numbers(number.value, id: originalNumber.id);

      var db = NumberDB();
      await db.UpdateData(updatedNumber);

      _numbers[index] = updatedNumber;
      notifyListeners();
    }
  }

  void clearHistory() async {
    var db = NumberDB();
    for (var n in _numbers) {
      if (n.id != null) {
        await db.DeleteData(n.id!);
      }
    }
    _numbers.clear();
    notifyListeners();
  }

  // Statistics calculation methods
  Map<int, int> getFaceCount() {
    Map<int, int> faceCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var number in _numbers) {
      String valueStr = number.value.toString();
      for (int i = 0; i < valueStr.length; i++) {
        int digit = int.parse(valueStr[i]);
        if (digit >= 1 && digit <= 6) {
          faceCount[digit] = (faceCount[digit] ?? 0) + 1;
        }
      }
    }

    return faceCount;
  }

  Map<String, int> getPairs() {
    Map<String, int> pairs = {};

    for (var number in _numbers) {
      String valueStr = number.value.toString().padLeft(3, '0');
      if (valueStr.length >= 2) {
        List<String> digits = valueStr.split('');
        List<String> sorted = List.from(digits)..sort();

        // Generate all unique pairs
        Set<String> uniquePairs = {
          '${sorted[0]}${sorted[1]}',
          '${sorted[0]}${sorted[2]}',
          '${sorted[1]}${sorted[2]}',
        };

        for (var pair in uniquePairs) {
          pairs[pair] = (pairs[pair] ?? 0) + 1;
        }
      }
    }

    return pairs;
  }

  Map<String, int> getTriples() {
    Map<String, int> triples = {};

    for (var number in _numbers) {
      String valueStr = number.value.toString().padLeft(3, '0');
      if (valueStr.length >= 3) {
        List<String> digits = valueStr.split('');
        List<String> sorted = List.from(digits)..sort();
        String tripleKey = sorted.join('');
        triples[tripleKey] = (triples[tripleKey] ?? 0) + 1;
      }
    }

    return triples;
  }

  Map<int, int> getSums() {
    Map<int, int> sums = {};

    for (var number in _numbers) {
      String valueStr = number.value.toString();
      int sum = 0;
      for (int i = 0; i < valueStr.length; i++) {
        sum += int.parse(valueStr[i]);
      }
      sums[sum] = (sums[sum] ?? 0) + 1;
    }

    return sums;
  }

  String getFrequency(int count) {
    if (_numbers.isEmpty) return '-';
    double pct = (count / _numbers.length) * 100;
    return '$count/${_numbers.length} = ${pct.toStringAsFixed(0)}%';
  }
}
