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

  // --- New Prediction Logic Integration ---

  List<int> _getDigits(int value) {
    final s = value.toString().padLeft(3, '0');
    return s.split('').map((e) => int.tryParse(e) ?? 0).toList();
  }

  Predictions get predictions {
    if (_numbers.isEmpty) return Predictions();
    // _numbers is [newest, ..., oldest]
    // history needs to be [oldest, ..., newest] for the user's logic iterating 0..length
    final history = _numbers.reversed.map((n) => _getDigits(n.value)).toList();
    final lastRoll = history.last;
    return calculatePredictions(history, lastRoll);
  }

  List<StatRow> getStatsRows(String activeFilter, {bool sortByFreq = false}) {
    return buildStatsRows(
      predictions,
      activeFilter.toLowerCase(),
      sortByFreq: sortByFreq,
    );
  }

  // Preserve old methods if needed, or rely on new logic.
  // The UI will be updated to use getStatsRows, so we can ignore old methods or remove them later.
  // For now I'm leaving the class structure clean by not deleting old methods yet if I was editing,
  // but since I am overwriting the file or appending, I should be careful.
  // I will append the user's classes and functions at the end of the file.

  GameStats get gameStats {
    int even = 0;
    int odd = 0;
    int hi = 0;
    int low = 0;

    for (var number in _numbers) {
      final digits = _getDigits(number.value);
      final sum = digits.fold(0, (a, b) => a + b);

      if (sum % 2 == 0) {
        even++;
      } else {
        odd++;
      }

      if (sum >= 11) {
        hi++;
      } else {
        low++;
      }
    }

    return GameStats(even: even, odd: odd, hi: hi, low: low);
  }
}

class GameStats {
  final int even;
  final int odd;
  final int hi;
  final int low;

  GameStats({
    required this.even,
    required this.odd,
    required this.hi,
    required this.low,
  });
}

// --- User Provided Logic Classes and Functions ---

class Predictions {
  Map<int, int> faceCount;
  Map<String, int> pairs;
  Map<String, int> triples;
  Map<int, int> sums;
  int totalMatches;

  Predictions({
    Map<int, int>? faceCount,
    Map<String, int>? pairs,
    Map<String, int>? triples,
    Map<int, int>? sums,
    this.totalMatches = 0,
  }) : faceCount = faceCount ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0},
       pairs = pairs ?? {},
       triples = triples ?? {},
       sums = sums ?? {};
}

bool matchesTriple(List<int> roll1, List<int> roll2) {
  if (roll1.length != 3 || roll2.length != 3) return false;
  final s1 = List<int>.from(roll1)..sort();
  final s2 = List<int>.from(roll2)..sort();
  for (var i = 0; i < 3; i++) {
    if (s1[i] != s2[i]) return false;
  }
  return true;
}

bool matchesPair(List<int> roll1, List<int> roll2) {
  if (roll1.length != 3 || roll2.length != 3) return false;

  Set<String> makePairs(List<int> r) {
    final s = List<int>.from(r)..sort();
    final p = <String>{};
    p.add('${s[0]}${s[1]}');
    p.add('${s[0]}${s[2]}');
    p.add('${s[1]}${s[2]}');
    return p;
  }

  final p1 = makePairs(roll1);
  final p2 = makePairs(roll2);
  for (var x in p1) {
    if (p2.contains(x)) return true;
  }
  return false;
}

bool matchesSum(List<int> roll1, List<int> roll2) {
  int sum(List<int> r) => r.fold(0, (a, b) => a + b);
  return sum(roll1) == sum(roll2);
}

Predictions calculatePredictions(List<List<int>> history, List<int>? lastRoll) {
  if (lastRoll == null || history.length < 2) {
    return Predictions();
  }

  final predictions = Predictions();

  for (var i = 0; i < history.length - 1; i++) {
    final currentRoll = history[i];
    final nextRoll = history[i + 1];

    final hasTripleMatch = matchesTriple(currentRoll, lastRoll);
    final hasPairMatch = matchesPair(currentRoll, lastRoll);
    // final hasSumMatch = matchesSum(currentRoll, lastRoll);

    final isNextRollTheLastOne = (i + 1 == history.length - 1);

    if ((hasTripleMatch || hasPairMatch) && !isNextRollTheLastOne) {
      predictions.totalMatches++;

      // Count unique faces (singles)
      final uniqueFaces = nextRoll.toSet();
      for (var face in uniqueFaces) {
        predictions.faceCount[face] = (predictions.faceCount[face] ?? 0) + 1;
      }

      // Count pairs (unique)
      final sorted = List<int>.from(nextRoll)..sort();
      final allPairs = <String>{
        '${sorted[0]}${sorted[1]}',
        '${sorted[0]}${sorted[2]}',
        '${sorted[1]}${sorted[2]}',
      };
      for (var pairKey in allPairs) {
        predictions.pairs[pairKey] = (predictions.pairs[pairKey] ?? 0) + 1;
      }

      // Count triple
      final tripleKey = '${sorted[0]}${sorted[1]}${sorted[2]}';
      predictions.triples[tripleKey] =
          (predictions.triples[tripleKey] ?? 0) + 1;

      // Count sum
      final sum = nextRoll.fold(0, (a, b) => a + b);
      predictions.sums[sum] = (predictions.sums[sum] ?? 0) + 1;
    }
  }

  return predictions;
}

class StatRow {
  final String dice;
  final String label;
  final String frequency;
  final String type;
  final dynamic sortValue;
  final int count;

  StatRow(
    this.dice,
    this.label,
    this.frequency,
    this.type,
    this.sortValue,
    this.count,
  );
}

List<StatRow> buildStatsRows(
  Predictions predictions,
  String activeFilter, {
  bool sortByFreq = false,
}) {
  final rows = <StatRow>[];
  final total = predictions.totalMatches;

  String freqText(int count) {
    if (total == 0) return '-';
    final pct = ((count / total) * 100).round();
    return '$count/$total = $pct%';
  }

  if (activeFilter == 'all' || activeFilter == 'single') {
    var entries = <MapEntry<int, int>>[];
    for (var i = 1; i <= 6; i++) {
      final c = predictions.faceCount[i] ?? 0;
      if (c > 0) entries.add(MapEntry(i, c));
    }
    if (sortByFreq) {
      entries.sort((a, b) => b.value.compareTo(a.value));
    } else {
      entries.sort((a, b) => a.key.compareTo(b.key));
    }

    for (var i = 0; i < entries.length; i++) {
      final key = entries[i].key;
      final val = entries[i].value;
      rows.add(
        StatRow(
          key.toString(),
          i == 0 && activeFilter == 'all' ? '(single)' : '',
          freqText(val),
          'single',
          key,
          val,
        ),
      );
    }
  }

  if (activeFilter == 'all' || activeFilter == 'pair') {
    final entries =
        predictions.pairs.entries.where((e) => e.value > 0).toList();
    if (sortByFreq) {
      entries.sort((a, b) => b.value.compareTo(a.value));
    } else {
      entries.sort((a, b) => a.key.compareTo(b.key));
    }

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final formatted = e.key.split('').join(',');
      rows.add(
        StatRow(
          formatted,
          i == 0 && activeFilter == 'all' ? '(pair)' : '',
          freqText(e.value),
          'pair',
          e.key,
          e.value,
        ),
      );
    }
  }

  if (activeFilter == 'all' || activeFilter == 'triple') {
    final entries =
        predictions.triples.entries.where((e) => e.value > 0).toList();
    if (sortByFreq) {
      entries.sort((a, b) => b.value.compareTo(a.value));
    } else {
      entries.sort((a, b) => a.key.compareTo(b.key));
    }

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final formatted = e.key.split('').join(',');
      rows.add(
        StatRow(
          formatted,
          i == 0 && activeFilter == 'all' ? '(triple)' : '',
          freqText(e.value),
          'triple',
          e.key,
          e.value,
        ),
      );
    }
  }

  if (activeFilter == 'all' || activeFilter == 'sum') {
    final entries = predictions.sums.entries.where((e) => e.value > 0).toList();
    if (sortByFreq) {
      entries.sort((a, b) => b.value.compareTo(a.value));
    } else {
      entries.sort((a, b) => a.key.compareTo(b.key));
    }

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      rows.add(
        StatRow(
          'Sum ${e.key}',
          i == 0 && activeFilter == 'all' ? '(Sum)' : '',
          freqText(e.value),
          'sum',
          e.key,
          e.value,
        ),
      );
    }
  }

  return rows;
}
