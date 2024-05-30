import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadScreen extends StatefulWidget {
  final String userEmail;

  UploadScreen({required this.userEmail});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  int _totalPrice = 0;

  Future<void> _uploadData(BuildContext context) async {
    String name = _nameController.text.trim();
    String category = _categoryController.text.trim();
    String description = _descriptionController.text.trim();
    String location = _locationController.text.trim();
    String price = _priceController.text.trim();
    String quantity = _quantityController.text.trim();
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      await FirebaseFirestore.instance.collection('data').add({
        'name': name,
        'category': category,
        'description': description,
        'location': location,
        'price': price,
        'quantity': quantity,
        'totalPrice': _totalPrice.toString(),
        'dateTime': dateTime,
        'userEmail': widget.userEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data uploaded successfully!')),
      );

      // Clear the text fields after successful upload
      _nameController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _priceController.clear();
      _quantityController.clear();

      setState(() {
        _totalPrice = 0;
      });
    } catch (error) {
      print('Failed to upload data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload data. Please try again.')),
      );
    }
  }

  void _updateTotalPrice() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = quantity * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateTotalPrice(),
              ),
              SizedBox(height: 16.0),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'User Email',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: widget.userEmail),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => _uploadData(context),
                child: Text('Upload Data (Total: $_totalPrice)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
