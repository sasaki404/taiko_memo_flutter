import 'package:flutter/material.dart';
import 'db/memo.dart';

// 楽曲に関するメモなどを表示させるページ
class MusicPage extends StatefulWidget {
  const MusicPage({Key? key, required this.id, required this.musicName})
      : super(key: key);
  final int id;
  final String musicName;

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List _memoList = [];
  final myController = TextEditingController();

  Future<void> initialize() async {
    _memoList = await Memo.getMemos(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.musicName),
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
              itemCount: _memoList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Text(
                      'ID ${_memoList[index].id}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text('${_memoList[index].text}'),
                    onTap: () {
                      // 編集ダイアログ実装
                      myController.text = _memoList[index].text;
                      showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextField(
                                      maxLines: 10,
                                      keyboardType: TextInputType.multiline,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder()),
                                      controller: myController,
                                    ),
                                    ButtonBar(children: <Widget>[
                                      ElevatedButton(
                                        child: Text("保存"),
                                        onPressed: () async {
                                          Memo _memo = Memo(
                                              id: _memoList[index].id,
                                              musicId: _memoList[index].musicId,
                                              text: myController.text);
                                          await Memo.updateMemo(_memo);
                                          final List<Memo> memos =
                                              await Memo.getMemos(
                                                  _memoList[index].musicId);
                                          setState(() {
                                            _memoList = memos;
                                          });
                                          myController.clear();
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text("削除"),
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
                                                        await Memo.deleteMemo(
                                                            _memoList[index]
                                                                .id);
                                                        final List<Memo> memos =
                                                            await Memo.getMemos(
                                                                _memoList[index]
                                                                    .musicId);
                                                        setState(() {
                                                          _memoList = memos;
                                                        });
                                                        myController.clear();
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text("いいえ"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        },
                                      )
                                    ])
                                  ],
                                ),
                              )).then(
                        (value) {
                          myController.clear();
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                  title: Text("メモを登録"),
                  content:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Text('${widget.musicName}のメモを入力するドン！'),
                    TextField(
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        controller: myController),
                    ElevatedButton(
                      child: Text('保存'),
                      onPressed: () async {
                        Memo _memo = Memo(
                            id: null,
                            text: myController.text,
                            musicId: widget.id);
                        await Memo.insertMemo(_memo);
                        final List<Memo> memos = await Memo.getMemos(widget.id);
                        setState(() {
                          _memoList = memos;
                        });
                        myController.clear();
                        Navigator.pop(context);
                      },
                    ),
                  ])));
        },
      ),
    );
  }
}
