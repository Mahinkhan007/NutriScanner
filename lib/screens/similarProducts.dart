import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductInfoPage extends StatefulWidget {
  final String barcode;

  ProductInfoPage({required this.barcode});

  @override
  _ProductInfoPageState createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  Map<String, dynamic>? _productInfo;
  List<Map<String, dynamic>> _similarProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProductInfo();
  }

  Future<void> fetchProductInfo() async {
    setState(() {
      _isLoading = true;
    });

    final url =
        'https://world.openfoodfacts.org/api/v0/product/${widget.barcode}.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _productInfo = json.decode(response.body) as Map<String, dynamic>;
      });
      await fetchSimilarProducts(_productInfo!['product']['product_name']);
    } else {
      print('Failed to fetch product information: ${response.statusCode}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchSimilarProducts(String productName) async {
    final searchUrl =
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(productName)}&search_simple=1&action=process&json=1';
    final searchResponse = await http.get(Uri.parse(searchUrl));

    if (searchResponse.statusCode == 200) {
      final Map<String, dynamic> searchResult =
          json.decode(searchResponse.body);
      final List<dynamic> products = searchResult['products'];

      setState(() {
        _similarProducts =
            products.map((product) => product as Map<String, dynamic>).toList();
      });
    } else {
      print('Failed to fetch similar products: ${searchResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Product Information'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _productInfo != null
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          _productInfo!['product']['product_name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        _productInfo!['product']['image_url'] != null
                            ? Image.network(
                                _productInfo!['product']['image_url'],
                                height: 200,
                                width: 200,
                                fit: BoxFit.contain,
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 20),
                        Text(
                          'Similar Products',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        _similarProducts.isNotEmpty
                            ? Column(
                                children: _similarProducts.map((product) {
                                  return ListTile(
                                    leading: product['image_url'] != null
                                        ? Image.network(product['image_url'],
                                            width: 50, height: 50)
                                        : SizedBox(width: 50, height: 50),
                                    title: Text(product['product_name']),
                                  );
                                }).toList(),
                              )
                            : Text('No similar products found'),
                      ],
                    ),
                  )
                : Center(
                    child: Text('No product information available.'),
                  ),
      ),
    );
  }
}

void main() {
  runApp(ProductInfoPage(barcode: 'your_barcode_here'));
}
