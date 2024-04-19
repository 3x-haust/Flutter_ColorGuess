import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _randomColor = Colors.blue; // 초기 색상 값
  String colorCode = '';
  bool match = false;
  final TextEditingController _colorController = TextEditingController();

  // 랜덤 색상 생성 함수
  void generateRandomColor() {
    final Random random = Random();
    setState(() {
      _randomColor = Color.fromRGBO(
        random.nextInt(256), 
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
      colorCode = '#${_randomColor.value.toRadixString(16).substring(2, 8).toUpperCase()}';
      _colorController.clear(); // 새 색상을 생성할 때마다 입력 필드 초기화
      match = false;
    });
  }

  bool isHexColor(String str) {
    // 정규표현식을 사용하여 헥스 색상 코드 형식을 확인
    final hexColorRegex = RegExp(r'^#([0-9A-Fa-f]{3}){1,2}$');

    return hexColorRegex.hasMatch(str);
  }


  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // 두 색상 코드의 정확도 계산
  double calculateColorAccuracy(String colorCode1, String colorCode2) {
    Color color1 = hexToColor(colorCode1);
    Color color2 = hexToColor(colorCode2);

    int redDifference = color1.red - color2.red;
    int greenDifference = color1.green - color2.green;
    int blueDifference = color1.blue - color2.blue;

    // 유클리드 거리 계산
    double distance = sqrt(pow(redDifference, 2) + pow(greenDifference, 2) + pow(blueDifference, 2));

    // 최대 거리 (검정색과 흰색 사이)
    final maxDistance = sqrt(pow(255, 2) * 3);

    // 정확도 계산
    double accuracy = ((maxDistance - distance) / maxDistance) * 100;
  
    return accuracy;
  }

  void calculateMatchColor(String userInput) {
    if (userInput.startsWith('#') && userInput.length == 7) {
      Color userColor = Color(int.parse(userInput.substring(1, 7), radix: 16) + 0xFF000000);
      setState(() {
        match = (userColor == _randomColor);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    generateRandomColor();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('랜덤 색상 맞추기'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 랜덤 색상을 보여주는 SizedBox
              SizedBox(
                height: 250,
                width: 250,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: _randomColor),
                ),
              ),
              SizedBox(height: 50),
              // Text(
              //   '랜덤 색상: $colorCode',
              //   style: TextStyle(fontSize: 24),
              // ),
              // SizedBox(height: 20), // 간격
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '색상 코드 입력 (예: #FF5733)',
                  ),
                ),
              ),
              SizedBox(height: 20), // 간격
              ElevatedButton(
                onPressed: () {
                  String userInput = _colorController.text.toUpperCase();

                  if(isHexColor(userInput)) {

                    calculateMatchColor(userInput);
                    _showColorMatchDialog(context, colorCode, userInput); // 여기서 context는 ElevatedButton이 위치한 현재 위치의 BuildContext입니다.
                    generateRandomColor();
                  }
                },
                child: Text('제출'),
              ),
            ],
          ),
        ),
      ),
    );
  }


    void _showColorMatchDialog(BuildContext context, String color, String user) {
      double accuracy = calculateColorAccuracy(color, user);

      showDialog(
        context: context, // 이제 올바른 BuildContext를 사용합니다.
        barrierDismissible: false,
         builder: ((context) {
                return AlertDialog(
                  title: Text(match ? "성공" : "실패", style: match ? TextStyle(color: Colors.green) :
                                                    TextStyle(color: Colors.red),textAlign: TextAlign.center),
                  content:  Text("정답: $color \n정확도: ${accuracy.toStringAsFixed(0)}%", textAlign: TextAlign.center),
                  actions: <Widget>[
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); //창 닫기
                        },
                        child: Text("확인"),
                      ),
                    ),
                  ],
                );
              }));
  }
}
