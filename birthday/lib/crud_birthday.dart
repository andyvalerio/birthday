import 'package:birthday/auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CrudBirthday extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final myName = TextEditingController();
  final myDate = TextEditingController();

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
              TextField(
                  enabled: false,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                  )),
              TextFormField(
                controller: myName,
                decoration: const InputDecoration(
                  hintText: '',
                ),
              ),
              TextField(
                  enabled: false,
                  decoration: const InputDecoration(
                    hintText: 'Birth Date',
                  )),
              TextFormField(
                controller: myDate,
                decoration: const InputDecoration(
                  hintText: 'dd-mm',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    saveBirthday(myName.value.text, myDate.value.text, context);
                  },
                  child: Text('Save'),
                ),
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
