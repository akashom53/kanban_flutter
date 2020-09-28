import 'package:drag_drop_test/models/task.dart';
import 'package:flutter/material.dart';

class DragDropList extends StatefulWidget {
  final List<Task> items;
  final ItemInsertedCallback onItemInserted;
  final ItemRemovedCallback onItemRemoved;
  final ItemInsertedCallback onReorder;
  final Function onScrollRight;
  final Function onScrollLeft;

  const DragDropList(
    this.items, {
    Key key,
    this.onItemInserted,
    this.onItemRemoved,
    this.onReorder,
    this.onScrollRight,
    this.onScrollLeft,
  }) : super(key: key);

  @override
  _DragDropListState createState() => _DragDropListState();
}

typedef ItemInsertedCallback = void Function(Task item, int index);
typedef ItemRemovedCallback = void Function(Task item);

class _DragDropListState extends State<DragDropList> {
  List<Task> items = [];
  final ScrollController scrollController = ScrollController();
  final _listKey = GlobalKey();
  double _topOffset = 0;

  @override
  void initState() {
    items.addAll(widget.items);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DragDropList oldWidget) {
    setState(() {
      items.clear();
      items.addAll(widget.items);
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      _topOffset = (_listKey.currentContext.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;
    });
    return DragTarget<Task>(
      builder: (context, incoming, rejected) {
        return Container(
          key: _listKey,
          constraints: BoxConstraints(
            minHeight: 100,
          ),
          child: ListView(
            shrinkWrap: true,
            semanticChildCount: items.length,
            controller: scrollController,
            children: items.map(
              (item) {
                final child = Card(
                  color: item.ghost ? Colors.transparent : Colors.white,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: item.ghost ? Colors.transparent : Colors.white,
                    ),
                    child: SizedBox(
                      width: 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${item.title}",
                                style: TextStyle(
                                    inherit: false, color: Colors.black),
                              ),
                              Text(
                                "${item.text}",
                                style: TextStyle(
                                  inherit: false,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                return Draggable(
                  data: item,
                  key: ValueKey(item.uid),
                  feedback: Opacity(
                    opacity: 0.7,
                    child: child,
                  ),
                  child: child,
                  childWhenDragging: Container(),
                );
              },
            ).toList(),
          ),
        );
      },
      onWillAccept: (data) => true,
      onAccept: (data) {},
      onAcceptWithDetails: (targetWithDetails) {
        // final srcIndex = items.indexOf(targetWithDetails.data);
        int destIndex = ((targetWithDetails.offset.dy - _topOffset) ~/ 58);
        if (destIndex > items.length) return;
        setState(() {
          items = items.where((element) => !element.ghost).toList();
        });
        if (widget.items.contains(targetWithDetails.data)) {
          widget.onReorder(targetWithDetails.data, destIndex);
        } else {
          if (destIndex > items.length) destIndex = items.length;
          widget.onItemInserted(targetWithDetails.data, destIndex);
        }
        // widget.onItemRemoved(targetWithDetails.data);
        // widget.onItemInserted(targetWithDetails.data, destIndex);
      },
      onLeave: (data) {
        setState(() {
          items = items.where((element) => !element.ghost).toList();
        });
        widget.onItemRemoved(data);
      },
      onMove: (targetWithDetails) {
        if (targetWithDetails.offset.dx + 120 >
            MediaQuery.of(context).size.width) {
          widget.onScrollRight();
        } else if (targetWithDetails.offset.dx < -10) {
          widget.onScrollLeft();
        }
        final srcIndex = items.indexOf(targetWithDetails.data as Task);
        final destIndex = ((targetWithDetails.offset.dy - _topOffset) ~/ 58);
        if (destIndex > items.length) return;
        if (srcIndex != destIndex && (destIndex == items.length || !items[destIndex].ghost)) {
          setState(() {
            final ghost = Task.ghost();
            items = items.where((element) => !element.ghost).toList();
            if (destIndex > items.length) {
              items.insert(items.length, ghost);
            } else
            items.insert(destIndex, ghost);
          });
        }
      },
    );
  }
}
