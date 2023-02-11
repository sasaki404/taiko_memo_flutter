import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

// 本アプリのDB管理クラス
// もし複数のDBが必要になったらjoinの第二引数を指定するためのイニシャライザを実装する
class DatabaseManager {
  // アプリに組み込まれているデータベースを取得する
  static Future<Database> getDatabase() async {
    // var directory = await getDatabasesPath();
    // var path = join(directory, 'taiko_memo_database.db');
    // await deleteDatabase(path); // データベースの削除（テーブルの設計を変更した時に使う）
    return openDatabase(
      join(await getDatabasesPath(), 'taiko_memo_database.db'),
      onCreate: (db, version) async {
        // 楽曲情報テーブルの作成
        await db.execute(
            "CREATE TABLE music(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)");
        // 楽曲のメモテーブルの作成
        await db.execute(
            "CREATE TABLE memo(id INTEGER PRIMARY KEY ,musicId INTEGER, text TEXT, FOREIGN KEY(musicId) REFERENCES music(id))");
      },
      version: 1,
    );
  }
}
