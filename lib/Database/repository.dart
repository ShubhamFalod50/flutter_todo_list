import 'package:sqflite/sqflite.dart';
import 'package:todo_list/Database/database_connection.dart';

class ListInfo
{
  int id;
  String name;
  String color;
  createListMap()
  {
    var mapping = Map<String,dynamic>();
    mapping['id']=id;
    mapping['name']=name;
    mapping['color']=color;
    return mapping;
  }
}

class TaskInfo
{
  int id;
  String name;
  int listid;
  String day;
  createTaskMap()
  {
    var mapping = Map<String,dynamic>();
    mapping['id']=id;
    mapping['name']=name;
    mapping ['listid']=listid;
    mapping['day']=day;
    return mapping;
  }
}

class ColorTaskInfo
{
  int id;
  String name;
  int listid;
  String day;
  String color;
}

class Repository {
  DatabaseConnection _databaseConnection;
  Repository(){
    //initialize database connection
    _databaseConnection= DatabaseConnection();
  }

  //To access database for connecting and executing queries
  static Database _database;
  Future<Database> get database async
  {
    if(_database !=  null) 
       return _database;
    _database = await _databaseConnection.setDatabase();
    return _database;
  }

  insertList(table, listDetails) async {
      var connection = await database;
      return await connection.insert(table, listDetails.createListMap());
  }

  readList(table) async {
      var connection = await database;
      return await connection.query(table);
  }

  readListById(table,int listID) async  {
      var connection = await database;
      return await connection.query(table, where: 'id=?', whereArgs: [listID]);
  }

  updateList(table, listId, newListName) async  {
      var connection = await database;
      return await connection.rawUpdate('UPDATE $table SET name = ? WHERE id = ?',
            ['$newListName',  listId]);
  }

  deleteList(table, listId) async {
     var connection = await database;
     await connection.rawDelete("Delete from Task where listid=$listId");
     return await connection.rawDelete("Delete from $table where id= $listId");
  }

  insertTask(table, newTask) async {
     var connection = await database;
     return await connection.insert(table, newTask.createTaskMap());
  }

  readTask(table, listid) async {
      var connection = await database;
      if(listid == 1) 
      {
          return await connection.rawQuery("SELECT Task.*, Listtype.color FROM Task, Listtype where Task.listid = Listtype.id");    
      }
      if(listid == 2) 
      {
          var day = DateTime.now().toString();
          var date=day.substring(0,10);
          return await connection.rawQuery("SELECT Task.*, Listtype.color FROM Task, Listtype where Task.listid= Listtype.id and substr(Task.day,1,10)='$date'");    
      }
      return await connection.rawQuery("SELECT * FROM $table where listid= '$listid'");
  }

  readTaskById(table, taskid) async {
      var connection = await database;
      return await connection.query(table, where: 'id=?', whereArgs: [taskid]);
  }

  updateTask(taskid, taskName, day) async {
     var connection = await database;
     return await connection.rawUpdate('UPDATE Task SET name = ?, day=? WHERE id = ?',
            ['$taskName',  '$day', taskid]);
  }
  
  deleteTask(table,taskid) async {
     var connection = await database;
     return await connection.rawDelete("Delete from $table where id='$taskid'");
  }

}