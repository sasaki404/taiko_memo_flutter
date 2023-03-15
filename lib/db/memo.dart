import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'database_manager.dart';

// entity
class Memo {
  int? id;
  int musicId; // 外部キーmusic(id)
  String text; // メモ
  int? ryoNum; // 良の数
  int? kaNum; // 可の数
  int? fukaNum; // 不可の数
  int? maxCom; // 最大コンボ数
  int? rendaNum; // 連打数
  String createdAt;

  // 名前付きコンストラクタ
  Memo(
      {required this.id,
      required this.musicId,
      required this.text,
      this.ryoNum,
      this.kaNum,
      this.fukaNum,
      this.maxCom,
      this.rendaNum,
      required this.createdAt});

  // Map型のオブジェクトへ変換
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'musicId': musicId,
      'text': text,
      'ryoNum': ryoNum,
      'kaNum': kaNum,
      'fukaNum': fukaNum,
      'maxCom': maxCom,
      'rendaNum': rendaNum,
      'createdAt': createdAt,
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
        // カラム追加時はここもいじらんとあかん
        columns: [
          "id",
          "musicId",
          "text",
          "ryoNum",
          "kaNum",
          "fukaNum",
          "maxCom",
          "rendaNum",
          "createdAt"
        ],
        where: 'musicId = ?',
        whereArgs: [musicId],
        orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return Memo(
          id: maps[i]['id'],
          musicId: maps[i]['musicId'],
          text: maps[i]['text'],
          ryoNum: maps[i]['ryoNum'],
          kaNum: maps[i]['kaNum'],
          fukaNum: maps[i]['fukaNum'],
          maxCom: maps[i]['maxCom'],
          rendaNum: maps[i]['rendaNum'],
          createdAt: maps[i]['createdAt']);
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
