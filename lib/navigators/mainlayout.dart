// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget body;

  const MainLayout({Key? key, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: body),
        Padding(
          padding: EdgeInsets.only(bottom: 8.0), // Add padding to the bottom
          // Bottom Navigation Bar stays fixed at the bottom
        ),
      ],
    );
  }
}
