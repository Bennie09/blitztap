import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_history.dart';

const String _historyKey = 'match_history_list';

class HistoryService {
  static final HistoryService _instance = HistoryService._();
  factory HistoryService() => _instance;
  HistoryService._();

  Future<List<MatchHistory>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey);
    if (jsonList == null || jsonList.isEmpty) return [];
    final list = <MatchHistory>[];
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        list.add(MatchHistory.fromJson(map));
      } catch (_) {}
    }
    list.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return list;
  }

  Future<List<MatchHistory>> getRecent({int limit = 3}) async {
    final all = await getAll();
    return all.take(limit).toList();
  }

  Future<List<MatchHistory>> getFavourites() async {
    final all = await getAll();
    return all.where((m) => m.isFavourite).toList();
  }

  Future<void> addMatch(MatchHistory match) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    jsonList.add(jsonEncode(match.toJson()));
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<void> deleteMatch(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    final newList = <String>[];
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (map['id'] != id) newList.add(jsonStr);
      } catch (_) {
        newList.add(jsonStr);
      }
    }
    await prefs.setStringList(_historyKey, newList);
  }

  Future<void> toggleFavourite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    final newList = <String>[];
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (map['id'] == id) {
          map['isFavourite'] = !(map['isFavourite'] as bool? ?? false);
          newList.add(jsonEncode(map));
        } else {
          newList.add(jsonStr);
        }
      } catch (_) {
        newList.add(jsonStr);
      }
    }
    await prefs.setStringList(_historyKey, newList);
  }

  Future<MatchHistory?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
