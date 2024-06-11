import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isUserLoggedIn() {
    var box = Hive.box('userBox');
    return box.get('userEmail') != null;
  }

  String? getUserEmail() {
    var box = Hive.box('userBox');
    return box.get('userEmail');
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      var box = Hive.box('userBox');
      box.put('userEmail', userCredential.user!.email);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get productsStream {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      var box = Hive.box('userBox');
      box.put('userEmail', userCredential.user!.email);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    var box = Hive.box('userBox');
    box.delete('userEmail');
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
