// ignore_for_file: prefer_const_constructors, unused_import
import 'package:eventory/modles/user_model.dart';
import 'package:eventory/screnns/authentication/authenticate.dart';
import 'package:eventory/screnns/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
