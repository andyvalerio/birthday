import 'dart:math';

import 'package:flutter/material.dart';

class BirthdayTile extends ListTile {
  BirthdayTile(String name, String date, int index)
      : super(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/lego/' +
                    Random().nextInt(9).toString() +
                    '.jpg'),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(date)
            ],
          ),
          onTap: () {},
        );
}
