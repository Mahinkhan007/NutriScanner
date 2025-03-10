import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:nutri_scan/constants.dart';
import 'package:nutri_scan/screens/BMIpage.dart';

class ProductInfoPage extends StatefulWidget {
  final String barcode;

  ProductInfoPage({required this.barcode});

  @override
  _ProductInfoPageState createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _productInfo;
  List<dynamic> _similarProducts = [];
  String? _prosAndCons;

  @override
  void initState() {
    super.initState();
    fetchProductInfo();
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchProductInfo() async {
    setState(() => _isLoading = true);

    var response = await http.get(
      Uri.parse(
          'https://world.openfoodfacts.org/api/v0/product/${widget.barcode}.json'),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result['status'] == 1) {
        setState(() {
          _productInfo = result['product'];
        });
        fetchProsAndCons();
        fetchSimilarProductNames();
      } else {
        print('Product not found.');
        showErrorDialog('Product not found: ${response.statusCode}');
      }
    } else {
      print('Failed to fetch product information.');
      showErrorDialog('Failed to product information: ${response.statusCode}');
    }

    setState(() => _isLoading = false);
  }

  Future<void> fetchProsAndCons() async {
    var headers = {
      'Authorization': 'Bearer ' + open_AIP_Key,
      'Content-Type': 'application/json',
    };

    // Prepare a summary of key nutritional info
    var nutritionalSummary = {
      'calories': _productInfo?['nutriments']['energy-kcal_100g'],
      'sugars': _productInfo?['nutriments']['sugars_100g'],
      'fat': _productInfo?['nutriments']['fat_100g'],
      'protein': _productInfo?['nutriments']['proteins_100g'],
      'fiber': _productInfo?['nutriments']['fiber_100g'],
      'salt': _productInfo?['nutriments']['salt_100g']
    };

    // Create a concise prompt with a clear structure for response
    var prompt =
        'Based on the nutritional data: ${jsonEncode(nutritionalSummary)} for ${_productInfo!['product_name']}, provide two sentences each on pros and cons.';

    var body = jsonEncode({
      'model': 'gpt-3.5-turbo-instruct',
      'prompt': prompt,
      'max_tokens': 300 // Keeping it low to generate concise responses
    });

    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        _prosAndCons = data['choices'][0]['text'];
      });
    } else {
      print('Failed to fetch pros and cons: ${response.statusCode}');
      print(response.body);
    }
  }

  Future<void> fetchSimilarProductNames() async {
    var headers = {
      'Authorization': 'Bearer ' + open_AIP_Key,
      'Content-Type': 'application/json',
    };
    var body = jsonEncode({
      'model': 'gpt-3.5-turbo-instruct',
      'prompt':
          'List three similar products to ${_productInfo!['product_name']} that are available in different brands.',
      'max_tokens': 200
    });

    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var productNames = data['choices'][0]['text'].trim().split('\n');

      if (productNames.isNotEmpty) {
        // Create a list of Future<void> to fetch details for each product
        List<Future<void>> fetchTasks = productNames
            .map<Future<void>>(
                (productName) => fetchProductDetails(productName))
            .toList();

        // Wait for all fetch tasks to complete
        await Future.wait(fetchTasks);
      } else {
        showErrorDialog('No similar products found.');
      }
    } else {
      showErrorDialog('Failed to fetch similar product names.');
    }
  }

  Future<void> fetchProductDetails(String productName) async {
    var response = await http.get(
      Uri.parse(
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$productName&search_simple=1&action=process&json=1'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['products'] != null && data['products'].isNotEmpty) {
        setState(() {
          _similarProducts.add(data['products'][0]);
        });
      }
    } else {
      print('Failed to fetch details for $productName.');
      showErrorDialog(
          'Failed to fetch details for $productName: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Product Information',
        style: TextStyle(color: kPrimaryColor),
      )),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: kPrimaryColor,
            ))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_productInfo != null) ...[
                    ListTile(
                      title: Text(
                        _productInfo!['product_name'] ?? 'No name available',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Barcode: ${widget.barcode}'),
                    ),
                    _productInfo!['image_front_small_url'] != null
                        ? Image.network(_productInfo!['image_front_small_url'])
                        : Container(
                            height: 200,
                            child: Icon(Icons.image_not_supported)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Pros and Cons: ${_prosAndCons ?? "No data available"}',
                      ),
                    ),
                    Divider(
                      color: kPrimaryColor,
                    ),
                    Text('Nutritional Facts',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor)),
                    SizedBox(height: 10),
                    _buildNutritionalTable(),
                    Divider(
                      color: kPrimaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Similar Products:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor)),
                    ),
                    if (_similarProducts.isEmpty)
                      Center(
                          child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ))
                    else
                      ..._similarProducts
                          .map((product) => ListTile(
                                leading:
                                    product['image_front_small_url'] != null
                                        ? Image.network(
                                            product['image_front_small_url'],
                                            width: 50,
                                            height: 50)
                                        : Icon(Icons.broken_image, size: 50),
                                title: Text(product['product_name'] ??
                                    'Unknown product'),
                              ))
                          .toList(),
                  ],
                  if (_productInfo == null)
                    Text('No product information available.'),
                ],
              ),
            ),
    );
  }

  Widget _buildNutritionalTable() {
    List<String> importantNutrients = [
      'energy_100g', // Energy usually in kJ or kcal
      'proteins_100g',
      'fat_100g',
      'carbohydrates_100g',
      'sugars_100g',
      'fiber_100g',
      'salt_100g',
      'vitamins', // You may need to handle each vitamin separately
      'minerals' // You may need to handle each mineral separately
    ];

    return Table(
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Nutrient',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Amount per 100g',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        ...importantNutrients.map((nutrient) {
          var nutrientName = nutrient
              .replaceAll('_100g', '')
              .replaceAll('_', ' ')
              .capitalize();
          var nutrientValue =
              _productInfo!['nutriments'][nutrient]?.toString() ??
                  'Not available';
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(nutrientName),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(nutrientValue),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  String capitalize(String input) =>
      input[0].toUpperCase() + input.substring(1);
}
