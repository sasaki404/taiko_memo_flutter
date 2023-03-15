import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'database_manager.dart';

// 楽曲情報のクラス
class Music {
  int? id; // 主キー
  String name; // 楽曲名
  String? kind; // 難しさ
  num? count; // 星の数
  String? difficulty; // 全良難易度
  String? target; // 目標
  String? description; // 備考
  bool isFinished = false; // 完了フラグ
  DateTime? deadline; // 期限
  DateTime? finishedAt; // 完了日時

  // コンストラクタ
  Music(
      {required this.id,
      required this.name,
      this.kind,
      this.count,
      this.difficulty,
      this.target,
      this.description,
      this.deadline,
      this.finishedAt,
      required this.isFinished});

  // Map型のオブジェクトへ変換
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'kind': kind,
      'count': count,
      'difficulty': difficulty,
      'target': target,
      'description': description,
      'isFinished': isFinished ? 1 : 0,
      'deadline': deadline,
      'finishedAt': finishedAt
    };
  }

  @override
  String toString() {
    return 'Music{id: $id, name: $name}';
  }

  // 楽曲情報をmusicテーブルに挿入する
  static Future<void> insertMusic(Music music) async {
    final Database db = await DatabaseManager.getDatabase();
    await db.insert(
      'music',
      music.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 楽曲情報一覧を取得する
  static Future<List<Music>> getMusics() async {
    final Database db = await DatabaseManager.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('music');
    return List.generate(maps.length, (i) {
      return Music(
          id: maps[i]['id'],
          name: maps[i]['name'],
          kind: maps[i]['kind'],
          count: maps[i]['count'],
          difficulty: maps[i]['difficuly'],
          target: maps[i]['target'],
          description: maps[i]['description'],
          isFinished: (maps[i]['isFinished'] == 1) ? true : false,
          deadline: maps[i]['deadline'],
          finishedAt: maps[i]['finishedAt']);
    });
  }

  // 楽曲情報を更新する
  static Future<void> updateMusic(Music music) async {
    final db = await DatabaseManager.getDatabase();
    await db.update(
      'music',
      music.toMap(),
      where: "id = ?",
      whereArgs: [music.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // 楽曲情報を削除する
  static Future<void> deleteMusic(int id) async {
    final db = await DatabaseManager.getDatabase();
    await db.delete(
      'music',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
