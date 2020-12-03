import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../classes/tags.dart';

class DatabaseHelper {
  static final _databaseName = "presentation2.db";
  static final _databaseVersion = 1;

  static final table = 'tags';

  static final columnId = 'id';
  static final columnTitle = 'title';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();

    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''  
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT UNIQUE NOT NULL
          )
          ''');
  }

  Future<int> insert(Tags tags) async {
    Database db = await instance.database;
    var res = await db.insert(table, tags.toMap());
    return res;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(table, orderBy: "$columnId DESC");
    return res;
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> clearTable() async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table");
  }
}

class AddTags extends StatefulWidget {
  AddTags({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddTags createState() => _AddTags();
}

class _AddTags extends State<AddTags> {
  TextEditingController textController = new TextEditingController();

  List<String> tagList = new List();

  @override
  void initState() {
    super.initState();

    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          //tagList.add(Tags(id: element['id'], title: element["title"]));
        });
      });
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tags'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "Enter a Tag"),
                    controller: textController,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addToDb,
                )
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                child: tagList.isEmpty
                    ? Container()
                    : ListView.builder(itemBuilder: (ctx, index) {
                        if (index == tagList.length) return null;
                        return ListTile(
                          title: Text(tagList[index]),
                          leading: Text(index.toString()),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deletetag(index),
                          ),
                        );
                      }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _deletetag(int index) async{
    tagList.removeAt(index);
  }

  void _addToDb() async{
    String tag = textController.text;
    tagList.add(tag);
  }
}
