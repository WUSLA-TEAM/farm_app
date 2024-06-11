import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productImageUrl;
  final String uploaderEmail;
  final int phonenumber;
  final String description;
  final String category;
  final String weight;
  final String height;

  const ProductDetailsScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    required this.uploaderEmail,
    required this.phonenumber,
    required this.description,
    required this.category,
    required this.weight,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: ()async {
              String waUrl = "https://wa.me/+91$phonenumber";
              final Uri waUri = Uri.parse(waUrl);

              if (!await launchUrl(waUri)) {
                throw 'Could not open $waUri';
              }
            },
            child: const Icon(Icons.chat),
          ),
      body: Column(
        children: [
          Image.network(productImageUrl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                productName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
            'Rupees $productPrice',
            style: TextStyle(fontSize: 25 , color: Colors.green[700], fontWeight: FontWeight.bold),
          ),
            ],
          ),
          
          Text(
            '$description',
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
          Text(
            '$category',
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
          Text(
            'height: $height m',
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
          Text(
            'weight: $weight kg',
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
          const Spacer(),
          
        ],
      ),
    );
  }
}
