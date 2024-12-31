import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? selectedDate;
  TimeOfDay? firstShiftClockIn;
  TimeOfDay? firstShiftClockOut;
  TimeOfDay? secondShiftClockIn;
  TimeOfDay? secondShiftClockOut;

  final Set<DateTime> markedDates = {}; // Datas com ponto registrado.

  @override
  void initState() {
    super.initState();
    _loadMarkedDates();
  }

  // Carrega as datas registradas no Firestore
  Future<void> _loadMarkedDates() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('clock_in_data')
          .where('userId', isEqualTo: user.uid) // Filtra pelo UID do usuário
          .get();

      final dates = snapshot.docs.map((doc) {
        final dateStr = doc['date'] as String;
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      }).toSet();

      setState(() {
        markedDates.addAll(dates);
      });
    } catch (e) {
      _showDialog("Error", "Failed to load marked dates: $e");
    }
  }

  // Mostra o seletor de data com marcações
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Salva os dados no Firestore
  Future<void> _saveData() async {
    if (selectedDate == null ||
        firstShiftClockIn == null ||
        firstShiftClockOut == null ||
        secondShiftClockIn == null ||
        secondShiftClockOut == null) {
      _showDialog("Error", "Please fill in all fields before saving.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showDialog("Error", "No user logged in. Please log in to save data.");
      return;
    }

    try {
      // Adiciona os dados à coleção 'clock_in_data'
      await FirebaseFirestore.instance.collection('clock_in_data').add({
        'userId': user.uid, // Conexão com a coleção 'users'
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'firstShiftClockIn': firstShiftClockIn!.format(context),
        'firstShiftClockOut': firstShiftClockOut!.format(context),
        'secondShiftClockIn': secondShiftClockIn!.format(context),
        'secondShiftClockOut': secondShiftClockOut!.format(context),
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        markedDates.add(selectedDate!);
        selectedDate = null;
        firstShiftClockIn = null;
        firstShiftClockOut = null;
        secondShiftClockIn = null;
        secondShiftClockOut = null;
      });

      _showDialog("Success", "Clock-in data has been saved successfully!");
    } catch (e) {
      _showDialog("Error", "Failed to save data: $e");
    }
  }

  // Mostra um diálogo com mensagem
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Método para selecionar horário
  Future<void> _selectTime(BuildContext context, bool isClockIn, bool isFirstShift) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isFirstShift) {
          if (isClockIn) {
            firstShiftClockIn = pickedTime;
          } else {
            firstShiftClockOut = pickedTime;
          }
        } else {
          if (isClockIn) {
            secondShiftClockIn = pickedTime;
          } else {
            secondShiftClockOut = pickedTime;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Did you\nclock in today?',
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enter Date',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Select date',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Time',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildTimeField('Clock-in time for the 1st shift', firstShiftClockIn, true, true),
            const SizedBox(height: 10),
            _buildTimeField('Clock-out time for the 1st shift', firstShiftClockOut, false, true),
            const SizedBox(height: 10),
            _buildTimeField('Clock-in time for the 2nd shift', secondShiftClockIn, true, false),
            const SizedBox(height: 10),
            _buildTimeField('Clock-out time for the 2nd shift', secondShiftClockOut, false, false),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: const StadiumBorder(),
              ),
              child: const Text('SAVE', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, bool isClockIn, bool isFirstShift) {
    return GestureDetector(
      onTap: () => _selectTime(context, isClockIn, isFirstShift),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time != null ? time.format(context) : '00 : 00',
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}