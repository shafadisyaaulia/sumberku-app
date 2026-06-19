import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'pages/landing_page.dart'; // Import halaman gerbang pertama aplikasi

void main() => runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SumberKu',
      useInheritedMediaQuery: true, // Mengaktifkan media query untuk Device Preview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        // Set warna tema dasar hijau teal sesuai identitas SumberKu
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C6B6F)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LandingPage(), // Diarahkan ke LandingPage sebagai tampilan awal
    );
  }
}