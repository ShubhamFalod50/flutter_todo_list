import 'package:flutter/material.dart';
import 'package:todo_list/Database/repository.dart';
import 'package:todo_list/task_screen.dart';
import 'package:todo_list/MyColorPicker.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  String newListName, oldName, updateName;
  Color color =Color(0xFF0000C8);
  List<ListInfo> list=[];
  var editController = TextEditingController();
  var _repository = new Repository();
  
  
  Color getColor(String colorValue)  {
      var parse=int.parse(colorValue);
      Color color=Color(parse).withOpacity(1);
      return color;
  }
  
  Container formCancelButton()  {
      return Container(
          height: 36,
          width: 90,
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Color.fromRGBO(47, 49, 55, 1)
           ),
          child: TextButton(
              onPressed: ()=>Navigator.pop(context), 
              child: Text("Cancel", style: TextStyle(fontSize: 18, color: Colors.white))
          ));
  }

  void showSnackBar(String message, Color snackColor) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
           content: Text(message, style: TextStyle(color: Colors.white)),
           backgroundColor: snackColor,
      ));
  }

  void addList(context, listColor) async  {
      String listName = newListName;
      if(listName!=null) {
          ListInfo newList = ListInfo();
          newList.name = listName;
          newList.color = listColor.value.toString();
          await _repository.insertList('Listtype', newList);
          Navigator.pop(context);
          displayLists();
  }}

  void editList(context, listId, listColor) async {
      var result = await _repository.readListById('Listtype', listId); 
      setState(() {
          oldName = editController.text= result[0]['name']?? 'No name';
      });  
      editListsForm(context, listId, listColor);
  }

  void addListForm() {
    showDialog(
      context: context, 
      builder: (param) {
        var contextWidth=  MediaQuery.of(context).size.width;
        return AlertDialog(
            insetPadding: EdgeInsets.all(contextWidth*0.06),
            backgroundColor: Color.fromRGBO(21, 23, 27, 1),
            title: Center(
                child: Text(
                  "New List", 
                  style: TextStyle(color: Colors.white, fontSize: 22)
            )),
            contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 10),
            actionsPadding: EdgeInsets.only(bottom:8),
            content: Container(
                width: contextWidth*0.97,
                height: 140,
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                    Row(children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical:3),
                        child:Icon(Icons.check_box_outline_blank_rounded, color: Colors.white, size: 26),
                        height: 25,
                      ),
                      SizedBox(width:10),
                      Container(
                        width: contextWidth*0.65,
                        child: TextField(
                          onChanged: (value){ newListName=value; },
                          style: TextStyle(fontSize:18, color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Create New List",
                              hintStyle: TextStyle(color: Colors.grey),
                                 enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color:Colors.white,width:2),
                                  ),
                                 focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color:Colors.white,width:2),
                                  ),
                             )
                           ),
                      ),
                    ]),
                  SizedBox(height: 20),
                  Text("Color", style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(height: 18),
                  Container(
                      height:32,
                      child: MyColorPicker(
                          onSelectColor: (value) {
                              setState(() {    color = value;    });
                          },
                          initialColor: Color(0xFF0000C8),
                          availableColors: [
                              Color(0xFF0000C8),
                              Color(0xFF0066FF),
                              Color(0xFF00FFFF),
                              Color(0xFF00FF7F),
                              Color(0xFFfae738),
                              Color(0xFFEEDC82),
                              Color(0xFFED9121),
                              Color(0xFFFF4040),
                              Color(0xFFFF3399),
                          ],
                  ))
            ]),
          ),
          actions:[
              formCancelButton(),
              Container(
                     height: 36,
                     width: 90,
                     decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          color: Colors.deepPurple
                     ),
                    child: TextButton(
                    onPressed: () async{  addList(context,color); }, 
                    child: Text("Create", style: TextStyle(fontSize: 18, color: Colors.white))
                )),
        ]);
    });
  }

  void editListsForm(context, listId, listColor) {
    showDialog(
      context: context, 
      builder: (param) {
        var contextWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          insetPadding: EdgeInsets.all(contextWidth*0.06),
          backgroundColor: Color.fromRGBO(21, 23, 27, 1),
          title: Center(
              child: Text("Edit List", style: TextStyle(color: Colors.white, fontSize: 22))
          ),
          contentPadding: EdgeInsets.fromLTRB(15, 20, 25, 10),
          actionsPadding: EdgeInsets.fromLTRB(0, 15, 0, 6),
          content: Row(children: [
              Container(
                   padding: EdgeInsets.symmetric(vertical:3),
                   child:Icon(Icons.check_box_outline_blank_rounded, color:getColor(listColor), size: 26),
                   height: 25,
              ),
              SizedBox(width:10),
              Container( 
                 width: contextWidth*0.62,
                 child: TextField(
                  controller: editController,
                  style: TextStyle(fontSize:18, color: Colors.white),
                  decoration: InputDecoration(
                     hintText: "Enter List Name",
                     hintStyle: TextStyle(color: Colors.grey),
                     contentPadding: EdgeInsets.symmetric(vertical:0,horizontal: 5),
                     enabledBorder: UnderlineInputBorder(
                           borderSide: BorderSide(color:Colors.white, width:2),
                     ),
                     focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:Colors.white, width:2),
                     ),
                   )
             ),
          )]),
          actions:[
              formCancelButton(),
              Container(
                 height: 36,
                 width: 90,
                 decoration: ShapeDecoration(
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                     color: Color.fromRGBO(23, 58, 115, 1)
                  ),
                  child:TextButton(
                      onPressed:() async { 
                        updateName = editController.text;
                        var result = await _repository.updateList('Listtype',listId,updateName);  

                        if(result>0) {
                            Navigator.pop(context);
                            displayLists();
                            showSnackBar('Item Updated Successfully', Color.fromRGBO(23, 58, 115, 1));
                      }}, 
                      child: Text("Update", style: TextStyle(fontSize: 18, color: Colors.white))
              )),
        ]);
    });
  }

  void deleteListForm(listId, listName) {
    showDialog(
      context: context, 
      builder: (param) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(21, 23, 27, 1),
          titlePadding: EdgeInsets.fromLTRB(20, 18, 20, 10),
          actionsPadding: EdgeInsets.only(bottom: 5),
          title: Text(
              "Are you sure you want to delete this?", 
              style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          actions:[
              formCancelButton(),
              Container(
                  height: 36,
                  width: 90,
                  decoration: ShapeDecoration(
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                       color: Color.fromRGBO(175, 32, 49, 1)
                  ),
                  child: TextButton(
                      onPressed: () async{ 
                      var result = await _repository.deleteList('Listtype', listId);    
                      if(result>0) {
                          Navigator.pop(context);
                          displayLists();
                          showSnackBar('Item Deleted Successfully', Color.fromRGBO(155, 32, 49, 1));
                      }}, 
                      child: Text("Delete", style: TextStyle(fontSize: 18, color: Colors.white)),
              )),
          ]);
      });
  }
   
  void showTasks(listid, listname, listColor)  {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TaskList(listId: listid, listName: listname, pageColor: listColor))
      );
  }
 
  void displayLists() async {
     var returnedList = await _repository.readList('Listtype');
     list.removeRange(0, list.length);
   
     // To access all Lists
     returnedList.forEach((retlist){
       setState(() {
           var getList = ListInfo();
           getList.id = retlist['id'];
           getList.name = retlist['name'];
           getList.color = retlist['color'];
           list.add(getList);
       });
     });
  }
  
  @override
  void initState() {  
     super.initState();
     displayLists();
  }

  @override
  Widget build(BuildContext context) {
    var contextWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(23, 25, 31, 1),
      appBar: AppBar(
          title: Text(widget.title, style: TextStyle(fontSize: 22)),
          backgroundColor: Color.fromRGBO(26, 28, 33, 1),
          centerTitle: true,
      ),
      body: Center(
          child: ListView.builder(
           itemCount: list.length,
           itemBuilder: (context,index)=>Padding(
          padding: EdgeInsets.symmetric(horizontal: contextWidth*.05),
          child:Column(
            children: [
              SizedBox(
                height: 60,
                child:Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: TextButton(
                    onPressed: ()=>showTasks(list[index].id, list[index].name, getColor(list[index].color)),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ 
                        Row(children: [
                           Container(
                             width: 40,
                             height: 38,
                             child: Card(
                                elevation: 10,
                                color: Colors.transparent,
                                shadowColor: getColor(list[index].color),
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(2, 6, 6, 0),
                                    child: Container(
                                       height: 22,
                                       decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(color: getColor(list[index].color), width:3),
                                ))
                              )
                            )),
                           Container(
                              padding: EdgeInsets.fromLTRB(10, 9, 9, 0),
                              height: 38,
                              child: Text(list[index].name,style: TextStyle(fontSize:18,color: Colors.white,fontWeight: FontWeight.bold))
                            )
                        ]),
                       if(list[index].name == "All" || list[index].name =="Today" || list[index].name == "Tasks") 
                            Container( 
                               child: Center(
                                   child: Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Icon(
                                          Icons.expand_more_rounded, 
                                          color: getColor(list[index].color),
                                          size:34
                                    )),
                              )) 
                         else 
                             Container( 
                              width: contextWidth*.1,
                              child: Center(
                                child: PopupMenuButton(
                                  padding: EdgeInsets.fromLTRB(5, 4, 0, 0),
                                  color: Color.fromRGBO(33, 35, 39, 1),
                                  offset: Offset(0,18),
                                  itemBuilder: (BuildContext context){
                                    return [
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, color: Colors.lightBlue, size: 20,),
                                            SizedBox(width: 6),
                                            Text("Edit List", style: TextStyle(fontSize: 16,color: Colors.white))
                                        ]), 
                                        height: 40,
                                        value: 1,
                                      ),
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                            SizedBox(width:6),
                                            Text("Delete List", style: TextStyle(fontSize: 16,color: Colors.white))
                                        ]),
                                        height: 40,
                                        value: 2,
                                      ),
                                  ];},
                                  onSelected: (value) {
                                      if(value == 1)  editList(context, list[index].id, list[index].color);
                                      if(value == 2)  deleteListForm(list[index].id, list[index].name);
                                  },
                                  icon: Icon(Icons.expand_more_rounded, color: getColor(list[index].color),size:34)
                                ),
                              ),
                            )
                      ])
              ))
            )],
          ))
      )),
      bottomNavigationBar: Container(  
          height: 45,
          color:  Color.fromRGBO(19, 21, 25, 1),
          child: InkWell(
              onTap: ()=>addListForm(),
              child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.add),
                        SizedBox(width:5),
                        Text("Create New List", style: TextStyle(fontSize: 18),),
                  ])
          )),
      ),  
  );}
  
}