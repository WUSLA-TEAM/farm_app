import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productImageUrl;
  final String uploaderEmail;
  final int phonenumber;

  const ProductDetailsScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    required this.uploaderEmail,
    required this.phonenumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Image.network(productImageUrl),
          Text(
            productName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '\$$productPrice',
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
          const Spacer(),
          FloatingActionButton(
            onPressed: ()async {
              String waUrl = "https://wa.me/+91$phonenumber";
              final Uri waUri = Uri.parse(waUrl);

              if (!await launchUrl(waUri)) {
                throw 'Could not open $waUri';
              }
              // Navigator.pushNamed(
              //   context,
              //   '/chat',
              //   arguments: {
              //     'uploaderEmail': uploaderEmail,
              //   },
              // );
            },
            child: const Icon(Icons.chat),
          ),
        ],
      ),
    );
  }
}
