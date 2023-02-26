import 'package:flutter/material.dart';
import 'package:flutter_practice/home_page_edit_dialog.dart';
import 'dart:async';
import 'music_page.dart';
import 'db/music.dart';

// 楽曲一覧ページ
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Music> _musicList = [];
  bool _flag = false;
  final myController = TextEditingController();
  String? _kind = "おに";
  var _selectedvalue;

  void updateMusic(Music m) async {
    Music newMusic = Music(name: m.name, id: m.id, isFinished: m.isFinished);
    await Music.updateMusic(newMusic);
    final List<Music> musics = await Music.getMusics();
    setState(() {
      _musicList = musics;
      _selectedvalue = null;
    });
  }

  void deleteMusic(int id) async {
    await Music.deleteMusic(id);
    final List<Music> musics = await Music.getMusics();
    setState(() {
      _musicList = musics;
    });
    myController.clear();
  }

  Future<void> initialize() async {
    _musicList = await Music.getMusics();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('研究する譜面一覧'),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: FutureBuilder(
          future: initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 非同期通信未完了のとき
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: _musicList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                        value: _flag,
                        onChanged: (value) {
                          setState(() {
                            _flag = !_flag;
                          });
                        }),
                    title: Text('${_musicList[index].name}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MusicPage(
                                id: _musicList[index].id!,
                                musicName: _musicList[index].name)),
                      );
                    },
                    // 編集ボタン
                    trailing: SizedBox(
                      child: IconButton(
                        onPressed: () {
                          myController.text = _musicList[index].name;
                          showDialog<void>(
                              context: context,
                              builder: (context) {
                                return HomePageEditDialog(
                                    music: _musicList[index],
                                    updateMusic: updateMusic,
                                    deleteMusic: deleteMusic);
                              }).then((value) {
                            myController.clear();
                            setState(() {});
                          });
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ), // 編集ボタン終了
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text("新規楽曲登録"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('追加したい曲の情報を入力するドン！'),
                            TextField(controller: myController),
                            Text('難易度'),
                            DropdownButton(
                              items: const [
                                DropdownMenuItem(
                                    value: "おに", child: Text("おに")),
                                DropdownMenuItem(
                                    value: "おに裏", child: Text("おに裏")),
                                DropdownMenuItem(
                                    value: "むずかしい", child: Text("むずかしい")),
                                DropdownMenuItem(
                                    value: "ふつう", child: Text("ふつう")),
                                DropdownMenuItem(
                                    value: "かんたん", child: Text("かんたん")),
                              ],
                              value: _kind,
                              onChanged: (String? value) {
                                setState(() {
                                  _kind = value;
                                });
                              },
                            ),
                            ElevatedButton(
                              child: Text('保存'),
                              onPressed: () async {
                                Music _music = Music(
                                    name: myController.text,
                                    id: null,
                                    isFinished: _flag);
                                await Music.insertMusic(_music);
                                final List<Music> musics =
                                    await Music.getMusics();
                                setState(() {
                                  _musicList = musics;
                                  _selectedvalue = null;
                                });
                                myController.clear();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ));
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
