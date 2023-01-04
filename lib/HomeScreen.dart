import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';
import 'package:resistorcalculator/logic/painter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';




class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class Resistors {
  int id;
  String name;
  Resistors(this.id,this.name);

  static List<Resistors> getResistors() {
    return <Resistors>[
      Resistors(3,'Placeholder'),
      Resistors(4,'4 Bands'),
      Resistors(5,'Placeholder'),
    ];
  }

}

class _HomeScreenState extends State<HomeScreen> {
  var arr = List<Color?>.filled(5, Colors.black, growable: true);



  List<Color> digitColors = [
    Colors.black,
    Colors.brown,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    const Color(0xffEE82EE),
    Colors.grey[700]!,
    Colors.white,
  ];

  Map digits  = {
    Colors.black:'0',
    Colors.brown:'1',
    Colors.red:'2',
    Colors.orange:'3',
    Colors.yellow:'4',
    Colors.green:'5',
    Colors.blue:'6',
    const Color(0xffEE82EE):'7',
    Colors.grey[700]:'8',
    Colors.white:'9',
  };


  List<Color> multiplierColors = [
    Colors.black,
    Colors.brown,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    const Color(0xffEE82EE),
    Colors.grey[700]!,
    Colors.white,
    const Color(0xffFFD700),
    const Color(0xffC0C0C0),
  ];

  Map multipliers  = {
    Colors.black:pow(10,0),
    Colors.brown:pow(10,1),
    Colors.red:pow(10,2),
    Colors.orange:pow(10,3),
    Colors.yellow:pow(10,4),
    Colors.green:pow(10,5),
    Colors.blue:pow(10,6),
    const Color(0xffEE82EE):pow(10,7),
    Colors.grey[700]:pow(10,8),
    Colors.white:pow(10,9),
    const Color(0xffFFD700):pow(10,-1),
    const Color(0xffC0C0C0):pow(10,-2),
  };

  List<Color> toleranceColors = [
    Colors.brown,
    Colors.red,
    Colors.green,
    Colors.blue,
    const Color(0xffEE82EE),
    Colors.grey[700]!,
    const Color(0xffFFD700),
    const Color(0xffC0C0C0),
  ];

  Map tolerances  = {
    Colors.brown:1.0,
    Colors.red:2.0,
    Colors.green:0.5,
    Colors.blue:0.25,
    const Color(0xffEE82EE):0.1,
    Colors.grey[700]:0.05,
    const Color(0xffFFD700):5.0,
    const Color(0xffC0C0C0):10.0,
  };



  List<Resistors> _resistors = Resistors.getResistors();
  late List<DropdownMenuItem<Resistors>> _dropdownMenuItems;
  late Resistors _selectedResistor;

  late ui.Image image;
  bool isImageloaded = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dropdownMenuItems = buildDropdownMenuItems(_resistors);
    _selectedResistor = _dropdownMenuItems[1].value!;
    init();
  }
  // Loads Image Initially

  Future <void> init() async {
    final ByteData data = await rootBundle.load('assets/images/resistorShower.png');
    image = await loadImage( Uint8List.view(data.buffer));
  }

  // Loads image as byte code for CustomPainter to understand
  Future<ui.Image> loadImage(List<int> img) async {

    Uint8List uint8List;
    uint8List = Uint8List.fromList(img);

    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(uint8List, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  // Builds Dropdown list for resistor type
  List<DropdownMenuItem<Resistors>> buildDropdownMenuItems(List resistors) {
    List<DropdownMenuItem<Resistors>> items = [];
    for (Resistors resistor in resistors) {
      items.add(
        DropdownMenuItem(
          value: resistor,
          child: Text(resistor.name),
        ),
      );
    }
    return items;
  }

  // Widget to show dialog for color picker
  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[300],
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            MaterialButton(
              child: const Text('CANCEL'),
              onPressed: (){
                setState(() {
                  Navigator.of(context).pop();
                });
              }
            ),
            MaterialButton(
              child: const Text('APPLY'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Opens color picker and lets user choose color
  void _openColorPicker(int button,List<Color> colors) async {
    _openDialog(
      "Color picker",
      BlockPicker(
        pickerColor: Colors.black,
        availableColors: colors,
        onColorChanged: (color) {
          setState(() {
            arr[button] = color;
          });
        },
      ),
    );
  }



  Map getColorsRes(Color a,Color b,Color c,Color d,Color e)  {
    Map combination = {
      'D1':Paint() ..color =  a ..style = PaintingStyle.fill,
      'D2':Paint() ..color = b ..style = PaintingStyle.fill,
      'Multiplier':Paint() ..color = d ..style = PaintingStyle.fill,
      'Tolerance':Paint() ..color = e ..style = PaintingStyle.fill,
    };
    return combination;
  }

  // Gets Range of colors depending on band
  List<Color> getTolerance(int id) {
    if (id == 4) {
      return toleranceColors.sublist(6);
    }
    else {
      return toleranceColors.sublist(0,6);
    }
  }

  // Function to format resistance values for displaying
  String formatNum(double num) {
    int decade;
    double temp;
    if(num > 0) {
      temp = (log(num) / log(10));
      temp = double.parse((temp).toStringAsFixed(2));
      decade = temp.floor();
    }
    else {
      decade = 0;
    }
    if (decade == 3) {
      return "${(num/1000).toStringAsFixed(2)} kΩ";
    } else if (decade == 4) {
      return "${(num/1000).toStringAsFixed(2)} kΩ";
    } else if(decade == 5) {
      return "${(num/1000).toStringAsFixed(2)} kΩ";
    } else if (decade >= 6 && decade < 9) {
      return "${(num/1000000).toStringAsFixed(2)} MΩ";
    } else if (decade >= 9) {
      return "${(num/1000000000).toStringAsFixed(2)} GΩ";
    } else {
      return "${num.toStringAsFixed(2)} Ω";
    }
  }

  // Combines answer to be displayed on screen
  String getAnswer(int id, List<Color> colors) {
    String digitValue;
    double? tolerance = tolerances[arr[4]];
    if (id < 5) {
      digitValue = "${digits[arr[0]]}${digits[arr[1]]}";
    }
    else {
      digitValue = "${digits[arr[0]]}${digits[arr[1]]}${digits[arr[2]]}";
    }
    if (!colors.contains(arr[4])) {
      arr[4] = Colors.transparent;
      tolerance = null;
    }

    if (id == 3) {
      tolerance = 20.0;
    }
    double resistance = double.parse(digitValue) * multipliers[arr[3]];

    return "${formatNum(resistance)}\nTolerance: ${tolerance == null ? "None" : "$tolerance%"}";
  }

  double sizenum = 15.0;

  Widget body() {
    double factorW = 1;
    double factorH = 1;
    return Center(
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                const Text(
                  "Resistor Calculator Task",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Band Digit 1",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: sizenum,
                                    color: Colors.white,
                                  ),
                                ),
                                FloatingActionButton(
                                  heroTag: 'D1',
                                  onPressed: () {
                                    _openColorPicker(0,digitColors);
                                  },
                                  backgroundColor: arr[0],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Band Digit 2",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: sizenum,
                                    color: Colors.white,
                                  ),
                                ),
                                FloatingActionButton(
                                  heroTag: 'D2',
                                  onPressed: () {
                                    _openColorPicker(1,digitColors);
                                  },
                                  backgroundColor: arr[1],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                "Multiplier Band",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizenum,
                                  color: Colors.white,
                                ),
                              ),
                              FloatingActionButton(
                                heroTag: 'D4',
                                onPressed: () {
                                  _openColorPicker(3,multiplierColors);
                                },
                                backgroundColor: arr[3],
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Tolerance Band',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizenum,
                                  color: Colors.white,
                                ),
                              ),
                              FloatingActionButton(
                                heroTag: 'D5',
                                onPressed: () {
                                  _openColorPicker(4,getTolerance(_selectedResistor.id));
                                },
                                backgroundColor: arr[4],
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),

                Text(
                  getAnswer(_selectedResistor.id,getTolerance(_selectedResistor.id)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),


                (isImageloaded) ?
                FittedBox(
                  child: SizedBox(
                    width: image.width.toDouble()*factorW,
                    height: image.height.toDouble()*factorH,
                    child: CustomPaint(
                      painter: myPainter(
                        image: image,
                        factorW: factorW,
                        factorH: factorH,
                        color: getColorsRes(arr[0]!,arr[1]!,arr[2]!,arr[3]!,arr[4]!),
                        id: _selectedResistor.id-2,
                      ),
                    ),
                  ),
                )
                    :
                const SizedBox(),

              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context)  {
    double factorW = 1;
    double factorH = 1;


    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      body: SafeArea(
        child: OrientationBuilder(
            builder: (context, orientation) {
              if(orientation == Orientation.portrait) {
                return body();
              }
              else {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                      minWidth:  MediaQuery.of(context).size.width,
                    ),
                    child: body(),
                  ),
                );
              }
            }
        ),
      ),
    );
  }
}