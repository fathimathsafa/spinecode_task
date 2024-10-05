import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:task_spine/presentation/expense_list_screen.dart/view/expense_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExpenseListScreen()));
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            "Expense Tracker",
            style: TextStyle(
                color: Colors.red,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}
