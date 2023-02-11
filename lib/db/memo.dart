import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'database_manager.dart';

class Memo {
  int? id;
  int musicId; // 外部キーmusic(id)
  String text; // メモ

  // コンストラクタ
  Memo({required this.id, required this.musicId, required this.text});

  // Map型のオブジェクトへ変換
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'musicId': musicId,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'Memo{id: $id, musicId: $musicId, text: $text}';
  }

  // 楽曲のメモをmemoテーブルに挿入する
  static Future<void> insertMemo(Memo memo) async {
    final Database db = await DatabaseManager.getDatabase();
    await db.insert(
      'memo',
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 楽曲のメモ一覧を取得する
  static Future<List<Memo>> getMemos(int musicId) async {
    final Database db = await DatabaseManager.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('memo',
        columns: ["id","musicId", "text"],
        where: 'musicId = ?',
        whereArgs: [musicId]);
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        musicId: maps[i]['musicId'],
        text: maps[i]['text'],
      );
    });
  }

  // 楽曲のメモを更新する
  static Future<void> updateMemo(Memo memo) async {
    final db = await DatabaseManager.getDatabase();
    await db.update(
      'memo',
      memo.toMap(),
      where: "id = ?",
      whereArgs: [memo.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // 楽曲のメモを削除する
  static Future<void> deleteMemo(int id) async {
    final db = await DatabaseManager.getDatabase();
    await db.delete(
      'memo',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
