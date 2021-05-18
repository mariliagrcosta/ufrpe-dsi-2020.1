import 'package:dsi_app/model/word_pair_model.dart';

int _nextWordPairId = 1;

List<DSIWordPair> _wordPairs;

class DSIWordPairController {
  DSIWordPairController() {
    _initWordPairs();
  }

  void _initWordPairs() {
    if (_wordPairs != null) return;

    _wordPairs = <DSIWordPair>[];
    for (var i = 0; i < 20; i++) {
      DSIWordPair wordPair = DSIWordPair();
      wordPair.id = _nextWordPairId++;
      _wordPairs.add(wordPair);
    }
    _wordPairs.sort();
  }

  List<DSIWordPair> getAll() {
    return List.unmodifiable(_wordPairs);
  }

  DSIWordPair getById(int id) {
    if (id == null) return null;

    for (var wp in _wordPairs) {
      if (wp.id == id) return wp;
    }
    return null;
  }

  List<DSIWordPair> getByFilter(bool test(DSIWordPair elemente)) {
    List<DSIWordPair> result = _wordPairs;
    if (test != null) {
      result = _wordPairs.where(test).toList();
    }
    return List.unmodifiable(result);
  }

  void save(DSIWordPair wordPair) {
    if (wordPair.id == null) {
      wordPair.id = _nextWordPairId++;
    } else {
      DSIWordPair oldWordPair = getById(wordPair.id);
      delete(oldWordPair);
    }
    _wordPairs.add(wordPair);
    _wordPairs.sort();
  }

  void delete(DSIWordPair wordPair) {
    _wordPairs.remove(wordPair);
    _wordPairs.sort();
  }
}
