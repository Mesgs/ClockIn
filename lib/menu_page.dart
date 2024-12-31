import 'package:flutter/material.dart';
import 'home_page.dart'; // Importação da página Home
import 'reports_page.dart';// Importação da página Reports
import 'login_page.dart'; // Importação da página Login
import 'updateprofile_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cor de fundo da tela de menu
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Retorna para a tela anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.person, size: 50, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
                );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'User',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Your account',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Botões
            _buildMenuButton(Icons.home, 'Home', context),
            const SizedBox(height: 20),
            _buildMenuButton(Icons.description, 'Reports', context),
            const SizedBox(height: 20),
            _buildMenuButton(Icons.login, 'Login', context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String title, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navegar para a página correspondente
        if (title == 'Home') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (title == 'Reports') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportsPage()),
          );
        } else if (title == 'Logout') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
