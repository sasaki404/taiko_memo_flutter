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

  void insertMusic(Music m) async {
    Music _music = m;
    await Music.insertMusic(_music);
    final List<Music> musics = await Music.getMusics();
    setState(() {
      _musicList = musics;
      _selectedvalue = null;
    });
    myController.clear();
  }

  void updateMusic(Music m) async {
    Music newMusic = m;
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
                        value: _musicList[index].isFinished,
                        onChanged: (value) {
                          setState(() {
                            _musicList[index].isFinished =
                                !_musicList[index].isFinished;
                          });
                          Music.updateMusic(_musicList[index]);
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
                                    deleteMusic: deleteMusic,
                                    insertMusic: insertMusic);
                              }).then((value) {
                            myController.clear();
                            setState(() {});
                          });
                        },
                        icon: const Icon(
                          Icons.edit,
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
                  builder: (context) {
                    return HomePageEditDialog(
                        music: new Music(id: null, name: '', isFinished: false),
                        updateMusic: updateMusic,
                        deleteMusic: deleteMusic,
                        insertMusic: insertMusic);
                  }).then((value) {
                myController.clear();
                setState(() {});
              });
              ;
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
