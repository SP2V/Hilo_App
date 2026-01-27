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
  Map<int, int> getFaceCount({List<Numbers>? source}) {
    Map<int, int> faceCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    List<Numbers> data = source ?? _numbers;

    for (var number in data) {
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

  Map<String, int> getPairs({List<Numbers>? source}) {
    Map<String, int> pairs = {};
    List<Numbers> data = source ?? _numbers;

    for (var number in data) {
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

  Map<String, int> getTriples({List<Numbers>? source}) {
    Map<String, int> triples = {};
    List<Numbers> data = source ?? _numbers;

    for (var number in data) {
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

  Map<int, int> getSums({List<Numbers>? source}) {
    Map<int, int> sums = {};
    List<Numbers> data = source ?? _numbers;

    for (var number in data) {
      String valueStr = number.value.toString();
      int sum = 0;
      for (int i = 0; i < valueStr.length; i++) {
        sum += int.parse(valueStr[i]);
      }
      sums[sum] = (sums[sum] ?? 0) + 1;
    }

    return sums;
  }

  // Helper to count digit frequency
  Map<String, int> _getFrequencyMap(String numStr) {
    Map<String, int> map = {};
    for (int i = 0; i < numStr.length; i++) {
      String digit = numStr[i];
      map[digit] = (map[digit] ?? 0) + 1;
    }
    return map;
  }

  // Get predictive pool based on similarity to the latest number
  List<Numbers> getPredictivePool() {
    if (_numbers.isEmpty) return [];

    List<Numbers> pool = [];
    Numbers latest = _numbers.first;
    Map<String, int> latestMap = _getFrequencyMap(latest.value.toString());

    // Iterate history starting from index 1 (previous rounds)
    // We look for contexts similar to 'latest', and collect the *next* outcome
    // Since list is ordered [latest, ..., oldest], if _numbers[i] is the context,
    // then _numbers[i-1] is the outcome that followed it.
    for (int i = 1; i < _numbers.length; i++) {
      Numbers context = _numbers[i];
      Map<String, int> contextMap = _getFrequencyMap(context.value.toString());

      int matchCount = 0;
      latestMap.forEach((digit, count) {
        if (contextMap.containsKey(digit)) {
          int commonCount =
              count < contextMap[digit]! ? count : contextMap[digit]!;
          matchCount += commonCount;
        }
      });

      // Similarity condition from user: match >= 2
      if (matchCount >= 2) {
        // Add the outcome that followed this context
        pool.add(_numbers[i - 1]);
      }
    }

    return pool;
  }

  // --- ส่วนที่เพิ่มใหม่: Logic คำนวณความน่าจะเป็นของ Input ตัวใหม่ ---

  // Helper class หรือ Map เพื่อส่งค่ากลับ
  Map<String, dynamic> calculateProbability(int inputNumber) {
    if (_numbers.isEmpty) {
      return {'probability': '0.00%', 'matchCount': 0, 'relatedNumbers': []};
    }

    // 1. แปลง Input เป็น Frequency Map (เช่น 324 -> {3:1, 2:1, 4:1})
    String inputStr = inputNumber.toString();
    Map<String, int> inputMap = _getFrequencyMap(inputStr);

    List<Map<String, dynamic>> relatedNumbers = [];

    // 2. Loop เช็คกับ History ทุกตัว
    for (var number in _numbers) {
      String histStr = number.value.toString();
      Map<String, int> histMap = _getFrequencyMap(histStr);

      int matchCount = 0;
      List<String> matchedDigits = [];

      // Logic: นับจำนวนที่ตรงกันจริง (รวมเลขเบิ้ล)
      inputMap.forEach((digit, count) {
        if (histMap.containsKey(digit)) {
          // เอาจำนวนที่น้อยที่สุดของทั้งสองฝั่ง (เช่น Input มี 1 สองตัว, Hist มี 1 ตัวเดียว -> ได้ 1 แต้ม)
          int commonCount = count < histMap[digit]! ? count : histMap[digit]!;
          matchCount += commonCount;
          // เก็บตัวเลขที่ตรงกันไว้แสดงผล
          for (int i = 0; i < commonCount; i++) matchedDigits.add(digit);
        }
      });

      // เงื่อนไข: ต้องตรงกัน 2 ตัวขึ้นไป (เช่น 23, 24, 34)
      if (matchCount >= 2) {
        relatedNumbers.add({
          'value': number.value,
          'matches': matchCount,
          'matchedDigits': matchedDigits.join(','),
        });
      }
    }

    // 3. คำนวณเปอร์เซ็นต์
    double probability = (relatedNumbers.length / _numbers.length) * 100;

    return {
      'probability': '${probability.toStringAsFixed(2)}%',
      'matchCount': relatedNumbers.length,
      'totalHistory': _numbers.length,
      'relatedNumbers':
          relatedNumbers, // รายการเลขที่เข้าเงื่อนไขเอาไปโชว์ต่อได้
    };
  }

  String getFrequency(int count, {int? total}) {
    int denominator = total ?? _numbers.length;
    if (denominator == 0) return '-';
    double pct = (count / denominator) * 100;
    return '$count/$denominator = ${pct.toStringAsFixed(0)}%';
  }
}
