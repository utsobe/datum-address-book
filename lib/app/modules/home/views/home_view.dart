import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HomeView'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('HomeView is working', style: TextStyle(fontSize: 20)),
            Text(
              'HomeView is working',
              style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}
