import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:tachomi_novel/ads/src/multi_ads_factory.dart';
import 'package:tachomi_novel/const.dart';
import 'package:tachomi_novel/main.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      var url = Uri.parse(Constants.jsonConfigUrl);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data2 = json.decode(response.body);
        gAds = MultiAds(response.body);
        await gAds.init();
        await gAds.loadAds();

        isInterShowed = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TachomiNovelApp()),
        );
      } else {
        await Future.delayed(const Duration(seconds: 2), () {
          _showErrorSnackbar('You are offline');
          setState(() {
            isLoading = false;
          });
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      await Future.delayed(const Duration(seconds: 2), () {
        _showErrorSnackbar(
            'Failed to load configuration. Please check your internet connection.');
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void _showErrorSnackbar(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          txt,
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xff33FD24),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  color: const Color(0xff33FD24),
                  backgroundColor: Colors.grey[800],
                  strokeWidth: 3,
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff33FD24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  _initializeApp();
                },
                child: Text(
                  'Try Again',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
