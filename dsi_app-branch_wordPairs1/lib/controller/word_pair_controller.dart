import 'dart:async';
import 'package:dsi_app/model/word_pair_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DSIWordPairController {
  CollectionReference<Map<String, dynamic>> _wordPairs;

  DSIWordPairController() {
    _initWordPairs();
  }

  void _initWordPairs() {
    _wordPairs = FirebaseFirestore.instance.collection('wordpairs');
  }

  DSIWordPair _createWordPair(DocumentSnapshot<Map<String, dynamic>> e) {
    DSIWordPair result = DSIWordPair.fromJson(e.data());
    result.id = e.id;
    return result;
  }

  Future<Iterable<DSIWordPair>> getAll() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _wordPairs.get();
    return snapshot.docs.map((e) => _createWordPair(e));
  }

  Future<DSIWordPair> getById(String id) async {
    if (id == null) return null;

    DocumentSnapshot doc = await _wordPairs.doc(id).get();
    return _createWordPair(doc);
  }

  Future<Iterable<DSIWordPair>> getByFilter(
      bool test(DSIWordPair element)) async {
    Iterable<DSIWordPair> result = await getAll();
    if (test != null) {
      result = result.where(test).toList();
    }
    return List.unmodifiable(result);
  }

  Future save(DSIWordPair wordPair) async {
    if (wordPair.id == null) {
      return _wordPairs.add(wordPair.toJson());
    } else {
      return _wordPairs.doc(wordPair.id).update(wordPair.toJson());
    }
  }

  Future delete(DSIWordPair wordPair) {
    return _wordPairs.doc(wordPair.id).delete();
  }
}
