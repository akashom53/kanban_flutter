import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task_container.dart';
import 'package:rxdart/rxdart.dart';

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

  Stream<QuerySnapshot> get tasksStream => _tasks.snapshots();

  Stream<QuerySnapshot> get taskColumnsStream => _columns.snapshots();

  Stream<List<TaskContainer>> get allTaskColumnsStream => CombineLatestStream
          .combine2<QuerySnapshot, QuerySnapshot, List<TaskContainer>>(
        taskColumnsStream,
        tasksStream,
        (columnsSnapshot, tasksSnapshot) {
          List<Task> allTasks =
              tasksSnapshot.docs.map((e) => Task.fromMap(e.data())).toList();
          List<TaskContainer> allContainers = columnsSnapshot.docs
              .map((e) => TaskContainer.fromMap(e.data()))
              .map((container) {
            var containerTasks = allTasks
                .where((element) => element.containerId == container.uid)
                .toList();
            containerTasks.sort((t1, t2) => t1.index.compareTo(t2.index));
            container.tasks = containerTasks;
            return container;
          }).toList();
          allContainers.sort((c1, c2) => c1.index.compareTo(c2.index));
          return allContainers;
        },
      );

  Future deleteTaskContainer(String id) async {
    _columns.doc(id).delete();
    print("test");
  }

  Future deleteTask(String uid) async {
    _tasks.where('uid', isEqualTo: uid).get().then((value) => {
          if (value.docs.length == 1) {_tasks.doc(value.docs[0].id).delete()}
        });
  }

  Future createTaskContainer(TaskContainer taskContainer, int index) => _columns
      .add({
        'title': taskContainer.title,
        'uid': taskContainer.uid,
        'index': index,
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
}
