import 'package:birthday/auth.dart';
import 'package:date_picker/date_picker_timeline.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CrudBirthday extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final myName = TextEditingController();
  String myDate =
      DateTime.now().day.toString() + '-' + DateTime.now().month.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add / Edit Birthday"),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: TextField(
                      textAlign: TextAlign.center,
                      enabled: false,
                      decoration: const InputDecoration(
                        hintText: 'Whose birthday is it?',
                      ))
              ),
              Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: myName,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  )
              ),
              Divider(),
              Expanded(
                  child: TextField(
                      textAlign: TextAlign.center,
                      enabled: false,
                      decoration: const InputDecoration(
                        hintText: 'Birth Date',
                      ))
              ),
              Expanded(
                child:
                DatePicker(
                  DateTime.utc(DateTime
                      .now()
                      .year),
                  initialSelectedDate: DateTime.now(),
                  selectionColor: Colors.black,
                  selectedTextColor: Colors.white,
                  daysCount: 366,
                  onDateChange: (date) {
                    myDate = date.day.toString() + "-" + date.month.toString();
                  },
                ),
              ),
              Divider(),
              Row(
                children: [
                  Expanded(child:
                  ElevatedButton(
                    onPressed: () {
                      saveBirthday(myName.value.text, myDate, context);
                    },
                    child: Text('Save'),
                  )
                  )
                ],
              ),
            ],
          ),
        ));
  }

  saveBirthday(String name, String date, BuildContext context) {
    if (name == null || name.length < 1 || date == null || date.length < 1)
      return;
    var database = FirebaseDatabase.instance;
    database
        .reference()
        .child("birthdays")
        .child(Auth.instance.userId)
        .push()
        .set(<String, String>{name: date});
    Navigator.pop(context);
  }
}
