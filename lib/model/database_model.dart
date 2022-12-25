
import 'package:intl/intl.dart';

class DatabaseModel {
  late int id;
  late String description;
  late String title;
   late String date;
   // date for comparison as after or before
   late String formattedDate;
   // formattedDate for display to user
  late String status;
 late dynamic codeTheImage;
late String time;
//Color(R,G,B,O)
  late  int degreeOfBlue;
    late  int degreeOfRed;
      late  int degreeOfGreen;
      late double degreeOfOpacity;
  DatabaseModel.fromMap({required Map map}) {
    id = map['id'];
    degreeOfBlue = map['degreeOfBlue'];
    degreeOfRed = map['degreeOfRed'];
    degreeOfGreen = map['degreeOfGreen'];
    degreeOfOpacity = map['degreeOfOpacity'];
    description = map['description'];
    title = map['title'];
     date = map['date'];
    status = map['status'];
    codeTheImage = map['codeTheImage'];

    time=map['time'];
    formattedDate=DateFormat.yMMMMd().format(DateTime.parse(date));
  }

 }
