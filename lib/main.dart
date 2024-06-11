import 'package:farm_app/src/AuthService.dart';
import 'package:farm_app/src/ChatScreen.dart';
import 'package:farm_app/src/HomeScreen.dart';
import 'package:farm_app/src/LoginScreen.dart';
import 'package:farm_app/src/productList_screen.dart';
import 'package:farm_app/src/sign_up_screen.dart';
import 'package:farm_app/src/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox('userBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Farm App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return authProvider.isUserLoggedIn() ? HomeScreen() : LoginScreen();
          },
        ),
        routes: {
          '/signup': (context) => SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/upload': (context) => UploadScreen(),
          '/chat': (context) => ChatScreen(productId: '', receiverEmail: ''), // Assuming you have a ChatScreen
          '/productlist' : (context) => ProductListScreen(),
        },
      ),
    );
  }
}
