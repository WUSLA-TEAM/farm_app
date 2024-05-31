import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  final ImagePicker _picker = ImagePicker();

  List<XFile>? _selectedImages;
  int _totalPrice = 0;
  String? _transactionResult;

  void _updateTotalPrice() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = quantity * 100;
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      setState(() {
        _selectedImages = pickedImages;
      });
    } catch (e) {
      print("Error picking images: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images. Please try again.')),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];
    for (var image in _selectedImages!) {
      File file = File(image.path);
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      Reference ref =
          FirebaseStorage.instance.ref().child('images').child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> _initiateTransaction() async {
    try {
      UpiResponse response = await UpiIndia().startTransaction(
        app: UpiApp.googlePay,
        receiverUpiId: '9747522318@jupiteraxis', // Replace with the actual UPI ID
        receiverName: 'MOHAMMED ARSH', // Replace with the actual receiver name
        transactionRefId: '1331717100266674184', // Replace with actual reference id
        transactionNote: 'Payment for service',
        amount: _totalPrice.toDouble(),
      );

      if (response.status == UpiPaymentStatus.SUCCESS) {
        _uploadData(context);
        setState(() {
          _transactionResult = 'Transaction successful';
        });
      } else {
        setState(() {
          _transactionResult = 'Transaction failed or cancelled by user';
        });
      }
    } catch (e) {
      setState(() {
        _transactionResult = 'Transaction failed: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadData(BuildContext context) async {
    if (_selectedImages == null || _selectedImages!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select images before uploading.')),
      );
      return;
    }

    List<String> imageUrls = await _uploadImages();

    try {
      await FirebaseFirestore.instance.collection('data').add({
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'price': _priceController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'totalPrice': _totalPrice.toString(),
        'dateTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'userEmail': widget.userEmail,
        'imageUrls': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data uploaded successfully!')),
      );

      // Clear the text fields and image list after successful upload
      _nameController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _priceController.clear();
      _quantityController.clear();
      setState(() {
        _totalPrice = 0;
        _selectedImages = null;
      });
    } catch (error) {
      print('Failed to upload data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload data. Please try again.')),
      );
    }
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              SizedBox(height: 16.0),
              if (_selectedImages != null && _selectedImages!.isNotEmpty) ...[
                Text(
                  'Selected Images:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedImages!.map((image) {
                    return Image.file(
                      File(image.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.0),
              ],
              ElevatedButton(
                onPressed: _initiateTransaction,
                child: Text('Upload Data and Pay (Total: $_totalPrice)'),
              ),
              if (_transactionResult != null) ...[
                SizedBox(height: 24.0),
                Text(
                  'Transaction Result: $_transactionResult',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
