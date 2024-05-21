import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:led_controll/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isSwitchedOn = false;
  String _statusText = 'OFF';

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan pada node Value
    _databaseRef.child('Value').onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        _isSwitchedOn = data == 1;
        _statusText = _isSwitchedOn ? 'ON' : 'OFF';
      });
    });
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _toggleSwitch(bool value) {
    setState(() {
      _isSwitchedOn = value;
      _statusText = _isSwitchedOn ? 'ON' : 'OFF';
    });
    // Mengirim nilai baru ke Firebase Realtime Database
    _databaseRef.child('Value').set(_isSwitchedOn ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: Text(
              'Welcome, ${user?.email ?? 'Guest'}!',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    _isSwitchedOn ? 'assets/img-2.png' : 'assets/img-1.png'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Transform.scale(
          scale: 2,
          child: Switch.adaptive(
            activeColor: Colors.cyan,
            value: _isSwitchedOn,
            onChanged: _toggleSwitch,
          ),
        ),
      ),
    );
  }
}
