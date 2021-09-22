import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_list/Database/repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TaskList extends StatefulWidget {
  const TaskList({ 
      Key key, 
      @required this.listId, 
      @required this.listName,
      @required this.pageColor
   }) : super(key: key);
  
  final int listId;
  final String listName;
  final Color pageColor;
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  String taskName, setDate= "Set Date", setTime ="Set Time";
  bool hideFloatingButton, showHelpingText=false;
  List<dynamic> listofTask=[];
  DateTime scheduleDate = DateTime.now();
  TimeOfDay scheduleTime = TimeOfDay.now();
  Repository _repository = Repository();
  var editController = TextEditingController();
  FlutterLocalNotificationsPlugin localNotifications;

  Future<void> initializetimezone() async{
      tz.initializeTimeZones();
  }

  String dayConversion(String day)  {
      DateTime date = DateTime.parse(day);
      String retDate, retTime, returnDate;

      if(DateFormat.E().format(date) == DateFormat.E().format(DateTime.now())){
          retTime =DateFormat.Hm().format(date).toString();  
          returnDate = "Today"+", "+retTime;
          return returnDate;
      }

      retDate = DateFormat.MMMd().format(date).toString();
      retTime =DateFormat.Hm().format(date).toString();
      returnDate= retDate+", "+retTime;
      return returnDate;
  }

  Color setColor(index)  {
      if(widget.listName == "All" || widget.listName == "Today") 
      {
          var convert=int.parse(listofTask[index].color);
          Color listColor=Color(convert).withOpacity(1);
          return listColor;
      }
      else
          return widget.pageColor;
  }
 
  Future<void> selectDate(BuildContext context) async {
        final DateTime pickedDate = await showDatePicker(
              context: context, 
              initialDate: scheduleDate, 
              firstDate: DateTime(2020), 
              lastDate: DateTime(2100),
        );
        if(pickedDate != null && pickedDate != scheduleDate) {
              setState(() {  scheduleDate = pickedDate;    });
        }
        setDate =DateFormat.yMMMd().format(scheduleDate).toString();
  }

  Future<void> selectTime(BuildContext context) async {
       final TimeOfDay pickedTime = await showTimePicker(
              context: context, 
              initialTime: scheduleTime
        );
        if(pickedTime != null && pickedTime != scheduleTime) {
              setState(() {   scheduleTime = pickedTime;  });
        }
        var now =DateTime.now();
        var dt = DateTime(now.year, now.month, now.day, scheduleTime.hour, scheduleTime.minute);
        setTime =DateFormat.jm().format(dt).toString();
   }
  
  void getTaskDetails(taskid) async {
      var result = await _repository.readTaskById('Task', taskid); 
      var day;
      setState(() {
          taskName= editController.text = result[0]['name']?? 'No name';
          String oldday =  result[0]['day'];

          day = DateTime.parse(oldday);
          setDate =DateFormat.yMMMd().format(day).toString();
          setTime =DateFormat.jm().format(day).toString();
      });  
      showModalBottomSheet(
          context: context, 
          builder: (ctx) => editBottomSheet(ctx,taskid,day),
      );
  }
  
  void addTask(context) async {
    if(taskName!=null ) 
    {   
        String day = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day, scheduleTime.hour, scheduleTime.minute).toString();
        TaskInfo newTask = TaskInfo();
              newTask.name = taskName;
              newTask.listid = widget.listId;
              newTask.day = day;
        var result =await _repository.insertTask("Task", newTask);    
        if(result > 0) 
        {
            Navigator.pop(context);
            displayTask();
            showNotification(newTask.name, newTask.day);
            scheduleDate = DateTime.now();
            scheduleTime = TimeOfDay.now();
            setDate= "Set Date";
            setTime ="Set Time";
        }
  }}

  void editTask(context, taskid) async {
    if(taskName!=null ) 
    {   
        String day = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day, scheduleTime.hour, scheduleTime.minute).toString();
        var result =await _repository.updateTask(taskid, taskName, day);    
        if(result > 0) 
        {
            Navigator.pop(context);
            displayTask();
            showNotification(taskName, day);
            scheduleDate = DateTime.now();
            scheduleTime = TimeOfDay.now();
            setDate = "Set Date";
            setTime = "Set Time";
        }
  }}

  void removeTask(taskid) async{
      var result = await _repository.deleteTask("Task", taskid);
      if(result > 0)
          displayTask();
  }

  void displayTask() async {
     var returnedList = await _repository.readTask('Task', widget.listId);
     listofTask.removeRange(0, listofTask.length);
    
     if(returnedList.length > 0)  {
         returnedList.forEach((retlist)  {
            setState(() {
              showHelpingText=false;
              var getTasks;
              if(widget.listName == "All" || widget.listName == "Today") {  
                  getTasks = ColorTaskInfo();
                  getTasks.color = retlist['color'];
               }
               else {
                 getTasks = TaskInfo();
                }
               getTasks.id = retlist['id'];
               getTasks.name = retlist['name'];
               getTasks.listid = retlist['listid'];
               getTasks.day = retlist['day'];
               listofTask.add(getTasks);
            });
         });
     }
     else
      setState ((){
        showHelpingText=true;
      });
  }
 
  @override
  void initState() {
    super.initState();
     if(widget.listName == "All" || widget.listName == "Today") 
          hideFloatingButton = true;
     else
          hideFloatingButton = false;
    displayTask();
    
    var androidIntialize = new AndroidInitializationSettings('ic_launcher');
    var iosInitialize = new IOSInitializationSettings();
    var initializationSettings= new InitializationSettings(
        android: androidIntialize, iOS: iosInitialize
    );
    localNotifications= new FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings);
  }

  void showNotification(taskName, taskDay) async {
    var currentDateTime= DateTime.now();
    var scheduleDateTime=DateTime.parse(taskDay);

    if(scheduleDateTime.compareTo(currentDateTime)>0)
    {
        await initializetimezone();
        var androidDetails = new AndroidNotificationDetails(
            "channelId", 
            "Local Notification",
            "Decription of Notification",
            importance: Importance.high,
        );
        var iosDetails= new IOSNotificationDetails();
        var generalNotificationDetails= 
             new NotificationDetails(android: androidDetails, iOS: iosDetails);
        
        tz.TZDateTime zonedTime = tz.TZDateTime.from(scheduleDateTime,tz.local);
        await localNotifications.zonedSchedule(
            0,
            "Reminder", 
            "$taskName", 
            zonedTime, 
            generalNotificationDetails,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'Payload',
            androidAllowWhileIdle: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.listName, style: TextStyle(fontSize: 22),),
          backgroundColor: Color.fromRGBO(26, 28, 33, 1),
          centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(23, 25, 31, 1),
      body: showHelpingText
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment, color: Colors.white30, size: 120,),
              SizedBox(height: 20,),
              Text(
                "Seems like task list is empty",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "Tap '+' button on bottom to add new task",
                style: TextStyle(color: Colors.grey),
              ),
          ])
        )
      : ListView.builder(
        itemCount: listofTask.length,
        itemBuilder: (context, index) {
            return Card(
                color: Color.fromRGBO(45, 47, 53, 1),
                child: Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.35,
                    child: ListTile(
                        onTap: () => {},
                        leading: Padding(
                             padding: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                             child: Icon(Icons.trip_origin, color: setColor(index)),
                        ),
                        title: Text(
                            listofTask[index].name, 
                            style: TextStyle(fontSize: 18)
                        ),
                        subtitle: Text(
                            dayConversion(listofTask[index].day), 
                            style: TextStyle(color: Colors.grey)
                        )
                    ),
                    actions: [
                      IconSlideAction(
                            color: Color.fromRGBO(23, 25, 31, 1),
                            iconWidget: Icon(Icons.edit_outlined, size: 36, color: Colors.lightBlue),
                            onTap: () => getTaskDetails(listofTask[index].id),
                    )],
                    secondaryActions:[
                        IconSlideAction(
                            color: Color.fromRGBO(23, 25, 31, 1),
                            iconWidget: Icon(Icons.delete_sweep_outlined, size: 40, color: Colors.red),
                            onTap: () => removeTask(listofTask[index].id),
                    )]
             ));
      }),

      floatingActionButton: hideFloatingButton ?
          null :
          FloatingActionButton(
              onPressed: () => showModalBottomSheet(
                  context: context, 
                  builder: (ctx) => addBottomSheet(ctx)
              ),
              backgroundColor: widget.pageColor,
              tooltip: "Add new task",
              child: Icon(Icons.add, size: 30,)
          ),
    );
  }

  Container addBottomSheet(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: 120,
      color: Color.fromRGBO(27, 29, 35, 1),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: width*.04),
      child: ListView(
        children: [
          Row(children: [
              Container(
                  height: 18,
                  width: width*0.06,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.pageColor, width: 4),
              )),
              SizedBox(width: width*0.03),
              Container(
                  width: width*0.69,
                  child:TextField(
                      maxLines: null,
                      onChanged: (value){taskName=value;},
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Task Name",
                          hintStyle: TextStyle(color: Colors.grey),
                      )
              )),
              Container(
                  width: width*0.14,
                  child: IconButton(
                      icon: Icon(Icons.send,color: widget.pageColor), 
                      onPressed: ()=>addTask(context)
              ))
          ]),
          SizedBox(height: 10),
          Row(
            children: [
              bottomSheetButton(setDate, ()=>selectDate(context)),
              SizedBox(width:20),
              bottomSheetButton(setTime, ()=>selectTime(context)),
          ])  
      ]),
    );
  }

  Container editBottomSheet(BuildContext context, int taskid, DateTime day)  {
    var width = MediaQuery.of(context).size.width;
    scheduleDate= day;
    scheduleTime= TimeOfDay.fromDateTime(day);
    return Container(
      height: 120,
      color: Color.fromRGBO(27, 29, 35, 1),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: width*.04),
      child: ListView(
        children: [
          Row(children:[
             Container(
                  height: 18,
                  width: width*0.06,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.pageColor, width: 4),
              )),
              SizedBox(width: width*0.03),
              Container(
                  width: width*0.69,
                  child:TextField(
                      controller: editController,
                      maxLines: null,
                      onChanged: (value){taskName=value;},
                      style: TextStyle(fontSize: 18,),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Task Name",
                          hintStyle: TextStyle(color: Colors.grey),
                      )
              )),
              Container(
                  width: width*0.14,
                  child: IconButton(
                      icon: Icon(Icons.send,color: widget.pageColor), 
                      onPressed: () => editTask(context,taskid)
              ))
          ]),
          SizedBox(height: 10),
          Row(
            children: [
              bottomSheetButton(setDate, ()=>selectDate(context)),
              SizedBox(width:20),
              bottomSheetButton(setTime, ()=>selectTime(context)),
          ])  
      ]),
    );
  }

  Container bottomSheetButton(String data, Function onPressed) {
    return Container(
       height: 38,
       width: 140,
       decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Color.fromRGBO(47, 49, 55, 1)
        ),
       child:TextButton.icon(
            onPressed: ()=> onPressed(),
            icon: Icon(Icons.event_outlined, color: widget.pageColor, size: 20), 
            label: Text(data, style: TextStyle(color: Colors.white)),
      ));
  }

}