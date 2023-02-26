import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

// 本アプリのDB管理クラス
// もし複数のDBが必要になったらjoinの第二引数を指定するためのイニシャライザを実装する
class DatabaseManager {
  static const String musicTableQuery =
      "CREATE TABLE music (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, kind TEXT, count INTEGER, difficulty TEXT, target TEXT, description TEXT, isFinished INTEGER, deadline TEXT, finishedAt TEXT)";
  static const String memoTableQuery =
      "CREATE TABLE memo (id INTEGER PRIMARY KEY, musicId INTEGER, text TEXT, ryoNum INTEGER, kaNum INTEGER, fukaNum INTEGER, maxCom INTEGER, rendaNum INTEGER, FOREIGN KEY(musicId) REFERENCES music(id))";

  // アプリに組み込まれているデータベースを取得する
  static Future<Database> getDatabase() async {
    // var directory = await getDatabasesPath();
    // var path = join(directory, 'taiko_memo_database.db');
    // await deleteDatabase(path); // データベースの削除（テーブルの設計を変更した時に使う）
    return openDatabase(
      join(await getDatabasesPath(), 'taiko_memo_database.db'),
      onCreate: (db, version) async {
        // 楽曲情報テーブルの作成
        await db.execute(musicTableQuery);
        // 楽曲のメモテーブルの作成
        await db.execute(memoTableQuery);
      },
      version: 1,
    );
  }
}
