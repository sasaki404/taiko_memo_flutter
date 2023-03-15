import 'package:flutter/material.dart';
import 'db/music.dart';

class HomePageEditDialog extends StatefulWidget {
  final Music music;
  final Function(Music) updateMusic;
  final Function(int) deleteMusic;
  final Function(Music) insertMusic;
  const HomePageEditDialog(
      {super.key,
      required this.music,
      required this.updateMusic,
      required this.deleteMusic,
      required this.insertMusic});
  @override
  State<HomePageEditDialog> createState() => _HomePageEditDialogState();
}

class _HomePageEditDialogState extends State<HomePageEditDialog> {
  bool _flag = false;
  late TextEditingController myController;
  String? _kind = "おに";
  String? _count = "10";
  final List<DropdownMenuItem<String>> countDropdownItems = [];
  late TextEditingController _difficultyController;

  @override
  void initState() {
    super.initState();
    myController = TextEditingController(text: widget.music.name);
    _flag = widget.music.isFinished;
    _kind = widget.music.kind;
    _difficultyController =
        TextEditingController(text: widget.music.difficulty);
    _count =
        (widget.music.count != null) ? widget.music.count.toString() : "10";
    for (int i = 10; i > 0; i--) {
      countDropdownItems.add(
        DropdownMenuItem(
          child: Text("$i"),
          value: "$i",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: (widget.music.id != null)
          ? const Text("楽曲情報編集")
          : const Text("新規楽曲追加"),
      // StatefulBuilderを使わないとドロップダウンが即時反映されない
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          const Text('楽曲名'),
          TextField(controller: myController),
          const Text('難易度'),
          DropdownButton(
            items: const [
              DropdownMenuItem(value: "おに", child: Text("おに")),
              DropdownMenuItem(value: "おに裏", child: Text("おに裏")),
              DropdownMenuItem(value: "むずかしい", child: Text("むずかしい")),
              DropdownMenuItem(value: "ふつう", child: Text("ふつう")),
              DropdownMenuItem(value: "かんたん", child: Text("かんたん")),
            ],
            value: _kind,
            onChanged: (String? value) {
              setState(() {
                _kind = value;
              });
            },
          ),
          const Text("★の数"),
          DropdownButton(
              items: countDropdownItems,
              value: _count,
              onChanged: (String? value) {
                setState(() {
                  _count = value;
                });
              }),
          Checkbox(
              value: _flag,
              onChanged: (value) {
                setState(() {
                  _flag = !_flag;
                });
              }),
          const Text("完了"),
        ]),
      ),
      actions: [
        ButtonBar(children: <Widget>[
          Builder(builder: (context) {
            return ElevatedButton.icon(
              label: const Text(
                '保存',
                style: TextStyle(fontSize: 11),
              ),
              icon: const Icon(
                Icons.save,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                if (widget.music.id != null) {
                  Music newMusic = Music(
                      name: myController.text,
                      id: widget.music.id,
                      kind: _kind,
                      count: int.parse(_count ?? ''),
                      isFinished: _flag);
                  widget.updateMusic(newMusic);
                } else {
                  Music newMusic = Music(
                      name: myController.text,
                      id: null,
                      kind: _kind,
                      count: int.parse(_count ?? ''),
                      isFinished: _flag);
                  widget.insertMusic(newMusic);
                }
                Navigator.pop(context);
              },
            );
          }),
          (widget.music.id != null)
              ? ElevatedButton.icon(
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
                            title: const Text("本当に削除しますか？"),
                            actions: [
                              TextButton(
                                child: const Text("はい"),
                                onPressed: () {
                                  widget.deleteMusic(widget.music.id!);
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                  child: const Text("いいえ"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  })
                            ],
                          );
                        }).then((value) => Navigator.pop(context));
                  })
              : const SizedBox(
                  width: 60,
                ),
        ])
      ],
    );
  }
}
