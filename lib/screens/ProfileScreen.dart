import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  String _selectedIcon = 'assets/icons/icon1.png';
  String _email = '';
  String _creationDate = '';
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserEmailAndDate();
  }

  Future<void> _loadUserProfile() async {
    String uid = _auth.currentUser?.uid ?? '';
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        _firstNameController.text = userDoc['firstName'] ?? '';
        _lastNameController.text = userDoc['lastName'] ?? '';
        _selectedIcon = userDoc['profileIcon'] ?? 'assets/icons/icon1.png';
      });
    }
  }

  Future<void> _loadUserEmailAndDate() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? 'Correo no disponible';
        _creationDate = user.metadata.creationTime != null
            ? '${user.metadata.creationTime!.year}-${user.metadata.creationTime!.month}-${user.metadata.creationTime!.day}'
            : 'Fecha desconocida';
      });
    }
  }

  Future<void> _saveUserProfile() async {
    String uid = _auth.currentUser?.uid ?? '';
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'profileIcon': _selectedIcon,
    }, SetOptions(merge: true));

    // Mostrar confirmación de guardado
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Perfil guardado exitosamente'),
      backgroundColor: Colors.green,
    ));
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(_selectedIcon),
            ),
            SizedBox(height: 16),
            Text(
              'Selecciona un ícono de perfil:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            // Row of icons to select from
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = 'assets/icons/icon1.png';
                    });
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/icons/icon1.png'),
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = 'assets/icons/icon2.png';
                    });
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/icons/icon2.png'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Apellido',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correo: $_email',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cuenta creada el: $_creationDate',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, 
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Guardar Perfil', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red, 
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
