import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/address_book_controller.dart';

class AddressBookView extends GetView<AddressBookController> {
  const AddressBookView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AddressBookView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AddressBookView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
