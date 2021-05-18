import 'package:english_words/english_words.dart';

class DSIWordPair extends Comparable<DSIWordPair> {
  String id;
  String first;
  String second;
  bool favourite;

  DSIWordPair() {
    WordPair wordPair = WordPair.random();
    this.first = _capitalize(wordPair.first);
    this.second = _capitalize(wordPair.second);
  }

  String _capitalize(String s) {
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  @override
  String toString() {
    return '${this.first} ${this.second}';
  }

  @override
  int compareTo(DSIWordPair that) {
    int result = this.first.toLowerCase().compareTo(that.first.toLowerCase());
    if (result == 0) {
      result = this.second.toLowerCase().compareTo(that.second.toLowerCase());
    }
    return result;
  }

  DSIWordPair.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    first = json['first'];
    second = json['second'];
    favourite = json['favourite'];
  }
  Map<String, dynamic> toJson() => {
        'first': first,
        'second': second,
        'favourite': favourite,
      };
}
