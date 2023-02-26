import 'package:flutter/material.dart';
import 'db/music.dart';

class HomePageEditDialog extends StatefulWidget {
  final Music music;
  final Function(Music) updateMusic;
  final Function(int) deleteMusic;
  const HomePageEditDialog(
      {super.key,
      required this.music,
      required this.updateMusic,
      required this.deleteMusic});
  @override
  State<HomePageEditDialog> createState() => _HomePageEditDialogState();
}

class _HomePageEditDialogState extends State<HomePageEditDialog> {
  bool _flag = false;
  late TextEditingController myController;
  String? _kind = "おに";

  @override
  void initState() {
    myController = TextEditingController(text: widget.music.name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("楽曲情報編集"),
        // StatefulBuilderを使わないとドロップダウンが即時反映されない
        content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
          Checkbox(
              value: _flag,
              onChanged: (value) {
                setState(() {
                  _flag = !_flag;
                });
              }),
          const Text("完了"),
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
                  Music newMusic = Music(
                      name: myController.text,
                      id: widget.music.id,
                      isFinished: _flag);
                  widget.updateMusic(newMusic);
                  Navigator.pop(context);
                },
              );
            }),
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
                          title: const Text("本当に削除しますか？"),
                          actions: [
                            TextButton(
                              child: const Text("はい"),
                              onPressed: () {
                                widget.deleteMusic(widget.music.id!);
                              },
                            ),
                            TextButton(
                                child: const Text("いいえ"),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        );
                      });
                }),
          ])
        ]));
  }
}
