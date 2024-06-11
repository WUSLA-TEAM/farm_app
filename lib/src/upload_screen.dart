import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:farm_app/src/AuthService.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _age = TextEditingController();

  File? _image;
  final picker = ImagePicker();
  String? _selectedCategory;
  bool _showAddCategoryButton = false;

  @override
  void initState() {
    super.initState();
    _checkCategories();
  }

  Future<void> _checkCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _showAddCategoryButton = snapshot.docs.isEmpty;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _addCategory() async {
    TextEditingController categoryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String categoryName = categoryController.text.trim();
              if (categoryName.isNotEmpty) {
                await FirebaseFirestore.instance.collection('categories').add({'name': categoryName});
                _checkCategories();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProduct() async {
    if (_selectedCategory == null || _image == null) {
      _showErrorMessage('Please select an image and category.');
      return;
    }

    String name = _nameController.text.trim();
    String price = _priceController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? userEmail = authProvider.getUserEmail();
    String phoneNumber = _phoneNumberController.text.trim();
    int? numPhone = int.parse(phoneNumber);
    String description = _descriptionController.text.trim();
    String weight = _weightController.text.trim();
    String height = _heightController.text.trim();
    String age = _age.text.trim();
    int? numage = int.parse(age);

    if (name.isEmpty) {
      _showErrorMessage('Please enter a name.');
      return;
    }
    if (price.isEmpty) {
      _showErrorMessage('Please enter a price.');
      return;
    }
    if (phoneNumber.isEmpty) {
      _showErrorMessage('Please enter a phone number.');
      return;
    }
    if (description.isEmpty) {
      _showErrorMessage('Please enter a description.');
      return;
    }
    if (weight.isEmpty) {
      _showErrorMessage('Please enter a weight.');
      return;
    }
    if (height.isEmpty) {
      _showErrorMessage('Please enter a height.');
      return;
    }

    if (age.isEmpty) {
      _showErrorMessage('Please entre a age');
    }

    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('products').doc();
      String productId = docRef.id;

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('products/$fileName');
      UploadTask uploadTask = storageReference.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      await docRef.set({
        'productId': productId,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'uploaderEmail': userEmail,
        'phoneNumber': numPhone,
        'description': description,
        'category': _selectedCategory,
        'height': height,
        'weight': weight,
        'age' : numage,
      });

      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product uploaded successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          margin: EdgeInsets.all(10),
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to upload product: $e');
    }
  }

  void _clearFields() {
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _phoneNumberController.clear();
      _descriptionController.clear();
      _weightController.clear();
      _heightController.clear();
      _selectedCategory = null;
      _image = null;
      _age.clear();
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
        centerTitle: true,
        actions: [
          if (_showAddCategoryButton)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addCategory,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? const Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final categories = snapshot.data!.docs
                      .where((doc) => doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('name'))
                      .map((doc) => doc['name'] as String)
                      .toList();


                  return DropdownButtonFormField(
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        child: Text(category),
                        value: category,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value as String?;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: TextField(
                      controller: _age,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadProduct,
                child: const Text('Upload Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
