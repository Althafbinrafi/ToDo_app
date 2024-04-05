import 'package:flutter/material.dart';
import 'package:todo/Constants/colors.dart';
import 'package:todo/Models/todo.dart';

class ToDoItem extends StatefulWidget {
  final ToDo todo;
  // ignore: prefer_typing_uninitialized_variables
  final onToDochanged;
  // ignore: prefer_typing_uninitialized_variables
  final onDeleteItem;
  const ToDoItem(
      {super.key,
      required this.todo,
      required this.onDeleteItem,
      required this.onToDochanged});

  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          widget.onToDochanged(widget.todo);
          //log('Clicked');
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          widget.todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: Text(
          widget.todo.todoText!,
          style: TextStyle(
              fontSize: 16,
              color: tdBlack,
              decoration:
                  widget.todo.isDone ? TextDecoration.lineThrough : null),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: tdRed,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
              onPressed: () {
                // log('Clicked');
                widget.onDeleteItem(widget.todo.id);
              },
              color: Colors.white,
              iconSize: 18,
              icon: const Icon(Icons.delete)),
        ),
      ),
    );
  }
}
