import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Household Budget',
      theme: ThemeData(primarySwatch: Colors.green),
      home: BudgetHome(),
    );
  }
}

class BudgetHome extends StatefulWidget {
  @override
  _BudgetHomeState createState() => _BudgetHomeState();
}

class _BudgetHomeState extends State<BudgetHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  double groceryBudget = 800.0;
  double gasBudget = 250.0;
  double grocerySpent = 0.0;
  double gasSpent = 0.0;

  TextEditingController groceryController = TextEditingController();
  TextEditingController gasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messaging.requestPermission();
    _loadBudgets();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification?.body ?? 'Update!')),
      );
    });
  }

  void _loadBudgets() async {
    DocumentSnapshot doc = await _firestore.collection('budgets').doc('household').get();
    if (doc.exists) {
      setState(() {
        grocerySpent = doc['grocerySpent'] ?? 0.0;
        gasSpent = doc['gasSpent'] ?? 0.0;
      });
    }
  }

  void _updateBudget(String type, double amount) async {
    if (type == 'grocery') {
      grocerySpent += amount;
      await _firestore.collection('budgets').doc('household').set({
        'grocerySpent': grocerySpent,
        'gasSpent': gasSpent,
      }, SetOptions(merge: true));
      _messaging.sendMessage(to: 'budget_updates', data: {'body': 'Grocery: \
      ```
      \[
      {groceryBudget - grocerySpent} left'});
    } else {
      gasSpent += amount;
      await _firestore.collection('budgets').doc('household').set({
        'grocerySpent': grocerySpent,
        'gasSpent': gasSpent,
      }, SetOptions(merge: true));
      _messaging.sendMessage(to: 'budget_updates', data: {'body': 'Gas: \
      \]GROK_BLOCK_LATEX
      ```
