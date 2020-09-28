import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task_container.dart';

class DbManager {
  CollectionReference _columns;
  CollectionReference _tasks;

  static DbManager _instance;

  DbManager._internal() {
    _columns = FirebaseFirestore.instance.collection("taskContainers");
    _tasks = FirebaseFirestore.instance.collection("tasks");
  }

  static DbManager get instance {
    if (_instance == null) _instance = DbManager._internal();
    return _instance;
  }

  Future createTaskContainer(TaskContainer taskContainer) => _columns
      .add({
        'title': taskContainer.title,
        'uid': taskContainer.uid,
      })
      .then((value) => print('TaskContainer added'))
      .catchError((error) => print("Error adding TaskContainer"));


  Future createTask(Task task, int index) => _tasks
      .add({
        'title': task.title,
        'text': task.text,
        'containerId': task.containerId,
        'uid': task.uid,
        'index': index,
      })
      .then((value) => print('Task added'))
      .catchError((error) => print("Error adding Task"));

  Future<List> fetchColumns() async {
    final t = await _columns.get();
    print("Hello");
  }
}
