import 'package:flutter/foundation.dart';

const String baseUrl = kIsWeb
    ? 'http://192.168.2.102:8080' // IP nội bộ cho Flutter Web
    : 'http://10.0.2.2:8080';     // Android emulator
