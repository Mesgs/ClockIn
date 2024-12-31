import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Para salvar localmente
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Seleciona uma data
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Gera o relatório e cria um PDF
  Future<void> _generateReport() async {
    final String name = _nameController.text.trim();
    final String municipality = _municipalityController.text.trim();
    final String startDate = _startDateController.text.trim();
    final String endDate = _endDateController.text.trim();

    if (name.isEmpty || municipality.isEmpty || startDate.isEmpty || endDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    try {
      // Busca o userId na coleção users
      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: name)
          .where('municipality', isEqualTo: municipality)
          .get();

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found!')),
        );
        return;
      }

      final String targetUserId = userSnapshot.docs.first.id;

      // Busca registros de ponto na coleção clock_in_data
      final QuerySnapshot snapshot;
      try {
        snapshot = await _firestore
            .collection('clock_in_data')
            .where('userId', isEqualTo: targetUserId)
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThanOrEqualTo: endDate)
            .get();
      } catch (e) {
        if (e.toString().contains('failed-precondition')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Query requires an index. Follow the link in the error message to create it.',
              ),
            ),
          );
          return;
        } else {
          rethrow;
        }
      }

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records found for the given filters.')),
        );
        return;
      }

      // Gera o PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Report for $name ($municipality)', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text('Period: $startDate to $endDate', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Date', 'First Clock-In', 'First Clock-Out', 'Second Clock-In', 'Second Clock-Out'],
                  data: snapshot.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return [
                      data['date'] ?? '',
                      data['firstShiftClockIn'] ?? '',
                      data['firstShiftClockOut'] ?? '',
                      data['secondShiftClockIn'] ?? '',
                      data['secondShiftClockOut'] ?? '',
                    ];
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );

      // Salva o PDF localmente
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
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
        title: const Text('Reports', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Inform the user:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: _nameController, hint: 'Enter user name'),
            const SizedBox(height: 20),
            const Text(
              'Inform the municipality:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: _municipalityController, hint: 'Enter municipality'),
            const SizedBox(height: 20),
            const Text(
              'Inform the period:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(_startDateController),
                    child: AbsorbPointer(
                      child: _buildTextField(controller: _startDateController, hint: 'Start Date'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('until', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(_endDateController),
                    child: AbsorbPointer(
                      child: _buildTextField(controller: _endDateController, hint: 'End Date'),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'EXPORT TO PDF',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.blue[700],
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}