import 'package:flutter/material.dart';

class MyColorPicker extends StatefulWidget {
    final Function onSelectColor; // This function sends the selected color to outside
    final List<Color> availableColors; // List of pickable colors
    final Color initialColor; // The default picked color
    final bool circleItem; // Determnie shapes of color cells

    MyColorPicker({
        @required this.onSelectColor,
        @required this.availableColors,
        @required this.initialColor,
        this.circleItem = true
    });
    
    @override
    _MyColorPickerState createState() => _MyColorPickerState();
}
class _MyColorPickerState extends State<MyColorPicker> {
    Color _pickedColor;

  @override
  void initState() {
     _pickedColor = widget.initialColor;
     super.initState();
  }

  @override
  Widget build(BuildContext context) {
     return Container(
        height: 32,
        child: GridView.builder(
           scrollDirection: Axis.horizontal,
           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 50,
                mainAxisSpacing: 18
            ),
           itemCount: widget.availableColors.length,
           itemBuilder: (context, index) {
               final itemColor = widget.availableColors[index];
               return InkWell(
                   onTap: () {
                       widget.onSelectColor(itemColor);
                       setState(() {
                            _pickedColor = itemColor;
                        });
                   },
                   child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: itemColor,
                          shape: widget.circleItem == true 
                             ? BoxShape.circle
                             : BoxShape.rectangle,
                       ),
                      child: itemColor == _pickedColor
                         ? Center(
                             child: Icon(Icons.circle,color: Colors.white,size:10)
                           )
                         : Container(),
                     ),
            );},
      ));
  }
}