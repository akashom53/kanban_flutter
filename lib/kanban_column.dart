import 'package:drag_drop_test/models/task_container.dart';
import 'package:drag_drop_test/reorder_list.dart';
import 'package:flutter/material.dart';

import 'models/task.dart';

class KanbanColumn extends StatefulWidget {
  final TaskContainer list1;
  final Function onScrollLeft;
  final Function onScrollRight;
  final ItemInsertedCallback onItemInserted;
  final ItemRemovedCallback onItemRemoved;

  const KanbanColumn({
    Key key,
    @required this.list1,
    @required this.onScrollLeft,
    @required this.onScrollRight,
    @required this.onItemInserted,
    @required this.onItemRemoved,
  }) : super(key: key);

  @override
  _KanbanColumnState createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {

  Future<Task> showAddTaskDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    return showDialog<Task>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Create Task"),
            content: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      hintText: "Title"
                  ),
                ),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                      hintText: "Details"
                  ),
                ),
              ],
            ),
            actions: [
              FlatButton(onPressed: () {
                final taskId = DateTime
                    .now()
                    .millisecond
                    .toString() + titleController.text;
                final task = Task(title: titleController.text,
                    text: textController.text,
                    uid: taskId,
                    containerId: widget.list1.uid);
                Navigator.of(context).pop(task);
              }, child: Text("Add")),
              FlatButton(onPressed: () {
                Navigator.of(context).pop();
              }, child: Text("Cancel"))
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        color: Colors.blueGrey,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.list1.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          final task = await showAddTaskDialog(context);
                          widget.onItemInserted(task, widget.list1.tasks.length);
                        },
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                DragDropList(
                  widget.list1.tasks,
                  onScrollLeft: widget.onScrollLeft,
                  onItemInserted: widget.onItemInserted,
                  onItemRemoved: widget.onItemRemoved,
                  onReorder: (item, index) {
                    widget.onItemRemoved(item);
                    widget.onItemInserted(item, index);
                    // setState(() {
                    //   widget.list1.tasks.remove(item);
                    //   widget.list1.tasks.insert(index, item);
                    // });
                  },
                  onScrollRight: widget.onScrollRight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
