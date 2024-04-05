import 'package:flutter/material.dart';
import 'package:todo/Constants/colors.dart';
import 'package:todo/Models/todo.dart';
// import 'package:todo/Widgets/todo_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/Widgets/todo_items.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    _loadToDoItems();
    super.initState();
  }

  void _loadToDoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todoIds = prefs.getStringList('todos') ?? [];

    final List<ToDo> loadedTodos = todoIds.map((id) {
      final todoText = prefs.getString('todo_$id') ?? '';
      final isDone = prefs.getBool('todo_isDone_$id') ?? false;
      return ToDo(
        id: id,
        todoText: todoText,
        isDone: isDone,
      );
    }).toList();

    setState(() {
      todosList.addAll(loadedTodos);
      _foundToDo = todosList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGcolor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  SearchBox(),
                  Expanded(
                      child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50, bottom: 20),
                        child: const Text(
                          'All ToDos',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                      ),
                      for (ToDo todo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todo,
                          onToDochanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ))
                ],
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          )
                        ],
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                          hintText: 'Add a new todo item',
                          border: InputBorder.none),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _addToDoItems(_todoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdBlue,
                      minimumSize: const Size(60, 60),
                      elevation: 10,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      todo.isDone = !todo.isDone;
      prefs.setBool(
          'todo_isDone_${todo.id}', todo.isDone); // Save the isDone state
    });
  }

  void _deleteToDoItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? todoList = prefs.getStringList('todos') ?? [];

    setState(() {
      todosList.removeWhere((item) => item.id == id);
      _foundToDo = todosList;
      todoList?.remove(id);
      prefs.setStringList('todos', todoList ?? []);
      prefs.remove('todo_$id'); // Remove the todo text associated with the id
    });
  }

  void _addToDoItems(String toDo) async {
    if (toDo.trim().isEmpty) {
      // Show a Snackbar if the entered text is blank
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          dismissDirection: DismissDirection.horizontal,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: MediaQuery.of(context).size.width / 4,
            right: MediaQuery.of(context).size.width / 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 17, 0),
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              Text(
                "  Please Enter an item",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          )));
      return; // Exit the method if the text is blank
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String>? todoList = prefs.getStringList('todos') ?? [];

    final todoId = DateTime.now().microsecondsSinceEpoch.toString();
    todoList!.add(todoId);
    prefs.setStringList('todos', todoList);
    prefs.setString('todo_$todoId', toDo);

    setState(() {
      todosList.add(ToDo(
        id: todoId,
        todoText: toDo,
      ));
    });

    _todoController.clear();
  }

  void _runFilter(String enterKeyword) {
    List<ToDo> results = [];
    if (enterKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) =>
              item.todoText!.toLowerCase().contains(enterKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  // ignore: non_constant_identifier_names
  Widget SearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: tdBlack,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
            border: InputBorder.none,
            hintText: 'Search...',
            hintStyle: TextStyle(color: tdGrey)),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        backgroundColor: tdBGcolor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.list,
              color: tdBlack,
              size: 30,
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image.asset('assets/images/althu.jpeg'),
              ),
            )
          ],
        ));
  }
}
