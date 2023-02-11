import 'package:flutter/material.dart';
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
  final myController = TextEditingController();
  final upDateController = TextEditingController();
  var _selectedvalue;

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
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: _musicList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Text(
                      'ID ${_musicList[index].id}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                    trailing: SizedBox(
                      child: IconButton(
                        onPressed: () {
                          myController.text = _musicList[index].name;
                          showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text("楽曲情報編集"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('楽曲名'),
                                        TextField(controller: myController),
                                        ButtonBar(children: <Widget>[
                                          ElevatedButton.icon(
                                            label: const Text(
                                              '保存',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            icon: const Icon(
                                              Icons.save,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            onPressed: () async {
                                              Music _music = Music(
                                                  name: myController.text,
                                                  id: _musicList[index].id);
                                              await Music.updateMusic(_music);
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
                                          ElevatedButton.icon(
                                            label: const Text(
                                              '削除',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            icon: const Icon(
                                              Icons.delete_forever,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("本当に削除しますか？"),
                                                      actions: [
                                                        TextButton(
                                                          child: Text("はい"),
                                                          onPressed: () async {
                                                            await Music
                                                                .deleteMusic(
                                                                    _musicList[
                                                                            index]
                                                                        .id!);
                                                            final List<Music>
                                                                musics =
                                                                await Music
                                                                    .getMusics();
                                                            setState(() {
                                                              _musicList =
                                                                  musics;
                                                            });
                                                            myController
                                                                .clear();
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        TextButton(
                                                            child: const Text(
                                                                "いいえ"),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            })
                                                      ],
                                                    );
                                                  });
                                            },
                                          ),
                                        ])
                                      ],
                                    ),
                                  )).then((value) {
                            myController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
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
                            ElevatedButton(
                              child: Text('保存'),
                              onPressed: () async {
                                Music _music =
                                    Music(name: myController.text, id: null);
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
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
