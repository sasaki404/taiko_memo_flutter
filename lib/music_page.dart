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
  List<Memo> _memoList = [];
  final myController = TextEditingController();
  final ryoController = TextEditingController();
  final kaController = TextEditingController();
  final fukaController = TextEditingController();
  final maxComController = TextEditingController();
  final rendaNumController = TextEditingController();
  double aveRyo = 0;
  double aveKa = 0;
  double aveFuka = 0;
  double aveMaxCom = 0;
  double aveRenda = 0;
  int noteNum = 0;

  Future<void> initialize() async {
    _memoList = await Memo.getMemos(widget.id);
    analyzeResult();
  }

  // 結果を分析する。getMemosを実行するタイミングで呼び出す
  void analyzeResult() {
    aveRyo = 0;
    aveKa = 0;
    aveFuka = 0;
    aveMaxCom = 0;
    aveRenda = 0;
    int n = _memoList.length;
    if (noteNum == 0 && n > 0) {
      noteNum = (_memoList[0].ryoNum ?? 0) +
          (_memoList[0].kaNum ?? 0) +
          (_memoList[0].fukaNum ?? 0);
    }
    for (int i = 0; i < _memoList.length; i++) {
      aveRyo += _memoList[i].ryoNum ?? 0;
      aveKa += _memoList[i].kaNum ?? 0;
      aveFuka += _memoList[i].fukaNum ?? 0;
      aveMaxCom += _memoList[i].maxCom ?? 0;
      aveRenda += _memoList[i].rendaNum ?? 0;
    }
    aveRyo /= n;
    aveKa /= n;
    aveFuka /= n;
    aveMaxCom /= n;
    aveRenda /= n;
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
            return Column(
              children: [
                Text(
                  '''
  平均  良:${aveRyo.toStringAsFixed(2)} 可:${aveKa.toStringAsFixed(2)} 不可:${aveFuka.toStringAsFixed(2)}
          連打:${aveRenda.toStringAsFixed(2)} 最大コンボ:${aveMaxCom.toStringAsFixed(2)}
  叩けた率: ${((noteNum - aveFuka) * 100 / noteNum).toStringAsFixed(2)}% 良の割合: ${(aveRyo * 100 / noteNum).toStringAsFixed(2)}%
                  ''',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _memoList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                              '良:${_memoList[index].ryoNum} 可:${_memoList[index].kaNum} 不可:${_memoList[index].fukaNum}\n連打:${_memoList[index].rendaNum} 最大コンボ:${_memoList[index].maxCom}\n良の割合:${((_memoList[index].ryoNum ?? 0) * 100 / noteNum).toStringAsFixed(2)}% 叩けた率:${((noteNum - (_memoList[index].fukaNum ?? 0)) * 100 / noteNum).toStringAsFixed(2)}%\n\n${_memoList[index].text}'),
                          onTap: () {
                            // 編集ダイアログ実装
                            myController.text = _memoList[index].text;
                            ryoController.text =
                                (_memoList[index].ryoNum != null)
                                    ? _memoList[index].ryoNum.toString()
                                    : "";
                            kaController.text = (_memoList[index].kaNum != null)
                                ? _memoList[index].kaNum.toString()
                                : "";
                            fukaController.text =
                                (_memoList[index].fukaNum != null)
                                    ? _memoList[index].fukaNum.toString()
                                    : "";
                            maxComController.text =
                                (_memoList[index].maxCom != null)
                                    ? _memoList[index].maxCom.toString()
                                    : "";
                            rendaNumController.text =
                                (_memoList[index].rendaNum != null)
                                    ? _memoList[index].rendaNum.toString()
                                    : "";
                            showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text("良"),
                                            SizedBox(
                                              width: 80,
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: ryoController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder()),
                                                onSubmitted: (_) =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("可"),
                                            SizedBox(
                                              width: 80,
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: kaController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder()),
                                                onSubmitted: (_) =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("不可"),
                                            SizedBox(
                                              width: 80,
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: fukaController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder()),
                                                onSubmitted: (_) =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("連打数"),
                                            SizedBox(
                                              width: 80,
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: rendaNumController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder()),
                                                onSubmitted: (_) =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("最大コンボ数"),
                                            SizedBox(
                                              width: 80,
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: maxComController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder()),
                                                onSubmitted: (_) =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                            Text(
                                                '${widget.musicName}のメモを入力するドン！'),
                                            TextField(
                                              maxLines: 10,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              decoration: const InputDecoration(
                                                  border: OutlineInputBorder()),
                                              controller: myController,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ButtonBar(
                                          children: <Widget>[
                                            ElevatedButton(
                                              child: Text("保存"),
                                              onPressed: () async {
                                                Memo _memo = Memo(
                                                    id: _memoList[index].id,
                                                    musicId: _memoList[index]
                                                        .musicId,
                                                    ryoNum: int.parse(
                                                        ryoController.text),
                                                    kaNum: int.parse(
                                                        kaController.text),
                                                    fukaNum: int.parse(
                                                        fukaController.text),
                                                    maxCom: int.parse(
                                                        maxComController.text),
                                                    rendaNum: int.parse(
                                                        rendaNumController
                                                            .text),
                                                    text: myController.text);
                                                await Memo.updateMemo(_memo);
                                                final List<Memo> memos =
                                                    await Memo.getMemos(
                                                        _memoList[index]
                                                            .musicId);
                                                setState(() {
                                                  _memoList = memos;
                                                });
                                                analyzeResult();
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
                                                                    .id!);
                                                            final List<Memo>
                                                                memos =
                                                                await Memo.getMemos(
                                                                    _memoList[
                                                                            index]
                                                                        .musicId);
                                                            setState(() {
                                                              _memoList = memos;
                                                            });
                                                            analyzeResult();
                                                            myController
                                                                .clear();
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text("いいえ"),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )).then(
                              (value) {
                                myController.clear();
                                ryoController.clear();
                                kaController.clear();
                                fukaController.clear();
                                maxComController.clear();
                                rendaNumController.clear();
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              final _focusNode = FocusNode();
              return AlertDialog(
                title: Text("記録・メモを登録"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("良"),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: ryoController,
                          maxLines: 1,
                          focusNode: _focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("可"),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: kaController,
                          maxLines: 1,
                          decoration:
                              InputDecoration(border: UnderlineInputBorder()),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("不可"),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: fukaController,
                          maxLines: 1,
                          decoration:
                              InputDecoration(border: UnderlineInputBorder()),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("連打数"),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: rendaNumController,
                          maxLines: 1,
                          decoration:
                              InputDecoration(border: UnderlineInputBorder()),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("最大コンボ数"),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: maxComController,
                          maxLines: 1,
                          decoration:
                              InputDecoration(border: UnderlineInputBorder()),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      Text('${widget.musicName}のメモを入力するドン！'),
                      TextField(
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        controller: myController,
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    child: Text('保存'),
                    onPressed: () async {
                      Memo _memo = Memo(
                        id: null,
                        ryoNum: int.parse(ryoController.text),
                        kaNum: int.parse(kaController.text),
                        fukaNum: int.parse(fukaController.text),
                        maxCom: int.parse(maxComController.text),
                        rendaNum: int.parse(rendaNumController.text),
                        text: myController.text,
                        musicId: widget.id,
                      );
                      await Memo.insertMemo(_memo);
                      final List<Memo> memos = await Memo.getMemos(widget.id);
                      setState(() {
                        _memoList = memos;
                      });
                      analyzeResult();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ).then((value) {
            analyzeResult();
            myController.clear();
            ryoController.clear();
            kaController.clear();
            fukaController.clear();
            maxComController.clear();
            rendaNumController.clear();
          });
        },
      ),
    );
  }
}
